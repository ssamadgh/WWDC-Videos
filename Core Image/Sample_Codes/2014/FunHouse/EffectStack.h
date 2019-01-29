/*
     File: EffectStack.h
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

@class CoreImageView;

@interface EffectStack : NSView
{
    CIImage *baseImage;         // a pointer to the base image in the array (generally layers[0].image
    NSMutableArray *layers;     // effect stack filter, image, text layers in an array
}

// designated init routine
- (id)init;
// effect stack layer operationsd
- (void)insertFilterLayer:(CIFilter *)filter atIndex:(NSInteger)index;
- (void)insertImageLayer:(CIImage *)image withFilename:(NSString *)filename atIndex:(NSInteger)index;
- (void)insertTextLayer:(NSString *)string withImage:(CIImage *)image atIndex:(NSInteger)index;
- (void)removeLayerAtIndex:(NSInteger)index;
- (void)removeAllLayers;
// getters
- (NSInteger)layerCount;
- (BOOL)layerEnabled:(NSInteger)index;
- (NSString *)typeAtIndex:(NSInteger)index;
- (CIFilter *)filterAtIndex:(NSInteger)index;
- (CIImage *)imageAtIndex:(NSInteger)index;
- (NSPoint)offsetAtIndex:(NSInteger)index;
- (NSString *)filenameAtIndex:(NSInteger)index;
- (NSString *)imageFilePathAtIndex:(NSInteger)index;
- (NSData *)imageFileDataAtIndex:(NSInteger)index;
- (NSString *)stringAtIndex:(NSInteger)index;
- (NSMutableDictionary *)mutableDictionaryAtIndex:(NSInteger)index;
- (CIImage *)baseImage;
- (NSString *)filterLayer:(NSInteger)index imageFilePathValueForKey:(NSString *)key;
- (NSData *)filterLayer:(NSInteger)index imageFileDataValueForKey:(NSString *)key;
// setters
- (void)setLayer:(NSInteger)index enabled:(BOOL)enabled;
- (void)setBaseImage:(CIImage *)image withFilename:(NSString *)filename andImageFilePath:(NSString *)path;
- (void)setFilterLayer:(NSInteger)index imageFilePathValue:(NSString *)path forKey:(NSString *)key;
- (void)setImageLayer:(NSInteger)index offset:(NSPoint)offset;
- (void)setImageLayer:(NSInteger)index image:(CIImage *)image andFilename:(NSString *)filename;
- (void)setImageLayer:(NSInteger)index imageFilePath:(NSString *)path;
- (void)setTextLayer:(NSInteger)index offset:(NSPoint)offset;
- (void)setTextLayer:(NSInteger)index string:(NSString *)string andImage:(CIImage *)image;
// for core image result graph from stack
- (CIImage *)coreImageResultForRect:(NSRect)bounds;
// convenience methods for preventing exceptions during evaluation and for reddening a box (alarm)
- (BOOL)filterHasMissingImage:(CIFilter *)f;
- (BOOL)hasMissingImage;
// for preset encoding
- (void)encodeValue:(id)obj forKey:(NSString *)key intoDictionary:(NSMutableDictionary *)v;
- (id)decodedValueForKey:(NSString *)key ofClass:(NSString *)classname fromDictionary:(NSDictionary *)v;
@end
