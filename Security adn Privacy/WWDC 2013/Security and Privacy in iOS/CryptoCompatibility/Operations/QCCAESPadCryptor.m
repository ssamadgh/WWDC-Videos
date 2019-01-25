/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Implements AES encryption and decryption with PKCS#7 padding.
 */

#import "QCCAESPadCryptor.h"

#include <CommonCrypto/CommonCrypto.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCCAESPadCryptor ()

- (instancetype)initWithOp:(CCOperation)op inputData:(NSData *)inputData keyData:(NSData *)keyData NS_DESIGNATED_INITIALIZER;

@property (atomic, assign, readonly ) CCOperation   op;

// read/write versions of public properties

@property (atomic, copy,   readwrite, nullable) NSError *   error;
@property (atomic, copy,   readwrite, nullable) NSData *    outputData;

@end

NS_ASSUME_NONNULL_END

@implementation QCCAESPadCryptor

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
    if ( (self.op == kCCDecrypt) && ((self.inputData.length % kCCBlockSizeAES128) != 0) ) {
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
        NSUInteger      padLength;
        
        // Padding can expand the data, so we have to allocate space for that.  The rule for block 
        // cyphers, like AES, is that the padding only adds space on encryption (on decryption it 
        // can reduce space, obviously, but we don't need to account for that) and it will only add 
        // at most one block size worth of space.

        if (self.op == kCCEncrypt) {
            padLength = kCCBlockSizeAES128;
        } else {
            padLength = 0;
        }
        result = [[NSMutableData alloc] initWithLength:self.inputData.length + padLength];

        err = CCCrypt(
            self.op, 
            kCCAlgorithmAES128, 
            ((self.ivData == nil) ? kCCOptionECBMode : 0) | kCCOptionPKCS7Padding,
            self.keyData.bytes, self.keyData.length, 
            self.ivData.bytes,                                  // will be NULL if ivData is nil
            self.inputData.bytes, self.inputData.length, 
            result.mutableBytes, result.length, 
            &resultLength
        );
    }
    if (err == kCCSuccess) {
        // Set the output length to the value returned by CCCrypt.  This is necessary because 
        // we have padding enabled, meaning that we might have allocated more space than we needed 
        // (in the encrypt case, this is the space we allocated above for padding; in the decrypt 
        // case, the output is actually shorter than the input because the padding is removed).
        result.length = resultLength;
        self.outputData = result;
    } else {
        self.error = [NSError errorWithDomain:QCCAESPadCryptorErrorDomain code:err userInfo:nil];
    }
}

@end

NSString * QCCAESPadCryptorErrorDomain = @"QCCAESPadCryptorErrorDomain";
