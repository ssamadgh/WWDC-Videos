/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Implements Base64 decoding.
 */

#import "QCCBase64Decode.h"

NS_ASSUME_NONNULL_BEGIN

@interface QCCBase64Decode ()

// read/write versions of public properties

@property (atomic, copy,   readwrite, nullable) NSData *        outputData;

@end

NS_ASSUME_NONNULL_END

@implementation QCCBase64Decode

- (instancetype)init {
    abort();
}

- (instancetype)initWithInputString:(NSString *)inputString {
    NSParameterAssert(inputString != nil);
    self = [super init];
    if (self != nil) {
        self->_inputString = [inputString copy];
    }
    return self;
}

- (void)main {
    self.outputData = [[NSData alloc] initWithBase64EncodedString:self.inputString options:NSDataBase64DecodingIgnoreUnknownCharacters];
}

@end
