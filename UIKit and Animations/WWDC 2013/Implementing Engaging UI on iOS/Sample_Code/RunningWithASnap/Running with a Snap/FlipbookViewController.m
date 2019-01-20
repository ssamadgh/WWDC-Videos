/*
     File: FlipbookViewController.m
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

#import "FlipbookViewController.h"
#import "Run.h"

@interface FlipbookContainerView : UIView 
@property (nonatomic, strong) UIPushBehavior *initialPush;
@property (nonatomic, readonly) UIImageView *imageView;
- (id)initWithFrame:(CGRect)rect imageView:(UIImageView *)imageView;
@end

@interface FlipbookViewController () <UICollisionBehaviorDelegate>
{
    NSUInteger displayedPhotoIdx;
}
@property (nonatomic, strong) IBOutlet UIView *contentView;
@property (nonatomic, strong) IBOutlet UIImageView *lightpoolView;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravity;
@property (nonatomic, strong) UICollisionBehavior *collision;
@property (nonatomic, strong) UIDynamicItemBehavior *springyBehavior;
@property (nonatomic, strong) UIAttachmentBehavior *attachment;
@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, strong) UIImageView *fixedBounceItem;
@property (nonatomic, strong) UIImageView *spotlightView;
@end

@implementation FlipbookViewController

- (void)viewDidLoad {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedView:)];
    [self.view addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pannedView:)];
    [self.view addGestureRecognizer:pan];
    
    self.lightpoolView.alpha = 0.20;

    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.contentView];

    _gravity = [[UIGravityBehavior alloc] init];
//    [_gravity setYComponent:3.0];
	CGVector vector = CGVectorMake(0, 3.0);
	[_gravity setGravityDirection:vector];
    
    _collision = [[UICollisionBehavior alloc] init];
    _collision.collisionDelegate = self;
    _collision.collisionMode = UICollisionBehaviorModeBoundaries;
    CGFloat midY = self.lightpoolView.center.y;
    [_collision addBoundaryWithIdentifier:@"lightpool-boundary" fromPoint:CGPointMake(100, midY) toPoint:CGPointMake(CGRectGetMaxX(self.contentView.bounds), midY)];

    _springyBehavior = [[UIDynamicItemBehavior alloc] init];
    _springyBehavior.elasticity = 1.0;
    [_animator addBehavior:_springyBehavior];
    
    [_animator addBehavior:_gravity];
    [_animator addBehavior:_collision];
}

- (void)viewWillDisappear:(BOOL)animated {
    [_link invalidate];
}

- (void)nextPhoto {
    // Loop through photos forever
    if (displayedPhotoIdx >= [self.run numberOfPhotos]) { displayedPhotoIdx = 0; }
    UIImage *img = [self.run photoAtIndex:displayedPhotoIdx++ ofType:RunPhotoTypePreview];
    NSAssert(img, @"Did not load image from run!");

    CGRect startingRect = CGRectMake(CGRectGetMaxX(self.contentView.bounds) - img.size.width, img.size.height / 2, img.size.width * img.scale, img.size.height * img.scale);
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(startingRect), CGRectGetHeight(startingRect))];
    imgView.userInteractionEnabled = NO;
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.image = img;

    FlipbookContainerView *containerView = [[FlipbookContainerView alloc] initWithFrame:startingRect imageView:imgView];
    containerView.userInteractionEnabled = NO;
	
	if (_fixedBounceItem) {
		[self.contentView insertSubview:containerView belowSubview:_fixedBounceItem];
	}
	else {
		[self.contentView addSubview:containerView];
	}

	
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        containerView.alpha = 1.0;
        containerView.imageView.transform = CGAffineTransformIdentity;
    } completion:nil];
    
    UIPushBehavior *sidePush = [[UIPushBehavior alloc] initWithItems:@[containerView] mode:UIPushBehaviorModeInstantaneous];
    [sidePush setAngle:M_PI magnitude:29.0];
    [_animator addBehavior:sidePush];

    containerView.initialPush = sidePush;
    
//    if (_fixedBounceItem) {
//        [self.contentView insertSubview:containerView belowSubview:_fixedBounceItem];
//    }
//    else {
//        [self.contentView addSubview:containerView];
//    }
    [_collision addItem:containerView];
    [_gravity addItem:containerView];
    [_springyBehavior addItem:containerView];
}

- (void)linkFired:(CADisplayLink *)link {
    [self nextPhoto];
}

- (void)tappedView:(UITapGestureRecognizer *)tapGesture {
    if (_link) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];

        [UIView animateWithDuration:0.25 animations:^{
            CGRect r = _spotlightView.frame;
            r.origin = CGPointMake(0, -CGRectGetHeight(r));
            _spotlightView.frame = r;

            self.lightpoolView.alpha = 0.20;
        }];
        
        [_link invalidate];
        _link = nil;
    }
    else {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        if (!_spotlightView) {
            UIImage *spotlight = [UIImage imageNamed:@"spotlight"];
            _spotlightView = [[UIImageView alloc] initWithImage:spotlight];
            _spotlightView.userInteractionEnabled = NO;
            _spotlightView.alpha = 0.50;
            CGRect r = _spotlightView.frame;
            r.origin = CGPointMake(0, -spotlight.size.height);
            _spotlightView.frame = r;
            
            [self.view addSubview:_spotlightView];
        }
        
        [UIView animateWithDuration:0.25 animations:^{
            CGRect r = _spotlightView.frame;
            r.origin = CGPointMake(0, 0);
            _spotlightView.frame = r;
            
            self.lightpoolView.alpha = 0.80;
        }];
        
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(linkFired:)];
        _link.frameInterval = 8;
        [_link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)pannedView:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateBegan && CGRectContainsPoint([_fixedBounceItem convertRect:_fixedBounceItem.bounds toView:nil], [panGesture locationInView:nil])) {
        CGPoint bounceItemViewPoint = [_fixedBounceItem convertPoint:[panGesture locationInView:nil] fromView:nil];
        CGPoint attachPoint = CGPointMake(bounceItemViewPoint.x <= CGRectGetMidX(_fixedBounceItem.bounds) ? -5 : 5, -CGRectGetMidY(_fixedBounceItem.bounds));
        
        // We must container the snapshot because we want to apply a transform to it. UIKit Dynamics also sets transforms and will stomp our transform if we don't isolate the snapshot.
        UIView *container = [[UIView alloc] initWithFrame:_fixedBounceItem.frame];

        UIView *snapshot;
        // In seed 2, the method -[UIView snapshot] has changed to -[UIView snapshotView]. Please use -snapshotView in seed 2 and going forward.
//        snapshot = [_fixedBounceItem snapshot];
		snapshot = [_fixedBounceItem snapshotViewAfterScreenUpdates:false];

        [container addSubview:snapshot];
        [self.contentView addSubview:container];
        [self.contentView bringSubviewToFront:container];
        [UIView animateWithDuration:0.4 animations:^{
            snapshot.transform = CGAffineTransformMakeScale(1.5, 1.5);
        }];
        
        [_gravity addItem:container];
       
//        _attachment = [[UIAttachmentBehavior alloc] initWithItem:container point:attachPoint attachedToAnchor:[self.view convertPoint:[panGesture locationInView:nil] fromView:nil]];
		_attachment = [[UIAttachmentBehavior alloc] initWithItem:container attachedToAnchor:[self.view convertPoint:[panGesture locationInView:nil] fromView:nil]];
		
        UIDynamicItemBehavior *offscreenBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[container]];
        __block typeof(offscreenBehavior) __block_behavior = offscreenBehavior;
        offscreenBehavior.action = ^{ 
            if (!CGRectIntersectsRect([[container window] bounds], [container frame])) {
                [_gravity removeItem:container];
                [_animator removeBehavior:__block_behavior];
                [container removeFromSuperview];
            }
        };
        
        [_animator addBehavior:_attachment];
        [_animator addBehavior:offscreenBehavior];
    }
    else if (panGesture.state == UIGestureRecognizerStateChanged) {
        _attachment.anchorPoint = [self.view convertPoint:[panGesture locationInView:nil] fromView:nil];
    }
    else if (panGesture.state == UIGestureRecognizerStateEnded) {
        [_animator removeBehavior:_attachment];
        _attachment = nil;
    }

}

- (void)collisionBehavior:(UICollisionBehavior*)behavior endedContactForItem:(id <UIDynamicItem>)item withBoundaryIdentifier:(id <NSCopying>)identifier {
    if (!_fixedBounceItem) {
        [[UIImageView alloc] initWithFrame:[(UIView *)item frame]];
        _fixedBounceItem.userInteractionEnabled = NO;
        [self.contentView addSubview:_fixedBounceItem];
        [self.contentView bringSubviewToFront:_fixedBounceItem];
    }
    _fixedBounceItem.image = ((FlipbookContainerView *)item).imageView.image;
    
    [UIView animateWithDuration:0.75 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [(UIView *)item setAlpha:0.0];
        ((FlipbookContainerView *)item).imageView.transform = CGAffineTransformMakeScale(0.3, 0.3);
    } completion:^(BOOL finished) {
        [_collision removeItem:item];
        [_gravity removeItem:item];
        [_springyBehavior removeItem:item];
        [_animator removeBehavior:((FlipbookContainerView *)item).initialPush];
        [(UIView *)item removeFromSuperview];
    }];
}

@end

@implementation FlipbookContainerView

- (id)initWithFrame:(CGRect)rect imageView:(UIImageView *)imageView {
    self = [super initWithFrame:rect];
    if (self != nil) {
        _imageView = imageView;
        [self addSubview:_imageView];
        _imageView.transform = CGAffineTransformMakeScale(1.5, 1.5);
        self.alpha = 0.0;
    }
    
    return self;
}

@end
