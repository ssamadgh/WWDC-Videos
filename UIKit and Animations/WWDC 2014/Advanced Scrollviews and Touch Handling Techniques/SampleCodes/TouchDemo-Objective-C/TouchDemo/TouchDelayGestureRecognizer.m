//
//  TouchDelayGestureRecognizer.m
//  TouchDemo
//
//  Created by Antonio081014 on 8/23/15.
//  Copyright (c) 2015 antonio081014.com. All rights reserved.
//

#import "TouchDelayGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface TouchDelayGestureRecognizer()
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation TouchDelayGestureRecognizer

- (instancetype)initWithTarget:(id)target action:(SEL)action
{
    if (self = [super initWithTarget:target action:action]) {
        self.delaysTouchesBegan = YES;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // start timer;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.15f target:self selector:@selector(fail) userInfo:nil repeats:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self fail];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self fail];
}

- (void)reset
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)fail
{
    self.state = UIGestureRecognizerStateFailed;
}

@end
