/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Calculates an authenticated message digest for some data using the HMAC-SHA algorithm.
 */

#import "QCCHMACSHAAuthentication.h"

#include <CommonCrypto/CommonCrypto.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCCHMACSHAAuthentication ()

// read/write versions of public properties

@property (atomic, copy,   readwrite, nullable) NSData *        outputHMAC;

@end

NS_ASSUME_NONNULL_END

@implementation QCCHMACSHAAuthentication

- (instancetype)init {
    abort();
}

- (instancetype)initWithAlgorithm:(QCCHMACSHAAuthenticationAlgorithm)algorithm inputData:(NSData *)inputData keyData:(NSData *)keyData {
    NSParameterAssert(inputData != nil);
    NSParameterAssert(keyData != nil);
    self = [super init];
    if (self != nil) {
        self->_algorithm = algorithm;
        self->_inputData = [inputData copy];
        self->_keyData = [keyData copy];
    }
    return self;
}

- (void)main {
    static const size_t kDigestSize[5] = {
        CC_SHA1_DIGEST_LENGTH, 
        CC_SHA224_DIGEST_LENGTH, 
        CC_SHA256_DIGEST_LENGTH, 
        CC_SHA384_DIGEST_LENGTH, 
        CC_SHA512_DIGEST_LENGTH
    };
    static const CCHmacAlgorithm kCCAlgorithm[5] = {
        kCCHmacAlgSHA1,
        kCCHmacAlgSHA224, 
        kCCHmacAlgSHA256, 
        kCCHmacAlgSHA384, 
        kCCHmacAlgSHA512
    };
    NSMutableData *         hmac;

    // The output length is determined by the hash algorithm, for example, SHA1 
    // implies that hmac must be CC_SHA1_DIGEST_LENGTH bytes long.

    hmac = [[NSMutableData alloc] initWithLength:kDigestSize[self.algorithm]];
    CCHmac(kCCAlgorithm[self.algorithm], self.keyData.bytes, self.keyData.length, self.inputData.bytes, self.inputData.length, hmac.mutableBytes);
    self.outputHMAC = hmac;
}

@end
