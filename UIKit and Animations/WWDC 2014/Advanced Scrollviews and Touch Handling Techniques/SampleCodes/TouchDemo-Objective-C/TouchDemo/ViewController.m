//
//  ViewController.m
//  TouchDemo
//
//  Created by Antonio081014 on 8/22/15.
//  Copyright (c) 2015 antonio081014.com. All rights reserved.
//

#import "ViewController.h"
#import "DotView.h"
#import "OverlayScrollView.h"
#import "TouchDelayGestureRecognizer.h"

@interface ViewController () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *canvasView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIVisualEffectView *drawerView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect bounds = self.view.bounds;
    
    self.canvasView = [[UIView alloc] initWithFrame:bounds];
    self.canvasView.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:self.canvasView];
    
    TouchDelayGestureRecognizer *touchDelayGesture = [[TouchDelayGestureRecognizer alloc] initWithTarget:nil action:nil];
    [self.view addGestureRecognizer:touchDelayGesture];
    
    [self addDots:25 toView:self.canvasView];
    [DotView arrangeDotsRandomlyInView:self.canvasView];
    
    self.scrollView = [[OverlayScrollView alloc] initWithFrame:bounds];
    [self.view addSubview:self.scrollView];
    
    self.drawerView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    self.drawerView.frame = CGRectMake(0, 0, bounds.size.width, 650);
    [self.scrollView addSubview:self.drawerView];
    
    [self addDots:20 toView:self.drawerView.contentView];
    [DotView arrangeDotsNeatlyInView:self.drawerView.contentView];
    
    self.scrollView.contentSize = CGSizeMake(bounds.size.width, bounds.size.height + self.drawerView.bounds.size.height);
    self.scrollView.contentOffset = CGPointMake(0, self.drawerView.bounds.size.height);
    
    [self.view addGestureRecognizer:self.scrollView.panGestureRecognizer];
}

- (void)addDots:(NSUInteger)count toView:(UIView *)view
{
    for (int i=0; i<count; i++) {
        DotView *dotView = [DotView randomDotView];
        [view addSubview:dotView];
        
        UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        gesture.cancelsTouchesInView = NO;
        gesture.delegate = self;
        [dotView addGestureRecognizer:gesture];
    }
}
#pragma mark - Moving Dot View
/**
 * User could move 2 or more dot views simultaneously, but could not scroll the scrollview with the pan gesture recognizer.
 * Becuase these dot views are siblings, so their gesture recognizer does not interact with each other. By default, the pan gesture recognizer in
 * superview is mutually exclusive in behavior with dot view's gesture recognizers.
 */
- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture
{
    UIView *dot = gesture.view;
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self grabDot:dot withGesture:gesture];
            break;
        case UIGestureRecognizerStateChanged:
            [self moveDot:dot withGesture:gesture];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            [self dropDot:dot withGesture:gesture];
            break;
        default:
            break;
    }
}

- (void)grabDot:(UIView *)dot withGesture:(UIGestureRecognizer *)gesture
{
    dot.center = [self.view convertPoint:dot.center fromView:dot.superview];
    [self.view addSubview:dot];
    [UIView animateWithDuration:.2f animations:^{
        dot.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
        dot.alpha = .8f;
        [self moveDot:dot withGesture:gesture];
    }];
    
    // Disable the pan gesture recognizer on this point;
    self.scrollView.panGestureRecognizer.enabled = NO;
    // Then reenable it so the pan guesture recognizer could recognize new touches, but no this one..
    self.scrollView.panGestureRecognizer.enabled = YES;
    
    [DotView arrangeDotsNeatlyInViewWithNiftyAnimation:self.drawerView.contentView];
}

- (void)moveDot:(UIView *)dot withGesture:(UIGestureRecognizer *)gesture
{
    dot.center = [gesture locationInView:self.view];
}

- (void)dropDot:(UIView *)dot withGesture:(UIGestureRecognizer *)gesture
{
    [UIView animateWithDuration:.2f animations:^{
        dot.transform = CGAffineTransformIdentity;
        dot.alpha = 1.f;
    }];
    
    CGPoint location = [gesture locationInView:self.drawerView];
    if (CGRectContainsPoint(self.drawerView.bounds, location)) {
        [self.drawerView.contentView addSubview:dot];
    } else {
        [self.canvasView addSubview:dot];
    }
    
    dot.center = [self.view convertPoint:dot.center fromView:dot.superview];

    [DotView arrangeDotsNeatlyInViewWithNiftyAnimation:self.drawerView.contentView];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
@end
