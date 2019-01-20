/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  AAPLRootViewController implementation.
  
 */

#import "AAPLRootViewController.h"
#import "AAPLPhotoCollectionViewCell.h"
#import "AAPLOverlayViewController.h"

#import "AAPLOverlayTransitioner.h"
#import "AAPLCoolTransitioner.h"

#define kNumberOfViews (37)
#define kViewsWide (5)
#define kViewMargin (2.0)
#define kCellReuseIdentifier @"CellReuseIdentifier"

@implementation AAPLRootViewController

- (instancetype)init
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self = [super initWithCollectionViewLayout:layout];
    if (self)
    {
        [self configureTitleBar];
    }
    return self;
}

- (void)viewDidLoad
{
    [[self collectionView] registerClass:[AAPLPhotoCollectionViewCell class] forCellWithReuseIdentifier:kCellReuseIdentifier];
    [[self collectionView] setBackgroundColor:nil];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)[self collectionViewLayout];
    
    [layout setMinimumInteritemSpacing:kViewMargin];
    [layout setMinimumLineSpacing:kViewMargin];
    
    [self viewWillTransitionToSize:[[self view] bounds].size withTransitionCoordinator:nil];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return kNumberOfViews;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AAPLPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    NSString *photoName = [@([indexPath item]) stringValue];
    UIImage *photo = [UIImage imageNamed:photoName];
    
    [cell setImage:photo];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AAPLOverlayViewController *overlay = [[AAPLOverlayViewController alloc] init];
    
    if([self presentationShouldBeAwesome])
    {
        transitioningDelegate = [[AAPLCoolTransitioningDelegate alloc] init];
    }
    else
    {
        transitioningDelegate = [[AAPLOverlayTransitioningDelegate alloc] init];
    }

    [overlay setTransitioningDelegate:transitioningDelegate];

    AAPLPhotoCollectionViewCell *selectedCell = (AAPLPhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    [overlay setPhotoView:selectedCell];
    
    [self presentViewController:overlay animated:YES completion:NULL];
}

- (BOOL)presentationShouldBeAwesome
{
    return [coolSwitch isOn];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    CGFloat itemWidth = size.width / kViewsWide;
    itemWidth -= kViewMargin;
    
    [(UICollectionViewFlowLayout *)[[self collectionView] collectionViewLayout] setItemSize:CGSizeMake(itemWidth, itemWidth)];
    [[self collectionViewLayout] invalidateLayout];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)configureTitleBar
{
    [self setTitle:NSLocalizedString(@"LookInside Photos", @"App Title")];
    [self setEdgesForExtendedLayout:UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight];
        
    coolSwitch = [[UISwitch alloc] init];
    [coolSwitch setOnTintColor:[UIColor purpleColor]];
    [coolSwitch setTintColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.2]];
    
    UIBarButtonItem *enablecoolBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:coolSwitch];
    
    [[self navigationItem] setLeftBarButtonItem:enablecoolBarButtonItem];
}

@end
