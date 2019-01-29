/*
     File: FilterView.h
 Abstract: The filter view is really the box that contains all the UI widgets to edit a layer. Each of the widgets (slider with label and readout, color well with label, check box, image view with choose button, etc) gets encoded in its own parameter view.
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

#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>
#import "EffectStackController.h"

@class CoreImageView;

// type of widget last added
typedef enum
{
    ctNone = 0,
    ctSlider,
    ctColorWell,
    ctCheckBox,
    ctImageWell,
    ctTransform,
    ctVector,
    ctTextView,
    ctOffset,
} ControlType;

@interface FilterView : EffectStackBox
{
    NSInteger tag;                                // tag: it's the layer index!
    NSInteger controlLeftPosition;                // state used for packing widgets
    NSInteger controlTopPosition;                 // state used for packing widgets
    NSInteger colorWellOffset;                    // state used for packing widgets
    ControlType lastControlType;            // last control type added (for packing widgets properly)
    NSTextField *filterNameField;           // text field for showing filter name (image name, text)
    NSButton *plusbutton;                   // plus button: allows user to create a new layer after this one
    NSButton *minusbutton;                  // minus button: allows user to delete this layer
    NSButton *checkBox;                     // check box: for enabling/disabling the layer
}

// for computing size of box beforehand
- (void)tryFilterHeader:(CIFilter *)filter;
- (void)trySliderForFilter:(CIFilter *)f key:(NSString *)k displayView:(CoreImageView *)v;
- (void)tryCheckBoxForFilter:(CIFilter *)f key:(NSString *)k displayView:(CoreImageView *)v;
- (void)tryColorWellForFilter:(CIFilter *)f key:(NSString *)k displayView:(CoreImageView *)v;
- (void)tryImageWellForFilter:(CIFilter *)f key:(NSString *)k displayView:(CoreImageView *)v;
- (void)tryTransformForFilter:(CIFilter *)f key:(NSString *)k displayView:(CoreImageView *)v;
- (void)tryVectorForFilter:(CIFilter *)f key:(NSString *)k displayView:(CoreImageView *)v;
- (void)tryOffsetForFilter:(CIFilter *)f key:(NSString *)k displayView:(CoreImageView *)v;

// for populating the box with controls
- (void)addFilterHeader:(CIFilter *)filter tag:(NSInteger)index enabled:(BOOL)enabled;
- (void)addSliderForFilter:(CIFilter *)f key:(NSString *)k displayView:(CoreImageView *)v;
- (void)addCheckBoxForFilter:(CIFilter *)f key:(NSString *)k displayView:(CoreImageView *)v;
- (void)addColorWellForFilter:(CIFilter *)f key:(NSString *)k displayView:(CoreImageView *)v;
- (void)addImageWellForFilter:(CIFilter *)f key:(NSString *)k displayView:(CoreImageView *)v;
- (void)addTransformForFilter:(CIFilter *)f key:(NSString *)k displayView:(CoreImageView *)v;
- (void)addVectorForFilter:(CIFilter *)f key:(NSString *)k displayView:(CoreImageView *)v;
- (void)addOffsetForFilter:(CIFilter *)f key:(NSString *)k displayView:(CoreImageView *)v;

// image layers
- (void)tryImageHeader:(CIImage *)im;
- (void)addImageHeader:(CIImage *)im filename:(NSString *)filename tag:(NSInteger)index enabled:(BOOL)enabled;
- (void)tryImageWellForImage:(CIImage *)im tag:(NSInteger)tag displayView:(CoreImageView *)v;
- (void)addImageWellForImage:(CIImage *)im tag:(NSInteger)tag displayView:(CoreImageView *)v;

// text layers
- (void)tryTextHeader:(NSString *)string;
- (void)addTextHeader:(NSString *)string tag:(NSInteger)index enabled:(BOOL)enabled;
- (void)tryTextViewForString;
- (void)addTextViewForString:(NSMutableDictionary *)d key:(NSString *)key displayView:(CoreImageView *)v;
- (void)trySliderForText;
- (void)addSliderForText:(NSMutableDictionary *)d key:(NSString *)key lo:(CGFloat)lo hi:(CGFloat)hi displayView:(CoreImageView *)v;

// trim box after adding UI
- (void)trimBox;
- (void)setTag:(NSInteger)index;

@end


