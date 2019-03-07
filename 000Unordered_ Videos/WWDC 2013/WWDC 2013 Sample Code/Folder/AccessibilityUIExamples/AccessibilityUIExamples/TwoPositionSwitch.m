/*
 
     File: TwoPositionSwitch.m
 Abstract: Custom control that behaves like a two-position switch.
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

#import "TwoPositionSwitch.h"
#import "TwoPositionSwitchCell.h"

static NSTimeInterval kSwitchAnimationDuration = 0.15;

@implementation TwoPositionSwitch

+ (Class)cellClass
{
    return [TwoPositionSwitchCell class];
}

+ (id)defaultAnimationForKey:(NSString *)key
{
    if ( [key isEqualToString:@"doubleValue"] )
    {
        return [self defaultAnimationForKey:@"frameOrigin"];
    }
	else
    {
        return [super defaultAnimationForKey:key];
    }
}

+ (NSSet *)keyPathsForValuesAffectingAnimating
{
    return [NSSet setWithObjects:@"doubleValue", @"targetValue", nil];
}

- (id)initWithFrame:(NSRect)inRect
{
    NSImage *aImage = [NSImage imageNamed:@"SwitchOverlayMask"];
    NSRect aRect = NSMakeRect(inRect.origin.x, inRect.origin.y, [aImage size].width, [aImage size].height);

    self = [super initWithFrame:aRect];
    if ( self != nil )
    {
        [self setDoubleValue:0.0];
        [self setMinValue:0.0];
        [self setMaxValue:1.0];
        [self setContinuous:NO];
    }

    return self;
}

- (BOOL)isAnimating
{
    return _targetValue != [self doubleValue];
}

- (BOOL)isFlipped
{
    return NO;
}

- (void)setDoubleValue:(double)value animate:(BOOL)animate
{
    _targetValue = value;

    if ( [self doubleValue] != value )
    {
        if ( animate )
        {
            [[NSAnimationContext currentContext] setDuration:kSwitchAnimationDuration*ABS(value - [self doubleValue])];
            [[self animator] setDoubleValue:value];
        }
        else
        {
            [self setDoubleValue:value];
        }
    }
}

- (void)setState:(NSInteger)inValue
{
    [self setState:inValue animate:YES];
}

- (void)setState:(NSInteger)inValue animate:(BOOL)animate
{
    double targetValue = [self targetValue];
    double value = (inValue == NSOnState) ? 1.0 : 0.0;

    if ( value != targetValue )
    {
        [self setDoubleValue:value animate:animate];
    }
}

- (NSInteger)state
{
    double aValue = [self targetValue];

    if ( aValue == 0.0 )
    {
        return NSOffState;
    }
    else if ( aValue == 1.0 )
    {
        return NSOnState;
    }
    else
    {
        return NSMixedState;
    }
}


#pragma mark Keyboard Input

- (void)moveRight:(id)sender
{
    if ( [self isEnabled] )
    {
        [self setDoubleValue:1.0 animate:YES];
        [self sendAction:[self action] to:[self target]];
    }
}

- (void)moveLeft:(id)sender
{
    if ( [self isEnabled] )
    {
        [self setDoubleValue:0.0 animate:YES];
        [self sendAction:[self action] to:[self target]];
    }
}

- (void)moveUp:(id)sender
{
    [self moveRight:sender];
}

- (void)moveDown:(id)sender
{
    [self moveLeft:sender];
}

- (void)pageUp:(id)sender
{
    [self moveRight:sender];
}

- (void)pageDown:(id)sender
{
    [self moveLeft:sender];
}

@end
