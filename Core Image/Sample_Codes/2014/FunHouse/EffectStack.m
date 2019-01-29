/*
     File: EffectStack.m
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

#import "EffectStack.h"
#import "CoreImageView.h"

@implementation EffectStack

- (id)init
{
    self = [super init];
    if (self)
    {
        layers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [baseImage release];
    [layers release];
    [super dealloc];
}

// insert a filter layer into the layers array
- (void)insertFilterLayer:(CIFilter *)filter atIndex:(NSInteger)index
{
    NSMutableDictionary *d;
    
    d = [NSMutableDictionary dictionaryWithCapacity:2];
    [d setValue:@"filter" forKey:@"type"];
    [d setValue:filter forKey:@"filter"];
    [d setValue:[NSNumber numberWithBool:YES] forKey:@"enabled"];
    [layers insertObject:d atIndex:index];
}

// insert an image layer into the layers array
- (void)insertImageLayer:(CIImage *)image withFilename:(NSString *)filename atIndex:(NSInteger)index
{
    NSMutableDictionary *d;
    
    d = [NSMutableDictionary dictionaryWithCapacity:2];
    [d setValue:@"image" forKey:@"type"];
    [d setValue:image forKey:@"image"];
    [d setValue:[NSNumber numberWithDouble:0.0] forKey:@"offsetX"];
    [d setValue:[NSNumber numberWithDouble:0.0] forKey:@"offsetY"];
    [d setValue:[NSNumber numberWithBool:YES] forKey:@"enabled"];
    [d setValue:filename forKey:@"filename"];
    [layers insertObject:d atIndex:index];
}

// insert a text layer into the layers array
- (void)insertTextLayer:(NSString *)string withImage:(CIImage *)image atIndex:(NSInteger)index
{
    NSMutableDictionary *d;
    
    d = [NSMutableDictionary dictionaryWithCapacity:2];
    [d setValue:@"text" forKey:@"type"];
    [d setValue:image forKey:@"image"];
    [d setValue:string forKey:@"string"];
    [d setValue:[NSNumber numberWithDouble:1.0] forKey:@"scale"];
    [d setValue:[NSNumber numberWithDouble:0.0] forKey:@"offsetX"];
    [d setValue:[NSNumber numberWithDouble:0.0] forKey:@"offsetY"];
    [d setValue:[NSNumber numberWithBool:YES] forKey:@"enabled"];
    [layers insertObject:d atIndex:index];
}

// remove an element from the layers array
- (void)removeLayerAtIndex:(NSInteger)index
{
    [layers removeObjectAtIndex:index];
}

// remove all elements from the layers array
- (void)removeAllLayers
{
    [layers removeAllObjects];
}

// return the number of elements in the layers array
- (NSInteger)layerCount
{
    return [layers count];
}

// getter: layers[index].enabled
- (BOOL)layerEnabled:(NSInteger)index
{
    NSMutableDictionary *d;
    
    if (index < 0 || index >= [self layerCount])
    {
        printf("index %d is out of range (%d layers in model)\n", (int)index, (int)[self layerCount]);
        return NO;
    }
    d = [layers objectAtIndex:index];
    return [[d valueForKey:@"enabled"] boolValue];
}

// getter: layers[index].type
- (NSString *)typeAtIndex:(NSInteger)index
{
    NSMutableDictionary *d;
    
    if (index < 0 || index >= [self layerCount])
    {
        printf("index %d is out of range (%d layers in model)\n", (int)index, (int)[self layerCount]);
        return nil;
    }
    d = [layers objectAtIndex:index];
    return [d valueForKey:@"type"];
}

// getter: layers[index].filter
- (CIFilter *)filterAtIndex:(NSInteger)index
{
    NSMutableDictionary *d;
    
    if (index < 0 || index >= [self layerCount])
    {
        printf("index %d is out of range (%d layers in model)\n", (int)index, (int)[self layerCount]);
        return nil;
    }
    d = [layers objectAtIndex:index];
    if (![[d valueForKey:@"type"] isEqualToString:@"filter"])
        return nil;
    return [d valueForKey:@"filter"];
}

// getter: layers[index].image
- (CIImage *)imageAtIndex:(NSInteger)index
{
    NSMutableDictionary *d;
    
    if (index < 0 || index >= [self layerCount])
    {
        printf("index %d is out of range (%d layers in model)\n", (int)index, (int)[self layerCount]);
        return nil;
    }
    d = [layers objectAtIndex:index];
    if (![[d valueForKey:@"type"] isEqualToString:@"image"] && ![[d valueForKey:@"type"] isEqualToString:@"text"])
        return nil;
    return [d valueForKey:@"image"];
}

// getter: layers[index].offset
- (NSPoint)offsetAtIndex:(NSInteger)index
{
    NSMutableDictionary *d;
    
    if (index < 0 || index >= [self layerCount])
    {
        printf("index %d is out of range (%d layers in model)\n", (int)index, (int)[self layerCount]);
        return NSMakePoint(0.0, 0.0);
    }
    d = [layers objectAtIndex:index];
    if (![[d valueForKey:@"type"] isEqualToString:@"image"] && ![[d valueForKey:@"type"] isEqualToString:@"text"])
        return NSMakePoint(0.0, 0.0);
    return NSMakePoint([[d valueForKey:@"offsetX"] doubleValue], [[d valueForKey:@"offsetY"] doubleValue]);
}

// getter: layers[index].filename
- (NSString *)filenameAtIndex:(NSInteger)index
{
    NSMutableDictionary *d;
    
    if (index < 0 || index >= [self layerCount])
    {
        printf("index %d is out of range (%d layers in model)\n", (int)index, (int)[self layerCount]);
        return nil;
    }
    d = [layers objectAtIndex:index];
    if (![[d valueForKey:@"type"] isEqualToString:@"image"])
        return nil;
    return [d valueForKey:@"filename"];
}

// getter: layers[index].imageFilePath
- (NSString *)imageFilePathAtIndex:(NSInteger)index
{
    NSMutableDictionary *d;
    
    if (index < 0 || index >= [self layerCount])
    {
        printf("index %d is out of range (%d layers in model)\n", (int)index, (int)[self layerCount]);
        return nil;
    }
    d = [layers objectAtIndex:index];
    if (![[d valueForKey:@"type"] isEqualToString:@"image"])
        return nil;
    return [d valueForKey:@"imageFilePath"];
}

// getter: layers[index].imageFileData
- (NSData *)imageFileDataAtIndex:(NSInteger)index
{
    NSMutableDictionary *d;
    
    if (index < 0 || index >= [self layerCount])
    {
        printf("index %d is out of range (%d layers in model)\n", (int)index, (int)[self layerCount]);
        return nil;
    }
    d = [layers objectAtIndex:index];
    if (![[d valueForKey:@"type"] isEqualToString:@"image"])
        return nil;
    return [d valueForKey:@"imageFileData"];
}

// getter: layers[index].string
- (NSString *)stringAtIndex:(NSInteger)index
{
    NSMutableDictionary *d;
    
    if (index < 0 || index >= [self layerCount])
    {
        printf("index %d is out of range (%d layers in model)\n", (int)index, (int)[self layerCount]);
        return nil;
    }
    d = [layers objectAtIndex:index];
    if (![[d valueForKey:@"type"] isEqualToString:@"text"])
        return nil;
    return [d valueForKey:@"string"];
}

// getter: layers[index] - used for text case where there are way too many to access otherwise
- (NSMutableDictionary *)mutableDictionaryAtIndex:(NSInteger)index
{
    if (index < 0 || index >= [self layerCount])
    {
        printf("index %d is out of range (%d layers in model)\n", (int)index, (int)[self layerCount]);
        return nil;
    }
    return [layers objectAtIndex:index];
}

// getter: layers[0].image
- (CIImage *)baseImage
{
    if ([[self typeAtIndex:0] isEqualToString:@"image"])
        return [self imageAtIndex:0];
    return nil;
}

// getter: [layers[0].imageFilePaths valueForKey:key].path
- (NSString *)filterLayer:(NSInteger)index imageFilePathValueForKey:(NSString *)key
{
    NSMutableDictionary *d;
    
    if (index < 0 || index >= [self layerCount])
    {
        printf("index %d is out of range (%d layers in model)\n", (int)index, (int)[self layerCount]);
        return nil;
    }
    d = [layers objectAtIndex:index];
    if (![[d valueForKey:@"type"] isEqualToString:@"filter"])
        return nil;
    d = [d valueForKey:@"imageFilePaths"];
    if (d == nil)
        return nil;
    return [[d valueForKey:key] valueForKey:@"path"];
}

// getter: [layers[0].imageFilePaths valueForKey:key].data
- (NSData *)filterLayer:(NSInteger)index imageFileDataValueForKey:(NSString *)key
{
    NSMutableDictionary *d;
    
    if (index < 0 || index >= [self layerCount])
    {
        printf("index %d is out of range (%d layers in model)\n", (int)index, (int)[self layerCount]);
        return nil;
    }
    d = [layers objectAtIndex:index];
    if (![[d valueForKey:@"type"] isEqualToString:@"filter"])
        return nil;
    d = [d valueForKey:@"imageFilePaths"];
    if (d == nil)
        return nil;
    return [[d valueForKey:key] valueForKey:@"data"];
}

// setter: [layers[index].imageFilePaths setValue:path forKey:key]
- (void)setFilterLayer:(NSInteger)index imageFilePathValue:(NSString *)path forKey:(NSString *)key
{
    NSMutableDictionary *d, *d2, *d3;
    
    if (index < 0 || index >= [self layerCount])
    {
        printf("index %d is out of range (%d layers in model)\n", (int)index, (int)[self layerCount]);
        return;
    }
    d = [layers objectAtIndex:index];
    if ([[d valueForKey:@"type"] isEqualToString:@"filter"])
    {
        d2 = [d valueForKey:@"imageFilePaths"];
        if (d2 == nil)
        {
            d2 = [NSMutableDictionary dictionary];
            [d setValue:d2 forKey:@"imageFilePaths"];
        }
        d3 = [NSMutableDictionary dictionary];
        [d3 setValue:path forKey:@"path"];
        // keep image file data around too!
        [d3 setValue:[NSData dataWithContentsOfMappedFile:path] forKey:@"data"];
        [d2 setValue:d3 forKey:key];
    }
}

// setter: layers[index].enabled
- (void)setLayer:(NSInteger)index enabled:(BOOL)enabled
{
    NSMutableDictionary *d;
    
    if (index < 0 || index >= [self layerCount])
    {
        printf("index %d is out of range (%d layers in model)\n", (int)index, (int)[self layerCount]);
        return;
    }
    d = [layers objectAtIndex:index];
    [d setValue:[NSNumber numberWithBool:enabled] forKey:@"enabled"];
}

// setter: layers[index].offset
- (void)setImageLayer:(NSInteger)index offset:(NSPoint)offset
{
    NSMutableDictionary *d;
    
    if (index < 0 || index >= [self layerCount])
    {
        printf("index %d is out of range (%d layers in model)\n", (int)index, (int)[self layerCount]);
        return;
    }
    d = [layers objectAtIndex:index];
    if ([[d valueForKey:@"type"] isEqualToString:@"image"])
    {
        [d setValue:[NSNumber numberWithDouble:offset.x] forKey:@"offsetX"];
        [d setValue:[NSNumber numberWithDouble:offset.y] forKey:@"offsetY"];
    }
}

// setter: layers[index].imageFilePath
- (void)setImageLayer:(NSInteger)index imageFilePath:(NSString *)path
{
    NSMutableDictionary *d;
    
    if (index < 0 || index >= [self layerCount])
    {
        printf("index %d is out of range (%d layers in model)\n", (int)index, (int)[self layerCount]);
        return;
    }
    d = [layers objectAtIndex:index];
    if ([[d valueForKey:@"type"] isEqualToString:@"image"])
    {
        [d setValue:path forKey:@"imageFilePath"];
        // keep image file data around too!
        [d setValue:[NSData dataWithContentsOfMappedFile:path] forKey:@"imageFileData"];
    }
}

// setter: layers[index].offset
- (void)setTextLayer:(NSInteger)index offset:(NSPoint)offset
{
    NSMutableDictionary *d;
    
    if (index < 0 || index >= [self layerCount])
    {
        printf("index %d is out of range (%d layers in model)\n", (int)index, (int)[self layerCount]);
        return;
    }
    d = [layers objectAtIndex:index];
    if ([[d valueForKey:@"type"] isEqualToString:@"text"])
    {
        [d setValue:[NSNumber numberWithDouble:offset.x] forKey:@"offsetX"];
        [d setValue:[NSNumber numberWithDouble:offset.y] forKey:@"offsetY"];
    }
}

// setter: layers[index].image/filename
- (void)setImageLayer:(NSInteger)index image:(CIImage *)image andFilename:(NSString *)filename
{
    NSMutableDictionary *d;
    
    if (index < 0 || index >= [self layerCount])
    {
        printf("index %d is out of range (%d layers in model)\n", (int)index, (int)[self layerCount]);
        return;
    }
    d = [layers objectAtIndex:index];
    if ([[d valueForKey:@"type"] isEqualToString:@"image"])
    {
        [d setValue:image forKey:@"image"];
        [d setValue:filename forKey:@"filename"];
    }
}

// setter: layers[index].string/image
- (void)setTextLayer:(NSInteger)index string:(NSString *)string andImage:(CIImage *)image
{
    NSMutableDictionary *d;
    
    if (index < 0 || index >= [self layerCount])
    {
        printf("index %d is out of range (%d layers in model)\n", (int)index, (int)[self layerCount]);
        return;
    }
    d = [layers objectAtIndex:index];
    if ([[d valueForKey:@"type"] isEqualToString:@"text"])
    {
        [d setValue:image forKey:@"image"];
        [d setValue:string forKey:@"string"];
    }
}

// setter: layers[0].image/filename and image/path
- (void)setBaseImage:(CIImage *)image withFilename:(NSString *)filename andImageFilePath:(NSString *)path
{
    NSMutableDictionary *d;
    
    if ([self layerCount] > 0 && [[self typeAtIndex:0] isEqualToString:@"image"])
    {
        d = [layers objectAtIndex:0];
        [d setValue:image forKey:@"image"];
        [d setValue:filename forKey:@"filename"];
        [d setValue:path forKey:@"imageFilePath"];
    }
    else if ([self layerCount] == 0)
    {
        [self insertImageLayer:image withFilename:filename atIndex:0];
        d = [layers objectAtIndex:0];
        [d setValue:path forKey:@"imageFilePath"];
        // keep image file data around too!
        [d setValue:[NSData dataWithContentsOfMappedFile:path] forKey:@"imageFileData"];
    }
    else
        printf("attempted setBaseImage with non-empty effect stack\n");
}

// return the core image graph for the effect stack (constrained to the rectangle)
- (CIImage *)coreImageResultForRect:(NSRect)bounds
{
    BOOL usesExtent, usesImage, hasBackground;
    NSInteger i, count;
    CIFilter *f;
    CIImage  *result;
    NSDictionary *attr;
    NSArray *inputKeys;
    NSString *key, *classstring, *type;
    NSEnumerator *enumerator;
    NSMutableArray *resultstack;
    
    resultstack = [NSMutableArray arrayWithCapacity:10];
    // get result of filter running over image
    count = [self layerCount];
    result = nil;
    for (i = 0; i < count; i++)
    {
        if (![self layerEnabled:i])
            continue;
        type = [self typeAtIndex:i];
        if ([type isEqualToString:@"filter"])
        {
            // filter layer
            f = [self filterAtIndex:i];
            if (f == nil)
                continue;
            usesExtent = NO;
            usesImage = NO;
            hasBackground = NO;
            attr = [f attributes];
            inputKeys = [f inputKeys];
            // scan the input parameters for various cases we need to handle
            enumerator = [inputKeys objectEnumerator];
            while ((key = [enumerator nextObject]) != nil) 
            {
                id parameter = [attr objectForKey:key];
                if ([parameter isKindOfClass:[NSDictionary class]])
                {
                    classstring = [(NSDictionary *)parameter objectForKey: kCIAttributeClass];
                    if ([classstring isEqualToString:@"CIVector"] && [key isEqualToString:@"inputExtent"])
                        usesExtent = YES;
                    if ([key isEqualToString:@"inputImage"])
                        usesImage = YES;
                    if ([key isEqualToString:@"inputBackgroundImage"])
                        hasBackground = YES;
                }
            }
            // stack generators here
            if (!usesImage && result != nil)
                // check for automatic SOver of layered results
                [resultstack addObject:result]; // keep result around for SOver at end
            // supply chained image parameters here
            if (usesImage)
            {
                if (result != nil)
                    {
                    if (hasBackground)
                        [f setValue:result forKey:@"inputBackgroundImage"]; // chain layers (blend modes by background)
                    else
                        [f setValue:result forKey:@"inputImage"]; // chain layers
                    }
            }
            // supply the obvious extent for any extent parameters
            if (usesExtent)
                [f setValue: [CIVector vectorWithX: 0  Y: 0  Z: NSWidth(bounds)  W: NSHeight(bounds)]
                  forKey: @"inputExtent"];
            // get the filter result
            result = [f valueForKey: @"outputImage"];
        }
        else if ([type isEqualToString:@"image"] || [type isEqualToString:@"text"])
        {
            // image or text layer
            if (result != nil)
                // check for automatic SOver of layered results
                [resultstack addObject:result]; // keep result around for SOver at end
            // get the image and offset
            CIImage *im = [self imageAtIndex:i];
            NSPoint offset = [self offsetAtIndex:i];
            // apply an affine transform to the iamge to account for the offset
            f = [CIFilter filterWithName:@"CIAffineTransform"];
            NSAffineTransform *t = [NSAffineTransform transform];
            [t translateXBy:offset.x yBy:offset.y];
            [f setValue:t forKey:@"inputTransform"];
            [f setValue:im forKey:@"inputImage"];
            // and get the result
            result = [f valueForKey:@"outputImage"];
        }
    }
    // at the end, if there are results stacked (base image, other image layers, text layers, generators), overlay them using SOver
    if ([resultstack count] > 0)
    {
        CIFilter *sover;
        CIImage *background = nil;
        
        count = [resultstack count];
        for (i = 0; i < count; i++)
        {
            if (i == 0)
                background = [resultstack objectAtIndex:i];
            else
            {
                sover = [CIFilter filterWithName:@"CISourceOverCompositing" keysAndValues:
                  @"inputBackgroundImage", background, @"inputImage", [resultstack objectAtIndex:i], nil];
                background = [sover valueForKey:@"outputImage"];
            }
        }
        if (result == nil)
            result = background;
        else
        {
            // finally composite result over stacked items
            sover = [CIFilter filterWithName:@"CISourceOverCompositing" keysAndValues:
              @"inputBackgroundImage", background, @"inputImage", result, nil];
            result = [sover valueForKey:@"outputImage"];
        }
    }
    return result;
}

// decide if a filter in the effect stack has a missing image parameter
// ignore the chained image parameter (either inputImage or inputBackgroundImage for blend modes/Porter-Duff modes)
- (BOOL)filterHasMissingImage:(CIFilter *)f
{
    BOOL hasBackground, missingImage;
    NSString *key, *classstring;
    NSDictionary *parameter, *attr;
    NSArray *inputKeys;
    NSEnumerator *enumerator;
    
    // first check the filter for an uninitialized image
    attr = [f attributes];
    inputKeys = [f inputKeys];
    hasBackground = NO;
    enumerator = [inputKeys objectEnumerator];
    // decide first if the filter has a background image - it is a blend mode or compositing method
    while ((key = [enumerator nextObject]) != nil) 
    {
        parameter = [attr objectForKey:key];
        classstring = [parameter objectForKey: kCIAttributeClass];
        if ([classstring isEqualToString:@"CIImage"] && [key isEqualToString:@"inputBackgroundImage"])
            hasBackground = YES;
    }
    missingImage = NO;
    enumerator = [inputKeys objectEnumerator];
    while ((key = [enumerator nextObject]) != nil) 
    {
        parameter = [attr objectForKey:key];
        classstring = [parameter objectForKey: kCIAttributeClass];
        if ([classstring isEqualToString:@"CIImage"])
        {
            if (hasBackground)
            {
                if (![key isEqualToString:@"inputBackgroundImage"] && [f valueForKey:key] == nil)
                {
                    missingImage = YES;
                    break;
                }
            }
            else
            {
                if (![key isEqualToString:@"inputImage"] && [f valueForKey:key] == nil)
                {
                    missingImage = YES;
                    break;
                }
            }
        }
    }
    return missingImage;
}

// determine if the entire effect stack has a missing image - if yes, then the effect stack can't be evaluated
- (BOOL)hasMissingImage
{
    NSInteger i, count;
    CIFilter *f;
    
    count = [self layerCount];
    for (i = 0; i < count; i++)
    {
        f = [self filterAtIndex:i];
        if (f != nil && [self filterHasMissingImage:f])
            return YES;
    }
    return NO;
}

// encode arbitrary parameter objects for filters into XML-compatible NSNumber's
- (void)encodeValue:(id)obj forKey:(NSString *)key intoDictionary:(NSMutableDictionary *)v
    {
    NSAffineTransformStruct S;
    
    // decide what it is and store values in the values dictionary
    if ([obj isKindOfClass:[NSNumber class]])
        [v setValue:obj forKey:key];
    else if ([obj isKindOfClass:[CIVector class]])
        {
        [v setValue:[obj stringRepresentation] forKey:[key stringByAppendingString:@"_CIVectorValue"]];
        }
    else if ([obj isKindOfClass:[CIColor class]])
        {
        [v setValue:[obj stringRepresentation] forKey:[key stringByAppendingString:@"_CIColorValue"]];
        }
    else if ([obj isKindOfClass:[NSAffineTransform class]])
        {
        S = [obj transformStruct];
        [v setValue:[NSNumber numberWithDouble:S.m11] forKey:[key stringByAppendingString:@"_m11"]];
        [v setValue:[NSNumber numberWithDouble:S.m12] forKey:[key stringByAppendingString:@"_m12"]];
        [v setValue:[NSNumber numberWithDouble:S.m21] forKey:[key stringByAppendingString:@"_m21"]];
        [v setValue:[NSNumber numberWithDouble:S.m22] forKey:[key stringByAppendingString:@"_m22"]];
        [v setValue:[NSNumber numberWithDouble:S.tX] forKey:[key stringByAppendingString:@"_tX"]];
        [v setValue:[NSNumber numberWithDouble:S.tY] forKey:[key stringByAppendingString:@"_tY"]];
        }
    }

// decode XML-compatible NSNumber's into arbitrary parameter objects for filters
- (id)decodedValueForKey:(NSString *)key ofClass:(NSString *)classname fromDictionary:(NSDictionary *)v
    {
    if ([classname isEqualToString:@"NSNumber"])
        return [v valueForKey:key];
    else if ([classname isEqualToString:@"CIVector"])
    {
        NSString    *objValue = (NSString*)[v valueForKey:[key stringByAppendingString:@"_CIVectorValue"]];
        
        if (objValue == nil)
            return nil;
        return [CIVector vectorWithString:objValue];
    }
    else if ([classname isEqualToString:@"CIColor"])
    {
        NSString    *objValue = (NSString*)[v valueForKey:[key stringByAppendingString:@"_CIColorValue"]];
        
        if (objValue == nil)
            return nil;
        return [CIColor colorWithString:objValue];
    }
    else if ([classname isEqualToString:@"NSAffineTransform"])
    {
        NSAffineTransformStruct S;
        NSAffineTransform *t;
        
        if ([v valueForKey:[key stringByAppendingString:@"_m11"]] == nil)
            return nil;
        S.m11 = [[v valueForKey:[key stringByAppendingString:@"_m11"]] doubleValue];
        S.m12 = [[v valueForKey:[key stringByAppendingString:@"_m12"]] doubleValue];
        S.m21 = [[v valueForKey:[key stringByAppendingString:@"_m21"]] doubleValue];
        S.m22 = [[v valueForKey:[key stringByAppendingString:@"_m22"]] doubleValue];
        S.tX = [[v valueForKey:[key stringByAppendingString:@"_tX"]] doubleValue];
        S.tY = [[v valueForKey:[key stringByAppendingString:@"_tY"]] doubleValue];
        t = [[[NSAffineTransform alloc] init] autorelease];
        [t setTransformStruct:S];
        return t;
    }
    else if ([classname isEqualToString:@"CIImage"])
    {
        if ([v valueForKey:key] == nil)
            return nil;
    }
    return nil;
    }

@end

