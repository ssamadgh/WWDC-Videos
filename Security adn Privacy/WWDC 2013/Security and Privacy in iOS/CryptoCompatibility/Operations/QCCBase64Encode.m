/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Implements Base64 encoding.
 */

#import "QCCBase64Encode.h"

NS_ASSUME_NONNULL_BEGIN

@interface QCCBase64Encode ()

// read/write versions of public properties

@property (atomic, copy,   readwrite, nullable) NSString *      outputString;

@end

NS_ASSUME_NONNULL_END

@implementation QCCBase64Encode

- (instancetype)init {
    abort();
}

- (instancetype)initWithInputData:(NSData *)inputData {
    NSParameterAssert(inputData != nil);
    self = [super init];
    if (self != nil) {
        self->_inputData = [inputData copy];
    }
    return self;
}

- (void)main {
    NSDataBase64EncodingOptions options;
    NSString * output;
    
    options = NSDataBase64EncodingEndLineWithLineFeed;
    if (self.addLineBreaks) {
        options |= NSDataBase64Encoding64CharacterLineLength; 
    }
    output = [self.inputData base64EncodedStringWithOptions:options];
    
    // Our old code use to always add a trailing LF unless the input was empty, 
    // and our unit test relies on that, so we replicate it here.  
    
    if ( (output.length > 0) && ! [output hasSuffix:@"\n"] ) {
        output = [output stringByAppendingString:@"\n"];
    }
    self.outputString = output;
}

@end
