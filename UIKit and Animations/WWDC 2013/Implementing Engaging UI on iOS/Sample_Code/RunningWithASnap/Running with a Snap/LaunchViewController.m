/*
     File: LaunchViewController.m
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

#import "LaunchViewController.h"
#import "NewRunSetupViewController.h"
#import "PreviousRunPickerViewController.h"
#import "InterfaceManager.h"
#import "UIImage+ImageEffects.h"
#import "AppDelegate.h"
#import "LensFlareView.h"

@interface UIView (SymbolNotPublicInSeed1)
// This method was implemented in seed 1 but the symbol was not made public. It will be public in seed 2.
- (BOOL)drawViewHierarchyInRect:(CGRect)rect;
@end

@interface LaunchViewController ()
{
    BOOL _updateButtonArt;
}
@property (nonatomic, strong) IBOutlet UIImageView *backgroundView;
@property (nonatomic, strong) IBOutlet UIButton *makeNewRunButton;
@property (nonatomic, strong) IBOutlet UIButton *pastRunButton;
@property (nonatomic, strong) LensFlareView *lensFlareView;
@end

@implementation LaunchViewController

- (void)_applyBackgroundToButton:(UIButton *)button sourceBlurFromView:(UIView *)backgroundView {
    CGRect buttonRectInBGViewCoords = [button convertRect:button.bounds toView:backgroundView];

    UIGraphicsBeginImageContextWithOptions(button.frame.size, NO, [[[[self view] window] screen] scale]);
    /*
     Note that in seed 1, drawViewHierarchyInRect: does not function correctly. This has been fixed in seed 2. Seed 1 users will have empty images returned to them.
     */
    [backgroundView drawViewHierarchyInRect:CGRectMake(-buttonRectInBGViewCoords.origin.x, -buttonRectInBGViewCoords.origin.y, CGRectGetWidth(backgroundView.frame), CGRectGetHeight(backgroundView.frame))];
    UIImage *newBGImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    newBGImage = [newBGImage applyLightEffect];
    [button setBackgroundImage:newBGImage forState:UIControlStateNormal];
    
    button.layer.mask.frame = button.bounds;
    button.layer.cornerRadius = 4.0;
    button.layer.masksToBounds = YES;
    
    UIInterpolatingMotionEffect *xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    xAxis.minimumRelativeValue = [NSNumber numberWithFloat:-10.0];
    xAxis.maximumRelativeValue = [NSNumber numberWithFloat:10.0];
    
    UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    yAxis.minimumRelativeValue = [NSNumber numberWithFloat:-10.0];
    yAxis.maximumRelativeValue = [NSNumber numberWithFloat:10.0];
    
    UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
    group.motionEffects = @[xAxis, yAxis];
    [button addMotionEffect:group];
    
}

- (void)_updateInterface {
    if (_updateButtonArt) {
        [self _applyBackgroundToButton:_makeNewRunButton sourceBlurFromView:self.backgroundView];
        [self _applyBackgroundToButton:_pastRunButton sourceBlurFromView:self.backgroundView];
        
        _updateButtonArt = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    UIImage *bgImage = [APP_DELEGATE.interfaceManager backgroundImage];
    if (self.backgroundView.image != bgImage) {
        self.backgroundView.image = bgImage;
        _updateButtonArt = YES;
    }
    
    if (self.backgroundView.image) {
        if (_lensFlareView) {
            // Always generate a unique lens flare each time the launch page is shown
            [_lensFlareView removeFromSuperview];
        }
        
        _lensFlareView = [[LensFlareView alloc] initWithFrame:self.view.bounds flareLineEndPoint:CGPointMake(200, CGRectGetHeight(self.view.bounds))];
        [self.view insertSubview:_lensFlareView aboveSubview:self.backgroundView];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [self _updateInterface];
}

- (IBAction)startNewRun:(id)sender {
    NewRunSetupViewController *vc = [[NewRunSetupViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)choosePreviousRun:(id)sender {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    PreviousRunPickerViewController *vc = [[PreviousRunPickerViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
