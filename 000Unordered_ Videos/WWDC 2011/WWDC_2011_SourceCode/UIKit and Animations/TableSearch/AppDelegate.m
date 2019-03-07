
/*
     File: AppDelegate.m
 Abstract: The application delegate used to configure the navigation controller.
  Version: 1.5
 
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
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */

#import "AppDelegate.h"
#import "MainViewController.h"
#import "Product.h"

@implementation AppDelegate;

@synthesize window, navController;

- (void)dealloc
{
	[navController release];
    [window release];
    [super dealloc];
}


- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    // Create and configure the window, navigation controller, and main view controller.

	// Create the master list for the main view controller.
	NSArray *listContent = [[NSArray alloc] initWithObjects:
						 [Product productWithType:@"Device" name:@"iPhone"],
						 [Product productWithType:@"Device" name:@"iPod"],
						 [Product productWithType:@"Device" name:@"iPod touch"],
						 [Product productWithType:@"Desktop" name:@"iMac"],
						 [Product productWithType:@"Desktop" name:@"Mac Pro"],
						 [Product productWithType:@"Portable" name:@"iBook"],
						 [Product productWithType:@"Portable" name:@"MacBook"],
						 [Product productWithType:@"Portable" name:@"MacBook Pro"],
						 [Product productWithType:@"Portable" name:@"PowerBook"], nil];
					
	
	// Create and configure the main view controller.
	MainViewController *mainViewController = [[MainViewController alloc] initWithNibName:@"MainView" bundle:nil];
	mainViewController.listContent = listContent;
	[listContent release];
	
	// Add create and configure the navigation controller.
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
	self.navController = navigationController;
	[mainViewController release];
	[navigationController release];
	
	// Configure and display the window.
	[window addSubview:navController.view];
	[window makeKeyAndVisible];
}


@end
