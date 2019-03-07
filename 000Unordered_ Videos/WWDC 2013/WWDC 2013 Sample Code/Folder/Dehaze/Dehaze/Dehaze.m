/*
 
 File:  Dehaze.m
 
 Abstract: class which is used to run dehazing kernel
 
 Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by
 Apple Inc. ("Apple") in consideration of your agreement to the
 following terms, and your use, installation, modification or
 redistribution of this Apple software constitutes acceptance of these
 terms.  If you do not agree with these terms, please do not use,
 install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc.
 may be used to endorse or promote products derived from the Apple
 Software without specific prior written permission from Apple.  Except
 as expressly stated in this notice, no other rights or licenses, express
 or implied, are granted by Apple herein, including but not limited to
 any patent rights that may be infringed by your derivative works or by
 other works in which the Apple Software may be incorporated.
 
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
 
 */

#import <QuartzCore/QuartzCore.h>
#import "Dehaze.h"
#import "MorphologicalMinCL.h"

@implementation Dehaze

-(IOSurfaceRef)_newBGRASurfaceForWidth:(size_t)width height:(size_t)height
{
    // align nicely on a 16 byte boundary:
    size_t alignment = 16;
    size_t bytesPerRow = (((size_t)width * 4) + (alignment -1)) & ~(alignment-1);
    
    NSDictionary *surfaceDict = @{
                                  (NSString *)kIOSurfaceBytesPerRow:     [NSNumber numberWithInteger:bytesPerRow],
                                  (NSString *)kIOSurfaceWidth:           [NSNumber numberWithInteger:width],
                                  (NSString *)kIOSurfaceHeight:          [NSNumber numberWithInteger:height],
                                  (NSString *)kIOSurfacePixelFormat:     [NSNumber numberWithInteger:'BGRA'],
                                  (NSString *)kIOSurfaceBytesPerElement: [NSNumber numberWithInteger:4],
                                  };

    return IOSurfaceCreate((CFDictionaryRef)surfaceDict);
}

-(id)_initWithFilename:(const char *)filename maxSize:(size_t)maxSize context:(CIContext *)context
{
    self = [super init];
    
    if ( self ) {
        _context = context;
        [context retain];
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithUTF8String:filename]];
        
        CIImage *inputImage = [CIImage imageWithContentsOfURL:url];
        
        _colorSpace = [inputImage colorSpace];
        
        if ( _colorSpace )
            CFRetain (_colorSpace);
        
        if ( ! inputImage  ) {
            NSLog(@"Can't open input file for Dehazing: %s",filename);
            [self release];
            return nil;
        }
        
        CGRect extent = [inputImage extent];
        
        // scale image if necessary.
        //
        // ideally we'd also check the underlying OpenCL context size limits to perform this test
        //
        if ( extent.size.width > maxSize || extent.size.height > maxSize ) {
            float scale = extent.size.width > extent.size.height ? maxSize / extent.size.width : maxSize / extent.size.height;

            CGAffineTransform  t = CGAffineTransformMakeScale ( scale , scale );

            NSAffineTransform *nst = [NSAffineTransform transform];
            [nst scaleBy:scale];
            
            _scaledImage = [[CIFilter filterWithName:@"CIAffineClamp" keysAndValues: @"inputImage", inputImage, @"inputTransform", nst, nil] valueForKey:@"outputImage"];
            
            //
            // we don't want fractional pixels otherwise we will end up with some pixels on the border of the image which
            // will have alpha != 1.0 which is to say they won't be completely opaque. If that's the case then we would need
            // to add a unpremultiply() to our code for reading the pixel data in the OpenCL kernel otherwise those will
            // edge pixels will definitely end up being the darkest values and we will end up with incorrect values for the
            // in on the border of the image. Best just to crop out some fractional pixel and get an integral image instead.
            //
            CGRect cropRect = CGRectIntegral(CGRectApplyAffineTransform(extent, t));
            
            _scaledImage = [_scaledImage imageByCroppingToRect : cropRect];
        } else {
            _scaledImage = inputImage;
        }
        
        [_scaledImage retain];
    }
    
    return self;
}

-(id)initWithFilename:(const char *)filename maxSize:(size_t)maxSize context:(CIContext *)context deviceType:(cl_device_type)deviceType
{
    self = [self _initWithFilename:filename maxSize:maxSize context:context];
    if ( self ) {
        _useDeviceType = true;
        _deviceType = deviceType;
    }
    return self;
}

-(id)initWithFilename:(const char *)filename maxSize:(size_t)maxSize context:(CIContext *)context glContext:(CGLContextObj)glContext
{
    if ( ! glContext )
        return nil;
    
    self = [self _initWithFilename:filename maxSize:maxSize context:context];
    if ( self ) {
        _useDeviceType = false;
        _cglCtx = glContext;
        if ( _cglCtx )
            CGLRetainContext(_cglCtx);
    }
    return self;
}

- (CIImage *)runXSpanFraction:(float)xSpanFraction ySpanFraction:(float)ySpanFraction blurFraction:(float)blurFraction
{
    size_t width  = [_scaledImage extent].size.width;
    size_t height = [_scaledImage extent].size.height;
    
    IOSurfaceRef inputSurface = [self _newBGRASurfaceForWidth:width height:height];
    IOSurfaceRef outputSurface = [self _newBGRASurfaceForWidth:width height:height];
    
    if ( ! inputSurface || ! outputSurface )
        return nil;
    
    bool allocatedColorSpace = false;
    if ( ! _colorSpace ) {
        _colorSpace = CGColorSpaceCreateDeviceRGB();
        allocatedColorSpace = true;
    }
    
    // Ask Core Image to render the scaled image to an IOSurface.
    [_context render:_scaledImage toIOSurface:inputSurface bounds:[_scaledImage extent] colorSpace:_colorSpace];

    MorphologicalMinCL *morphMin = nil;
    
    if ( _useDeviceType )
        morphMin = [[MorphologicalMinCL alloc] initUsingDeviceType:_deviceType index:0];
    else
        morphMin = [[MorphologicalMinCL alloc] initUsingCGLContext:_cglCtx];

    // These factors control how far the effect is spread in the x and y directions based on fractions of the input image (scaled)
    // size.
    const float spanX = width / xSpanFraction;
    const float spanY = height / ySpanFraction;
    NSNumber *blurRadius = [NSNumber numberWithFloat:width / blurFraction];
    
    CIImage *outputImage = nil;
    
    bool success = morphMin ? [morphMin removeHazeFromImage:inputSurface outputSurface:outputSurface spanX:spanX spanY:spanY] : false;
    if ( success ) {
        CIImage *newImage = [CIImage imageWithIOSurface:outputSurface options:@{kCIImageColorSpace : (id)_colorSpace}];
        
        // clamp image so that we get appropriate edge behavior (clamp to edge) when performing blur:
        CIImage *clampedImage = [[CIFilter filterWithName:@"CIAffineClamp" keysAndValues:@"inputImage", newImage, @"inputTransform", [NSAffineTransform transform], nil] valueForKey:kCIOutputImageKey];
        CIImage *blurredImage = [[[CIFilter filterWithName:@"CIGaussianBlur" keysAndValues:@"inputRadius", blurRadius, @"inputImage", clampedImage, nil] valueForKey:kCIOutputImageKey] imageByCroppingToRect:[newImage extent]];
        
        outputImage = [[CIFilter filterWithName:@"CIDifferenceBlendMode" keysAndValues:@"inputImage", _scaledImage, @"inputBackgroundImage", blurredImage, nil] valueForKey:@"outputImage"];
    }
    [morphMin release];

    CFRelease(inputSurface);
    CFRelease(outputSurface);
    
    if ( allocatedColorSpace )
        CGColorSpaceRelease (_colorSpace);
    
    return outputImage;
}

-(void)dealloc
{
    if ( _cglCtx )
        CGLReleaseContext(_cglCtx), _cglCtx = nil;
    
    if ( _colorSpace )
        CGColorSpaceRelease(_colorSpace);
    
    [_scaledImage release];
    [_context release];
    [super dealloc];
}

@end
