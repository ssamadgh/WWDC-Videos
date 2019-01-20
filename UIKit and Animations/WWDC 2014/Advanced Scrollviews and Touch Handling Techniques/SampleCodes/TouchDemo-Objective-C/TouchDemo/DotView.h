//
//  DotView.h
//  TouchDemo
//
//  Created by Antonio081014 on 8/22/15.
//  Copyright (c) 2015 antonio081014.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DotView : UIView
+ (DotView *)randomDotView;
+ (void)arrangeDotsRandomlyInView:(UIView *)containerView;
+ (void)arrangeDotsNeatlyInView:(UIView *)containerView;
+ (void)arrangeDotsNeatlyInViewWithNiftyAnimation:(UIView *)containerView;

- (instancetype)initWithColor:(UIColor *)aColor withRadius:(CGFloat)radius;
@end
