/*
 
     File: TwoPositionSwitchCell.m
 Abstract: Cell class for the two-position switch.
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

#import "TwoPositionSwitchCell.h"
#import "TwoPositionSwitch.h"

@implementation TwoPositionSwitchCell

- (NSRect)knobRectFlipped:(BOOL)inFlipped
{
    double aMinValue = [self minValue];
    double aMaxValue = [self maxValue];
    double aValue = [self doubleValue];
    double aPercent = (aMaxValue <= aMinValue) ? 0.0 : (aValue - aMinValue) / (aMaxValue - aMinValue);

    NSImage* aKnobImage = [NSImage imageNamed:@"SwitchHandle"];
    NSRect aKnobRect = NSMakeRect(0, 0, [aKnobImage size].width, [aKnobImage size].height);

    NSRect aTrackRect = [self trackRect];
    double offset = floor((NSWidth(aTrackRect) - NSWidth(aKnobRect) + 4.0) * aPercent ) - 4.0;

    aKnobRect.origin = NSMakePoint(aTrackRect.origin.x + offset, 2.0);

    return NSIntegralRect( aKnobRect );
}

- (void)drawKnob:(NSRect)rect
{
    NSImage* anImage = [NSImage imageNamed:_scFlags.isPressed ? @"SwitchHandleDown" : @"SwitchHandle"];
    [anImage drawAtPoint:rect.origin fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:([self isEnabled] ? 1.0 : 0.5)];
}

- (void)drawBarInside:(NSRect)aRect flipped:(BOOL)flipped
{
    // avoid drawing the track
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSImage* aImage = [NSImage imageNamed:@"SwitchWell"];
    NSPoint trackPoint = cellFrame.origin;
    trackPoint.y += 1.0;

    if( [(NSSlider*)controlView isEnabled] )
    {
        [aImage drawAtPoint:trackPoint fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
    }
    else
    {
        [aImage drawAtPoint:trackPoint fromRect:NSZeroRect operation:NSCompositePlusLighter fraction:1.0];
        [aImage drawAtPoint:trackPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:0.3];
    }

    aImage = [NSImage imageNamed: @"SwitchOverlayMask"];
    trackPoint.y -= 1.0;

    BOOL focused = [self showsFirstResponder] && ([self focusRingType] != NSFocusRingTypeNone);
    if ( focused )
    {
        [aImage drawAtPoint:trackPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    }

    [super drawInteriorWithFrame:cellFrame inView:controlView];

    if( !focused )
    {
        [aImage drawAtPoint:trackPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    }
}

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView
{
    if ([(TwoPositionSwitch *)controlView isAnimating])
    {
        return NO;
    }

    // Don't track if mouseDown is not on the knob
    NSRect aKnobRect = [self knobRectFlipped:[controlView isFlipped]];
    if (NSPointInRect(startPoint, aKnobRect))
    {
        _trackingState = SwitchKnobClickedState;
        return [super startTrackingAt:startPoint inView:controlView];
    }

    _trackingState = SwitchTrackClickedState;
    return YES;
}

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView *)controlView
{
    if ( (_trackingState == SwitchKnobClickedState) && !NSEqualPoints(lastPoint, currentPoint) && !NSEqualPoints(lastPoint, NSZeroPoint) )
    {
        _trackingState = SwitchKnobMovedState;
    }

    else if ( _trackingState == SwitchTrackClickedState )
    {
        return YES;
    }

    return [super continueTracking:lastPoint at:currentPoint inView:controlView];
}


- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag
{
    [super stopTracking:lastPoint at:stopPoint inView:controlView mouseIsUp:flag];

    TwoPositionSwitch *aSwitch = (TwoPositionSwitch *)[self controlView];
    double startValue = [aSwitch targetValue];
    double aValue = [self doubleValue];

    switch( _trackingState )
    {
        case SwitchKnobClickedState:
        case SwitchTrackClickedState:
            [aSwitch setDoubleValue:(startValue == 0.0) ? 1.0 : 0.0 animate:YES];
            break;
        case SwitchKnobMovedState:
            if ( ABS(startValue - aValue) < 0.2 )
            {
                [aSwitch setDoubleValue:startValue animate:YES];
            }
            else
            {
                [aSwitch setDoubleValue:(startValue == 0.0) ? 1.0 : 0.0 animate:YES];
            }
            break;
    }
}

#pragma mark Accessibility

- (NSArray *)accessibilityAttributeNames
{
    static NSMutableArray *attributes = nil;
    if ( attributes == nil )
    {
        attributes = [[super accessibilityAttributeNames] mutableCopy];
        NSArray *removeAttributes = @[NSAccessibilityChildrenAttribute,
                                      NSAccessibilityAllowedValuesAttribute,
                                      NSAccessibilityMaxValueAttribute,
                                      NSAccessibilityMinValueAttribute];
        
        for ( NSString *attribute in removeAttributes )
        {
            if ( [attributes containsObject:attribute] )
            {
                [attributes removeObject:attribute];
            }
        }
        
        [attributes addObject:NSAccessibilitySubroleAttribute];
    }
    return attributes;
}

- (id)accessibilityAttributeValue:(NSString *)attribute
{
    id value = nil;
    if ( [attribute isEqualToString:NSAccessibilityRoleAttribute] )
    {
        value = NSAccessibilityCheckBoxRole;
    }
    else if ( [attribute isEqualToString:NSAccessibilitySubroleAttribute] )
    {
        value = NSAccessibilitySwitchSubrole;
    }
    else
    {
        value = [super accessibilityAttributeValue:attribute];
    }
    
    return value;
}

- (NSArray *)accessibilityActionNames
{
    return [NSArray arrayWithObject:NSAccessibilityPressAction];
}

- (NSString *)accessibilityActionDescription:(NSString *)action
{
    return NSAccessibilityActionDescription(action);
}

- (void)accessibilityPerformAction:(NSString *)action
{
    if ( [action isEqualToString:NSAccessibilityPressAction] )
    {
        TwoPositionSwitch *controlView = (TwoPositionSwitch *)[self controlView];
        [controlView setState:[controlView state] == NSOffState ? NSOnState : NSOffState];
    }
}

@end
