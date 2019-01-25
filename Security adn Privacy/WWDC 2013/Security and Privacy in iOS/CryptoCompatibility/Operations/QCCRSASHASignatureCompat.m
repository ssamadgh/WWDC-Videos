/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Implements RSA SHA signature signing and verification in a maximally compatible way.
 */

#import "QCCRSASHASignatureCompat.h"

#include <CommonCrypto/CommonCrypto.h>

static SecKeyAlgorithm _Nonnull secAlgorithmForAlgorithm(QCCRSASHASignatureCompatAlgorithm algorithm) {
    switch (algorithm) {
        case QCCRSASHASignatureCompatAlgorithmSHA1:     { return kSecKeyAlgorithmRSASignatureDigestPKCS1v15SHA1;   } break;
        case QCCRSASHASignatureCompatAlgorithmSHA2_224: { return kSecKeyAlgorithmRSASignatureDigestPKCS1v15SHA224; } break;
        case QCCRSASHASignatureCompatAlgorithmSHA2_256: { return kSecKeyAlgorithmRSASignatureDigestPKCS1v15SHA256; } break;
        case QCCRSASHASignatureCompatAlgorithmSHA2_384: { return kSecKeyAlgorithmRSASignatureDigestPKCS1v15SHA384; } break;
        case QCCRSASHASignatureCompatAlgorithmSHA2_512: { return kSecKeyAlgorithmRSASignatureDigestPKCS1v15SHA512; } break;
        default: { abort(); } break;
    }
}

static NSData * _Nonnull digestForAlgorithmOverInputData(QCCRSASHASignatureCompatAlgorithm algorithm, NSData * _Nonnull inputData) {
    NSMutableData *     digest;
    
    switch (algorithm) {
        case QCCRSASHASignatureCompatAlgorithmSHA1:     {
            digest = [[NSMutableData alloc] initWithLength:CC_SHA1_DIGEST_LENGTH];
            (void) CC_SHA1(inputData.bytes, (CC_LONG) inputData.length, digest.mutableBytes);
        } break;
        case QCCRSASHASignatureCompatAlgorithmSHA2_224: {
            digest = [[NSMutableData alloc] initWithLength:CC_SHA224_DIGEST_LENGTH];
            (void) CC_SHA224(inputData.bytes, (CC_LONG) inputData.length, digest.mutableBytes);
        } break;
        case QCCRSASHASignatureCompatAlgorithmSHA2_256: {
            digest = [[NSMutableData alloc] initWithLength:CC_SHA256_DIGEST_LENGTH];
            (void) CC_SHA256(inputData.bytes, (CC_LONG) inputData.length, digest.mutableBytes);
        } break;
        case QCCRSASHASignatureCompatAlgorithmSHA2_384: {
            digest = [[NSMutableData alloc] initWithLength:CC_SHA384_DIGEST_LENGTH];
            (void) CC_SHA384(inputData.bytes, (CC_LONG) inputData.length, digest.mutableBytes);
        } break;
        case QCCRSASHASignatureCompatAlgorithmSHA2_512: {
            digest = [[NSMutableData alloc] initWithLength:CC_SHA512_DIGEST_LENGTH];
            (void) CC_SHA512(inputData.bytes, (CC_LONG) inputData.length, digest.mutableBytes);
        } break;
        default: { abort(); } break;
    }
    return digest;
}

#pragma mark - Verify

NS_ASSUME_NONNULL_BEGIN

@interface QCCRSASHAVerifyCompat ()

// read/write versions of public properties

@property (atomic, copy,   readwrite, nullable) NSError *   error;
@property (atomic, assign, readwrite)           BOOL        verified;

@end

NS_ASSUME_NONNULL_END

@implementation QCCRSASHAVerifyCompat

- (instancetype)init {
    abort();
}

- (instancetype)initWithAlgorithm:(QCCRSASHASignatureCompatAlgorithm)algorithm inputData:(NSData *)inputData publicKey:(SecKeyRef)publicKey signatureData:(NSData *)signatureData {
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
    NSData *            digest;
    CFErrorRef          errorCF = NULL;

    // First create a SHA digest of the data (this works out the right SecKeyAlgorithm at the same time).
    // 
    // You can simplify this process by passing in a kSecKeyAlgorithmRSASignatureMessageXxx algorithm, 
    // whereupon the system will automatically calculate the digest for you.  For an example of this, 
    // see QCCRSASHAVerify.  However, in some cases it's necessary to verify a digest directly, and this 
    // code shows how to do that. 

    digest = digestForAlgorithmOverInputData(self.algorithm, self.inputData);
    
    // Then verify it.
    
    self.verified = SecKeyVerifySignature(
        self.publicKey, 
        secAlgorithmForAlgorithm(self.algorithm), 
        (__bridge CFDataRef) digest, 
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

#if TARGET_OS_OSX

static BOOL setupTransformForAlgorithm(SecTransformRef transform, QCCRSASHASignatureCompatAlgorithm algorithm, CFErrorRef _Nullable * _Nullable  errorCFPtr) {
    BOOL    success;
    
    if (algorithm == QCCRSASHASignatureCompatAlgorithmSHA1) {
        success = SecTransformSetAttribute(transform, kSecDigestTypeAttribute, kSecDigestSHA1, errorCFPtr) != false;
    } else {
        success = SecTransformSetAttribute(transform, kSecDigestTypeAttribute, kSecDigestSHA2, errorCFPtr) != false;
        if (success) {
            NSInteger   digestSize;
            
            switch (algorithm) {
                case QCCRSASHASignatureCompatAlgorithmSHA1:     { abort();   } break;
                case QCCRSASHASignatureCompatAlgorithmSHA2_224: { digestSize = 224; } break;
                case QCCRSASHASignatureCompatAlgorithmSHA2_256: { digestSize = 256; } break;
                case QCCRSASHASignatureCompatAlgorithmSHA2_384: { digestSize = 384; } break;
                case QCCRSASHASignatureCompatAlgorithmSHA2_512: { digestSize = 512; } break;
                default: { abort(); } break;
            }
            success = SecTransformSetAttribute(transform, kSecDigestLengthAttribute, (__bridge CFNumberRef) @(digestSize), errorCFPtr) != false;
        }
    }
    return success;
}

- (void)runUsingTransforms {
    BOOL                success;
    SecTransformRef     transform;
    CFBooleanRef        result;
    CFErrorRef          errorCF;
    
    result = NULL;
    errorCF = NULL;
    
    // Set up the transform.
    
    transform = SecVerifyTransformCreate(self.publicKey, (__bridge CFDataRef) self.signatureData, &errorCF);
    success = (transform != NULL);

    // Note: kSecInputIsAttributeName defaults to kSecInputIsPlainText, which is what we want.

    if (success) {
        success = setupTransformForAlgorithm(transform, self.algorithm, &errorCF);
    }

    if (success) {
        success = SecTransformSetAttribute(transform, kSecTransformInputAttributeName, (__bridge CFDataRef) self.inputData, &errorCF) != false;
    }

    // Run it.
    
    if (success) {
        result = SecTransformExecute(transform, &errorCF);
        success = (result != NULL);
    }
    
    // Process the results.
    
    if (success) {
        assert(CFGetTypeID(result) == CFBooleanGetTypeID());
        self.verified = (CFBooleanGetValue(result) != false);
    } else {
        assert(errorCF != NULL);
        self.error = (__bridge NSError *) errorCF;
    }
    
    // Clean up.

    if (result != NULL) {
        CFRelease(result);
    }
    if (errorCF != NULL) {
        CFRelease(errorCF);
    }
    if (transform != NULL) {
        CFRelease(transform);
    }
}

#endif

#if TARGET_OS_IPHONE

static SecPadding secPaddingForAlgorithm(QCCRSASHASignatureCompatAlgorithm algorithm) {
    switch (algorithm) {
        case QCCRSASHASignatureCompatAlgorithmSHA1:     { return kSecPaddingPKCS1SHA1;   } break;
        case QCCRSASHASignatureCompatAlgorithmSHA2_224: { return kSecPaddingPKCS1SHA224; } break;
        case QCCRSASHASignatureCompatAlgorithmSHA2_256: { return kSecPaddingPKCS1SHA256; } break;
        case QCCRSASHASignatureCompatAlgorithmSHA2_384: { return kSecPaddingPKCS1SHA384; } break;
        case QCCRSASHASignatureCompatAlgorithmSHA2_512: { return kSecPaddingPKCS1SHA512; } break;
        default: { abort(); } break;
    }
}

- (void)runUsingRaw {
    OSStatus    err;
    NSData *    digest;

    // First create a SHA digest of the data.
    
    digest = digestForAlgorithmOverInputData(self.algorithm, self.inputData);
    
    // Then verify it.
    
    err = SecKeyRawVerify(
        self.publicKey, 
        secPaddingForAlgorithm(self.algorithm), 
        digest.bytes, 
        digest.length, 
        self.signatureData.bytes, 
        self.signatureData.length
    );
    
    // Deal with the results.
    
    if (err == errSecSuccess) {
        self.verified = YES;
    } else if (err == errSSLCrypto) {
        assert( ! self.verified );
    } else {
        self.error = [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
    }
}

#endif

- (void)main {
    if ( (SecKeyVerifySignature != NULL) && ! self.debugUseCompatibilityCode) {
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

@end

#pragma mark - Sign

NS_ASSUME_NONNULL_BEGIN

@interface QCCRSASHASignCompat ()

// read/write versions of public properties

@property (atomic, copy,   readwrite, nullable) NSError *   error;
@property (atomic, copy,   readwrite, nullable) NSData *    signatureData;

@end

NS_ASSUME_NONNULL_END

@implementation QCCRSASHASignCompat

- (instancetype)init {
    abort();
}

- (instancetype)initWithAlgorithm:(QCCRSASHASignatureCompatAlgorithm)algorithm inputData:(NSData *)inputData privateKey:(SecKeyRef)privateKey {
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

- (void)runUsingUnified {
    CFErrorRef      errorCF = NULL;
    NSData *        digest;
    NSData *        resultData;

    // First create a SHA digest of the data.  This isn't strictly speaking necessary.  If you 
    // use a kSecKeyAlgorithmRSASignatureMessageXxx algorithm, the system will automatically 
    // calculate the digest for you.  For an example of this, see QCCRSASHASign.  However, in 
    // some cases it's necessary to sign a digest directly, and this code shows how to do that. 
    
    digest = digestForAlgorithmOverInputData(self.algorithm, self.inputData);

    // Then sign it.
    
    resultData = CFBridgingRelease( SecKeyCreateSignature(
        self.privateKey, 
        secAlgorithmForAlgorithm(self.algorithm), 
        (__bridge CFDataRef) digest, 
        &errorCF
    ) );
    
    // Deal with the results.
    
    if (resultData == nil) {
        self.error = CFBridgingRelease( errorCF );
    } else {
        self.signatureData = resultData;
    }
}

#if TARGET_OS_OSX

- (void)runUsingTransforms {
    BOOL                success;
    SecTransformRef     transform;
    CFDataRef           resultData;
    CFErrorRef          errorCF;
    
    resultData = NULL;
    errorCF = NULL;
    
    // Set up the transform.

    transform = SecSignTransformCreate(self.privateKey, &errorCF);
    success = (transform != NULL);
    
    if (success) {
        success = setupTransformForAlgorithm(transform, self.algorithm, &errorCF);
    }

    if (success) {
        success = SecTransformSetAttribute(transform, kSecTransformInputAttributeName, (__bridge CFDataRef) self.inputData, &errorCF) != false;
    }
    
    // Run it.

    if (success) {
        resultData = SecTransformExecute(transform, &errorCF);
        success = (resultData != NULL);
    }
    
    // Process the results.
    
    if (success) {
        assert(CFGetTypeID(resultData) == CFDataGetTypeID());
        self.signatureData = (__bridge NSData *) resultData;
    } else {
        assert(errorCF != NULL);
        self.error = (__bridge NSError *) errorCF;
    }

    // Clean up.
    
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

#if TARGET_OS_IPHONE

- (void)runUsingRaw {
    OSStatus            err;
    NSData *            digest;
    NSMutableData *     resultData;
    size_t              resultDataLength;
    
    // First create a SHA digest of the data.
    
    digest = digestForAlgorithmOverInputData(self.algorithm, self.inputData);
    
    // Then sign it.
    
    resultData = [[NSMutableData alloc] initWithLength:SecKeyGetBlockSize(self.privateKey)];
    resultDataLength = resultData.length;
    err = SecKeyRawSign(
        self.privateKey, 
        secPaddingForAlgorithm(self.algorithm), 
        digest.bytes, 
        digest.length, 
        resultData.mutableBytes, 
        &resultDataLength
    );

    // Deal with the results.

    if (err == errSecSuccess) {
        assert(resultDataLength == [resultData length]);
        self.signatureData = resultData;
    } else {
        self.error = [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
    }
}

#endif

- (void)main {
    if ( (SecKeyCreateSignature != NULL) && ! self.debugUseCompatibilityCode) {
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

@end
