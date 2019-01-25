/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Implements Base64 decoding.
 */

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

// Decodes a Base64 string to data.  This does not do anything particularly clever 
// (it does skip whitespace but, for example, it won't skip a PEM header or PEM footer). 

/*! Decodes a Base64 string to data.
 *  \details This only handles plain Base64 data.  Specifically, it has not skip whitespace, 
 *      nor will it deal with PEM headers and footers.
 */

@interface QCCBase64Decode : NSOperation

/*! Initialise the object to decide the supplied string.
 *  \param inputString The data to encode; this may be empty.
 *  \returns The initialised object.
 */

- (instancetype)initWithInputString:(NSString *)inputString NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/*! The data to decode.
 *  \details This is set by the init method.
 */

@property (atomic, copy,   readonly ) NSString *            inputString;

/*! The decode data. 
 *  \details This is set when the operation is finished.  This will be nil if there was 
 *      an error decoding the Base64 string.
 */

@property (atomic, copy,   readonly, nullable) NSData *     outputData;

@end

NS_ASSUME_NONNULL_END
