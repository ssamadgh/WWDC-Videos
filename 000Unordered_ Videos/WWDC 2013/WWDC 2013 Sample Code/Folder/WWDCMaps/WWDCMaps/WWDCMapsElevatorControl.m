/*
    File: WWDCMapsElevatorControl.m
Abstract: Adjusts the floor number and the visible floor plan.
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

#import "WWDCMapsElevatorControl.h"

#import "WWDCMapsCommon.h"

typedef enum : NSUInteger {
    WWDCMapsControlDirectionDown = 1,
    WWDCMapsControlDirectionUp
} WWDCMapsControlDirection;

@interface WWDCMapsElevatorControl ()

@property (nonatomic) CGPoint touchPoint;

@end

@implementation WWDCMapsElevatorControl

#pragma mark - Accessibility

- (void)accessibilityDecrement
{
    [self decrementFloor];
    
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

- (void)accessibilityIncrement
{
    [self incrementFloor];
    
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

- (NSString *)accessibilityLabel
{
    return @"Floor";
}

- (UIAccessibilityTraits)accessibilityTraits
{
    return UIAccessibilityTraitAdjustable;
}

- (NSString *)accessibilityValue
{
    return [NSString stringWithFormat:@"%d", self.floor];
}

- (BOOL)isAccessibilityElement
{
    return YES;
}

#pragma mark - Helpers

- (BOOL)controlEnabledForDirection:(WWDCMapsControlDirection)controlDirection
{
    switch ( controlDirection )
    {
        case WWDCMapsControlDirectionDown:
            return self.floor > WWDCMapsMinimumFloor;
        case WWDCMapsControlDirectionUp:
            return self.floor < WWDCMapsMaximumFloor;
        default:
            // Unsupported control direction
            return NO;
    }
}

- (CGRect)controlRectForDirection:(WWDCMapsControlDirection)controlDirection
{
    CGRect bounds = self.bounds;
    CGFloat controlWidth = CGRectGetWidth(bounds) - WWDCMapsPadding * 2.0;
    
    switch ( controlDirection )
    {
        case WWDCMapsControlDirectionDown:
            return CGRectMake(WWDCMapsPadding, CGRectGetHeight(bounds) - WWDCMapsPadding - controlWidth, controlWidth, controlWidth);
        case WWDCMapsControlDirectionUp:
            return CGRectMake(WWDCMapsPadding, WWDCMapsPadding, controlWidth, controlWidth);
        default:
            // Unsupported control direction
            return CGRectZero;
    }
}

- (BOOL)controlTouchedForDirection:(WWDCMapsControlDirection)controlDirection
{
    return CGRectContainsPoint([self controlRectForDirection:controlDirection], self.touchPoint);
}

- (void)decrementFloor
{
    if ( [self controlEnabledForDirection:WWDCMapsControlDirectionDown] )
    {
        self.floor -= 1;
        
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)incrementFloor
{
    if ( [self controlEnabledForDirection:WWDCMapsControlDirectionUp] )
    {
        self.floor += 1;
        
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

#pragma mark - Overrides

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.touchPoint = [touch locationInView:self];
    
    if ( [self controlTouchedForDirection:WWDCMapsControlDirectionDown] || [self controlTouchedForDirection:WWDCMapsControlDirectionUp] )
    {
        [self setNeedsDisplay];
        
        return YES;
    }
    
    return NO;
}

- (void)drawRect:(CGRect)rect
{
    if ( self.enabled )
    {
        BOOL downControlEnabled = [self controlEnabledForDirection:WWDCMapsControlDirectionDown];
        CGRect downControlRect = [self controlRectForDirection:WWDCMapsControlDirectionDown];
        BOOL upControlEnabled = [self controlEnabledForDirection:WWDCMapsControlDirectionUp];
        CGRect upControlRect = [self controlRectForDirection:WWDCMapsControlDirectionUp];
        
        // Draw down control
        NSAttributedString *downControlAttributedString = [[NSAttributedString alloc] initWithString:@"Down" attributes:@{ NSFontAttributeName : [UIFont boldSystemFontOfSize:WWDCMapsFontSize], NSForegroundColorAttributeName : ( !downControlEnabled ) ? [UIColor lightGrayColor] : [UIColor blackColor] }];
        UIBezierPath *downControlBezierPath = [UIBezierPath bezierPathWithOvalInRect:downControlRect];
        downControlBezierPath.lineWidth = WWDCMapsLineWidth;
        [( downControlEnabled && [self controlTouchedForDirection:WWDCMapsControlDirectionDown] ) ? [UIColor darkGrayColor] : [UIColor whiteColor] setFill];
        [downControlBezierPath fill];
        [( downControlEnabled ) ? [UIColor blackColor] : [UIColor lightGrayColor] setStroke];
        [downControlBezierPath stroke];
        [downControlAttributedString drawAtPoint:CGPointMake(CGRectGetMidX(downControlRect) - downControlAttributedString.size.width * 0.5, CGRectGetMidY(downControlRect) - downControlAttributedString.size.height * 0.5)];
        
        // Draw up control
        NSAttributedString *upControlAttributedString = [[NSAttributedString alloc] initWithString:@"Up" attributes:@{ NSFontAttributeName : [UIFont boldSystemFontOfSize:WWDCMapsFontSize], NSForegroundColorAttributeName : ( !upControlEnabled ) ? [UIColor lightGrayColor] : [UIColor blackColor] }];
        UIBezierPath *upControlBezierPath = [UIBezierPath bezierPathWithOvalInRect:upControlRect];
        upControlBezierPath.lineWidth = WWDCMapsLineWidth;
        [( upControlEnabled && [self controlTouchedForDirection:WWDCMapsControlDirectionUp] ) ? [UIColor darkGrayColor] : [UIColor whiteColor] setFill];
        [upControlBezierPath fill];
        [( upControlEnabled ) ? [UIColor blackColor] : [UIColor lightGrayColor] setStroke];
        [upControlBezierPath stroke];
        [upControlAttributedString drawAtPoint:CGPointMake(CGRectGetMidX(upControlRect) - upControlAttributedString.size.width * 0.5, CGRectGetMidY(upControlRect) - upControlAttributedString.size.height * 0.5)];
    }
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    // Decrement floor
    if ( [self controlTouchedForDirection:WWDCMapsControlDirectionDown] )
    {
        [self decrementFloor];
    }
    // Increment floor
    else if ( [self controlTouchedForDirection:WWDCMapsControlDirectionUp] )
    {
        [self incrementFloor];
    }
    
    self.touchPoint = CGPointZero;
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    [self setNeedsDisplay];
}

#pragma mark - Properties

- (void)setFloor:(int)floor
{
    // Clamp floor between [WWDCMapsMinimumFloor, WWDCMapsMaximumFloor]
    _floor = MAX(MIN(floor, WWDCMapsMaximumFloor), WWDCMapsMinimumFloor);
    
    [self setNeedsDisplay];
}

@end
