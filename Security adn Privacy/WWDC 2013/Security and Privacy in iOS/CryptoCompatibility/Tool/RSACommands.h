/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Commands for RSA-based encryption, decryption, signing, and verification.
 */

#import "QToolCommand.h"

NS_ASSUME_NONNULL_BEGIN

/*! Implements the `rsa-verify` command.
 */

@interface RSASHAVerifyCommand : QToolCommand

@end

/*! Implements the `rsa-sign` command.
 */

@interface RSASHASignCommand : QToolCommand

@end

/*! A base class for the `RSASmallEncryptCommand` and `RSASmallDecryptCommand` classes.
 */

@interface RSACryptorCommand : QToolCommand

@end

/*! Implements the `rsa-small-encrypt` command.
 */

@interface RSASmallEncryptCommand : RSACryptorCommand

@end

/*! Implements the `rsa-small-decrypt` command.
 */

@interface RSASmallDecryptCommand : RSACryptorCommand

@end

NS_ASSUME_NONNULL_END
