/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A view controller that demonstrates how to use UIButton. The buttons are created using storyboards, but each of the system buttons can be created in code by using the +[UIButton buttonWithType:] initializer. See UIButton.h for a comprehensive list of the various UIButtonType values.
*/

#import "AAPLButtonViewController.h"

@interface AAPLButtonViewController()

@property (nonatomic, weak) IBOutlet UIButton *systemTextButton;
@property (nonatomic, weak) IBOutlet UIButton *systemContactAddButton;
@property (nonatomic, weak) IBOutlet UIButton *systemDetailDisclosureButton;
@property (nonatomic, weak) IBOutlet UIButton *imageButton;
@property (nonatomic, weak) IBOutlet UIButton *attributedTextButton;

@end


#pragma mark -

@implementation AAPLButtonViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // All of the buttons are created in the storyboard, but configured below.
    [self configureSystemTextButton];
    [self configureSystemContactAddButton];
    [self configureSystemDetailDisclosureButton];
    [self configureImageButton];
    [self configureAttributedTextSystemButton];
}


#pragma mark - Configuration

- (void)configureSystemTextButton {
    [self.systemTextButton setTitle:NSLocalizedString(@"Button", nil) forState:UIControlStateNormal];
    
    [self.systemTextButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureSystemContactAddButton {
    self.systemContactAddButton.backgroundColor = [UIColor clearColor];
    
    [self.systemContactAddButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureSystemDetailDisclosureButton {
    self.systemDetailDisclosureButton.backgroundColor = [UIColor clearColor];
    
    [self.systemDetailDisclosureButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureImageButton {
    // To create this button in code you can use +[UIButton buttonWithType:] with a parameter value of UIButtonTypeCustom.
    
    // Remove the title text.
    [self.imageButton setTitle:@"" forState:UIControlStateNormal];

    self.imageButton.tintColor = [UIColor aapl_applicationPurpleColor];
    
    [self.imageButton setImage:[UIImage imageNamed:@"x_icon"] forState:UIControlStateNormal];

    // Add an accessibility label to the image.
    self.imageButton.accessibilityLabel = NSLocalizedString(@"X Button", nil);
    
    [self.imageButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureAttributedTextSystemButton {
    NSDictionary *titleAttributes = @{NSForegroundColorAttributeName: [UIColor aapl_applicationBlueColor], NSStrikethroughStyleAttributeName: @(NSUnderlineStyleSingle)};
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Button", nil) attributes:titleAttributes];
    [self.attributedTextButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];

    NSDictionary *highlightedTitleAttributes = @{NSForegroundColorAttributeName : [UIColor aapl_applicationGreenColor], NSStrikethroughStyleAttributeName: @(NSUnderlineStyleThick)};
    NSAttributedString *highlightedAttributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Button", nil) attributes:highlightedTitleAttributes];
    [self.attributedTextButton setAttributedTitle:highlightedAttributedTitle forState:UIControlStateHighlighted];

    [self.attributedTextButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - Actions

- (void)buttonClicked:(UIButton *)button {
    NSLog(@"A button was clicked: %@.", button);
}

@end
