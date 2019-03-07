/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A view controller that demonstrates how to use UIProgressView.
*/

#import "AAPLProgressViewController.h"

const NSUInteger kProgressViewControllerMaxProgress = 100;


@interface AAPLProgressViewController()

@property (nonatomic, weak) IBOutlet UIProgressView *defaultStyleProgressView;
@property (nonatomic, weak) IBOutlet UIProgressView *barStyleProgressView;
@property (nonatomic, weak) IBOutlet UIProgressView *tintedProgressView;

@property (nonatomic) NSOperationQueue *operationQueue;
@property (nonatomic) NSUInteger completedProgress;

@end


#pragma mark -

@implementation AAPLProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // All progress views should initially have zero progress.
    self.completedProgress = 0;

    [self configureDefaultStyleProgressView];
    [self configureBarStyleProgressView];
    [self configureTintedProgressView];

    // As progress is received from another subsystem (i.e. NSProgress, NSURLSessionTaskDelegate, etc.), update the progressView's progress.
    [self simulateProgress];
}

// Overrides the "completedProgress" property's setter.
- (void)setCompletedProgress:(NSUInteger)completedProgress {
    if (_completedProgress != completedProgress) {
        float fractionalProgress = (float)completedProgress / (float)kProgressViewControllerMaxProgress;

        // We only want to animate the progress if we're in the process of updating progress.
        BOOL animated = completedProgress != 0;
        
        [self.defaultStyleProgressView setProgress:fractionalProgress animated:animated];

        [self.barStyleProgressView setProgress:fractionalProgress animated:animated];

        [self.tintedProgressView setProgress:fractionalProgress animated:animated];

        _completedProgress = completedProgress;
    }
}


#pragma mark - Configuration

- (void)configureDefaultStyleProgressView {
    self.defaultStyleProgressView.progressViewStyle = UIProgressViewStyleDefault;
}

- (void)configureBarStyleProgressView {
    self.barStyleProgressView.progressViewStyle = UIProgressViewStyleBar;
}

- (void)configureTintedProgressView {
    self.tintedProgressView.progressViewStyle = UIProgressViewStyleDefault;

    self.tintedProgressView.trackTintColor = [UIColor aapl_applicationBlueColor];
    self.tintedProgressView.progressTintColor = [UIColor aapl_applicationPurpleColor];
}


#pragma mark - Progress Simulation

- (void)simulateProgress {
    // In this example we will simulate progress with a "sleep operation".
    self.operationQueue = [[NSOperationQueue alloc] init];
    
    for (NSUInteger count = 0; count < kProgressViewControllerMaxProgress; count++) {
        [self.operationQueue addOperationWithBlock:^{
            // Delay the system for a random number of seconds.
            // This code is _not_ intended for production purposes. The "sleep" call is meant to simulate work done in another subsystem.
            sleep(arc4random_uniform(10));
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.completedProgress++;
            }];
        }];
    }
}

@end
