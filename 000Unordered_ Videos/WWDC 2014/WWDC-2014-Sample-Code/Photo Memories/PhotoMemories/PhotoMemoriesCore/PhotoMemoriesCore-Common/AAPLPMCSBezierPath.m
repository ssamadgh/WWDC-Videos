//
//  AAPLPMCSBezierPath.m
//  PhotoMemoriesCore
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "AAPLPMCSBezierPath.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>

@interface AAPLPMCSiOSBezierPath : AAPLPMCSBezierPath
- (instancetype) initWithOvalInRect:(CGRect)rect;
@end

#else
@interface AAPLPMCSMacBezierPath : AAPLPMCSBezierPath
- (instancetype) initWithOvalInRect:(CGRect)rect;
@end
#endif


/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  AAPLPMCSBezierPath represents a cross-platform bezier path object.
  
  At a high level, this class sacrifices the functionality and granularity of pure NSBezierPaths and UIBezierPaths
  in exchange for the creation, basic path manipulation and filling of bezier paths in a platform-agnostic fashion.
  
  To achieve cross-platform functionality, this class uses the composite object pattern and wrapper pattern.
  In other words, when we initialize the AAPLPMCSBezierPath, we check the platform the code is being run on, and
  initialize a platform-specific subclass of AAPLPMCSBezierPath. In turn, the platform-specific subclasses wrap
  a UIBezierPath (in the case of iOS) and a NSBezierPath (in the case of OS X).
  
  More information about the composite object pattern can be found here: https://developer.apple.com/library/ios/documentation/general/conceptual/CocoaEncyclopedia/ClassClusters/ClassClusters.html#//apple_ref/doc/uid/TP40010810-CH4-SW76
  
 */
@implementation AAPLPMCSBezierPath

- (instancetype) init
{
#if TARGET_OS_IPHONE
    return [[AAPLPMCSiOSBezierPath alloc] init];
#else
    return [[AAPLPMCSMacBezierPath alloc] init];
#endif
}

- (instancetype) p_init
{
    return [super init];
}

- (instancetype) initWithOvalInRect:(CGRect)rect
{
#if TARGET_OS_IPHONE
    return [[AAPLPMCSiOSBezierPath alloc] initWithOvalInRect:rect];
#else
    return [[AAPLPMCSMacBezierPath alloc] initWithOvalInRect:rect];
#endif
}

- (void)moveToPoint:(CGPoint)point
{
    // no-op, overriden by concrete subclasses
}

- (void)lineToPoint:(CGPoint)point
{
    // no-op, overriden by concrete subclasses
}

- (void)curveToPoint:(CGPoint)endPoint
       controlPoint1:(CGPoint)controlPoint1
       controlPoint2:(CGPoint)controlPoint2
{
    // no-op, overriden by concrete subclasses
}

- (void)closePath
{
    // no-op, overriden by concrete subclasses
}

- (void)fill
{
    // no-op, overridden by concrete subclasses
}

@end

#if !TARGET_OS_IPHONE

@implementation AAPLPMCSMacBezierPath
{
    NSBezierPath *_backingBezierPath;
}

- (instancetype) init
{
    self = [self p_init];
    
    if (self != nil) {
        _backingBezierPath = [[NSBezierPath alloc] init];
    }
    
    return self;
}

- (AAPLPMCSBezierPath*) initWithOvalInRect:(CGRect)rect
{
    self = [super p_init];
    
    if (self != nil) {
        _backingBezierPath = [NSBezierPath bezierPathWithOvalInRect:rect];
    }
    
    return self;
}

- (void)moveToPoint:(CGPoint)point
{
    [_backingBezierPath moveToPoint:point];
}

- (void)lineToPoint:(CGPoint)point
{
    [_backingBezierPath lineToPoint:point];
}

- (void)curveToPoint:(CGPoint)endPoint
       controlPoint1:(CGPoint)controlPoint1
       controlPoint2:(CGPoint)controlPoint2
{
    [_backingBezierPath curveToPoint:endPoint
                       controlPoint1:controlPoint1
                       controlPoint2:controlPoint2];
}

- (void)closePath
{
    [_backingBezierPath closePath];
}

- (void)fill
{
    [_backingBezierPath fill];
}

- (CGFloat)miterLimit
{
    return [_backingBezierPath miterLimit];
}

- (void)setMiterLimit:(CGFloat)miterLimit
{
    return [_backingBezierPath setMiterLimit:miterLimit];
}

@end
#endif

#if TARGET_OS_IPHONE

@implementation AAPLPMCSiOSBezierPath
{
    UIBezierPath *_backingBezierPath;
}

- (instancetype) init
{
    self = [super p_init];
    
    if (self != nil) {
        _backingBezierPath = [[UIBezierPath alloc] init];
    }
    
    return self;
}

- (AAPLPMCSBezierPath*) initWithOvalInRect:(CGRect)rect
{
    self = [super init];
    
    if (self != nil) {
        _backingBezierPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    }
    
    return self;
}

- (void)moveToPoint:(CGPoint)point
{
    [_backingBezierPath moveToPoint:point];
}

- (void)lineToPoint:(CGPoint)point
{
    [_backingBezierPath addLineToPoint:point];
}

- (void)curveToPoint:(CGPoint)endPoint
       controlPoint1:(CGPoint)controlPoint1
       controlPoint2:(CGPoint)controlPoint2
{
    [_backingBezierPath addCurveToPoint:endPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
}

- (void)closePath
{
    [_backingBezierPath closePath];
}

- (void)fill
{
    [_backingBezierPath fill];
}

- (CGFloat)miterLimit
{
    return [_backingBezierPath miterLimit];
}

- (void)setMiterLimit:(CGFloat)miterLimit
{
    return [_backingBezierPath setMiterLimit:miterLimit];
}

@end
#endif