/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Calculates the SHA digest of some data.
 */

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/*! Denotes a specific SHA digest algorithm.
 *  \warning SHA1 is probably not secure; if you have a choice, choose SHA2-256 
 *      or better.
 */

typedef NS_ENUM(NSInteger, QCCSHADigestAlgorithm) {
    QCCSHADigestAlgorithmSHA1, 
    QCCSHADigestAlgorithmSHA2_224, 
    QCCSHADigestAlgorithmSHA2_256,
    QCCSHADigestAlgorithmSHA2_384,
    QCCSHADigestAlgorithmSHA2_512 
};

/*! Calculates the SHA digest of some data.
 */

@interface QCCSHADigest : NSOperation

/*! Initialise the object to digest the supplied data.
 *  \param algorithm The specific SHA digest algorithm to use.
 *  \param inputData The data to digest; this may be empty.
 *  \returns The initialised object.
 */

- (instancetype)initWithAlgorithm:(QCCSHADigestAlgorithm)algorithm inputData:(NSData *)inputData NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/*! The specific SHA digest algorithm to use.
 *  \details This is set by the init method.
 */

@property (atomic, assign, readonly ) QCCSHADigestAlgorithm algorithm;

/*! The data to digest.
 *  \details This is set by the init method.
 */

@property (atomic, copy,   readonly ) NSData *              inputData;

/*! The output digest. 
 *  \details This is set when the operation is finished.  The length of this data will be  
 *      determined by the specific digest algorithm.  For example, if you specify the 
 *      SHA2-256 algorithm (`QCCSHADigestAlgorithmSHA2_256`) then the length of this data  
 *      will be 32 bytes (`CC_SHA256_DIGEST_LENGTH`).
 */

@property (atomic, copy,   readonly, nullable) NSData *     outputDigest;

@end

NS_ASSUME_NONNULL_END
