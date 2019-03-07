/*
     File: TTTRatingControl.m
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

#import "TTTRatingControl.h"

NSInteger const TTTRatingControlMinimumRating = 0;
NSInteger const TTTRatingControlMaximumRating = 4;

@implementation TTTRatingControl {
    UIImageView *_backgroundImageView;
    NSArray *_buttons;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _rating = TTTRatingControlMinimumRating;
    }
    return self;
}

+ (UIImage *)backgroundImage
{
    static UIImage *backgroundImage;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat cornerRadius = 4.0;
        CGFloat capSize = 2.0 * cornerRadius;
        CGFloat rectSize = 2.0 * capSize + 1.0;
        CGRect rect = CGRectMake(0.0, 0.0, rectSize, rectSize);
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
        
        [[UIColor colorWithWhite:0.0 alpha:0.2] set];
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
        [bezierPath fill];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(capSize, capSize, capSize, capSize)];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIGraphicsEndImageContext();
        
        backgroundImage = image;
    });
    return backgroundImage;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithImage:[[self class] backgroundImage]];
        [self addSubview:_backgroundImageView];
    }
    _backgroundImageView.frame = self.bounds;
    
    if (!_buttons) {
        NSMutableArray *buttons = [NSMutableArray array];
        for (NSInteger rating = TTTRatingControlMinimumRating; rating <= TTTRatingControlMaximumRating; rating++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[UIImage imageNamed:@"unselectedButton"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"unselectedButton"] forState:UIControlStateHighlighted];
            [button setImage:[UIImage imageNamed:@"favoriteButton"] forState:UIControlStateSelected];
            [button setImage:[UIImage imageNamed:@"favoriteButton"] forState:(UIControlStateSelected | UIControlStateHighlighted)];
            button.tag = rating;
            [button addTarget:self action:@selector(touchButton:) forControlEvents:UIControlEventTouchUpInside];
            [button setAccessibilityLabel:[NSString stringWithFormat:NSLocalizedString(@"%d stars", @"%d stars"), rating + 1]];
            [self addSubview:button];
            [buttons addObject:button];
        }
        
        _buttons = [buttons copy];
        [self updateButtonImages];
    }
    
    __block CGRect buttonFrame = self.bounds;
    CGFloat width = buttonFrame.size.width / (TTTRatingControlMaximumRating - TTTRatingControlMinimumRating + 1);
    [_buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger buttonIndex, BOOL *stop) {
        buttonFrame.size.width = round(width * (buttonIndex + 1)) - buttonFrame.origin.x;
        button.frame = buttonFrame;
        buttonFrame.origin.x += buttonFrame.size.width;
    }];
}

- (void)updateButtonImages
{
    [_buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger buttonIndex, BOOL *stop) {
        button.selected = (buttonIndex + TTTRatingControlMinimumRating <= self.rating);
    }];
}

- (void)touchButton:(UIButton *)button
{
    self.rating = button.tag;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)setRating:(NSInteger)value
{
    if (_rating != value) {
        _rating = value;
        [self updateButtonImages];
    }
}

#pragma mark - Accessibility

- (BOOL)isAccessibilityElement
{
    return NO;
}

@end
