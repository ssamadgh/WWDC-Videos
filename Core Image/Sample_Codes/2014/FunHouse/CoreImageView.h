/*
     File: CoreImageView.h
 Abstract: n/a
  Version: 2.1
 
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

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "SampleCIView.h"

@class FunHouseWindowController;

// these are the possible item types that get moved
// within a mouseDown mouseDragged mouseUp loop
enum
    {
    pmNone = 0,
    pmPoint,            // moving a filter point (example: the inputCenter parameter to CIBumpDistortion)
    pmTopLeft,          // moving the top left point of a filter rectangle (example: the inputRectangle parameter to CICrop)
    pmBottomLeft,       // moving the bottom left point of a filter rectangle (example: the inputRectangle parameter to CICrop)
    pmTopRight,         // moving the top right point of a filter rectangle (example: the inputRectangle parameter to CICrop)
    pmBottomRight,      // moving the bottom right point of a filter rectangle (example: the inputRectangle parameter to CICrop)
    pmImageOffset,      // moving an image layer's offset
    pmTextOffset,       // moving a text layer's origin
    pmTransformOffset,  // moving the offset of a filter's affine transform parameter
    pmSpotLight,        // moving a CISpotLight position parameter
    pm3DPoint,          // moving the XY components of a filter 3D position parameter
    };

@interface CoreImageView : SampleCIView
{
    BOOL initialized;
    NSBundle *bundle;
    FunHouseWindowController *controller;
    // these fields are for mouse movement - they're set up in mouseDown, and used in mouseDragged and mouseUp
    NSInteger parmIndex;
    NSString *parmKey;
    NSInteger parmMode;
    NSString *savedActionName;
    BOOL movingNow;
    // this onee is used to indicate that the filter, image, and text layer origin handles are to be displayed
    BOOL displayingPoints;
    // the tracking rectangle is set up so mouseEntered and mouseExited events will be generated
    NSTrackingRectTag lastTrack;
    // view transform
    CGFloat viewTransformScale;
    CGFloat viewTransformOffsetX;
    CGFloat viewTransformOffsetY;
}

- (void)awakeFromNib;

- (void)setFunHouseWindowController:(FunHouseWindowController *)c;
- (CIContext *)context;

// view transform setters and getters
- (void)setViewTransformScale:(CGFloat)scale;
- (void)setViewTransformOffsetX:(CGFloat)x andY:(CGFloat)y;
- (BOOL)isScaled;

// setters for filter parameters (undo glue code)
- (void)setFilter:(CIFilter *)f value:(id)val forKey:(NSString *)key; // undoable operation
- (void)setDict:(NSMutableDictionary *)f value:(id)val forKey:(NSString *)key; // undoable operation
- (void)setActionNameForFilter:(CIFilter *)f key:(NSString *)key;
- (void)setActionNameForTextLayerKey:(NSString *)key;

@end
