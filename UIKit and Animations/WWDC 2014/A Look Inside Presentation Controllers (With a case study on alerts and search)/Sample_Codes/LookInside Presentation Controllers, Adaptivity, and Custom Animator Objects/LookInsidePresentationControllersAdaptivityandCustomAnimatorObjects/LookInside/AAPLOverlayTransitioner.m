/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  AAPLOverlayAnimatedTransitioning and AAPLOverlayTransitioningDelegate implementations.
  
 */

#import "AAPLOverlayTransitioner.h"
#import "AAPLOverlayPresentationController.h"
#import "AAPLCoolPresentationController.h"

#import "AAPLRootViewController.h"

@implementation AAPLOverlayTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    Class presentationControllerClass;
    
    if([source isKindOfClass:[AAPLRootViewController class]] && [(AAPLRootViewController *)source presentationShouldBeAwesome])
    {
        presentationControllerClass = [AAPLCoolPresentationController class];
    }
    else
    {
        presentationControllerClass = [AAPLOverlayPresentationController class];
    }
    
    return [[presentationControllerClass alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

- (AAPLOverlayAnimatedTransitioning *)animationController
{
    AAPLOverlayAnimatedTransitioning *animationController = [[AAPLOverlayAnimatedTransitioning alloc] init];
    return animationController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    AAPLOverlayAnimatedTransitioning *animationController = [self animationController];
    [animationController setIsPresentation:YES];
    
    return animationController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    AAPLOverlayAnimatedTransitioning *animationController = [self animationController];
    [animationController setIsPresentation:NO];
    
    return animationController;
}

@end

@implementation AAPLOverlayAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *fromView = [fromVC view];
    UIViewController *toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = [toVC view];
    
    UIView *containerView = [transitionContext containerView];
    
    BOOL isPresentation = [self isPresentation];

    if(isPresentation)
    {
        [containerView addSubview:toView];
    }
    
    UIViewController *animatingVC = isPresentation ? toVC : fromVC;
    UIView *animatingView = [animatingVC view];
    
    CGRect appearedFrame = [transitionContext finalFrameForViewController:animatingVC];
    CGRect dismissedFrame = appearedFrame;
    dismissedFrame.origin.x += dismissedFrame.size.width;
    
    CGRect initialFrame = isPresentation ? dismissedFrame : appearedFrame;
    CGRect finalFrame = isPresentation ? appearedFrame : dismissedFrame;
    
    [animatingView setFrame:initialFrame];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
         usingSpringWithDamping:300.0
          initialSpringVelocity:5.0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [animatingView setFrame:finalFrame];
                    }
                     completion:^(BOOL finished){
                         if(![self isPresentation])
                         {
                             [fromView removeFromSuperview];
                         }
                        [transitionContext completeTransition:YES];
                    }];
}

@end

