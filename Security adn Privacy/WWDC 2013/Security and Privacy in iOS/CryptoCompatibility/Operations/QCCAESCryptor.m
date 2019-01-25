/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Implements AES encryption and decryption without padding.
 */

#import "QCCAESCryptor.h"

#include <CommonCrypto/CommonCrypto.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCCAESCryptor ()

- (instancetype)initWithOp:(CCOperation)op inputData:(NSData *)inputData keyData:(NSData *)keyData NS_DESIGNATED_INITIALIZER;

@property (atomic, assign, readonly ) CCOperation   op;

// read/write versions of public properties

@property (atomic, copy,   readwrite, nullable) NSError *   error;
@property (atomic, copy,   readwrite, nullable) NSData *    outputData;

@end

NS_ASSUME_NONNULL_END

@implementation QCCAESCryptor

- (instancetype)init {
    abort();
}

- (instancetype)initWithOp:(CCOperation)op inputData:(NSData *)inputData keyData:(NSData *)keyData {
    NSParameterAssert(inputData != nil);
    NSParameterAssert(keyData != nil);
    self = [super init];
    if (self != nil) {
        self->_op = op;
        self->_inputData = [inputData copy];
        self->_keyData = [keyData copy];
        self->_ivData = [[NSMutableData alloc] initWithLength:kCCBlockSizeAES128];
    }
    return self;
}

- (instancetype)initToEncryptInputData:(NSData *)inputData keyData:(NSData *)keyData {
    return [self initWithOp:kCCEncrypt inputData:inputData keyData:keyData];
}

- (instancetype)initToDecryptInputData:(NSData *)inputData keyData:(NSData *)keyData {
    return [self initWithOp:kCCDecrypt inputData:inputData keyData:keyData];
}

- (void)main {
    CCCryptorStatus     err;
    NSUInteger          keyDataLength;
    NSMutableData *     result;
    size_t              resultLength;
    
    // We check for common input problems to make it easier for someone tracing through 
    // the code to find problems (rather than just getting a mysterious kCCParamError back 
    // from CCCrypt).
    
    err = kCCSuccess;
    if ((self.inputData.length % kCCBlockSizeAES128) != 0) {
        err = kCCParamError;
    }
    keyDataLength = self.keyData.length;
    if ( (keyDataLength != kCCKeySizeAES128) && (keyDataLength != kCCKeySizeAES192) && (keyDataLength != kCCKeySizeAES256) ) {
        err = kCCParamError;
    }
    if ( (self.ivData != nil) && (self.ivData.length != kCCBlockSizeAES128) ) {
        err = kCCParamError;
    }
    
    if (err == kCCSuccess) {
        result = [[NSMutableData alloc] initWithLength:self.inputData.length];

        err = CCCrypt(
            self.op, 
            kCCAlgorithmAES128, 
            (self.ivData == nil) ? kCCOptionECBMode : 0, 
            self.keyData.bytes, self.keyData.length, 
            self.ivData.bytes,                                  // will be NULL if ivData is nil
            self.inputData.bytes, self.inputData.length, 
            result.mutableBytes,  result.length, 
            &resultLength
        );
    }
    if (err == kCCSuccess) {
        // In the absence of padding the data out is always the same size as the data in.
        assert(resultLength == [result length]);
        self.outputData = result;
    } else {
        self.error = [NSError errorWithDomain:QCCAESCryptorErrorDomain code:err userInfo:nil];
    }
}

@end

NSString * QCCAESCryptorErrorDomain = @"QCCAESCryptorErrorDomain";
