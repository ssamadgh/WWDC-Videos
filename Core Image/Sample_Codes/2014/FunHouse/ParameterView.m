/*
     File: ParameterView.m
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

#import <QuartzCore/QuartzCore.h>
#import "ParameterView.h"
#import "CoreImageView.h"
#import "FilterView.h"
#import "EffectStackController.h"


@implementation ParameterView

- (id)initWithFrame:(NSRect)frame 
{
    self = [super initWithFrame:frame];
    return self;
}

- (void)dealloc
{
    // free objects that we don't own but still have to retain
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    if (filter != nil)
        [filter release];
    if (dict != nil)
        [dict release];
    if (key != nil)
        [key release];
    [displayView release];
    [master release];
    [super dealloc];
}

// convert slider value to readout value
static CGFloat slider_to_readout_value(CGFloat v, SliderType t)
{
    CGFloat v2;
    
    switch (t)
    {
    case stScalar: // readout without units
    case stDistance: // readout in pixels
        v2 = v;
        break;
    case stAngle:
        v2 = v * 180.0 / M_PI; // readout in degrees
        break;
    case stTime:
        v2 = v * 100.0; // readout in percent
        break;
    }
    return v2;
}

// convert readout value to slider value
static CGFloat readout_to_slider_value(CGFloat v, SliderType t)
{
    CGFloat v2;
    
    switch (t)
    {
    case stScalar: // readout without units
    case stDistance: // readout in pixels
        v2 = v;
        break;
    case stAngle:
        v2 = v * M_PI / 180.0; // readout in degrees
        break;
    case stTime:
        v2 = v * 0.01; // readout in percent
        break;
    }
    return v2;
}

// format a floating point number to spec
static void format_floating_point_number(CGFloat v, NSInteger before, NSInteger after, char *str)
{
    char format[16];
    char floatstr[32];
    
    snprintf(format, 16, "%%%d.%df", (int)before, (int)after);
    snprintf(floatstr, 32, format, v);
    // printf("%s for %f\n", floatstr, v);
    strncpy(str, floatstr, MIN(strlen(floatstr) + 1, 32));
}

// this gets called when the filter's slider thumb gets moved
- (IBAction)sliderChanged:(id)sender
{
    CGFloat f;
    char str[32];
    
    // make sure we're connected right
    if (labelTextField == nil)
        return;
    if (readoutTextField != nil && slider != nil)
    {
        // get the value of the slider
        f = [slider doubleValue];
        // make sure we don't do this any more than we have to
        if (f == lastFloatValue)
            return;
        lastFloatValue = f;
        // update the parallel readout field
        format_floating_point_number(slider_to_readout_value(f, dataType), beforeDecimal, afterDecimal, str);
        [readoutTextField setStringValue:[NSString stringWithUTF8String:str]];
        // update the filter (using undo-compatible glue code)
        [displayView setFilter:filter value:[slider objectValue] forKey:key];
        // and set up the undo string based on the filter and key names
        [displayView setActionNameForFilter:filter key:key];
    }
    // let core image recompute the display
    if (displayView != nil)
        [displayView setNeedsDisplay:YES];
}

// this gets called when the filter's slider readout text field gets edited
- (IBAction)readoutTextFieldChanged:(id)sender
{
    CGFloat f;
    
    // make sure we're connected right
    if (labelTextField == nil)
        return;
    if (readoutTextField != nil && slider != nil)
    {
        // get the readout value
        f = readout_to_slider_value([readoutTextField doubleValue], dataType);
        // make sure we don't do this any more than we have to
        if (f == lastFloatValue)
            return;
        lastFloatValue = f;
        // update the parallel slider
        [slider setDoubleValue:f];
        // update the filter (using undo-compatible glue code)
        [displayView setFilter:filter value:[NSNumber numberWithDouble:f] forKey:key];
        // and set up the undo string based on the filter and key names
        [displayView setActionNameForFilter:filter key:key];
    }
    // let core image recompute the display
    if (displayView != nil)
        [displayView setNeedsDisplay:YES];
}

// this gets called when a filter's check box changes
- (IBAction)checkBoxChanged:(id)sender
{
    NSCellStateValue state;
    BOOL b;
    
    // make sure we're connected right
    if (checkBox != nil)
    {
        // get the check box boolean value
        state = [checkBox state];
        b = (state == NSOnState) ? YES : NO;
        // update the filter (using undo-compatible glue code)
        [displayView setFilter:filter value:[NSNumber numberWithBool:b] forKey:key];
        // and set up the undo string based on the filter and key names
        [displayView setActionNameForFilter:filter key:key];
    }
    // let core image recompute the display
    if (displayView != nil)
        [displayView setNeedsDisplay:YES];
}

// this gets called when a vector's x editable text field changes
- (IBAction)readout1TextFieldChanged:(id)sender
{
    CGFloat f;
    CIVector *vec, *vec2;
    
    // make sure we're connected right
    if (labelTextField == nil)
        return;
    if (readout1TextField != nil)
    {
        // get the readout's value
        f = readout_to_slider_value([readout1TextField doubleValue], dataType);
        // store the changed value back into the vector in place
        vec = [filter valueForKey:key];
        vec2 = [CIVector vectorWithX:f Y:[vec Y] Z:[vec Z] W:[vec W]];
        // update the filter (using undo-compatible glue code)
        [displayView setFilter:filter value:vec2 forKey:key];
        // and set up the undo string based on the filter and key names
        [displayView setActionNameForFilter:filter key:key];
    }
    // let core image recompute the display
    if (displayView != nil)
         [displayView setNeedsDisplay:YES];
}

// this gets called when a vector's x editable text field changes
- (void)readout1DidChange:(NSNotification *)notification
{
    CGFloat f;
    CIVector *vec, *vec2;
    
    // make sure we're connected right
    if (labelTextField == nil)
        return;
    if (readout1TextField != nil)
    {
        // get the readout's value
        f = readout_to_slider_value([readout1TextField doubleValue], dataType);
        // store the changed value back into the vector in place
        vec = [filter valueForKey:key];
        vec2 = [CIVector vectorWithX:f Y:[vec Y] Z:[vec Z] W:[vec W]];
        // update the filter (using undo-compatible glue code)
        [displayView setFilter:filter value:vec2 forKey:key];
        // and set up the undo string based on the filter and key names
        [displayView setActionNameForFilter:filter key:key];
    }
    // let core image recompute the display
    if (displayView != nil)
         [displayView setNeedsDisplay:YES];
}

// this gets called when a vector's y editable text field changes
- (IBAction)readout2TextFieldChanged:(id)sender
{
    CGFloat f;
    CIVector *vec, *vec2;
    
    // make sure we're connected right
    if (labelTextField == nil)
        return;
    if (readout2TextField != nil)
    {
        // get the readout's value
        f = readout_to_slider_value([readout2TextField doubleValue], dataType);
        // store the changed value back into the vector in place
        vec = [filter valueForKey:key];
        vec2 = [CIVector vectorWithX:[vec X] Y:f Z:[vec Z] W:[vec W]];
        // update the filter (using undo-compatible glue code)
        [displayView setFilter:filter value:vec2 forKey:key];
        // and set up the undo string based on the filter and key names
        [displayView setActionNameForFilter:filter key:key];
    }
    // let core image recompute the display
    if (displayView != nil)
         [displayView setNeedsDisplay:YES];
}

// this gets called when a vector's y editable text field changes
- (void)readout2DidChange:(NSNotification *)notification
{
    CGFloat f;
    CIVector *vec, *vec2;
    
    // make sure we're connected right
    if (labelTextField == nil)
        return;
    if (readout2TextField != nil)
    {
        // get the readout's value
        f = readout_to_slider_value([readout2TextField doubleValue], dataType);
        // store the changed value back into the vector in place
        vec = [filter valueForKey:key];
        vec2 = [CIVector vectorWithX:[vec X] Y:f Z:[vec Z] W:[vec W]];
        // update the filter (using undo-compatible glue code)
        [displayView setFilter:filter value:vec2 forKey:key];
        // and set up the undo string based on the filter and key names
        [displayView setActionNameForFilter:filter key:key];
    }
    // let core image recompute the display
    if (displayView != nil)
         [displayView setNeedsDisplay:YES];
}

// this gets called when a vector's z editable text field changes
- (IBAction)readout3TextFieldChanged:(id)sender
{
    CGFloat f;
    CIVector *vec, *vec2;
    
    // make sure we're connected right
    if (labelTextField == nil)
        return;
    if (readout3TextField != nil)
    {
        // get the readout's value
        f = readout_to_slider_value([readout3TextField doubleValue], dataType);
        // store the changed value back into the vector in place
        vec = [filter valueForKey:key];
        vec2 = [CIVector vectorWithX:[vec X] Y:[vec Y] Z:f W:[vec W]];
        // update the filter (using undo-compatible glue code)
        [displayView setFilter:filter value:vec2 forKey:key];
        // and set up the undo string based on the filter and key names
        [displayView setActionNameForFilter:filter key:key];
    }
    // let core image recompute the display
    if (displayView != nil)
         [displayView setNeedsDisplay:YES];
}

// this gets called when a vector's z editable text field changes
- (void)readout3DidChange:(NSNotification *)notification
{
    CGFloat f;
    CIVector *vec, *vec2;
    
    // make sure we're connected right
    if (labelTextField == nil)
        return;
    if (readout3TextField != nil)
    {
        // get the readout's value
        f = readout_to_slider_value([readout3TextField doubleValue], dataType);
        // store the changed value back into the vector in place
        vec = [filter valueForKey:key];
        vec2 = [CIVector vectorWithX:[vec X] Y:[vec Y] Z:f W:[vec W]];
        // update the filter (using undo-compatible glue code)
        [displayView setFilter:filter value:vec2 forKey:key];
        // and set up the undo string based on the filter and key names
        [displayView setActionNameForFilter:filter key:key];
    }
    // let core image recompute the display
    if (displayView != nil)
         [displayView setNeedsDisplay:YES];
}

// this gets called when a vector's w editable text field changes
- (IBAction)readout4TextFieldChanged:(id)sender
{
    CGFloat f;
    CIVector *vec, *vec2;
    
    // make sure we're connected right
    if (labelTextField == nil)
        return;
    if (readout4TextField != nil)
    {
        // get the readout's value
        f = readout_to_slider_value([readout4TextField doubleValue], dataType);
        // store the changed value back into the vector in place
        vec = [filter valueForKey:key];
        vec2 = [CIVector vectorWithX:[vec X] Y:[vec Y] Z:[vec Z] W:f];
        // update the filter (using undo-compatible glue code)
        [displayView setFilter:filter value:vec2 forKey:key];
        // and set up the undo string based on the filter and key names
        [displayView setActionNameForFilter:filter key:key];
    }
    // let core image recompute the display
    if (displayView != nil)
         [displayView setNeedsDisplay:YES];
}

// this gets called when a vector's w editable text field changes
- (void)readout4DidChange:(NSNotification *)notification
{
    CGFloat f;
    CIVector *vec, *vec2;
    
    // make sure we're connected right
    if (labelTextField == nil)
        return;
    if (readout4TextField != nil)
    {
        // get the readout's value
        f = readout_to_slider_value([readout4TextField doubleValue], dataType);
        // store the changed value back into the vector in place
        vec = [filter valueForKey:key];
        vec2 = [CIVector vectorWithX:[vec X] Y:[vec Y] Z:[vec Z] W:f];
        // update the filter (using undo-compatible glue code)
        [displayView setFilter:filter value:vec2 forKey:key];
        // and set up the undo string based on the filter and key names
        [displayView setActionNameForFilter:filter key:key];
    }
    // let core image recompute the display
    if (displayView != nil)
         [displayView setNeedsDisplay:YES];
}

// this gets called when a filter's color well changes
- (IBAction)colorWellChanged:(id)sender
{
    CIColor *color;

    // make sure we're connected right
    if (labelTextField == nil)
        return;
    if (colorWell != nil)
    {
        // get the color well's color
        color = [[CIColor alloc] initWithColor: [colorWell color]];
        // update the filter (using undo-compatible glue code)
        [displayView setFilter:filter value: color forKey:key];
        // and set up the undo string based on the filter and key names
        [displayView setActionNameForFilter:filter key:key];
        [color release];
    }
    // let core image recompute the display
    if (displayView != nil)
         [displayView setNeedsDisplay:YES];
}

// convert an NSImage to a CIImage - this is useful when the user has dragged some image into an image view and
// we need it in CIImage form (to talk with Core Image)
+ (CIImage *)CIImageWithNSImage:(NSImage *)image
{
    NSInteger size, sourceTextureBytesPerRow, width, height;
    NSBitmapImageRep *bitmapimagerep;
    uint32_t row, col, bpr;
    unsigned char *sr, *dr, *s, *d, *sourceTextureAddr;
    NSSize sz;
    NSData *data;
    CIImage *im;

    sz = [image size];
    width = sz.width;
    height = sz.height;
    // Get a bitmap image representation of the image
    [image lockFocus];
    bitmapimagerep = [[NSBitmapImageRep alloc]
      initWithFocusedViewRect:NSMakeRect(0.0, 0.0, (CGFloat)width, (CGFloat)height)];
    [image unlockFocus];
    // get it into the right format
    if ([bitmapimagerep bitsPerPixel] == 24)
    {
        // retain the data for personal use
        sourceTextureBytesPerRow = width*4;
        size = sourceTextureBytesPerRow * height;
        sourceTextureAddr = malloc(size);
        bpr = [bitmapimagerep bytesPerRow];
        for (row = 0, sr = [bitmapimagerep bitmapData], dr = sourceTextureAddr; row < height; row++, sr += bpr, dr += sourceTextureBytesPerRow)
        {
            for (col = 0, s = sr, d = dr; col < width; col++, s += 3, d += 4)
            {
                d[0] = 255;
                d[1] = s[0];
                d[2] = s[1];
                d[3] = s[2];
            }
        }
    }
    else
    {
        // retain the data for personal use
        sourceTextureBytesPerRow = width*4;
        size = sourceTextureBytesPerRow * height;
        sourceTextureAddr = malloc(size);
        bpr = [bitmapimagerep bytesPerRow];
        for (row = 0, sr = [bitmapimagerep bitmapData], dr = sourceTextureAddr; row < height; row++, sr += bpr, dr += sourceTextureBytesPerRow)
        {
            for (col = 0, s = sr, d = dr; col < width; col++, s += 4, d += 4)
            {
                d[0] = s[3];
                d[1] = s[0];
                d[2] = s[1];
                d[3] = s[2];
            }
        }
    }
    // and release the data structures created herein
    [bitmapimagerep release];
    data = [NSData dataWithBytes:sourceTextureAddr length:size];
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    // create the CIImage from the bitmap data
    im = [CIImage imageWithBitmapData:data bytesPerRow:sourceTextureBytesPerRow size:CGSizeMake(width, height) format:kCIFormatARGB8 colorSpace:cs];
    CGColorSpaceRelease(cs);
    free(sourceTextureAddr);
    return im;
}

// this gets called when the user drags an image into a filter's image view
- (IBAction)imageWellChanged:(id)sender
{
    CIImage *im;
    NSString *path;
    
    // make sure we're connected right
    if (labelTextField == nil)
        return;
    if (imageView != nil)
    {
        // get the filename of the dragged image (if there is one)
        path = [sender filePath];
        // since we are assuming file path exists for image well images, we read them directly
        im = [[[CIImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]] autorelease];
        // update the filter (using undo-compatible glue code)
        [displayView setFilter:filter value:im forKey:key];
        // and set up the undo string based on the filter and key names
        [displayView setActionNameForFilter:filter key:key];
        [master registerFilterLayer:filter key:key imageFilePath:path];
    }
    // let core image recompute the display
    if (displayView != nil)
        [displayView setNeedsDisplay:YES];
    // we must re-layout the effect stack inspector now!
    if (master != nil)
    {
        [master setChanges];
        [master updateLayout];
    }
}

// this gets called when the user punches the "choose" button in a filter to select a new image
- (IBAction)pushButtonChanged:(id)sender
{
    CIImage *im;
    NSOpenPanel *opanel;
    NSURL *url;
    
    // make sure we're connected right
    if (labelTextField == nil)
        return;
    if (imageView != nil)
    {
        // get image using open
        opanel = [NSOpenPanel openPanel];
        [opanel setAllowsMultipleSelection:NO];
        if (![opanel runModal])
            return;
        url = [[opanel URLs] objectAtIndex:0];
        // read in the image file
        im = [CIImage imageWithContentsOfURL:url];
        // update the filter (using undo-compatible glue code)
        [displayView setFilter:filter value:im forKey:key];
        // and set up the undo string based on the filter and key names
        [displayView setActionNameForFilter:filter key:key];
        [master registerFilterLayer:filter key:key imageFilePath:[url path]];
    }
    // let core image recompute the display
    if (displayView != nil)
        [displayView setNeedsDisplay:YES];
    // we must re-layout the effect stack inspector now!
    if (master != nil)
    {
        [master setChanges];
        [master updateLayout];
    }
}

// this gets called when the user drags an image into an image layer's image well
- (IBAction)imageLayerImageWellChanged:(id)sender
{
    CIImage *im;
    NSString *path;
    
    // make sure we're connected right
    if (imageView != nil)
    {
        // get the filename of the dragged image (if there is one)
        path = [sender filePath];
        // since we are assuming file path exists for image well images, we read them directly
        im = [[[CIImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]] autorelease];
        // and store the image into the image layer
        [master setLayer:[sender tag] image:im andFilename:[path lastPathComponent]];
        [master registerImageLayer:[sender tag] imageFilePath:path];
        if ([sender tag] == 0)
            [master reconfigureWindow];
    }
    // let core image recompute the display
    if (displayView != nil)
        [displayView setNeedsDisplay:YES];
    // we must re-layout the effect stack inspector now!
    if (master != nil)
    {
        [master setChanges];
        [master updateLayout];
    }
}

// this gets called when the user punches the "choose" button in an image layer - to select a new image
- (IBAction)imageLayerPushButtonChanged:(id)sender
{
    CIImage *im;
    NSOpenPanel *opanel;
    NSURL *url;
    
    // make sure we're connected right
    if (imageView != nil)
    {
        // get image using open
        opanel = [NSOpenPanel openPanel];
        [opanel setAllowsMultipleSelection:NO];
        if (![opanel runModal])
            return;
        url = [[opanel URLs] objectAtIndex:0];
        // read it in
        im = [CIImage imageWithContentsOfURL:url];
        // set the image layer's image from this
        [master setLayer:[sender tag] image:im andFilename:[[url path] lastPathComponent]];
        [master registerImageLayer:[sender tag] imageFilePath:[url path]];
        if ([sender tag] == 0)
            [master reconfigureWindow];
    }
    // let core image recompute the display
    if (displayView != nil)
        [displayView setNeedsDisplay:YES];
    // we must re-layout the effect stack inspector now!
    if (master != nil)
    {
        [master setChanges];
        [master updateLayout];
    }
}

// recompute the text image from the text storage (which in turn comes from the live text view!)
// then associate that image with the text layer in the effect stack
- (void)recomputeTextImage:(NSTextStorage *)ts
{
    NSBitmapImageRep *bitmapimagerep;
    NSSize sz;
    CIImage *im;
    NSRect bounds;
    NSImage *image;
    NSAffineTransform *t;
    
    // display control points and wing points, etc.
    // make a bitmap context to draw into
    bounds = [displayView bounds];
    image = [[[NSImage alloc] initWithSize:bounds.size] autorelease];
    sz = [image size];
    [image lockFocus];
    t = [[[NSAffineTransform alloc] init] autorelease];
    [t scaleBy:[[dict valueForKey:@"scale"] doubleValue]];
    [t set];
    // write to the image
    [ts drawAtPoint:NSMakePoint(0.0, 0.0)];
    // Get a bitmap image representation of the image
    bitmapimagerep = [[[NSBitmapImageRep alloc]
      initWithFocusedViewRect:NSMakeRect(0.0, 0.0, sz.width, (CGFloat)sz.height)] autorelease];
    [image unlockFocus];
    im = [[[CIImage alloc] initWithBitmapImageRep:bitmapimagerep] autorelease];
    [dict setValue:im forKey:@"image"];
}

// decide if a given text viuew differs in properties from those stored in the (retained) dictionary
// note: this is the dictionary from the effect stack text layer
- (BOOL)textViewDiffers:(NSTextView *)tv
{
    NSTextStorage *ts;
    NSDictionary *dattrs;
    NSFont *font;
    NSColor *color, *shadowColor;
    CGFloat red, green, blue, alpha, shadowColorRed, shadowColorGreen, shadowColorBlue, shadowColorAlpha,
      dShadowColorRed, dShadowColorGreen, dShadowColorBlue, dShadowColorAlpha, shadowBlurRadius, dShadowBlurRadius;
    NSShadow *shadow;
    NSSize shadowOffset, dShadowOffset;
    BOOL isShadow, dIsShadow;
    NSInteger strikeThrough, dStrikeThrough, underline, dUnderline;
    NSNumber *strikeThroughStyle, *underlineStyle;
    
    // see if string differs
    if (![[tv string] isEqualToString:[dict valueForKey:@"string"]])
        return YES;
    ts = [tv textStorage];
    dattrs = [ts attributesAtIndex:0 effectiveRange:nil];
    font = [dattrs valueForKey:NSFontAttributeName];
    // see if font has never been set
    if ([dict valueForKey:@"font"] == nil || [dict valueForKey:@"pointSize"] == nil || font == nil)
        return YES;
    // see if font name differs
    if (![[font fontName] isEqualToString:[dict valueForKey:@"font"]])
        return YES;
    // see if point size differs
    if ([font pointSize] != [[dict valueForKey:@"pointSize"] doubleValue])
        return YES;
    // see if color differs
    color = [dattrs valueForKey:NSForegroundColorAttributeName];
    if (color == nil)
    {
        red = 0.0;
        green = 0.0;
        blue = 0.0;
        alpha = 1.0;
    }
    else
        [color getRed:&red green:&green blue:&blue alpha:&alpha];
    if ([[dict valueForKey:@"colorRed"] doubleValue] != red
      || [[dict valueForKey:@"colorGreen"] doubleValue] != green
      || [[dict valueForKey:@"colorBlue"] doubleValue] != blue
      || [[dict valueForKey:@"colorAlpha"] doubleValue] != alpha)
        return YES;
    // see if shadow differs
    shadow = [dattrs valueForKey:NSShadowAttributeName];
    if (shadow == nil)
    {
        isShadow = NO;
        shadowOffset = NSMakeSize(0.0, 0.0);
        shadowColorRed = 0.0;
        shadowColorGreen = 0.0;
        shadowColorBlue = 0.0;
        shadowColorAlpha = 0.0;
        shadowBlurRadius = 0.0;
    }
    else
    {
        isShadow = YES;
        shadowOffset = [shadow shadowOffset];
        shadowColor = [shadow shadowColor];
        [shadowColor getRed:&shadowColorRed green:&shadowColorGreen blue:&shadowColorBlue alpha:&shadowColorAlpha];
        shadowBlurRadius = [shadow shadowBlurRadius];
    }
    if ([dict valueForKey:@"isShadow"] == nil)
    {
        dIsShadow = NO;
        dShadowOffset = NSZeroSize;
        dShadowColorRed = dShadowColorGreen = dShadowColorBlue = dShadowColorAlpha = 0.0;
        dShadowBlurRadius = 0.0;
    }
    else
    {
        dIsShadow = [[dict valueForKey:@"isShadow"] boolValue];
        dShadowOffset = NSMakeSize([[dict valueForKey:@"shadowOffsetX"] doubleValue], [[dict valueForKey:@"shadowOffsetY"] doubleValue]);
        dShadowColorRed = [[dict valueForKey:@"shadowColorRed"] doubleValue];
        dShadowColorGreen = [[dict valueForKey:@"shadowColorGreen"] doubleValue];
        dShadowColorBlue = [[dict valueForKey:@"shadowColorBlue"] doubleValue];
        dShadowColorAlpha = [[dict valueForKey:@"shadowColorAlpha"] doubleValue];
        dShadowBlurRadius = [[dict valueForKey:@"shadowBlurRadius"] doubleValue];
    }
    if (isShadow != dIsShadow)
        return YES;
    if (shadowOffset.height != dShadowOffset.height || shadowOffset.width != dShadowOffset.width)
        return YES;
    if (shadowColorRed != dShadowColorRed || shadowColorGreen != dShadowColorGreen || shadowColorBlue != dShadowColorBlue || shadowColorAlpha != dShadowColorAlpha)
        return YES;
    if (shadowBlurRadius != dShadowBlurRadius)
        return YES;
    // see if strike through style differs
    strikeThroughStyle = [dattrs valueForKey:NSStrikethroughStyleAttributeName];
    if (strikeThroughStyle == nil)
        strikeThrough = 0;
    else
        strikeThrough = [strikeThroughStyle integerValue];
    if ([dict valueForKey:@"strikeThroughStyle"] == nil)
        dStrikeThrough = 0;
    else
        dStrikeThrough = [[dict valueForKey:@"strikeThroughStyle"] integerValue];
    if (strikeThrough != dStrikeThrough)
        return YES;
    // see if underline style differs
    underlineStyle = [dattrs valueForKey:NSUnderlineStyleAttributeName];
    if (underlineStyle == nil)
        underline = 0;
    else
        underline = [underlineStyle integerValue];
    if ([dict valueForKey:@"underlineStyle"] == nil)
        dUnderline = 0;
    else
        dUnderline = [[dict valueForKey:@"underlineStyle"] integerValue];
    if (underline != dUnderline)
        return YES;
    return NO;
}

// synchronize the retained dictionary (the same one that's in the text layer) to a text view
// make sure all properties are up to date
- (void)synchronizeTextView:(NSTextView *)tv
{
    NSTextStorage *ts;
    NSDictionary *dattrs;
    NSFont *font;
    NSColor *color, *shadowColor;
    CGFloat red, green, blue, alpha, shadowColorRed, shadowColorGreen, shadowColorBlue, shadowColorAlpha, shadowBlurRadius;
    NSShadow *shadow;
    NSSize shadowOffset;
    BOOL isShadow;
    NSInteger strikeThrough, underline;
    NSNumber *strikeThroughStyle, *underlineStyle;
    
    if ([[tv string] isEqualToString:@""]) {
        // save string
        [displayView setDict:dict value:@"" forKey:@"string"];
        // set up an undo string for this action
        [displayView setActionNameForTextLayerKey:@"Typing"];
        return;
    }
    
    // save string
    [displayView setDict:dict value:[[[tv string] copy] autorelease] forKey:@"string"];
    ts = [tv textStorage];
    dattrs = [ts attributesAtIndex:0 effectiveRange:nil];
    // save font attributes
    font = [dattrs valueForKey:NSFontAttributeName];
    [displayView setDict:dict value:[[[font fontName] copy] autorelease] forKey:@"font"];
    [displayView setDict:dict value:[NSNumber numberWithDouble:[font pointSize]] forKey:@"pointSize"];
    // save color attributes
    color = [dattrs valueForKey:NSForegroundColorAttributeName];
    if (color == nil)
    {
        red = 0.0;
        green = 0.0;
        blue = 0.0;
        alpha = 1.0;
    }
    else
        [color getRed:&red green:&green blue:&blue alpha:&alpha];
    [displayView setDict:dict value:[NSNumber numberWithDouble:red] forKey:@"colorRed"];
    [displayView setDict:dict value:[NSNumber numberWithDouble:green] forKey:@"colorGreen"];
    [displayView setDict:dict value:[NSNumber numberWithDouble:blue] forKey:@"colorBlue"];
    [displayView setDict:dict value:[NSNumber numberWithDouble:alpha] forKey:@"colorAlpha"];
    // save shadow attributes
    shadow = [dattrs valueForKey:NSShadowAttributeName];
    if (shadow == nil)
    {
        isShadow = NO;
        shadowOffset = NSMakeSize(0.0, 0.0);
        shadowColorRed = 0.0;
        shadowColorGreen = 0.0;
        shadowColorBlue = 0.0;
        shadowColorAlpha = 0.0;
        shadowBlurRadius = 0.0;
    }
    else
    {
        isShadow = YES;
        shadowOffset = [shadow shadowOffset];
        shadowColor = [shadow shadowColor];
        [shadowColor getRed:&shadowColorRed green:&shadowColorGreen blue:&shadowColorBlue alpha:&shadowColorAlpha];
        shadowBlurRadius = [shadow shadowBlurRadius];
    }
    [displayView setDict:dict value:[NSNumber numberWithBool:isShadow] forKey:@"isShadow"];
    [displayView setDict:dict value:[NSNumber numberWithDouble:shadowOffset.width] forKey:@"shadowOffsetX"];
    [displayView setDict:dict value:[NSNumber numberWithDouble:shadowOffset.height] forKey:@"shadowOffsetY"];
    [displayView setDict:dict value:[NSNumber numberWithDouble:shadowColorRed] forKey:@"shadowColorRed"];
    [displayView setDict:dict value:[NSNumber numberWithDouble:shadowColorGreen] forKey:@"shadowColorGreen"];
    [displayView setDict:dict value:[NSNumber numberWithDouble:shadowColorBlue] forKey:@"shadowColorBlue"];
    [displayView setDict:dict value:[NSNumber numberWithDouble:shadowColorAlpha] forKey:@"shadowColorAlpha"];
    [displayView setDict:dict value:[NSNumber numberWithDouble:shadowBlurRadius] forKey:@"shadowBlurRadius"];
    // save strike through style
    strikeThroughStyle = [dattrs valueForKey:NSStrikethroughStyleAttributeName];
    if (strikeThroughStyle == nil)
        strikeThrough = 0;
    else
        strikeThrough = [strikeThroughStyle integerValue];
    [displayView setDict:dict value:[NSNumber numberWithInteger:strikeThrough] forKey:@"strikeThroughStyle"];
    // save underline style
    underlineStyle = [dattrs valueForKey:NSUnderlineStyleAttributeName];
    if (underlineStyle == nil)
        underline = 0;
    else
        underline = [underlineStyle integerValue];
    [displayView setDict:dict value:[NSNumber numberWithInteger:underline] forKey:@"underlineStyle"];
    // set up an undo string for this action
    [displayView setActionNameForTextLayerKey:@"Typing"];
}

// if a text view has changed from its version in the text layer dictionary, then re-render it and
// associate the image with the text layer for (later) redisplay
- (void)renderTextViewOnChanges:(NSTextView *)tv
{
    if ([self textViewDiffers:tv])
    {
        [self recomputeTextImage:[tv textStorage]];
        [self synchronizeTextView:tv];
    }
    // let core image recompute the display
    if (displayView != nil)
        [displayView setNeedsDisplay:YES];
    // we must re-layout the effect stack inspector now!
    if (master != nil)
        [master setChanges];
}

// called when text changes in the text view
- (IBAction)textDidChange:(NSNotification *)aNotification;
{
    [self renderTextViewOnChanges:[aNotification object]];
}

// called when typing attributes change in the text view
- (IBAction)textViewDidChangeTypingAttributes:(NSNotification *)aNotification
{
    [self renderTextViewOnChanges:[aNotification object]];
}

// this gets called when a scale slider in a text layer changes
- (IBAction)textSliderChanged:(id)sender
{
    CGFloat f;
    char str[32];
    
    // make sure we're connected right
    if (labelTextField == nil)
        return;
    if (readoutTextField != nil && slider != nil)
    {
        f = [slider doubleValue];
        // make sure we don't do this any more than we have to
        if (f == lastFloatValue)
            return;
        lastFloatValue = f;
        // update the parallel readout field
        format_floating_point_number(slider_to_readout_value(f, dataType), beforeDecimal, afterDecimal, str);
        [readoutTextField setStringValue:[NSString stringWithUTF8String:str]];
        // set the scale field for the text layer
        [displayView setDict:dict value:[NSNumber numberWithDouble:f] forKey:key];
        [displayView setActionNameForTextLayerKey:key];
        // and recompute the text image
        [self recomputeTextImage:[dict valueForKey:@"textStorage"]];
    }
    // let core image recompute the display
    if (displayView != nil)
        [displayView setNeedsDisplay:YES];
}

// this gets called when the scale readout field in a text layer gets edited
- (IBAction)textReadoutTextFieldChanged:(id)sender
{
    CGFloat f;
    
    // make sure we're connected right
    if (labelTextField == nil)
        return;
    if (readoutTextField != nil && slider != nil)
    {
        // get the readout's value
        f = readout_to_slider_value([readoutTextField doubleValue], dataType);
        // make sure we don't do this any more than we have to
        if (f == lastFloatValue)
            return;
        lastFloatValue = f;
        // update the parallel slider
        [slider setDoubleValue:f];
        // set the scale field for the text layer
        [displayView setDict:dict value:[NSNumber numberWithDouble:f] forKey:key];
        [displayView setActionNameForTextLayerKey:key];
        // and recompute the text image
        [self recomputeTextImage:[dict valueForKey:@"textStorage"]];
    }
    // let core image recompute the display
    if (displayView != nil)
        [displayView setNeedsDisplay:YES];
}

// convert scale, angle, stretch, skew, tx, and ty into a coherent transform (vector format)
static CIVector *standard_fields_to_transform_vector(CGFloat scale, CGFloat angle, CGFloat stretch, CGFloat skew, CGFloat tx, CGFloat ty)
{
    double cs, sn;
    CIVector *t;
    CGFloat values[6];
    
    cs = cos(angle);
    sn = sin(angle);
    values[0] = (cs - skew * sn) * stretch * scale;
    values[1] = (sn + skew * cs) * stretch * scale;
    values[2] = - sn * scale;
    values[3] = cs * scale;
    values[4] = tx;
    values[5] = ty;
    t = [CIVector vectorWithValues:values count:6];
    return t;
}

// convert scale, angle, stretch, skew, tx, and ty into an NSAffineTransform
static NSAffineTransform *standard_fields_to_transform(CGFloat scale, CGFloat angle, CGFloat stretch, CGFloat skew, CGFloat tx, CGFloat ty)
{
    double cs, sn;
    NSAffineTransform *t;
    NSAffineTransformStruct S;
    
    cs = cos(angle);
    sn = sin(angle);
    S.m11 = (cs - skew * sn) * stretch * scale;
    S.m12 = (sn + skew * cs) * stretch * scale;
    S.m21 = - sn * scale;
    S.m22 = cs * scale;
    S.tX = tx;
    S.tY = ty;
    t = [NSAffineTransform transform];
    [t setTransformStruct:S];
    return t;
}

// convert a vector or an NSAffineTransform into the standard breakout - scale, angle, stretch, skew, tx, and ty
static void transform_to_standard_fields(CIVector *t, CGFloat *scale, CGFloat *angle, CGFloat *stretch, CGFloat *skew, CGFloat *tx, CGFloat *ty)
{
    double sc, an, sk, st, sn, cs, m11, m12, m21, m22, mtx, mty, tm;
    
    if ([t isKindOfClass:[NSAffineTransform class]])
    {
        NSAffineTransformStruct T;
        NSAffineTransform *tr;
        
        tr = (NSAffineTransform *)t;
        T = [tr transformStruct];
        m11 = T.m11;
        m12 = T.m12;
        m21 = T.m21;
        m22 = T.m22;
        mtx = T.tX;
        mty = T.tY;
    }
    else
    {
        m11 = [t valueAtIndex:0];
        m12 = [t valueAtIndex:1];
        m21 = [t valueAtIndex:2];
        m22 = [t valueAtIndex:3];
        mtx = [t valueAtIndex:4];
        mty = [t valueAtIndex:5];
    }
    sc = sqrt(m21 * m21 + m22 * m22);
    if (m21 == 0.0 && m22 == 1.0)
        an = 0.0;
    else
    {
        an = atan2(-m21, m22);
        if (an < 0.0)
            an += M_PI * 2.0;
    }
    cs = cos(an);
    sn = sin(an);
    tm = m11 * sn - m12 * cs;
    if (tm == 0.0)
        sk = 0.0;
    else
        sk = - tm / (m12 * sn + m11 * cs);
    st = m11 / (sc * (cs - sn * sk));
    *scale = sc;
    *angle = an;
    *stretch = st;
    *skew = sk;
    *tx = mtx;
    *ty = mty;
}

// this gets called when a filter's transform scale slider changes
- (IBAction)scaleSliderChanged:(id)sender
{
    CGFloat f, tx, ty;
    char str[32];
    CIVector *t;
    NSAffineTransform *tr;
    NSAffineTransformStruct T;
    
    // make sure we're connected right
    if (scaleLabelTextField == nil)
        return;
    if (scaleReadoutTextField != nil && scaleSlider != nil)
    {
        f = pow(10.0, [scaleSlider doubleValue]);
        // make sure we don't do this any more than we have to
        if (f == lastScaleFloatValue)
            return;
        lastScaleFloatValue = f;
        // update the parallel readout field
        format_floating_point_number(slider_to_readout_value(f, scaleDataType), 4, 2, str);
        [scaleReadoutTextField setStringValue:[NSString stringWithUTF8String:str]];
        t = [filter valueForKey:key];
        if ([t isKindOfClass:[NSAffineTransform class]])
        {
            tr = (NSAffineTransform *)t;
            T = [tr transformStruct];
            tx = T.tX;
            ty = T.tY;
        }
        else
        {
            tx = [t valueAtIndex:4];
            ty = [t valueAtIndex:5];
        }
        if (usingNSAffineTransform)
        {
            tr = standard_fields_to_transform(lastScaleFloatValue, lastAngleFloatValue, lastStretchFloatValue, lastSkewFloatValue, tx, ty);
            // update the filter (using undo-compatible glue code)
            [displayView setFilter:filter value:tr forKey:key];
            // and set up the undo string based on the filter and key names
            [displayView setActionNameForFilter:filter key:key];
        }
        else
        {
            t = standard_fields_to_transform_vector(lastScaleFloatValue, lastAngleFloatValue, lastStretchFloatValue, lastSkewFloatValue, tx, ty);
            // update the filter (using undo-compatible glue code)
            [displayView setFilter:filter value:t forKey:key];
            // and set up the undo string based on the filter and key names
            [displayView setActionNameForFilter:filter key:key];
        }
    }
    // let core image recompute the display
    if (displayView != nil)
         [displayView setNeedsDisplay:YES];
}

// this gets called when a filter's transform scale readout gets edited
- (IBAction)scaleReadoutTextFieldChanged:(id)sender
{
    CGFloat f, tx, ty;
    CIVector *t;
    NSAffineTransform *tr;
    NSAffineTransformStruct T;
    
    // make sure we're connected right
    if (scaleLabelTextField == nil)
        return;
    if (scaleReadoutTextField != nil && scaleSlider != nil)
    {
        // get the readout's value
        f = readout_to_slider_value([scaleReadoutTextField doubleValue], scaleDataType);
        // make sure we don't do this any more than we have to
        if (f == lastScaleFloatValue)
            return;
        lastScaleFloatValue = f;
        // update the parallel slider
        [scaleSlider setDoubleValue:log10(f)];
        t = [filter valueForKey:key];
        if ([t isKindOfClass:[NSAffineTransform class]])
        {
            tr = (NSAffineTransform *)t;
            T = [tr transformStruct];
            tx = T.tX;
            ty = T.tY;
        }
        else
        {
            tx = [t valueAtIndex:4];
            ty = [t valueAtIndex:5];
        }
        if (usingNSAffineTransform)
        {
            tr = standard_fields_to_transform(lastScaleFloatValue, lastAngleFloatValue, lastStretchFloatValue, lastSkewFloatValue, tx, ty);
            // update the filter (using undo-compatible glue code)
            [displayView setFilter:filter value:tr forKey:key];
            // and set up the undo string based on the filter and key names
            [displayView setActionNameForFilter:filter key:key];
        }
        else
        {
            t = standard_fields_to_transform_vector(lastScaleFloatValue, lastAngleFloatValue, lastStretchFloatValue, lastSkewFloatValue, tx, ty);
            // update the filter (using undo-compatible glue code)
            [displayView setFilter:filter value:t forKey:key];
            // and set up the undo string based on the filter and key names
            [displayView setActionNameForFilter:filter key:key];
        }
    }
    // let core image recompute the display
    if (displayView != nil)
         [displayView setNeedsDisplay:YES];
}

// this gets called when a filter's transform angle slider changes
- (IBAction)angleSliderChanged:(id)sender
{
    CGFloat f, tx, ty;
    char str[32];
    CIVector *t;
    NSAffineTransform *tr;
    NSAffineTransformStruct T;
    
    // make sure we're connected right
    if (angleLabelTextField == nil)
        return;
    if (angleReadoutTextField != nil && angleSlider != nil)
    {
        f = [angleSlider doubleValue];
        // make sure we don't do this any more than we have to
        if (f == lastAngleFloatValue)
            return;
        lastAngleFloatValue = f;
        // update the parallel readout field
        format_floating_point_number(slider_to_readout_value(f, angleDataType), 3, 1, str);
        [angleReadoutTextField setStringValue:[NSString stringWithUTF8String:str]];
        t = [filter valueForKey:key];
        if ([t isKindOfClass:[NSAffineTransform class]])
        {
            tr = (NSAffineTransform *)t;
            T = [tr transformStruct];
            tx = T.tX;
            ty = T.tY;
        }
        else
        {
            tx = [t valueAtIndex:4];
            ty = [t valueAtIndex:5];
        }
        if (usingNSAffineTransform)
        {
            tr = standard_fields_to_transform(lastScaleFloatValue, lastAngleFloatValue, lastStretchFloatValue, lastSkewFloatValue, tx, ty);
            // update the filter (using undo-compatible glue code)
            [displayView setFilter:filter value:tr forKey:key];
            // and set up the undo string based on the filter and key names
            [displayView setActionNameForFilter:filter key:key];
        }
        else
        {
            t = standard_fields_to_transform_vector(lastScaleFloatValue, lastAngleFloatValue, lastStretchFloatValue, lastSkewFloatValue, tx, ty);
            // update the filter (using undo-compatible glue code)
            [displayView setFilter:filter value:t forKey:key];
            // and set up the undo string based on the filter and key names
            [displayView setActionNameForFilter:filter key:key];
        }
    }
    // let core image recompute the display
    if (displayView != nil)
         [displayView setNeedsDisplay:YES];
}

// this gets called when a filter's transform angle readout gets edited
- (IBAction)angleReadoutTextFieldChanged:(id)sender
{
    CGFloat f, tx, ty;
    CIVector *t;
    NSAffineTransform *tr;
    NSAffineTransformStruct T;
    
    // make sure we're connected right
    if (angleLabelTextField == nil)
        return;
    if (angleReadoutTextField != nil && angleSlider != nil)
    {
        // get the readout's value
        f = readout_to_slider_value([angleReadoutTextField doubleValue], angleDataType);
        // make sure we don't do this any more than we have to
        if (f == lastAngleFloatValue)
            return;
        lastAngleFloatValue = f;
        // update the parallel slider
        [angleSlider setDoubleValue:f];
        t = [filter valueForKey:key];
        if ([t isKindOfClass:[NSAffineTransform class]])
        {
            tr = (NSAffineTransform *)t;
            T = [tr transformStruct];
            tx = T.tX;
            ty = T.tY;
        }
        else
        {
            tx = [t valueAtIndex:4];
            ty = [t valueAtIndex:5];
        }
        if (usingNSAffineTransform)
        {
            tr = standard_fields_to_transform(lastScaleFloatValue, lastAngleFloatValue, lastStretchFloatValue, lastSkewFloatValue, tx, ty);
            // update the filter (using undo-compatible glue code)
            [displayView setFilter:filter value:tr forKey:key];
            // and set up the undo string based on the filter and key names
            [displayView setActionNameForFilter:filter key:key];
        }
        else
        {
            t = standard_fields_to_transform_vector(lastScaleFloatValue, lastAngleFloatValue, lastStretchFloatValue, lastSkewFloatValue, tx, ty);
            // update the filter (using undo-compatible glue code)
            [displayView setFilter:filter value:t forKey:key];
            // and set up the undo string based on the filter and key names
            [displayView setActionNameForFilter:filter key:key];
        }
    }
    // let core image recompute the display
    if (displayView != nil)
         [displayView setNeedsDisplay:YES];
}

// this gets called when a filter's transform stretch slider changes
- (IBAction)stretchSliderChanged:(id)sender
{
    CGFloat f, tx, ty;
    char str[32];
    CIVector *t;
    NSAffineTransform *tr;
    NSAffineTransformStruct T;
    
    // make sure we're connected right
    if (stretchLabelTextField == nil)
        return;
    if (stretchReadoutTextField != nil && stretchSlider != nil)
    {
        f = pow(10.0, [stretchSlider doubleValue]);
        // make sure we don't do this any more than we have to
        if (f == lastStretchFloatValue)
            return;
        lastStretchFloatValue = f;
        // update the parallel readout field
        format_floating_point_number(slider_to_readout_value(f, stretchDataType), 4, 2, str);
        [stretchReadoutTextField setStringValue:[NSString stringWithUTF8String:str]];
        t = [filter valueForKey:key];
        if ([t isKindOfClass:[NSAffineTransform class]])
        {
            tr = (NSAffineTransform *)t;
            T = [tr transformStruct];
            tx = T.tX;
            ty = T.tY;
        }
        else
        {
            tx = [t valueAtIndex:4];
            ty = [t valueAtIndex:5];
        }
        if (usingNSAffineTransform)
        {
            tr = standard_fields_to_transform(lastScaleFloatValue, lastAngleFloatValue, lastStretchFloatValue, lastSkewFloatValue, tx, ty);
            // update the filter (using undo-compatible glue code)
            [displayView setFilter:filter value:tr forKey:key];
            // and set up the undo string based on the filter and key names
            [displayView setActionNameForFilter:filter key:key];
        }
        else
        {
            t = standard_fields_to_transform_vector(lastScaleFloatValue, lastAngleFloatValue, lastStretchFloatValue, lastSkewFloatValue, tx, ty);
            // update the filter (using undo-compatible glue code)
            [displayView setFilter:filter value:t forKey:key];
            // and set up the undo string based on the filter and key names
            [displayView setActionNameForFilter:filter key:key];
        }
    }
    // let core image recompute the display
    if (displayView != nil)
         [displayView setNeedsDisplay:YES];
   }

// this gets called when a filter's transform stretch readout gets edited
- (IBAction)stretchReadoutTextFieldChanged:(id)sender
{
    CGFloat f, tx, ty;
    CIVector *t;
    NSAffineTransform *tr;
    NSAffineTransformStruct T;
    
    // make sure we're connected right
    if (stretchLabelTextField == nil)
        return;
    if (stretchReadoutTextField != nil && stretchSlider != nil)
    {
        // get the readout's value
        f = readout_to_slider_value([stretchReadoutTextField doubleValue], stretchDataType);
        // make sure we don't do this any more than we have to
        if (f == lastStretchFloatValue)
            return;
        lastStretchFloatValue = f;
        // update the parallel slider
        [stretchSlider setDoubleValue:log10(f)];
        t = [filter valueForKey:key];
        if ([t isKindOfClass:[NSAffineTransform class]])
        {
            tr = (NSAffineTransform *)t;
            T = [tr transformStruct];
            tx = T.tX;
            ty = T.tY;
        }
        else
        {
            tx = [t valueAtIndex:4];
            ty = [t valueAtIndex:5];
        }
        if (usingNSAffineTransform)
        {
            tr = standard_fields_to_transform(lastScaleFloatValue, lastAngleFloatValue, lastStretchFloatValue, lastSkewFloatValue, tx, ty);
            // update the filter (using undo-compatible glue code)
            [displayView setFilter:filter value:tr forKey:key];
            // and set up the undo string based on the filter and key names
            [displayView setActionNameForFilter:filter key:key];
        }
        else
        {
            t = standard_fields_to_transform_vector(lastScaleFloatValue, lastAngleFloatValue, lastStretchFloatValue, lastSkewFloatValue, tx, ty);
            // update the filter (using undo-compatible glue code)
            [displayView setFilter:filter value:t forKey:key];
            // and set up the undo string based on the filter and key names
            [displayView setActionNameForFilter:filter key:key];
        }
    }
    // let core image recompute the display
    if (displayView != nil)
         [displayView setNeedsDisplay:YES];
}

// this gets called when a filter's transform skew slider changes
- (IBAction)skewSliderChanged:(id)sender
{
    CGFloat f, tx, ty;
    char str[32];
    CIVector *t;
    NSAffineTransform *tr;
    NSAffineTransformStruct T;
    
    // make sure we're connected right
    if (skewLabelTextField == nil)
        return;
    if (skewReadoutTextField != nil && skewSlider != nil)
    {
        f = [skewSlider doubleValue];
        // make sure we don't do this any more than we have to
        if (f == lastSkewFloatValue)
            return;
        lastSkewFloatValue = f;
        // update the parallel readout field
        format_floating_point_number(slider_to_readout_value(f, skewDataType), 4, 2, str);
        [skewReadoutTextField setStringValue:[NSString stringWithUTF8String:str]];
        t = [filter valueForKey:key];
        if ([t isKindOfClass:[NSAffineTransform class]])
        {
            tr = (NSAffineTransform *)t;
            T = [tr transformStruct];
            tx = T.tX;
            ty = T.tY;
        }
        else
        {
            tx = [t valueAtIndex:4];
            ty = [t valueAtIndex:5];
        }
        if (usingNSAffineTransform)
        {
            tr = standard_fields_to_transform(lastScaleFloatValue, lastAngleFloatValue, lastStretchFloatValue, lastSkewFloatValue, tx, ty);
            // update the filter (using undo-compatible glue code)
            [displayView setFilter:filter value:tr forKey:key];
            // and set up the undo string based on the filter and key names
            [displayView setActionNameForFilter:filter key:key];
        }
        else
        {
            t = standard_fields_to_transform_vector(lastScaleFloatValue, lastAngleFloatValue, lastStretchFloatValue, lastSkewFloatValue, tx, ty);
            // update the filter (using undo-compatible glue code)
            [displayView setFilter:filter value:t forKey:key];
            // and set up the undo string based on the filter and key names
            [displayView setActionNameForFilter:filter key:key];
        }
    }
    // let core image recompute the display
    if (displayView != nil)
         [displayView setNeedsDisplay:YES];
}

// this gets called when a filter's transform skew readout gets edited
- (IBAction)skewReadoutTextFieldChanged:(id)sender
{
    CGFloat f, tx, ty;
    CIVector *t;
    NSAffineTransform *tr;
    NSAffineTransformStruct T;
    
    // make sure we're connected right
    if (skewLabelTextField == nil)
        return;
    if (skewReadoutTextField != nil && skewSlider != nil)
    {
        // get the readout's value
        f = readout_to_slider_value([skewReadoutTextField doubleValue], skewDataType);
        // make sure we don't do this any more than we have to
        if (f == lastSkewFloatValue)
            return;
        lastSkewFloatValue = f;
        // update the parallel slider
        [skewSlider setDoubleValue:f];
        t = [filter valueForKey:key];
        if ([t isKindOfClass:[NSAffineTransform class]])
        {
            tr = (NSAffineTransform *)t;
            T = [tr transformStruct];
            tx = T.tX;
            ty = T.tY;
        }
        else
        {
            tx = [t valueAtIndex:4];
            ty = [t valueAtIndex:5];
        }
        if (usingNSAffineTransform)
        {
            tr = standard_fields_to_transform(lastScaleFloatValue, lastAngleFloatValue, lastStretchFloatValue, lastSkewFloatValue, tx, ty);
            // update the filter (using undo-compatible glue code)
            [displayView setFilter:filter value:tr forKey:key];
            // and set up the undo string based on the filter and key names
            [displayView setActionNameForFilter:filter key:key];
        }
        else
        {
            t = standard_fields_to_transform_vector(lastScaleFloatValue, lastAngleFloatValue, lastStretchFloatValue, lastSkewFloatValue, tx, ty);
            // update the filter (using undo-compatible glue code)
            [displayView setFilter:filter value:t forKey:key];
            // and set up the undo string based on the filter and key names
            [displayView setActionNameForFilter:filter key:key];
        }
    }
    // let core image recompute the display
    if (displayView != nil)
         [displayView setNeedsDisplay:YES];
}

// take a standard input parameter, add spaces between the words
NSString *unInterCap(NSString *s)
{
    BOOL change;
    NSInteger i;
    unichar c1, c2;
    NSString *l;
    NSMutableString *s2;
    
    s2 = [s mutableCopy];
    l = [s2 lowercaseString];
    // "StriationStrength" => "Striation Strength"
    change = NO;
    for (i = 0; i < [s2 length]; i++)
    {
        c1 = [s2 characterAtIndex:i];
        c2 = [l characterAtIndex:i];
        if ((c1 != c2 || (c1 >= '0' && c1 <= '9')) && i != 0)
        {
            [s2 insertString:@" " atIndex:i];
            l = [s2 lowercaseString];
            change = YES;
            i++;
        }
    }
    if (change)
	s = [[s2 copy] autorelease];
    [s2 release];
    return s;
}

// constants for slider size and spacing
#define kSliderHeight      (16)
#define kSliderLabelWidth  (60)
#define kSliderValueWidth  (43)
#define kSliderGap         (4)

// compute the length of a text string, decide if it fits within a field rectangle, then ellipsize it if necessary
// using "..."
+ (NSString *)ellipsizeField:(CGFloat)width font:(NSFont *)font string:(NSString *)label
{
    BOOL first;
    NSInteger length, columnwidth, stringwidth;
    NSMutableString *label2;
    
    // determine if we need to ellipsize
    columnwidth = width - 5;
	stringwidth = (NSInteger)[label sizeWithAttributes:[NSDictionary dictionaryWithObject:font forKey:NSFontNameAttribute]].width;
    if (stringwidth <= columnwidth)
        return label;
    label2 = [label mutableCopy];
    first = YES;
    while (stringwidth > columnwidth)
    {
        length = [label2 length];
        if (first)
            [label2 replaceCharactersInRange:NSMakeRange(length-1, 1) withString:@"..."];
        else
            [label2 replaceCharactersInRange:NSMakeRange(length-4, 4) withString:@"..."]; // must include ellipsis now
        first = NO;
		stringwidth = (NSInteger)[label2 sizeWithAttributes:[NSDictionary dictionaryWithObject:font forKey:NSFontNameAttribute]].width;
    }
    label = [[label2 copy] autorelease];
    [label2 release];
    return label;
}

// add a slider, hooked up to a given filter instance, connected to the filter's parameter with the given key
- (void)addSliderForFilter:(CIFilter *)f key:(NSString *)k displayView:(CoreImageView *)v master:(EffectStackController *)m
{
    CGFloat hi, lo, def;
    NSRect sRect, tRect, rRect, bounds;
    NSNumber *number;
    NSString *label, *typestr;
    NSDictionary *parameter;
    NSCell *c;
    char str[32];
    
    filter = [f retain];
    dict = nil;
    key = [k retain];
    displayView = [v retain];
    master = [m retain];
    bounds = [self bounds];
    // allocate rectangles here
    tRect = NSMakeRect(0, 0, kSliderLabelWidth, kSliderHeight);
    sRect = NSMakeRect(kSliderLabelWidth + kSliderGap, 0, bounds.size.width - 3*kSliderGap
	    - kSliderLabelWidth - kSliderValueWidth, kSliderHeight);
    rRect = NSMakeRect(bounds.size.width - kSliderValueWidth - kSliderGap, 0, kSliderValueWidth, kSliderHeight);
    // make the slider
    slider = [[NSSlider alloc] initWithFrame:sRect];
    [slider setTarget:self];
    [slider setAction:@selector(sliderChanged:)];
    [[slider cell] setControlSize:NSMiniControlSize];
    [slider setAutoresizingMask:NSViewWidthSizable|NSViewMinYMargin];
    // set up the slider's min and max values from the parameter dictionary
    parameter = [[filter attributes] valueForKey:key];
    number = [parameter objectForKey: kCIAttributeSliderMax];
    if (number == nil)
        number = [parameter objectForKey: kCIAttributeMax];
    hi = [number doubleValue];
    [slider setMaxValue:hi];
    number = [parameter objectForKey: kCIAttributeSliderMin];
    if (number == nil)
        number = [parameter objectForKey: kCIAttributeMin];
    lo = [number doubleValue];
    [slider setMinValue:lo];
    // set up the slider's current value from its value
    number = [filter valueForKey:key];
    def = [number doubleValue];
    [slider setDoubleValue:def];
    lastFloatValue = def;
    [self addSubview:slider];
    // determine numeric data type
    typestr = [parameter objectForKey: kCIAttributeType];
    dataType = stScalar;
    if ([typestr isEqualToString: kCIAttributeTypeScalar])
        dataType = stScalar;
    else if ([typestr isEqualToString: kCIAttributeTypeAngle])
        dataType = stAngle;
    else if ([typestr isEqualToString: kCIAttributeTypeTime])
        dataType = stTime;
    else if ([typestr isEqualToString: kCIAttributeTypeDistance])
        dataType = stDistance;
    // set up the label text field
    labelTextField = [[NSTextField alloc] initWithFrame:tRect];
    if (![key hasPrefix:@"input"])
        printf("input key does not begin with input\n");
    label = [parameter objectForKey:kCIAttributeDisplayName];
    // if no localized display name for the key, make one from the key name
    if (label == nil)
        label = unInterCap([key substringFromIndex:5]);
    // set text label to 9 point
    c = [labelTextField cell];
    [c setFont:[NSFont fontWithName:[[c font] fontName] size:9]];
    [c setAlignment:NSRightTextAlignment];
    // compute the label text, ellipsize if necessary
    label = [ParameterView ellipsizeField:[c drawingRectForBounds:[labelTextField bounds]].size.width font:[c font] string:label];
    [labelTextField setStringValue:label];
    [labelTextField setEditable:NO];
    [labelTextField setBezeled:NO];
    [labelTextField setDrawsBackground:NO];
    [labelTextField setAutoresizingMask:NSViewMaxXMargin|NSViewMinYMargin];
    [self addSubview:labelTextField];
    // add the readout (editable) text field
    // decide its floating point format
    switch (dataType)
    {
    case stScalar:
        beforeDecimal = 4;
        afterDecimal = 2;
        break;
    case stAngle:
        beforeDecimal = 3;
        afterDecimal = 1;
        break;
    case stTime:
        beforeDecimal = 1;
        afterDecimal = 3;
        break;
    case stDistance:
        beforeDecimal = 4;
        afterDecimal = 1;
        break;
    }
    readoutTextField = [[NSTextField alloc] initWithFrame:rRect];
    [readoutTextField setTarget:self];
    [readoutTextField setAction:@selector(readoutTextFieldChanged:)];
    format_floating_point_number(slider_to_readout_value(def, dataType), beforeDecimal, afterDecimal, str);
    [readoutTextField setStringValue:[NSString stringWithUTF8String:str]];
    // set text readout to 9 point
    c = [readoutTextField cell];
    [c setFont:[NSFont fontWithName:[[c font] fontName] size:9]];
    [c setAlignment:NSLeftTextAlignment];
    [readoutTextField setEditable:YES];
    [readoutTextField setDrawsBackground:YES];
    [[readoutTextField cell] setControlSize:NSSmallControlSize];
    [readoutTextField setAutoresizingMask:NSViewMinXMargin|NSViewMinYMargin];
    [self addSubview:readoutTextField];
}

// add a check box for a filter parameter that's a number with a boolean tag
// given the filter instance, and the actual key it's bound to
- (void)addCheckBoxForFilter:(CIFilter *)f key:(NSString *)k displayView:(CoreImageView *)v master:(EffectStackController *)m
{
    BOOL b;
    NSCellStateValue state;
    NSRect sRect;
    NSNumber *number;
    NSString *label;
    NSCell *c;
    NSDictionary *parameter;
    
    filter = [f retain];
    dict = nil;
    key = [k retain];
    displayView = [v retain];
    master = [m retain];
    sRect = NSMakeRect(76, 0, 155, 16);
    // make the check box
    checkBox = [[NSButton alloc] initWithFrame:sRect];
    [checkBox setTarget:self];
    [checkBox setAction:@selector(checkBoxChanged:)];
    [[checkBox cell] setControlSize:NSMiniControlSize];
    [checkBox setButtonType:NSSwitchButton];
    [checkBox setAutoresizingMask:NSViewMaxXMargin|NSViewMinYMargin];
    parameter = [[filter attributes] valueForKey:key];
    // set up its state from its value
    number = [filter valueForKey:key];
    b = [number boolValue];
    state = b ? NSOnState : NSOffState;
    [checkBox setState:state];
    [self addSubview:checkBox];
    if (![key hasPrefix:@"input"])
        printf("input key does not begin with input\n");
    label = [parameter objectForKey:kCIAttributeDisplayName];
    // if no localized display name for the key, make one directly from its name
    if (label == nil)
        label = unInterCap([key substringFromIndex:5]);
    [checkBox setTitle:label];
    // set text label to 9 point
    c = [checkBox cell];
    [c setFont:[NSFont fontWithName:[[c font] fontName] size:9]];
    [c setAlignment:NSLeftTextAlignment];
}

// add a color well for a CIColor parameter
// given the filter instance and the key it's bound to
- (void)addColorWellForFilter:(CIFilter *)f key:(NSString *)k displayView:(CoreImageView *)v master:(EffectStackController *)m
{
    NSRect cRect, tRect, bounds;
    NSString *label;
    NSCell *c;
    CIColor *color;
    NSDictionary *parameter;
    
    filter = [f retain];
    dict = nil;
    key = [k retain];
    displayView = [v retain];
    master = [m retain];
    bounds = [self bounds];
    cRect = NSMakeRect(bounds.size.width - 38, 0, 38, 24);
    tRect = NSMakeRect(0, 0, bounds.size.width - 43, 16);
    // make the color well
    colorWell = [[NSColorWell alloc] initWithFrame:cRect];
    [colorWell setTarget:self];
    [colorWell setAction:@selector(colorWellChanged:)];
    parameter = [[filter attributes] valueForKey:key];
    color = [filter valueForKey:key];
    [colorWell setColor:[NSColor colorWithCIColor: color]];
    [colorWell setAutoresizingMask:NSViewWidthSizable|NSViewMinXMargin|NSViewMinYMargin];
    [self addSubview:colorWell];
    // make the text label
    labelTextField = [[NSTextField alloc] initWithFrame:tRect];
    if (![key hasPrefix:@"input"])
        printf("input key does not begin with input\n");
    label = [parameter objectForKey:kCIAttributeDisplayName];
    // if there's no localized display name for the key, make one directly from the key name
    if (label == nil)
        label = unInterCap([key substringFromIndex:5]);
    // set text label to 9 point
    c = [labelTextField cell];
    [c setFont:[NSFont fontWithName:[[c font] fontName] size:9]];
    [c setAlignment:NSRightTextAlignment];
    label = [ParameterView ellipsizeField:[c drawingRectForBounds:[labelTextField bounds]].size.width font:[c font] string:label];
    [labelTextField setStringValue:label];
    [labelTextField setEditable:NO];
    [labelTextField setBezeled:NO];
    [labelTextField setDrawsBackground:NO];
    [labelTextField setAutoresizingMask:NSViewMaxXMargin|NSViewMinYMargin];
    [self addSubview:labelTextField];
}    

#define textbox_sep 5

// this one adds 4 editable text fields for a CIVector that has no other attributes
// given the filter instance pointer and the key that it's bound to
- (void)addVectorForFilter:(CIFilter *)f key:(NSString *)k displayView:(CoreImageView *)v master:(EffectStackController *)m
{
    NSInteger left, right, tbwid;
    CGFloat def, textbox_width;
    NSRect r1Rect, r2Rect, r3Rect, r4Rect, tRect, bounds;
    NSString *label;
    NSCell *c;
    char str[32];
    CIVector *vec;
    NSDictionary *parameter;
    
    filter = [f retain];
    dict = nil;
    key = [k retain];
    displayView = [v retain];
    master = [m retain];
    bounds = [self bounds];
    tRect = NSMakeRect(0, 0, 75, 16);
    left = 80;
    right = bounds.size.width - 5;
    textbox_width = (right - left - textbox_sep*3)*0.25;
    tbwid = floor(textbox_width);
    r1Rect = NSMakeRect(left, 0, tbwid, 16);
    r2Rect = NSMakeRect(floor(left + textbox_width + textbox_sep), 0, tbwid, 16);
    r3Rect = NSMakeRect(floor(left + 2*(textbox_width + textbox_sep)), 0, tbwid, 16);
    r4Rect = NSMakeRect(floor(left + 3*(textbox_width + textbox_sep)), 0, tbwid, 16);
    beforeDecimal = 1;
    afterDecimal = 3;
    parameter = [[filter attributes] valueForKey:key];
    // create the text label for the vector
    labelTextField = [[NSTextField alloc] initWithFrame:tRect];
    label = [parameter objectForKey:kCIAttributeDisplayName];
    if (label == nil)
        label = unInterCap([key substringFromIndex:5]);
    // set text label to 9 point
    c = [labelTextField cell];
    [c setFont:[NSFont fontWithName:[[c font] fontName] size:9]];
    [c setAlignment:NSRightTextAlignment];
    // determine if we need to ellipsize the text label
    label = [ParameterView ellipsizeField:[c drawingRectForBounds:[labelTextField bounds]].size.width font:[c font] string:label];
    [labelTextField setStringValue:label];
    [labelTextField setEditable:NO];
    [labelTextField setBezeled:NO];
    [labelTextField setDrawsBackground:NO];
    [labelTextField setAutoresizingMask:NSViewMaxXMargin|NSViewMinYMargin];
    [self addSubview:labelTextField];
    // create the (editable) text field for the x value of the vector
    vec = [filter valueForKey:key];
    def = [vec X];
    readout1TextField = [[NSTextField alloc] initWithFrame:r1Rect];
    [readout1TextField setTarget:self];
    [readout1TextField setAction:@selector(readout1TextFieldChanged:)];
    format_floating_point_number(slider_to_readout_value(def, dataType), beforeDecimal, afterDecimal, str);
    [readout1TextField setStringValue:[NSString stringWithUTF8String:str]];
    // set text label to 9 point
    c = [readout1TextField cell];
    [c setFont:[NSFont fontWithName:[[c font] fontName] size:9]];
    [c setAlignment:NSLeftTextAlignment];
    [readout1TextField setEditable:YES];
    [readout1TextField setBezeled:YES];
    [readout1TextField setDrawsBackground:YES];
    [readout1TextField setAutoresizingMask:NSViewMinXMargin|NSViewMinYMargin];
    [self addSubview:readout1TextField];
    // create the (editable) text field for the y value of the vector
    vec = [filter valueForKey:key];
    def = [vec Y];
    readout2TextField = [[NSTextField alloc] initWithFrame:r2Rect];
    [readout2TextField setTarget:self];
    [readout2TextField setAction:@selector(readout2TextFieldChanged:)];
    format_floating_point_number(slider_to_readout_value(def, dataType), beforeDecimal, afterDecimal, str);
    [readout2TextField setStringValue:[NSString stringWithUTF8String:str]];
    // set text label to 9 point
    c = [readout2TextField cell];
    [c setFont:[NSFont fontWithName:[[c font] fontName] size:9]];
    [c setAlignment:NSLeftTextAlignment];
    [readout2TextField setEditable:YES];
    [readout2TextField setBezeled:YES];
    [readout2TextField setDrawsBackground:YES];
    [readout2TextField setAutoresizingMask:NSViewMinXMargin|NSViewMinYMargin];
    [self addSubview:readout2TextField];
    // create the (editable) text field for the z value of the vector
    vec = [filter valueForKey:key];
    def = [vec Z];
    readout3TextField = [[NSTextField alloc] initWithFrame:r3Rect];
    [readout3TextField setTarget:self];
    [readout3TextField setAction:@selector(readout3TextFieldChanged:)];
    format_floating_point_number(slider_to_readout_value(def, dataType), beforeDecimal, afterDecimal, str);
    [readout3TextField setStringValue:[NSString stringWithUTF8String:str]];
    // set text label to 9 point
    c = [readout3TextField cell];
    [c setFont:[NSFont fontWithName:[[c font] fontName] size:9]];
    [c setAlignment:NSLeftTextAlignment];
    [readout3TextField setEditable:YES];
    [readout3TextField setBezeled:YES];
    [readout3TextField setDrawsBackground:YES];
    [readout3TextField setAutoresizingMask:NSViewMinXMargin|NSViewMinYMargin];
    [self addSubview:readout3TextField];
    // create the (editable) text field for the w value of the vector
    vec = [filter valueForKey:key];
    def = [vec W];
    readout4TextField = [[NSTextField alloc] initWithFrame:r4Rect];
    [readout4TextField setTarget:self];
    [readout4TextField setAction:@selector(readout4TextFieldChanged:)];
    format_floating_point_number(slider_to_readout_value(def, dataType), beforeDecimal, afterDecimal, str);
    [readout4TextField setStringValue:[NSString stringWithUTF8String:str]];
    // set text label to 9 point
    c = [readout4TextField cell];
    [c setFont:[NSFont fontWithName:[[c font] fontName] size:9]];
    [c setAlignment:NSLeftTextAlignment];
    [readout4TextField setEditable:YES];
    [readout4TextField setBezeled:YES];
    [readout4TextField setDrawsBackground:YES];
    [readout4TextField setAutoresizingMask:NSViewMinXMargin|NSViewMinYMargin];
    [self addSubview:readout4TextField];
    // set us up for notification on change
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readout1DidChange:)
      name:NSControlTextDidChangeNotification object:readout1TextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readout2DidChange:)
      name:NSControlTextDidChangeNotification object:readout2TextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readout3DidChange:)
      name:NSControlTextDidChangeNotification object:readout3TextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readout4DidChange:)
      name:NSControlTextDidChangeNotification object:readout4TextField];
}

// this one adds 2 editable text fields for an offset CIVector
// given the filter instance pointer and the key that it's bound to
- (void)addOffsetForFilter:(CIFilter *)f key:(NSString *)k displayView:(CoreImageView *)v master:(EffectStackController *)m
{
    NSInteger left, right, tbwid;
    CGFloat def, textbox_width;
    NSRect r1Rect, r2Rect, tRect, bounds;
    NSString *label;
    NSCell *c;
    char str[32];
    CIVector *vec;
    NSDictionary *parameter;
    
    filter = [f retain];
    dict = nil;
    key = [k retain];
    displayView = [v retain];
    master = [m retain];
    bounds = [self bounds];
    tRect = NSMakeRect(0, 0, 75, 16);
    left = 80;
    right = bounds.size.width - 5;
    textbox_width = (right - left - textbox_sep*3)*0.25;
    tbwid = floor(textbox_width);
    r1Rect = NSMakeRect(left, 0, tbwid, 16);
    r2Rect = NSMakeRect(floor(left + textbox_width + textbox_sep), 0, tbwid, 16);
    beforeDecimal = 1;
    afterDecimal = 3;
    parameter = [[filter attributes] valueForKey:key];
    // create the text label for the vector
    labelTextField = [[NSTextField alloc] initWithFrame:tRect];
    label = [parameter objectForKey:kCIAttributeDisplayName];
    if (label == nil)
        label = unInterCap([key substringFromIndex:5]);
    // set text label to 9 point
    c = [labelTextField cell];
    [c setFont:[NSFont fontWithName:[[c font] fontName] size:9]];
    [c setAlignment:NSRightTextAlignment];
    // determine if we need to ellipsize the text label
    label = [ParameterView ellipsizeField:[c drawingRectForBounds:[labelTextField bounds]].size.width font:[c font] string:label];
    [labelTextField setStringValue:label];
    [labelTextField setEditable:NO];
    [labelTextField setBezeled:NO];
    [labelTextField setDrawsBackground:NO];
    [labelTextField setAutoresizingMask:NSViewMaxXMargin|NSViewMinYMargin];
    [self addSubview:labelTextField];
    // create the (editable) text field for the x value of the vector
    vec = [filter valueForKey:key];
    def = [vec X];
    readout1TextField = [[NSTextField alloc] initWithFrame:r1Rect];
    [readout1TextField setTarget:self];
    [readout1TextField setAction:@selector(readout1TextFieldChanged:)];
    format_floating_point_number(slider_to_readout_value(def, dataType), beforeDecimal, afterDecimal, str);
    [readout1TextField setStringValue:[NSString stringWithUTF8String:str]];
    // set text label to 9 point
    c = [readout1TextField cell];
    [c setFont:[NSFont fontWithName:[[c font] fontName] size:9]];
    [c setAlignment:NSLeftTextAlignment];
    [readout1TextField setEditable:YES];
    [readout1TextField setBezeled:YES];
    [readout1TextField setDrawsBackground:YES];
    [readout1TextField setAutoresizingMask:NSViewMinXMargin|NSViewMinYMargin];
    [self addSubview:readout1TextField];
    // create the (editable) text field for the y value of the vector
    vec = [filter valueForKey:key];
    def = [vec Y];
    readout2TextField = [[NSTextField alloc] initWithFrame:r2Rect];
    [readout2TextField setTarget:self];
    [readout2TextField setAction:@selector(readout2TextFieldChanged:)];
    format_floating_point_number(slider_to_readout_value(def, dataType), beforeDecimal, afterDecimal, str);
    [readout2TextField setStringValue:[NSString stringWithUTF8String:str]];
    // set text label to 9 point
    c = [readout2TextField cell];
    [c setFont:[NSFont fontWithName:[[c font] fontName] size:9]];
    [c setAlignment:NSLeftTextAlignment];
    [readout2TextField setEditable:YES];
    [readout2TextField setBezeled:YES];
    [readout2TextField setDrawsBackground:YES];
    [readout2TextField setAutoresizingMask:NSViewMinXMargin|NSViewMinYMargin];
    [self addSubview:readout2TextField];
    // set us up for notification on change
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readout1DidChange:)
      name:NSControlTextDidChangeNotification object:readout1TextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readout2DidChange:)
      name:NSControlTextDidChangeNotification object:readout2TextField];
}

// add widgets to edit the transform parameter
// these are scale, angle, stretch, and skew sliders
// note: the offset of the transform is edited as a graphic parameter, in core image view mouseDown processing
// give the filter instance and the key it's bound to
- (void)addTransformForFilter:(CIFilter *)f key:(NSString *)k displayView:(CoreImageView *)v master:(EffectStackController *)m
    {
    CGFloat scale_default, angle_default, stretch_default, skew_default, tx, ty;
    NSRect sScaleRect, tScaleRect, rScaleRect, sAngleRect, tAngleRect, rAngleRect,
      sStretchRect, tStretchRect, rStretchRect, sSkewRect, tSkewRect, rSkewRect, bounds;
    NSString *label;
    NSCell *c;
    char str[32];
    CIVector *transform;
    
    filter = [f retain];
    dict = nil;
    key = [k retain];
    displayView = [v retain];
    master = [m retain];
    bounds = [self bounds];
    // lay out the widgets
    tScaleRect = NSMakeRect(0, 51, 75, 16);
    sScaleRect = NSMakeRect(80, 51, bounds.size.width - 133, 16);
    rScaleRect = NSMakeRect(bounds.size.width - 48, 51, 43, 16);
    tAngleRect = NSMakeRect(0, 34, 75, 16);
    sAngleRect = NSMakeRect(80, 34, bounds.size.width - 133, 16);
    rAngleRect = NSMakeRect(bounds.size.width - 48, 34, 43, 16);
    tStretchRect = NSMakeRect(0, 17, 75, 16);
    sStretchRect = NSMakeRect(80, 17, bounds.size.width - 133, 16);
    rStretchRect = NSMakeRect(bounds.size.width - 48, 17, 43, 16);
    tSkewRect = NSMakeRect(0, 0, 75, 16);
    sSkewRect = NSMakeRect(80, 0, bounds.size.width - 133, 16);
    rSkewRect = NSMakeRect(bounds.size.width - 48, 0, 43, 16);
    // set up defaults by decomposing transform into 4 values
    transform = [filter valueForKey:key];
    usingNSAffineTransform = [transform isKindOfClass:[NSAffineTransform class]];
    transform_to_standard_fields(transform, &scale_default, &angle_default, &stretch_default, &skew_default, &tx, &ty);
    // create the scale slider
    scaleSlider = [[NSSlider alloc] initWithFrame:sScaleRect];
    [scaleSlider setTarget:self];
    [scaleSlider setAction:@selector(scaleSliderChanged:)];
    [[scaleSlider cell] setControlSize:NSMiniControlSize];
    [scaleSlider setAutoresizingMask:NSViewWidthSizable|NSViewMinYMargin];
    [scaleSlider setMinValue:-2.0];
    [scaleSlider setMaxValue:2.0];
    [scaleSlider setDoubleValue:log10(scale_default)];
    lastScaleFloatValue = scale_default;
    [self addSubview:scaleSlider];
    scaleDataType = stScalar;
    // create the scale label
    scaleLabelTextField = [[NSTextField alloc] initWithFrame:tScaleRect];
    label = @"Scale";
    // set text label to 9 point
    c = [scaleLabelTextField cell];
    [c setFont:[NSFont fontWithName:[[c font] fontName] size:9]];
    [c setAlignment:NSRightTextAlignment];
    [scaleLabelTextField setStringValue:label];
    [scaleLabelTextField setEditable:NO];
    [scaleLabelTextField setBezeled:NO];
    [scaleLabelTextField setDrawsBackground:NO];
    [scaleLabelTextField setAutoresizingMask:NSViewMaxXMargin|NSViewMinYMargin];
    [self addSubview:scaleLabelTextField];
    // create the scale readout
    scaleReadoutTextField = [[NSTextField alloc] initWithFrame:rScaleRect];
    [scaleReadoutTextField setTarget:self];
    [scaleReadoutTextField setAction:@selector(scaleReadoutTextFieldChanged:)];
    format_floating_point_number(slider_to_readout_value(scale_default, scaleDataType), 4, 2, str);
    [scaleReadoutTextField setStringValue:[NSString stringWithUTF8String:str]];
    // set text label to 9 point
    c = [scaleReadoutTextField cell];
    [c setFont:[NSFont fontWithName:[[c font] fontName] size:9]];
    [c setAlignment:NSLeftTextAlignment];
    [scaleReadoutTextField setEditable:YES];
    [scaleReadoutTextField setBezeled:YES];
    [scaleReadoutTextField setDrawsBackground:YES];
    [scaleReadoutTextField setAutoresizingMask:NSViewMinXMargin|NSViewMinYMargin];
    [self addSubview:scaleReadoutTextField];
    // create the angle slider
    angleSlider = [[NSSlider alloc] initWithFrame:sAngleRect];
    [angleSlider setTarget:self];
    [angleSlider setAction:@selector(angleSliderChanged:)];
    [[angleSlider cell] setControlSize:NSMiniControlSize];
    [angleSlider setAutoresizingMask:NSViewWidthSizable|NSViewMinYMargin];
    [angleSlider setMinValue:0.0];
    [angleSlider setMaxValue:2.0 * M_PI];
    [angleSlider setDoubleValue:angle_default];
    lastAngleFloatValue = angle_default;
    [self addSubview:angleSlider];
    angleDataType = stAngle;
    // create the angle label
    angleLabelTextField = [[NSTextField alloc] initWithFrame:tAngleRect];
    label = @"Angle";
    // set text label to 9 point
    c = [angleLabelTextField cell];
    [c setFont:[NSFont fontWithName:[[c font] fontName] size:9]];
    [c setAlignment:NSRightTextAlignment];
    [angleLabelTextField setStringValue:label];
    [angleLabelTextField setEditable:NO];
    [angleLabelTextField setBezeled:NO];
    [angleLabelTextField setDrawsBackground:NO];
    [angleLabelTextField setAutoresizingMask:NSViewMaxXMargin|NSViewMinYMargin];
    [self addSubview:angleLabelTextField];
    // create the angle readout
    angleReadoutTextField = [[NSTextField alloc] initWithFrame:rAngleRect];
    [angleReadoutTextField setTarget:self];
    [angleReadoutTextField setAction:@selector(angleReadoutTextFieldChanged:)];
    format_floating_point_number(slider_to_readout_value(angle_default, angleDataType), 3, 1, str);
    [angleReadoutTextField setStringValue:[NSString stringWithUTF8String:str]];
    // set text label to 9 point
    c = [angleReadoutTextField cell];
    [c setFont:[NSFont fontWithName:[[c font] fontName] size:9]];
    [c setAlignment:NSLeftTextAlignment];
    [angleReadoutTextField setEditable:YES];
    [angleReadoutTextField setBezeled:YES];
    [angleReadoutTextField setDrawsBackground:YES];
    [angleReadoutTextField setAutoresizingMask:NSViewMinXMargin|NSViewMinYMargin];
    [self addSubview:angleReadoutTextField];
    // create the stretch slider
    stretchSlider = [[NSSlider alloc] initWithFrame:sStretchRect];
    [stretchSlider setTarget:self];
    [stretchSlider setAction:@selector(stretchSliderChanged:)];
    [[stretchSlider cell] setControlSize:NSMiniControlSize];
    [stretchSlider setAutoresizingMask:NSViewWidthSizable|NSViewMinYMargin];
    [stretchSlider setMinValue:-2.0];
    [stretchSlider setMaxValue:2.0];
    [stretchSlider setDoubleValue:log10(stretch_default)];
    lastStretchFloatValue = stretch_default;
    [self addSubview:stretchSlider];
    stretchDataType = stScalar;
    // create the stretch label
    stretchLabelTextField = [[NSTextField alloc] initWithFrame:tStretchRect];
    label = @"Stretch";
    // set text label to 9 point
    c = [stretchLabelTextField cell];
    [c setFont:[NSFont fontWithName:[[c font] fontName] size:9]];
    [c setAlignment:NSRightTextAlignment];
    [stretchLabelTextField setStringValue:label];
    [stretchLabelTextField setEditable:NO];
    [stretchLabelTextField setBezeled:NO];
    [stretchLabelTextField setDrawsBackground:NO];
    [stretchLabelTextField setAutoresizingMask:NSViewMaxXMargin|NSViewMinYMargin];
    [self addSubview:stretchLabelTextField];
    // create the stretch readout
    stretchReadoutTextField = [[NSTextField alloc] initWithFrame:rStretchRect];
    [stretchReadoutTextField setTarget:self];
    [stretchReadoutTextField setAction:@selector(stretchReadoutTextFieldChanged:)];
    format_floating_point_number(slider_to_readout_value(stretch_default, stretchDataType), 4, 2, str);
    [stretchReadoutTextField setStringValue:[NSString stringWithUTF8String:str]];
    // set text label to 9 point
    c = [stretchReadoutTextField cell];
    [c setFont:[NSFont fontWithName:[[c font] fontName] size:9]];
    [c setAlignment:NSLeftTextAlignment];
    [stretchReadoutTextField setEditable:YES];
    [stretchReadoutTextField setBezeled:YES];
    [stretchReadoutTextField setDrawsBackground:YES];
    [stretchReadoutTextField setAutoresizingMask:NSViewMinXMargin|NSViewMinYMargin];
    [self addSubview:stretchReadoutTextField];
    // create the skew slider
    skewSlider = [[NSSlider alloc] initWithFrame:sSkewRect];
    [skewSlider setTarget:self];
    [skewSlider setAction:@selector(skewSliderChanged:)];
    [[skewSlider cell] setControlSize:NSMiniControlSize];
    [skewSlider setAutoresizingMask:NSViewWidthSizable|NSViewMinYMargin];
    [skewSlider setMinValue:-10.0];
    [skewSlider setMaxValue:10.0];
    [skewSlider setDoubleValue:skew_default];
    lastSkewFloatValue = skew_default;
    [self addSubview:skewSlider];
    skewDataType = stScalar;
    // create the skew label
    skewLabelTextField = [[NSTextField alloc] initWithFrame:tSkewRect];
    label = @"Skew";
    // set text label to 9 point
    c = [skewLabelTextField cell];
    [c setFont:[NSFont fontWithName:[[c font] fontName] size:9]];
    [c setAlignment:NSRightTextAlignment];
    [skewLabelTextField setStringValue:label];
    [skewLabelTextField setEditable:NO];
    [skewLabelTextField setBezeled:NO];
    [skewLabelTextField setDrawsBackground:NO];
    [skewLabelTextField setAutoresizingMask:NSViewMaxXMargin|NSViewMinYMargin];
    [self addSubview:skewLabelTextField];
    // create the skew readout
    skewReadoutTextField = [[NSTextField alloc] initWithFrame:rSkewRect];
    [skewReadoutTextField setTarget:self];
    [skewReadoutTextField setAction:@selector(skewReadoutTextFieldChanged:)];
    format_floating_point_number(slider_to_readout_value(skew_default, skewDataType), 4, 2, str);
    [skewReadoutTextField setStringValue:[NSString stringWithUTF8String:str]];
    // set text label to 9 point
    c = [skewReadoutTextField cell];
    [c setFont:[NSFont fontWithName:[[c font] fontName] size:9]];
    [c setAlignment:NSLeftTextAlignment];
    [skewReadoutTextField setEditable:YES];
    [skewReadoutTextField setBezeled:YES];
    [skewReadoutTextField setDrawsBackground:YES];
    [skewReadoutTextField setAutoresizingMask:NSViewMinXMargin|NSViewMinYMargin];
    [self addSubview:skewReadoutTextField];
    }

// convert a CIImage to an NSImage, so that a core image result can be drawn in an image view
// as you can see, with the proper AppKit glue, there's not much to it
- (NSImage *)CIImageToNSImage:(CIImage *)im usingRect:(CGRect)r
{
    NSImage *image;
    NSCIImageRep *ir;
    
    ir = [NSCIImageRep imageRepWithCIImage:im];
    image = [[NSImage allocWithZone:[self zone]] initWithSize:NSMakeSize(r.size.width, r.size.height)];
    [image addRepresentation:ir];
    return [image autorelease];
}

// add an image well for an image parameter
// given the filter instance and the key it's bound to
- (void)addImageWellForFilter:(CIFilter *)f key:(NSString *)k displayView:(CoreImageView *)v master:(EffectStackController *)m
{
    NSRect cRect, tRect, pbRect;
    NSString *label;
    NSCell *c;
    NSDictionary *parameter;
    CIImage *im;
    
    filter = [f retain];
    dict = nil;
    key = [k retain];
    displayView = [v retain];
    master = [m retain];
    cRect = NSMakeRect(80, 0, 48, 44);
    tRect = NSMakeRect(0, 10, 75, 16);
    pbRect = NSMakeRect(135, 13, 75, 16);
    // add the image view
    imageView = [[FunHouseImageView alloc] initWithFrame:cRect];
    [imageView setTarget:self];
    [imageView setAction:@selector(imageWellChanged:)];
    [imageView setImageFrameStyle:NSImageFrameGrayBezel];
    [imageView setEditable:YES];
    [imageView setImageScaling:NSScaleProportionally];
    parameter = [[filter attributes] valueForKey:key];
    im = [filter valueForKey:key];
    // create the thumbnail for the image
    if (im != nil)
    {
        CGSize size;
        CGFloat xscale, yscale, newHeight, newWidth;
        CIFilter *f;
        NSAffineTransform *t;
        NSImage *image;
        
        size = [im extent].size;
        if (size.width > size.height)
        {
            // width will be 64, what will height be?
            newWidth = 64.0;
            xscale = newWidth / size.width;
            newHeight = round(xscale * size.height);
            if (newHeight < 1.0)
                newHeight = 1.0;
            yscale = newHeight / size.height;
        }
        else
        {
            // height will be 64, what will width be?
            newHeight = 64.0;
            yscale = newHeight / size.height;
            newWidth = round(yscale * size.width);
            if (newWidth < 1.0)
                newWidth = 1.0;
            xscale = newWidth / size.width;
        }
        // transform image down to scale of thumbnail
        f = [CIFilter filterWithName:@"CIAffineTransform"];
        t = [NSAffineTransform transform];
        [t scaleXBy:xscale yBy:yscale];
        [f setValue:t forKey:@"inputTransform"];
        [f setValue:im forKey:@"inputImage"];
        im = [f valueForKey:@"outputImage"];
        // make it into an NSImage
        image = [self CIImageToNSImage:im usingRect:CGRectMake(0, 0, newWidth, newHeight)];
        [imageView setImage:image];
        // associate the original file path with the image view for drag and drop (out of the image view)
        [imageView setFilePath:[master imageFilePathForFilterLayer:filter key:key]];
    }
    [imageView setAutoresizingMask:NSViewWidthSizable|NSViewMinXMargin|NSViewMinYMargin];
    [self addSubview:imageView];
    // create the text label
    labelTextField = [[NSTextField alloc] initWithFrame:tRect];
    label = [parameter objectForKey:kCIAttributeDisplayName];
    if (label == nil)
        label = unInterCap([key substringFromIndex:5]);
    // set text label to 9 point
    c = [labelTextField cell];
    [c setFont:[NSFont fontWithName:[[c font] fontName] size:9]];
    [c setAlignment:NSRightTextAlignment];
    label = [ParameterView ellipsizeField:[c drawingRectForBounds:[labelTextField bounds]].size.width font:[c font] string:label];
    [labelTextField setStringValue:label];
    [labelTextField setEditable:NO];
    [labelTextField setBezeled:NO];
    [labelTextField setDrawsBackground:NO];
    [labelTextField setAutoresizingMask:NSViewMaxXMargin|NSViewMinYMargin];
    [self addSubview:labelTextField];
    // create the push button that allows us to change the image after the fact
    pushButton = [[NSButton alloc] initWithFrame:pbRect];
    [pushButton setTarget:self];
    [pushButton setAction:@selector(pushButtonChanged:)];
    [pushButton setAutoresizingMask:NSViewWidthSizable|NSViewMinXMargin|NSViewMinYMargin];
    [pushButton setBordered:YES];
    [pushButton setEnabled:YES];
    [pushButton setButtonType:NSMomentaryPushInButton];
    [pushButton setBezelStyle:NSRoundedBezelStyle];
    [pushButton setTitle:@"Choose"];
    [pushButton setImagePosition:NSNoImage];
    [[pushButton cell] setControlSize:NSMiniControlSize];
    [self addSubview:pushButton];
}    

// add an image well for an image layer. the tag tells us the layer index within the effect stack
- (void)addImageWellForImage:(CIImage *)im tag:(NSInteger)tag displayView:(CoreImageView *)v master:(EffectStackController *)m
{
    NSRect cRect, pbRect;
    
    filter = nil;
    dict = nil;
    key = nil;
    displayView = [v retain];
    master = [m retain];
    cRect = NSMakeRect(80, 0, 48, 44);
    pbRect = NSMakeRect(135, 13, 75, 16);
    // create the image view
    imageView = [[FunHouseImageView alloc] initWithFrame:cRect];
    [imageView setTarget:self];
    [imageView setAction:@selector(imageLayerImageWellChanged:)];
    [imageView setImageFrameStyle:NSImageFrameGrayBezel];
    [imageView setEditable:YES];
    [imageView setTag:tag];
    // create the thumbnail for the image
    if (im != nil)
    {
        CGSize size;
        CGFloat xscale, yscale, newHeight, newWidth;
        CIFilter *f;
        NSAffineTransform *t;
        NSImage *image;
        
        size = [im extent].size;
        if (size.width > size.height)
        {
            // width will be 64, what will height be?
            newWidth = 64.0;
            xscale = newWidth / size.width;
            newHeight = round(xscale * size.height);
            if (newHeight < 1.0)
                newHeight = 1.0;
            yscale = newHeight / size.height;
        }
        else
        {
            // height will be 64, what will width be?
            newHeight = 64.0;
            yscale = newHeight / size.height;
            newWidth = round(yscale * size.width);
            if (newWidth < 1.0)
                newWidth = 1.0;
            xscale = newWidth / size.width;
        }
        // transform image down to scale of thumbnail
        f = [CIFilter filterWithName:@"CIAffineTransform"];
        t = [NSAffineTransform transform];
        [t scaleXBy:xscale yBy:yscale];
        [f setValue:t forKey:@"inputTransform"];
        [f setValue:im forKey:@"inputImage"];
        im = [f valueForKey:@"outputImage"];
        // make it into an NSImage
        image = [self CIImageToNSImage:im usingRect:CGRectMake(0, 0, newWidth, newHeight)];
        [imageView setImage:image];
        // associate the original file path with the image view for drag and drop (out of the image view)
        [imageView setFilePath:[master imageFilePathForImageLayer:tag]];
    }
    [imageView setAutoresizingMask:NSViewWidthSizable|NSViewMinXMargin|NSViewMinYMargin];
    [self addSubview:imageView];
    // create the push button that allows us to choose a new image (we can also drag into the well)
    pushButton = [[NSButton alloc] initWithFrame:pbRect];
    [pushButton setTarget:self];
    [pushButton setAction:@selector(imageLayerPushButtonChanged:)];
    [pushButton setAutoresizingMask:NSViewWidthSizable|NSViewMinXMargin|NSViewMinYMargin];
    [pushButton setBordered:YES];
    [pushButton setEnabled:YES];
    [pushButton setButtonType:NSMomentaryPushInButton];
    [pushButton setBezelStyle:NSRoundedBezelStyle];
    [pushButton setTitle:@"Choose"];
    [pushButton setImagePosition:NSNoImage];
    [pushButton setTag:tag];
    [[pushButton cell] setControlSize:NSMiniControlSize];
    [self addSubview:pushButton];
}    

// add a text view and initialize it to the properties coming from a dictionary
- (void)addTextViewForString:(NSMutableDictionary *)d key:(NSString *)k displayView:(CoreImageView *)v master:(EffectStackController *)m
{
    NSRect bounds, tRect;
    NSTextStorage *ts;
    NSScrollView *scrollView;
    
    filter = nil;
    dict = [d retain];
    key = [k retain];
    displayView = [v retain];
    master = [m retain];
    bounds = [self bounds];
    tRect = NSInsetRect(bounds, 6.0, 6.0);
    tRect.size.width -= 14;
    // create the scroll view
    scrollView = [[NSScrollView allocWithZone:[self zone]] initWithFrame:tRect];
    [scrollView setBorderType:NSBezelBorder];
    [scrollView setAutohidesScrollers:YES];
    [scrollView setHasVerticalScroller:YES];
    [scrollView setHasHorizontalScroller:NO];
    [scrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    [[scrollView verticalScroller] setControlSize:NSSmallControlSize];
    [[scrollView contentView] setAutoresizesSubviews:YES];
    [self addSubview:scrollView];
    [scrollView release];
    // Set frame for content area of scroll view
    tRect.origin = NSMakePoint(0.0, 0.0);
    tRect.size = [scrollView contentSize];
    // create the text view and pop it into the scroll view
    textView = [[NSTextView allocWithZone:[self zone]] initWithFrame:tRect];
    // set up the properties for the text from the dictionary
    if ([d valueForKey:@"font"] != nil)
    {
        [textView setFont:[NSFont fontWithName:[d valueForKey:@"font"] size:[[d valueForKey:@"pointSize"] doubleValue]]];
        [textView setTextColor:[NSColor colorWithCalibratedRed:[[d valueForKey:@"colorRed"] doubleValue]
          green:[[d valueForKey:@"colorGreen"] doubleValue] blue:[[d valueForKey:@"colorBlue"] doubleValue]
          alpha:[[d valueForKey:@"colorAlpha"] doubleValue]]];
    }
    [textView setDelegate:self];
    [textView setMinSize:tRect.size];
    [textView setMaxSize:NSMakeSize(1000.0, 1000.0)];
    [textView setHorizontallyResizable:NO];
    [textView setVerticallyResizable:YES];
    [textView setAutoresizingMask:NSViewWidthSizable];
    [textView setSelectable:YES];
    [textView setEditable:YES];
    [textView setRichText:NO];
    [textView setImportsGraphics:NO];
    [textView setUsesFontPanel:YES];
    [textView setUsesRuler:NO];
    [textView setString:[d valueForKey:@"string"]];
    [textView setSelectedRange:NSMakeRange(0, 6)];
    [scrollView setDocumentView:textView];
    [textView release];
    // retain the text storage from the text view in the dictionary
    ts = [textView textStorage];
    [d setValue:ts forKey:@"textStorage"];
    [self recomputeTextImage:ts];
}

// add a scale slider for a text layer
- (void)addSliderForText:(NSMutableDictionary *)d key:(NSString *)k lo:(CGFloat)lo hi:(CGFloat)hi displayView:(CoreImageView *)v master:(EffectStackController *)m
{
    CGFloat def;
    NSRect sRect, tRect, rRect, bounds;
    NSString *label;
    NSCell *c;
    char str[32];
    
    filter = nil;
    dict = [d retain];
    key = [k retain];
    displayView = [v retain];
    master = [m retain];
    bounds = [self bounds];
    tRect = NSMakeRect(0, 0, kSliderLabelWidth, kSliderHeight);
    sRect = NSMakeRect(kSliderLabelWidth + kSliderGap, 0, bounds.size.width - 3*kSliderGap
	    - kSliderLabelWidth - kSliderValueWidth, kSliderHeight);
    rRect = NSMakeRect(bounds.size.width - kSliderValueWidth - kSliderGap, 0, kSliderValueWidth, kSliderHeight);
    // create the scale slider
    slider = [[NSSlider alloc] initWithFrame:sRect];
    [slider setTarget:self];
    [slider setAction:@selector(textSliderChanged:)];
    [[slider cell] setControlSize:NSMiniControlSize];
    [slider setAutoresizingMask:NSViewWidthSizable|NSViewMinYMargin];
    [slider setMaxValue:hi];
    [slider setMinValue:lo];
    def = [[d valueForKey:key] doubleValue];
    [slider setDoubleValue:def];
    lastFloatValue = def;
    [self addSubview:slider];
    dataType = stScalar;
    // add the text label
    labelTextField = [[NSTextField alloc] initWithFrame:tRect];
    label = unInterCap(key);
    // set text label to 9 point
    c = [labelTextField cell];
    [c setFont:[NSFont fontWithName:[[c font] fontName] size:9]];
    [c setAlignment:NSRightTextAlignment];
    label = [ParameterView ellipsizeField:[c drawingRectForBounds:[labelTextField bounds]].size.width font:[c font] string:label];
    [labelTextField setStringValue:label];
    [labelTextField setEditable:NO];
    [labelTextField setBezeled:NO];
    [labelTextField setDrawsBackground:NO];
    [labelTextField setAutoresizingMask:NSViewMaxXMargin|NSViewMinYMargin];
    [self addSubview:labelTextField];
    // add the (editable) text readout field
    beforeDecimal = 4;
    afterDecimal = 2;
    readoutTextField = [[NSTextField alloc] initWithFrame:rRect];
    [readoutTextField setTarget:self];
    [readoutTextField setAction:@selector(textReadoutTextFieldChanged:)];
    format_floating_point_number(slider_to_readout_value(def, dataType), beforeDecimal, afterDecimal, str);
    [readoutTextField setStringValue:[NSString stringWithUTF8String:str]];
    // set text label to 9 point
    c = [readoutTextField cell];
    [c setFont:[NSFont fontWithName:[[c font] fontName] size:9]];
    [c setAlignment:NSLeftTextAlignment];
    [readoutTextField setEditable:YES];
    [readoutTextField setDrawsBackground:YES];
    [[readoutTextField cell] setControlSize:NSSmallControlSize];
    [readoutTextField setAutoresizingMask:NSViewMinXMargin|NSViewMinYMargin];
    [self addSubview:readoutTextField];
}

@end

// we subclass NSImageView so we can get the file path of the image the user drags into the image view

@implementation FunHouseImageView

// useful for image views set up explicitly
- (void)setFilePath:(NSString *)path
{
    _filePath = [path copy];
}

// return the file path we have retained
- (NSString *)filePath
{
    return _filePath;
}

// at the end of a drag operation (of an image into this image view) we interrogate the dragging pasteboard
// and pull out the filename of the image being dragged
- (void)concludeDragOperation:(id<NSDraggingInfo>)sender
{
    NSPasteboard *pboard;
    NSArray *files;
    
    pboard = [sender draggingPasteboard];
    [_filePath release];
    _filePath = nil;
    if ([pboard availableTypeFromArray:[NSArray arrayWithObject:NSFilenamesPboardType]])
    {
        files = [pboard propertyListForType:NSFilenamesPboardType];
        if ([files count] > 0)
            _filePath = [[files objectAtIndex:0] copy];
    }
    [super concludeDragOperation:sender];
}

- (NSUInteger)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
    return NSDragOperationCopy;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSImage *dragImage;
    NSPoint dragPosition;
    NSArray *fileList;
    NSPasteboard *pboard;

    // write data to the pasteboard
    fileList = [NSArray arrayWithObjects:[self filePath], nil];
    pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
    [pboard declareTypes:[NSArray arrayWithObject:NSFilenamesPboardType] owner:nil];
    [pboard setPropertyList:fileList forType:NSFilenamesPboardType];
    // start the drag operation
    dragImage = [[NSWorkspace sharedWorkspace] iconForFile:[self filePath]];
    dragPosition = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    dragPosition.x -= 16;
    dragPosition.y -= 16;
    [self dragImage:dragImage at:dragPosition offset:NSZeroSize event:theEvent
      pasteboard:pboard source:self slideBack:YES];
}

@end
