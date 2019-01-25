/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Implements RSA SHA signature signing and verification using the unified crypto API.
 */

#import "QCCRSASHASignature.h"

#include <CommonCrypto/CommonCrypto.h>

static SecKeyAlgorithm _Nonnull secAlgorithmForAlgorithm(QCCRSASHASignatureAlgorithm algorithm) {
    switch (algorithm) {
        case QCCRSASHASignatureAlgorithmSHA1:     { return kSecKeyAlgorithmRSASignatureMessagePKCS1v15SHA1;   } break;
        case QCCRSASHASignatureAlgorithmSHA2_224: { return kSecKeyAlgorithmRSASignatureMessagePKCS1v15SHA224; } break;
        case QCCRSASHASignatureAlgorithmSHA2_256: { return kSecKeyAlgorithmRSASignatureMessagePKCS1v15SHA256; } break;
        case QCCRSASHASignatureAlgorithmSHA2_384: { return kSecKeyAlgorithmRSASignatureMessagePKCS1v15SHA384; } break;
        case QCCRSASHASignatureAlgorithmSHA2_512: { return kSecKeyAlgorithmRSASignatureMessagePKCS1v15SHA512; } break;
        default: { abort(); } break;
    }
}

#pragma mark - Sign

NS_ASSUME_NONNULL_BEGIN

@interface QCCRSASHAVerify ()

// read/write versions of public properties

@property (atomic, copy,   readwrite, nullable) NSError *   error;
@property (atomic, assign, readwrite)           BOOL        verified;

@end

NS_ASSUME_NONNULL_END

@implementation QCCRSASHAVerify

- (instancetype)init {
    abort();
}

- (instancetype)initWithAlgorithm:(QCCRSASHASignatureAlgorithm)algorithm inputData:(NSData *)inputData publicKey:(SecKeyRef)publicKey signatureData:(NSData *)signatureData {
    NSParameterAssert(inputData != nil);
    NSParameterAssert(publicKey != NULL);
    NSParameterAssert(signatureData != nil);
    self = [super init];
    if (self != nil) {
        self->_algorithm = algorithm;
        self->_inputData = [inputData copy];
        self->_publicKey = publicKey;
        self->_signatureData = [signatureData copy];
    }
    return self;
}

- (void)runUsingUnified {
    CFErrorRef          errorCF = NULL;

    // Verify the signature against our input data.  We don't need to calculate our own digest 
    // because we're using a kSecKeyAlgorithmRSASignatureMessageXxx algorithm, which takes an 
    // input message and generate the digest internally.
    //
    // If you /need/ to verify a digest rather than a message, check out the code for 
    // QCCRSASHAVerifyCompat which shows how to do that.
    
    self.verified = SecKeyVerifySignature(
        self.publicKey, 
        secAlgorithmForAlgorithm(self.algorithm), 
        (__bridge CFDataRef) self.inputData, 
        (__bridge CFDataRef) self.signatureData, 
        &errorCF
    ) != false;
    
    // Deal with the results.
    
    if ( ! self.verified ) {
        NSError *   error;
        
        error = CFBridgingRelease( errorCF );
        if ([error.domain isEqual:NSOSStatusErrorDomain] && (error.code == errSecVerifyFailed)) {
            // An explicit verify failure is not considered an error.
            assert(self.error == nil);
        } else {
            self.error = error;
        }
    }
}

- (void)main {
    [self runUsingUnified];
}

@end

#pragma mark - Sign

NS_ASSUME_NONNULL_BEGIN

@interface QCCRSASHASign ()

// read/write versions of public properties

@property (atomic, copy,   readwrite, nullable) NSError *   error;
@property (atomic, copy,   readwrite, nullable) NSData *    signatureData;

@end

NS_ASSUME_NONNULL_END

@implementation QCCRSASHASign

- (instancetype)initWithAlgorithm:(QCCRSASHASignatureAlgorithm)algorithm inputData:(NSData *)inputData privateKey:(SecKeyRef)privateKey {
    NSParameterAssert(inputData != nil);
    NSParameterAssert(privateKey != NULL);
    self = [super init];
    if (self != nil) {
        self->_algorithm = algorithm;
        self->_inputData = [inputData copy];
        self->_privateKey = privateKey;
    }
    return self;
}

- (instancetype)init {
    abort();
}

- (void)runUsingUnified {
    CFErrorRef      errorCF = NULL;
    NSData *        resultData;

    // Sign the input data.   We don't need to calculate our own digest because we're using 
    // a kSecKeyAlgorithmRSASignatureMessageXxx algorithm, which takes an input message 
    // and generate the digest internally.
    //
    // If you /need/ to sign a digest rather than a message, check out the code for 
    // QCCRSASHASignCompat which shows how to do that.
    
    resultData = CFBridgingRelease( SecKeyCreateSignature(
        self.privateKey, 
        secAlgorithmForAlgorithm(self.algorithm), 
        (__bridge CFDataRef) self.inputData, 
        &errorCF
    ) );
    
    // Deal with the results.
    
    if (resultData == nil) {
        self.error = CFBridgingRelease( errorCF );
    } else {
        self.signatureData = resultData;
    }
}

- (void)main {
    [self runUsingUnified];
}

@end
