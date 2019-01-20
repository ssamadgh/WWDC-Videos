/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  A view controller that shows a list of conversations that can be viewed.
  
 */

#import "AAPLListTableViewController.h"
#import "AAPLConversation.h"
#import "AAPLConversationViewController.h"
#import "AAPLPhotoViewController.h"
#import "AAPLProfileViewController.h"
#import "AAPLUser.h"
#import "UIViewController+AAPLViewControllerShowing.h"

@interface AAPLListTableViewController ()
@end

@implementation AAPLListTableViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.title = NSLocalizedString(@"Conversations", @"Conversations");
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Profile", @"Profile") style:UIBarButtonItemStylePlain target:self action:@selector(showProfile:)];
        self.clearsSelectionOnViewWillAppear = NO;
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [self init];
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIViewControllerShowDetailTargetDidChangeNotification object:nil];
}

static NSString * const AAPLListTableViewControllerCellIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:AAPLListTableViewControllerCellIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDetailTargetDidChange:) name:UIViewControllerShowDetailTargetDidChangeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
        BOOL pushes;
        if ([self shouldShowConversationViewForIndexPath:indexPath]) {
            pushes = [self aapl_willShowingViewControllerPushWithSender:self];
        } else {
            pushes = [self aapl_willShowingDetailViewControllerPushWithSender:self];
        }
        if (pushes) {
            // If we're pushing for this indexPath, deselect it when we appear
            [self.tableView deselectRowAtIndexPath:indexPath animated:animated];
        }
    }
}

- (void)showDetailTargetDidChange:(NSNotification *)notification
{
    // Whenever the target for showDetailViewController: changes, update all of our cells (to ensure they have the right accessory type)
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self tableView:self.tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}


- (BOOL)aapl_containsPhoto:(AAPLPhoto *)photo
{
    return YES;
}

- (void)setUser:(AAPLUser *)user
{
    if (_user != user) {
        _user = user;
        if ([self isViewLoaded]) {
            [self.tableView reloadData];
        }
    }
}

- (void)showProfile:(UIBarButtonItem *)sender
{
    AAPLProfileViewController *controller = [[AAPLProfileViewController alloc] init];
    controller.user = self.user;
    controller.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeProfile:)];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    navController.modalPresentationStyle = UIModalPresentationPopover;
    navController.popoverPresentationController.barButtonItem = sender;
    navController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    [self presentViewController:navController animated:YES completion:NULL];
}

- (void)closeProfile:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Table view

- (AAPLConversation *)conversationForIndexPath:(NSIndexPath *)indexPath
{
    return [self.user.conversations objectAtIndex:indexPath.row];
}

- (BOOL)shouldShowConversationViewForIndexPath:(NSIndexPath *)indexPath
{
    AAPLConversation *conversation = [self conversationForIndexPath:indexPath];
    return (conversation.photos.count != 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.user.conversations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AAPLListTableViewControllerCellIdentifier forIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL pushes;
    if ([self shouldShowConversationViewForIndexPath:indexPath]) {
        pushes = [self aapl_willShowingViewControllerPushWithSender:self];
    } else {
        pushes = [self aapl_willShowingDetailViewControllerPushWithSender:self];
    }
    
    // Only show a disclosure indicator if we're pushing
    if (pushes) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    AAPLConversation *conversation = [self conversationForIndexPath:indexPath];
    cell.textLabel.text = conversation.name;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AAPLConversation *conversation = [self conversationForIndexPath:indexPath];
    if ([self shouldShowConversationViewForIndexPath:indexPath]) {
        AAPLConversationViewController *controller = [[AAPLConversationViewController alloc] init];
        controller.conversation = conversation;
        controller.title = conversation.name;
        
        // If this row has a conversation, we just want to show it
        [self showViewController:controller sender:self];
    } else {
        AAPLPhoto *photo = [conversation.photos lastObject];
        AAPLPhotoViewController *controller = [[AAPLPhotoViewController alloc] init];
        controller.photo = photo;
        controller.title = conversation.name;
        
        // If this row has a single photo, then show it as the detail (if possible)
        [self showDetailViewController:controller sender:self];
    }
}

@end
