/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Tests for the digest operations.
 */

@import XCTest;

#import "QCCSHADigest.h"
#import "QCCHMACSHAAuthentication.h"

#import "ToolCommon.h"

#import "QHex.h"

NS_ASSUME_NONNULL_BEGIN

@interface DigestOperationsTests : XCTestCase

@end

NS_ASSUME_NONNULL_END

@implementation DigestOperationsTests

- (void)setUp {
    [super setUp];
    [ToolCommon sharedInstance].debugRunOpOnMainThread = YES;
}

- (void)testSHADigest {
    NSData *            testDotCerData;
    
    testDotCerData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"test" withExtension:@"cer"]];
    assert(testDotCerData != nil);
    
    static const QCCSHADigestAlgorithm  kDigestAlgorithms[5] = { QCCSHADigestAlgorithmSHA1, QCCSHADigestAlgorithmSHA2_224, QCCSHADigestAlgorithmSHA2_256, QCCSHADigestAlgorithmSHA2_384, QCCSHADigestAlgorithmSHA2_512 };
    static       NSString *             kDigestsOfTestDotCer[5] = { 
        @"c1ddfe7dd14c9b8dee83b46b87a408970fd2a83f",
        @"d71908c49c7c1563a829882f1ba6115e1616d1bdbb1d1f757265137b",
        @"d69cb53f849c80d7803294ee8fed312e917656986538d14224468185fac56289",
        @"b1cbdc8c517ad3b0b96436839bfc9cdaf75609c4d8f908444eb31675909912ae73252e0df8a6c8599e81f2a0a760f182",
        @"a1b17242359bb8dbb0cda8356991f65131ca1894ef9f797b296e68dacd300e0e179e28823cd69da1cccc8a3a8d7339bf2c1311b018c48a0e53d488e66df22250",
    };
    static       NSString * kDigestsOfEmpty[5] = {
        @"da39a3ee5e6b4b0d3255bfef95601890afd80709",
        @"d14a028c2a3a2bc9476102bb288234c415a2b01f828ea62ac5b3e42f",
        @"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
        @"38b060a751ac96384cd9327eb1b1e36a21fdb71114be07434c0cc7bf63f6e1da274edebfe76f65fbd51ad2f14898b95b",
        @"cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e",
    };
    
    for (size_t i = 0; i < 4; i++) {
        QCCSHADigest *      op;
        NSData *            expectedOutputData;

        expectedOutputData = [QHex dataWithHexString:kDigestsOfTestDotCer[i]];
        assert(expectedOutputData != nil);

        op = [[QCCSHADigest alloc] initWithAlgorithm:kDigestAlgorithms[i] inputData:testDotCerData];
        [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
        XCTAssertEqualObjects(op.outputDigest, expectedOutputData);

        expectedOutputData = [QHex dataWithHexString:kDigestsOfEmpty[i]];
        assert(expectedOutputData != nil);

        op = [[QCCSHADigest alloc] initWithAlgorithm:kDigestAlgorithms[i] inputData:[NSData data]];
        [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
        XCTAssertEqualObjects(op.outputDigest, expectedOutputData);
    }
}

- (void)testHMACSHAAuthentication {
    NSData *                    inputData;
    NSData *                    keyData;
    
    inputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"test" withExtension:@"cer"]];
    assert(inputData != nil);
    
    keyData = [QHex dataWithHexString:@"48656c6c6f20437275656c20576f726c6421"];
    assert(keyData != nil);

    static const QCCHMACSHAAuthenticationAlgorithm  kAlgorithms[5] = { QCCHMACSHAAuthenticationAlgorithmSHA1, QCCHMACSHAAuthenticationAlgorithmSHA2_224, QCCHMACSHAAuthenticationAlgorithmSHA2_256, QCCHMACSHAAuthenticationAlgorithmSHA2_384, QCCHMACSHAAuthenticationAlgorithmSHA2_512 };
    static       NSString * kHMACsOfTestDotCer[5] = { 
        @"550a1da058c1b5df6ea167870ae6dbc92f0e0281", 
        @"aea439459bf3b7732886d9345c7f2651de94c45ebfc320b1b49c3057", 
        @"5ad394b17fb3f064079b0a21f25758550f7c8d9065803ae7271cb7bb86dac081", 
        @"78b0fd6c8241261010ad92a9a91538aac46a90989eebdda0cb2564b2dea26061f341eb379d71af720d961c295fbbf5cc", 
        @"7ab5c9a876bd52ca9a9cf643ba097e6847ac02797e69f5d39fbdb4ce70390098b978faa022889496c22f0c787e41b17fe9456bb648b2c66ceb53c2dc3cc2c16e", 
    };
    static       NSString * kHMACsOfEmptyKey[5] = {
        @"4d38e8a1ea27cb89a3ce3f0df8de45b5e5820c6a", 
        @"ecb9eeee58c481e9d1aed1b5ad28fdc9703029ef56a7f27b9e116cb4", 
        @"210ad382b2c6eda12b39c7aa39e74f5823778dca3bde77ffdbefb6afb4adeced", 
        @"cafc52d0e028ab00c4a938fbe972802b541fb53fe67262db3678a0e205fd78cb6dbfdf03aba420582b902c79212587af", 
        @"c16e07bf237d58391b7a3098ddd6b0447bc45f251f3467c691131bb7e2d95cfb0aecc2abdf3f1b0e83e03bcff34e3c078eb90bf0ee7b2b10cde1143dc8ecbb66", 
    };
    
    for (size_t i = 0; i < 4; i++) {
        QCCHMACSHAAuthentication *  op;
        NSData *                    expectedOutputData;

        expectedOutputData = [QHex dataWithHexString:kHMACsOfTestDotCer[i]];
        assert(expectedOutputData != nil);
        
        op = [[QCCHMACSHAAuthentication alloc] initWithAlgorithm:kAlgorithms[i] inputData:inputData keyData:keyData];
        [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
        XCTAssertEqualObjects(expectedOutputData, op.outputHMAC);

        expectedOutputData = [QHex dataWithHexString:kHMACsOfEmptyKey[i]];
        assert(expectedOutputData != nil);
        
        op = [[QCCHMACSHAAuthentication alloc] initWithAlgorithm:kAlgorithms[i] inputData:inputData keyData:[NSData data]];
        [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
        XCTAssertEqualObjects(expectedOutputData, op.outputHMAC);
    }
}

- (void)testDigestThrows {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows((void) [[QCCSHADigest alloc] initWithAlgorithm:QCCSHADigestAlgorithmSHA1 inputData:nil]);
    XCTAssertThrows((void) [[QCCHMACSHAAuthentication alloc] initWithAlgorithm:QCCHMACSHAAuthenticationAlgorithmSHA1 inputData:nil keyData:[NSData data]]);
    XCTAssertThrows((void) [[QCCHMACSHAAuthentication alloc] initWithAlgorithm:QCCHMACSHAAuthenticationAlgorithmSHA1 inputData:[NSData data] keyData:nil]);
    #pragma clang diagnostic pop
}

@end
