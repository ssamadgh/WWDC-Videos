/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Tests for the key derivation operations.
 */

@import XCTest;

#import "QCCPBKDF2SHAKeyDerivation.h"

#import "ToolCommon.h"

#import "QHex.h"

#include <CommonCrypto/CommonCrypto.h>

NS_ASSUME_NONNULL_BEGIN

@interface KeyDerivationOperationsTests : XCTestCase

@end

NS_ASSUME_NONNULL_END

@implementation KeyDerivationOperationsTests

- (void)setUp {
    [super setUp];
    [ToolCommon sharedInstance].debugRunOpOnMainThread = YES;
}

- (void)testPBKDF2 {
    NSString *                      passwordString;
    NSData *                        saltData;
    
    passwordString = @"Hello Cruel World!";
    assert(passwordString != nil);
    
    saltData = [@"Some salt sir?" dataUsingEncoding:NSUTF8StringEncoding];
    assert(saltData != nil);

    // These results were generated with PHP 7.0.5 using:
    // 
    // hash_pbkdf2("sha1", "Hello Cruel World!", "Some salt sir?", 1000, 10, true);
    // hash_pbkdf2("sha224", "Hello Cruel World!", "Some salt sir?", 1000, 10, true);
    // ...
    //
    // and then repeated with "" for salt.
    // and then repeated again with "" for both password and salt.

    // Note: This test fails on OS X 10.7.x and iOS 5.x because CCKeyDerivationPBKDF returns 
    // an error if there's no salt.
    
    static const QCCPBKDF2SHAKeyDerivationAlgorithm  kAlgorithms[5] = { QCCPBKDF2SHAKeyDerivationAlgorithmSHA1, QCCPBKDF2SHAKeyDerivationAlgorithmSHA2_224, QCCPBKDF2SHAKeyDerivationAlgorithmSHA2_256, QCCPBKDF2SHAKeyDerivationAlgorithmSHA2_384, QCCPBKDF2SHAKeyDerivationAlgorithmSHA2_512 };
    static       NSString * kExpected[5] = { 
        @"e56c27f5eed251db50a3", 
        @"88597c3d039227ea2723", 
        @"884185449fa0f5ea91bf", 
        @"7c44bd93a3f5d732a667", 
        @"d4537676e0af5274ca01"
    };

    static       NSString * kExpectedNoSalt[5] = { 
        @"98b4c8aec38c64c8e2de", 
        @"8bd95e3da6187c36d737", 
        @"338919ba6253c606fc02", 
        @"821d33494a485633ebb9", 
        @"80878761083c187e425c"
    };
    static       NSString * kExpectedDegenerate[5] = { 
        @"6e40910ac02ec89cebb9", 
        @"7df7ef68f01b61a28b21", 
        @"4fc58a21c100ce1835b8", 
        @"9cbfe72d194da34e17c8", 
        @"cb93096c3a02beeb1c5f"
    };
    
    for (size_t i = 0; i < 2; i++) {
        QCCPBKDF2SHAKeyDerivation *     op;
        NSData *                        expectedKeyData;

        expectedKeyData = [QHex dataWithHexString:kExpected[i]];

        op = [[QCCPBKDF2SHAKeyDerivation alloc] initWithAlgorithm:kAlgorithms[i] passwordString:passwordString saltData:saltData];
        op.rounds = 1000;
        op.derivedKeyLength = 10;
        [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
        XCTAssertNil(op.error);
        XCTAssertEqualObjects(op.derivedKeyData, expectedKeyData);

        expectedKeyData = [QHex dataWithHexString:kExpectedNoSalt[i]];

        op = [[QCCPBKDF2SHAKeyDerivation alloc] initWithAlgorithm:kAlgorithms[i] passwordString:passwordString saltData:[NSData data]];
        op.rounds = 1000;
        op.derivedKeyLength = 10;
        [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
        XCTAssertNil(op.error);
        XCTAssertEqualObjects(op.derivedKeyData, expectedKeyData);

        expectedKeyData = [QHex dataWithHexString:kExpectedDegenerate[i]];

        op = [[QCCPBKDF2SHAKeyDerivation alloc] initWithAlgorithm:kAlgorithms[i] passwordString:@"" saltData:[NSData data]];
        op.rounds = 1000;
        op.derivedKeyLength = 10;
        [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
        XCTAssertNil(op.error);
        XCTAssertEqualObjects(op.derivedKeyData, expectedKeyData);
    }
}

- (void)testPBKDF2Calibration {
    NSString *                      passwordString;
    NSData *                        saltData;
    QCCPBKDF2SHAKeyDerivation *     op;
    NSData *                        derivedKey;
    NSInteger                       actualRounds;
    NSTimeInterval                  startTime;
    NSTimeInterval                  timeTaken;
    
    passwordString = @"Hello Cruel World!";
    assert(passwordString != nil);
    
    saltData = [@"Some salt sir?" dataUsingEncoding:NSUTF8StringEncoding];
    assert(saltData != nil);
        
    // First run the operation with a target time (0.5 seconds).
    
    op = [[QCCPBKDF2SHAKeyDerivation alloc] initWithAlgorithm:QCCPBKDF2SHAKeyDerivationAlgorithmSHA1 passwordString:passwordString saltData:saltData];
    op.derivationTime = 0.5;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);
    XCTAssertNotNil(op.derivedKeyData);
    derivedKey = op.derivedKeyData;
    actualRounds = op.actualRounds;
    
    // Then run it again with the rounds from the previous operation. 
    // It should take (roughly) 0.5 seconds.  If it doesn't, that's a problem.
    //
    // Note we have a huge time variance here due, so we accept a large range of values.
    
    op = [[QCCPBKDF2SHAKeyDerivation alloc] initWithAlgorithm:QCCPBKDF2SHAKeyDerivationAlgorithmSHA1 passwordString:passwordString saltData:saltData];
    op.rounds = actualRounds;
    startTime = [NSDate timeIntervalSinceReferenceDate];
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    timeTaken = [NSDate timeIntervalSinceReferenceDate] - startTime;
    XCTAssertNil(op.error);
    XCTAssertEqualWithAccuracy(timeTaken, 0.5, 0.2);
    XCTAssertEqual(op.actualRounds, actualRounds);
    XCTAssertEqualObjects(op.derivedKeyData, derivedKey);
}

- (void)testPBKDF2Error {
    NSString *                      passwordString;
    NSData *                        saltData;
    QCCPBKDF2SHAKeyDerivation *     op;

    passwordString = @"Hello Cruel World!";
    assert(passwordString != nil);
    
    saltData = [@"Some salt sir?" dataUsingEncoding:NSUTF8StringEncoding];
    assert(saltData != nil);
        
    // a derived key length of zero is not valid
    
    op = [[QCCPBKDF2SHAKeyDerivation alloc] initWithAlgorithm:QCCPBKDF2SHAKeyDerivationAlgorithmSHA1 passwordString:passwordString saltData:saltData];
    op.derivedKeyLength = 0;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, QCCPBKDF2KeyDerivationErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) kCCParamError);
    XCTAssertNil(op.derivedKeyData);

    // repeat the above with a rounds value, which triggers the error in a different place
    
    op = [[QCCPBKDF2SHAKeyDerivation alloc] initWithAlgorithm:QCCPBKDF2SHAKeyDerivationAlgorithmSHA1 passwordString:passwordString saltData:saltData];
    op.derivedKeyLength = 0;
    op.rounds = 1000;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, QCCPBKDF2KeyDerivationErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) kCCParamError);
    XCTAssertNil(op.derivedKeyData);
}

- (void)testKeyDerivationThrows {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows((void) [[QCCPBKDF2SHAKeyDerivation alloc] initWithAlgorithm:QCCPBKDF2SHAKeyDerivationAlgorithmSHA1 passwordString:nil saltData:[NSData data]]);
    XCTAssertThrows((void) [[QCCPBKDF2SHAKeyDerivation alloc] initWithAlgorithm:QCCPBKDF2SHAKeyDerivationAlgorithmSHA1 passwordString:@"" saltData:nil]);
    #pragma clang diagnostic pop
}

@end
