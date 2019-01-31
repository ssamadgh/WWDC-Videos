/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Managed object class for the Quake entity.
 */

#import "AAPLQuake.h"

NSString *const JSONPropertiesKeyCode = @"code";
NSString *const JSONPropertiesKeyMagnitude = @"mag";
NSString *const JSONPropertiesKeyPlaceName = @"place";
NSString *const JSONPropertiesKeyDetailURL = @"detail";
NSString *const JSONPropertiesKeyTime = @"time";
NSString *const JSONPropertiesKeyLocation = @"geometry";

@implementation AAPLQuake

@dynamic magnitude;
@dynamic placeName;
@dynamic time;
@dynamic longitude;
@dynamic latitude;
@dynamic depth;
@dynamic detailURL;
@dynamic code;

- (void)updateFromDictionary:(NSDictionary *)quakeDictionary {
    [quakeDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        // Ignore the key / value pair if the value is NSNull.
        if ([value isEqual:[NSNull null]]) {
            return;
        }

        if ([key isEqualToString:JSONPropertiesKeyCode]) {
            self.code = value;
        }
        else if ([key isEqualToString:JSONPropertiesKeyMagnitude]) {
            self.magnitude = [value floatValue];
        }
        else if ([key isEqualToString:JSONPropertiesKeyPlaceName]) {
            self.placeName = value;
        }
        else if ([key isEqualToString:JSONPropertiesKeyMagnitude]) {
            self.magnitude = [value floatValue];
        }
        else if ([key isEqualToString:JSONPropertiesKeyDetailURL]) {
            self.detailURL = value;
        }
        else if ([key isEqualToString:JSONPropertiesKeyTime]) {
            NSNumber *time = value;
            NSTimeInterval timeInterval = [time doubleValue] / 1000.0;

            self.time = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        }
        else if ([key isEqualToString:JSONPropertiesKeyLocation]) {
            NSDictionary *geometry = value;
            NSArray *coordinates = geometry[@"coordinates"];

            // The longitude, latitude, and depth values are stored in an array in JSON.
            // Access these values by index directly.
            self.longitude = [coordinates[0] floatValue];
            self.latitude = [coordinates[1] floatValue];
            self.depth = [coordinates[2] floatValue];
        }
    }];
}

@end
