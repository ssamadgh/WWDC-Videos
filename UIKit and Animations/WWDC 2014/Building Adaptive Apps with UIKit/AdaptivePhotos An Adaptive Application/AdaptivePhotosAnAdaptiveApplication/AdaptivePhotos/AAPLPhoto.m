/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  The model object that represents an individual photo.
  
 */

#import "AAPLPhoto.h"

@implementation AAPLPhoto

+ (instancetype)photoWithDictionary:(NSDictionary *)dictionary
{
    AAPLPhoto *photo = [[self alloc] init];
    photo.imageName = [dictionary objectForKey:@"imageName"];
    photo.comment = [dictionary objectForKey:@"comment"];
    photo.rating = [[dictionary objectForKey:@"rating"] integerValue];
    return photo;
}

- (UIImage *)image
{
    return [UIImage imageNamed:self.imageName];
}

@end
