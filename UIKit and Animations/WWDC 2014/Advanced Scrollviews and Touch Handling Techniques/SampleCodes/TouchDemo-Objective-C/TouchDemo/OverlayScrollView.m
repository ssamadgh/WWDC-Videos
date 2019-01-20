//
//  OverlayScrollView.m
//  TouchDemo
//
//  Created by Antonio081014 on 8/23/15.
//  Copyright (c) 2015 antonio081014.com. All rights reserved.
//

#import "OverlayScrollView.h"

@implementation OverlayScrollView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    
    if (hitView == self) {
        return nil;
    }
    return hitView;
}

@end
