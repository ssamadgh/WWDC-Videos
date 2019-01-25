/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Commands for RSA-based encryption, decryption, signing, and verification.
 */

#import "RSACommands.h"

#import "QCCRSASHASignatureCompat.h"
#import "QCCRSASmallCryptorCompat.h"

#import "ToolCommon.h"

#import "QHex.h"

static BOOL validFileArguments(NSArray * arguments) {
    BOOL        success;
    
    success = YES;
    for (NSString * filePath in arguments) {
        if ([NSURL fileURLWithPath:filePath] == nil) {
            success = NO;
        }
    }
    return success;
}

static SecKeyRef keyOfClassWithFile(CFStringRef keyClass, NSString * keyFilePath, NSError **errorPtr) {
    BOOL                success;
    OSStatus            err;
    NSURL *             keyFileURL;
    NSData *            keyPEMData;
    SecExternalItemType itemType;
    NSArray *           importedKeys;
    SecKeyRef           key;

    key = NULL;
    
    keyFileURL = [NSURL fileURLWithPath:keyFilePath];
    assert(keyFileURL != nil);      // checked by `validFileArguments`

    keyPEMData = [NSData dataWithContentsOfURL:keyFileURL options:(NSDataReadingOptions) 0 error:errorPtr];
    success = (keyPEMData != nil);
    
    if (success) {
        CFArrayRef      importedItems;

        err = SecItemImport(
            (__bridge CFDataRef) keyPEMData, 
            CFSTR("pem"), 
            NULL, 
            &itemType, 
            (SecItemImportExportFlags) 0, 
            NULL, 
            NULL, 
            &importedItems
        );
        success = (err == errSecSuccess);
        if (success) {
            importedKeys = CFBridgingRelease(importedItems);
        } else if (errorPtr != NULL) {
            *errorPtr = [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
        }
    }
    if (success) {
        success = (importedKeys.count == 1);
        if (success) {
            switch (itemType) {
                case kSecItemTypePrivateKey: {
                    success = CFEqual(keyClass, kSecAttrKeyClassPrivate) != false;
                } break;
                case kSecItemTypePublicKey: {
                    success = CFEqual(keyClass, kSecAttrKeyClassPublic) != false;
                } break;
                default: {
                    success = NO;
                } break;
            }
        }
        if ( ! success && (errorPtr != NULL) ) {
            *errorPtr = [NSError errorWithDomain:NSOSStatusErrorDomain code:errSecUnsupportedFormat userInfo:nil];
        }
    }
    if (success) {
        key = (SecKeyRef) CFRetain( (__bridge CFTypeRef) importedKeys[0] );
        CFAutorelease(key);
    }
    
    return key;
}

static SecKeyRef publicKeyWithFile(NSString * publicKeyFilePath, NSError **errorPtr) {
    return keyOfClassWithFile(kSecAttrKeyClassPublic, publicKeyFilePath, errorPtr);
}

static SecKeyRef privateKeyWithFile(NSString * privateKeyFilePath, NSError **errorPtr) {
    return keyOfClassWithFile(kSecAttrKeyClassPrivate, privateKeyFilePath, errorPtr); 
}

NS_ASSUME_NONNULL_BEGIN

@interface RSASHAVerifyCommand ()

@property (nonatomic, assign, readwrite) QCCRSASHASignatureCompatAlgorithm algorithm;

@end

NS_ASSUME_NONNULL_END

@implementation RSASHAVerifyCommand

+ (NSString *)commandName {
    return @"rsa-verify";
}

+ (NSString *)commandUsage {
    return [NSString stringWithFormat:@"%@ -a sha1|sha2-224|sha2-256|sha2-384|sha2-512 publicKeyFile.pem signatureFile dataFile", [self commandName]];
}

- (NSString *)commandOptions {
    return @"a:";
}

- (BOOL)setOption_a_argument:(NSString *)argument {
    BOOL    result;
    
    result = YES;
    if ([argument isEqual:@"sha1"]) {
        self.algorithm = QCCRSASHASignatureCompatAlgorithmSHA1;
    } else if ([argument isEqual:@"sha2-224"]) {
        self.algorithm = QCCRSASHASignatureCompatAlgorithmSHA2_224;
    } else if ([argument isEqual:@"sha2-256"]) {
        self.algorithm = QCCRSASHASignatureCompatAlgorithmSHA2_256;
    } else if ([argument isEqual:@"sha2-384"]) {
        self.algorithm = QCCRSASHASignatureCompatAlgorithmSHA2_384;
    } else if ([argument isEqual:@"sha2-512"]) {
        self.algorithm = QCCRSASHASignatureCompatAlgorithmSHA2_512;
    } else {
        result = NO;
    }

    return result;
}

- (BOOL)validateOptionsAndArguments:(NSArray *)optionsAndArguments {
    BOOL    success;
    
    success = [super validateOptionsAndArguments:optionsAndArguments];
    if (success) {
        success = (self.arguments.count == 3);
    }
    if (success) {
        success = validFileArguments(self.arguments);
    }
    // We don't check self.algorithm because the default, SHA1, is fine.
    return success;
}

- (BOOL)runError:(NSError **)errorPtr {
    BOOL        success;
    NSString *  publicKeyFilePath;
    NSData *    signatureData;
    NSData *    fileData;
    SecKeyRef   publicKey;
    
    publicKey = NULL;
    
    publicKeyFilePath = self.arguments[0];
    signatureData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.arguments[1]] options:(NSDataReadingOptions) 0 error:errorPtr];
    success = (signatureData != nil);
    if (success) {
        fileData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.arguments[2]] options:(NSDataReadingOptions) 0 error:errorPtr];
        success = (fileData != nil);
    }
    
    if (success) {
        publicKey = publicKeyWithFile(publicKeyFilePath, errorPtr);
        success = (publicKey != NULL);
    }
    
    if (success) {
        QCCRSASHAVerifyCompat *     op;
        
        op = [[QCCRSASHAVerifyCompat alloc] initWithAlgorithm:self.algorithm inputData:fileData publicKey:publicKey signatureData:signatureData];
        [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
        success = (op.error == nil);
        if (success) {
            if (op.verified) {
                fprintf(stdout, "verified\n");
            } else {
                fprintf(stdout, "not verified\n");
            }
        } else if (errorPtr != NULL) {
            *errorPtr = op.error;
        }
    }
    
    return success;
}

@end

NS_ASSUME_NONNULL_BEGIN

@interface RSASHASignCommand ()

@property (nonatomic, assign, readwrite) QCCRSASHASignatureCompatAlgorithm algorithm;

@end

NS_ASSUME_NONNULL_END

@implementation RSASHASignCommand

+ (NSString *)commandName {
    return @"rsa-sign";
}

+ (NSString *)commandUsage {
    return [NSString stringWithFormat:@"%@ -a sha1|sha2-224|sha2-256|sha2-384|sha2-512 privateKeyFile.pem file", [self commandName]];
}

- (NSString *)commandOptions {
    return @"a:";
}

- (BOOL)setOption_a_argument:(NSString *)argument {
    BOOL    result;
    
    result = YES;
    if ([argument isEqual:@"sha1"]) {
        self.algorithm = QCCRSASHASignatureCompatAlgorithmSHA1;
    } else if ([argument isEqual:@"sha2-224"]) {
        self.algorithm = QCCRSASHASignatureCompatAlgorithmSHA2_224;
    } else if ([argument isEqual:@"sha2-256"]) {
        self.algorithm = QCCRSASHASignatureCompatAlgorithmSHA2_256;
    } else if ([argument isEqual:@"sha2-384"]) {
        self.algorithm = QCCRSASHASignatureCompatAlgorithmSHA2_384;
    } else if ([argument isEqual:@"sha2-512"]) {
        self.algorithm = QCCRSASHASignatureCompatAlgorithmSHA2_512;
    } else {
        result = NO;
    }

    return result;
}

- (BOOL)validateOptionsAndArguments:(NSArray *)optionsAndArguments {
    BOOL    success;
    
    success = [super validateOptionsAndArguments:optionsAndArguments];
    if (success) {
        success = (self.arguments.count == 2);
    }
    if (success) {
        success = validFileArguments(self.arguments);
    }
    // We don't check self.algorithm because the default, SHA1, is fine.
    return success;
}

- (BOOL)runError:(NSError **)errorPtr {
    BOOL        success;
    NSString *  privateKeyFilePath;
    NSData *    fileData;
    SecKeyRef   privateKey;
    
    privateKey = NULL;
    
    privateKeyFilePath = self.arguments[0];
    fileData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.arguments[1]] options:(NSDataReadingOptions) 0 error:errorPtr];
    success = (fileData != nil);
    
    if (success) {
        privateKey = privateKeyWithFile(privateKeyFilePath, errorPtr);
        success = (privateKey != NULL);
    }
    
    if (success) {
        QCCRSASHASignCompat *   op;
        
        op = [[QCCRSASHASignCompat alloc] initWithAlgorithm:self.algorithm inputData:fileData privateKey:privateKey];
        [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
        success = (op.error == nil);
        if (success) {
            fprintf(stdout, "%s\n", [QHex hexStringWithData:op.signatureData].UTF8String);
        } else if (errorPtr != NULL) {
            *errorPtr = op.error;
        }
    }
    
    return success;
}

@end

NS_ASSUME_NONNULL_BEGIN

@interface RSACryptorCommand ()

@property (nonatomic, assign, readwrite) QCCRSASmallCryptorCompatPadding padding;

@end

NS_ASSUME_NONNULL_END

@implementation RSACryptorCommand

- (id)init {
    self = [super init];
    if (self != nil) {
        self->_padding = QCCRSASmallCryptorCompatPaddingPKCS1;
    }
    return self;
}

- (NSString *)commandOptions {
    return @"p:";
}

- (BOOL)setOption_p_argument:(NSString *)argument {
    BOOL    result;
    
    result = YES;
    if ([argument isEqual:@"pkcs1"]) {
        self.padding = QCCRSASmallCryptorCompatPaddingPKCS1;
    } else if ([argument isEqual:@"oaep"]) {
        self.padding = QCCRSASmallCryptorCompatPaddingOAEP;
    } else {
        result = NO;
    }
    return result;
}

@end

NS_ASSUME_NONNULL_BEGIN

@interface RSASmallEncryptCommand ()

@end

NS_ASSUME_NONNULL_END

@implementation RSASmallEncryptCommand

+ (NSString *)commandName {
    return @"rsa-small-encrypt";
}

+ (NSString *)commandUsage {
    return [NSString stringWithFormat:@"%@ [-p pkcs1|oaep] publicKeyFile.pem file", [self commandName]];
}

- (BOOL)validateOptionsAndArguments:(NSArray *)optionsAndArguments {
    BOOL    success;
    
    success = [super validateOptionsAndArguments:optionsAndArguments];
    if (success) {
        success = (self.arguments.count == 2);
    }
    if (success) {
        success = validFileArguments(self.arguments);
    }
    return success;
}

- (BOOL)runError:(NSError **)errorPtr {
    BOOL        success;
    NSString *  publicKeyFilePath;
    NSData *    fileData;
    SecKeyRef   publicKey;
    
    publicKey = NULL;
    
    publicKeyFilePath = self.arguments[0];
    fileData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.arguments[1]] options:(NSDataReadingOptions) 0 error:errorPtr];
    success = (fileData != nil);
    
    if (success) {
        publicKey = publicKeyWithFile(publicKeyFilePath, errorPtr);
        success = (publicKey != NULL);
    }
    
    if (success) {
        QCCRSASmallCryptorCompat *  op;
        
        op = [[QCCRSASmallCryptorCompat alloc] initToEncryptSmallInputData:fileData key:publicKey];
        op.padding = self.padding;
        [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
        success = (op.error == nil);
        if (success) {
            fprintf(stdout, "%s\n", [QHex hexStringWithData:op.smallOutputData].UTF8String);
        } else if (errorPtr != NULL) {
            *errorPtr = op.error;
        }
    }
    
    return success;
}

@end

NS_ASSUME_NONNULL_BEGIN

@interface RSASmallDecryptCommand ()

@end

NS_ASSUME_NONNULL_END

@implementation RSASmallDecryptCommand

+ (NSString *)commandName {
    return @"rsa-small-decrypt";
}

+ (NSString *)commandUsage {
    return [NSString stringWithFormat:@"%@ [-p pkcs1|oaep] privateKeyFile.pem file", [self commandName]];
}

- (BOOL)validateOptionsAndArguments:(NSArray *)optionsAndArguments {
    BOOL    success;
    
    success = [super validateOptionsAndArguments:optionsAndArguments];
    if (success) {
        success = (self.arguments.count == 2);
    }
    if (success) {
        success = validFileArguments(self.arguments);
    }
    return success;
}

- (BOOL)runError:(NSError **)errorPtr {
    BOOL        success;
    NSString *  privateKeyFilePath;
    NSData *    fileData;
    SecKeyRef   privateKey;
    
    privateKey = NULL;
    
    privateKeyFilePath = self.arguments[0];
    fileData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.arguments[1]] options:(NSDataReadingOptions) 0 error:errorPtr];
    success = (fileData != nil);
    
    if (success) {
        privateKey = privateKeyWithFile(privateKeyFilePath, errorPtr);
        success = (privateKey != NULL);
    }
    
    if (success) {
        QCCRSASmallCryptorCompat *   op;
        
        op = [[QCCRSASmallCryptorCompat alloc] initToDecryptSmallInputData:fileData key:privateKey];
        op.padding = self.padding;
        [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
        success = (op.error == nil);
        if (success) {
            fprintf(stdout, "%s\n", [QHex hexStringWithData:op.smallOutputData].UTF8String);
        } else if (errorPtr != NULL) {
            *errorPtr = op.error;
        }
    }
    
    return success;
}

@end
