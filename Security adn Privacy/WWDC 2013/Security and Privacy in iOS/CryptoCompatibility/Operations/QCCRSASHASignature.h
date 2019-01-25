/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Implements RSA SHA signature signing and verification using the unified crypto API.
 */

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/*! Denotes a specific SHA-based RSA signature algorithm algorithm.
 */

typedef NS_ENUM(NSInteger, QCCRSASHASignatureAlgorithm) {
    QCCRSASHASignatureAlgorithmSHA1, 
    QCCRSASHASignatureAlgorithmSHA2_224, 
    QCCRSASHASignatureAlgorithmSHA2_256,
    QCCRSASHASignatureAlgorithmSHA2_384,
    QCCRSASHASignatureAlgorithmSHA2_512 
};

#pragma mark - Verify

/*! Verifies an RSA SHA signature.
 *  \details This uses the unified asymmetric crypto API added in iOS 10 and macOS 10.12.
 *
 *      If your deployment target does not guarantee the availability of the unified asymmetric 
 *      crypto API, use QCCRSASHAVerifyCompat instead.
 */

@interface QCCRSASHAVerify : NSOperation

/*! Initialise the object to verify a signature.
 *  \param algorithm The specific SHA-based RSA signature algorithm to use.
 *  \param inputData The data whose signature you want to verify.  This is the original data itself, not 
 *      a digest of that data.
 *  \param publicKey The public key whose associated private key was used to generate the signature.
 *  \param signatureData The signature to verify; the length of this data is tied to the key size.  For example, 
 *      a 2048-bit RSA key will always generate a 256 byte signature.
 *  \returns The initialised object.
 */

- (instancetype)initWithAlgorithm:(QCCRSASHASignatureAlgorithm)algorithm inputData:(NSData *)inputData publicKey:(SecKeyRef)publicKey signatureData:(NSData *)signatureData NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/*! The specific SHA-based RSA signature algorithm to use.
 *  \details This is set by the init method.
 */

@property (atomic, assign, readonly ) QCCRSASHASignatureAlgorithm       algorithm;

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
 *  \details This uses the unified asymmetric crypto API added in iOS 10 and macOS 10.12.
 *
 *      If your deployment target does not guarantee the availability of the unified asymmetric 
 *      crypto API, use QCCRSASHASignCompat instead.
 */

@interface QCCRSASHASign : NSOperation

/*! Initialise the object to create a signature.
 *  \param algorithm The specific SHA-based RSA signature algorithm to use.
 *  \param inputData The data that you want to sign.  This is the original data itself, not 
 *      a digest of that data.
 *  \param privateKey The private key used to generate the signature.
 *  \returns The initialised object.
 */

- (instancetype)initWithAlgorithm:(QCCRSASHASignatureAlgorithm)algorithm inputData:(NSData *)inputData privateKey:(SecKeyRef)privateKey NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/*! The specific SHA-based RSA signature algorithm to use.
 *  \details This is set by the init method.
 */

@property (atomic, assign, readonly ) QCCRSASHASignatureAlgorithm       algorithm;

/*! The data that you want to sign.
 *  \details This is set by the init method.
 */

@property (atomic, copy,   readonly ) NSData *                          inputData;

/*! The private key used to generate the signature.
 *  \details This is set by the init method.
 */

@property (atomic, strong, readonly ) SecKeyRef                         privateKey __attribute__ (( NSObject ));

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
