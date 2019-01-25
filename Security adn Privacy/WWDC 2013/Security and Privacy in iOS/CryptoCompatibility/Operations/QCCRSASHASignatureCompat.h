/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Implements RSA SHA signature signing and verification in a maximally compatible way.
 */

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/*! Denotes a specific SHA-based RSA signature algorithm algorithm.
 */

typedef NS_ENUM(NSInteger, QCCRSASHASignatureCompatAlgorithm) {
    QCCRSASHASignatureCompatAlgorithmSHA1, 
    QCCRSASHASignatureCompatAlgorithmSHA2_224, 
    QCCRSASHASignatureCompatAlgorithmSHA2_256,
    QCCRSASHASignatureCompatAlgorithmSHA2_384,
    QCCRSASHASignatureCompatAlgorithmSHA2_512 
};

#pragma mark - Verify

/*! Verifies an RSA SHA signature.
 *  \details This uses the unified asymmetric crypto API (added in iOS 10 and macOS 10.12) 
 *      if it's available, otherwise it falls back to platform-specific APIs (SecKeyRawXxx 
 *      on iOS-based platforms, SecTransforms on macOS).
 *
 *      If your deployment target is high enough to guarantee that the unified asymmetric crypto 
 *      API is available, consider using QCCRSASHAVerify instead.
 */

@interface QCCRSASHAVerifyCompat : NSOperation

/*! Initialise the object to verify a signature.
 *  \param algorithm The specific SHA-based RSA signature algorithm to use.
 *  \param inputData The data whose signature you want to verify.  This is the original data itself, not 
 *      a digest of that data.
 *  \param publicKey The public key whose associated private key was used to generate the signature.
 *  \param signatureData The signature to verify; the length of this data is tied to the key size.  For example, 
 *      a 2048-bit RSA key will always generate a 256 byte signature.
 *  \returns The initialised object.
 */

- (instancetype)initWithAlgorithm:(QCCRSASHASignatureCompatAlgorithm)algorithm inputData:(NSData *)inputData publicKey:(SecKeyRef)publicKey signatureData:(NSData *)signatureData NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/*! The specific SHA-based RSA signature algorithm to use.
 *  \details This is set by the init method.
 */

@property (atomic, assign, readonly ) QCCRSASHASignatureCompatAlgorithm algorithm;

/*! The data whose signature you want to verify.
 *  \details This is set by the init method.
 */

@property (atomic, copy,   readonly ) NSData *                          inputData;

/*! The public key whose associated private key was used to generate the signature.
 *  \details This is set by the init method.
 */

@property (atomic, strong, readonly ) SecKeyRef                         publicKey __attribute__ (( NSObject ));

/*! The signature to verify.
 *  \details This is set by the init method.
 */

@property (atomic, copy,   readonly ) NSData *                          signatureData; 

/*! Force the operation to use the compatibility code path.
 *  \details The default is false.  You might set this to true when testing and debugging.
 *      
 *      If you set this, you must set it before queuing the operation.
 */

@property (atomic, assign, readwrite) BOOL                              debugUseCompatibilityCode;

/*! The error, if any, resulting from verification operation.
 *  \details This is set when the operation is finished.  On success, it will be nil.  Or error, 
 *      it will hold a value describing that error.
 *
 *      This will not be set if the verification fails.  Rather, this will be nil and `verified` 
 *      will be false.
 */

@property (atomic, copy,   readonly, nullable) NSError *                error;

/*! The verification result.
 *  \details This is only meaningful when the operation has finished.  It will be `NO` if there 
 *      was an error during verification (in which case `error` will be set) or the signature 
 *      was simply not verified (in which case `error` will be nil).
 */

@property (atomic, assign, readonly)           BOOL                     verified;

@end

#pragma mark - Sign

/*! Creating an RSA SHA signature.
 *  \details This uses the unified asymmetric crypto API (added in iOS 10 and macOS 10.12) 
 *      if it's available, otherwise it falls back to platform-specific APIs (SecKeyRawXxx 
 *      on iOS-based platforms, SecTransforms on macOS).
 *
 *      If your deployment target is high enough to guarantee that the unified asymmetric crypto 
 *      API is available, consider using QCCRSASHASign instead.
 */

@interface QCCRSASHASignCompat : NSOperation

/*! Initialise the object to create a signature.
 *  \param algorithm The specific SHA-based RSA signature algorithm to use.
 *  \param inputData The data that you want to sign.  This is the original data itself, not 
 *      a digest of that data.
 *  \param privateKey The private key used to generate the signature.
 *  \returns The initialised object.
 */

- (instancetype)initWithAlgorithm:(QCCRSASHASignatureCompatAlgorithm)algorithm inputData:(NSData *)inputData privateKey:(SecKeyRef)privateKey NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/*! The specific SHA-based RSA signature algorithm to use.
 *  \details This is set by the init method.
 */

@property (atomic, assign, readonly ) QCCRSASHASignatureCompatAlgorithm algorithm;

/*! The data that you want to sign.
 *  \details This is set by the init method.
 */

@property (atomic, copy,   readonly ) NSData *                          inputData;

/*! The private key used to generate the signature.
 *  \details This is set by the init method.
 */

@property (atomic, strong, readonly ) SecKeyRef                         privateKey __attribute__ (( NSObject ));

/*! Force the operation to use the compatibility code path.
 *  \details The default is false.  You might set this to true when testing and debugging.
 *      
 *      If you set this, you must set it before queuing the operation.
 */

@property (atomic, assign, readwrite) BOOL                              debugUseCompatibilityCode;

/*! The error, if any, resulting from signing operation.
 *  \details This is set when the operation is finished.  On success, it will be nil.  Or error, 
 *      it will hold a value describing that error.
 */

@property (atomic, copy,   readonly, nullable) NSError *                error;

/*! The generated signature.
 *  \details This is only meaningful when the operation has finished without error.   The length 
 *      of this data is tied to the key size.  For example, a 2048-bit RSA key will always generate 
 *      a 256 byte signature.
 */

@property (atomic, copy,   readonly, nullable) NSData *                 signatureData;

@end

NS_ASSUME_NONNULL_END
