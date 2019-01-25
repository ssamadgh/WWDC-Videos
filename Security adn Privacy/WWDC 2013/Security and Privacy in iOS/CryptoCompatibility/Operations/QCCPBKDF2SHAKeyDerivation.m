/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Derives a key from a password string using the PBKDF2 algorithm.
 */

#import "QCCPBKDF2SHAKeyDerivation.h"

#include <CommonCrypto/CommonCrypto.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCCPBKDF2SHAKeyDerivation ()

// read/write versions of public properties

@property (atomic, copy,   readwrite, nullable) NSError *         error;
@property (atomic, assign, readwrite)           NSInteger         actualRounds;
@property (atomic, copy,   readwrite, nullable) NSData *          derivedKeyData;

@end

NS_ASSUME_NONNULL_END

@implementation QCCPBKDF2SHAKeyDerivation

- (instancetype)init {
    abort();
}

- (instancetype)initWithAlgorithm:(QCCPBKDF2SHAKeyDerivationAlgorithm)algorithm passwordString:(NSString *)passwordString saltData:(NSData *)saltData {
    NSParameterAssert(passwordString != nil);
    NSParameterAssert(saltData != nil);
    self = [super init];
    if (self != nil) {
        self->_algorithm = algorithm;
        self->_passwordString = [passwordString copy];
        self->_saltData = [saltData copy];
        self->_rounds = 0;
        self->_derivationTime = 0.1;
        self->_derivedKeyLength = 16;
    }
    return self;
}

- (void)calculateActualRoundsForPasswordLength:(size_t)passwordLength saltLength:(size_t)saltLength ccAlgorithm:(CCPseudoRandomAlgorithm)ccAlgorithm {
    int         result;
    double      derivationTimeMilliseconds;
    
    derivationTimeMilliseconds = self.derivationTime * 1000.0;
    
    // CCCalibratePBKDF has undocumented limits on the salt length <rdar://problem/13641064>.
    
    if (saltLength == 0) {
        saltLength = 1;
    } else if (saltLength > 128) {
        saltLength = 128;
    }

    // Make sure the specified time is not zero and fits into a uint32_t.
    
    if (derivationTimeMilliseconds < 1.0) {
        derivationTimeMilliseconds = 1.0;
    } else if (derivationTimeMilliseconds > (double) UINT32_MAX) {
        derivationTimeMilliseconds = (double) UINT32_MAX;
    }
    
    // Do the key derivation.
    
    result = (int) CCCalibratePBKDF(
        kCCPBKDF2, 
        passwordLength, 
        saltLength, 
        ccAlgorithm, 
        (size_t) self.derivedKeyLength, 
        (uint32_t) derivationTimeMilliseconds
    );
    
    // CCCalibratePBKDF returns undocumented error codes <rdar://problem/13641039>.
    
    if (result < 0) {
        // Setting actualRounds to 0 triggers an error path in our caller.
        result = 0;
    }
    
    // Save the result.  This can't truncate because NSUInteger always has either the same 
    // or more range than (unsigned int).
    
    self.actualRounds = (NSInteger) result;
}

- (void)main {
    CCCryptorStatus         err;
    const char *            passwordUTF8;
    size_t                  passwordUTFLength;
    CCPseudoRandomAlgorithm ccAlgorithm;
    const uint8_t *         saltPtr;
    static const uint8_t    saltDummy = 0;
    size_t                  saltLength;
    NSMutableData *         result;

    NSParameterAssert(self.derivedKeyLength >= 0);

    result = [[NSMutableData alloc] initWithLength:(NSUInteger) self.derivedKeyLength];

    passwordUTF8 = self.passwordString.UTF8String;
    passwordUTFLength = strlen(passwordUTF8);
    
    // Map our algorithm enum to Common Crypto's equivalent.
    
    switch (self.algorithm) {
        case QCCPBKDF2SHAKeyDerivationAlgorithmSHA1:     { ccAlgorithm = kCCPRFHmacAlgSHA1;   break; }
        case QCCPBKDF2SHAKeyDerivationAlgorithmSHA2_224: { ccAlgorithm = kCCPRFHmacAlgSHA224; break; }
        case QCCPBKDF2SHAKeyDerivationAlgorithmSHA2_256: { ccAlgorithm = kCCPRFHmacAlgSHA256; break; }
        case QCCPBKDF2SHAKeyDerivationAlgorithmSHA2_384: { ccAlgorithm = kCCPRFHmacAlgSHA384; break; }
        case QCCPBKDF2SHAKeyDerivationAlgorithmSHA2_512: { ccAlgorithm = kCCPRFHmacAlgSHA512; break; }
        default: {
            abort();
        } break;
    }

    // If the salt is zero bytes long then saltPtr ends up being NULL.  This causes 
    // CCKeyDerivationPBKDF to fail with an error.  We fix this by passing in a 
    // pointer a dummy variable in that case.
    
    saltLength = self.saltData.length;
    if (saltLength == 0) {
        saltPtr = &saltDummy;
    } else {
        saltPtr = self.saltData.bytes;
    }

    // If the client didn't specify the rounds, calculate one based on the derivation time.
    
    if (self.rounds != 0) {
        self.actualRounds = self.rounds;
    } else {
        // Note that we only pass in the values that we've already calculated; the method reads 
        // various other properties.
        [self calculateActualRoundsForPasswordLength:passwordUTFLength saltLength:saltLength ccAlgorithm:ccAlgorithm];
    }
    
    // Check that actualRounds makes sense.
    
    err = kCCSuccess;
    if (self.actualRounds == 0) {
        err = kCCParamError;
    } else if (self.actualRounds > INT_MAX) {
        err = kCCParamError;
    }
    
    // Do the key derivation and save the results.
    
    if (err == kCCSuccess) {
        err = CCKeyDerivationPBKDF(
            kCCPBKDF2, 
            passwordUTF8, passwordUTFLength, 
            saltPtr, saltLength, 
            ccAlgorithm, 
            (unsigned int) self.actualRounds,
            result.mutableBytes, 
            result.length
        );
        if (err == -1) {
            // The header docs say that CCKeyDerivationPBKDF returns kCCParamError but that's not the case 
            // on current systems; you get -1 instead <rdar://problem/13640477>.  We translate -1, which isn't 
            // a reasonable CommonCrypto error, to kCCParamError.
            err = kCCParamError;
        }
    }
    if (err == kCCSuccess) {
        self.derivedKeyData = result;
    } else {
        self.error = [NSError errorWithDomain:QCCPBKDF2KeyDerivationErrorDomain code:err userInfo:nil];
    }
}

@end

NSString * QCCPBKDF2KeyDerivationErrorDomain = @"QCCPBKDF2KeyDerivationErrorDomain";
