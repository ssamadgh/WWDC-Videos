/*
     File: Run.m
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

#import "Run.h"
#import "RunManager.h"
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface Run ()
{
    NSUInteger _photoCounter;
    __strong NSString *_photoPath;
}
@property (nonatomic, strong) NSUUID *uuid;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSMutableDictionary *imageObjects;
@end

@implementation Run

+ (CGSize)previewPhotoSize {
    return CGSizeMake(75,138);
}

- (id)init {
    self = [super init];
    if (self != nil) {
        _uuid = [NSUUID UUID];
        _imageObjects = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_uuid forKey:@"kRun_UUID"];
    [aCoder encodeObject:_when forKey:@"kRun_When"];
    [aCoder encodeObject:_where forKey:@"kRun_Where"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self != nil) {
        id obj = [aDecoder decodeObjectForKey:@"kRun_UUID"];
        if (obj) {
            _uuid = (NSUUID *)obj;
        }
        
        obj = [aDecoder decodeObjectForKey:@"kRun_When"];
        if (obj) {
            _when = (NSDate *)obj;
        }
        
        NSString *string = [aDecoder decodeObjectForKey:@"kRun_Where"];
        if (string) {
            _where = string;
        }
        
        _imageObjects = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSString *)_photoPath {
    if (!_photoPath) {
        _photoPath = [NSString stringWithFormat:@"%@/%@", [RunManager photoSavePath], [self.uuid UUIDString]];
        NSFileManager *fm = [[NSFileManager alloc] init];
        if (![fm fileExistsAtPath:_photoPath]) {
            [fm createDirectoryAtPath:_photoPath withIntermediateDirectories:YES attributes:nil error:nil];
            [fm createDirectoryAtPath:[_photoPath stringByAppendingPathComponent:@"previews"] withIntermediateDirectories:YES attributes:nil error:nil];
            [fm createDirectoryAtPath:[_photoPath stringByAppendingPathComponent:@"photos"] withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    
    return _photoPath;
}

- (void)_loadPhotos {
    if (!self.photos) {
        NSFileManager *fm = [[NSFileManager alloc] init];
        self.photos = [fm contentsOfDirectoryAtPath:[[self _photoPath] stringByAppendingPathComponent:@"previews"] error:nil];
    }
}

- (NSUInteger)numberOfPhotos {
    [self _loadPhotos];
    return [self.photos count];
}

- (UIImage *)photoAtIndex:(NSUInteger)idx ofType:(RunPhotoType)type {
    [self _loadPhotos];
    UIImage *img = nil;
    if (idx < [self.photos count]) {
        NSString *photoName = [self.photos objectAtIndex:idx];
        if (type == RunPhotoTypePreview) {
            img = [self.imageObjects objectForKey:photoName];
            if (!img) {
                NSString *imgPath = [[[self _photoPath] stringByAppendingPathComponent:@"previews"] stringByAppendingPathComponent:photoName];
                img = [UIImage imageWithData:[NSData dataWithContentsOfFile:imgPath] scale:[[UIScreen mainScreen] scale]];
                [self.imageObjects setObject:img forKey:photoName];
            }
        }
        else {
            photoName = [[photoName stringByDeletingPathExtension] stringByAppendingPathExtension:@"jpg"];
            NSString *imgPath = [[[self _photoPath] stringByAppendingPathComponent:@"photos"] stringByAppendingPathComponent:photoName];
            img = [UIImage imageWithData:[NSData dataWithContentsOfFile:imgPath] scale:[[UIScreen mainScreen] scale]];
        }
    }
    return img;
}

- (BOOL)savePhotoData:(NSData *)photoData {
    UIImage *originalImage = [UIImage imageWithData:photoData];
    CGRect destRect = CGRectZero;
    destRect.size = [Run previewPhotoSize];
    UIGraphicsBeginImageContextWithOptions(destRect.size, NO, [[UIScreen mainScreen] scale]);
    [originalImage drawInRect:destRect];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    NSData *pngData = UIImagePNGRepresentation(scaledImage);
    
    NSString *savePNGPath = [NSString stringWithFormat:@"%@/previews/%08ld.png", [self _photoPath], (unsigned long)++_photoCounter];
    BOOL dataWroteSuccessfully = [pngData writeToFile:savePNGPath options:0 error:nil];
        
    NSString *saveJPGPath = [NSString stringWithFormat:@"%@/photos/%08ld.jpg", [self _photoPath], (unsigned long)_photoCounter];
    dataWroteSuccessfully &= [photoData writeToFile:saveJPGPath options:0 error:nil];
    
    return dataWroteSuccessfully;
}

- (void)deletePhotoAtIndex:(NSUInteger)idx {
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSString *photoName = [self.photos objectAtIndex:idx];
    for (NSArray *parts in @[ @[@"previews", @"png"], @[@"photos", @"jpg"]]) {
        NSString *subpath = parts[0];
        NSString *extension = parts[1];
        photoName = [[photoName stringByDeletingPathExtension] stringByAppendingPathExtension:extension];
        NSString *photoPath = [[[self _photoPath] stringByAppendingPathComponent:subpath] stringByAppendingPathComponent:photoName];
        [fm removeItemAtPath:photoPath error:nil];
    }
    
    NSMutableArray *newPhotoList = [self.photos mutableCopy];
    [newPhotoList removeObjectAtIndex:idx];
    self.photos = newPhotoList;
    
    [self.imageObjects removeObjectForKey:photoName];
}

- (NSString *)identifier {
    return [self.uuid UUIDString];
}

- (NSString *)description {
    NSString *desc = [NSString stringWithFormat:@"<%@ %p> [%@] - \"%@\" on %@; %d photos", NSStringFromClass([self class]), self, [self identifier], self.where, [self.when descriptionWithLocale:[NSLocale currentLocale]], (unsigned int)[self numberOfPhotos]];
    return desc;
}

@end
