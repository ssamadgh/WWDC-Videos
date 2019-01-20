/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A category to add a simple method to send an action up the responder chain.
 */

#import "UIView+Helpers.h"

@implementation UIView (Helpers)

- (BOOL)aapl_sendAction:(SEL)action
{
    // Get the target in the responder chain
    id sender = self;
    id target = sender;

    while (target && ![target canPerformAction:action withSender:sender]) {
        target = [target nextResponder];
    }

    if (!target)
        return NO;

    return [[UIApplication sharedApplication] sendAction:action to:target from:sender forEvent:nil];
}

@end
