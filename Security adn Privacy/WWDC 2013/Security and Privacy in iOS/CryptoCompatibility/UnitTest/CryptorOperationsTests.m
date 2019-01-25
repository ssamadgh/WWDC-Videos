/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Tests for the cryptor operations.
 */

@import XCTest;

#import "QCCAESCryptor.h"
#import "QCCAESPadCryptor.h"
#import "QCCAESPadBigCryptor.h"

#import "ToolCommon.h"

#import "QHex.h"

#include <CommonCrypto/CommonCrypto.h>

NS_ASSUME_NONNULL_BEGIN

@interface CryptorOperationsTests : XCTestCase

@end

NS_ASSUME_NONNULL_END

@implementation CryptorOperationsTests

- (void)setUp {
    [super setUp];
    [ToolCommon sharedInstance].debugRunOpOnMainThread = YES;
}

#pragma mark * QCCAESCryptor

// AES-128 ECB

- (void)testAES128ECBEncryption {
    NSData *            inputData;
    NSData *            keyData;
    QCCAESCryptor *     op;
    NSData *            expectedOutputData;
    
    inputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"plaintext-336" withExtension:@"dat"]];
    assert(inputData != nil);
    
    expectedOutputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"cyphertext-aes-128-ecb-336" withExtension:@"dat"]];
    assert(expectedOutputData != nil);
    
    keyData = [QHex dataWithHexString:@"0C1032520302EC8537A4A82C4EF7579D"];
    assert(keyData != nil);

    op = [[QCCAESCryptor alloc] initToEncryptInputData:inputData keyData:keyData];
    op.ivData = nil;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);
    XCTAssertEqualObjects(expectedOutputData, op.outputData);
}

- (void)testAES128ECBEncryptionEmpty {
    NSData *            inputData;
    NSData *            keyData;
    QCCAESCryptor *     op;
    NSData *            expectedOutputData;
    
    inputData = [NSData data];
    assert(inputData != nil);
    
    expectedOutputData = [NSData data];
    assert(expectedOutputData != nil);
    
    keyData = [QHex dataWithHexString:@"0C1032520302EC8537A4A82C4EF7579D"];
    assert(keyData != nil);

    op = [[QCCAESCryptor alloc] initToEncryptInputData:inputData keyData:keyData];
    op.ivData = nil;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);
    XCTAssertEqualObjects(expectedOutputData, op.outputData);
}

- (void)testAES128ECBDecryption {
    NSData *            inputData;
    NSData *            keyData;
    QCCAESCryptor *     op;
    NSData *            expectedOutputData;
    
    inputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"cyphertext-aes-128-ecb-336" withExtension:@"dat"]];
    assert(inputData != nil);
    
    expectedOutputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"plaintext-336" withExtension:@"dat"]];
    assert(expectedOutputData != nil);
    
    keyData = [QHex dataWithHexString:@"0C1032520302EC8537A4A82C4EF7579D"];
    assert(keyData != nil);

    op = [[QCCAESCryptor alloc] initToDecryptInputData:inputData keyData:keyData];
    op.ivData = nil;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);
    XCTAssertEqualObjects(expectedOutputData, op.outputData);
}

- (void)testAES128ECBDecryptionEmpty {
    NSData *            inputData;
    NSData *            keyData;
    QCCAESCryptor *     op;
    NSData *            expectedOutputData;
    
    inputData = [NSData data];
    assert(inputData != nil);
    
    expectedOutputData = [NSData data];
    assert(expectedOutputData != nil);
    
    keyData = [QHex dataWithHexString:@"0C1032520302EC8537A4A82C4EF7579D"];
    assert(keyData != nil);

    op = [[QCCAESCryptor alloc] initToDecryptInputData:inputData keyData:keyData];
    op.ivData = nil;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);
    XCTAssertEqualObjects(expectedOutputData, op.outputData);
}

// AES-128 CBC

- (void)testAES128CBCEncryption {
    NSData *            inputData;
    NSData *            keyData;
    NSData *            ivData;
    QCCAESCryptor *     op;
    NSData *            expectedOutputData;
    
    inputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"plaintext-336" withExtension:@"dat"]];
    assert(inputData != nil);
    
    expectedOutputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"cyphertext-aes-128-cbc-336" withExtension:@"dat"]];
    assert(expectedOutputData != nil);
    
    keyData = [QHex dataWithHexString:@"0C1032520302EC8537A4A82C4EF7579D"];
    assert(keyData != nil);

    ivData = [QHex dataWithHexString:@"AB5BBEB426015DA7EEDCEE8BEE3DFFB7"];
    assert(ivData != nil);
    
    op = [[QCCAESCryptor alloc] initToEncryptInputData:inputData keyData:keyData];
    op.ivData = ivData;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);
    XCTAssertEqualObjects(expectedOutputData, op.outputData);
}

- (void)testAES128CBCEncryptionEmpty {
    NSData *            inputData;
    NSData *            keyData;
    NSData *            ivData;
    QCCAESCryptor *     op;
    NSData *            expectedOutputData;
    
    inputData = [NSData data];
    assert(inputData != nil);
    
    expectedOutputData = [NSData data];
    assert(expectedOutputData != nil);
    
    keyData = [QHex dataWithHexString:@"0C1032520302EC8537A4A82C4EF7579D"];
    assert(keyData != nil);

    ivData = [QHex dataWithHexString:@"AB5BBEB426015DA7EEDCEE8BEE3DFFB7"];
    assert(ivData != nil);
    
    op = [[QCCAESCryptor alloc] initToEncryptInputData:inputData keyData:keyData];
    op.ivData = ivData;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);
    XCTAssertEqualObjects(expectedOutputData, op.outputData);
}

- (void)testAES128CBCDecryption {
    NSData *            inputData;
    NSData *            keyData;
    NSData *            ivData;
    QCCAESCryptor *     op;
    NSData *            expectedOutputData;
    
    inputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"cyphertext-aes-128-cbc-336" withExtension:@"dat"]];
    assert(inputData != nil);
    
    expectedOutputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"plaintext-336" withExtension:@"dat"]];
    assert(expectedOutputData != nil);
    
    keyData = [QHex dataWithHexString:@"0C1032520302EC8537A4A82C4EF7579D"];
    assert(keyData != nil);

    ivData = [QHex dataWithHexString:@"AB5BBEB426015DA7EEDCEE8BEE3DFFB7"];
    assert(ivData != nil);
    
    op = [[QCCAESCryptor alloc] initToDecryptInputData:inputData keyData:keyData];
    op.ivData = ivData;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);
    XCTAssertEqualObjects(expectedOutputData, op.outputData);
}

- (void)testAES128CBCDecryptionEmpty {
    NSData *            inputData;
    NSData *            keyData;
    NSData *            ivData;
    QCCAESCryptor *     op;
    NSData *            expectedOutputData;
    
    inputData = [NSData data];
    assert(inputData != nil);
    
    expectedOutputData = [NSData data];
    assert(expectedOutputData != nil);
    
    keyData = [QHex dataWithHexString:@"0C1032520302EC8537A4A82C4EF7579D"];
    assert(keyData != nil);

    ivData = [QHex dataWithHexString:@"AB5BBEB426015DA7EEDCEE8BEE3DFFB7"];
    assert(ivData != nil);
    
    op = [[QCCAESCryptor alloc] initToDecryptInputData:inputData keyData:keyData];
    op.ivData = ivData;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);
    XCTAssertEqualObjects(expectedOutputData, op.outputData);
}

// AES-256 ECB

- (void)testAES256ECBEncryption {
    NSData *            inputData;
    NSData *            keyData;
    QCCAESCryptor *     op;
    NSData *            expectedOutputData;
    
    inputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"plaintext-336" withExtension:@"dat"]];
    assert(inputData != nil);
    
    expectedOutputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"cyphertext-aes-256-ecb-336" withExtension:@"dat"]];
    assert(expectedOutputData != nil);
    
    keyData = [QHex dataWithHexString:@"0C1032520302EC8537A4A82C4EF7579D2b88e4309655eb40707decdb143e328a"];
    assert(keyData != nil);

    op = [[QCCAESCryptor alloc] initToEncryptInputData:inputData keyData:keyData];
    op.ivData = nil;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);
    XCTAssertEqualObjects(expectedOutputData, op.outputData);
}

- (void)testAES256ECBDecryption {
    NSData *            inputData;
    NSData *            keyData;
    QCCAESCryptor *     op;
    NSData *            expectedOutputData;
    
    inputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"cyphertext-aes-256-ecb-336" withExtension:@"dat"]];
    assert(inputData != nil);
    
    expectedOutputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"plaintext-336" withExtension:@"dat"]];
    assert(expectedOutputData != nil);
    
    keyData = [QHex dataWithHexString:@"0C1032520302EC8537A4A82C4EF7579D2b88e4309655eb40707decdb143e328a"];
    assert(keyData != nil);
    
    op = [[QCCAESCryptor alloc] initToDecryptInputData:inputData keyData:keyData];
    op.ivData = nil;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);
    XCTAssertEqualObjects(expectedOutputData, op.outputData);
}

// AES-256 CBC

- (void)testAES256CBCEncryption {
    NSData *            inputData;
    NSData *            keyData;
    NSData *            ivData;
    QCCAESCryptor *     op;
    NSData *            expectedOutputData;
    
    inputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"plaintext-336" withExtension:@"dat"]];
    assert(inputData != nil);
    
    expectedOutputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"cyphertext-aes-256-cbc-336" withExtension:@"dat"]];
    assert(expectedOutputData != nil);
    
    keyData = [QHex dataWithHexString:@"0C1032520302EC8537A4A82C4EF7579D2b88e4309655eb40707decdb143e328a"];
    assert(keyData != nil);

    ivData = [QHex dataWithHexString:@"AB5BBEB426015DA7EEDCEE8BEE3DFFB7"];
    assert(ivData != nil);
    
    op = [[QCCAESCryptor alloc] initToEncryptInputData:inputData keyData:keyData];
    op.ivData = ivData;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);
    XCTAssertEqualObjects(expectedOutputData, op.outputData);
}

- (void)testAES256CBCDecryption {
    NSData *            inputData;
    NSData *            keyData;
    NSData *            ivData;
    QCCAESCryptor *     op;
    NSData *            expectedOutputData;
    
    inputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"cyphertext-aes-256-cbc-336" withExtension:@"dat"]];
    assert(inputData != nil);
    
    expectedOutputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"plaintext-336" withExtension:@"dat"]];
    assert(expectedOutputData != nil);
    
    keyData = [QHex dataWithHexString:@"0C1032520302EC8537A4A82C4EF7579D2b88e4309655eb40707decdb143e328a"];
    assert(keyData != nil);

    ivData = [QHex dataWithHexString:@"AB5BBEB426015DA7EEDCEE8BEE3DFFB7"];
    assert(ivData != nil);
    
    op = [[QCCAESCryptor alloc] initToDecryptInputData:inputData keyData:keyData];
    op.ivData = ivData;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);
    XCTAssertEqualObjects(expectedOutputData, op.outputData);
}

// errors

- (void)testAESErrors {
    NSData *            inputData;
    NSData *            keyData;
    NSData *            ivData;
    QCCAESCryptor *     op;
    
    // data not a multiple of the block size
    
    inputData = [QHex dataWithHexString:@"000102030405060708090a0b0c0d0e"];
    assert(inputData != nil);

    keyData = [QHex dataWithHexString:@"000102030405060708090a0b0c0d0e0f"];
    assert(keyData != nil);

    op = [[QCCAESCryptor alloc] initToEncryptInputData:inputData keyData:keyData];
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, QCCAESCryptorErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) kCCParamError);
    XCTAssertNil(op.outputData);

    op = [[QCCAESCryptor alloc] initToDecryptInputData:inputData keyData:keyData];
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, QCCAESCryptorErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) kCCParamError);
    XCTAssertNil(op.outputData);

    // key not one of the standard AES key lengths
    
    inputData = [QHex dataWithHexString:@"000102030405060708090a0b0c0d0e0f"];
    assert(inputData != nil);

    keyData = [QHex dataWithHexString:@"000102030405060708090a0b0c0d0e"];
    assert(keyData != nil);

    op = [[QCCAESCryptor alloc] initToEncryptInputData:inputData keyData:keyData];
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, QCCAESCryptorErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) kCCParamError);
    XCTAssertNil(op.outputData);

    op = [[QCCAESCryptor alloc] initToDecryptInputData:inputData keyData:keyData];
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, QCCAESCryptorErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) kCCParamError);
    XCTAssertNil(op.outputData);

    // IV specified, but not a multiple of the block size
    
    inputData = [QHex dataWithHexString:@"000102030405060708090a0b0c0d0e0f"];
    assert(inputData != nil);

    keyData = [QHex dataWithHexString:@"000102030405060708090a0b0c0d0e0f"];
    assert(keyData != nil);

    ivData = [QHex dataWithHexString:@"000102030405060708090a0b0c0d0e"];
    assert(keyData != nil);

    op = [[QCCAESCryptor alloc] initToEncryptInputData:inputData keyData:keyData];
    op.ivData = ivData;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, QCCAESCryptorErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) kCCParamError);
    XCTAssertNil(op.outputData);

    op = [[QCCAESCryptor alloc] initToDecryptInputData:inputData keyData:keyData];
    op.ivData = ivData;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, QCCAESCryptorErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) kCCParamError);
    XCTAssertNil(op.outputData);
}

- (void)testAESThrows {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows((void) [[QCCAESCryptor alloc] initToDecryptInputData:nil keyData:[NSData data]]);
    XCTAssertThrows((void) [[QCCAESCryptor alloc] initToDecryptInputData:[NSData data] keyData:nil]);
    XCTAssertThrows((void) [[QCCAESCryptor alloc] initToEncryptInputData:nil keyData:[NSData data]]);
    XCTAssertThrows((void) [[QCCAESCryptor alloc] initToEncryptInputData:[NSData data] keyData:nil]);
    #pragma clang diagnostic pop
}

#pragma mark * QCCAESCryptor

// AES-128 Pad CBC

- (void)testAES128PadCBCEncryption {
    NSData *            inputData;
    NSData *            keyData;
    NSData *            ivData;
    QCCAESPadCryptor *  op;
    NSData *            expectedOutputData;
    
    inputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"plaintext-332" withExtension:@"dat"]];
    assert(inputData != nil);
    
    expectedOutputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"cyphertext-aes-128-cbc-332" withExtension:@"dat"]];
    assert(expectedOutputData != nil);
    
    keyData = [QHex dataWithHexString:@"0C1032520302EC8537A4A82C4EF7579D"];
    assert(keyData != nil);

    ivData = [QHex dataWithHexString:@"AB5BBEB426015DA7EEDCEE8BEE3DFFB7"];
    assert(ivData != nil);
    
    op = [[QCCAESPadCryptor alloc] initToEncryptInputData:inputData keyData:keyData];
    op.ivData = ivData;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);
    XCTAssertEqualObjects(expectedOutputData, op.outputData);
}

- (void)testAES128PadCBCEncryptionEmpty {
    NSData *            inputData;
    NSData *            keyData;
    NSData *            ivData;
    QCCAESPadCryptor *  op;
    NSData *            expectedOutputData;
    
    inputData = [NSData data];
    assert(inputData != nil);
    
    expectedOutputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"cyphertext-aes-128-cbc-0" withExtension:@"dat"]];
    assert(expectedOutputData != nil);
    
    keyData = [QHex dataWithHexString:@"0C1032520302EC8537A4A82C4EF7579D"];
    assert(keyData != nil);

    ivData = [QHex dataWithHexString:@"AB5BBEB426015DA7EEDCEE8BEE3DFFB7"];
    assert(ivData != nil);
    
    op = [[QCCAESPadCryptor alloc] initToEncryptInputData:inputData keyData:keyData];
    op.ivData = ivData;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);
    XCTAssertEqualObjects(expectedOutputData, op.outputData);
}

- (void)testAES128PadCBCDecryption {
    NSData *            inputData;
    NSData *            keyData;
    NSData *            ivData;
    QCCAESPadCryptor *  op;
    NSData *            expectedOutputData;
    
    inputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"cyphertext-aes-128-cbc-332" withExtension:@"dat"]];
    assert(inputData != nil);
    
    expectedOutputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"plaintext-332" withExtension:@"dat"]];
    assert(expectedOutputData != nil);
    
    keyData = [QHex dataWithHexString:@"0C1032520302EC8537A4A82C4EF7579D"];
    assert(keyData != nil);

    ivData = [QHex dataWithHexString:@"AB5BBEB426015DA7EEDCEE8BEE3DFFB7"];
    assert(ivData != nil);
    
    op = [[QCCAESPadCryptor alloc] initToDecryptInputData:inputData keyData:keyData];
    op.ivData = ivData;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);
    XCTAssertEqualObjects(expectedOutputData, op.outputData);
}

- (void)testAES128PadCBCDecryptionEmpty {
    NSData *            inputData;
    NSData *            keyData;
    NSData *            ivData;
    QCCAESPadCryptor *  op;
    NSData *            expectedOutputData;
    
    inputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"cyphertext-aes-128-cbc-0" withExtension:@"dat"]];
    assert(inputData != nil);
    
    expectedOutputData = [NSData data];
    assert(expectedOutputData != nil);
    
    keyData = [QHex dataWithHexString:@"0C1032520302EC8537A4A82C4EF7579D"];
    assert(keyData != nil);

    ivData = [QHex dataWithHexString:@"AB5BBEB426015DA7EEDCEE8BEE3DFFB7"];
    assert(ivData != nil);
    
    op = [[QCCAESPadCryptor alloc] initToDecryptInputData:inputData keyData:keyData];
    op.ivData = ivData;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);
    XCTAssertEqualObjects(expectedOutputData, op.outputData);
}

// AES-256 Pad CBC

- (void)testAES256PadCBCEncryption {
    NSData *            inputData;
    NSData *            keyData;
    NSData *            ivData;
    QCCAESPadCryptor *  op;
    NSData *            expectedOutputData;
    
    inputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"plaintext-332" withExtension:@"dat"]];
    assert(inputData != nil);
    
    expectedOutputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"cyphertext-aes-256-cbc-332" withExtension:@"dat"]];
    assert(expectedOutputData != nil);
    
    keyData = [QHex dataWithHexString:@"0C1032520302EC8537A4A82C4EF7579D2b88e4309655eb40707decdb143e328a"];
    assert(keyData != nil);

    ivData = [QHex dataWithHexString:@"AB5BBEB426015DA7EEDCEE8BEE3DFFB7"];
    assert(ivData != nil);
    
    op = [[QCCAESPadCryptor alloc] initToEncryptInputData:inputData keyData:keyData];
    op.ivData = ivData;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);
    XCTAssertEqualObjects(expectedOutputData, op.outputData);
}

- (void)testAES256PadCBCDecryption {
    NSData *            inputData;
    NSData *            keyData;
    NSData *            ivData;
    QCCAESPadCryptor *  op;
    NSData *            expectedOutputData;
    
    inputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"cyphertext-aes-256-cbc-332" withExtension:@"dat"]];
    assert(inputData != nil);
    
    expectedOutputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"plaintext-332" withExtension:@"dat"]];
    assert(expectedOutputData != nil);
    
    keyData = [QHex dataWithHexString:@"0C1032520302EC8537A4A82C4EF7579D2b88e4309655eb40707decdb143e328a"];
    assert(keyData != nil);

    ivData = [QHex dataWithHexString:@"AB5BBEB426015DA7EEDCEE8BEE3DFFB7"];
    assert(ivData != nil);
    
    op = [[QCCAESPadCryptor alloc] initToDecryptInputData:inputData keyData:keyData];
    op.ivData = ivData;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);
    XCTAssertEqualObjects(expectedOutputData, op.outputData);
}

// errors

- (void)testAESPadErrors {
    NSData *            inputData;
    NSData *            keyData;
    NSData *            ivData;
    QCCAESPadCryptor *  op;
    
    // data not a multiple of the block size
    
    // Note that we don't test the encrypt case here because the whole point of padding 
    // is to allow us to encrypt data that's not a multiple of the block length.
    
    inputData = [QHex dataWithHexString:@"000102030405060708090a0b0c0d0e"];
    assert(inputData != nil);

    keyData = [QHex dataWithHexString:@"000102030405060708090a0b0c0d0e0f"];
    assert(keyData != nil);

    op = [[QCCAESPadCryptor alloc] initToDecryptInputData:inputData keyData:keyData];
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, QCCAESPadCryptorErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) kCCParamError);
    XCTAssertNil(op.outputData);

    // key not one of the standard AES key lengths
    
    inputData = [QHex dataWithHexString:@"000102030405060708090a0b0c0d0e0f"];
    assert(inputData != nil);

    keyData = [QHex dataWithHexString:@"000102030405060708090a0b0c0d0e"];
    assert(keyData != nil);

    op = [[QCCAESPadCryptor alloc] initToEncryptInputData:inputData keyData:keyData];
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, QCCAESPadCryptorErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) kCCParamError);
    XCTAssertNil(op.outputData);

    op = [[QCCAESPadCryptor alloc] initToDecryptInputData:inputData keyData:keyData];
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, QCCAESPadCryptorErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) kCCParamError);
    XCTAssertNil(op.outputData);

    // IV specified, but not a multiple of the block size
    
    inputData = [QHex dataWithHexString:@"000102030405060708090a0b0c0d0e0f"];
    assert(inputData != nil);

    keyData = [QHex dataWithHexString:@"000102030405060708090a0b0c0d0e0f"];
    assert(keyData != nil);

    ivData = [QHex dataWithHexString:@"000102030405060708090a0b0c0d0e"];
    assert(keyData != nil);

    op = [[QCCAESPadCryptor alloc] initToEncryptInputData:inputData keyData:keyData];
    op.ivData = ivData;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, QCCAESPadCryptorErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) kCCParamError);
    XCTAssertNil(op.outputData);

    op = [[QCCAESPadCryptor alloc] initToDecryptInputData:inputData keyData:keyData];
    op.ivData = ivData;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, QCCAESPadCryptorErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) kCCParamError);
    XCTAssertNil(op.outputData);
}

- (void)testAESPadThrows {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows((void) [[QCCAESPadCryptor alloc] initToDecryptInputData:nil keyData:[NSData data]]);
    XCTAssertThrows((void) [[QCCAESPadCryptor alloc] initToDecryptInputData:[NSData data] keyData:nil]);
    XCTAssertThrows((void) [[QCCAESPadCryptor alloc] initToEncryptInputData:nil keyData:[NSData data]]);
    XCTAssertThrows((void) [[QCCAESPadCryptor alloc] initToEncryptInputData:[NSData data] keyData:nil]);
    #pragma clang diagnostic pop
}

#pragma mark * QCCAESPadBigCryptor

// AES-128 Pad Big CBC

- (void)testAES128PadBigCBCEncryption {
    NSData *                inputData;
    NSInputStream *         inputStream;
    NSOutputStream *        outputStream;
    NSData *                keyData;
    NSData *                ivData;
    QCCAESPadBigCryptor *   op;
    NSData *                expectedOutputData;
    
    inputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"plaintext-332" withExtension:@"dat"]];
    assert(inputData != nil);

    inputStream = [NSInputStream inputStreamWithData:inputData];
    assert(inputStream != nil);
    
    outputStream = [NSOutputStream outputStreamToMemory];
    assert(outputStream != nil);
    
    expectedOutputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"cyphertext-aes-128-cbc-332" withExtension:@"dat"]];
    assert(expectedOutputData != nil);
    
    keyData = [QHex dataWithHexString:@"0C1032520302EC8537A4A82C4EF7579D"];
    assert(keyData != nil);

    ivData = [QHex dataWithHexString:@"AB5BBEB426015DA7EEDCEE8BEE3DFFB7"];
    assert(ivData != nil);
    
    op = [[QCCAESPadBigCryptor alloc] initToEncryptInputStream:inputStream toOutputStream:outputStream keyData:keyData];
    op.ivData = ivData;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);
    XCTAssertEqualObjects(expectedOutputData, [outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey]);
}

- (void)testAES128PadBigCBCDecryption {
    NSData *                inputData;
    NSInputStream *         inputStream;
    NSOutputStream *        outputStream;
    NSData *                keyData;
    NSData *                ivData;
    QCCAESPadBigCryptor *   op;
    NSData *                expectedOutputData;
    
    inputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"cyphertext-aes-128-cbc-332" withExtension:@"dat"]];
    assert(inputData != nil);
    
    inputStream = [NSInputStream inputStreamWithData:inputData];
    assert(inputStream != nil);
    
    outputStream = [NSOutputStream outputStreamToMemory];
    assert(outputStream != nil);
    
    expectedOutputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"plaintext-332" withExtension:@"dat"]];
    assert(expectedOutputData != nil);
    
    keyData = [QHex dataWithHexString:@"0C1032520302EC8537A4A82C4EF7579D"];
    assert(keyData != nil);

    ivData = [QHex dataWithHexString:@"AB5BBEB426015DA7EEDCEE8BEE3DFFB7"];
    assert(ivData != nil);
    
    op = [[QCCAESPadBigCryptor alloc] initToDecryptInputStream:inputStream toOutputStream:outputStream keyData:keyData];
    op.ivData = ivData;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);
    XCTAssertEqualObjects(expectedOutputData, [outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey]);
}

#if 0

// This test has been disabled because modern versions of CommonCrypto do /not/ return 
// errors (because they allow for padding oracle attacks).
//
// <https://en.wikipedia.org/wiki/Padding_oracle_attack>
 
- (void)testAES128PadBigErrors {
    NSData *                inputData;
    NSInputStream *         inputStream;
    NSOutputStream *        outputStream;
    NSData *                keyData;
    NSData *                ivData;
    QCCAESPadBigCryptor *   op;
    NSData *                expectedOutputData;
    NSData *                actualOutputData;
    
    // data not a multiple of the block size

    inputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"cyphertext-aes-128-cbc-332" withExtension:@"dat"]];
    assert(inputData != nil);
    
    inputData = [inputData subdataWithRange:NSMakeRange(0, [inputData length] - 1)];
    assert(inputData != nil);
    
    inputStream = [NSInputStream inputStreamWithData:inputData];
    assert(inputStream != nil);
    
    outputStream = [NSOutputStream outputStreamToMemory];
    assert(outputStream != nil);
    
    expectedOutputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"plaintext-332" withExtension:@"dat"]];
    assert(expectedOutputData != nil);
    
    keyData = [QHex dataWithHexString:@"0C1032520302EC8537A4A82C4EF7579D"];
    assert(keyData != nil);

    ivData = [QHex dataWithHexString:@"AB5BBEB426015DA7EEDCEE8BEE3DFFB7"];
    assert(ivData != nil);
    
    op = [[QCCAESPadBigCryptor alloc] initToDecryptInputStream:inputStream toOutputStream:outputStream keyData:keyData];
    op.ivData = ivData;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, QCCAESPadBigCryptorErrorDomain);
    // The actual error we get is kCCBufferTooSmall, which doesn't make much sense in this 
    // context, but that's what Common Crypto gives us.  Rather than test for a specific 
    // error, we test for any error.
    XCTAssertTrue(op.error.code != kCCSuccess);
    // We actually get partial output data.  Check that the any data we got is correct.
    actualOutputData = [outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    XCTAssertNotNil(actualOutputData);
    XCTAssertTrue([actualOutputData length] < [expectedOutputData length]);     // shouldn't have got all the bytes
    XCTAssertEqualObjects(actualOutputData, [expectedOutputData subdataWithRange:NSMakeRange(0, [actualOutputData length])]);
}

#endif

- (void)testAES128PadBigErrors2 {
    NSData *                inputData;
    NSInputStream *         inputStream;
    NSOutputStream *        outputStream;
    NSData *                keyData;
    NSData *                ivData;
    QCCAESPadBigCryptor *   op;

    // key not one of the standard AES key lengths

    inputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"cyphertext-aes-128-cbc-332" withExtension:@"dat"]];
    assert(inputData != nil);
    
    inputStream = [NSInputStream inputStreamWithData:inputData];
    assert(inputStream != nil);
    
    outputStream = [NSOutputStream outputStreamToMemory];
    assert(outputStream != nil);
    
    keyData = [QHex dataWithHexString:@"0C1032520302EC8537A4A82C4EF757"];
    assert(keyData != nil);

    ivData = [QHex dataWithHexString:@"AB5BBEB426015DA7EEDCEE8BEE3DFFB7"];
    assert(ivData != nil);
    
    op = [[QCCAESPadBigCryptor alloc] initToDecryptInputStream:inputStream toOutputStream:outputStream keyData:keyData];
    op.ivData = ivData;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, QCCAESPadBigCryptorErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) kCCParamError);
    XCTAssertEqual([ (NSData *) [outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey] length], (NSUInteger) 0);

    // IV specified, but not a multiple of the block size

    inputData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"cyphertext-aes-128-cbc-332" withExtension:@"dat"]];
    assert(inputData != nil);
    
    inputStream = [NSInputStream inputStreamWithData:inputData];
    assert(inputStream != nil);
    
    outputStream = [NSOutputStream outputStreamToMemory];
    assert(outputStream != nil);
    
    keyData = [QHex dataWithHexString:@"0C1032520302EC8537A4A82C4EF7579D"];
    assert(keyData != nil);

    ivData = [QHex dataWithHexString:@"AB5BBEB426015DA7EEDCEE8BEE3DFF"];
    assert(ivData != nil);
    
    op = [[QCCAESPadBigCryptor alloc] initToDecryptInputStream:inputStream toOutputStream:outputStream keyData:keyData];
    op.ivData = ivData;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, QCCAESPadBigCryptorErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) kCCParamError);
    XCTAssertEqual([ (NSData *) [outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey] length], (NSUInteger) 0);
}

- (void)testAESPadBigThrows {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows((void) [[QCCAESPadBigCryptor alloc] initToDecryptInputStream:nil toOutputStream:[NSOutputStream outputStreamToMemory] keyData:[NSData data]]);
    XCTAssertThrows((void) [[QCCAESPadBigCryptor alloc] initToDecryptInputStream:[NSInputStream inputStreamWithData:[NSData data]] toOutputStream:nil keyData:[NSData data]]);
    XCTAssertThrows((void) [[QCCAESPadBigCryptor alloc] initToDecryptInputStream:[NSInputStream inputStreamWithData:[NSData data]] toOutputStream:[NSOutputStream outputStreamToMemory] keyData:nil]);
    #pragma clang diagnostic pop
}

@end
