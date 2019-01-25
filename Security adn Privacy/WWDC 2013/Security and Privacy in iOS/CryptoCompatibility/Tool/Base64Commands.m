/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Commands for Base64 encode and decode.
 */

#import "Base64Commands.h"

#import "QCCBase64Encode.h"
#import "QCCBase64Decode.h"

#import "ToolCommon.h"

NS_ASSUME_NONNULL_BEGIN

@interface Base64EncodeCommand ()

@property (nonatomic, assign, readwrite) BOOL   addLineBreaks;

@end

NS_ASSUME_NONNULL_END

@implementation Base64EncodeCommand

+ (NSString *)commandName {
    return @"base64-encode";
}

+ (NSString *)commandUsage {
    return [NSString stringWithFormat:@"%@ [-l] file", [self commandName]];
}

- (NSString *)commandOptions {
    return @"l";
}

- (void)setOption_l {
    self.addLineBreaks = YES;
}

- (BOOL)validateOptionsAndArguments:(NSArray *)optionsAndArguments {
    BOOL    success;
    
    success = [super validateOptionsAndArguments:optionsAndArguments];
    if (success && (self.arguments.count != 1)) {
        success = NO;
    }
    return success;
}

- (BOOL)runError:(NSError **)errorPtr {
    BOOL        success;
    NSData *    fileData;
    
    fileData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.arguments[0]] options:(NSDataReadingOptions) 0 error:errorPtr];
    success = (fileData != nil);
    
    if (success) {
        QCCBase64Encode *   op;
        
        op = [[QCCBase64Encode alloc] initWithInputData:fileData];
        op.addLineBreaks = self.addLineBreaks;
        [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
        fprintf(stdout, "%s", op.outputString.UTF8String);
    }
    
    return success;
}

@end

@implementation Base64DecodeCommand

+ (NSString *)commandName {
    return @"base64-decode";
}

+ (NSString *)commandUsage {
    return [NSString stringWithFormat:@"%@ file", [self commandName]];
}

- (BOOL)validateOptionsAndArguments:(NSArray *)optionsAndArguments {
    BOOL    success;
    
    success = [super validateOptionsAndArguments:optionsAndArguments];
    if (success && (self.arguments.count != 1)) {
        success = NO;
    }
    return success;
}

- (BOOL)runError:(NSError **)errorPtr {
    BOOL        success;
    NSString *  fileString;
    
    fileString = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:self.arguments[0]] encoding:NSUTF8StringEncoding error:errorPtr];
    success = (fileString != nil);
    
    if (success) {
        QCCBase64Decode *   op;
        
        op = [[QCCBase64Decode alloc] initWithInputString:fileString];
        [[ToolCommon sharedInstance] synchronouslyRunOperation:op];
        if (op.outputData == nil) {
            success = NO;
            if (errorPtr != NULL) {
                *errorPtr = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadCorruptFileError userInfo:nil];
            }
        } else {
            (void) fwrite(op.outputData.bytes, op.outputData.length, 1, stdout);
        }
    }
    
    return success;
}

@end

