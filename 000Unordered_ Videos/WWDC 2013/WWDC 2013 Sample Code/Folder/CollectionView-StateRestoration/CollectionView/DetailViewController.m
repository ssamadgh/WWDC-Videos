/*
     File: DetailViewController.m
 Abstract: 
 The secondary detail view controller for this app.
 
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


#import "AppDelegate.h"
#import "DetailViewController.h"
#import "FilterViewController.h"
#import "ImageFilter.h"

@interface DetailViewController ()

@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) NSMutableDictionary *filters;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic) CGFloat lastScale;
@property (nonatomic) BOOL statusBarHidden;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGestureRecognizer;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGestureRecognizer;

@end

@implementation DetailViewController

- (void) _updateImage {
    if (self.image == nil) {
        if (self.imageIdentifier) {
            self.title = [self.dataSource titleForIdentifier:self.imageIdentifier];
            self.image = [self.dataSource imageForIdentifier:self.imageIdentifier];
            self.imageView.image = self.image;
        }
        else {
            NSLog(@"%s - Warning: Called without an imageIdentifier set", __PRETTY_FUNCTION__);
            return;
        }
    }
    // Note prior to 7.0, these filters are not supported, but self.filters will always be nil when running
    // on an older version of iOS since we remove the toolbar items to create them (see below in viewDidLoad).
    if (self.image && self.filters) {
        CIImage *filteredCIImage = nil;
        UIImage *filteredImage = self.imageView.image;
        BlurFilter *blurFilter = [self.filters objectForKey:kBlurFilterKey];
        ModifyFilter *modifyFilter = [self.filters objectForKey:kModifyFilterKey];
        BOOL dirty = blurFilter.dirty || modifyFilter.dirty;
        if (blurFilter.active && dirty) {
            @try {
                CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
                if (filter) {
                    [filter setValue:[[CIImage alloc] initWithCGImage:self.image.CGImage] forKey:kCIInputImageKey];
                    [filter setValue:[NSNumber numberWithFloat:blurFilter.blurRadius * 50] forKey:kCIInputRadiusKey];
                    filteredCIImage = [filter valueForKey:kCIOutputImageKey];
                }
            } @catch (NSException *e) {
                NSLog(@"%s: Exception trying to set blur filter: %@", __PRETTY_FUNCTION__, e);
            }
        }
        if (modifyFilter.active && dirty) {
            @try {
                CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone"];
                if (filter) {
                    [filter setValue:(filteredCIImage ?: [[CIImage alloc] initWithCGImage:self.image.CGImage]) forKey:kCIInputImageKey];
                    [filter setValue:[NSNumber numberWithFloat:modifyFilter.intensity] forKey:kCIInputIntensityKey];
                    filteredCIImage = [filter valueForKey:kCIOutputImageKey];
                }
            } @catch (NSException *e) {
                NSLog(@"%s: Exception trying to set blur filter: %@", __PRETTY_FUNCTION__, e);
            }
        }
        if (filteredCIImage) {
            CIContext *context = [CIContext contextWithOptions:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], kCIContextUseSoftwareRenderer, nil]];
            CGImageRef cgImage = [context createCGImage:filteredCIImage fromRect:[filteredCIImage extent]];
            filteredImage = [[UIImage alloc] initWithCGImage:cgImage];
            self.imageView.image = filteredImage;
        }
        else if (dirty) {
            self.imageView.image = self.image;
        }
        blurFilter.dirty = modifyFilter.dirty = NO;
    }
}

- (void) _setImageViewConstraints:(UIDeviceOrientation)orientation {
    BOOL flip = UIInterfaceOrientationIsLandscape(orientation);
    NSArray *constraints = self.imageView.constraints;
    CGRect bounds = [UIScreen mainScreen].bounds;
    for (NSLayoutConstraint *constraint in constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            constraint.constant = flip ? bounds.size.width : bounds.size.height;
        }
        else if (constraint.firstAttribute == NSLayoutAttributeWidth) {
            constraint.constant = flip ? bounds.size.height : bounds.size.width;
        }
    }
    [self.imageView setNeedsUpdateConstraints];
}

- (void) viewDidLoad {
    // We use the check for this API introduced on iOS 7, and if not there we also know the filters we use aren't supported
    // and thus we remove the toolbar items so we never create filters we can't apply.
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        NSArray *items = @[[self.toolBar.items objectAtIndex:0]];
        self.toolBar.items = items;
    }
    self.lastScale = 1.0;
    self.imageView.userInteractionEnabled = YES;
}

- (BOOL) prefersStatusBarHidden {
    return self.statusBarHidden;
    
}

- (void) _updateBars:(NSTimeInterval)animationDuration {
    BOOL hidden = !self.toolBar.hidden; // Flip our hidden state
    
    if (hidden && self.navigationController.topViewController != self) {
        NSLog(@"%s: Asked to hide bar, but not the top view controller, skipping update of bars", __PRETTY_FUNCTION__);
        return;
    }

    // Animate the alpha for navbar and toolbar, and animate status bar's hidden state
    void (^animationBlock)() = ^{
        CGFloat alpha = hidden ? 0.0 : 1.0;
        [[UIApplication sharedApplication] setStatusBarHidden:hidden];
        self.statusBarHidden = hidden;
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            [self setNeedsStatusBarAppearanceUpdate];
        }
        if (hidden == NO) {
            self.toolBar.hidden = NO;
            [self.navigationController setNavigationBarHidden:NO animated:NO];
        }
        self.toolBar.alpha =  alpha;
        self.navigationController.navigationBar.alpha = alpha;
    };
    
    // If we're hiding, after animation completes really make navbar and statusbar hidden
    void (^completionBlock)(BOOL finished) = ^(BOOL finished) {
        if (finished && hidden) {
            self.toolBar.hidden = YES;
            [self.navigationController setNavigationBarHidden:YES animated:NO];
        }
    };
    
    if (animationDuration > 0.0) {
        [UIView animateWithDuration:animationDuration animations:animationBlock completion:completionBlock];
    }
    else {
        animationBlock();
        completionBlock(YES);
    }
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (CGAffineTransformIsIdentity(self.imageView.transform)) {
        [self _setImageViewConstraints:toInterfaceOrientation];
    }
    // If going to landscape, hide status bar if showing
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        if (self.statusBarHidden == NO) {
            [self _updateBars:0.0];
        }
    }
    // If going to portrait, show status bar if hidden
    else {
        if (self.statusBarHidden == YES) {
            [self _updateBars:0.0];
        }
    }
}

- (void) handleSingleTapGesture:(UIGestureRecognizer *)gestureRecognizer {
    [self _updateBars:0.25];
}

- (void) scale:(id)sender {
	if ([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
		self.lastScale = 1.0;
		return;
	}
	CGFloat scale = [(UIPinchGestureRecognizer*)sender scale] / self.lastScale;
	CGAffineTransform currentTransform = self.imageView.transform;
	CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
	self.imageView.transform = newTransform;
	self.lastScale = [(UIPinchGestureRecognizer*)sender scale];
}

- (void) handleDoubleTapGesture {
    [UIView animateWithDuration:0.4 animations:^{
        if (CGAffineTransformIsIdentity(self.imageView.transform)) {
            CGAffineTransform currentTransform = self.imageView.transform;
            CGFloat scale = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? 2.0 : 2.5;
            CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
            self.imageView.transform = newTransform;
        }
        else {
            self.imageView.transform = CGAffineTransformIdentity;
            self.lastScale = 1.0;
            [self _setImageViewConstraints:[UIApplication sharedApplication].statusBarOrientation];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    UIDevice *device = [UIDevice currentDevice];
    if ([[device systemVersion] floatValue] < 7.0) {
        [self setWantsFullScreenLayout:YES];
    }
    [super viewWillAppear:animated];
    [self _updateImage];
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        if (self.statusBarHidden == NO) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                // Make sure we're still in landscape, and the status bar isn't already hidden
                if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) && (self.statusBarHidden == NO)) {
                    [self _updateBars:0.75];
                }
            });
        }
    }

    if (self.tapGestureRecognizer == nil) {
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
        [self.imageView addGestureRecognizer:self.tapGestureRecognizer];
    }
    if (self.doubleTapGestureRecognizer == nil) {
        self.doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture)];
        self.doubleTapGestureRecognizer.numberOfTapsRequired = 2;
        [self.imageView addGestureRecognizer:self.doubleTapGestureRecognizer];
    }
    if (self.pinchGestureRecognizer == nil) {
        self.pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
        [self.imageView addGestureRecognizer:self.pinchGestureRecognizer];
    }
    [self.tapGestureRecognizer requireGestureRecognizerToFail:self.doubleTapGestureRecognizer];
    [self _setImageViewConstraints:[UIApplication sharedApplication].statusBarOrientation];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.toolBar.hidden) {
        [self _updateBars:0.0];
    }
}

- (void) _cleanupGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    [gestureRecognizer removeTarget:nil action:NULL];
    [self.imageView removeGestureRecognizer:gestureRecognizer];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [self _cleanupGestureRecognizer:self.tapGestureRecognizer]; self.tapGestureRecognizer = nil;
    [self _cleanupGestureRecognizer:self.doubleTapGestureRecognizer]; self.doubleTapGestureRecognizer = nil;
    [self _cleanupGestureRecognizer:self.pinchGestureRecognizer]; self.pinchGestureRecognizer = nil;
}

static ImageFilter *_createImageFilter (NSString *key, Class filterClass, BOOL useDefault) {
    ImageFilter *filter = nil;
    filter = [[filterClass alloc] initFilter:useDefault];
    filter.dirty = YES;
    if ([UIApplication respondsToSelector:@selector(registerObjectForStateRestoration:restorationIdentifier:)]) {
        [UIApplication registerObjectForStateRestoration:filter restorationIdentifier:key];
    }
    filter.objectRestorationClass = [DetailViewController class];
    return filter;
}

- (ImageFilter *) _imageFilterForKey:(NSString *)key class:(Class)filterClass {
    if (self.filters == nil) self.filters = [[NSMutableDictionary alloc] init];
    ImageFilter *filter = [self.filters objectForKey:key];
    if (filter == nil) {
        filter = _createImageFilter(key, filterClass, YES);
        [self.filters setObject:filter forKey:key];
    }
    return filter;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *key = nil;
    Class filterClass = Nil;
    NSString *segueIdentifier = [segue identifier];

    if ([segueIdentifier isEqualToString:@"showBlurInfo"]) {
        key = kBlurFilterKey;
        filterClass = [BlurFilter class];
    }
    else if ([segueIdentifier isEqualToString:@"showModifyInfo"]) {
        key = kModifyFilterKey;
        filterClass = [ModifyFilter class];
    }
    
    if (key) {
        ImageFilter *filter = [self _imageFilterForKey:key class:filterClass];
        FilterViewController *filterViewController = [segue destinationViewController];
        filterViewController.filter = filter;
    }
}

- (IBAction)share:(id)sender {
    if (self.imageView.image) {
        UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:[NSArray arrayWithObject:self.imageView.image] applicationActivities:nil];
        avc.restorationIdentifier = @"Activity";
        [self presentViewController:avc animated:YES completion:nil];
    }
}

#pragma mark -
#pragma mark -- State Restoration --

+ (NSObject<UIStateRestoring>*) objectWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    ImageFilter *filter = nil;
    Class filterClass = Nil;
    NSString *key = [identifierComponents lastObject];
    if ([key isEqualToString:kBlurFilterKey]) {
        filterClass = [BlurFilter class];
    }
    else if ([key isEqualToString:kModifyFilterKey]) {
        filterClass = [ModifyFilter class];
    }
    if (filterClass != Nil) {
        filter = _createImageFilter(key, filterClass, NO);
    }
    return filter;
}

#define kImageIdentifierKey @"kImageIdentifierKey"
#define kDataSourceKey @"kDataSourceKey"
#define kImageFiltersKey @"kImageFiltersKey"
#define kBarsHiddenKey @"kBarsHiddenKey"

- (void) encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    [coder encodeObject:self.self.imageIdentifier forKey:kImageIdentifierKey];
    // Only encode these objects if we're running on iOS 7 or later, else they will encode incorrectly.
    if ([UIApplication respondsToSelector:@selector(registerObjectForStateRestoration:restorationIdentifier:)]) {
        [coder encodeObject:self.dataSource forKey:kDataSourceKey];
        [coder encodeObject:self.filters forKey:kImageFiltersKey];
    }
    // If we're portrait, save whether the status bar is hidden or not. Since we never start up
    // in landscape, saving it for landscape is counter productive.
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        [coder encodeBool:self.toolBar.hidden forKey:kBarsHiddenKey];
    }
}

- (void) decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    self.imageIdentifier = [coder decodeObjectForKey:kImageIdentifierKey];
    self.dataSource = [coder decodeObjectForKey:kDataSourceKey];
    self.filters = [coder decodeObjectForKey:kImageFiltersKey];
    // On iOS versions prior to 7.0, we can't encode/decode the data source, so we have to ask the delegate for it.
    if (NO == [UIApplication respondsToSelector:@selector(registerObjectForStateRestoration:restorationIdentifier:)]) {
        self.dataSource = ((AppDelegate*)[UIApplication sharedApplication].delegate).dataSource;
        [self _updateImage];
    }
    BOOL hidden = [coder decodeBoolForKey:kBarsHiddenKey];
    if (hidden && !self.toolBar.hidden) {
        [self _updateBars:0.0];
    }
}

- (void) applicationFinishedRestoringState {
    [self _updateImage];    
}
@end
