/*
     File: ParameterView.h
 Abstract: This class contains the low-level automatic generation for effect stack UI from CoreImage filters and keys.
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

// various types of data represented in a slider
typedef enum
{
    stScalar = 0,
    stAngle,
    stTime,
    stDistance,
} SliderType;

@class CoreImageView;
@class EffectStackController;
@class FunHouseImageView;

#if MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_5
@interface ParameterView : NSView
#else
@interface ParameterView : NSView <NSTextViewDelegate>
#endif
{
    CIFilter *filter;                   // filter this UI element belongs to
    NSMutableDictionary *dict;          // dictionary for text layer this slider/text view belongs to
    NSString *key;                      // key this UI element sets in filter
    CoreImageView *displayView;         // view that owns this filter and can call to update display
    EffectStackController *master;      // pointer back to the effect stack controller
    NSSlider *slider;                   // slider pointer, if we are a slider
    SliderType dataType;                // basic data type represented by the slider
    NSButton *checkBox;                 // check box pointer, if we are a check box
    NSColorWell *colorWell;             // color well pointer, if we are a color well
    FunHouseImageView *imageView;       // image view pointer, if we are an image view
    NSButton *pushButton;               // push button pointer (used in image layer widgets)
    NSTextField *labelTextField;        // label text field (for slider, color well, some image views)
    NSTextField *readoutTextField;      // readout text field (for sliders)
    NSTextView *textView;               // text view pointer (for text layer widgets)
    NSInteger beforeDecimal;                  // format info for slider readouts
    NSInteger afterDecimal;                   // format info for slider readouts
    CGFloat lastFloatValue;               // for slider: last floating point value shown
    // for transform
    NSSlider *scaleSlider;
    NSSlider *angleSlider;
    NSSlider *stretchSlider;
    NSSlider *skewSlider;
    NSTextField *scaleLabelTextField;
    NSTextField *angleLabelTextField;
    NSTextField *stretchLabelTextField;
    NSTextField *skewLabelTextField;
    NSTextField *scaleReadoutTextField;
    NSTextField *angleReadoutTextField;
    NSTextField *stretchReadoutTextField;
    NSTextField *skewReadoutTextField;
    SliderType scaleDataType;
    SliderType angleDataType;
    SliderType stretchDataType;
    SliderType skewDataType;
    CGFloat lastScaleFloatValue;
    CGFloat lastAngleFloatValue;
    CGFloat lastStretchFloatValue;
    CGFloat lastSkewFloatValue;
    BOOL usingNSAffineTransform;
    // for naked CIVector widgets
    NSTextField *readout1TextField;
    NSTextField *readout2TextField;
    NSTextField *readout3TextField;
    NSTextField *readout4TextField;
}

// convenience methods we export
+ (CIImage *)CIImageWithNSImage:(NSImage *)image;
+ (NSString *)ellipsizeField:(CGFloat)width font:(NSFont *)font string:(NSString *)label;

- (IBAction)sliderChanged:(id)sender;
- (IBAction)readoutTextFieldChanged:(id)sender;
- (IBAction)colorWellChanged:(id)sender;

// for filter inspection
- (void)addSliderForFilter:(CIFilter *)f key:(NSString *)k displayView:(CoreImageView *)v master:(EffectStackController *)m;
- (void)addCheckBoxForFilter:(CIFilter *)f key:(NSString *)k displayView:(CoreImageView *)v master:(EffectStackController *)m;
- (void)addColorWellForFilter:(CIFilter *)f key:(NSString *)k displayView:(CoreImageView *)v master:(EffectStackController *)m;
- (void)addImageWellForFilter:(CIFilter *)f key:(NSString *)k displayView:(CoreImageView *)v master:(EffectStackController *)m;
- (void)addTransformForFilter:(CIFilter *)f key:(NSString *)k displayView:(CoreImageView *)v master:(EffectStackController *)m;
- (void)addVectorForFilter:(CIFilter *)f key:(NSString *)k displayView:(CoreImageView *)v master:(EffectStackController *)m;
- (void)addOffsetForFilter:(CIFilter *)f key:(NSString *)k displayView:(CoreImageView *)v master:(EffectStackController *)m;

// for image inspection
- (void)addImageWellForImage:(CIImage *)im tag:(NSInteger)tag displayView:(CoreImageView *)v master:(EffectStackController *)m;

// for text inspection 
- (void)addTextViewForString:(NSMutableDictionary *)d key:(NSString *)k displayView:(CoreImageView *)v master:(EffectStackController *)m;
- (void)addSliderForText:(NSMutableDictionary *)d key:(NSString *)k lo:(CGFloat)lo hi:(CGFloat)hi displayView:(CoreImageView *)v master:(EffectStackController *)m;

@end

@interface FunHouseImageView : NSImageView
    {
    NSString *_filePath;
    }

- (void)setFilePath:(NSString *)path;
- (NSString *)filePath;
@end

NSString *unInterCap(NSString *s);
