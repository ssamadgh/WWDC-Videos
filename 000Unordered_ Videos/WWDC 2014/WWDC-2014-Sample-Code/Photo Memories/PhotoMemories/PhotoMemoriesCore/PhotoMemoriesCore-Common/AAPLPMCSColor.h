//
//  AAPLPMCSColor.h
//  PhotoMemoriesCore
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  AAPLPMCSColor represents a cross-platform color object, and is an example of the wrapper pattern.
  
  AAPLPMCSColor can be initalized with a CGColor (platform-agnostic) or can be initialized with the
  color class of choice for a given platform (i.e. UIColor for iOS, NSColor for OS X). However,
  regardless of how the class is initialized, it ultimately relies on a CGColor instance variable to
  represent the underlying color. This CGColorRef can later used to create equivalent platform-specific
  color objects (i.e. UIColor or NSColor).
  
  
 */
@interface AAPLPMCSColor : NSObject <NSCopying>

@property (readonly) CGColorRef CGColor;

/** 
 * Designated initializer. Constructs a color fill with the given CGColor.
 */
+ (AAPLPMCSColor*) colorWithCGColor: (CGColorRef) color;

/** 
 * Constructs a color in the device RGB colorspace with the given rgb and alpha values.
 */
+ (AAPLPMCSColor*) colorWithRed: (CGFloat) red green: (CGFloat) green blue: (CGFloat) blue alpha: (CGFloat) alpha;

/** 
 * Constructs a color in the device greyscale colorspace with the given white and alpha values.
 */
+ (AAPLPMCSColor*) colorWithWhite: (CGFloat) white alpha: (CGFloat) alpha;

/** 
 * Constructs a color with hsb values.
 */
+ (AAPLPMCSColor*) colorWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha;

#if TARGET_OS_IPHONE
/** 
 * Constructs a new color fill with a UIColor.
 */
+ (AAPLPMCSColor*) colorWithUIColor:(UIColor*) uiColor;
#elif TARGET_OS_MAC
/**
 * Constructs a new color fill with a NSColor.
 */
+ (AAPLPMCSColor*) colorWithNSColor: (NSColor*) nsColor;
#endif

+ (AAPLPMCSColor*) clearColor;
+ (AAPLPMCSColor*) blackColor;
+ (AAPLPMCSColor*) whiteColor;
+ (AAPLPMCSColor*) grayColor;
+ (AAPLPMCSColor*) redColor;
+ (AAPLPMCSColor*) greenColor;
+ (AAPLPMCSColor*) blueColor;
+ (AAPLPMCSColor*) cyanColor;
+ (AAPLPMCSColor*) yellowColor;
+ (AAPLPMCSColor*) magentaColor;
+ (AAPLPMCSColor*) orangeColor;
+ (AAPLPMCSColor*) purpleColor;
+ (AAPLPMCSColor*) brownColor;
+ (AAPLPMCSColor*) lightGrayColor;

/** 
 * Initializes a new color fill with the given CG color.
 */
- (id) initWithCGColor: (CGColorRef) color;

/** 
 * Initializes a new color fill in the device rgb colorspace with the given rgb and alpha values.
 */
- (id) initWithRed: (CGFloat) red green: (CGFloat) green blue: (CGFloat) blue alpha: (CGFloat) alpha;

/**
 * Initializes a new color fill in the device greyscale colorspace with the given white and alpha values.
 */
- (id) initWithWhite: (CGFloat) white alpha: (CGFloat) alpha;

/** 
 * Initializes a new color with hsb values.
 */
- (id) initWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha;

#if TARGET_OS_IPHONE
/** 
 * Initialize a new color fill with a UIColor.
 */
- (id) initWithUIColor:(UIColor*) uiColor;
#elif TARGET_OS_MAC
/**
 * Initialize a new color fill with a NSColor.
 */
- (id) initWithNSColor:(NSColor*) nsColor;
#endif

#if TARGET_OS_IPHONE
/** 
 * Returns an equivalent UIColor.
 */
- (UIColor*) uiColor;
#elif TARGET_OS_MAC
/** 
 * Returns an equivalent NSColor.
 */
- (NSColor*) nsColor;
#endif

/**
 * Set the fill or stroke colors individually.
 */
- (void) setFill;

@end
