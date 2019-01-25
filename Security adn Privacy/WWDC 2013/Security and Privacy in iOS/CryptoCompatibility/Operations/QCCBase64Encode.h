/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Implements Base64 encoding.
 */

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/*! Encodes data as a Base64 string.
 *  \details This is a vanilla encoding; it does not do anything especially clever, like 
 *      deal PEM headers and footers.
 */

@interface QCCBase64Encode : NSOperation

/*! Initialise the object to encode the supplied data.
 *  \param inputData The data to encode; this may be empty.
 *  \returns The initialised object.
 */

- (instancetype)initWithInputData:(NSData *)inputData NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/*! The data to encode.
 *  \details This is set by the init method.
 */

@property (atomic, copy,   readonly ) NSData *              inputData;

/*! Determines whether line breaks are added.
 *  \details If true, UNIX style line breaks (LF) are added at column 64 as is traditional 
 *      for PEM.
 */

@property (atomic, assign, readwrite) BOOL                  addLineBreaks;

/*! The output Base64 string. 
 *  \details This is set when the operation is finished.
 */

@property (atomic, copy,   readonly, nullable) NSString *   outputString;

@end

NS_ASSUME_NONNULL_END
