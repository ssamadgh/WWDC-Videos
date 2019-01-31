/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A NSViewController subclass showing how to use IBActions to manipulate a view, and how to use UndoManager.
 */

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var dotView: DotView!
    
    // radiusChanged(_:) is an action method which lets you change the radius of the dot.
    // A possible optimization is to check to see if the old and new value is the same,
    // and not do anything if so.
    @IBAction func radiusChanged(_ sender: NSSlider) {
        updateRadius(CGFloat(sender.doubleValue))
    }

    // Having a method which takes the updated radius value as a parameter means that undo can just call this same method
    // with the previous value. This also makes redo work without any extra code.
    private func updateRadius(_ radius: CGFloat) {
        if let undoManager = undoManager {

            undoManager.registerUndo(withTarget: self, handler: { [previousRadius = dotView.radius] (_) -> Void in
                self.updateRadius(previousRadius)
            })
            undoManager.setActionName("Change Radius")
        }

        dotView.radius = radius
    }

    // colorChanged(_:) is an action method which lets you change the color of the dot.
    // A possible optimization is to check to see if the old and new value is the same,
    // and not do anything if so.
    @IBAction func colorChanged(_ sender: NSColorWell) {
        updateColor(sender.color)
    }

    private func updateColor(_ color: NSColor) {
        if let undoManager = undoManager {
            undoManager.registerUndo(withTarget: self, handler: { [previousColor = dotView.color] (_) -> Void in
                self.updateColor(previousColor)
            })
            undoManager.setActionName("Change Color")
        }

        dotView.color = color
    }

    // The recommended way to handle events is to override NSResponder (superclass
    // of NSView) methods in the NSView subclass. One such method is mouseUp(with:).
    // These methods get the event as the argument. The event has the mouse
    // location in window coordinates; use convert(_:from:) (with "nil"
    // as the view argument) to convert this point to view coordinates local
    // to dotView.
    //
    // Note that once we set the new center, needsDisplay is set to true in the center
    // property's didSet observer to mark that the view needs to be redisplayed (which
    // is done automatically by AppKit).
    override func mouseUp(with event: NSEvent) {
        let convertedCenter = dotView.convert(event.locationInWindow, from: nil)
        updateCenter(convertedCenter)
    }

    private func updateCenter(_ center: NSPoint) {
        // Since the previous center was already converted from the window coordinates
        // before setting it as the dotView's center, there is no need to convert
        // previousCenter from window coordinates.
        if let undoManager = undoManager {
            undoManager.registerUndo(withTarget: self, handler: { [previousCenter = dotView.center, unowned self] (_) -> Void in
                self.updateCenter(previousCenter)
            })
            undoManager.setActionName("Change Center")
        }

        dotView.center = center
    }
}
