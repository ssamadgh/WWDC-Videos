//
//  AAPLPMCSBezierPath.h
//  PhotoMemoriesCore
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>

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
  
  More information about the composite object pattern can be found here:
  https://developer.apple.com/library/ios/documentation/general/conceptual/CocoaEncyclopedia/ClassClusters/ClassClusters.html#//apple_ref/doc/uid/TP40010810-CH4-SW76
  
  More information about how Bezier paths work can be found here:
  https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CocoaDrawingGuide/Paths/Paths.html
  
 */
@interface AAPLPMCSBezierPath : NSObject

/**
 * Create a bezier path representing an oval which circumscribes a provided rect.
 */
- (AAPLPMCSBezierPath*) initWithOvalInRect:(CGRect)rect;

- (void) moveToPoint:(CGPoint)point;
- (void) lineToPoint:(CGPoint)point;
- (void) curveToPoint:(CGPoint)endPoint
       controlPoint1:(CGPoint)controlPoint1
       controlPoint2:(CGPoint)controlPoint2;
- (void) closePath;

@property(nonatomic,assign) CGFloat miterLimit;

- (void) fill;

@end
