/*
     File: Utils.h
 Abstract: This file contains some utilities such as titled box, loading DAE files, loading images etc...
  Version: 1.1
 
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
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#import <SceneKit/SceneKit.h>

typedef NS_ENUM(NSInteger, ASCLabelSize) {
    ASCLabelSizeSmall = 1,
    ASCLabelSizeNormal = 2,
    ASCLabelSizeLarge = 4
};

@interface SCNNode (ASCAdditions)

// Add the node named 'name' found in the DAE document located at 'path' as a child of the receiver
- (instancetype)asc_addChildNodeNamed:(NSString *)name fromSceneNamed:(NSString *)path withScale:(CGFloat)scale;

// Setup a 3D box with a title
+ (instancetype)asc_boxNodeWithTitle:(NSString *)title frame:(NSRect)frame color:(NSColor *)color cornerRadius:(CGFloat)cornerRadius centered:(BOOL)centered;

// Create a 3D plan with the specified image mapped on it
+ (instancetype)asc_planeNodeWithImage:(NSImage *)image size:(CGFloat)size isLit:(BOOL)isLit;
+ (instancetype)asc_planeNodeWithImageNamed:(NSString *)imageName size:(CGFloat)size isLit:(BOOL)isLit;

// Create a 3D text node
+ (instancetype)asc_labelNodeWithString:(NSString *)text size:(ASCLabelSize)size isLit:(BOOL)isLit;

// Create a 3D gauge
+ (instancetype)asc_gaugeNodeWithTitle:(NSString *)title progressNode:(SCNNode * __strong *)progressNode;

@end

@interface NSBezierPath (ASCAdditions)

// Create an arrow
+ (instancetype)asc_arrowBezierPathWithBaseSize:(NSSize)baseSize tipSize:(NSSize)tipSize hollow:(CGFloat)hollow twoSides:(BOOL)twoSides;

@end

@interface NSImage (ASCAdditions)

// Load an image that represents the application named
+ (instancetype)asc_imageForApplicationNamed:(NSString *)name;

// Create and return an image with the closest resolution to "size"
- (instancetype)asc_copyWithResolution:(CGFloat)size;

@end
