/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Implements RSA encryption and decryption using the unified crypto API.
 */

#import "QCCRSASmallCryptor.h"

typedef NS_ENUM(NSInteger, QCCRSASmallCryptorOperation) {
    QCCRSASmallCryptorOperationEncrypt, 
    QCCRSASmallCryptorOperationDecrypt
};

NS_ASSUME_NONNULL_BEGIN

@interface QCCRSASmallCryptor ()

- (instancetype)initWithOperation:(QCCRSASmallCryptorOperation)op smallInputData:(NSData *)smallInputData key:(SecKeyRef)key NS_DESIGNATED_INITIALIZER;

@property (atomic, assign, readonly ) QCCRSASmallCryptorOperation   op;

// read/write versions of public properties

@property (atomic, copy,   readwrite, nullable) NSError *           error;
@property (atomic, copy,   readwrite, nullable) NSData *            smallOutputData;

@end

NS_ASSUME_NONNULL_END

@implementation QCCRSASmallCryptor

- (instancetype)init {
    abort();
}

- (instancetype)initWithOperation:(QCCRSASmallCryptorOperation)op smallInputData:(NSData *)smallInputData key:(SecKeyRef)key {
    NSParameterAssert(smallInputData != nil);
    NSParameterAssert(key != NULL);
    self = [super init];
    if (self != nil) {
        self->_op = op;
        self->_smallInputData = [smallInputData copy];
        self->_key = key;
        self->_padding = QCCRSASmallCryptorPaddingPKCS1;
    }
    return self;
}

- (instancetype)initToEncryptSmallInputData:(NSData *)smallInputData key:(SecKeyRef)key {
    return [self initWithOperation:QCCRSASmallCryptorOperationEncrypt smallInputData:smallInputData key:key];
}

- (instancetype)initToDecryptSmallInputData:(NSData *)smallInputData key:(SecKeyRef)key {
    return [self initWithOperation:QCCRSASmallCryptorOperationDecrypt smallInputData:smallInputData key:key];
}

- (void)runUsingUnified {
    CFErrorRef          errorCF = NULL;     // Security framework seems to be grumpy if errorCF left uninitialised 
    SecKeyAlgorithm     algorithm;
    NSData *            resultData;

    // Map our padding constant appropriately.
        
    switch (self.padding) {
        default:
            assert(NO);
            // fall through
        case QCCRSASmallCryptorPaddingPKCS1: {
            algorithm = kSecKeyAlgorithmRSAEncryptionPKCS1;
        } break;
        case QCCRSASmallCryptorPaddingOAEP: {
            algorithm = kSecKeyAlgorithmRSAEncryptionOAEPSHA1;
        } break;
    }
    
    // Do the crypto.
    
    switch (self.op) {
        default:
            assert(NO);
            // fall through
        case QCCRSASmallCryptorOperationEncrypt: {
            resultData = CFBridgingRelease( SecKeyCreateEncryptedData(
                self.key, 
                algorithm, 
                (__bridge CFDataRef) self.smallInputData, 
                &errorCF
            ) );
        } break;
        case QCCRSASmallCryptorOperationDecrypt: {
            resultData = CFBridgingRelease( SecKeyCreateDecryptedData(
                self.key, 
                algorithm, 
                (__bridge CFDataRef) self.smallInputData, 
                &errorCF
            ) );
        } break;
    }
    
    // Set up the result.

    if (resultData == nil) {
        self.error = CFBridgingRelease( errorCF );
    } else {
        self.smallOutputData = resultData;
    }
}

- (void)main {
    OSStatus                err;
    NSUInteger              smallInputDataLength;
    NSUInteger              keyBlockSize;
    
    smallInputDataLength = self.smallInputData.length;
    keyBlockSize = SecKeyGetBlockSize(self.key);

    // Check that the input data length makes sense.  In most cases these checks are 
    // redundant (because the underlying crypto operation does the same checks) but 
    // it's good to have them here to help with debugging.  If you get the length 
    // wrong, you can set a breakpoint here and learn what's wrong.
    
    err = errSecSuccess;
    switch (self.op) {
        default:
            assert(NO);
            // fall through
        case QCCRSASmallCryptorOperationEncrypt: {
            switch (self.padding) {
                default:
                    assert(NO);
                    // fall through
                case QCCRSASmallCryptorPaddingPKCS1: {
                    assert(keyBlockSize > 11);
                    if ((smallInputDataLength + 11) > keyBlockSize) {
                        err = errSecParam;
                    }
                } break;
                case QCCRSASmallCryptorPaddingOAEP: {
                    // 42 is 2 + 2 * HashLen, where HashLen is the length of the hash 
                    // use by the OAEP algorithm.  We currently only support OAEP with SHA1, 
                    // which has a hash length of 20.
                    assert(keyBlockSize > 42);
                    if ((smallInputDataLength + 42) > keyBlockSize) {
                        err = errSecParam;
                    }
                } break;
            }
        } break;
        case QCCRSASmallCryptorOperationDecrypt: {
            if (smallInputDataLength != keyBlockSize) {
                err = errSecParam;
            }
        } break;
    }

    // If everything is OK, call the real code.
    
    if (err != errSecSuccess) {
        self.error = [NSError errorWithDomain:NSOSStatusErrorDomain code:errSecParam userInfo:nil];
    } else {
        [self runUsingUnified];
    }
}

@end
