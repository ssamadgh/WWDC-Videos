/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Calculates an authenticated message digest for some data using the HMAC-SHA algorithm.
 */

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/*! Denotes a specific SHA digest algorithm used internally by the authenticated message digest.
 *  \warning SHA1 may not secure; if you have a choice, choose SHA2-256 or better.
 */

typedef NS_ENUM(NSInteger, QCCHMACSHAAuthenticationAlgorithm) {
    QCCHMACSHAAuthenticationAlgorithmSHA1, 
    QCCHMACSHAAuthenticationAlgorithmSHA2_224, 
    QCCHMACSHAAuthenticationAlgorithmSHA2_256,
    QCCHMACSHAAuthenticationAlgorithmSHA2_384,
    QCCHMACSHAAuthenticationAlgorithmSHA2_512 
};

/*! Calculates an authenticated message digest for some data using the HMAC-SHA algorithm.
 */

@interface QCCHMACSHAAuthentication : NSOperation

/*! Initialise the object to digest the supplied data.
 *  \param algorithm The specific SHA digest algorithm to use for the authenticated message digest.
 *  \param inputData The data to digest; this may be empty.
 *  \param keyData The key to use for the authenticated message digest; this may be empty, 
 *      although that would be very poor security.
 *  \returns The initialised object.
 */

- (instancetype)initWithAlgorithm:(QCCHMACSHAAuthenticationAlgorithm)algorithm inputData:(NSData *)inputData keyData:(NSData *)keyData NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/*! The specific SHA digest algorithm to use for the authenticated message digest.
 *  \details This is set by the init method.
 */

@property (atomic, assign, readonly ) QCCHMACSHAAuthenticationAlgorithm algorithm;

/*! The data to digest.
 *  \details This is set by the init method.
 */

@property (atomic, copy,   readonly ) NSData *                          inputData;

/*! The key to use for the authenticated message digest.
 *  \details This is set by the init method.
 */

@property (atomic, copy,   readonly ) NSData *                          keyData;

/*! The output authenticated digest. 
 *  \details This is set when the operation is finished.  The length of this data will be 
 *      determined by the specific digest algorithm.  For example, if you specify the 
 *      SHA2-256 algorithm (`QCCHMACSHAAuthenticationAlgorithmSHA2_256`) then the length of 
 *      this data will be 32 bytes (`CC_SHA256_DIGEST_LENGTH`).
 */

@property (atomic, copy,   readonly, nullable) NSData *                 outputHMAC;

@end

NS_ASSUME_NONNULL_END
