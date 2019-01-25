/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Commands for symmetric encryption and decryption.
 */

#import "QToolCommand.h"

NS_ASSUME_NONNULL_BEGIN

/*! A base class for all the AES commands.
 */

@interface AESCryptorCommand : QToolCommand

@end

/*! Implements the `aes-encrypt` command.
 */

@interface AESEncryptCommand : AESCryptorCommand

@end

/*! Implements the `aes-decrypt` command.
 */

@interface AESDecryptCommand : AESCryptorCommand

@end

/*! Implements the `aes-pad-encrypt` command.
 */

@interface AESPadEncryptCommand : AESCryptorCommand

@end

/*! Implements the `aes-pad-decrypt` command.
 */

@interface AESPadDecryptCommand : AESCryptorCommand

@end

/*! A base class for the AES 'big' cryptor commands.
 */

@interface AESBigCryptorCommand : AESCryptorCommand

@end

/*! Implements the `aes-pad-big-encrypt` command.
 */

@interface AESPadBigEncryptCommand : AESBigCryptorCommand

@end

/*! Implements the `aes-pad-big-decrypt` command.
 */

@interface AESPadBigDecryptCommand : AESBigCryptorCommand

@end

NS_ASSUME_NONNULL_END
