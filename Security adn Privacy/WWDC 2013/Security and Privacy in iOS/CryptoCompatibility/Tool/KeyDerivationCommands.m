/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Commands for key derivation.
 */

#import "KeyDerivationCommands.h"

#import "QCCPBKDF2SHAKeyDerivation.h"

#import "ToolCommon.h"

#import "QHex.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBKDF2KeyDerivationCommand ()

@property (nonatomic, assign, readwrite)           QCCPBKDF2SHAKeyDerivationAlgorithm   algorithm;
@property (nonatomic, copy,   readwrite, nullable) NSString *                           passwordString;
@property (nonatomic, copy,   readwrite, nullable) NSData *                             saltData;
@property (nonatomic, assign, readwrite)           NSInteger                            rounds;
@property (nonatomic, assign, readwrite)           NSInteger                            derivedKeyLength;

@end

NS_ASSUME_NONNULL_END

@implementation PBKDF2KeyDerivationCommand

+ (NSString *)commandName {
    return @"pbkdf2-key-derivation";
}

+ (NSString *)commandUsage {
    return [NSString stringWithFormat:@"%@ -a sha1|sha2-224|sha2-256|sha2-384|sha2-512 -p passwordStr -s saltHexStr [-r rounds] [-z derivedKeyLength]", [self commandName]];
}

- (NSString *)commandOptions {
    return @"a:p:s:r:z:";
}

- (BOOL)setOption_a_argument:(NSString *)argument {
    BOOL    result;
    
    result = YES;
    if ([argument isEqual:@"sha1"]) {
        self.algorithm = QCCPBKDF2SHAKeyDerivationAlgorithmSHA1;
    } else if ([argument isEqual:@"sha2-224"]) {
        self.algorithm = QCCPBKDF2SHAKeyDerivationAlgorithmSHA2_224;
    } else if ([argument isEqual:@"sha2-256"]) {
        self.algorithm = QCCPBKDF2SHAKeyDerivationAlgorithmSHA2_256;
    } else if ([argument isEqual:@"sha2-384"]) {
        self.algorithm = QCCPBKDF2SHAKeyDerivationAlgorithmSHA2_384;
    } else if ([argument isEqual:@"sha2-512"]) {
        self.algorithm = QCCPBKDF2SHAKeyDerivationAlgorithmSHA2_512;
    } else {
        result = NO;
    }

    return result;
}

- (BOOL)setOption_p_argument:(NSString *)argument {
    self.passwordString = argument;
    return YES;
}

- (BOOL)setOption_s_argument:(NSString *)argument {
    self.saltData = [QHex optionalDataWithHexString:argument];
    return (self.saltData != nil);
}

- (BOOL)setOption_r_argument:(NSString *)argument {
    self.rounds = argument.integerValue;
    return (self.rounds >= 0);
}

- (BOOL)setOption_z_argument:(NSString *)argument {
    self.derivedKeyLength = argument.integerValue;
    return (self.derivedKeyLength >= 0);
}

- (BOOL)validateOptionsAndArguments:(NSArray *)optionsAndArguments {
    BOOL    success;
    
    success = [super validateOptionsAndArguments:optionsAndArguments];
    if (success) {
        if (self.arguments.count != 0) {
            success = NO;
        } else if (self.passwordString == nil) {
            success = NO;
        } else if (self.saltData == nil) {
            success = NO;
        }
        // We don't check self.algorithm because the default, SHA1, is fine.
    }
    return success;
}

- (BOOL)runError:(NSError **)errorPtr {
    BOOL                            success;
    QCCPBKDF2SHAKeyDerivation *     op;
    
    success = YES;
    op = [[QCCPBKDF2SHAKeyDerivation alloc] initWithAlgorithm:self.algorithm passwordString:self.passwordString saltData:self.saltData];
    if (self.rounds != 0) {
        op.rounds = self.rounds;
    }
    if (self.derivedKeyLength != 0) {
        op.derivedKeyLength = self.derivedKeyLength;
    }
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    if (op.error == nil) {
        fprintf(stdout, "%s\n", [QHex hexStringWithData:op.derivedKeyData].UTF8String);
    } else {
        if (errorPtr != NULL) {
            *errorPtr = op.error;
        }
        success = NO;
    }
    
    return success;
}

@end
