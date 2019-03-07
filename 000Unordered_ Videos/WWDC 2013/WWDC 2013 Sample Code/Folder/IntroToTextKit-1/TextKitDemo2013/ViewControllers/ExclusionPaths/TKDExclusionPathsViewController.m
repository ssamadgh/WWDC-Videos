/*
     File: TKDExclusionPathsViewController.m
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

#import "TKDExclusionPathsViewController.h"

@interface TKDExclusionPathsViewController ()
@property (nonatomic, strong, readonly) UIBezierPath *originalButterflyPath;
@property (nonatomic, strong) UIBezierPath *butterflyPath;
@property (nonatomic) CGPoint gestureStartingPoint;
@property (nonatomic) CGPoint gestureStartingCenter;
@end

@implementation TKDExclusionPathsViewController
- (UIBezierPath *)translatedBezierPath
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _originalButterflyPath = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"butterflyPath" ofType:@"plist"]];
    });

    CGRect butterflyImageRect = [self.textView convertRect:self.imageView.frame fromView:self.view];
    UIBezierPath *newButterflyPath = [self.originalButterflyPath copy];
    [newButterflyPath applyTransform:CGAffineTransformMakeTranslation(butterflyImageRect.origin.x, butterflyImageRect.origin.y)];

    return newButterflyPath;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.textView.attributedText = self.demo.attributedText;
    self.textView.textAlignment = NSTextAlignmentJustified;

    self.textView.textContainer.exclusionPaths = @[[self translatedBezierPath]];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    self.textView.textContainer.exclusionPaths = @[[self translatedBezierPath]];
}

- (IBAction)imagePanned:(id)sender
{
    if ([sender isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *localSender = sender;

        if (localSender.state == UIGestureRecognizerStateBegan) {
            self.gestureStartingPoint = [localSender translationInView:self.textView];
            self.gestureStartingCenter = self.imageView.center;
        } else if (localSender.state == UIGestureRecognizerStateChanged) {
            CGPoint currentPoint = [localSender translationInView:self.textView];

            CGFloat distanceX = currentPoint.x - self.gestureStartingPoint.x;
            CGFloat distanceY = currentPoint.y - self.gestureStartingPoint.y;

            CGPoint newCenter = self.gestureStartingCenter;

            newCenter.x += distanceX;
            newCenter.y += distanceY;

            self.imageView.center = newCenter;

            self.textView.textContainer.exclusionPaths = @[[self translatedBezierPath]];
        } else if (localSender.state == UIGestureRecognizerStateEnded) {
            self.gestureStartingPoint = CGPointZero;
            self.gestureStartingCenter = CGPointZero;
        }
    }
}
@end

