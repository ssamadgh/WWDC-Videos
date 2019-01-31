# DotViewUndo

DotViewUndo is a small application which demonstrates a small subclass of NSView for:

1. drawing
2. event handling
3. target/action handling
4. undo support

See comments in `DotView.swift` for more info.  Also refer to `Main.storyboard` and `ViewController.swift` to see the instance of DotView in the application and the controls connected to it.

This sample implements undo support by declaring DotView's attributes (radius, center, and color) as properties, then by register undo actions in the IBAction and NSResponder methods that change those properties.

Adding undo is simple: Whenever some state changes which should be undoable, simply tell the appropriate (in this case, per-window) undo manager what call to make to undo that state change. This call is often the same method with the previous value. With this, redo also becomes automatic.  

To tell the undo manager how to undo, use
```
 public func registerUndo<TargetType>(withTarget target: TargetType, handler: @escaping (TargetType) -> Swift.Void) where TargetType : AnyObject
```

which allows registering a closure containing the undo logic.

Direct use of NSUndoManager would be unnecessary in a CoreData based app — CoreData helps with the object lifecycle management, including undo/redo; in such cases your key value coding (KVC) compliant objects will automatically have undo/redo support. (You can still use NSUndoManager in those cases for further customization.)

## Requirements

### Build

Requires Xcode 9.0 and macOS 10.13 SDK

### Runtime
macOS 10.11 or later
