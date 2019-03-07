//
//  AAPLPMCSButtons.m
//  PhotoMemoriesCore
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "AAPLPMCSButtons.h"

#import "AAPLPMCSBezierPath.h"
#import "AAPLPMCSColor.h"

#import <CoreGraphics/CoreGraphics.h>

/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  AAPLPMCSButtons contains common drawing logic for buttons shared across both platforms.
  
 */
@implementation AAPLPMCSButtons

+ (void) drawCameraButton
{
    // Circle
    AAPLPMCSColor *blueColor = [AAPLPMCSColor colorWithRed: 0 green: 0.295 blue: 0.886 alpha: 1];
    
    CGRect ovalRect = CGRectMake(0, 0, 44, 44);
    AAPLPMCSBezierPath *ovalPath = [[AAPLPMCSBezierPath alloc] initWithOvalInRect:ovalRect];
    
    [blueColor setFill];
    [ovalPath fill];
    
    // Camera
    AAPLPMCSBezierPath* bezierPath = [[AAPLPMCSBezierPath alloc] init];
    
    [bezierPath moveToPoint: CGPointMake(22, 19)];
    [bezierPath curveToPoint: CGPointMake(17.5, 23.5) controlPoint1: CGPointMake(19.51, 19) controlPoint2: CGPointMake(17.5, 21.02)];
    [bezierPath curveToPoint: CGPointMake(22, 28) controlPoint1: CGPointMake(17.5, 25.99) controlPoint2: CGPointMake(19.51, 28)];
    [bezierPath curveToPoint: CGPointMake(26.5, 23.5) controlPoint1: CGPointMake(24.48, 28) controlPoint2: CGPointMake(26.5, 25.99)];
    [bezierPath curveToPoint: CGPointMake(22, 19) controlPoint1: CGPointMake(26.5, 21.02) controlPoint2: CGPointMake(24.48, 19)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(34, 14.5)];
    [bezierPath lineToPoint: CGPointMake(30.4, 14.5)];
    [bezierPath curveToPoint: CGPointMake(29.22, 13.65) controlPoint1: CGPointMake(29.91, 14.5) controlPoint2: CGPointMake(29.37, 14.12)];
    [bezierPath lineToPoint: CGPointMake(28.28, 10.85)];
    [bezierPath curveToPoint: CGPointMake(27.1, 10) controlPoint1: CGPointMake(28.13, 10.38) controlPoint2: CGPointMake(27.59, 10)];
    [bezierPath lineToPoint: CGPointMake(16.9, 10)];
    [bezierPath curveToPoint: CGPointMake(15.72, 10.85) controlPoint1: CGPointMake(16.41, 10) controlPoint2: CGPointMake(15.87, 10.38)];
    [bezierPath lineToPoint: CGPointMake(14.78, 13.65)];
    [bezierPath curveToPoint: CGPointMake(13.6, 14.5) controlPoint1: CGPointMake(14.63, 14.12) controlPoint2: CGPointMake(14.09, 14.5)];
    [bezierPath lineToPoint: CGPointMake(10, 14.5)];
    [bezierPath curveToPoint: CGPointMake(7, 17.5) controlPoint1: CGPointMake(8.35, 14.5) controlPoint2: CGPointMake(7, 15.85)];
    [bezierPath lineToPoint: CGPointMake(7, 31)];
    [bezierPath curveToPoint: CGPointMake(10, 34) controlPoint1: CGPointMake(7, 32.65) controlPoint2: CGPointMake(8.35, 34)];
    [bezierPath lineToPoint: CGPointMake(34, 34)];
    [bezierPath curveToPoint: CGPointMake(37, 31) controlPoint1: CGPointMake(35.65, 34) controlPoint2: CGPointMake(37, 32.65)];
    [bezierPath lineToPoint: CGPointMake(37, 17.5)];
    [bezierPath curveToPoint: CGPointMake(34, 14.5) controlPoint1: CGPointMake(37, 15.85) controlPoint2: CGPointMake(35.65, 14.5)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(22, 31)];
    [bezierPath curveToPoint: CGPointMake(14.5, 23.5) controlPoint1: CGPointMake(17.86, 31) controlPoint2: CGPointMake(14.5, 27.64)];
    [bezierPath curveToPoint: CGPointMake(22, 16) controlPoint1: CGPointMake(14.5, 19.36) controlPoint2: CGPointMake(17.86, 16)];
    [bezierPath curveToPoint: CGPointMake(29.5, 23.5) controlPoint1: CGPointMake(26.14, 16) controlPoint2: CGPointMake(29.5, 19.36)];
    [bezierPath curveToPoint: CGPointMake(22, 31) controlPoint1: CGPointMake(29.5, 27.64) controlPoint2: CGPointMake(26.14, 31)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(32.95, 19.6)];
    [bezierPath curveToPoint: CGPointMake(31.9, 18.55) controlPoint1: CGPointMake(32.37, 19.6) controlPoint2: CGPointMake(31.9, 19.13)];
    [bezierPath curveToPoint: CGPointMake(32.95, 17.5) controlPoint1: CGPointMake(31.9, 17.97) controlPoint2: CGPointMake(32.37, 17.5)];
    [bezierPath curveToPoint: CGPointMake(34, 18.55) controlPoint1: CGPointMake(33.53, 17.5) controlPoint2: CGPointMake(34, 17.97)];
    [bezierPath curveToPoint: CGPointMake(32.95, 19.6) controlPoint1: CGPointMake(34, 19.13) controlPoint2: CGPointMake(33.53, 19.6)];
    [bezierPath closePath];
    
    [bezierPath setMiterLimit: 4];
    
    [[AAPLPMCSColor whiteColor] setFill];
    [bezierPath fill];
}

@end
