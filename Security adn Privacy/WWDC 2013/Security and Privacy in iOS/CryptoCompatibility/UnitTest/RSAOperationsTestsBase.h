/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Base class for our RSA operation tests.
 */

@import XCTest;

NS_ASSUME_NONNULL_BEGIN

@interface RSAOperationsTestsBase : XCTestCase

@property (nonatomic, strong, readonly, nullable) SecKeyRef     publicKey __attribute__ (( NSObject ));
@property (nonatomic, strong, readonly, nullable) SecKeyRef     privateKey __attribute__ (( NSObject ));
@property (nonatomic, assign, readonly)           BOOL          hasUnifiedCrypto;

@end

NS_ASSUME_NONNULL_END
