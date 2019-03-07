/*
 
 File:  main.m
 
 Abstract: Example of how to interop in between Core Image and OpenCL
 and remove haze from images.
 
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

#import <Foundation/Foundation.h>
#import <OpenGL/OpenGL.h>

#import "Dehaze.h"
#import "MorphologicalMinCL.h"


static
CGLPixelFormatObj createPFA(void)
{
    CGLPixelFormatAttribute attrs[] = {
        kCGLPFAAccelerated,
        kCGLPFAAcceleratedCompute, // ensure OpenCL GPU support; not strictly necessary assuming we wanted to run this on a CPU device
        kCGLPFAAllowOfflineRenderers,
        kCGLPFANoRecovery,
        0
    };
    
    GLint nPix = 0;
    CGLPixelFormatObj pfa = nil;
    
    CGLError err = CGLChoosePixelFormat(attrs, &pfa, &nPix);
    
    return kCGLNoError == err && nPix > 0 ? pfa : nil;
}

static
CGLContextObj createCGLContext(const CGLPixelFormatObj pfa)
{
    CGLContextObj cgl_ctx = nil;
    CGLError err = CGLCreateContext(pfa, nil, &cgl_ctx);
    
    return kCGLNoError == err ? cgl_ctx : nil;
}

int main(int argc, const char * argv[])
{
    bool success = false;
    
    @autoreleasepool {
        
        const char *inputFilename  = argc > 1 ? argv[1] : "/tmp/_DSC6843.JPG";
        const char *outputFilename = argc > 2 ? argv[2] : "/tmp/output.tiff";
        
        CGLPixelFormatObj pfa = createPFA();
        if ( ! pfa )
            return 1;
        
        CGLContextObj cgl_ctx = createCGLContext(pfa);
        
        if ( nil == cgl_ctx ) {
            CGLReleasePixelFormat(pfa);
            return 1;
        }
        
        CGColorSpaceRef cs = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
        //
        // if instead of running on the GPU you wanted to run this all on the CPU then in the options
        // dictionary you would set kCIContextUseSoftwareRenderer to TRUE in addition to using
        // a CL_DEVICE_TYPE_CPU when allocating a Dehaze object.
        //
        CIContext *context = [CIContext contextWithCGLContext:cgl_ctx pixelFormat:pfa colorSpace:cs options:nil];
        CGLReleasePixelFormat(pfa);
        CGColorSpaceRelease (cs);
        
        //
        // When creating a GPU based dehazer we specify the GL context so that we ensure to use the same share
        // group for OpenGL and OpenCL thus ensuring that everyone has access to the same data.
        //
        // Part of the beauty of using IOSurface as the intermediate format in between Core Image and OpenCL
        // is that none of the underlying code needs to change and we can just use a different type of device
        // and everything just works. This would not be the case if we were using OpenGL textures or a random
        // byte buffer.
        //
        
        const int maxImageSize = 1024; // max output size for our image
        const bool useGPU = true; // set this to false if you want to use the CPU instead
        Dehaze *dehazer = useGPU ? [[Dehaze alloc] initWithFilename:inputFilename maxSize:maxImageSize context:context glContext:cgl_ctx] : nil;
        
        if ( nil == dehazer ) // if we either asked for a GPU based context and couldn't find one or we wanted a CPU based context then:
            dehazer = [[Dehaze alloc] initWithFilename:inputFilename maxSize:maxImageSize context:context deviceType:CL_DEVICE_TYPE_CPU];
        
        CGLReleaseContext(cgl_ctx);
        
        //
        // the xSpanFraction determines how wide the morphological min will search for a minimum value and it is based
        // on a fraction of the width of the image for if your input image is 1500 pixels wide and you specify a fraction
        // of 15.0 then you would end up with a search of 100 pixels (in each direction) for that pass. Same logic applies
        // to the ySpanFraction and the blurFraction is based on the width of the image.
        //
        CIImage *outputImage = dehazer ?  [dehazer runXSpanFraction:15.0 ySpanFraction:256.0 blurFraction:20.0] : nil;
        
        if ( outputImage ) {
            CGImageRef image = [context createCGImage:outputImage fromRect:[outputImage extent]];
            
            if ( image ) {
                NSURL *outputURL = [NSURL fileURLWithPath:[NSString stringWithUTF8String:outputFilename]];
                
                CGImageDestinationRef dest = CGImageDestinationCreateWithURL((CFURLRef)outputURL, CFSTR("public.tiff"), 0, nil);
                
                if ( dest ) {
                    CGImageDestinationAddImage(dest, image, nil);
                    success = CGImageDestinationFinalize(dest);
                    
                    if ( success )
                        NSLog(@"Successfully wrote file at location %@",outputURL);
                    
                    CFRelease (dest);
                }
                
                CGImageRelease (image);
            }
        }
        [dehazer release];
        
    }
    return 1 == success;
}

