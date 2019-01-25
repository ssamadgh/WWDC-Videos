/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Tests for the RSA operations.
 */

#import "RSAOperationsTestsBase.h"

#import "QCCRSASHASignature.h"
#import "QCCRSASmallCryptor.h"

#import "ToolCommon.h"
#import "QHex.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSAOperationsTests : RSAOperationsTestsBase

@end

@interface RSAOperationsTests ()

@end

NS_ASSUME_NONNULL_END

@implementation RSAOperationsTests

- (void)setUp {
    [super setUp];

    [ToolCommon sharedInstance].debugRunOpOnMainThread = YES;
}

static const QCCRSASHASignatureAlgorithm  kAlgorithms[5] = { QCCRSASHASignatureAlgorithmSHA1, QCCRSASHASignatureAlgorithmSHA2_224, QCCRSASHASignatureAlgorithmSHA2_256, QCCRSASHASignatureAlgorithmSHA2_384, QCCRSASHASignatureAlgorithmSHA2_512 };
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
        QCCRSASHAVerify *           op;

        signatureData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:kSignatures[i] withExtension:@"sig"]];
        assert(signatureData != nil);
        
        op = [[QCCRSASHAVerify alloc] initWithAlgorithm:kAlgorithms[i] inputData:fileData publicKey:self.publicKey signatureData:signatureData];
        [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
        assert(op.error == nil);
        if (op.verified) {
            result += 1;
        }
    }
    return result;
}

- (void)testRSASHAVerify {
    if ( ! self.hasUnifiedCrypto ) { return; }
    XCTAssertEqual([self verifyCountForFile:@"test"], (NSInteger) 5);
    XCTAssertEqual([self verifyCountForFile:@"test-corrupted"], (NSInteger) 0);
}

- (void)testRSASHASign {
    if ( ! self.hasUnifiedCrypto ) { return; }
    NSData *                fileData;
    
    fileData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"test" withExtension:@"cer"]];
    assert(fileData != nil);

    for (size_t i = 0; i < 5; i++) {
        QCCRSASHASign *         op;
        NSData *                expectedSignatureData;

        expectedSignatureData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:kSignatures[i] withExtension:@"sig"]];
        assert(expectedSignatureData != nil);
        
        op = [[QCCRSASHASign alloc] initWithAlgorithm:kAlgorithms[i] inputData:fileData privateKey:self.privateKey];
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
    if ( ! self.hasUnifiedCrypto ) { return; }
    NSData *                    fileData;
    QCCRSASmallCryptor *        op;
    
    fileData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"plaintext-32" withExtension:@"dat"]];
    assert(fileData != nil);
    
    op = [[QCCRSASmallCryptor alloc] initToEncryptSmallInputData:fileData key:self.publicKey];
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);
    
    if (op.smallOutputData != nil) {
        op = [[QCCRSASmallCryptor alloc] initToDecryptSmallInputData:op.smallOutputData key:self.privateKey];
        [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
        XCTAssertNil(op.error);

        XCTAssertEqualObjects(fileData, op.smallOutputData);
    }
}

- (void)testRSADecryptPKCS1 {
    if ( ! self.hasUnifiedCrypto ) { return; }
    NSData *                    fileData;
    QCCRSASmallCryptor *        op;
    NSData *                    cyphertext32Data;

    fileData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"plaintext-32" withExtension:@"dat"]];
    assert(fileData != nil);
    
    // This is the "plaintext-32.dat" data encrypted with the public key using the 
    // following OpenSSL command:
    //
    // $ openssl rsautl -encrypt -pkcs -pubin -inkey TestData/public.pem -in TestData/plaintext-32.dat

    cyphertext32Data = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"cyphertext-rsa-pkcs1-32" withExtension:@"dat"]];
    assert(cyphertext32Data != nil);
    
    op = [[QCCRSASmallCryptor alloc] initToDecryptSmallInputData:cyphertext32Data key:self.privateKey];
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);

    XCTAssertEqualObjects(fileData, op.smallOutputData);
}

- (void)testRSADecryptOAEP {
    if ( ! self.hasUnifiedCrypto ) { return; }
    NSData *                    fileData;
    QCCRSASmallCryptor *        op;
    NSData *                    cyphertext32Data;

    fileData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"plaintext-32" withExtension:@"dat"]];
    assert(fileData != nil);
    
    // This is the "plaintext-32.dat" data encrypted with the public key using the 
    // following OpenSSL command:
    //
    // $ openssl rsautl -encrypt -oaep -pubin -inkey TestData/public.pem -in TestData/plaintext-32.dat
    
    cyphertext32Data = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"cyphertext-rsa-oaep-32" withExtension:@"dat"]];
    assert(cyphertext32Data != nil);

    op = [[QCCRSASmallCryptor alloc] initToDecryptSmallInputData:cyphertext32Data key:self.privateKey];
    op.padding = QCCRSASmallCryptorPaddingOAEP;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);
    XCTAssertEqualObjects(fileData, op.smallOutputData);
}

- (void)testRSAVerifyError {
    if ( ! self.hasUnifiedCrypto ) { return; }
    NSData *                    fileData;
    NSData *                    signatureData;
    QCCRSASHAVerify *           op;
    
    // passing private key to verify
    
    fileData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"test" withExtension:@"cer"]];
    assert(fileData != nil);
    
    signatureData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"test.cer-sha1" withExtension:@"sig"]];
    assert(signatureData != nil);
    
    op = [[QCCRSASHAVerify alloc] initWithAlgorithm:QCCRSASHASignatureAlgorithmSHA1 inputData:fileData publicKey:self.privateKey signatureData:signatureData];
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    // We skip the error check because some OS releases make it impossible to determine 
    // where there was a very failure or a parameter error.  What matters here is that 
    // op.verified is false.
    //
    // XCTAssertNotNil(op.error);
    // XCTAssertEqualObjects(op.error.domain, NSOSStatusErrorDomain);
    // XCTAssertEqual(op.error.code, (NSInteger) errSecUnimplemented);
    XCTAssertFalse(op.verified);        // this would be true if we'd passed in self.publicKey
}

- (void)testRSASignError {
    if ( ! self.hasUnifiedCrypto ) { return; }
    NSData *                fileData;
    NSData *                expectedSignatureData;
    QCCRSASHASign *         op;
    
    // passing public key to sign
    
    fileData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"test" withExtension:@"cer"]];
    assert(fileData != nil);
    
    expectedSignatureData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"test.cer-sha1" withExtension:@"sig"]];
    assert(expectedSignatureData != nil);
    
    op = [[QCCRSASHASign alloc] initWithAlgorithm:QCCRSASHASignatureAlgorithmSHA1 inputData:fileData privateKey:self.publicKey];
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertNotNil(op.error.domain);
    XCTAssertTrue(op.error.code != 0); // We don't check the specific error here because different OS releases given you different values.
    XCTAssertNil(op.signatureData);
}

- (void)testRSACryptorErrorWrongKeys {
    if ( ! self.hasUnifiedCrypto ) { return; }
    NSData *                    plaintextData;
    NSData *                    cyphertextData;
    QCCRSASmallCryptor *        op;
    
    // encrypt with the private key
    
    plaintextData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"plaintext-32" withExtension:@"dat"]];
    assert(plaintextData != nil);
    
    op = [[QCCRSASmallCryptor alloc] initToEncryptSmallInputData:plaintextData key:self.privateKey];
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, NSOSStatusErrorDomain);
    XCTAssertTrue(op.error.code != 0); // We don't check the specific error here because different OS releases given you different values.
    XCTAssertNil(op.smallOutputData);

    // decrypt with the public key
    
    cyphertextData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"cyphertext-rsa-pkcs1-32" withExtension:@"dat"]];
    assert(cyphertextData != nil);
    
    op = [[QCCRSASmallCryptor alloc] initToDecryptSmallInputData:cyphertextData key:self.publicKey];
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, NSOSStatusErrorDomain);
    XCTAssertTrue(op.error.code != 0); // We don't check the specific error here because different OS releases given you different values.
    XCTAssertNil(op.smallOutputData);
}

- (void)testRSACryptorErrorTooBig {
    if ( ! self.hasUnifiedCrypto ) { return; }
    NSData *                    plaintextData;
    QCCRSASmallCryptor *        op;

    // PKCS#1
    
    plaintextData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"plaintext-332" withExtension:@"dat"]];
    assert(plaintextData != nil);
    
    op = [[QCCRSASmallCryptor alloc] initToEncryptSmallInputData:plaintextData key:self.publicKey];
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, NSOSStatusErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) errSecParam);
    XCTAssertNil(op.smallOutputData);
    
    plaintextData = [plaintextData subdataWithRange:NSMakeRange(0, 256)];

    op = [[QCCRSASmallCryptor alloc] initToEncryptSmallInputData:plaintextData key:self.publicKey];
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, NSOSStatusErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) errSecParam);
    XCTAssertNil(op.smallOutputData);

    plaintextData = [plaintextData subdataWithRange:NSMakeRange(0, 246)];

    op = [[QCCRSASmallCryptor alloc] initToEncryptSmallInputData:plaintextData key:self.publicKey];
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, NSOSStatusErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) errSecParam);
    XCTAssertNil(op.smallOutputData);

    plaintextData = [plaintextData subdataWithRange:NSMakeRange(0, 245)];

    op = [[QCCRSASmallCryptor alloc] initToEncryptSmallInputData:plaintextData key:self.publicKey];
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);

    // OAEP
    
    plaintextData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"plaintext-332" withExtension:@"dat"]];
    assert(plaintextData != nil);
    
    op = [[QCCRSASmallCryptor alloc] initToEncryptSmallInputData:plaintextData key:self.publicKey];
    op.padding = QCCRSASmallCryptorPaddingOAEP;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, NSOSStatusErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) errSecParam);
    XCTAssertNil(op.smallOutputData);
    
    plaintextData = [plaintextData subdataWithRange:NSMakeRange(0, 256)];

    op = [[QCCRSASmallCryptor alloc] initToEncryptSmallInputData:plaintextData key:self.publicKey];
    op.padding = QCCRSASmallCryptorPaddingOAEP;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, NSOSStatusErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) errSecParam);
    XCTAssertNil(op.smallOutputData);

    plaintextData = [plaintextData subdataWithRange:NSMakeRange(0, 215)];

    op = [[QCCRSASmallCryptor alloc] initToEncryptSmallInputData:plaintextData key:self.publicKey];
    op.padding = QCCRSASmallCryptorPaddingOAEP;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, NSOSStatusErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) errSecParam);
    XCTAssertNil(op.smallOutputData);

    plaintextData = [plaintextData subdataWithRange:NSMakeRange(0, 214)];

    op = [[QCCRSASmallCryptor alloc] initToEncryptSmallInputData:plaintextData key:self.publicKey];
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNil(op.error);
}

- (void)testRSACryptorErrorWrongLength {
    if ( ! self.hasUnifiedCrypto ) { return; }
    NSData *                    cyphertextData;
    QCCRSASmallCryptor *        op;

    // PKCS#1

    cyphertextData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"cyphertext-rsa-pkcs1-32" withExtension:@"dat"]];
    assert(cyphertextData != nil);
    
    cyphertextData = [cyphertextData subdataWithRange:NSMakeRange(0, 255)];
    
    op = [[QCCRSASmallCryptor alloc] initToDecryptSmallInputData:cyphertextData key:self.privateKey];
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, NSOSStatusErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) errSecParam);
    XCTAssertNil(op.smallOutputData);

    // OAEP
    
    cyphertextData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"cyphertext-rsa-oaep-32" withExtension:@"dat"]];
    assert(cyphertextData != nil);
    
    cyphertextData = [cyphertextData subdataWithRange:NSMakeRange(0, 255)];
    
    op = [[QCCRSASmallCryptor alloc] initToDecryptSmallInputData:cyphertextData key:self.privateKey];
    op.padding = QCCRSASmallCryptorPaddingOAEP;
    [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
    XCTAssertNotNil(op.error);
    XCTAssertEqualObjects(op.error.domain, NSOSStatusErrorDomain);
    XCTAssertEqual(op.error.code, (NSInteger) errSecParam);
    XCTAssertNil(op.smallOutputData);
}

- (void)testRSAThrows {
    if ( ! self.hasUnifiedCrypto ) { return; }
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wnonnull"

    XCTAssertThrows((void) [[QCCRSASHAVerify alloc] initWithAlgorithm:QCCRSASHASignatureAlgorithmSHA1 inputData:nil publicKey:self.publicKey signatureData:[NSData data]]);
    XCTAssertThrows((void) [[QCCRSASHAVerify alloc] initWithAlgorithm:QCCRSASHASignatureAlgorithmSHA1 inputData:[NSData data] publicKey:NULL signatureData:[NSData data]]);
    XCTAssertThrows((void) [[QCCRSASHAVerify alloc] initWithAlgorithm:QCCRSASHASignatureAlgorithmSHA1 inputData:[NSData data] publicKey:self.publicKey signatureData:nil]);

    XCTAssertThrows((void) [[QCCRSASHASign alloc] initWithAlgorithm:QCCRSASHASignatureAlgorithmSHA1 inputData:nil privateKey:self.privateKey]);
    XCTAssertThrows((void) [[QCCRSASHASign alloc] initWithAlgorithm:QCCRSASHASignatureAlgorithmSHA1 inputData:[NSData data] privateKey:NULL]);

    XCTAssertThrows((void) [[QCCRSASmallCryptor alloc] initToDecryptSmallInputData:nil key:self.publicKey]);
    XCTAssertThrows((void) [[QCCRSASmallCryptor alloc] initToDecryptSmallInputData:[NSData data] key:NULL]);
    XCTAssertThrows((void) [[QCCRSASmallCryptor alloc] initToEncryptSmallInputData:nil key:self.privateKey]);
    XCTAssertThrows((void) [[QCCRSASmallCryptor alloc] initToEncryptSmallInputData:[NSData data] key:NULL]);

    #pragma clang diagnostic pop
}

@end
