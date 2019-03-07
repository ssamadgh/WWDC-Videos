
/*
     File: CustomTableViewCellAppDelegate.m
 Abstract: Application delegate that sets up the navigation controller and the root view controller.
 
  Version: 2.1
 
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

#import "CustomTableViewCellAppDelegate.h"
#import "RootViewController.h"

#import "Region.h"


NSTimeZone *App_defaultTimeZone;

@implementation CustomTableViewCellAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	/*
	 We use these images and the application's time zone a lot, they're also static, so cache them and make them available globally...
	 */
	App_defaultTimeZone = [[NSTimeZone defaultTimeZone] retain];
	
	// Create the navigation and view controllers
	RootViewController *rootViewController = [[RootViewController alloc] initWithStyle:UITableViewStylePlain];
	
	rootViewController.displayList = [self displayList];
	rootViewController.calendar = [self calendar];
	
	UINavigationController *aNavigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
	self.navigationController = aNavigationController;
	[aNavigationController release];
	[rootViewController release];
	
	// Configure and show the window
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}


#pragma mark -
#pragma mark Setting up the display list

- (NSArray *)displayList {
	/*
	 Return an array of Region objects.
	 Each object represents a geographical region.  Each region contains time zones.
	 Much of the information required to display a time zone is expensive to compute, so rather than using NSTimeZone objects directly use wrapper objects that calculate the required derived values on demand and cache the results.
	 */
	NSArray *knownTimeZoneNames = [NSTimeZone knownTimeZoneNames];
	
	NSMutableArray *regions = [NSMutableArray array];
	
	for (NSString *timeZoneName in knownTimeZoneNames) {
		
		NSArray *components = [timeZoneName componentsSeparatedByString:@"/"];
		NSString *regionName = [components objectAtIndex:0];
		
		Region *region = [Region regionNamed:regionName];
		if (region == nil) {
			region = [Region newRegionWithName:regionName];
			region.calendar = [self calendar];
			[regions addObject:region];
			[region release];
		}
		
		NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:timeZoneName];
		[region addTimeZone:timeZone nameComponents:components];
		[timeZone release];
	}
	
	NSDate *date = [NSDate date];
	// Now sort the time zones by name
	for (Region *region in regions) {
		[region sortZones];
		[region setDate:date];
	}
	// Sort the regions
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	[regions sortUsingDescriptors:sortDescriptors];
	[sortDescriptor release];
	
	return regions;
}


- (NSCalendar *)calendar {
	if (calendar == nil) {
		calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	}
	return calendar;
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
    [window release];
    [calendar release];
    [super dealloc];
}

@end
