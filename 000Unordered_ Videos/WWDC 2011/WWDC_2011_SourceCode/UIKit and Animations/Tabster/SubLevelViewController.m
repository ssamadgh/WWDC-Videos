/*
     File: SubLevelViewController.m 
 Abstract: The view controller for sublevel 2. 
  Version: 1.1 
  
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
  
 Copyright (C) 2012 Apple Inc. All Rights Reserved. 
  
 */

#import "SubLevelViewController.h"
#import "ModalViewController.h"

@interface SubLevelViewController ()
	@property (nonatomic, retain) NSArray *dataArray;
@end

@implementation SubLevelViewController

@synthesize dataArray, modalViewController, currentSelectionTitle;

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.hidesBottomBarWhenPushed = YES;
	
	self.dataArray = [NSArray arrayWithObjects:@"Feature 1", @"Feature 2", nil];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	self.dataArray = nil;
	self.modalViewController = nil;
}

- (void)dealloc
{
	[dataArray release];
	[modalViewController release];
	[currentSelectionTitle release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	// keep track of the parent navigation controller so "modalViewController" can dismiss itself
	self.modalViewController.parentNavController = self.navigationController;
	
	// keep track of this view controller so modalViewController can set its label value;
	self.modalViewController.owningViewController = self;
	
	self.currentSelectionTitle = cell.textLabel.text;	// remember the current selection\
	
	[self.navigationController presentModalViewController:self.modalViewController animated:YES];
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellID2 = @"cellID2";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID2];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID2] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

	cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
	
	return cell;
}


#pragma mark -
#pragma mark UIViewControllerRotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES; // support all orientations
}

@end
