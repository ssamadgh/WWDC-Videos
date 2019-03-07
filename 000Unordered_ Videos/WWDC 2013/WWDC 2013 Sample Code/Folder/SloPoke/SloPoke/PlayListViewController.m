/*
     File: PlayListViewController.m
 Abstract: The view controller for the play list table view.
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

#import "PlayListViewController.h"
#import "PlayListItem.h"
#import "PlayerViewController.h"

@interface PlayListViewController ()

@property(nonatomic, assign) IBOutlet UITableView *tableView;
@property(nonatomic, copy) NSURL *selectedURL;

@property(retain) NSMutableArray *urls;
@property(retain) NSMutableDictionary *itemCache;

@end

@implementation PlayListViewController

@synthesize selectedURL=_selectedURL;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	_urls = [[PlayListViewController assetURLs] retain];
	_itemCache = [[NSMutableDictionary alloc] init];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addMovieURL:) name:@"RecordingCompleted" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_urls release];
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	for (NSURL* URL in [_itemCache allKeys])
		[notificationCenter removeObserver:self name:PlayListItemDidChangeNotification object:[_itemCache objectForKey:URL]];
	[_itemCache release];
	[super dealloc];
}

+ (NSMutableArray *)assetURLs
{
	NSMutableArray *urls = [NSMutableArray array];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
	if (path) {
		for ( NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL] ) {
			if ( [[file pathExtension] isEqualToString:@"mov"] && [file hasPrefix:@"SloPoke_"] ) {
				[urls addObject:[NSURL fileURLWithPath:[path stringByAppendingPathComponent:file]]];
			}
		}
	}
	return urls;
}

- (void)itemDidChange:(NSNotification*)notification
{
	PlayListItem *item = [notification object];
	NSMutableArray *indexPaths = [NSMutableArray array];
	NSURL *URL = [item url];
	
	[_urls enumerateObjectsUsingBlock:
	 ^(id obj, NSUInteger idx, BOOL *stop)
	 {
		 if ([obj isEqual:URL])
			 [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
	 }];
	
	[self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

- (PlayListItem *)itemForURL:(NSURL*)URL
{
	PlayListItem* item = [_itemCache objectForKey:URL];
	
	if (!item)
	{
		item = [[[PlayListItem alloc] initWithURL:URL] autorelease];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidChange:) name:PlayListItemDidChangeNotification object:item];
		
		[_itemCache setObject:item forKey:URL];
	}
	
	return item;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_urls count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString* const cellIdentifier = @"PlayListItemCell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
	
	PlayListItem* item = [self itemForURL:[_urls objectAtIndex:[indexPath row]]];
	((UIImageView *)[cell viewWithTag:100]).image = item.thumbnail;
	((UILabel *)[cell viewWithTag:101]).text = item.title;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSURL* URL = [_urls objectAtIndex:[indexPath row]];
	
	if (_selectedURL != URL)
	{
		[_selectedURL release];
		_selectedURL = [URL copy];
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSURL *urlToDelete = [_urls[indexPath.row] retain];
		[_itemCache removeObjectForKey:urlToDelete];
		[_urls removeObject:urlToDelete];
		[[NSFileManager defaultManager] removeItemAtURL:urlToDelete error:NULL];
		[urlToDelete release];
		
		[tableView setEditing:NO animated:YES];
		[tableView reloadData];
    }
}

- (NSURL *)selectedURL
{
	return _selectedURL;
}

- (void)setSelectedURL:(NSURL *)URL
{
	if (_selectedURL != URL)
	{
		[_selectedURL release];
		_selectedURL = [URL copy];
		
		NSUInteger index = _urls ? [_urls indexOfObject:_selectedURL] : NSNotFound;
		NSIndexPath* path = index != NSNotFound ? [NSIndexPath indexPathForRow:index inSection:0] : nil;
		
		[self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ( [segue.identifier isEqual:@"showPlayerView"] ) {
		PlayerViewController *playController = segue.destinationViewController;
		NSIndexPath *path = [self.tableView indexPathForSelectedRow];
		NSURL *url = [_urls objectAtIndex:[path row]];
		playController.playListItem = [_itemCache objectForKey:url];
	}
	[super prepareForSegue:segue sender:sender];
}

- (void)addMovieURL:(NSNotification *)notification
{
	NSURL *URL = [[notification userInfo] objectForKey:@"URL"];
	if (URL) {
		[_urls addObject:URL];
		[self.tableView reloadData];
	}
}

@end
