//  AAPLPMCSImage.m
//  PhotoMemories
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "AAPLPMCSImage.h"

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
@implementation AAPLPMCSImage
{
    CGImageRef _CGImage;
    CGFloat _scale;
    AAPLPMCSImageOrientation _imageOrientation;
    
    id mCachedSystemImage;
    dispatch_once_t mCachedImageLock;
}

- (instancetype)initWithCGImage:(CGImageRef)ref NS_RETURNS_RETAINED
{
    return [[AAPLPMCSImage alloc] initWithCGImage:ref scale:0.0 orientation:AAPLPMCSImageOrientationUp];
}

- (instancetype)initWithCGImage:(CGImageRef)imageRef scale:(CGFloat)scale orientation:(AAPLPMCSImageOrientation)orientation
{
    if ((self = [super init])) {
        _CGImage = CGImageRetain(imageRef);
        _imageOrientation = orientation;
        _scale = scale;
        
        if (!_CGImage) {
            self = nil;
        }
    }
    
    return self;
}

- (instancetype) initWithData:(NSData *)data
{
#if TARGET_OS_IPHONE
    return [self initWithUIImage:[[UIImage alloc] initWithData:data]];
#else
    return [self initWithNSImage:[[NSImage alloc] initWithData:data]];
#endif
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    return [[[self class] alloc] initWithCGImage:_CGImage scale:_scale orientation:_imageOrientation];
}

- (CGImageRef)CGImage
{
    return _CGImage;
}

- (CGImageRef)CGImageForSize:(CGSize)size
{
    return _CGImage;
}

- (CGSize)size
{
    CGFloat scale = self.scale;
    CGSize contentSize = CGSizeMake(CGImageGetWidth(_CGImage), CGImageGetHeight(_CGImage));
    
    // Use fact that bit 1 is 0 for up/down and 1 for left/right based on our
    // enum to return swapped size
    return (_imageOrientation & 0x02) == 0 ? CGSizeMake(contentSize.width / scale, contentSize.height / scale) : CGSizeMake(contentSize.height / scale, contentSize.width / scale);
}

- (CGFloat)scale
{
    return _scale != 0.0f ? _scale : 1.0;
}

- (AAPLPMCSImageOrientation)imageOrientation
{
    return _imageOrientation;
}

#if TARGET_OS_IPHONE

- (id)initWithUIImage:(UIImage *)image
{
    CGImageRef cgImage = image.CGImage;
    CGFloat scale = image.scale;
    AAPLPMCSImageOrientation orientation = (AAPLPMCSImageOrientation)image.imageOrientation;
    
    
    return [self initWithCGImage:cgImage scale:scale orientation:orientation];
}

- (UIImage *) UIImage
{
    dispatch_once(&mCachedImageLock, ^{
        self->mCachedSystemImage = [[UIImage alloc] initWithCGImage:[self CGImage] scale:[self scale] orientation:[self imageOrientation]];
    });
    return mCachedSystemImage;
}

#endif

#if !TARGET_OS_IPHONE

- (id)initWithNSImage:(NSImage *)image
{
    CGImageRef cgImage = [image CGImageForProposedRect:NULL context:[NSGraphicsContext currentContext] hints:nil];
    CGFloat scale = 0.f;
    
    NSArray *reps = [image representations];
    
    if ([reps count] == 0) {
        NSLog(@"Need at least one representation before computing an image's scale");
    }
    
    CGFloat baseWidth = [image size].width;
    
    if (baseWidth != 0.0) {
        CGFloat maxWidth = baseWidth;
        
        for (NSImageRep *rep in reps) {
            CGFloat currWidth = [rep pixelsWide];
            if (currWidth > maxWidth) {
                maxWidth = currWidth;
            }
        }
        
        scale = maxWidth / baseWidth;
    }
    
    return [self initWithCGImage:cgImage scale:scale orientation:AAPLPMCSImageOrientationUp];
}

- (NSImage *) NSImage
{
    dispatch_once(&mCachedImageLock, ^{
        mCachedSystemImage = [[NSImage alloc] initWithCGImage:[self CGImage] size:[self size]];
    });
    return mCachedSystemImage;
}

#endif


@end
