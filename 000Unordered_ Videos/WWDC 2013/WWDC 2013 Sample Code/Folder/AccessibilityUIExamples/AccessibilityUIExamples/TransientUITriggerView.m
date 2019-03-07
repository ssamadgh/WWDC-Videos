/*
 
     File: TransientUITriggerView.m
 Abstract: View used to track mouse movement to trigger hidden UI.
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

#import "TransientUITriggerView.h"

@interface TransientUITriggerView (TransientUITriggerViewPrivate)
- (void)sendTransientUIChangedNotification;
@end

@implementation TransientUITriggerView

- (id)init
{
    self = [super init];
    [self localInit];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self localInit];
    return self;
}


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    [self localInit];
    return self;
}

- (void)localInit
{
    [self createTrackingArea];
}

- (void)awakeFromNib
{
    [_transientView setAlphaValue:0.0];
    [self setTransientViewIsVisible:NO];
}

- (void)createTrackingArea
{
    NSTrackingAreaOptions options = NSTrackingActiveInActiveApp;
    options |= NSTrackingMouseEnteredAndExited;
    options |= NSTrackingMouseMoved;
    options |= NSTrackingInVisibleRect;
    options |= NSTrackingActiveAlways;
    
    NSTrackingArea *tracking = [[NSTrackingArea alloc] initWithRect:NSZeroRect
                                                            options:options
                                                              owner:self
                                                           userInfo:nil];
    [self addTrackingArea:tracking];
}

- (void)setTransientViewIsVisible:(BOOL)transientViewIsVisible
{
    if ( transientViewIsVisible != _transientViewIsVisible )
    {
        _transientViewIsVisible = transientViewIsVisible;
        [_transientView setHidden:_transientViewIsVisible ? NO : YES];

        NSAnimationContext *animationContext = [NSAnimationContext currentContext];
        [NSAnimationContext beginGrouping];
        [animationContext setDuration:0.2f];
        [[_transientView animator] setAlphaValue:_transientViewIsVisible ? 1.0 : 0.0];
        [NSAnimationContext endGrouping];
        
        [self sendTransientUIChangedNotification];
    }
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    [self setTransientViewIsVisible:YES];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    [self setTransientViewIsVisible:YES];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [self setTransientViewIsVisible:NO];
}

@end
