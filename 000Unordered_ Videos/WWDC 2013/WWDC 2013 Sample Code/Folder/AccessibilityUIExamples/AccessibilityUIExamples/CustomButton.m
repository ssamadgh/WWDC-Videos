/*
 
     File: CustomButton.m
 Abstract: Custom view that behaves like a button.
  Version: 2.0
 
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

#import "CustomButton.h"

// IMPORTANT: This is not a template for developing a custom button. This sample is
// intended to demonstrate how to add accessibility to UI that may not have been
// ideally designed. For information on how to create custom controls please visit
// http://developer.apple.com

@implementation CustomButton

@synthesize actionHandler = mActionHandler;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Register for mouse events that affect drawing.
        NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                                    options:NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow | NSTrackingEnabledDuringMouseDrag
                                                                      owner:self
                                                                   userInfo:nil];
        [self addTrackingArea:trackingArea];
    }
    
    return self;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)drawFocusRingMask
{
    NSRectFill([self bounds]);
}

- (NSRect)focusRingMaskBounds
{
    return [self bounds];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSImage *upImage = [bundle imageForResource:@"CustomButtonUp"];
    NSImage *highlightedImage = [bundle imageForResource:@"CustomButtonHighlight"];
    NSImage *depressedImage = [bundle imageForResource:@"CustomButtonDown"];
    
    NSImage *imageToDraw = upImage;
    
    if ( mShowDepressed )
    {
        imageToDraw = depressedImage;
    }
    else if ( mShowHighlighted )
    {
        imageToDraw = highlightedImage;
    }
    
    [imageToDraw drawInRect:[self bounds] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}

- (void)performPress
{
    // Set down and release after momentary delay so it flickers.
    [self pressDown];

    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self pressUpInside:YES andHighlight:NO];
    });
}

- (void)pressDown
{
    mIsPressed = YES;
    mShowDepressed = YES;
    [self setNeedsDisplay:YES];
}

- (void)pressUpInside:(BOOL)inside andHighlight:(BOOL)shouldHighlight
{
    mIsPressed = NO;
    mShowDepressed = NO;
    mShowHighlighted = shouldHighlight ? inside : NO;
    [self setNeedsDisplay:YES];
    
    if ( inside )
    {
        [mActionHandler pressButton:self];
    }
}

#pragma mark Mouse events

- (void)mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];
    [self pressDown];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [super mouseUp:theEvent];
    NSPoint localPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    BOOL isInside = NSPointInRect(localPoint, self.bounds);
    [self pressUpInside:isInside andHighlight:YES];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    [super mouseEntered:theEvent];
    mShowHighlighted = YES;
    mShowDepressed = mIsPressed; // Restore pressed state, possibly set before mouseExited.
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [super mouseExited:theEvent];
    mShowHighlighted = mIsPressed;
    mShowDepressed = NO;
    [self setNeedsDisplay:YES];
}

#pragma mark Keyboard events

- (void)keyDown:(NSEvent *)theEvent
{
    if ([[theEvent characters] isEqualToString:@" "])
    {
        [self performPress];
    }
    else
    {
        [super keyDown:theEvent];
    }
}

@end
