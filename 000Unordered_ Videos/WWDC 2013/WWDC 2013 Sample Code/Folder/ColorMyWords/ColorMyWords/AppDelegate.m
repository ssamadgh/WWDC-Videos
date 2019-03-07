/*
     File: AppDelegate.m
 Abstract: Implementation of the AppDelegate. Manages all of the JavaScript plugin logic to allow color highlighting of its NSTextView.
 
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 
 Copyright © 2013 Apple Inc. All rights reserved.
 WWDC 2013 License
 
 NOTE: This Apple Software was supplied by Apple as part of a WWDC 2013
 Session. Please refer to the applicable WWDC 2013 Session for further
 information.
 
 IMPORTANT: This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and
 your use, installation, modification or redistribution of this Apple
 software constitutes acceptance of these terms. If you do not agree with
 these terms, please do not use, install, modify or redistribute this
 Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple
 Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple. Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis. APPLE MAKES
 NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE
 IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 EA1002
 5/3/2013
 */

#import "AppDelegate.h"
#import <JavaScriptCore/JavaScriptCore.h>

@implementation AppDelegate {
    JSContext *_context;
    JSManagedValue *_colorPlugin;
}

@synthesize textView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self.textView setAutomaticSpellingCorrectionEnabled:NO];
    [self.textView setContinuousSpellCheckingEnabled:NO];
    [self.textView.textStorage setDelegate:self];
    [self loadColorsPlugin];
    [self.textView setString:@"The quick brown fox jumped over the lazy red dog to eat the yellow hen in the blue coop."];
    [self refreshColors];
}

- (void)loadColorsPlugin
{    
    // Load the plugin script from the bundle.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"colors" ofType:@"js"];
    NSString *pluginScript = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    _context = [[JSContext alloc] init];
    
    // We insert the AppDelegate into the global object so that when we call
    // -addManagedReference:withOwner: for the plugin object we're about to load
    // and pass the AppDelegate as the owner, the AppDelegate itself is reachable from
    // within JavaScript. If we didn't do this, the AppDelegate wouldn't be reachable
    // from JavaScript, and there wouldn't be anything keeping the plugin object alive.
    _context[@"AppDelegate"] = self;
    
    // Insert a block so that the plugin can create NSColors to return to us later.
    _context[@"makeNSColor"] = ^(NSDictionary *rgb){
        return [NSColor colorWithRed:[rgb[@"red"] floatValue] / 255.0f
                               green:[rgb[@"green"] floatValue] / 255.0f
                                blue:[rgb[@"blue"] floatValue] / 255.0f
                               alpha:1.0f];
    };
    
    JSValue *plugin = [_context evaluateScript:pluginScript];
    
    _colorPlugin = [JSManagedValue managedValueWithValue:plugin];
    [_context.virtualMachine addManagedReference:_colorPlugin withOwner:self];
    [self.window setDelegate:self];
}

- (void)unloadColorsPlugin
{
    [_context.virtualMachine removeManagedReference:_colorPlugin withOwner:self];
    _colorPlugin = nil;
    _context = nil;
}

- (void)windowWillClose:(NSNotification *)notification
{
    // We created a cycle when we inserted the AppDelegate into the JSContext
    // that the AppDelegate itself owns. When we close the window, we need to
    // break that cycle.
    [self unloadColorsPlugin];
}

- (IBAction)didClickShuffleButton:(id)sender
{
    JSValue *plugin = [_colorPlugin value];
    JSValue *shuffleFunction = plugin[@"shuffle"];
    [shuffleFunction callWithArguments:@[]];
    
    [self refreshColors];
}

- (IBAction)didClickResetButton:(id)sender
{
    JSValue *plugin = [_colorPlugin value];
    JSValue *resetFunction = plugin[@"reset"];
    [resetFunction callWithArguments:@[]];
    
    [self refreshColors];
}

- (IBAction)didClickReloadButton:(id)sender
{
    [self unloadColorsPlugin];
    [self loadColorsPlugin];
    [self refreshColors];
}

- (void)refreshColors
{
    // Get the words from the NSTextView.
    NSTextStorage *textStorage = [self.textView textStorage];
    NSString *textBody = [textStorage string];
    NSCharacterSet *whiteSpace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSArray *words = [textBody componentsSeparatedByCharactersInSet:whiteSpace];
    
    // Get the callback from the plugin.
    JSValue *plugin = [_colorPlugin value];
    JSValue *colorForWordFunction = plugin[@"colorForWord"];
    
    // Remove all the old formatting.
    [textStorage removeAttribute:NSBackgroundColorAttributeName range:NSMakeRange(0, [textBody length])];
    [textStorage removeAttribute:NSForegroundColorAttributeName range:NSMakeRange(0, [textBody length])];
    
    NSUInteger bodyOffset = 0;
    for (NSUInteger i = 0; i < [words count]; i++) {
        // Skip over whitespace at the end of words.
        while (bodyOffset < [textBody length] && [whiteSpace characterIsMember:[textBody characterAtIndex:bodyOffset]])
            bodyOffset++;
        
        NSString *word = [words objectAtIndex:i];
        NSRange wordRange = NSMakeRange(bodyOffset, [word length]);
        
        // Get the color from the plugin and highlight the word with it.
        NSColor *color = [[colorForWordFunction callWithArguments:@[word]] toObject];
        if (color) {
            [textStorage addAttribute:NSBackgroundColorAttributeName value:color range:wordRange];
            [textStorage addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:wordRange];
        }
        
        bodyOffset += [word length];
    }
}

- (void)textStorageDidProcessEditing:(NSNotification *)aNotification
{
    [self refreshColors];
}

@end
