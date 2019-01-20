/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  The application delegate, which is also the split view controller's delegate.
  
 */

#import "AAPLAppDelegate.h"
#import "AAPLEmptyViewController.h"
#import "AAPLListTableViewController.h"
#import "AAPLTraitOverrideViewController.h"
#import "AAPLUser.h"
#import "UIViewController+AAPLPhotoContents.h"

@interface AAPLAppDelegate () <UISplitViewControllerDelegate>
@end

@implementation AAPLAppDelegate
    
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"User" withExtension:@"plist"];
    NSDictionary *userDictionary = [[NSDictionary alloc] initWithContentsOfURL:url];
    AAPLUser *user = [AAPLUser userWithDictionary:userDictionary];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UISplitViewController *controller = [[UISplitViewController alloc] init];
    controller.delegate = self;
    
    AAPLListTableViewController *master = [[AAPLListTableViewController alloc] init];
    master.user = user;
    UINavigationController *masterNav = [[UINavigationController alloc] initWithRootViewController:master];
    
    AAPLEmptyViewController *detail = [[AAPLEmptyViewController alloc] init];
    
    controller.viewControllers = @[masterNav, detail];
    controller.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    
    AAPLTraitOverrideViewController *traitController = [[AAPLTraitOverrideViewController alloc] init];
    traitController.viewController = controller;
    self.window.rootViewController = traitController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

#pragma mark - Split View Controller

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController
{
    AAPLPhoto *photo = [secondaryViewController aapl_containedPhoto];
    if (!photo) {
        // If our secondary controller doesn't show a photo, do the collapse ourself by doing nothing
        return YES;
    }
    
    // Before collapsing, remove any view controllers on our stack that don't match the photo we are about to merge on
    if ([primaryViewController isKindOfClass:[UINavigationController class]]) {
        NSMutableArray *viewControllers = [NSMutableArray array];
        for (UIViewController *controller in [(UINavigationController *)primaryViewController viewControllers]) {
            if ([controller aapl_containsPhoto:photo]) {
                [viewControllers addObject:controller];
            }
        }
        [(UINavigationController *)primaryViewController setViewControllers:viewControllers];
    }
    return NO;
}

- (UIViewController *)splitViewController:(UISplitViewController *)splitViewController separateSecondaryViewControllerFromPrimaryViewController:(UIViewController *)primaryViewController
{
    if ([primaryViewController isKindOfClass:[UINavigationController class]]) {
        for (UIViewController *controller in [(UINavigationController *)primaryViewController viewControllers]) {
            if ([controller aapl_containedPhoto]) {
                // Do the standard behavior if we have a photo
                return nil;
            }
        }
    }
    // If there's no content on the navigation stack, make an empty view controller for the detail side
    return [[AAPLEmptyViewController alloc] init];
}

@end
