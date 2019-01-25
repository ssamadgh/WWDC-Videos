/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Implements AES encryption and decryption with PKCS#7 padding in a way that's suitable for large data sets.
 */

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/*! Implements AES encryption and decryption with PKCS#7 padding in a way that's suitable for large data sets.
 *  \details The key difference between this and `QCCAESPadCryptor` is that this operation 
 *      reads its input data from a stream and writes its output data to a stream, rather than 
 *      requiring the data to be in memory.
 *      
 *      In padded AES, the unencrypted data can be of any length wbile the length of the 
 *      encrypted data is always an even multiple of the AES block size (`kCCBlockSizeAES128`, 
 *      or 16).  Encrypted the data will always increase its length (slightly), while decrypting 
 *      it will do the reverse.
 *
 *      This operation supports both EBC and CBC mode.
 *      
 *  \warning In most cases you will want to use AES in CBC mode; to do that securely, set the 
 *      initialisation vector (via the `ivData` property) to some cryptographically sound 
 *      random data.  If you need to use EBC mode, which is generally not recommended, set 
 *      the `ivData` property to nil.
 *      
 *  \note The designated initialiser for this class is private.  In the unlikely event you 
 *      need to subclass it, you will have to make that public.
 *      
 *  \note The operation reads and writes the streams synchronously, making it only suitable for 
 *      use with file streams.  An operation that supported network streams would be significantly 
 *      more complex.
 */

@interface QCCAESPadBigCryptor : NSOperation

/*! Initialise the object to encrypt data using a key.
 *  \details When initialised this way, the operation will read the input stream, encrypt the data 
 *      with the supplied key, and write that to the output stream.
 *
 *      Both the input and output streams are opened if necessary (if the stream state is  
 *      `NSStreamStatusNotOpen`) and, if they are opened, will be closed at the end.
 *
 *      On error, the content of the output stream is unspecified.
 *  \param inputStream The source of unencrypted data; this stream can be of any length.
 *  \param outputStream The sink for encrypted data; on success, the final output stream length will 
 *      be slightly longer than the input stream length, and that length will always be an even 
 *      multiple of the AES block size (`kCCBlockSizeAES128`, or 16). 
 *  \param keyData The key used to encrypt the data; its length must must be one of the 
 *      standard AES key sizes (128 bits, `kCCKeySizeAES128`, 16 bytes; 192 bits, 
 *      `kCCKeySizeAES192`, 24 bytes; 256 bits, `kCCKeySizeAES256`, or 32 bytes).
 *  \returns The initialised object.
 */

- (instancetype)initToEncryptInputStream:(NSInputStream *)inputStream toOutputStream:(NSOutputStream *)outputStream keyData:(NSData *)keyData;

/*! Initialise the object to decrypt data using a key.
 *  \details When initialised this way, the operation will read the input stream, decrypt the data 
 *      with the supplied key, and write that to the output stream. 
 *
 *      Both the input and output streams are opened if necessary (if the stream state is  
 *      `NSStreamStatusNotOpen`) and, if they are opened, will be closed at the end.
 *
 *      An error, the content of the output stream is unspecified.
 *  \param inputStream The source of encrypted data; the length of this stream must be an even 
 *      multiple of the AES block size (`kCCBlockSizeAES128`, or 16). 
 *  \param outputStream The sink for decrypted data; this can of any length although it will only 
 *      be slightly shorter than the input stream.  
 *  \param keyData The key used to decrypt the data; its length must must be one of the 
 *      standard AES key sizes (128 bits, `kCCKeySizeAES128`, 16 bytes; 192 bits, 
 *      `kCCKeySizeAES192`, 24 bytes; 256 bits, `kCCKeySizeAES256`, or 32 bytes).
 *  \returns The initialised object.
 */

- (instancetype)initToDecryptInputStream:(NSInputStream *)inputStream toOutputStream:(NSOutputStream *)outputStream keyData:(NSData *)keyData;

- (instancetype)init NS_UNAVAILABLE;

/*! A stream of data to be encrypted or decrypted.
 *  \details This is set by the init method.
 */

@property (atomic, strong, readonly ) NSInputStream *       inputStream;

/*! A stream in which to place the output data.
 *  \details This is set by the init method.
 *
 *      This still will be opened if necessary (if the stream state is `NSStreamStatusNotOpen`)   
 *      and, if it was opened, will be closed at the end.
 */

@property (atomic, strong, readonly ) NSOutputStream *      outputStream;

/*! The key with which to do the encryption or decryption.
 *  \details This is set by the init method.
 *
 *      This still will be opened if necessary (if the stream state is `NSStreamStatusNotOpen`)   
 *      and, if it was opened, will be closed at the end.
 *
 *      On error, the content of this stream are unspecified.
 */

@property (atomic, copy,   readonly ) NSData *              keyData;

/*! The initialisation vector for the encryption or decryption. 
 *  \details Set this to nil to use EBC mode.  To use CBC mode securely, set this to an 
 *      initialisation vector generated by a cryptographically sound random number generator.  
 *      Its length must be the AES block size (`kCCBlockSizeAES128`, or 16).
 *      
 *      If you set this, you must set it before queuing the operation.
 *
 *  \warning The default value is an initialisation vector all zeroes.  This is not good 
 *      from a security standard, although still better than EBC mode.
 */

@property (atomic, copy,   readwrite, nullable) NSData *    ivData; 

/*! The error, if any, resulting from encryption or decryption operation.
 *  \details This is set when the operation is finished.  On success, it will be nil.  Or error, 
 *      it will hold a value describing that error.  Errors can be in the `QCCAESPadBigCryptorErrorDomain` 
 *      but will most likely be in error domains associated with the stream I/O.
 *
 *  \warning Do not expect an error if the data has been corrupted.  The underlying crypto  
 *      system does not report errors in that case because it can lead to 
 *      padding oracle attacks.  If you need to check whether the data has arrived intact, 
 *      use a separate message authentication code (MAC), often generated using HMAC-SHA as 
 *      implemented by the QCCHMACSHAAuthentication operation.
 *
 *      <https://en.wikipedia.org/wiki/Padding_oracle_attack>
 */

@property (atomic, copy,   readonly,  nullable) NSError *   error;

@end

/*! The error domain for the QCCAESPadBigCryptor operation.
 *  \details Codes are Common Crypto error codes, that is, `kCCParamError` and its friends.
 *      Note that this domain is only used for crypto errors.  If there's an error reading 
 *      or writing the streams, that error will be returned directly.
 */

extern NSString * QCCAESPadBigCryptorErrorDomain;

NS_ASSUME_NONNULL_END
