/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Base class for our RSA operation tests.
 */

#import "RSAOperationsTestsBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSAOperationsTestsBase ()

@property (nonatomic, strong, readwrite, nullable) SecKeyRef    publicKey __attribute__ (( NSObject ));
@property (nonatomic, strong, readwrite, nullable) SecKeyRef    privateKey __attribute__ (( NSObject ));

@end

NS_ASSUME_NONNULL_END

@implementation RSAOperationsTestsBase

#if TARGET_OS_OSX

- (void)setUpMac {
    OSStatus        err;
    NSData *        pemData;
    CFArrayRef      importedItems;
    NSArray *       importedKeys;
    
    // public key

    pemData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"public" withExtension:@"pem"]];
    err = SecItemImport(
        (__bridge CFDataRef) pemData, 
        CFSTR("pem"), 
        NULL, 
        NULL, 
        (SecItemImportExportFlags) 0, 
        NULL, 
        NULL, 
        &importedItems
    );
    assert(err == errSecSuccess);
        
    importedKeys = CFBridgingRelease(importedItems);
    assert(importedKeys.count == 1);
    self.publicKey = (__bridge SecKeyRef) importedKeys[0];
    importedKeys = nil;
    
    // private key
    
    pemData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"private" withExtension:@"pem"]];
    err = SecItemImport(
        (__bridge CFDataRef) pemData, 
        CFSTR("pem"), 
        NULL, 
        NULL, 
        (SecItemImportExportFlags) 0, 
        NULL, 
        NULL, 
        &importedItems
    );
    assert(err == errSecSuccess);
        
    importedKeys = CFBridgingRelease(importedItems);
    assert(importedKeys.count == 1);
    self.privateKey = (__bridge SecKeyRef) importedKeys[0];
}

#endif

#if TARGET_OS_IPHONE

// On the phone, we import the .p12.

- (void)setUpPhone {
    OSStatus            err;
    NSData *            certData;
    SecCertificateRef   cert;
    SecPolicyRef        policy;
    SecTrustRef         trust;
    SecTrustResultType  trustResult;

    // public key
    
    certData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"test" withExtension:@"cer"]];
    assert(certData != nil);

    cert = SecCertificateCreateWithData(NULL, (__bridge CFDataRef) certData);
    assert(cert != NULL);
    
    policy = SecPolicyCreateBasicX509();
    
    err = SecTrustCreateWithCertificates(cert, policy, &trust);
    assert(err == errSecSuccess);
    
    err = SecTrustEvaluate(trust, &trustResult);
    assert(err == errSecSuccess);
    
    self->_publicKey = SecTrustCopyPublicKey(trust);
    assert(self->_publicKey != NULL);
    
    CFRelease(policy);
    CFRelease(cert);
    
    // private key
    
    NSData *            pkcs12Data;
    CFArrayRef          imported;
    NSDictionary *      importedItem;
    SecIdentityRef      identity;
    
    pkcs12Data = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"private" withExtension:@"p12"]];
    assert(pkcs12Data != nil);
    
    err = SecPKCS12Import((__bridge CFDataRef) pkcs12Data, (__bridge CFDictionaryRef) @{
        (__bridge NSString *) kSecImportExportPassphrase: @"test"
    }, &imported);
    assert(err == errSecSuccess);
    assert(CFArrayGetCount(imported) == 1);
    importedItem = (__bridge NSDictionary *) CFArrayGetValueAtIndex(imported, 0);
    assert([importedItem isKindOfClass:[NSDictionary class]]);
    identity = (__bridge SecIdentityRef) importedItem[(__bridge NSString *) kSecImportItemIdentity];
    assert(identity != NULL);
    
    err = SecIdentityCopyPrivateKey(identity, &self->_privateKey);
    assert(err == errSecSuccess);
    assert(self->_privateKey != NULL);
    
    CFRelease(imported);
}

#endif
 
- (void)setUp; {
    [super setUp];
    
    #if TARGET_OS_OSX
        [self setUpMac];
    #elif TARGET_OS_IPHONE
        [self setUpPhone];
    #else
        #error What platform?
    #endif
}

- (BOOL)hasUnifiedCrypto {
    return (SecKeyCreateEncryptedData != NULL);
}

@end
