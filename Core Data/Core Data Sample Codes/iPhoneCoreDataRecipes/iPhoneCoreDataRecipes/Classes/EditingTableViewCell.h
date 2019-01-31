/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A table view cell that displays a label and a text field so that a value can be edited. The user interface is loaded from a nib file.
 */

@interface EditingTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *label;
@property (nonatomic, strong) IBOutlet UITextField *textField;

@end
