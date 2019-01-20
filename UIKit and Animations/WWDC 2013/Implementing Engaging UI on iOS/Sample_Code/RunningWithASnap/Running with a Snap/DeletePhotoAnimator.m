/*
     File: DeletePhotoAnimator.m
 Abstract: 
 
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

#import <UIKit/UIKit.h>
#import "DeletePhotoAnimator.h"
#import "EditPhotoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "LensFlareView.h"

#define SECTION_SIZE 20.0

@interface SubsnapshotContainerView : UIView
@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIPushBehavior *push;
@end

@interface DeletePhotoAnimator ()
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravity;
@property (nonatomic, strong) UICollisionBehavior *collision;
@property (nonatomic, strong) UIDynamicItemBehavior *propertyBehavior;
@property (nonatomic, strong) UIImageView *scanlineImageView;
@end

@implementation DeletePhotoAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 2.0;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    EditPhotoViewController *fromVC = (EditPhotoViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *toView = [toVC view];
    UIView *fromView = [fromVC view];
    
    // Stick the toView into position
    toView.frame = [transitionContext finalFrameForViewController:toVC];
    [transitionContext.containerView insertSubview:toView belowSubview:fromView];
    
    NSInteger numberOfRows = ceil(CGRectGetHeight(fromVC.imageView.frame)/SECTION_SIZE);
    NSTimeInterval perRowAnimationDelay = [self transitionDuration:transitionContext] / numberOfRows;
    NSTimeInterval accumulatedRowAnimationDelay = 0.08;
    
    // Use a holder view so that placement is a bit easier on us later
    UIView *holderView = [[UIView alloc] initWithFrame:fromVC.imageView.frame];
    [transitionContext.containerView addSubview:holderView];
    
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:holderView];
    _gravity = [[UIGravityBehavior alloc] init];
    [_animator addBehavior:_gravity];
    
    _propertyBehavior = [[UIDynamicItemBehavior alloc] init];
    _propertyBehavior.density = 50.0;
    [_animator addBehavior:_propertyBehavior];
    
    NSMutableArray *thisRowsViews = [NSMutableArray array];

    UIView *snapshot;
    // In seed 2, the method -[UIView snapshot] has changed to -[UIView snapshotView]. Please use -snapshotView in seed 2 and going forward.
//    snapshot = [fromVC.imageView snapshot];
	snapshot = [fromVC.imageView snapshotViewAfterScreenUpdates:false];

    for (int y=CGRectGetHeight(fromVC.imageView.frame)-SECTION_SIZE; y>=0; y-=SECTION_SIZE) {
        [thisRowsViews removeAllObjects];
        
        for (int x=0; x<CGRectGetWidth(fromVC.imageView.frame); x+=SECTION_SIZE) {
            CGRect subrect = CGRectMake(x, y, SECTION_SIZE, SECTION_SIZE);
            SubsnapshotContainerView *containerView = [[SubsnapshotContainerView alloc] initWithFrame:subrect];

            UIView *subsnapshot;
            // In seed 2, the method -[UIView resizableSnapshotFromRect:withCapInsets:] has changed to -[UIView resizableSnapshotViewFromRect:withCapInsets:]. Please use -resizableSnapshotViewFromRect:withCapInsets: in seed 2 and going forward.
//            subsnapshot = [snapshot resizableSnapshotFromRect:subrect withCapInsets:UIEdgeInsetsZero];
			subsnapshot = [snapshot resizableSnapshotViewFromRect:subrect afterScreenUpdates:false withCapInsets:UIEdgeInsetsZero];
            [containerView insertSubview:subsnapshot belowSubview:containerView.coverView];
            
            containerView.layer.borderWidth = 1.0 / [[UIScreen mainScreen] scale];
            containerView.layer.borderColor = [UIColor blackColor].CGColor;
            
            [holderView addSubview:containerView];
            [holderView sendSubviewToBack:containerView];
            [thisRowsViews addObject:containerView];
        }
        
        // Need to make a copy of the mutable array otherwise the animation block will only ever see the last row's views.
        NSArray *views = [thisRowsViews copy];

        (void)[NSTimer scheduledTimerWithTimeInterval:accumulatedRowAnimationDelay target:self selector:@selector(addItemsToEngine:) userInfo:views repeats:NO];
        
        // Turns each square white, then makes each disappear
        [UIView animateWithDuration:0.05 delay:accumulatedRowAnimationDelay options:UIViewAnimationOptionCurveLinear animations:^{
            for (SubsnapshotContainerView *containerView in views) {
                containerView.coverView.alpha = 1.0;
            }
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.4 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
                for (SubsnapshotContainerView *containerView in views) {
                    containerView.alpha = 0.0;
                }
            } completion:^(BOOL finished) {
                for (SubsnapshotContainerView *containerView in views) {
                    [_gravity removeItem:containerView];
                    [_propertyBehavior removeItem:containerView];

                    [_animator removeBehavior:containerView.push];
                    
                    [containerView removeFromSuperview];
                }
            }];
        }];
        
        accumulatedRowAnimationDelay += perRowAnimationDelay;
    }
    
    UIImage *scanline = [[UIImage imageNamed:@"scanline"] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile];
    scanline = [scanline imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _scanlineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(holderView.frame) + 5, CGRectGetWidth(transitionContext.containerView.frame), 20)];
    _scanlineImageView.image = scanline;
    [transitionContext.containerView addSubview:_scanlineImageView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        CGRect r = _scanlineImageView.frame;
        r.origin.y = CGRectGetMinY(holderView.frame) - 5;
        _scanlineImageView.frame = r;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.30 animations:^{
            _scanlineImageView.alpha = 0.0;
            fromVC.view.alpha = 0.0;
        } completion:^(BOOL finished) {
            [_animator removeAllBehaviors];
            
            // Important! Call this method when all of our animations are finished
            [transitionContext completeTransition:YES];
        }];
    }];
    
    // Now that all the animations are setup, hide the image we're going to delete so it doesn't show up while we're deleting.
    [fromVC.imageView setHidden:YES];
}

- (void)addItemsToEngine:(NSTimer *)aTimer {
    NSArray *views = [aTimer userInfo];
    for (SubsnapshotContainerView *containerView in views) { 
        [_gravity addItem:containerView];
        [_propertyBehavior addItem:containerView];
        
        // Upwards shove
        UIPushBehavior *push = [[UIPushBehavior alloc] initWithItems:@[containerView] mode:UIPushBehaviorModeInstantaneous];
        [push setAngle:_randomFloat(4.4, 5.1) magnitude:5.0];
        [self.animator addBehavior:push];
        
        containerView.push = push;
    }
}

@end

@implementation SubsnapshotContainerView 

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _coverView = [[UIView alloc] initWithFrame:CGRectMake(0,0,frame.size.width,frame.size.height)];
        _coverView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.80];
        _coverView.alpha = 0.0;
        [self addSubview:_coverView];
    }
    
    return self;
}

@end
