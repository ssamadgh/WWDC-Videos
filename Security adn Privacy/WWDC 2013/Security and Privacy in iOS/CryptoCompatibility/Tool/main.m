/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Command line tool main.
 */

@import Foundation;

#import "Base64Commands.h"
#import "DigestCommands.h"
#import "KeyDerivationCommands.h"
#import "CryptorCommands.h"
#import "RSACommands.h"

#import "ToolCommon.h"

#import "QToolCommand.h"

NS_ASSUME_NONNULL_BEGIN

/*! A tool command subclass that implements the main command.
 */

@interface MainCommand : QComplexToolCommand

@property (nonatomic, assign, readwrite) NSUInteger verbose;
@property (nonatomic, assign, readwrite) BOOL       debug;

@end

NS_ASSUME_NONNULL_END

@implementation MainCommand

+ (NSArray *)subcommandClasses {
    return @[
        [Base64EncodeCommand class], 
        [Base64DecodeCommand class],
        [DigestCommand class],
        [HMACCommand class], 
        [PBKDF2KeyDerivationCommand class], 
        [AESEncryptCommand class], 
        [AESDecryptCommand class], 
        [AESPadEncryptCommand class], 
        [AESPadDecryptCommand class], 
        [AESPadBigEncryptCommand class], 
        [AESPadBigDecryptCommand class], 
        [RSASHAVerifyCommand class], 
        [RSASHASignCommand class], 
        [RSASmallEncryptCommand class], 
        [RSASmallDecryptCommand class]
    ];
}

+ (NSString *)commandName {
    return @(getprogname());
}

+ (NSString *)commandUsage {
    return [[NSString alloc] initWithFormat:@"%@ [-v] subcommand\n"
        "\n"
        "Subcommands:\n"
        "\n"
        "%@", 
        [self commandName], 
        [super commandUsage]
    ];
}

- (NSString *)commandOptions {
    return @"vd";
}

- (void)setOption_v {
    self.verbose += 1;
}

- (void)setOption_d {
    self.debug = YES;
}

@end

int main(int argc, char **argv) {
    #pragma unused(argc)
    #pragma unused(argv)
    BOOL        success;

    @autoreleasepool {
        MainCommand *   mainCommand;
        NSArray *       optionsAndArguments;
        
        mainCommand = [[MainCommand alloc] init];

        optionsAndArguments = [QToolCommand optionsAndArgumentsFromArgC:argc argV:argv];
        success = (optionsAndArguments != nil);
        if (success) {
            success = [mainCommand validateOptionsAndArguments:optionsAndArguments];
        }
        
        if ( ! success ) {
            fprintf(stderr, "usage: %s\n\n", [[mainCommand class] commandUsage].UTF8String);
        } else {
            NSError *       error;
            
            if (mainCommand.debug) {
                [ToolCommon sharedInstance].debugRunOpOnMainThread = YES;
            }
            success = [mainCommand runError:&error];
            if (success) {
                if (mainCommand.verbose != 0) {
                    fprintf(stderr, "Success!\n");
                }
            } else {
                fprintf(stderr, "%s: error: %s / %d\n", [[mainCommand class] commandName].UTF8String, error.domain.UTF8String, (int) error.code);
            }
        }
    }

    return success ? EXIT_SUCCESS : EXIT_FAILURE;
}
