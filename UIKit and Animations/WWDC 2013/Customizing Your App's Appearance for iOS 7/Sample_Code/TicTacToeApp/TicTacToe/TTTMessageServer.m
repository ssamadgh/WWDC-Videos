/*
     File: TTTMessageServer.m
 Abstract: 
 
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 
 Copyright © 2013 Apple Inc. All rights reserved.
 WWDC 2013 License
 
 NOTE: This Apple Software was supplied by Apple as part of a WWDC 2013
 Session. Please refer to the applicable WWDC 2013 Session for further
 information.
 
 IMPORTANT: This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and
 your use, installation, modification or redistribution of this Apple
 software constitutes acceptance of these terms. If you do not agree with
 these terms, please do not use, install, modify or redistribute this
 Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple
 Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple. Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis. APPLE MAKES
 NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE
 IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 EA1002
 5/3/2013
 */

#import "TTTMessageServer.h"

#import "TTTMessage.h"

NSString * const TTTMessageServerDidAddMessagesNotification = @"TTTMessageServerDidAddMessagesNotification";
NSString * const TTTMessageServerAddedMessageIndexesUserInfoKey = @"TTTMessageServerAddedMessageIndexesUserInfoKey";

@implementation TTTMessageServer {
    NSMutableArray *_messages;
    NSMutableArray *_favoriteMessages;
}

+ (TTTMessageServer *)sharedMessageServer
{
    static TTTMessageServer *sharedMessageServer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMessageServer = [[TTTMessageServer alloc] init];
        [sharedMessageServer readMessages];
    });
    return sharedMessageServer;
}

- (NSURL *)messagesURL
{
    NSURL *url = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    url = [url URLByAppendingPathComponent:@"Messages.ttt"];
    return url;
}

- (void)readMessages
{
    NSData *data = [NSData dataWithContentsOfURL:[self messagesURL]];
    if (data) {
        _messages = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
}

- (void)writeMessages
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_messages];
    [data writeToURL:[self messagesURL] atomically:YES];
}

- (NSInteger)numberOfMessages
{
    return _messages.count;
}

- (TTTMessage *)messageAtIndex:(NSUInteger)messageIndex
{
    return _messages[messageIndex];
}

- (void)addMessage:(TTTMessage *)message
{
    if (!_messages) {
        _messages = [NSMutableArray array];
    }
    NSUInteger messageIndex = 0;
    [_messages insertObject:message atIndex:messageIndex];
    NSDictionary *userInfo = @{TTTMessageServerAddedMessageIndexesUserInfoKey : @[@(messageIndex)]};
    [[NSNotificationCenter defaultCenter] postNotificationName:TTTMessageServerDidAddMessagesNotification object:self userInfo:userInfo];
    [self writeMessages];
}

- (BOOL)isFavoriteMessage:(TTTMessage *)message
{
    return [_favoriteMessages containsObject:message];
}

- (void)setFavorite:(BOOL)favorite forMessage:(TTTMessage *)message
{
    if (favorite) {
        if (!_favoriteMessages) {
            _favoriteMessages = [NSMutableArray array];
        }
        [_favoriteMessages addObject:message];
    } else {
        [_favoriteMessages removeObject:message];
    }
}

@end
