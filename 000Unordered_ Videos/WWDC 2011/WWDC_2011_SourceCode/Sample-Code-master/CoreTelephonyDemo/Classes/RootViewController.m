/*
     File: RootViewController.m
 Abstract: Root view controller that sets up a grouped table view to display current call, call center, 
 and carrier information.
 
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
 
 Copyright (C) 2011 Apple Inc. All Rights Reserved.
 
 */

#import "RootViewController.h"
#import <UIKit/UIKit.h>
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>


#pragma mark -
#pragma mark RootViewController properties

@interface RootViewController ()

@property (nonatomic, retain) CTTelephonyNetworkInfo *tni;
@property (nonatomic, retain) CTCallCenter *callCenter;
@property (nonatomic, retain) NSString *crtCarrierName;
@property (nonatomic, copy) NSArray *crtCalls;

@end


#pragma mark -
#pragma mark RootViewController implementation

@implementation RootViewController

@synthesize tni, callCenter, crtCarrierName, crtCalls;


// Define a block for sorting calls by their callIDs.
NSComparator sortingBlock = ^(id call1, id call2) {
	NSString *callIdentifier = [call1 callID];
	NSString *call2Identifier = [call2 callID];
	NSComparisonResult result = [callIdentifier compare:call2Identifier 
												options:NSNumericSearch | NSForcedOrderingSearch 
												  range:NSMakeRange(0, [callIdentifier length]) 
												 locale:[NSLocale currentLocale]];
	return result;
};


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];

	self.title = @"Core Telephony Info";
	self.tableView.allowsSelection = NO;
	
	// Instantiate CTTelephonyNetworkInfo and CTCallCenter objects.
	tni = [[CTTelephonyNetworkInfo alloc] init];
	callCenter = [[CTCallCenter alloc] init];
	crtCarrierName = tni.subscriberCellularProvider.carrierName;
	
	// Get the set of current calls from call center.	
	crtCalls = [[callCenter.currentCalls allObjects] retain];
	
	// Sort current calls array by callIDs.
	crtCalls = [crtCalls sortedArrayUsingComparator:sortingBlock]; 
		
	// Define callEventHandler block inline
	callCenter.callEventHandler = ^(CTCall* inCTCall) {
		dispatch_async(dispatch_get_main_queue(), ^{
			crtCalls = [[callCenter.currentCalls allObjects] retain];
			crtCalls = [crtCalls sortedArrayUsingComparator:sortingBlock]; 

			[self.tableView reloadData];
		});
		
		// Enable this NSLog inspect current call center.
		// NSLog(@"%s, self: <%@>, callCenter: <%@>", __PRETTY_FUNCTION__, self, self.callCenter);
	};
	
	// Define subscriberCellularProviderDidUpdateNotifier block inline
	tni.subscriberCellularProviderDidUpdateNotifier = ^(CTCarrier* inCTCarrier) {
		dispatch_async(dispatch_get_main_queue(), ^{
			crtCarrierName = inCTCarrier.carrierName;
			[self.tableView reloadData];
		});
	};
	
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	self.tni.subscriberCellularProviderDidUpdateNotifier = nil;
	self.tni = nil;
	self.callCenter.callEventHandler = nil;
	self.callCenter = nil;
}

// Override and return YES to support all orientations.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}


- (NSDictionary *)callStateToUser {
	static NSDictionary *sCallStateToUser;
	if (sCallStateToUser == nil) {
		sCallStateToUser = [[NSDictionary alloc] initWithObjectsAndKeys:
							@"Dialing", CTCallStateDialing, 
							@"Incoming", CTCallStateIncoming, 
							@"Connected", CTCallStateConnected, 
							@"Disconnected", CTCallStateDisconnected, 
							nil];
	}
	return sCallStateToUser;
}


#pragma mark -
#pragma mark Table view data source

enum {
	kSectionIndexCurrentCall = 0,
	kSectionIndexCallCenter,
	kSectionIndexCarrier, 
	kSectionCount
};

enum {
    kSectionRowCurrentCall = 1,
    kSectionRowCallCenter = 1,
	kSectionRowCarrier = 1,
    kSectionRowCount
};


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return kSectionCount;
}


// Return the number of rows in the section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {	

	NSInteger numRows;
	
	// The number of rows varies by section.
    switch (section) {
        case kSectionIndexCurrentCall:
			// If there's 0 or 1 calls, display 1 row, otherwise set number of rows to the number of calls
			if ([crtCalls count] <= 1) {
				numRows = kSectionRowCurrentCall;				
			} else {
				numRows = [crtCalls count];
			}
			break;
        case kSectionIndexCallCenter:
            // 1 row for display total number of calls in call center
			numRows = kSectionRowCallCenter;
			break;
        case kSectionIndexCarrier:
            // 1 row for carrier info
			numRows = kSectionRowCarrier;
			break;
		default:
            return 1;
    }
	return numRows;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
    NSString *cellText = nil;
	
	// set the cell text to the CT information
    switch (indexPath.section) {
        case kSectionIndexCurrentCall:
			if ([crtCalls count] > 0){	
				// Display each call's call state.
				CTCall *call = [crtCalls objectAtIndex:indexPath.row];				
				cellText = [NSString stringWithFormat:@"Call %zu: %@", (size_t)indexPath.row+1,[[self callStateToUser] objectForKey:call.callState]];
			} else {
				cellText = @"No calls";
			}
			break;
				 
        case kSectionIndexCallCenter:
			// Display number of call in the call center.
			if ([crtCalls count] == 0){
				cellText = @"No calls";
			} else if ([crtCalls count] == 1) {
				cellText = [NSString stringWithFormat:@"%zu call at Call Center", [crtCalls count]];		
			} else {
				cellText = [NSString stringWithFormat:@"%zu calls at Call Center", [crtCalls count]];		
			}
            break;
			
        case kSectionIndexCarrier:
			// Display carrier name. If no carrier, display Unknown.
			if (crtCarrierName) {
				cellText = crtCarrierName;
			} else {
				cellText = @"Unknown";
			}
			if ([crtCarrierName compare:@""] == NSOrderedSame) {
				cellText = @"Unknown";
			}
            break;
			
        default:
            break;
    }
	
    cell.textLabel.text = cellText;
    return cell;
}


#pragma mark -
#pragma mark Section header titles

// Set the title for each section.
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *title = nil;
	
	// Define section titles.
    switch (section) {
        case kSectionIndexCurrentCall:
            title = @"Current call";
            break;
        case kSectionIndexCallCenter:
            title = @"Call center";
            break;
        case kSectionIndexCarrier:
            title = @"Carrier";
            break;
        default:
            break;
    }
    return title;
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[tni release];	
	[callCenter release];	
	[crtCarrierName release];
	[crtCalls release];
	
    [super dealloc];
}


@end
