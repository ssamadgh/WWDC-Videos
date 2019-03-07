/*
     File: APLAppDelegate.m
 Abstract: Application delegate.
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

#import "APLAppDelegate.h"
#import "APLMasterViewController.h"


@implementation APLAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    BLog();

    /*
     You must invoke setMinimumBackgroundFetchInterval:. The default value is UIApplicationBackgroundFetchIntervalNever which means the app will never be woken for a background fetch.
     */
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    return YES;
}
							

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    BLog();

    /*
     This method gets called when a background fetch happens. The app will have a limited amount of time to update itself in the background, so be careful on how you use this.
     When are done with this, you must call completionHandler with a suitable UIBackgroundFetchResult constant:
     * UIBackgroundFetchResultNewData if the app was able to successfully update itself.
     * UIBackgroundFetchResultNoData if the app did not have any additional data to update itself with.
     * UIBackgroundFetchResultFailed if the app failed to update for some reason.

     Be careful not to cache the completionHandler, although as shown in this example you can pass it through to the corresponding methods where you intend to do call it.

     Replace this implementation with whatever makes sense in your app.
     
     */

    /*
     ** For the purposes of illustration in this particular example only**, consider the fetch successful only if the navigation controller's top view controller is the master table view controller. (You can then test the two scenarios by navigating from the master to the detail view controller.)
     * If the master view controller is the top view controller, invoke its insertNewObjectForFetchWithCompletionHandler: method. The insertNewObjectForFetchWithCompletionHandler: method takes as its argument the completion handler which is then invoked in the method with the argument UIBackgroundFetchResultNewData.
     * If the detail view controller is the top view controller, then pretend that the fetch failed and invoke the completion handler with the argument UIBackgroundFetchResultFailed.
     
     Important: Not shown here is a case where the background fetch didn't have new data to fetch. If the fetch fails in this way, you must call the completion handler with the argument UIBackgroundFetchResultNoData.
     */
    UINavigationController *navigationController = (UINavigationController*)self.window.rootViewController;
    
    id topViewController = navigationController.topViewController;
    if ([topViewController isKindOfClass:[APLMasterViewController class]])
    {
        /*
         The master view controller's insertNewObjectForFetchWithCompletionHandler: method simply adds some new data to the tableview in this app. Replace this with what's appropriate for your app.

         The insertNewObjectForFetchWithCompletionHandler: method invokes the completion handler with the argument UIBackgroundFetchResultNewData.
         */
        [(APLMasterViewController*)topViewController insertNewObjectForFetchWithCompletionHandler:completionHandler];
        
        // Update the app badge count (if appropriate for your app).
        BLog("applicationIconBadgeNumber++");
        [UIApplication sharedApplication].applicationIconBadgeNumber++;
    }
    else
    {
        BLog(@"Not the right class %@.", [topViewController class]);
        completionHandler(UIBackgroundFetchResultFailed);
    }

    // If completionHandler is not called the app will get killed by the system, so don't forget to update that.
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    BLog();
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    */
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    BLog();
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    BLog();
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    BLog();
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    BLog();
    /*
     Called when the application is about to terminate. Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}


@end
