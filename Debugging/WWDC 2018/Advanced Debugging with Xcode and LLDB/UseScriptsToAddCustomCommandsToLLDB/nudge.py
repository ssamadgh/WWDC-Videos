""" File: nudge.py
    
An lldb Python script to add a nudge command.

Add to ~/.lldbinit:
    command script import ~/path/to/nudge.py

Usage:
    (lldb) nudge x-offset y-offset [view]

Examples:
    (lldb) nudge 0 100 self.view
    (lldb) nudge 1 0 "[self view]"
    (lldb) nudge -1 -1 0x0123456f
    (lldb) nudge 5 5

References:
    "LLDB Python Reference" https://lldb.llvm.org/python-reference.html
    "LLDB Python Classes Reference Guide" https://lldb.llvm.org/python_reference/index.html
    "Python Command Template" http://llvm.org/svn/llvm-project/lldb/trunk/examples/python/cmdtemplate.py
    "WWDC 2018 Session 412: Advanced Debugging with Xcode and LLDB" https://developer.apple.com/wwdc18/412

Acknowledgements:
    See the ACKNOWLEDGMENTS.txt file
"""

__copyright__ = 'Copyright (c) 2018 Apple Inc.'
__license__ = 'MIT'


# Python's LLDB API.
import lldb
# Use Python's simple lexical analysis module for argument splitting.
import shlex
# Use argparse for parsing command-line arguments and options.
import argparse


class NudgeCommand:
    target_view = None              # A pointer to the view being nudged. Persisted across calls for convenience and total offset tracking.
    original_center = None          # Tracks the original center point of the target view before it was nudged.
    total_center_offset = (0, 0)    # Tracks the total offset applied to the target view.

    def evaluate_view_expression(self, view_expression, target):
        # Expression options to evaluate the view expression using the language of the current stack frame.
        exprOptions = lldb.SBExpressionOptions()
        exprOptions.SetIgnoreBreakpoints()

        # Get a pointer to the view by evaluating the user-provided expression (in the language of the current frame).
        result = target.EvaluateExpression(view_expression, exprOptions)
        
        if result.GetValue() is None:
            return result.GetError()
        else:
            if self.target_view and self.target_view.GetValue() != result.GetValue():
                # Reset center-point offset tracking for new target view.
                self.original_center = None
                self.total_center_offset = (0.0, 0.0)
            
            self.target_view = result
            return None     # No error

    def nudge(self, x_offset, y_offset, target, command_result):
        """ Adjusts the center point of the target view by (x_offset, y_offset) points.
            target specifies the execution context target to use for expression evaluation.
        """
        # Expression options to evaluate embedded Objective-C expressions.
        exprOptions = lldb.SBExpressionOptions()
        exprOptions.SetIgnoreBreakpoints()
        exprOptions.SetLanguage(lldb.eLanguageTypeObjC)

        # Fetch view.center and extract x and y member values.
        centerExpression = "(CGPoint)[(UIView *)%s center]" %(self.target_view.GetValue())
        centerValue = target.EvaluateExpression(centerExpression, exprOptions)
        center_x = float(centerValue.GetChildMemberWithName('x').GetValue())
        center_y = float(centerValue.GetChildMemberWithName('y').GetValue())
        
        if self.original_center is None:
            self.original_center = (center_x, center_y)
        
        # Adjust the x,y center values by adding the offsets.
        center_x += x_offset
        center_y += y_offset
        
        # Set the new view.center.
        setExpression = "(void)[(UIView *)%s setCenter:(CGPoint){%f, %f}]" %(self.target_view.GetValue(), center_x, center_y)
        target.EvaluateExpression(setExpression, exprOptions)
        
        # Tell CoreAnimation to flush view updates to the screen.
        target.EvaluateExpression("(void)[CATransaction flush]", exprOptions)

        # Update total offset.
        self.total_center_offset = (center_x - self.original_center[0], center_y - self.original_center[1])

        # Output the total offset applied to this view (tracked over multiple calls for the same view).
        command_result.PutCString("Total offset: (%0.1f, %0.1f)" %self.total_center_offset)

        # Fetch the new view.frame and output it as a convenience for the user.
        frameExpression = "(CGRect)[(UIView *)%s frame]" %(self.target_view.GetValue())
        frameValue = target.EvaluateExpression(frameExpression, exprOptions)
        command_result.PutCString(str(frameValue))

    def get_valid_target(self, exe_ctx):
        # Must be debugging a process.
        if exe_ctx.process.IsValid() == False:
            raise RuntimeError("No process is being debugged.")

        # There must be an execution context target for expression evaluation.
        target = exe_ctx.target
        if target is None:
            raise RuntimeError("No target available for evaluating expressions.")

        return target

    def create_options(self):
        usage = "usage: %(prog)s <x-offset> <y-offset> [view expression]"
        description = '''This command can be used to nudge the position of a view (UIView/NSView) instance and
flush the current CATransaction so that the change is visible on-screen, even while paused
in the debugger.

A view instance must be specified the first time. Thereafter, specifying the view is optional,
as the previously specified view will be used if left out.  The total offset for the view is
tracked across multiple calls and displayed after each nudge.
'''

        # Create the argument parser.  Disable help as lldb's help system will take care of it.
        self.parser = argparse.ArgumentParser(
            description=description,
            prog = 'nudge',
            usage = usage,
            add_help = False)

        # Parse two floating point arguments for the x,y offset.
        self.parser.add_argument(
            'offsets',
            metavar='offset',
            type=float,
            nargs=2,
            help='x/y offsets')

        # Parse all remaining arguments as the expression to evalute for the target view.
        self.parser.add_argument(
            'view_expression',
            metavar='view_expression',
            type=str,
            nargs='*',
            help='target view expression')

    def get_short_help(self):
        return "Nudge a view's center position."

    def get_long_help(self):
        return self.help_string

    def __init__(self, debugger, unused):
        self.create_options()
        self.help_string = self.parser.format_help()

    def __call__(self, debugger, command, exe_ctx, result):
        """ Command entry point.
        """
        # Use the shell Lexer to properly parse command args & options just like a shell would.
        command_args = shlex.split(command)
        
        try:
            # Parse the arguments into objects. Aborts with error if any arguments are incorrectly formatted (e.g. offsets are not floats).
            args = self.parser.parse_args(command_args)
        except:
            return

        # There must be an execution context target for expression evaluation.
        try:
            target = self.get_valid_target(exe_ctx)
        except RuntimeError as error:
            result.SetError(str(error))
            return

        # If optional 3rd argument is supplied, then evaluate it to get the target view reference.
        if len(args.view_expression) > 0:
            view_expression = ' '.join(args.view_expression)
            expr_error = self.evaluate_view_expression(view_expression, target)
            if expr_error is not None:
                result.SetError(str(expr_error))
                return

        # Cannot continue if no target view has been specified.
        if self.target_view is None:
            result.SetError("No view expression has been specified.")
            return

        # X and Y offsets are already parsed as floats.
        x_offset = args.offsets[0]
        y_offset = args.offsets[1]

        # We have everything we need to nudge the view.
        self.nudge(x_offset, y_offset, exe_ctx.target, result)


def __lldb_init_module(debugger, dict):
    # This initializer is being run from LLDB in the embedded command interpreter.

    # Add the command to LLDB.
    debugger.HandleCommand('command script add -c nudge.NudgeCommand nudge')
    print 'The "nudge" command has been installed, type "help nudge" for detailed help.'
