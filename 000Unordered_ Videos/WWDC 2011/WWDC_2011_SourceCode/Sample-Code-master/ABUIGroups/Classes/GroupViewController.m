/*
     File: GroupViewController.m
 Abstract: Adds, displays, and removes group records. Uses
 AddGroupDelegate to retrieve the typed group name.
 
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

#import "GroupViewController.h"
#import "MySource.h"

@implementation GroupViewController
@synthesize sourcesAndGroups;


#pragma mark -
#pragma mark Manage groups

// Return the name associated with the given identifier
- (NSString *)nameForSourceWithIdentifier:(int)identifier
{
	switch (identifier)
	{
		case kABSourceTypeLocal:
			return @"On My Device";
			break;
		case kABSourceTypeExchange:
			return @"Exchange server";
			break;
		case kABSourceTypeExchangeGAL:
			return @"Exchange Global Address List";
			break;
		case kABSourceTypeMobileMe:
			return @"MobileMe";
			break;
		case kABSourceTypeLDAP:
			return @"LDAP server";
			break;
		case kABSourceTypeCardDAV:
			return @"CardDAV server";
			break;
		case kABSourceTypeCardDAVSearch:
			return @"Searchable CardDAV server";
			break;
		default:
			break;
	}
	return nil;
}


// Return the name of a given group
- (NSString *)nameForGroup:(ABRecordRef)group
{
	CFStringRef name = ABRecordCopyCompositeName(group);
	return [(NSString *)name autorelease];
}


// Return the name of a given source
- (NSString *)nameForSource:(ABRecordRef)source
{
	// Fetch the source type
	CFNumberRef sourceType = ABRecordCopyValue(source, kABSourceTypeProperty);
	
	// Fetch the name associated with the source type
	NSString *sourceName = [self nameForSourceWithIdentifier:[(NSNumber*)sourceType intValue]];
	CFRelease(sourceType);
	return sourceName;
}


#pragma mark -
#pragma mark Display New Group view controller

// Display the New Group view controller
- (void)showAddGroupViewController
{
	AddGroupViewController *anotherViewController = [[AddGroupViewController alloc] init];
	anotherViewController.delegate = self;
	[self presentModalViewController:anotherViewController animated:YES];
	[anotherViewController release];
}


// Remove a group from the given address book
- (void)deleteGroup:(ABRecordRef)group fromAddressBook:(ABAddressBookRef)myAddressBook
{
	CFErrorRef error = NULL;
	ABAddressBookRemoveRecord(myAddressBook, group, &error);
	ABAddressBookSave(myAddressBook,&error);
}


// Return a list of groups organized by sources
- (NSMutableArray *)fetchGroupsInAddressBook:(ABAddressBookRef)myAddressBook
{
	NSMutableArray *list = [NSMutableArray array];
	
	// Get all the sources from the address book
	CFArrayRef allSources = ABAddressBookCopyArrayOfAllSources(myAddressBook);
	
	for (CFIndex i = 0; i < CFArrayGetCount(allSources); i++)
    {
		ABRecordRef aSource = CFArrayGetValueAtIndex(allSources,i);
		
		// Fetch all groups included in the current source
		CFArrayRef result = ABAddressBookCopyArrayOfAllGroupsInSource (myAddressBook, aSource);
		
		// The app displays a source if and only if it contains groups
		if (CFArrayGetCount(result) > 0)
		{
			NSMutableArray *groups = [[NSMutableArray alloc] initWithArray:(NSArray *)result];
			
			// Fetch the source name
			NSString *sourceName = [self nameForSource:aSource];
			//Create a MySource object that contains the source name and all its groups
			MySource *source = [[MySource alloc] initWithAllGroups:groups name:sourceName];
			
			// Save the source object into the array
			[list addObject:source];
			[source release];
			[groups release];
		}
		
		CFRelease(result);
    }
	
	CFRelease(allSources);
    return list;	
}


#pragma mark -
#pragma mark AddGroup delegate method

-  (void)addViewController:(AddGroupViewController *)addGroupViewController 
			   didAddGroup:(NSString *)name
{
	BOOL sourceFound = NO;
	if ([name length] != 0)
	{
		
		CFErrorRef error = NULL;
		ABRecordRef newGroup = ABGroupCreate();
		ABRecordSetValue(newGroup,kABGroupNameProperty,name,&error);
		// Add the new group to the Address Book
		ABAddressBookAddRecord(addressBook, newGroup, &error);
		ABAddressBookSave(addressBook, &error);
		
		// Get the ABSource object that contains this new group
		ABRecordRef groupSource = ABGroupCopySource (newGroup);
		// Fetch the source name 
		NSString *sourceName = [self nameForSource:groupSource];
		CFRelease(groupSource);
	
		// Look for the above source among the sources in sourcesAndGroups
		for (MySource *source in sourcesAndGroups)
		{
			if ([source.name compare:sourceName] == 0)
			{
				// Associate the new group with the found source
				[source.groups addObject:(id)newGroup];
			    // Set sourceFound to YES if sourcesAndGroups already contains this source
				sourceFound = YES;
			}
		}
		
		// Add this source to sourcesAndGroups 
		if (!sourceFound)
		{
			NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithObjects:(id)newGroup, nil];
			MySource *newSource = [[MySource alloc] initWithAllGroups:mutableArray name:sourceName];
		    [self.sourcesAndGroups addObject:newSource];
			
			[newSource release];
			[mutableArray release];
		}
		
        [self.tableView reloadData];
		
		CFRelease(newGroup);
	}
	[self.navigationController dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
    self.tableView.allowsSelection = NO;
	
	addressBook = ABAddressBookCreate();
	CFRetain(addressBook);
	
	//Display all groups available in the Address Book
	self.sourcesAndGroups = [self fetchGroupsInAddressBook:addressBook];

	//Add an Edit button
	self.navigationItem.leftBarButtonItem = self.editButtonItem;
	
	// Create an Add button 
	UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
																				   target:self 
																				   action:@selector(showAddGroupViewController)];
	self.navigationItem.rightBarButtonItem = addButtonItem;
	[addButtonItem release];	
}


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [sourcesAndGroups count];
}


// Customize section header titles
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[sourcesAndGroups objectAtIndex:section] name];
}


// Customize the number of rows in the table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[[sourcesAndGroups objectAtIndex:section] groups] count];	
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	MySource *source = [sourcesAndGroups objectAtIndex:indexPath.section];
	ABRecordRef group = [source.groups objectAtIndex:indexPath.row];
	
	cell.textLabel.text = [self nameForGroup:group];
		
    return cell;
 }


#pragma mark -
#pragma mark Editing rows

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return UITableViewCellEditingStyleDelete;
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated 
{    
    [super setEditing:editing animated:animated];	
	//Disables the Add button while editing
	self.navigationItem.rightBarButtonItem.enabled = !editing;
}


// Handle the deletion of a group
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		MySource *source = [self.sourcesAndGroups objectAtIndex:indexPath.section];
		// group to be deleted
		ABRecordRef group = [source.groups objectAtIndex:indexPath.row];
		
		// Remove the above group from its associated source
		[source.groups removeObjectAtIndex:indexPath.row];
		
		// Remove the group from the address book
		[self deleteGroup:group fromAddressBook:addressBook];
		
		// Update the table view
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		
		// Remove the section from the table if the associated source does not contain any groups
		if ([source.groups count] == 0)
		{
			// Remove the source from sourcesAndGroups
			[self.sourcesAndGroups removeObject:source];
			
			[tableView deleteSections: [NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
		}
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning 
{
    // Release the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}


- (void)viewDidUnload 
{
	[super viewDidUnload];
	CFRelease(addressBook);
	self.sourcesAndGroups = nil;
}


- (void)dealloc 
{
	CFRelease(addressBook); 
	[sourcesAndGroups release];
    [super dealloc];
}

@end

