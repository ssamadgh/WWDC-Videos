/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Utilities used by various tool commands.
 */

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/*! description
 *  \details Utilities used by various tool commands and tests.
 */

@interface ToolCommon : NSObject

/*! Instance shared between all the tool commands and tests.
 */

+ (ToolCommon *)sharedInstance;

/*! Runs the supplied operation synchronously.
 *  \details This has two modes.  If `debugRunOpOnMainThread` is NO, it runs 
 *      the operation on a default operation queue and then waits for it to 
 *      complete.  OTOH, if it's YES, it actually calls the `-main` method of the 
 *      operation directly.  The later is used by the tool (when in debug mode) and 
 *      the unit tests to ensure that everything runs on the main thread.
 */

- (void)synchronouslyRunOperation:(NSOperation *)op;

/*! Controls the behaviour of `-synchronouslyRunOperation:`.
 */

@property (atomic, assign, readwrite) BOOL   debugRunOpOnMainThread;

@end

NS_ASSUME_NONNULL_END
