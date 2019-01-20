/*
     File: InterfaceManager.m
 Abstract: 
 
  Version: 1.0
 
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
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 
 Copyright © 2013 Apple Inc. All rights reserved.
 WWDC 2013 License
 
 NOTE: This Apple Software was supplied by Apple as part of a WWDC 2013
 Session. Please refer to the applicable WWDC 2013 Session for further
 information.
 
 IMPORTANT: This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and
 your use, installation, modification or redistribution of this Apple
 software constitutes acceptance of these terms. If you do not agree with
 these terms, please do not use, install, modify or redistribute this
 Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple
 Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple. Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis. APPLE MAKES
 NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE
 IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 EA1002
 5/3/2013
 */

#import "InterfaceManager.h"
#import "RunManager.h"
#import "UIImage+ImageEffects.h"

static NSString *_rootInterfacePath() {
    __strong static NSString *_interfacePath = nil;
    if (!_interfacePath) {
        _interfacePath = [_rootDataPath() stringByAppendingPathComponent:@"interface"];
        
        NSFileManager *fm = [[NSFileManager alloc] init];
        if (![fm fileExistsAtPath:_interfacePath]) {
            [fm createDirectoryAtPath:_interfacePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    
    return _interfacePath;
}

@interface InterfaceManager ()
{
    __strong UIImage *_backgroundImage;
}
@property (nonatomic, readwrite) UIImage *blurredBackgroundImage;
@end

@implementation InterfaceManager

-(UIImage *)backgroundImage {
    if (!_backgroundImage) {
        _backgroundImage = [UIImage imageWithContentsOfFile:[_rootInterfacePath() stringByAppendingPathComponent:@"backgroundImage.jpg"]];
    }

    return _backgroundImage;
}

- (void)_writeImage:(UIImage *)image toFilename:(NSString *)filename {
    if (!image || !filename || [filename length] == 0) { return; }
    
    NSData *imgData = UIImageJPEGRepresentation(image, 1.0);
    if (imgData) {
        [imgData writeToFile:[_rootInterfacePath() stringByAppendingPathComponent:filename] options:NSDataWritingAtomic error:nil];
    }
}

-(void)setBackgroundImage:(UIImage *)image {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGRect destRect = CGRectZero;
        destRect.size = [[UIScreen mainScreen] bounds].size;
        UIGraphicsBeginImageContextWithOptions(destRect.size, NO, [[UIScreen mainScreen] scale]);
        [image drawInRect:destRect];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        _backgroundImage = scaledImage;
        [self _writeImage:_backgroundImage toFilename:@"backgroundImage.jpg"];
        
        _blurredBackgroundImage = [scaledImage applyLightEffect];
        [self _writeImage:_blurredBackgroundImage toFilename:@"blurredBackgroundImage.jpg"];
    });
}

- (UIImage *)blurredBackgroundImage {
    if (!_blurredBackgroundImage) {
        _blurredBackgroundImage = [UIImage imageWithContentsOfFile:[_rootInterfacePath() stringByAppendingPathComponent:@"blurredBackgroundImage.jpg"]];

        if (!_blurredBackgroundImage) {
            _blurredBackgroundImage = [[self backgroundImage] applyLightEffect];
            
            [self _writeImage:_blurredBackgroundImage toFilename:@"blurredBackgroundImage.jpg"];
        }
    }
    
    return _blurredBackgroundImage;
}

@end
