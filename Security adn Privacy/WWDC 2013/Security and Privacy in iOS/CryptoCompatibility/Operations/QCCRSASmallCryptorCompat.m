/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Implements RSA encryption and decryption in a maximally compatible way.
 */

#import "QCCRSASmallCryptorCompat.h"

typedef NS_ENUM(NSInteger, QCCRSASmallCryptorOperationCompat) {
    QCCRSASmallCryptorCompatOperationEncrypt, 
    QCCRSASmallCryptorCompatOperationDecrypt
};

NS_ASSUME_NONNULL_BEGIN

@interface QCCRSASmallCryptorCompat ()

- (instancetype)initWithOperation:(QCCRSASmallCryptorOperationCompat)op smallInputData:(NSData *)smallInputData key:(SecKeyRef)key NS_DESIGNATED_INITIALIZER;

@property (atomic, assign, readonly ) QCCRSASmallCryptorOperationCompat op;

// read/write versions of public properties

@property (atomic, copy,   readwrite, nullable) NSError *           error;
@property (atomic, copy,   readwrite, nullable) NSData *            smallOutputData;

@end

NS_ASSUME_NONNULL_END

@implementation QCCRSASmallCryptorCompat

- (instancetype)init {
    abort();
}

- (instancetype)initWithOperation:(QCCRSASmallCryptorOperationCompat)op smallInputData:(NSData *)smallInputData key:(SecKeyRef)key {
    NSParameterAssert(smallInputData != nil);
    NSParameterAssert(key != NULL);
    self = [super init];
    if (self != nil) {
        self->_op = op;
        self->_smallInputData = [smallInputData copy];
        self->_key = key;
        self->_padding = QCCRSASmallCryptorCompatPaddingPKCS1;
    }
    return self;
}

- (instancetype)initToEncryptSmallInputData:(NSData *)smallInputData key:(SecKeyRef)key {
    return [self initWithOperation:QCCRSASmallCryptorCompatOperationEncrypt smallInputData:smallInputData key:key];
}

- (instancetype)initToDecryptSmallInputData:(NSData *)smallInputData key:(SecKeyRef)key {
    return [self initWithOperation:QCCRSASmallCryptorCompatOperationDecrypt smallInputData:smallInputData key:key];
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
        case QCCRSASmallCryptorCompatPaddingPKCS1: {
            algorithm = kSecKeyAlgorithmRSAEncryptionPKCS1;
        } break;
        case QCCRSASmallCryptorCompatPaddingOAEP: {
            algorithm = kSecKeyAlgorithmRSAEncryptionOAEPSHA1;
        } break;
    }
    
    // Do the crypto.
    
    switch (self.op) {
        default:
            assert(NO);
            // fall through
        case QCCRSASmallCryptorCompatOperationEncrypt: {
            resultData = CFBridgingRelease( SecKeyCreateEncryptedData(
                self.key, 
                algorithm, 
                (__bridge CFDataRef) self.smallInputData, 
                &errorCF
            ) );
        } break;
        case QCCRSASmallCryptorCompatOperationDecrypt: {
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

#if TARGET_OS_IPHONE

- (void)runUsingRaw {
    OSStatus            err;
    SecPadding          padding;
    NSMutableData *     resultData;
    size_t              resultDataLength;

    // Map our padding constant appropriately.
        
    switch (self.padding) {
        default:
            assert(NO);
            // fall through
        case QCCRSASmallCryptorCompatPaddingPKCS1: {
            padding = kSecPaddingPKCS1;
        } break;
        case QCCRSASmallCryptorCompatPaddingOAEP: {
            padding = kSecPaddingOAEP;
        } break;
    }
    
    // Do the crypto.
        
    resultData = [[NSMutableData alloc] initWithLength:SecKeyGetBlockSize(self.key)];
    resultDataLength = resultData.length;
    switch (self.op) {
        default:
            assert(NO);
            // fall through
        case QCCRSASmallCryptorCompatOperationEncrypt: {
            err = SecKeyEncrypt(
                self.key, 
                padding, 
                self.smallInputData.bytes, self.smallInputData.length, 
                resultData.mutableBytes, &resultDataLength
            );
        } break;
        case QCCRSASmallCryptorCompatOperationDecrypt: {
            err = SecKeyDecrypt(
                self.key, 
                padding, 
                self.smallInputData.bytes, self.smallInputData.length, 
                resultData.mutableBytes, &resultDataLength
            );
        } break;
    }
    
    // Set up the result.
    
    if (err == errSecSuccess) {
        // Set the output length to the value returned by the crypto.  This is necessary because, 
        // in the decrypt case, the padding means we have allocated more space that we need.
        resultData.length = resultDataLength;
        self.smallOutputData = resultData;
    } else {
        self.error = [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
    }    
}

#endif

#if TARGET_OS_OSX

- (void)runUsingTransforms {
    BOOL                success;
    CFErrorRef          errorCF;
    SecTransformRef     transform;
    CFStringRef         paddingStr;
    CFDataRef           resultData;

    transform = NULL;
    errorCF = NULL;
    resultData = NULL;

    // First determine the padding.
    
    success = YES;
    switch (self.padding) {
        default:
            assert(NO);
            // fall through
        case QCCRSASmallCryptorCompatPaddingPKCS1: {
            // For an RSA key the transform does PKCS#1 padding by default.  Weirdly, if we explicitly 
            // set the padding to kSecPaddingPKCS1Key then the transform fails <rdar://problem/13661366>.  
            // Thus, if the client has requested PKCS#1, we leave paddingStr set to NULL, which prevents 
            // us explicitly setting the padding to anything, which avoids the error while giving us 
            // PKCS#1 padding.
            
            // paddingStr = kSecPaddingPKCS1Key;
            paddingStr = NULL;
        } break;
        case QCCRSASmallCryptorCompatPaddingOAEP: {
            paddingStr = kSecPaddingOAEPKey;
        } break;
    }
    
    // Now create and execute the transform.
    
    if (success) {
        switch (self.op) {
            default:
                assert(NO);
                // fall through
            case QCCRSASmallCryptorCompatOperationEncrypt: {
                transform = SecEncryptTransformCreate(self.key, &errorCF);
            } break;
            case QCCRSASmallCryptorCompatOperationDecrypt: {
                transform = SecDecryptTransformCreate(self.key, &errorCF);
            } break;
        }
        success = (transform != NULL);
    }
    if (success && (paddingStr != NULL)) {
        success = SecTransformSetAttribute(transform, kSecPaddingKey, paddingStr, &errorCF) != false;
    }
    if (success) {
        success = SecTransformSetAttribute(transform, kSecTransformInputAttributeName, (__bridge CFDataRef) self.smallInputData, &errorCF) != false;
    }
    if (success) {
        resultData = SecTransformExecute(transform, &errorCF);
        success = (resultData != NULL);
    }
    if (success) {
        self.smallOutputData = (__bridge NSData *) resultData;
    } else {
        assert(errorCF != NULL);
        self.error = (__bridge NSError *) errorCF;
    }
    
    if (resultData != NULL) {
        CFRelease(resultData);
    }
    if (errorCF != NULL) {
        CFRelease(errorCF);
    }
    if (transform != NULL) {
        CFRelease(transform);
    }
}

#endif

- (void)main {
    OSStatus                err;
    NSUInteger              smallInputDataLength;
    NSUInteger              keyBlockSize;
    
    smallInputDataLength = self.smallInputData.length;
    keyBlockSize = SecKeyGetBlockSize(self.key);
    
    // Prior to OS X 10.8, SecKeyGetBlockSize returns the key size in bits rather than the 
    // block size <rdar://problem/10623794>.  It's easy correct this, at least for RSA keys, 
    // by simply dividing the value by 8.  I've removed that code because we no longer support 
    // OS X 10.8 but it would be easy to bring back.

    // Check that the input data length makes sense.  In most cases these checks are 
    // redundant (because the underlying crypto operation does the same checks) but 
    // it's good to have them here to help with debugging.  If you get the length 
    // wrong, you can set a breakpoint here and learn what's wrong.
    
    err = errSecSuccess;
    switch (self.op) {
        default:
            assert(NO);
            // fall through
        case QCCRSASmallCryptorCompatOperationEncrypt: {
            switch (self.padding) {
                default:
                    assert(NO);
                    // fall through
                case QCCRSASmallCryptorCompatPaddingPKCS1: {
                    assert(keyBlockSize > 11);
                    if ((smallInputDataLength + 11) > keyBlockSize) {
                        err = errSecParam;
                    }
                } break;
                case QCCRSASmallCryptorCompatPaddingOAEP: {
                    // 42 is 2 + 2 * HashLen, where HashLen is the length of the hash 
                    // use by the OAEP algorithm.  We currently only support OAEP with SHA1, 
                    // which has a hash length of 20.
                    //
                    // The fact that this is The Answer is just a happy coincidence.
                    assert(keyBlockSize > 42);
                    if ((smallInputDataLength + 42) > keyBlockSize) {
                        err = errSecParam;
                    }
                } break;
            }
        } break;
        case QCCRSASmallCryptorCompatOperationDecrypt: {
            if (smallInputDataLength != keyBlockSize) {
                err = errSecParam;
            }
        } break;
    }

    // If everything is OK, call the real code.
    
    if (err != errSecSuccess) {
        self.error = [NSError errorWithDomain:NSOSStatusErrorDomain code:errSecParam userInfo:nil];
    } else {
        if ( (SecKeyCreateEncryptedData != NULL) && ! self.debugUseCompatibilityCode) {
            [self runUsingUnified];
        } else {
            #if TARGET_OS_OSX
                [self runUsingTransforms];
            #elif TARGET_OS_IPHONE
                [self runUsingRaw];
            #else
                #error What platform?
            #endif
        }
    }
}

@end
