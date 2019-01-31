/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A NSView subclass showing how to draw and handle simple events.
 */

import Cocoa

class DotView: NSView {

    // We initialize the instance variables here in the same way they are
    // initialized in the storyboard. This is adequate, but a better solution is to make
    // sure the two places are initialized from the same place. Slightly more
    // sophisticated apps which load storyboards for each document or window would initialize
    // UI elements at the time they're loaded from values in the app.

    var color: NSColor = .red {

        // This property observer tells AppKit that the view needs to redraw after this property is changed
        didSet {
            self.needsDisplay = true
        }
    }

    var radius: CGFloat = 10 {

        // This property observer tells AppKit that the view needs to redraw after this property is changed
        didSet {
            self.needsDisplay = true
        }
    }

    var center = NSPoint(x: 50, y: 50) {

        // This property observer tells AppKit that the view needs to redraw after this property is changed
        didSet {
            
            self.needsDisplay = true
        }
    }

    // draw(_:) should be overridden in subclassers of NSView to do necessary
    // drawing in order to create the look of the view. It will be called
    // to draw the whole view or parts of it (pay attention the dirtyRect argument);
    // it will also be called during printing if your app is set up to print.
    // In DotView, we first clear the view to white, then draw the dot at its
    // current location and size.
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        NSColor.white.set()
        self.bounds.fill()

        var dotRect = NSRect()
        dotRect.origin.x = center.x - radius
        dotRect.origin.y = center.y - radius

        let size = 2 * radius
        dotRect.size.width = size
        dotRect.size.height = size

        color.set()
        let path = NSBezierPath(ovalIn: dotRect)
        path.fill()
    }

    // Views which totally redraw their whole bounds without needing any of the
    // views behind it should override isOpaque to return true. This is a performance
    // optimization hint for the display subsystem. This applies to DotView, whose
    // draw(_:) fills the whole rect with a solid, opaque color.
    override var isOpaque: Bool {
        return true
    }
}
