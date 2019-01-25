/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Hex dump utilities.
 */

#import "QHex.h"

@implementation QHex

+ (NSString *)hexStringWithBytes:(const void *)bytes length:(NSUInteger)length {
    NSMutableString *   result;
    
    NSParameterAssert(bytes != nil);
    
    result = [[NSMutableString alloc] initWithCapacity:length * 2];
    for (size_t i = 0; i < length; i++) {
        [result appendFormat:@"%02x", ((const uint8_t *) bytes)[i]];
    }
    return result;
}

+ (NSString *)hexStringWithData:(NSData *)data {
    NSParameterAssert(data != nil);
    return [[self class] hexStringWithBytes:data.bytes length:data.length];
}

+ (nullable NSData *)optionalDataWithHexString:(NSString *)hexString {
    NSMutableData *     result;
    NSUInteger          cursor;
    NSUInteger          limit;

    NSParameterAssert(hexString != nil);
    
    result = nil;
    cursor = 0;
    limit = hexString.length;
    if ((limit % 2) == 0) {
        result = [[NSMutableData alloc] init];
        
        while (cursor != limit) {
            unsigned int    thisUInt;
            uint8_t         thisByte;
            
            if ( sscanf([hexString substringWithRange:NSMakeRange(cursor, 2)].UTF8String, "%x", &thisUInt) != 1 ) {
                result = nil;
                break;
            }
            thisByte = (uint8_t) thisUInt;
            [result appendBytes:&thisByte length:sizeof(thisByte)];
            cursor += 2;
        }
    }
    
    return result;
}

+ (NSData *)dataWithHexString:(NSString *)hexString {
    NSData *    result;
    
    result = [self optionalDataWithHexString:hexString];
    if (result == nil) {
        abort();
    }
    return result;
}

@end
