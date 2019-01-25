/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Tests for the RSA compatibility operations.
 */

#import "RSAOperationsTestsBase.h"

#import "QCCRSASHASignatureCompat.h"
#import "QCCRSASmallCryptorCompat.h"

#import "ToolCommon.h"
#import "QHex.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSAOperationsTestsCompat : RSAOperationsTestsBase

@end

@interface RSAOperationsTestsCompat ()

@end

NS_ASSUME_NONNULL_END

static BOOL sUseCompatibilityCode = NO;

@implementation RSAOperationsTestsCompat

- (void)setUp {
    [super setUp];

    [ToolCommon sharedInstance].debugRunOpOnMainThread = YES;
}

static const QCCRSASHASignatureCompatAlgorithm  kAlgorithms[5] = { QCCRSASHASignatureCompatAlgorithmSHA1, QCCRSASHASignatureCompatAlgorithmSHA2_224, QCCRSASHASignatureCompatAlgorithmSHA2_256, QCCRSASHASignatureCompatAlgorithmSHA2_384, QCCRSASHASignatureCompatAlgorithmSHA2_512 };
static       NSString * kSignatures[5] = { 
    @"test.cer-sha1", 
    @"test.cer-sha2-224", 
    @"test.cer-sha2-256", 
    @"test.cer-sha2-384", 
    @"test.cer-sha2-512", 
};

- (NSInteger)verifyCountForFile:(NSString *)fileName {
    NSInteger   result;
    NSData *    fileData;
    
    fileData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:fileName withExtension:@"cer"]];
    assert(fileData != nil);
    
    result = 0;
    for (size_t i = 0; i < 5; i++) {
        NSData *                    signatureData;
        QCCRSASHAVerifyCompat *     op;

        signatureData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:kSignatures[i] withExtension:@"sig"]];
        assert(signatureData != nil);
        
        op = [[QCCRSASHAVerifyCompat alloc] initWithAlgorithm:kAlgorithms[i] inputData:fileData publicKey:self.publicKey signatureData:signatureData];
        op.debugUseCompatibilityCode = sUseCompatibilityCode;
        [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
        assert(op.error == nil);
        if (op.verified) {
            result += 1;
        }
    }
    return result;
}

- (void)testRSASHAVerify {
    XCTAssertEqual([self verifyCountForFile:@"test"], (NSInteger) 5);
    XCTAssertEqual([self verifyCountForFile:@"test-corrupted"], (NSInteger) 0);
}

- (void)testRSASHASign {
    NSData *                fileData;
    
    fileData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"test" withExtension:@"cer"]];
    assert(fileData != nil);

    for (size_t i = 0; i < 5; i++) {
        QCCRSASHASignCompat *   op;
        NSData *                expectedSignatureData;

        expectedSignatureData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:kSignatures[i] withExtension:@"sig"]];
        assert(expectedSignatureData != nil);
        
        op = [[QCCRSASHASignCompat alloc] initWithAlgorithm:kAlgorithms[i] inputData:fileData privateKey:self.privateKey];
        op.debugUseCompatibilityCode = sUseCompatibilityCode;
        [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
        XCTAssertNil(op.error);
        XCTAssertEqualObjects(op.signatureData, expectedSignatureData);
    }
}

// When you encrypt with padding you can't test a fixed encryption because the padding 
// adds some randomness so that no two encryptions are the same.  Thus, we can only test 
// the round trip case (-testRSASmallCryptor) and the decrypt case (-testRSADecryptPKCS1 
// and -testRSADecryptOAEP).

- (void)testRSASmallCryptor {
    NSData *                    fileData;
    QCCRSASmallCryptorCompat *  op;
    
    fileData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"plaintext-32" withExtension:@"dat"]];
    assert(fileData != nil);
    
    op = [[QCCRSASmallCryptorCompat alloc] initToEncryptSmallInputData:fileData key:self.publicKey];
    op.debugUseCompatibilityCode = sUseCompatibilityCode;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);
    
    if (op.smallOutputData != nil) {
        op = [[QCCRSASmallCryptorCompat alloc] initToDecryptSmallInputData:op.smallOutputData key:self.privateKey];
        op.debugUseCompatibilityCode = sUseCompatibilityCode;
        [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
        XCTAssertNil(op.error);

        XCTAssertEqualObjects(fileData, op.smallOutputData);
    }
}

- (void)testRSADecryptPKCS1 {
    NSData *                    fileData;
    QCCRSASmallCryptorCompat *  op;
    NSData *                    cyphertext32Data;

    fileData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"plaintext-32" withExtension:@"dat"]];
    assert(fileData != nil);
    
    // This is the "plaintext-32.dat" data encrypted with the public key using the 
    // following OpenSSL command:
    //
    // $ openssl rsautl -encrypt -pkcs -pubin -inkey TestData/public.pem -in TestData/plaintext-32.dat

    cyphertext32Data = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"cyphertext-rsa-pkcs1-32" withExtension:@"dat"]];
    assert(cyphertext32Data != nil);
    
    op = [[QCCRSASmallCryptorCompat alloc] initToDecryptSmallInputData:cyphertext32Data key:self.privateKey];
    op.debugUseCompatibilityCode = sUseCompatibilityCode;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);

    XCTAssertEqualObjects(fileData, op.smallOutputData);
}

- (void)testRSADecryptOAEP {
    NSData *                    fileData;
    QCCRSASmallCryptorCompat *  op;
    NSData *                    cyphertext32Data;

    fileData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"plaintext-32" withExtension:@"dat"]];
    assert(fileData != nil);
    
    // This is the "plaintext-32.dat" data encrypted with the public key using the 
    // following OpenSSL command:
    //
    // $ openssl rsautl -encrypt -oaep -pubin -inkey TestData/public.pem -in TestData/plaintext-32.dat
    
    cyphertext32Data = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"cyphertext-rsa-oaep-32" withExtension:@"dat"]];
    assert(cyphertext32Data != nil);

    op = [[QCCRSASmallCryptorCompat alloc] initToDecryptSmallInputData:cyphertext32Data key:self.privateKey];
    op.debugUseCompatibilityCode = sUseCompatibilityCode;
    op.padding = QCCRSASmallCryptorCompatPaddingOAEP;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);
    XCTAssertEqualObjects(fileData, op.smallOutputData);
}

- (void)testRSAVerifyError {
    NSData *                    fileData;
    NSData *                    signatureData;
    QCCRSASHAVerifyCompat *     op;
    
    // passing private key to verify
    
    fileData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"test" withExtension:@"cer"]];
    assert(fileData != nil);
    
    signatureData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"test.cer-sha1" withExtension:@"sig"]];
    assert(signatureData != nil);
    
    op = [[QCCRSASHAVerifyCompat alloc] initWithAlgorithm:QCCRSASHASignatureCompatAlgorithmSHA1 inputData:fileData publicKey:self.privateKey signatureData:signatureData];
    op.debugUseCompatibilityCode = sUseCompatibilityCode;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    // We skip the error check because some OS releases make it impossible to determine 
    // where there was a very failure or a parameter error.  What matters here is that 
    // op.verified is false.
    //
    // XCTAssertNotNil(op.error);
    // XCTAssertEqualObjects(op.error.domain, @"Internal CSSM error");
    // XCTAssertTrue(op.error.code != 0);
    XCTAssertFalse(op.verified);        // this would be true if we'd passed in self.publicKey
}

- (void)testRSASignError {
    NSData *                fileData;
    NSData *                expectedSignatureData;
    QCCRSASHASignCompat *   op;
    
    // Note: This test fails on OS X 10.7.x because the signing transform doesn't fail if
    // you pass it a public key; rather it succeeds, but produces gibberish results.
    
    // passing public key to sign
    
    fileData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"test" withExtension:@"cer"]];
    assert(fileData != nil);
    
    expectedSignatureData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"test.cer-sha1" withExtension:@"sig"]];
    assert(expectedSignatureData != nil);
    
    op = [[QCCRSASHASignCompat alloc] initWithAlgorithm:QCCRSASHASignatureCompatAlgorithmSHA1 inputData:fileData privateKey:self.publicKey];
    op.debugUseCompatibilityCode = sUseCompatibilityCode;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertNotNil(op.error.domain);
    XCTAssertTrue(op.error.code != 0); // We don't check the specific error here because different OS releases given you different values.
    XCTAssertNil(op.signatureData);
}

- (void)testRSACryptorErrorWrongKeys {
    NSData *                    plaintextData;
    NSData *                    cyphertextData;
    QCCRSASmallCryptorCompat *  op;
    
    // encrypt with the private key
    
    plaintextData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"plaintext-32" withExtension:@"dat"]];
    assert(plaintextData != nil);
    
    op = [[QCCRSASmallCryptorCompat alloc] initToEncryptSmallInputData:plaintextData key:self.privateKey];
    op.debugUseCompatibilityCode = sUseCompatibilityCode;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, NSOSStatusErrorDomain);
    XCTAssertTrue(op.error.code != 0); // We don't check the specific error here because different OS releases given you different values.
    XCTAssertNil(op.smallOutputData);

    // decrypt with the public key
    
    cyphertextData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"cyphertext-rsa-pkcs1-32" withExtension:@"dat"]];
    assert(cyphertextData != nil);
    
    op = [[QCCRSASmallCryptorCompat alloc] initToDecryptSmallInputData:cyphertextData key:self.publicKey];
    op.debugUseCompatibilityCode = sUseCompatibilityCode;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, NSOSStatusErrorDomain);
    XCTAssertTrue(op.error.code != 0); // We don't check the specific error here because different OS releases given you different values.
    XCTAssertNil(op.smallOutputData);
}

- (void)testRSACryptorErrorTooBig {
    NSData *                    plaintextData;
    QCCRSASmallCryptorCompat *  op;

    // PKCS#1
    
    plaintextData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"plaintext-332" withExtension:@"dat"]];
    assert(plaintextData != nil);
    
    op = [[QCCRSASmallCryptorCompat alloc] initToEncryptSmallInputData:plaintextData key:self.publicKey];
    op.debugUseCompatibilityCode = sUseCompatibilityCode;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, NSOSStatusErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) errSecParam);
    XCTAssertNil(op.smallOutputData);
    
    plaintextData = [plaintextData subdataWithRange:NSMakeRange(0, 256)];

    op = [[QCCRSASmallCryptorCompat alloc] initToEncryptSmallInputData:plaintextData key:self.publicKey];
    op.debugUseCompatibilityCode = sUseCompatibilityCode;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, NSOSStatusErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) errSecParam);
    XCTAssertNil(op.smallOutputData);

    plaintextData = [plaintextData subdataWithRange:NSMakeRange(0, 246)];

    op = [[QCCRSASmallCryptorCompat alloc] initToEncryptSmallInputData:plaintextData key:self.publicKey];
    op.debugUseCompatibilityCode = sUseCompatibilityCode;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, NSOSStatusErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) errSecParam);
    XCTAssertNil(op.smallOutputData);

    // Note: The following test fails on iOS 5.x because of an off-by-one error in the data 
    // length check in the Security framework.  To make it work on 5.x you have to change 
    // 245 to 244.  245 is definitely the right number, so I've left the test as it should be 
    // and commented about the failure here.

    plaintextData = [plaintextData subdataWithRange:NSMakeRange(0, 245)];

    op = [[QCCRSASmallCryptorCompat alloc] initToEncryptSmallInputData:plaintextData key:self.publicKey];
    op.debugUseCompatibilityCode = sUseCompatibilityCode;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);

    // OAEP
    
    plaintextData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"plaintext-332" withExtension:@"dat"]];
    assert(plaintextData != nil);
    
    op = [[QCCRSASmallCryptorCompat alloc] initToEncryptSmallInputData:plaintextData key:self.publicKey];
    op.debugUseCompatibilityCode = sUseCompatibilityCode;
    op.padding = QCCRSASmallCryptorCompatPaddingOAEP;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, NSOSStatusErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) errSecParam);
    XCTAssertNil(op.smallOutputData);
    
    plaintextData = [plaintextData subdataWithRange:NSMakeRange(0, 256)];

    op = [[QCCRSASmallCryptorCompat alloc] initToEncryptSmallInputData:plaintextData key:self.publicKey];
    op.debugUseCompatibilityCode = sUseCompatibilityCode;
    op.padding = QCCRSASmallCryptorCompatPaddingOAEP;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, NSOSStatusErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) errSecParam);
    XCTAssertNil(op.smallOutputData);

    plaintextData = [plaintextData subdataWithRange:NSMakeRange(0, 215)];

    op = [[QCCRSASmallCryptorCompat alloc] initToEncryptSmallInputData:plaintextData key:self.publicKey];
    op.debugUseCompatibilityCode = sUseCompatibilityCode;
    op.padding = QCCRSASmallCryptorCompatPaddingOAEP;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, NSOSStatusErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) errSecParam);
    XCTAssertNil(op.smallOutputData);

    plaintextData = [plaintextData subdataWithRange:NSMakeRange(0, 214)];

    op = [[QCCRSASmallCryptorCompat alloc] initToEncryptSmallInputData:plaintextData key:self.publicKey];
    op.debugUseCompatibilityCode = sUseCompatibilityCode;
    op.padding = QCCRSASmallCryptorCompatPaddingOAEP;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);
}

- (void)testRSACryptorErrorWrongLength {
    NSData *                    cyphertextData;
    QCCRSASmallCryptorCompat *  op;

    // PKCS#1

    cyphertextData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"cyphertext-rsa-pkcs1-32" withExtension:@"dat"]];
    assert(cyphertextData != nil);
    
    cyphertextData = [cyphertextData subdataWithRange:NSMakeRange(0, 255)];
    
    op = [[QCCRSASmallCryptorCompat alloc] initToDecryptSmallInputData:cyphertextData key:self.privateKey];
    op.debugUseCompatibilityCode = sUseCompatibilityCode;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, NSOSStatusErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) errSecParam);
    XCTAssertNil(op.smallOutputData);

    // OAEP
    
    cyphertextData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"cyphertext-rsa-oaep-32" withExtension:@"dat"]];
    assert(cyphertextData != nil);
    
    cyphertextData = [cyphertextData subdataWithRange:NSMakeRange(0, 255)];
    
    op = [[QCCRSASmallCryptorCompat alloc] initToDecryptSmallInputData:cyphertextData key:self.privateKey];
    op.padding = QCCRSASmallCryptorCompatPaddingOAEP;
    op.debugUseCompatibilityCode = sUseCompatibilityCode;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, NSOSStatusErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) errSecParam);
    XCTAssertNil(op.smallOutputData);
}

- (void)testRSAThrows {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wnonnull"

    XCTAssertThrows((void) [[QCCRSASHAVerifyCompat alloc] initWithAlgorithm:QCCRSASHASignatureCompatAlgorithmSHA1 inputData:nil publicKey:self.publicKey signatureData:[NSData data]]);
    XCTAssertThrows((void) [[QCCRSASHAVerifyCompat alloc] initWithAlgorithm:QCCRSASHASignatureCompatAlgorithmSHA1 inputData:[NSData data] publicKey:NULL signatureData:[NSData data]]);
    XCTAssertThrows((void) [[QCCRSASHAVerifyCompat alloc] initWithAlgorithm:QCCRSASHASignatureCompatAlgorithmSHA1 inputData:[NSData data] publicKey:self.publicKey signatureData:nil]);

    XCTAssertThrows((void) [[QCCRSASHASignCompat alloc] initWithAlgorithm:QCCRSASHASignatureCompatAlgorithmSHA1 inputData:nil privateKey:self.privateKey]);
    XCTAssertThrows((void) [[QCCRSASHASignCompat alloc] initWithAlgorithm:QCCRSASHASignatureCompatAlgorithmSHA1 inputData:[NSData data] privateKey:NULL]);

    XCTAssertThrows((void) [[QCCRSASmallCryptorCompat alloc] initToDecryptSmallInputData:nil key:self.publicKey]);
    XCTAssertThrows((void) [[QCCRSASmallCryptorCompat alloc] initToDecryptSmallInputData:[NSData data] key:NULL]);
    XCTAssertThrows((void) [[QCCRSASmallCryptorCompat alloc] initToEncryptSmallInputData:nil key:self.privateKey]);
    XCTAssertThrows((void) [[QCCRSASmallCryptorCompat alloc] initToEncryptSmallInputData:[NSData data] key:NULL]);

    #pragma clang diagnostic pop
}

@end
