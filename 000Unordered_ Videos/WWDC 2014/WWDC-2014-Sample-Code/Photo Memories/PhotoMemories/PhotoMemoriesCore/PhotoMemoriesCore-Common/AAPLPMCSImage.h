//
//  AAPLPMCSImage.h
//  PhotoMemories
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>

typedef UIImageOrientation AAPLPMCSImageOrientation;
const static AAPLPMCSImageOrientation
AAPLPMCSImageOrientationUp = UIImageOrientationUp,
AAPLPMCSImageOrientationDown = UIImageOrientationDown,
AAPLPMCSImageOrientationLeft = UIImageOrientationLeft,
AAPLPMCSImageOrientationRight = UIImageOrientationRight,
AAPLPMCSImageOrientationUpMirrored = UIImageOrientationUpMirrored,
AAPLPMCSImageOrientationDownMirrored = UIImageOrientationDownMirrored,
AAPLPMCSImageOrientationLeftMirrored = UIImageOrientationLeftMirrored,
AAPLPMCSImageOrientationRightMirrored = UIImageOrientationRightMirrored;

#else
/// Defined to be equivalent to UIImageOrientation
typedef enum {
    AAPLPMCSImageOrientationUp,            // default orientation
    AAPLPMCSImageOrientationDown,          // 180 deg rotation
    AAPLPMCSImageOrientationLeft,          // 90 deg CCW
    AAPLPMCSImageOrientationRight,         // 90 deg CW
    AAPLPMCSImageOrientationUpMirrored,    // as above but image mirrored along other axis. horizontal flip
    AAPLPMCSImageOrientationDownMirrored,  // horizontal flip
    AAPLPMCSImageOrientationLeftMirrored,  // vertical flip
    AAPLPMCSImageOrientationRightMirrored, // vertical flip
} AAPLPMCSImageOrientation;
#endif

/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  AAPLPMCSImage represents a cross-platform image object, and is an example of the composite object pattern.
  
  AAPLPMCSImage can be initialized with a CGImage (platform-agnostic) or can be initialized with the
  image class of choice for a given platform (i.e. UIImage for iOS, NSImage for OS X). However,
  regardless of how the class is initialized, it ultimately relies on a CGImageRef instance variable to
  represent the underlying image. This CGImageRef can later used to create equivalent platform-specific
  color objects (i.e. UIImage or NSImage).
  
  However, it is the goal of AAPLPMCSImage to not rely heavily on platform-specific image classes, therefore
  it stands in contrast to AAPLPMCSBezierPath, which wraps platform bezier classes heavily. It is worth
  nothing that they do accomplish the same end goal of providing a cross-platform object, but the means by
  which this is accomplished is considerably different.
  
  More information about the composite object pattern can be found here:
  https://developer.apple.com/library/ios/documentation/general/conceptual/CocoaEncyclopedia/ClassClusters/ClassClusters.html#//apple_ref/doc/uid/TP40010810-CH4-SW76
  
 */
@interface AAPLPMCSImage : NSObject

- (instancetype)initWithCGImage:(CGImageRef)imageRef;
- (instancetype)initWithCGImage:(CGImageRef)imageRef scale:(CGFloat)scale orientation:(AAPLPMCSImageOrientation)orientation;
- (instancetype)initWithData:(NSData *)data;

/**
 * Reflects the orientation setting. Size is in pixels.
 */
@property(nonatomic,readonly) CGSize size;

/**
 * Returns the underlying CGImage. May be cached by the system.
 */
@property(nonatomic,readonly) CGImageRef CGImage;

/**
 * The orientation of the image. This will affect how the image is composited.
 */
@property(nonatomic,readonly) AAPLPMCSImageOrientation imageOrientation;

/**
 * The scale of the image. Returns 1.0 if the scale cannot be deduced and the image was created without scale information.
 */
@property(nonatomic,readonly) CGFloat scale;

@end

#pragma mark UIKit-specific additions

#if TARGET_OS_IPHONE

@interface AAPLPMCSImage (UIKitAdditions)

- (instancetype)initWithUIImage:(UIImage *)image;

@property (nonatomic,readonly) UIImage *UIImage;

@end

#endif


#pragma mark AppKit-specific additions

#if !TARGET_OS_IPHONE

@interface AAPLPMCSImage (AppKitAdditions)

- (instancetype)initWithNSImage:(NSImage *)image;

@property(nonatomic,readonly) NSImage *NSImage;

@end

#endif
