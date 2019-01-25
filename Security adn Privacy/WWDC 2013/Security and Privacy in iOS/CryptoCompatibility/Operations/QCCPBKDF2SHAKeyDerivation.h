/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Derives a key from a password string using the PBKDF2 algorithm.
 */

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/*! Denotes a specific SHA digest algorithm used internally the key derivation.
 *  \warning SHA1 may not secure; if you have a choice, choose SHA2-256 or better.
 */

typedef NS_ENUM(NSInteger, QCCPBKDF2SHAKeyDerivationAlgorithm) {
    QCCPBKDF2SHAKeyDerivationAlgorithmSHA1, 
    QCCPBKDF2SHAKeyDerivationAlgorithmSHA2_224, 
    QCCPBKDF2SHAKeyDerivationAlgorithmSHA2_256,
    QCCPBKDF2SHAKeyDerivationAlgorithmSHA2_384,
    QCCPBKDF2SHAKeyDerivationAlgorithmSHA2_512 
};

/*! Derives a key from a password string using the PBKDF2 algorithm.
 *  \details One key aspect of PBKDF2 is that it takes a significant amount of time to calculate the 
 *      key from the password, which helps to defeat brute force attacks.  This time is proportional  
 *      to the number of 'rounds' done by PBKDF2.  To get the best security, you should set 'rounds' 
 *      as high as you can such that PBKDF2 in a reasonable amount of time on your target hardware.
 *
 *      This operation facilitates this by allowing you to specify a target derivation time.  The 
 *      operation will automatically set the rounds parameter so that key derivation takes that 
 *      amount of time on the current hardware.  It will also return the number of rounds taken, 
 *      so you can save that away along with the key and the salt.
 *
 *  \warning You should *always* set the salt to some random data and save that random data along 
 *      with the key.  This a) ensures that users with the same password don't end up using the same 
 *      key, and b) as a consequence of this, protects from rainbow table attacks.
 *
 *  \details To use this operation, first generate a key:
 *
 *          1. use a cryptographically sound random number generator to generate some salt data
 *          
 *          2. initialise the object with the required parameters, including that random salt
 *          
 *          3. set `derivationTime` to a reasonable derivation time for a typical user login
 *          
 *          4. run the operation
 *          
 *          5. save the salt, the actual rounds and the derived key
 *          
 *      When the user tries to log in you can run the operation again:
 *
 *          1. initialise the object with the required parameters, where the password string 
 *              is the string the user entered and the salt is the salt you saved with the key
 *          
 *          2. set the operation's rounds to be rounds you saved with the key
 *          
 *          3. run the operation
 *          
 *          4. get the derived key and compare it to your saved key
 */

@interface QCCPBKDF2SHAKeyDerivation : NSOperation

/*! Initialise the object to derive a key from the specified password..
 *  \param algorithm The specific SHA digest algorithm to use for the key derivation.
 *  \param passwordString The password string from which to derive a key; may be empty.
 *  \param saltData Some random data to salt the key derivation.
 *  \returns The initialised object.
 */

- (instancetype)initWithAlgorithm:(QCCPBKDF2SHAKeyDerivationAlgorithm)algorithm passwordString:(NSString *)passwordString saltData:(NSData *)saltData NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/*! The specific SHA digest algorithm to use for the key derivation.
 *  \details This is set by the init method.
 */

@property (atomic, assign, readonly ) QCCPBKDF2SHAKeyDerivationAlgorithm    algorithm;

/*! The password string from which to derive a key
 *  \details This is set by the init method.
 */

@property (atomic, copy,   readonly ) NSString *                            passwordString;

/*! Some random data to salt the key derivation.
 *  \details This is set by the init method.
 */

@property (atomic, copy,   readonly ) NSData *                              saltData;

/*! The number of rounds to use for the key derivation. 
 *  \details The default value is 0, which tells the operation to automatically calculate the 
 *      numbers of rounds based on `derivationTime`.  That's a good choice when deriving a new 
 *      key.  When checking a key you should set this to the number of rounds that were used  
 *      to derive the original key.
 *
 *      If you set this, you must set it before queuing the operation.
 */

@property (atomic, assign, readwrite) NSInteger                             rounds;

/*! The target key derivation time. 
 *  \details If `rounds` is 0, this value is used as a target key derivation time; otherwise, 
 *      this value is ignored.  The default is 0.1 seconds.
 *      
 *      The underlying API accepts this key derivation time as a `uint32_t` number of 
 *      milliseconds.  This means that values less than 1 ms or greater than 0xFFFFFFFF 
 *      milliseconds are silently clipped.
 *
 *      If you set this, you must set it before queuing the operation.
 */

@property (atomic, assign, readwrite) NSTimeInterval                        derivationTime;

/*! The size of the derived key.
 *  \details The default is 16 bytes.
 *
 *      If you set this, you must set it before queuing the operation.
 */

@property (atomic, assign, readwrite) NSInteger                             derivedKeyLength;

/*! The error, if any, resulting from key derivation operation.
 *  \details This is set when the operation is finished.  On success, it will be nil.  Or error, 
 *      it will hold a value describing that error.  You should expect errors to be in the 
 *      `QCCPBKDF2KeyDerivationErrorDomain` error domain.
 */

@property (atomic, copy,   readonly, nullable) NSError *                    error;

/*! The number of rounds used to derive the key.
 *  \details This is only meaningful when the operation has finished without error.   If `rounds` 
 *      was non-zero, this will be equal to it.  If `rounds` was 0, this will be the actual number 
 *      of rounds used to derive the key based on the target time set via `derivationTime`.
 */

@property (atomic, assign, readonly)           NSInteger                    actualRounds;

/*! The derived key.
 *  \details This is only meaningful when the operation has finished without error.   The length 
 *      of this key will match `derivedKeyLength`.
 */

@property (atomic, copy,   readonly, nullable) NSData *                     derivedKeyData;

@end

/*! The error domain for the QCCPBKDF2SHAKeyDerivation operation.
 *  \details Codes are Common Crypto error codes, that is, `kCCParamError` and its friends.
 */

extern NSString * QCCPBKDF2KeyDerivationErrorDomain; 

NS_ASSUME_NONNULL_END
