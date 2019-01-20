/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  AAPLCoolPresentationController implementation.
  
 */

#import "AAPLCoolPresentationController.h"

@implementation AAPLCoolPresentationController

- (instancetype)initWithPresentingViewController:(UIViewController *)presentingViewController presentedViewController:(UIViewController *)presentedViewController
{
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if(self)
    {
        dimmingView = [[UIView alloc] init];
        [dimmingView setBackgroundColor:[[UIColor purpleColor] colorWithAlphaComponent:0.4]];
        
        bigFlowerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BigFlower"]];
        carlImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Carl"]];
        [carlImageView setFrame:CGRectMake(0,0,500,245)];
        
        jaguarPrintImageH = [[UIImage imageNamed:@"JaguarH"] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile];
        jaguarPrintImageV = [[UIImage imageNamed:@"JaguarV"] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile];

        topJaguarPrintImageView = [[UIImageView alloc] initWithImage:jaguarPrintImageH];
        bottomJaguarPrintImageView = [[UIImageView alloc] initWithImage:jaguarPrintImageH];

        leftJaguarPrintImageView = [[UIImageView alloc] initWithImage:jaguarPrintImageV];
        rightJaguarPrintImageView = [[UIImageView alloc] initWithImage:jaguarPrintImageV];
    }
    return self;
}

- (CGRect)frameOfPresentedViewInContainerView
{
    CGRect containerBounds = [[self containerView] bounds];
    
    CGRect presentedViewFrame = CGRectZero;
    presentedViewFrame.size = CGSizeMake(300, 500);
    presentedViewFrame.origin = CGPointMake(containerBounds.size.width / 2.0, containerBounds.size.height / 2.0);
    presentedViewFrame.origin.x -= presentedViewFrame.size.width / 2.0;
    presentedViewFrame.origin.y -= presentedViewFrame.size.height / 2.0;
    
    return presentedViewFrame;
}

- (void)presentationTransitionWillBegin
{
    [super presentationTransitionWillBegin];
    
    [self addViewsToDimmingView];

    [dimmingView setAlpha:0.0];
    
    [[[self presentedViewController] transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
		[self->dimmingView setAlpha:1.0];
    } completion:nil];

    [self moveJaguarPrintToPresentedPosition:NO];
    
    [UIView animateWithDuration:1.0 animations:^{
        [self moveJaguarPrintToPresentedPosition:YES];
    }];
}

- (void)containerViewWillLayoutSubviews
{
    [dimmingView setFrame:[[self containerView] bounds]];
}

- (void)containerViewDidLayoutSubviews
{
    CGPoint bigFlowerCenter = [dimmingView frame].origin;
    bigFlowerCenter.x += [[bigFlowerImageView image] size].width / 4.0;
    bigFlowerCenter.y += [[bigFlowerImageView image] size].height / 4.0;
    
    [bigFlowerImageView setCenter:bigFlowerCenter];
    
    CGRect carlFrame = [carlImageView frame];
    carlFrame.origin.y = [dimmingView bounds].size.height - carlFrame.size.height;
    
    [carlImageView setFrame:carlFrame];
}

- (void)dismissalTransitionWillBegin
{
    [super dismissalTransitionWillBegin];

    [[[self presentedViewController] transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [dimmingView setAlpha:0.0];
} completion:nil];
}

- (void)addViewsToDimmingView
{
    [dimmingView addSubview:bigFlowerImageView];
    [dimmingView addSubview:carlImageView];

    [dimmingView addSubview:topJaguarPrintImageView];
    [dimmingView addSubview:bottomJaguarPrintImageView];

    [dimmingView addSubview:leftJaguarPrintImageView];
    [dimmingView addSubview:rightJaguarPrintImageView];
    
    [[self containerView] addSubview:dimmingView];
}

- (void)moveJaguarPrintToPresentedPosition:(BOOL)presentedPosition
{
    CGSize horizontalJaguarSize = [jaguarPrintImageH size];
    CGSize verticalJaguarSize = [jaguarPrintImageV size];
    CGRect frameOfView = [self frameOfPresentedViewInContainerView];
    CGRect containerFrame = [[self containerView] frame];

    CGRect topFrame, bottomFrame, leftFrame, rightFrame;
    topFrame.size.height = bottomFrame.size.height = horizontalJaguarSize.height;
    topFrame.size.width = bottomFrame.size.width = frameOfView.size.width;

    leftFrame.size.width = rightFrame.size.width = verticalJaguarSize.width;
    leftFrame.size.height = rightFrame.size.height = frameOfView.size.height;

    topFrame.origin.x = frameOfView.origin.x;
    bottomFrame.origin.x = frameOfView.origin.x;

    leftFrame.origin.y = frameOfView.origin.y;
    rightFrame.origin.y = frameOfView.origin.y;

    CGRect frameToAlignAround = presentedPosition ? frameOfView : containerFrame;

    topFrame.origin.y = CGRectGetMinY(frameToAlignAround) - horizontalJaguarSize.height;
    bottomFrame.origin.y = CGRectGetMaxY(frameToAlignAround);
    leftFrame.origin.x = CGRectGetMinX(frameToAlignAround) - verticalJaguarSize.width;
    rightFrame.origin.x = CGRectGetMaxX(frameToAlignAround);
    
    [topJaguarPrintImageView setFrame:topFrame];
    [bottomJaguarPrintImageView setFrame:bottomFrame];
    [leftJaguarPrintImageView setFrame:leftFrame];
    [rightJaguarPrintImageView setFrame:rightFrame];
}

@end
