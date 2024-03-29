/*
     File: RegionManager.m
 Abstract: Singleton class to manage region monitoring interations with a CLLocationManger
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
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */

#import "RegionManager.h"
#import "RemindersAppDelegate.h"

static CLLocationAccuracy const kRegionAccuracy = 100.0; // meters

static RegionManager *sharedInstance = nil;

@implementation RegionManager
+ (RegionManager *)sharedInstance {
	if (!sharedInstance) {
		sharedInstance = [[[self class] alloc] init];
	}
	return sharedInstance;
}

- (id)init {
	if ((self = [super init])) {
		locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self;
		locationManager.purpose = @"You will be notified whenever you pass by a location with a reminder.";
	}
	return self;
}

- (NSSet *)regions {
	NSSet *regions = [locationManager monitoredRegions];
	return regions;
}

- (CLLocationDistance)minDistance {
	return 1000.0; // 1km
}

- (CLLocationDistance)maxDistance {
	return [locationManager maximumRegionMonitoringDistance];
}

- (void)addRegion:(CLRegion *)region {
	NSLog(@"startMonitoringForRegion: %@",region);
	[locationManager startMonitoringForRegion:region];
}

- (void)removeRegion:(CLRegion *)region {
	NSLog(@"stopMonitoringForRegion: %@",region);
	[locationManager stopMonitoringForRegion:region];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

/*
 *  locationManager:didEnterRegion:
 *
 *  Discussion:
 *    Invoked when the user enters a monitored region.  This callback will be invoked for every allocated
 *    CLLocationManager instance with a non-nil delegate that implements this method.
 */
- (void)locationManager:(CLLocationManager *)manager
		 didEnterRegion:(CLRegion *)region {
	NSLog(@"didEnterRegion: %@", region);
	
	// issue notification the app delegate can respond to
	[(RemindersAppDelegate *)[UIApplication sharedApplication].delegate didEnterRegion:region];
}

/*
 *  locationManager:didExitRegion:
 *
 *  Discussion:
 *    Invoked when the user exits a monitored region.  This callback will be invoked for every allocated
 *    CLLocationManager instance with a non-nil delegate that implements this method.
 */
- (void)locationManager:(CLLocationManager *)manager
		  didExitRegion:(CLRegion *)region {
	NSLog(@"didExitRegion: %@", region);
	
	// issue notification the app delegate can respond to
	[(RemindersAppDelegate *)[UIApplication sharedApplication].delegate didExitRegion:region];
}

/*
 *  locationManager:monitoringDidFailForRegion:withError:
 *  
 *  Discussion:
 *    Invoked when a region monitoring error has occurred. Error types are defined in "CLError.h".
 */
- (void)locationManager:(CLLocationManager *)manager
	monitoringDidFailForRegion:(CLRegion *)region
			  withError:(NSError *)error {
	NSLog(@"monitoringDidFailForRegion: %@ withError: %@", region, error);
}

@end
