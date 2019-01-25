/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Implements RSA encryption and decryption in a maximally compatible way.
 */

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/*! Denotes the RSA padding to use.
 *  \details The default is `QCCRSASmallCryptorCompatPaddingPKCS1`. 
 * 
 *  \note This operation only supports the traditional OAEP algorithm, as defined by 
 *      PKCS#1 v2 / RFC 2437.  That is, it uses SHA1 as its hash function.  It does not 
 *      support SHA2-based OAEP algorithms because it relies legacy APIs that only 
 *      support SHA1.
 */

typedef NS_ENUM(NSInteger, QCCRSASmallCryptorCompatPadding) {
    QCCRSASmallCryptorCompatPaddingPKCS1,
    QCCRSASmallCryptorCompatPaddingOAEP
};

/*! Implements RSA encryption and decryption for small chunks of data.
 *  \details The exact definition of "small" depends on the key size and the padding in 
 *      use.  The key size represents the maximum size, and from that you subtract 
 *      the padding overhead (11 bytes for PKCS#1, 42 bytes for OAEP).  For example, a 
 *      2048-bit key with PKCS#1 padding can encrypt 245 bytes (2048 bits -> 256 bytes - 11).   
 *      
 *  \warning This is for encrypting and decrypting small amounts of data, not an 
 *      entire file.  The standard technique for encrypting a large file is to 
 *      encrypt it with a symmetric algorithm (like AES-128), using a randomly generated 
 *      key, and then encrypt that key with RSA.  However, doing that sort of thing 
 *      correctly is a challenge and we recommend you use some standard encryption 
 *      scheme (such as CMS).
 *      
 *  \note The designated initialiser for this class is private.  In the unlikely event you 
 *      need to subclass it, you will have to make that public.
 *      
 *  \details This uses the unified asymmetric crypto API (added in iOS 10 and macOS 10.12) 
 *      if it's available, otherwise it falls back to platform-specific APIs (SecKeyRawXxx 
 *      on iOS-based platforms, SecTransforms on macOS).
 *
 *      If your deployment target is high enough to guarantee that the unified asymmetric crypto 
 *      API is available, consider using QCCRSASmallCryptor instead.
 */

@interface QCCRSASmallCryptorCompat : NSOperation

/*! Initialise the object to encrypt data using a public key.
 *  \param smallInputData A small amount of data to encrypt; the exact limit to this length 
 *      is determined by the key size and the padding as discussed above.
 *  \param key The public key used to encrypt the data.
 *  \returns The initialised object.
 */

- (instancetype)initToEncryptSmallInputData:(NSData *)smallInputData key:(SecKeyRef)key;

/*! Initialise the object to decrypt data using a private key.
 *  \param smallInputData The data to decrypt; its length must match the key size, for  
 *      example, for a 2048-bit key this must be 256 bytes. 
 *  \param key The private key used to decrypt the data.
 *  \returns The initialised object.
 */

- (instancetype)initToDecryptSmallInputData:(NSData *)smallInputData key:(SecKeyRef)key;

- (instancetype)init NS_UNAVAILABLE;

/*! The data to be encrypted or decrypted.
 *  \details This is set by the init method.
 */

@property (atomic, copy,   readonly ) NSData *                          smallInputData;

/*! The key with which to do the encryption (public key) or decryption (private key).
 *  \details This is set by the init method.
 */

@property (atomic, strong, readonly ) SecKeyRef                         key __attribute__ (( NSObject ));

/*! The padding to use. 
 *  \details The default is `QCCRSASmallCryptorCompatPaddingPKCS1`.
 *      
 *      If you set this, you must set it before queuing the operation.
 */

@property (atomic, assign, readwrite) QCCRSASmallCryptorCompatPadding   padding;

/*! Force the operation to use the compatibility code path.
 *  \details The default is false.  You might set this to true when testing and debugging.
 *      
 *      If you set this, you must set it before queuing the operation.
 */

@property (atomic, assign, readwrite) BOOL                              debugUseCompatibilityCode;

/*! The error, if any, resulting from encryption or decryption operation.
 *  \details This is set when the operation is finished.  On success, it will be nil.  Or error, 
 *      it will hold a value describing that error.
 */

@property (atomic, copy,   readonly, nullable) NSError *                error;     

/*! The output data.
 *  \details This is only meaningful when the operation has finished without error.
 *      If this is an encryption operation, this will be the input data encrypted using the 
 *      public key.  The output data length will match the key size so, for example, a 2048-bit 
 *      key will output 256 bytes.
 *
 *      If this is a decryption operation, this will be the input data decrypted using 
 *      the private key.  Its length will be strictly less than the input data length.
 */

@property (atomic, copy,   readonly, nullable) NSData *                 smallOutputData;

@end

NS_ASSUME_NONNULL_END
