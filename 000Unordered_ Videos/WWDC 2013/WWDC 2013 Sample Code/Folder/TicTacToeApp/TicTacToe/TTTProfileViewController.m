/*
     File: TTTProfileViewController.m
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

#import "TTTProfileViewController.h"

#import "TTTHistoryListViewController.h"
#import "TTTProfile.h"
#import "TTTCountView.h"

typedef NS_ENUM(NSInteger, TTTProfileViewControllerSection) {
    TTTProfileViewControllerSectionIcon,
    TTTProfileViewControllerSectionStatistics,
    TTTProfileViewControllerSectionHistory,
    
    TTTProfileViewControllerSectionCount,
};

@interface TTTProfileIconTableViewCell : UITableViewCell
@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@end

@interface TTTProfileStatisticsTableViewCell : UITableViewCell
@property (strong, nonatomic) TTTCountView *countView;
@end

@interface TTTProfileViewController ()
@property (strong, nonatomic) TTTProfile *profile;
@property (copy, nonatomic) NSURL *profileURL;
@end

@implementation TTTProfileViewController

+ (UIViewController *)viewControllerWithProfile:(TTTProfile *)profile profileURL:(NSURL *)profileURL;
{
    TTTProfileViewController *controller = [[self alloc] init];
    controller.profile = profile;
    controller.profileURL = profileURL;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    return navController;
}

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = NSLocalizedString(@"Profile", @"Profile");
        self.tabBarItem.image = [UIImage imageNamed:@"profileTab"];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"profileTabSelected"];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [self init];
    return self;
}

static NSString * const IconIdentifier = @"Icon";
static NSString * const StatisticsIdentifier = @"Statistics";
static NSString * const HistoryIdentifier = @"History";

- (void)loadView
{
    [super loadView];
    [self.tableView registerClass:[TTTProfileIconTableViewCell class] forCellReuseIdentifier:IconIdentifier];
    [self.tableView registerClass:[TTTProfileStatisticsTableViewCell class] forCellReuseIdentifier:StatisticsIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:HistoryIdentifier];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSInteger rowCount = [self tableView:self.tableView numberOfRowsInSection:TTTProfileViewControllerSectionStatistics];
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (NSInteger row = 0; row < rowCount; row++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:TTTProfileViewControllerSectionStatistics]];
    }
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (void)changeIcon:(UISegmentedControl *)sender
{
    self.profile.icon = sender.selectedSegmentIndex;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return TTTProfileViewControllerSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case TTTProfileViewControllerSectionIcon:
            return 1;
        case TTTProfileViewControllerSectionStatistics:
            return 3;
        case TTTProfileViewControllerSectionHistory:
            return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case TTTProfileViewControllerSectionIcon:
            return [tableView dequeueReusableCellWithIdentifier:IconIdentifier forIndexPath:indexPath];
        case TTTProfileViewControllerSectionStatistics:
            return [tableView dequeueReusableCellWithIdentifier:StatisticsIdentifier forIndexPath:indexPath];
        case TTTProfileViewControllerSectionHistory:
            return [tableView dequeueReusableCellWithIdentifier:HistoryIdentifier forIndexPath:indexPath];
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    switch (section) {
        case TTTProfileViewControllerSectionIcon:
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [[(TTTProfileIconTableViewCell *)cell segmentedControl] setSelectedSegmentIndex:self.profile.icon];
            [[(TTTProfileIconTableViewCell *)cell segmentedControl] addTarget:self action:@selector(changeIcon:) forControlEvents:UIControlEventValueChanged];
            break;
            
        case TTTProfileViewControllerSectionStatistics:
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (row == 0) {
                cell.textLabel.text = NSLocalizedString(@"Victories", @"Victories");
                cell.imageView.image = [[UIImage imageNamed:@"victory"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [[(TTTProfileStatisticsTableViewCell *)cell countView] setCount:[self.profile numberOfGamesWithResult:TTTGameResultVictory]];
            } else if (row == 1) {
                cell.textLabel.text = NSLocalizedString(@"Defeats", @"Defeats");
                cell.imageView.image = [[UIImage imageNamed:@"defeat"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [[(TTTProfileStatisticsTableViewCell *)cell countView] setCount:[self.profile numberOfGamesWithResult:TTTGameResultDefeat]];
            } else if (row == 2) {
                cell.textLabel.text = NSLocalizedString(@"Draws", @"Draws");
                cell.imageView.image = [[UIImage imageNamed:@"draw"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [[(TTTProfileStatisticsTableViewCell *)cell countView] setCount:[self.profile numberOfGamesWithResult:TTTGameResultDraw]];
            }
            break;
            
        case TTTProfileViewControllerSectionHistory:
            cell.textLabel.text = NSLocalizedString(@"Show History", @"Show History");
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == TTTProfileViewControllerSectionStatistics) {
        return NSLocalizedString(@"Statistics", @"Statistics");
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == TTTProfileViewControllerSectionIcon) {
        return 100.0;
    }
    return tableView.rowHeight;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == TTTProfileViewControllerSectionHistory) {
        return indexPath;
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTTHistoryListViewController *controller = [[TTTHistoryListViewController alloc] init];
    controller.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeHistory:)];
    controller.profile = self.profile;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [navController.navigationBar setBackIndicatorImage:[UIImage imageNamed:@"backIndicator"]];
    [navController.navigationBar setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"backIndicatorMask"]];
    
    [self presentViewController:navController animated:YES completion:NULL];
}

- (void)closeHistory:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end

@implementation TTTProfileIconTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImage *x = [[TTTProfile imageForIcon:TTTProfileIconX] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *o = [[TTTProfile imageForIcon:TTTProfileIconO] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[x, o]];
        _segmentedControl.frame = CGRectMake(0.0, 0.0, 240.0, 80.0);
        UIEdgeInsets capInsets = UIEdgeInsetsMake(6.0, 6.0, 6.0, 6.0);
        [_segmentedControl setBackgroundImage:[[UIImage imageNamed:@"segmentBackground"] resizableImageWithCapInsets:capInsets] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [_segmentedControl setBackgroundImage:[[UIImage imageNamed:@"segmentBackgroundHighlighted"] resizableImageWithCapInsets:capInsets] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
        [_segmentedControl setBackgroundImage:[[UIImage imageNamed:@"segmentBackgroundSelected"] resizableImageWithCapInsets:capInsets] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        [_segmentedControl setDividerImage:[UIImage imageNamed:@"segmentDivider"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        
        _segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        UIView *containerView = [[UIView alloc] initWithFrame:_segmentedControl.frame];
        [containerView addSubview:_segmentedControl];
        
        containerView.frame = self.contentView.bounds;
        containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:containerView];
    }
    return self;
}

@end

@implementation TTTProfileStatisticsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _countView = [[TTTCountView alloc] initWithFrame:CGRectMake(0.0, 0.0, 160.0, 20.0)];
        self.accessoryView = _countView;
    }
    return self;
}

@end
