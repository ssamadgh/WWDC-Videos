/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  A view controller that shows a user's profile.
  
 */

#import "AAPLProfileViewController.h"
#import "AAPLConversation.h"
#import "AAPLPhoto.h"
#import "AAPLUser.h"

@interface AAPLProfileViewController ()
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *conversationsLabel;
@property (strong, nonatomic) UILabel *photosLabel;

@property (copy, nonatomic) NSArray *constraints;
@end

@implementation AAPLProfileViewController

- (void)updateConstraintsForTraitCollection:(UITraitCollection *)collection
{
    NSDictionary *views = @{@"topLayoutGuide" : self.topLayoutGuide, @"imageView" : self.imageView, @"nameLabel" : self.nameLabel, @"conversationsLabel" : self.conversationsLabel, @"photosLabel" : self.photosLabel};
    NSMutableArray *newConstraints = [NSMutableArray array];
    if (collection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|[imageView]-[nameLabel]-|" options:0 metrics:nil views:views]];
        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"[imageView]-[conversationsLabel]-|" options:0 metrics:nil views:views]];
        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"[imageView]-[photosLabel]-|" options:0 metrics:nil views:views]];
        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topLayoutGuide]-[nameLabel]-[conversationsLabel]-[photosLabel]" options:0 metrics:nil views:views]];
        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topLayoutGuide][imageView]|" options:0 metrics:nil views:views]];
        [newConstraints addObject:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.5 constant:0.0]];
    } else {
        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|[imageView]|" options:0 metrics:nil views:views]];
        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[nameLabel]-|" options:0 metrics:nil views:views]];
        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[conversationsLabel]-|" options:0 metrics:nil views:views]];
        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[photosLabel]-|" options:0 metrics:nil views:views]];
        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLayoutGuide]-[nameLabel]-[conversationsLabel]-[photosLabel]-20-[imageView]|" options:0 metrics:nil views:views]];
    }
	
    if (self.constraints) {
        [self.view removeConstraints:self.constraints];
    }
    self.constraints = newConstraints;
    [self.view addConstraints:self.constraints];
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context) {
        [self updateConstraintsForTraitCollection:newCollection];
        [self.view setNeedsLayout];
    } completion:nil];
}



- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Profile", @"Profile");
    }
    return self;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:self.imageView];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:self.nameLabel];
    
    self.conversationsLabel = [[UILabel alloc] init];
    self.conversationsLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.conversationsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:self.conversationsLabel];
    
    self.photosLabel = [[UILabel alloc] init];
    self.conversationsLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.photosLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:self.photosLabel];
    
    self.view = view;
    [self updateUser];
    [self updateConstraintsForTraitCollection:self.traitCollection];
}

- (void)setUser:(AAPLUser *)user
{
    if (_user != user) {
        _user = user;
        if ([self isViewLoaded]) {
            [self updateUser];
        }
    }
}

- (NSString *)nameText
{
    return self.user.name;
}

- (NSString *)conversationsText
{
    return [NSString stringWithFormat:NSLocalizedString(@"%ld conversations", @"%ld conversations"), self.user.conversations.count];
}

- (NSString *)photosText
{
    NSUInteger photoCount = 0;
    for (AAPLConversation *conversation in self.user.conversations) {
        photoCount += conversation.photos.count;
    }
    return [NSString stringWithFormat:NSLocalizedString(@"%ld photos", @"%ld photos"), photoCount];
}

- (void)updateUser
{
    self.nameLabel.text = self.nameText;
    self.conversationsLabel.text = self.conversationsText;
    self.photosLabel.text = self.photosText;
    self.imageView.image = self.user.lastPhoto.image;
}

@end
