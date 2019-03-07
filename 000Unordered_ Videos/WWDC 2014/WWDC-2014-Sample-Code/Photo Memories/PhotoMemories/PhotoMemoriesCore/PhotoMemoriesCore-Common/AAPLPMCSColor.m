//
//  AAPLPMCSColor.m
//  PhotoMemoriesCore
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "AAPLPMCSColor.h"

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
@implementation AAPLPMCSColor
{
    CGColorRef _backingCGColor;
}

@synthesize CGColor = _backingCGColor;

+ (AAPLPMCSColor *)colorWithCGColor:(CGColorRef)CGColor
{
    return [[self alloc] initWithCGColor:CGColor];
}

+ (AAPLPMCSColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    return [[self alloc] initWithRed:red green:green blue:blue alpha:alpha];
}

+ (AAPLPMCSColor *)colorWithWhite:(CGFloat)white alpha:(CGFloat)alpha
{
    return [[self alloc] initWithWhite:white alpha:alpha];
}

+ (AAPLPMCSColor *)colorWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha
{
    return [[self alloc] initWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
}

#if TARGET_OS_IPHONE
+ (AAPLPMCSColor *)colorWithUIColor:(UIColor *)uiColor
{
    return [[self alloc] initWithUIColor:uiColor];
}
#elif TARGET_OS_MAC
+ (AAPLPMCSColor *)colorWithNSColor:(NSColor *)nsColor
{
    return [[self alloc] initWithNSColor:nsColor];
}
#endif

+ (AAPLPMCSColor *)clearColor
{
    return [[self alloc] initWithWhite:0.0 alpha:0.0];
}

+ (AAPLPMCSColor *)blackColor
{
    return [[self alloc] initWithWhite:0.0 alpha:1.0];
}

+ (AAPLPMCSColor *)whiteColor
{
    return [[self alloc] initWithWhite:1.0 alpha:1.0];
}

+ (AAPLPMCSColor *)grayColor
{
    return [[self alloc] initWithWhite:0.5 alpha:1.0];
}

+ (AAPLPMCSColor *)lightGrayColor
{
    return [[self alloc] initWithWhite:0.667 alpha:1.0];
}

+ (AAPLPMCSColor *)redColor
{
    return [[self alloc] initWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
}

+ (AAPLPMCSColor *)greenColor
{
    return [[self alloc] initWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
}

+ (AAPLPMCSColor *)blueColor
{
    return [[self alloc] initWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
}

+ (AAPLPMCSColor *)cyanColor
{
    return [[self alloc] initWithRed:0.0 green:1.0 blue:1.0 alpha:1.0];
}

+ (AAPLPMCSColor *)yellowColor
{
    return [[self alloc] initWithRed:1.0 green:1.0 blue:0.0 alpha:1.0];
}

+ (AAPLPMCSColor *)magentaColor
{
    return [[self alloc] initWithRed:1.0 green:0.0 blue:1.0 alpha:1.0];
}

+ (AAPLPMCSColor *)orangeColor
{
    return [[self alloc] initWithRed:1.0 green:0.5 blue:0.0 alpha:1.0];
}

+ (AAPLPMCSColor *)purpleColor
{
    return [[self alloc] initWithRed:0.5 green:0.0 blue:0.5 alpha:1.0];
}

+ (AAPLPMCSColor *)brownColor
{
    return [[self alloc] initWithRed:0.6 green:0.4 blue:0.2 alpha:1.0];
}

- (id)initWithCGColor:(CGColorRef)CGColor
{
    if (self = [super init]) {
        CGColorRef convertedColorRef = NULL;
        
        if (CGColorGetPattern(CGColor) == NULL) {
#if !TARGET_OS_IPHONE
            convertedColorRef = PMCSCGColorCreateConvertedToSRGB(CGColor);
            
            if (convertedColorRef == nil) {
                NSLog(@"Expected non-nil color ref");
            }
#else
            
            CGColorSpaceModel incomingSpaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(CGColor));
            if (incomingSpaceModel == kCGColorSpaceModelMonochrome) {
                if (CGColorGetNumberOfComponents(CGColor) == 2) {
                    const CGFloat* monochrome = CGColorGetComponents(CGColor);
                    CGFloat color = monochrome[0];
                    CGFloat alpha = monochrome[1];
                    convertedColorRef = PMCSCGColorCreateDeviceRGB(color, color, color, alpha);
                }
                else {
                    NSLog(@"Unexpected number of components for monochrome!");
                }
            }
            else if (incomingSpaceModel == kCGColorSpaceModelCMYK) {
                if (CGColorGetNumberOfComponents(CGColor) == 4) {
                    const CGFloat* cmykComponents = CGColorGetComponents(CGColor);
                    CGFloat cyan = cmykComponents[0];
                    CGFloat magenta = cmykComponents[1];
                    CGFloat yellow = cmykComponents[2];
                    CGFloat black = cmykComponents[3];
                    CGFloat red = 0;
                    CGFloat green = 0;
                    CGFloat blue = 0;
                    PMCSCMYKToRGB(cyan, magenta, yellow, black, &red, &green, &blue);
                    convertedColorRef = PMCSCGColorCreateDeviceRGB(red, green, blue, 1.0);
                }
                else {
                    NSLog(@"Unexpected number of components for CMYK!");
                }
            }
            else {
                if (incomingSpaceModel != kCGColorSpaceModelRGB) {
                    NSLog(@"Unexpected color space model for color %@", CGColor);
                }
            }
#endif
        }
        _backingCGColor = convertedColorRef ? convertedColorRef : CGColorCreateCopy(CGColor);
    }
    
    return self;
}

- (id)initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    CGColorSpaceRef rgbSpace;
#if !TARGET_OS_IPHONE
    rgbSpace = PMCSSRGBColorSpace();
#else
    rgbSpace = CGColorSpaceCreateDeviceRGB();
#endif
    CGFloat rgbComponents[4];
    rgbComponents[0] = red;
    rgbComponents[1] = green;
    rgbComponents[2] = blue;
    rgbComponents[3] = alpha;
    
    CGColorRef cgColor = CGColorCreate(rgbSpace, rgbComponents);
    self = [self initWithCGColor:cgColor];
    CGColorRelease(cgColor);
#if TARGET_OS_IPHONE
    CGColorSpaceRelease(rgbSpace);
#endif
    
    return self;
}

- (id)initWithWhite:(CGFloat)white alpha:(CGFloat)alpha
{
    CGColorSpaceRef rgbSpace = CGColorSpaceCreateDeviceGray();
    CGFloat rgbComponents[2];
    rgbComponents[0] = white;
    rgbComponents[1] = alpha;
    
    CGColorRef cgColor = CGColorCreate(rgbSpace, rgbComponents);
    self = [self initWithCGColor:cgColor];
    CGColorRelease(cgColor);
    CGColorSpaceRelease(rgbSpace);
    
    return self;
}

- (id)initWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha
{
    CGColorRef cgColor = PMCSCreateCGColorFromHSB(hue, saturation, brightness, alpha);
    self = [self initWithCGColor:cgColor];
    CGColorRelease(cgColor);
    
    return self;
}

#if TARGET_OS_IPHONE
- (id)initWithUIColor:(UIColor *)uiColor
{
    CGColorRef cgColor = [uiColor CGColor];
    self = [self initWithCGColor:cgColor];
    
    return self;
}
#elif TARGET_OS_MAC
- (id)initWithNSColor:(NSColor *)nsColor
{
    CGColorRef cgColor = [nsColor CGColor];
    self = [self initWithCGColor:cgColor];
    
    return self;
}
#endif

-(id)copyWithZone:(NSZone*)zone
{
    return [[AAPLPMCSColor allocWithZone:zone] initWithCGColor:_backingCGColor];
}

#if TARGET_OS_IPHONE
- (UIColor *)uiColor
{
    return [UIColor colorWithCGColor:self.CGColor];
}
#elif TARGET_OS_MAC
- (NSColor *)nsColor
{
    return [NSColor colorWithCGColor:self.CGColor];
}
#endif

- (void) setFill
{
#if TARGET_OS_IPHONE
    [[self uiColor] setFill];
#elif TARGET_OS_MAC
    [[self nsColor] setFill];
#endif
}

#pragma mark - Utility

CGColorRef PMCSCreateCGColorFromHSB(CGFloat hue, CGFloat saturation, CGFloat brightness, CGFloat alpha)
{
    return PMCSCCreateCGColorFromHSBInColorSpace(hue, saturation, brightness, alpha, NULL);
}

CGColorRef PMCSCGColorCreateDeviceRGB(CGFloat r, CGFloat g, CGFloat b, CGFloat a)
{
    CGFloat components[4] = { r, g, b, a };
    return CGColorCreate(PMCSDeviceRGBColorSpace(), components);
}

CGColorRef PMCSCCreateCGColorFromHSBInColorSpace(CGFloat hue, CGFloat saturation, CGFloat brightness, CGFloat alpha, CGColorSpaceolor* color = [[UIColor alloc] initWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
    cgcolor = [color CGColor];
    CGColorRetain(cgcolor);
#else
    CGFloat components[4];
    components[3] = alpha;
    
    PMCSCHSBToRGB(hue, saturation, brightness, &components[0], &components[1], &components[2]);
    
    CGColorSpaceRef colorSpace = targetColorSpace ? : PMCSDeviceRGBColorSpace();
    
    cgcolor = CGColorCreate(colorSpace, components);
    
#endif
    return cgcolor;
}

/* Convert HSB to RGB. Come in with hue, saturation, and brightness all in the range 0..1.
 */
void PMCSCHSBToRGB (CGFloat hue, CGFloat saturation, CGFloat brightness, CGFloat *red, CGFloat *green, CGFloat *blue) {
    CGFloat hueTimesSix, frac, p1, p2, p3;
    if (hue == 1.0) {
        hue = 0.0;
    }
    hueTimesSix = hue * 6.0;
    frac = hueTimesSix - (NSInteger)hueTimesSix;
    p1 = brightness * (1.0 - saturation);
    p2 = brightness * (1.0 - (saturation * frac));
    p3 = brightness * (1.0 - (saturation * (1.0 - frac)));
    switch ((NSInteger)hueTimesSix) {
        case 0:
            *red = brightness;
            *green = p3;
            *blue = p1;
            break;
        case 1:
            *red = p2;
            *green = brightness;
            *blue = p1;
            break;
        case 2:
            *red = p1;
            *green = brightness;
            *blue = p3;
            break;
        case 3:
            *red = p1;
            *green = p2;
            *blue = brightness;
            break;
        case 4:
            *red = p3;
            *green = p1;
            *blue = brightness;
            break;
        case 5:
            *red = brightness;
            *green = p1;
            *blue = p2;
            break;
    }
}

/* Convert CMYK to RGB. Come in with cyan, magenta, yellow, and black all in the range 0..1.
 Quick and dirty CMYK -> RGB conversion.
 */
void PMCSCMYKToRGB (CGFloat cyan, CGFloat magenta, CGFloat yellow, CGFloat black, CGFloat *red, CGFloat *green, CGFloat *blue) {
    *red   = 1.0 - fmin(1.0, cyan    * (1.0 - black) + black);
    *green = 1.0 - fmin(1.0, magenta * (1.0 - black) + black);
    *blue  = 1.0 - fmin(1.0, yellow  * (1.0 - black) + black);
}


CGColorSpaceRef PMCSDeviceRGBColorSpace()
{
    static CGColorSpaceRef sDeviceRGBColorSpace = NULL;
    static dispatch_once_t sDeviceRGBDispatchOnce;
    
    dispatch_once(&sDeviceRGBDispatchOnce, ^{
        sDeviceRGBColorSpace = CGColorSpaceCreateDeviceRGB();
    });
    
    return sDeviceRGBColorSpace;
}

#if !TARGET_OS_IPHONE

CGColorSpaceRef PMCSSRGBColorSpace()
{
    static CGColorSpaceRef sSRGBColorSpace = NULL;
    static dispatch_once_t sSRGBDispatchOnce;
    
    dispatch_once(&sSRGBDispatchOnce, ^{
        sSRGBColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
    });
    
    return sSRGBColorSpace;
}

CGColorRef PMCSCGColorCreateConvertedToSRGB(CGColorRef colorToConvert)
{
    CGColorRef colorToReturn = colorToConvert;
    CGColorSpaceRef srgb = PMCSSRGBColorSpace();
    CGColorSpaceRef inColorSpace = CGColorGetColorSpace(colorToReturn);
    if (!CFEqual(srgb, inColorSpace))
    {
        NSColor* nsColor = [NSColor colorWithCGColor:colorToConvert];
        NSColorSpace* targetNSColorSpace = [[NSColorSpace alloc] initWithCGColorSpace: srgb];
        NSColor* convertedNSColor = [nsColor colorUsingColorSpace:targetNSColorSpace];
        colorToReturn = [convertedNSColor CGColor];
    }
    CGColorRetain(colorToReturn);
    return colorToReturn;
}

#endif

@end
