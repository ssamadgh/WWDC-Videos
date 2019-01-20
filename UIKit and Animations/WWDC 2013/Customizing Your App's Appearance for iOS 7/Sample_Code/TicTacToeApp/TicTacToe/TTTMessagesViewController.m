/*
     File: TTTMessagesViewController.m
 Abstract: 
 
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

#import "TTTMessagesViewController.h"

#import "TTTMessage.h"
#import "TTTMessageServer.h"
#import "TTTNewMessageViewController.h"

@interface TTTMessagesViewController ()
@property (strong, nonatomic) TTTProfile *profile;
@end

@interface TTTMessageTableViewCell : UITableViewCell
@property (strong, nonatomic) UIButton *replyButton;
@property (nonatomic) BOOL showReplyButton;
@end

@implementation TTTMessagesViewController {
    TTTMessage *_selectedMessage;
}

+ (UIViewController *)viewControllerWithProfile:(TTTProfile *)profile profileURL:(NSURL *)profileURL;
{
    TTTMessagesViewController *controller = [[self alloc] init];
    controller.profile = profile;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    return navController;
}

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.title = NSLocalizedString(@"Messages", @"Messages");
        self.tabBarItem.image = [UIImage imageNamed:@"messagesTab"];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"messagesTabSelected"];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(newMessage:)];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddMessages:) name:TTTMessageServerDidAddMessagesNotification object:[TTTMessageServer sharedMessageServer]];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(favorite:)];
        [self updateFavoriteButton];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [self init];
    return self;
}

static NSString *CellIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[TTTMessageTableViewCell class] forCellReuseIdentifier:CellIdentifier];
}

- (void)newMessage:(id)sender
{
    TTTNewMessageViewController *controller = [[TTTNewMessageViewController alloc] init];
    controller.profile = self.profile;
    [controller presentFromViewController:self];
}

- (void)didAddMessages:(NSNotification *)notification
{
    NSArray *addedIndexes = notification.userInfo[TTTMessageServerAddedMessageIndexesUserInfoKey];
    NSMutableArray *addedIndexPaths = [NSMutableArray array];
    for (NSNumber *indexValue in addedIndexes) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[indexValue integerValue] inSection:0];
        [addedIndexPaths addObject:indexPath];
    }
    [self.tableView insertRowsAtIndexPaths:addedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)favorite:(id)sender
{
    BOOL favorite = [[TTTMessageServer sharedMessageServer] isFavoriteMessage:_selectedMessage];
    favorite = !favorite;
    [[TTTMessageServer sharedMessageServer] setFavorite:favorite forMessage:_selectedMessage];
    [self updateFavoriteButton];
}

- (void)updateFavoriteButton
{
    BOOL favorite = NO;
    if (_selectedMessage) {
        favorite = [[TTTMessageServer sharedMessageServer] isFavoriteMessage:_selectedMessage];
    }
    
    UIImage *image;
    if (favorite) {
        image = [[UIImage imageNamed:@"favorite"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    } else {
        image = [UIImage imageNamed:@"favoriteUnselected"];
    }
    self.navigationItem.leftBarButtonItem.image = image;
    self.navigationItem.leftBarButtonItem.enabled = (_selectedMessage != nil);
}

#pragma mark - Table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[TTTMessageServer sharedMessageServer] numberOfMessages];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(TTTMessageTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTTMessage *message = [[TTTMessageServer sharedMessageServer] messageAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", message.text];
    cell.imageView.image = [TTTProfile smallImageForIcon:message.icon];
    
    if (!cell.replyButton) {
        UIButton *replyButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [replyButton addTarget:self action:@selector(newMessage:) forControlEvents:UIControlEventTouchUpInside];
        [replyButton setImage:[UIImage imageNamed:@"reply"] forState:UIControlStateNormal];
        [replyButton sizeToFit];
        cell.replyButton = replyButton;
    }
    
    BOOL isSelected = [tableView.indexPathForSelectedRow isEqual:indexPath];
    [cell setShowReplyButton:isSelected];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTTMessageTableViewCell *cell = (TTTMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell setShowReplyButton:NO];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTTMessage *message = [[TTTMessageServer sharedMessageServer] messageAtIndex:indexPath.row];
    TTTMessageTableViewCell *cell = (TTTMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (_selectedMessage == message) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        _selectedMessage = nil;
        [cell setShowReplyButton:NO];
    } else {
        _selectedMessage = message;
        [cell setShowReplyButton:YES];
    }
    [self updateFavoriteButton];
}

@end

@implementation TTTMessageTableViewCell

- (void)setShowReplyButton:(BOOL)value
{
    if (_showReplyButton != value) {
        _showReplyButton = value;
        if (_showReplyButton) {
            self.accessoryView = self.replyButton;
        } else {
            self.accessoryView = nil;
        }
    }
}

@end
