/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  The top level model object.
  
 */

#import "AAPLUser.h"
#import "AAPLConversation.h"
#import "AAPLPhoto.h"

@implementation AAPLUser

+ (instancetype)userWithDictionary:(NSDictionary *)dictionary
{
    AAPLUser *user = [[self alloc] init];
    user.name = [dictionary objectForKey:@"name"];
    
    NSArray *conversationDictionaries = [dictionary objectForKey:@"conversations"];
    NSMutableArray *conversations = [NSMutableArray array];
    
    for (NSDictionary *conversationDictionary in conversationDictionaries) {
        AAPLConversation *conversation = [AAPLConversation conversationWithDictionary:conversationDictionary];
        [conversations addObject:conversation];
    }
    
    user.conversations = conversations;
    
    NSDictionary *lastPhotoDictionary = [dictionary objectForKey:@"lastPhoto"];
    user.lastPhoto = [AAPLPhoto photoWithDictionary:lastPhotoDictionary];
    return user;
}

@end
