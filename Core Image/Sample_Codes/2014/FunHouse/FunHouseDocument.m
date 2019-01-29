/*
     File: FunHouseDocument.m
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

#import "FunHouseDocument.h"
#import "EffectStack.h"
#import "FunHouseWindowController.h"
#import "ParameterView.h"
#import "CoreImageView.h"
#import "EffectStackController.h"
#import <ApplicationServices/ApplicationServices.h>
#import <Carbon/Carbon.h>
#import "FunHouseApplication.h"

@implementation FunHouseDocument

//
// fun house document code - we're a subclass of NSDocument
//
// this code uses NSFileWrapper to encode the fun house preset
// check out the NSFileWrapper class - it allows you to support packages or regular files
// to do so, you need to encode your data files as NSData first
// this NSDocument subclass also uses ImageIO to encode and decode the JPEG and TIFF files to and from NSData.
//

// set this to 1 to disable save
// to complete this, you must disconnext the save and save as menu items in MainMenu.nib
#define SAVEDISABLED 0

- (id)init
{
    self = [super init];
    if (self)
    {
        // allocate the effect stack for a document here
        effectStack = [[EffectStack alloc] init];
        fullScreen = NO;
        hasWindowDimensions = NO;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // release the effect stack for the document here
    [effectStack release];
    if (colorspace)
        CFRelease(colorspace);
    [super dealloc];
}

// this sets up our (non-full-screen) window controller
- (void)makeWindowControllers
{
    // create the window controller
    windowController = [[FunHouseWindowController allocWithZone:[self zone]] init];
    [self addWindowController:windowController];
    [windowController release];
}

+ (NSArray *)writableTypes
{
	return [NSArray arrayWithObjects:@"Fun House Preset", @"JPEG File", @"TIFF File", nil];
}

+ (BOOL)isNativeType:(NSString *)aType
{
	return [[[self class] writableTypes] containsObject:aType];
}

- (BOOL)prepareSavePanel:(NSSavePanel *)sp
{
    // assign defaults for the save panel
    [sp setTitle:@"Save image"];
    [sp setExtensionHidden:NO];
    return YES;
}


// add '-1' to filename before extension
- (NSString *)disambiguateFilename:(NSString *)filename
{
    NSString *base, *extension;
    
    base = [filename stringByDeletingPathExtension];
    extension = [filename pathExtension];
    return [[base stringByAppendingString:@"-1"] stringByAppendingPathExtension:extension];
}

#if SAVEDISABLED
// we implement this method in the NSDocument subclass specifically so we can disable the save and save as commands
- (BOOL)isDocumentEdited
{
    // this is all that's required to make a document think it doesn't have to be saved
    return NO;
}
#endif

// create JPEG data for a document, using ImageIO
- (NSData *)jpegData:(NSError **)outError
{
    NSData *d;
    NSRect r;
    CIContext *context;

    // save the image
    // create a mutable data to store the JPEG data into
    CFMutableDataRef data = CFDataCreateMutable(kCFAllocatorDefault, 0);
    // create an image destination (ImageIO's way of saying we want to save to a file format)
    // note: public.jpeg denotes that we are saving to JPEG
    CGImageDestinationRef ref = CGImageDestinationCreateWithData(data, (CFStringRef)@"public.jpeg", 1, NULL);
    if (ref == NULL)
    {
        printf("problems creating image destination\n");
        if(data)
			CFRelease(data);
        if(ref)
			CFRelease(ref);
        if (outError)
            *outError = [NSError errorWithDomain:@"fun house errors" code:-10101
                                        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"problems creating image destination for file save", NSLocalizedDescriptionKey, nil]];
        return nil;
    }
    // get the window controller for this document
    FunHouseWindowController *con = [[self windowControllers] objectAtIndex:0];
    // compute the rectangle that the file fits into - we use the bounds of the view in many cases
    if ([[con coreImageView] isScaled])
    {
        if ([effectStack layerCount] < 1 || ![[effectStack typeAtIndex:0] isEqualToString:@"image"])
            // if there's no image (generator used instead or nothing is in the effect stack) we use the view bounds
            r = [[con coreImageView] bounds];
        else
        {
            // for the scaled image case, we use the actual image extents (too big to fit on screen)
            CGRect extent = [[effectStack imageAtIndex:0] extent];
            r = NSMakeRect(extent.origin.x, extent.origin.y, extent.size.width, extent.size.height);
        }
    }
    else
        // image is not scaled by a view transform, use the view bounds
        r = [[con coreImageView] bounds];
    // we make a CGImageRef for the view, based on the core image graph. Note: it gets rendered in createCGImage
    if (colorspace == nil) {
        CGColorSpaceRef cs = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
        context = [CIContext contextWithCGContext:[[[[con coreImageView] window] graphicsContext] graphicsPort]
                                          options:[NSDictionary dictionaryWithObjectsAndKeys:(id)cs, kCIContextOutputColorSpace, nil]];
        CGColorSpaceRelease(cs);
    }
    else {
        context = [CIContext contextWithCGContext:[[[[con coreImageView] window] graphicsContext] graphicsPort]
                                          options:[NSDictionary dictionaryWithObjectsAndKeys:(id)colorspace, kCIContextOutputColorSpace, nil]];
    }
    CGImageRef iref = [context createCGImage:[effectStack coreImageResultForRect:r] fromRect:CGRectMake(r.origin.x, r.origin.y, r.size.width, r.size.height)];
    // add image to the ImageIO destination (specify the image we want to save)
    CGImageDestinationAddImage(ref, iref, NULL);
    // finalize: this saves the image to the JPEG format as data
    if (!CGImageDestinationFinalize(ref))
    {
        printf("problems writing JPEG file\n");
        CFRelease(data);
        CFRelease(ref);
        CGImageRelease(iref);
        if (outError)
            *outError = [NSError errorWithDomain:@"fun house errors" code:-10102
                                        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"problems writing JPEG file for file save", NSLocalizedDescriptionKey, nil]];
        return nil;
    }
    CFRelease(ref);
    CGImageRelease(iref);
    if (outError)
        *outError = nil;
    // return the data
    d = (NSData *)data;
    return [d autorelease];
}

- (NSData *)tiffData:(NSError **)outError
{
    NSData *d;
    NSRect r;
    CIContext *context;
    
    // save the image
    // create a mutable data to store the TIFF data into
    CFMutableDataRef data = CFDataCreateMutable(kCFAllocatorDefault, 0);
    // create an image destination (ImageIO's way of saying we want to save to a file format)
    // note: public.tiff denotes that we are saving to TIFF
    CGImageDestinationRef ref = CGImageDestinationCreateWithData(data, (CFStringRef)@"public.tiff", 1, NULL);
    if (ref == NULL)
        {
        printf("problems creating image destination\n");
        CFRelease(data);
        if (outError)
            *outError = [NSError errorWithDomain:@"fun house errors" code:-10101
                                        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"problems creating image destination for file save", NSLocalizedDescriptionKey, nil]];
        return nil;
        }
    // get the window controller for this document
    FunHouseWindowController *con = [[self windowControllers] objectAtIndex:0];
    // compute the rectangle that the file fits into - we use the bounds of the view in many cases
    if ([[con coreImageView] isScaled])
    {
        if ([effectStack layerCount] < 1 || ![[effectStack typeAtIndex:0] isEqualToString:@"image"])
            // if there's no image (generator used instead or nothing is in the effect stack) we use the view bounds
            r = [[con coreImageView] bounds];
        else
        {
            // for the scaled image case, we use the actual image extents (too big to fit on screen)
            CGRect extent = [[effectStack imageAtIndex:0] extent];
            r = NSMakeRect(extent.origin.x, extent.origin.y, extent.size.width, extent.size.height);
        }
    }
    else
        // image is not scaled by a view transform, use the view bounds
        r = [[con coreImageView] bounds];
    // we make a CGImageRef for the view, based on the core image graph. Note: it gets rendered in createCGImage
    if (colorspace == nil) {
        CGColorSpaceRef cs = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
        context = [CIContext contextWithCGContext:[[[[con coreImageView] window] graphicsContext] graphicsPort]
                                          options:[NSDictionary dictionaryWithObjectsAndKeys:(id)cs, kCIContextOutputColorSpace, nil]];
        CGColorSpaceRelease(cs);
    }
    else {
        context = [CIContext contextWithCGContext:[[[[con coreImageView] window] graphicsContext] graphicsPort]
                                          options:[NSDictionary dictionaryWithObjectsAndKeys:(id)colorspace, kCIContextOutputColorSpace, nil]];
    }
    CGImageRef iref = [context createCGImage:[effectStack coreImageResultForRect:r] fromRect:CGRectMake(r.origin.x, r.origin.y, r.size.width, r.size.height)];
    // add image to the ImageIO destination (specify the image we want to save)
    CGImageDestinationAddImage(ref, iref, NULL);
    // finalize: this saves the image to the TIFF format as data
    if (!CGImageDestinationFinalize(ref))
    {
        printf("problems writing TIFF file\n");
        if(data)
			CFRelease(data);
        CFRelease(ref);
        CGImageRelease(iref);
        if (outError)
            *outError = [NSError errorWithDomain:@"fun house errors" code:-10102
                                        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"problems writing TIFF file for file save", NSLocalizedDescriptionKey, nil]];
        return nil;
    }
    if(ref)
		CFRelease(ref);
    CGImageRelease(iref);
    if (outError)
        *outError = nil;
    // return the data
    d = (NSData *)data;
    return [d autorelease];
}

// convert a CIImage to a CGImageRef - uses the context of the document's view
- (CGImageRef)CIImageToCGImage:(CIImage *)im usingRect:(CGRect)r
{
    FunHouseWindowController *con = [[self windowControllers] objectAtIndex:0];
    CGImageRef cgImage = [[[con coreImageView] context] createCGImage:im fromRect:r];
    return (CGImageRef)[(id)cgImage autorelease];;
}
    
- (NSPrintOperation *)printOperationWithSettings:(NSDictionary *)printSettings error:(NSError **)outError
{
    FunHouseWindowController *con = [[self windowControllers] objectAtIndex:0];
    
    return [NSPrintOperation printOperationWithView: [con coreImageView]];
}

// save the document's effect stack as a preset bundle (package)
// images are saved as actual files within the package with names ident1.tiff, ident2.tiff, etc.
// the effect stack is saved as a text XML file, with the name file.xml
// this means that core image data must be encoded as NSDictionary, NSArray, NSString and NSNumber items
// anything that's not of that form (like CIVector, CIColor, etc.) must be re-encoded
// this also has good code for converting CIImage to tiff file data
- (NSFileWrapper *)fileWrapperForPreset:(NSError **)outError
{
    BOOL hasBackground;
    NSInteger i, count;
    NSString *type, *file, *key, *error, *name, *filename, *path;
    NSMutableDictionary *layerdict, *filedict, *values, *pathdict;
    NSMutableArray *layerarray;
    NSPoint offset;
    NSArray *inputKeys;
    NSDictionary *attr;
    NSEnumerator *enumerator, *e;
    id obj;
    CIFilter *filter;
    NSData *xmlData, *d;
    NSFileWrapper *fw;
    NSMutableDictionary *dict, *localdict;
    
    // create the preset bundle
    fw = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:[NSDictionary dictionary]];
    count = [effectStack layerCount];
    // first sort out all the image files used by this effect stack
    pathdict = [NSMutableDictionary dictionary];
    // enumerate the document's effect stack layers
    for (i = 0; i < count; i++)
    {
        type = [effectStack typeAtIndex:i];
        if ([type isEqualToString:@"image"])
        {
            // image layer
            // get original image file path
            path = [effectStack imageFilePathAtIndex:i];
            // make sure the file isn't being stored twice - we can reference the same file as many times as we want!
            if ([pathdict valueForKey:path] == nil)
            {		
                filename = [path lastPathComponent];
                // make sure the last component is unique (there could be two files withg the same name from two directories)
                // we must assume they are different at this point
                e = [pathdict objectEnumerator];
                while ((localdict = [e nextObject]) != nil)
                {
                    name = [localdict valueForKey:@"filename"];
                    if ([name isEqualToString:filename])
                    {
                        // handle collision
                        filename = [self disambiguateFilename:filename];
                        // start over - check again!
                        e = [pathdict objectEnumerator];
                    }
                }
		// set up the path to have a representation, by default its last component (e. g. tiger.jpg)
                [pathdict setValue:
                  [NSMutableDictionary dictionaryWithObjectsAndKeys:filename, @"filename",
                    [NSNumber numberWithBool:NO], @"storedToDisk", [effectStack imageFileDataAtIndex:i], @"data", nil]
                  forKey:path];
            }
        }
        else if ([type isEqualToString:@"filter"])
        {
            // filter layer
            filter = [effectStack filterAtIndex:i];
            inputKeys = [filter inputKeys];
            // decide if the filter has a background (it's a blend mode)
            enumerator = [inputKeys objectEnumerator];
            hasBackground = NO;
            while ((key = [enumerator nextObject]) != nil) 
            {
                if ([key isEqualToString:@"inputBackgroundImage"])
                {
                    hasBackground = YES;
                    break;
                }
            }
            // now inspect all the input keys for the filter
            enumerator = [inputKeys objectEnumerator];
            while ((key = [enumerator nextObject]) != nil)
            {
                obj = [filter valueForKey:key];
                if (obj != nil)
                {
                    if ([obj isKindOfClass:[CIImage class]])
                    {
                        // decide whether to skip this key (it gets filled in by something above it in the effect stack)
                        if (hasBackground && [key isEqualToString:@"inputBackgroundImage"])
                            continue; // a blend mode; we chain on inputBackgroundImage
                        if (!hasBackground && [key isEqualToString:@"inputImage"])
                            continue; // not a blend mode; we chain on inputImage
                        // we have an image that fills in a filter image parameter
                        // get its path
                        path = [effectStack filterLayer:i imageFilePathValueForKey:key];
                        // make sure the file isn't being stored twice - we can reference the same file as many times as we want!
                        if ([pathdict valueForKey:path] == nil)
                        {
                            filename = [path lastPathComponent];
                            // make sure the last component is unique (there could be two files withg the same name from two directories)
                            // we must assume they are different at this point
                            e = [pathdict objectEnumerator];
                            while ((localdict = [e nextObject]) != nil)
                            {
                                name = [localdict valueForKey:@"filename"];
                                if ([name isEqualToString:filename])
                                {
                                    // handle collision
                                    filename = [self disambiguateFilename:filename];
                                    // start over - check again!
                                    e = [pathdict objectEnumerator];
                                }
                            }
                            // set up the path to have a representation, by default its last component (e. g. tiger.jpg)
                            [pathdict setValue:
                              [NSMutableDictionary dictionaryWithObjectsAndKeys:filename, @"filename",
                                [NSNumber numberWithBool:NO], @"storedToDisk",
                                [effectStack filterLayer:i imageFileDataValueForKey:key], @"data", nil]
                              forKey:path];
                        }
                    }
                }
            }
        }
    }
    // make two structures: image file dictionary and layer array
    filedict = [NSMutableDictionary dictionaryWithCapacity:10];
    layerarray = [NSMutableArray arrayWithCapacity:count];
    [filedict setValue:layerarray forKey:@"layers"];
    NSRect fr = [[windowController window] frame];
    [filedict setValue:[NSNumber numberWithDouble:fr.size.width] forKey:@"windowWidth"];
    [filedict setValue:[NSNumber numberWithDouble:fr.size.height] forKey:@"windowHeight"];
    // enumerate the document's effect stack layers
    for (i = 0; i < count; i++)
    {
        // create a dictionary for this layer and add it to the layer array
        layerdict = [NSMutableDictionary dictionaryWithCapacity:10];
        [layerarray addObject:layerdict];
        // dispatch on layer type
        type = [effectStack typeAtIndex:i];
        if ([type isEqualToString:@"image"])
        {
            // image layer
            // fill dictionary for image layer
            [layerdict setValue:@"image" forKey:@"type"];
            offset = [effectStack offsetAtIndex:i];
            [layerdict setValue:[NSNumber numberWithDouble:offset.x] forKey:@"offsetX"];
            [layerdict setValue:[NSNumber numberWithDouble:offset.y] forKey:@"offsetY"];
            // create identifier for image
            path = [effectStack imageFilePathAtIndex:i];
            // decide if this file has yet been output
            localdict = [pathdict valueForKey:path];
            // get the filename within the bundle
            file = [localdict valueForKey:@"filename"];
            // we only store it if it hasn't yet been stored
            if (![[localdict valueForKey:@"storedToDisk"] boolValue])
            {
                // mark it stored
                [localdict setValue:[NSNumber numberWithBool:YES] forKey:@"storedToDisk"];
                // get original file as data
                //d = [NSData dataWithContentsOfFile:path];
                d = [localdict valueForKey:@"data"];
                // add the file to the file wrapper, given the NSData for the file
                [fw addRegularFileWithContents:d preferredFilename:file];
            }
            // bind it to the layer dictionary
            [layerdict setValue:file forKey:@"file"];
        }
        else if ([type isEqualToString:@"text"])
        {
            // text layer
            // fill dictionary for image layer
            [layerdict setValue:@"text" forKey:@"type"];
            dict = [effectStack mutableDictionaryAtIndex:i];
            [layerdict setValue:[dict valueForKey:@"string"] forKey:@"string"];
            [layerdict setValue:[dict valueForKey:@"scale"] forKey:@"scale"];
            [layerdict setValue:[dict valueForKey:@"offsetX"] forKey:@"offsetX"];
            [layerdict setValue:[dict valueForKey:@"offsetY"] forKey:@"offsetY"];
            [layerdict setValue:[dict valueForKey:@"font"] forKey:@"font"];
            [layerdict setValue:[dict valueForKey:@"pointSize"] forKey:@"pointSize"];
            [layerdict setValue:[dict valueForKey:@"colorRed"] forKey:@"colorRed"];
            [layerdict setValue:[dict valueForKey:@"colorGreen"] forKey:@"colorGreen"];
            [layerdict setValue:[dict valueForKey:@"colorBlue"] forKey:@"colorBlue"];
            [layerdict setValue:[dict valueForKey:@"colorAlpha"] forKey:@"colorAlpha"];
            [layerdict setValue:[dict valueForKey:@"shadowColorRed"] forKey:@"shadowColorRed"];
            [layerdict setValue:[dict valueForKey:@"shadowColorGreen"] forKey:@"shadowColorGreen"];
            [layerdict setValue:[dict valueForKey:@"shadowColorBlue"] forKey:@"shadowColorBlue"];
            [layerdict setValue:[dict valueForKey:@"shadowColorAlpha"] forKey:@"shadowColorAlpha"];
            [layerdict setValue:[dict valueForKey:@"shadowBlurRadius"] forKey:@"shadowBlurRadius"];
            [layerdict setValue:[dict valueForKey:@"shadowBlurOffsetX"] forKey:@"shadowBlurOffsetX"];
            [layerdict setValue:[dict valueForKey:@"shadowBlurOffsetY"] forKey:@"shadowBlurOffsetY"];
            [layerdict setValue:[dict valueForKey:@"strikeThroughStyle"] forKey:@"strikeThroughStyle"];
            [layerdict setValue:[dict valueForKey:@"underlineStyle"] forKey:@"underlineStyle"];
        }
        else if ([type isEqualToString:@"filter"])
        {
            // filter layer
            // fill dictionary for filter layer
            filter = [effectStack filterAtIndex:i];
            [layerdict setValue:@"filter" forKey:@"type"];
            attr = [filter attributes];
            inputKeys = [filter inputKeys];
            // decide if the filter has a background (it's a blend mode)
            enumerator = [inputKeys objectEnumerator];
            hasBackground = NO;
            while ((key = [enumerator nextObject]) != nil) 
            {
                if ([key isEqualToString:@"inputBackgroundImage"])
                {
                    hasBackground = YES;
                    break;
                }
            }
            [layerdict setValue:[attr valueForKey:kCIAttributeFilterName] forKey:@"classname"];
            values = [NSMutableDictionary dictionaryWithCapacity:10];
            [layerdict setValue:values forKey:@"values"];
            // now inspect all the input keys for the filter
            enumerator = [inputKeys objectEnumerator];
            while ((key = [enumerator nextObject]) != nil) 
            {
                obj = [filter valueForKey:key];
                if (obj != nil)
                {
                    if ([obj isKindOfClass:[CIImage class]])
                    {
                        // decide whether to skip this key (it gets filled in by something above it in the effect stack)
                        if (hasBackground && [key isEqualToString:@"inputBackgroundImage"])
                            continue; // a blend mode; we chain on inputBackgroundImage
                        if (!hasBackground && [key isEqualToString:@"inputImage"])
                            continue; // not a blend mode; we chain on inputImage
                        // we have an image that fills in a filter image parameter
                        // create identifier for image
                        path = [effectStack filterLayer:i imageFilePathValueForKey:key];
                        localdict = [pathdict valueForKey:path];
                        // get the filename within the bundle
                        file = [localdict valueForKey:@"filename"];
                        // we only store it if it hasn't yet been stored
                        if (![[localdict valueForKey:@"storedToDisk"] boolValue])
                        {
                            // mark it stored
                            [localdict setValue:[NSNumber numberWithBool:YES] forKey:@"storedToDisk"];
                            // get original file as data
                            // d = [NSData dataWithContentsOfFile:path];
                            d = [localdict valueForKey:@"data"];
                            // add the file to the file wrapper, given the NSData for the file
                            [fw addRegularFileWithContents:d preferredFilename:file];
                        }
                        // bind the filename within the bundle to the filter's key
                        [values setValue:file forKey:key];
                    }
                    else
                        // if not an image, do a standard encoding into XML-compatible items
                        [effectStack encodeValue:obj forKey:key intoDictionary:values];
                }
            }
        }
    }
    // now create the top level XML file (as data, of course)
    xmlData = [NSPropertyListSerialization dataFromPropertyList:filedict format:NSPropertyListXMLFormat_v1_0
      errorDescription:&error];
    if (xmlData == nil)
    {
        NSLog(@"%@", error);
        [error release];
        if (outError)
            *outError = [NSError errorWithDomain:@"fun house errors" code:-10106
                                        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"problems writing xml file for preset save", NSLocalizedDescriptionKey, nil]];
        [fw release];
        return nil;
    }
    // add the XML file (in NSData form) to the file wrapper
    [fw addRegularFileWithContents:xmlData preferredFilename:@"file.xml"];
    if (outError)
        *outError = nil;
    // and the file wrapper's ready to store onto disk
    return [fw autorelease];
}

// this is the high-level method that produces the NSFileWrapper for JPEG, TIFF, or fun house preset files
- (NSFileWrapper *)fileWrapperOfType:(NSString *)typeName error:(NSError **)outError
{
    if ([typeName isEqualToString:@"JPEG File"])
        return [[[NSFileWrapper alloc] initRegularFileWithContents:[self jpegData:outError]] autorelease];
    if ([typeName isEqualToString:@"TIFF File"])
        return [[[NSFileWrapper alloc] initRegularFileWithContents:[self tiffData:outError]] autorelease];
    if ([typeName isEqualToString:@"Fun House Preset"])
        return [self fileWrapperForPreset:outError];
    if (outError)
        *outError = [NSError errorWithDomain:@"fun house errors" code:-10103
                                    userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"unrecognized file type for file save", NSLocalizedDescriptionKey, nil]];
    return nil;
}

// this handles the read of a plain image file - it sets up the base image of the effect stack
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)aType error:(NSError **)outError
{
    CIImage *im;
    CGImageSourceRef ref;
    CGImageRef image;
    
    // use Core Image to convert the data - it uses the ImageIO library
    // get color space of image data
    if ([aType isEqualToString:@"OpenEXR File"])
        ref = CGImageSourceCreateWithURL((CFURLRef)[self fileURL], nil);
    else
        ref = CGImageSourceCreateWithData((CFDataRef)data, nil);
    image = CGImageSourceCreateImageAtIndex(ref, 0, (CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:(id)kCFBooleanTrue,
      (NSString *)kCGImageSourceShouldAllowFloat, nil]);
    colorspace = CGImageGetColorSpace(image);
    if(colorspace)
		CFRetain(colorspace);
    CFRelease(ref);
    if ([aType isEqualToString:@"OpenEXR File"])
        im = [CIImage imageWithCGImage:image];
    else
        im = [CIImage imageWithData:data];
    if (image)
		CFRelease(image);
    [effectStack setBaseImage:im withFilename:[[[self fileURL] path] lastPathComponent] andImageFilePath:[[self fileURL] path]];
    return YES;
}

// this is the high-level method required by the NSDocument subclass that reads in the document from an NSFileWrapper
- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError **)outError
{
    BOOL b;
    
    if ([fileWrapper isRegularFile])
        b = [self readFromData:[fileWrapper regularFileContents] ofType:typeName error:outError];
    else
        b = [self openPreset:fileWrapper error:outError];
    [[self undoManager] removeAllActions];
    return b;
}

// we implement this method in the subclass so that we can call removeAllActions (for undo)
- (void)updateChangeCount:(NSDocumentChangeType)change
{
    // This clears the undo stack whenever we load or save.
    [super updateChangeCount:change];
    if (change == NSChangeCleared)
        [[self undoManager] removeAllActions];
}

// return this document's effect stack
- (EffectStack *)effectStack
{
    return effectStack;
}

// this reads in a fun house preset from an NSFileWrapper
- (BOOL)openPreset:(NSFileWrapper *)fileWrapper error:(NSError **)outError
{
    BOOL hasBackground;
    NSInteger i, count;
    NSDictionary *fw;
    NSData *xmldata;
    NSDictionary *filedict, *layerdict, *values, *attr, *parameter;
    NSArray *layers, *inputKeys;
    NSString *type, *file, *classname, *error, *key, *classstring, *path;
    NSPoint offset;
    NSNumber *num;
    CIImage *im;
    CIFilter *filter;
    NSPropertyListFormat format;
    NSEnumerator *enumerator;
    NSMutableDictionary *dict;
    
    // note: fileWrapper must be a dictionary by here
    fw = [fileWrapper fileWrappers];
    // unpack dictionary
    xmldata = [[fw valueForKey:@"file.xml"] regularFileContents];
    [effectStack removeAllLayers];
    // read into internal data structure
    filedict = [NSPropertyListSerialization propertyListFromData:xmldata
      mutabilityOption:kCFPropertyListImmutable format:&format errorDescription:&error];
    if (filedict == nil)
        {
        *outError = [NSError errorWithDomain:@"fun house errors" code:-10105
          userInfo:[NSDictionary dictionaryWithObjectsAndKeys:error, NSLocalizedDescriptionKey, nil]];
        [error release];
        return NO;
        }
    // now unpack file dictionary
    num = [filedict valueForKey:@"windowWidth"];
    if (num == nil)
        hasWindowDimensions = NO;
    else
    {
        hasWindowDimensions = YES;
        wdWidth = [num doubleValue];
        wdHeight = [[filedict valueForKey:@"windowHeight"] doubleValue];
    }
    layers = [filedict valueForKey:@"layers"];
    count = [layers count];
    for (i = 0; i < count; i++)
    {
        layerdict = [layers objectAtIndex:i];
        type = [layerdict valueForKey:@"type"];
        if ([type isEqualToString:@"image"])
        {
            // an image layer
            offset = NSMakePoint([[layerdict valueForKey:@"offsetX"] doubleValue], [[layerdict valueForKey:@"offsetY"] doubleValue]);
            file = [layerdict valueForKey:@"file"];
            path = [[[[self fileURL] path] stringByAppendingString:@"/"] stringByAppendingString:file];
            im = [[[CIImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]] autorelease];
            // and insert the image layer into the effect stack
            [effectStack insertImageLayer:im withFilename:file atIndex:i];
            [effectStack setImageLayer:i offset:offset];
            [effectStack setImageLayer:i imageFilePath:path];
        }
        else if ([type isEqualToString:@"text"])
        {
            // add the text layer to the effect stack
            [effectStack insertTextLayer:[layerdict valueForKey:@"string"] withImage:nil atIndex:i];
            // rebuild the effect stack text layer's properties from the dictionary format saved to the XML file
            dict = [effectStack mutableDictionaryAtIndex:i];
            [dict setValue:[layerdict valueForKey:@"offsetX"] forKey:@"offsetX"];
            [dict setValue:[layerdict valueForKey:@"offsetY"] forKey:@"offsetY"];
            [dict setValue:[layerdict valueForKey:@"scale"] forKey:@"scale"];
            [dict setValue:[layerdict valueForKey:@"font"] forKey:@"font"];
            [dict setValue:[layerdict valueForKey:@"pointSize"] forKey:@"pointSize"];
            [dict setValue:[layerdict valueForKey:@"colorRed"] forKey:@"colorRed"];
            [dict setValue:[layerdict valueForKey:@"colorGreen"] forKey:@"colorGreen"];
            [dict setValue:[layerdict valueForKey:@"colorBlue"] forKey:@"colorBlue"];
            [dict setValue:[layerdict valueForKey:@"colorAlpha"] forKey:@"colorAlpha"];
            [dict setValue:[layerdict valueForKey:@"shadowColorRed"] forKey:@"shadowColorRed"];
            [dict setValue:[layerdict valueForKey:@"shadowColorGreen"] forKey:@"shadowColorGreen"];
            [dict setValue:[layerdict valueForKey:@"shadowColorBlue"] forKey:@"shadowColorBlue"];
            [dict setValue:[layerdict valueForKey:@"shadowColorAlpha"] forKey:@"shadowColorAlpha"];
            [dict setValue:[layerdict valueForKey:@"shadowBlurRadius"] forKey:@"shadowBlurRadius"];
            [dict setValue:[layerdict valueForKey:@"shadowBlurOffsetX"] forKey:@"shadowBlurOffsetX"];
            [dict setValue:[layerdict valueForKey:@"shadowBlurOffsetY"] forKey:@"shadowBlurOffsetY"];
            [dict setValue:[layerdict valueForKey:@"strikeThroughStyle"] forKey:@"strikeThroughStyle"];
            [dict setValue:[layerdict valueForKey:@"underlineStyle"] forKey:@"underlineStyle"];
        }
        else if ([type isEqualToString:@"filter"])
        {
            // filter layer
            classname = [layerdict valueForKey:@"classname"];
            values = [layerdict valueForKey:@"values"];
            filter = [CIFilter filterWithName:classname];
            // add the filter to the effect stack
            [effectStack insertFilterLayer:filter atIndex:i];
            // get filter keys
            attr = [filter attributes];
            inputKeys = [filter inputKeys];
            // decide if the filter has a background (it's a blend mode)
            enumerator = [inputKeys objectEnumerator];
            hasBackground = NO;
            while ((key = [enumerator nextObject]) != nil) 
            {
                if ([key isEqualToString:@"inputBackgroundImage"])
                    hasBackground = YES;
            }
            // now inspect all the input keys for the filter
            enumerator = [inputKeys objectEnumerator];
            while ((key = [enumerator nextObject]) != nil) 
            {
                parameter = [attr objectForKey:key];
                // decide whether to skip this key
                // we skip it if it's an image parameter that's provided by evaluation of the effect stack (a chained image from above)
                if (hasBackground && [key isEqualToString:@"inputBackgroundImage"])
                    continue; // a blend mode; we chain on inputBackgroundImage
                if (!hasBackground && [key isEqualToString:@"inputImage"])
                    continue; // not a blend mode; we chain on inputImage
                // otherwise try to unpack this key's value from values dictionary
                classstring = [parameter objectForKey:kCIAttributeClass];
                if ([classstring isEqualToString:@"CIImage"])
                {
                    // filter image parameter
                    file = [values valueForKey:key];
                    path = [[[[self fileURL] path] stringByAppendingString:@"/"] stringByAppendingString:file];
                    im = [[[CIImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]] autorelease];
                    // and set up the filter's image value
                    [filter setValue:im forKey:key];
                    [effectStack setFilterLayer:i imageFilePathValue:[[[[self fileURL] path] stringByAppendingString:@"/"] stringByAppendingString:file]
                      forKey:key];
                }
                else
                    // set the filter's value (must decode complex parameters line CIVector, CIColor, etc.)
                    [filter setValue:[effectStack decodedValueForKey:key ofClass:classstring fromDictionary:values] forKey:key];
            }
        }
    }
    return YES;
}

// handle revert - basically do what NSDocument does, except that we have to update the effect stack to correspond
- (IBAction)revertDocumentToSaved:(id)sender
{
    [super revertDocumentToSaved:sender];
    // redo the effect stack to correspond
    [[EffectStackController sharedEffectStackController] updateLayout];
}

// this handles the zoom to full screen menu item
- (IBAction)zoomToFullScreenAction:(id)sender
{
    CoreImageView *v;
    
    if (fullScreen)
    {
        // zoom away from full screen mode
        // put the menu bar and dock back
        [[NSApplication sharedApplication] setPresentationOptions:NSApplicationPresentationDefault];
        // close the full screen window and its controller
        [fullScreenController close];
        fullScreen = NO;
        // reset the core image view for the effect stack controller
        v = [windowController coreImageView];
        [[EffectStackController sharedEffectStackController] setCoreImageView:v];
        // and update the effect stack controller
        [[EffectStackController sharedEffectStackController] updateLayout];
        // finally redisplay the window
        [v setNeedsDisplay:YES];
    }
    else
    {
        // zoom into full screen mode
        // add a new window controller, and thus a new window
        fullScreenController = [[FunHouseWindowController allocWithZone:[self zone]] initFullScreen];
        [self addWindowController:fullScreenController];
        // set the window up properly to be a full screen window (check out FunHouseWindowController.m)
        [fullScreenController prepFullScreenWindow];
        v = [fullScreenController coreImageView];
        // release it now that it's owned by the document
        [fullScreenController release];
        fullScreen = YES;
        // point the effect stack controller to the right view in the right window
        [[EffectStackController sharedEffectStackController] setCoreImageView:v];
        // update the effect stack controller
        [[EffectStackController sharedEffectStackController] updateLayout];
        // recompute the view transform
        // note: the base image is zoomed to fit the full screen window
        if ([[effectStack typeAtIndex:0] isEqualToString:@"image"])
        {
            CGFloat scale, xscale, yscale, offsetX, offsetY;
            CGSize imagesize;
            NSSize screensize;
            
            // compute size of image
            imagesize = [[effectStack imageAtIndex:0] extent].size;
            // compute size of full screen window
            screensize = [[NSScreen mainScreen] frame].size;
            // decide scale factor now
            xscale = screensize.width / imagesize.width;
            yscale = screensize.height / imagesize.height;
            if (yscale < xscale)
            {
                scale = yscale;
                offsetX = (screensize.width - imagesize.width * scale) * 0.5;
                offsetY = 0.0;
                
            }
            else
            {
                scale = xscale;
                offsetX = 0.0;
                offsetY = (screensize.height - imagesize.height * scale) * 0.5;
            }
            
            // set the view transform for the core image view
            [v setViewTransformScale:scale];
            [v setViewTransformOffsetX:offsetX andY:offsetY];
        }
        // and call for a redisplay
        [v setNeedsDisplay:YES];
    }
    // finally, set up the menu item to reflect the current state (actually, to reflect what the menu item will do)
    [((FunHouseApplication *)NSApp) setFullScreenMenuTitle:(BOOL)fullScreen];
}

// handle the undo command
- (void)undo
{
    CoreImageView *v;
    
    // undo (resets the object state)
    [[self undoManager] undo];
    // get the right core image view pointer
    if (!fullScreen)
        v = [windowController coreImageView];
    else
        v = [fullScreenController coreImageView];
    // update the effect stack controller
    [[EffectStackController sharedEffectStackController] updateLayout];
    // redisplay the core image view
    [v setNeedsDisplay:YES];
}

// handle the redo command
- (void)redo
{
    CoreImageView *v;
    
    // redo (sets the object state)
    [[self undoManager] redo];
    // get the right core image view pointer
    if (!fullScreen)
        v = [windowController coreImageView];
    else
        v = [fullScreenController coreImageView];
    // update the effect stack controller
    [[EffectStackController sharedEffectStackController] updateLayout];
    // redisplay the core image view
    [v setNeedsDisplay:YES];
}

- (void)reconfigureWindowToSize:(NSSize)size andPath:(NSString *)path
{
    [self setFileURL:[NSURL fileURLWithPath:path]];
    [windowController configureToSize:size andFilename:[path lastPathComponent]];
}

- (BOOL)hasWindowDimensions
{
    return hasWindowDimensions;
}

- (CGFloat)windowWidth
{
    return wdWidth;
}

- (CGFloat)windowHeight
{
    return wdHeight;
}

@end
