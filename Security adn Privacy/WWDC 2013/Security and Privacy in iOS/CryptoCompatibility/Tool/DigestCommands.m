/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Commands for SHA and other digests.
 */

#import "DigestCommands.h"

#import "QCCSHADigest.h"
#import "QCCHMACSHAAuthentication.h"

#import "ToolCommon.h"

#import "QHex.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DigestOperation 

@property (atomic, copy,   readonly, nullable) NSData *     outputDigest;

@end

typedef NSOperation<DigestOperation> * (^DigestOpMaker)(NSData * data);

@interface DigestCommand ()

@property (nonatomic, strong, readwrite) DigestOpMaker      opMaker;

@end

NS_ASSUME_NONNULL_END

@implementation DigestCommand

+ (NSString *)commandName {
    return @"digest";
}

+ (NSString *)commandUsage {
    return [NSString stringWithFormat:@"%@ -a sha1|sha2-224|sha2-256|sha2-384|sha2-512 file", [self commandName]];
}

- (NSString *)commandOptions {
    return @"a:";
}

- (BOOL)setOption_a_argument:(NSString *)argument {
    BOOL    result;
    
    result = YES;
    if ([argument isEqual:@"sha1"]) {
        self.opMaker = ^(NSData * data){ return [[QCCSHADigest alloc] initWithAlgorithm:QCCSHADigestAlgorithmSHA1 inputData:data]; };
    } else if ([argument isEqual:@"sha2-224"]) {
        self.opMaker = ^(NSData * data){ return [[QCCSHADigest alloc] initWithAlgorithm:QCCSHADigestAlgorithmSHA2_224 inputData:data]; };
    } else if ([argument isEqual:@"sha2-256"]) {
        self.opMaker = ^(NSData * data){ return [[QCCSHADigest alloc] initWithAlgorithm:QCCSHADigestAlgorithmSHA2_256 inputData:data]; };
    } else if ([argument isEqual:@"sha2-384"]) {
        self.opMaker = ^(NSData * data){ return [[QCCSHADigest alloc] initWithAlgorithm:QCCSHADigestAlgorithmSHA2_384 inputData:data]; };
    } else if ([argument isEqual:@"sha2-512"]) {
        self.opMaker = ^(NSData * data){ return [[QCCSHADigest alloc] initWithAlgorithm:QCCSHADigestAlgorithmSHA2_512 inputData:data]; };
    } else {
        result = NO;
    }

    return result;
}

- (BOOL)validateOptionsAndArguments:(NSArray *)optionsAndArguments {
    BOOL    success;
    
    success = [super validateOptionsAndArguments:optionsAndArguments];
    if (success) {
        if (self.arguments.count != 1) {
            success = NO;
        } else if (self.opMaker == nil) {
            // Defaulting to SHA1 is reasonable.
            success = [self setOption_a_argument:@"sha1"];
        }
    }
    return success;
}

- (BOOL)runError:(NSError **)errorPtr {
    BOOL        success;
    NSData *    data;
    
    data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.arguments[0]] options:(NSDataReadingOptions) 0 error:errorPtr];
    success = (data != nil);
    
    if (success) {
        NSOperation<DigestOperation> *  op;

        op = self.opMaker(data);
        [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
        fprintf(stdout, "%s\n", [QHex hexStringWithData:op.outputDigest].UTF8String);
    }
    
    return success;
}

@end

NS_ASSUME_NONNULL_BEGIN

@interface HMACCommand ()

@property (nonatomic, copy,   readwrite, nullable) NSData *                 keyData;
@property (nonatomic, assign, readwrite) QCCHMACSHAAuthenticationAlgorithm  algorithm;

@end

NS_ASSUME_NONNULL_END

@implementation HMACCommand

+ (NSString *)commandName {
    return @"hmac";
}

+ (NSString *)commandUsage {
    return [NSString stringWithFormat:@"%@ -a sha1|sha2-224|sha2-256|sha2-384|sha2-512 -k keyHexStr file", [self commandName]];
}

- (NSString *)commandOptions {
    return @"a:k:";
}

- (BOOL)setOption_k_argument:(NSString *)argument {
    self.keyData = [QHex optionalDataWithHexString:argument];
    return (self.keyData != nil);
}

- (BOOL)setOption_a_argument:(NSString *)argument {
    BOOL    result;
    
    result = YES;
    if ([argument isEqual:@"sha1"]) {
        self.algorithm = QCCHMACSHAAuthenticationAlgorithmSHA1;
    } else if ([argument isEqual:@"sha2-224"]) {
        self.algorithm = QCCHMACSHAAuthenticationAlgorithmSHA2_224;
    } else if ([argument isEqual:@"sha2-256"]) {
        self.algorithm = QCCHMACSHAAuthenticationAlgorithmSHA2_256;
    } else if ([argument isEqual:@"sha2-384"]) {
        self.algorithm = QCCHMACSHAAuthenticationAlgorithmSHA2_384;
    } else if ([argument isEqual:@"sha2-512"]) {
        self.algorithm = QCCHMACSHAAuthenticationAlgorithmSHA2_512;
    } else {
        result = NO;
    }

    return result;
}

- (BOOL)validateOptionsAndArguments:(NSArray *)optionsAndArguments {
    BOOL    success;
    
    success = [super validateOptionsAndArguments:optionsAndArguments];
    if (success) {
        if (self.arguments.count != 1) {
            success = NO;
        } else if (self.keyData == nil) {
            success = NO;
        }
        // We don't check self.algorithm because the default, SHA1, is fine.
    }
    return success;
}

- (BOOL)runError:(NSError **)errorPtr {
    BOOL        success;
    NSData *    data;
    
    data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.arguments[0]] options:(NSDataReadingOptions) 0 error:errorPtr];
    success = (data != nil);
    
    if (success) {
        QCCHMACSHAAuthentication *      op;
        
        op = [[QCCHMACSHAAuthentication alloc] initWithAlgorithm:self.algorithm inputData:data keyData:self.keyData];
        [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
        fprintf(stdout, "%s\n", [QHex hexStringWithData:op.outputHMAC].UTF8String);
    }
    
    return success;
}

@end
