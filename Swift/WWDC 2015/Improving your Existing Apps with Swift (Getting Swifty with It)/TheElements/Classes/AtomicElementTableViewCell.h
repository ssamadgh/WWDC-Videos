/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
Draws the tableview cell and lays out the subviews.
*/

@import UIKit;

@class AtomicElement;

@interface AtomicElementTableViewCell : UITableViewCell

@property (nonatomic,strong) AtomicElement *element;

@end
