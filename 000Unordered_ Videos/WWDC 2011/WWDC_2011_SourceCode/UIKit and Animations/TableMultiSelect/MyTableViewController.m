/*
     File: MyTableViewController.m 
 Abstract: UIViewController subclass for managing the table and other UI. 
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

#import "MyTableViewController.h"

static NSString *kDeleteAllTitle = @"Delete All";
static NSString *kDeletePartialTitle = @"Delete (%d)";

@interface MyTableViewController ()

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) IBOutlet UIViewController *viewController;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *deleteButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *addButton;

- (IBAction)editAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)deleteAction:(id)sender;
- (IBAction)addAction:(id)sender;
@end

#pragma mark -

@implementation MyTableViewController

@synthesize viewController, dataArray, editButton, cancelButton, deleteButton, addButton;

- (void)resetUI
{
    // leave edit mode for our table and apply the edit button
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = self.editButton;
    [self.tableView setEditing:NO animated:YES];
    
    self.navigationItem.leftBarButtonItem = self.addButton;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.dataArray = [NSMutableArray arrayWithObjects:
                        @"Item 1", @"Item 2", @"Item 3", @"Item 4", @"Item 5", @"Item 6",
                      nil];
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    self.deleteButton.tintColor = [UIColor redColor];
    self.navigationItem.rightBarButtonItem = self.editButton;
    
    [self resetUI];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	self.dataArray = nil;
	self.viewController = nil;
    
    self.editButton = nil;
    self.cancelButton = nil;
    self.deleteButton = nil;
    self.addButton = nil;
}


#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.dataArray.count;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView.isEditing)
    {
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        self.deleteButton.title = (selectedRows.count == 0) ?
            kDeleteAllTitle : [NSString stringWithFormat:kDeletePartialTitle, selectedRows.count];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!self.tableView.isEditing)
    {
        self.viewController.title = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
        [[self navigationController] pushViewController:self.viewController animated:YES];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else
    {
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        NSString *deleteButtonTitle = [NSString stringWithFormat:kDeletePartialTitle, selectedRows.count];
        
        if (selectedRows.count == self.dataArray.count)
        {
            deleteButtonTitle = kDeleteAllTitle;
        }
        self.deleteButton.title = deleteButtonTitle;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellID = @"cellID";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
	
	return cell;
}


#pragma mark -
#pragma mark Action methods

- (IBAction)editAction:(id)sender
{
    // setup our UI for editing
    self.navigationItem.rightBarButtonItem = self.cancelButton;

    self.deleteButton.title = kDeleteAllTitle;
    
    self.navigationItem.leftBarButtonItem = self.deleteButton;
                                                                                       
    [self.tableView setEditing:YES animated:YES];
}

- (IBAction)cancelAction:(id)sender
{
    [self resetUI]; // reset our UI
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 0)
	{
		// delete the selected rows
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        if (selectedRows.count > 0)
        {
            // setup our deletion array so they can all be removed at once
            NSMutableArray *deletionArray = [NSMutableArray array];
            for (NSIndexPath *selectionIndex in selectedRows)
            {
                [deletionArray addObject:[self.dataArray objectAtIndex:selectionIndex.row]];
            }
            [self.dataArray removeObjectsInArray:deletionArray];
            
            // then delete the only the rows in our table that were selected
            [self.tableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else
        {
            [self.dataArray removeAllObjects];
            
            // since we are deleting all the rows, just reload the current table section
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        [self resetUI]; // reset our UI
        [self.tableView setEditing:NO animated:YES];
        
        self.editButton.enabled = (self.dataArray.count > 0) ? YES : NO;
	}
}

- (IBAction)deleteAction:(id)sender
{
    // open a dialog with just an OK button
	NSString *actionTitle = ([[self.tableView indexPathsForSelectedRows] count] == 1) ?
        @"Are you sure you want to remove this item?" : @"Are you sure you want to remove these items?";
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionTitle
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showInView:self.view];	// show from our table view (pops up in the middle of the table)
}

- (IBAction)addAction:(id)sender
{
    [self.tableView beginUpdates]; 
    
    [self.dataArray addObject:@"New Item"];
    NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:(self.dataArray.count - 1) inSection:0]];
    [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:NO];
    
    [self.tableView endUpdates];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(self.dataArray.count - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    self.editButton.enabled = (self.dataArray.count > 0) ? YES : NO;
}

@end

