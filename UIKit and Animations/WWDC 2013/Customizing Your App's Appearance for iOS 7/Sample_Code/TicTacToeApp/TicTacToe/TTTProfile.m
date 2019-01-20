/*
     File: TTTProfile.m
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

#import "TTTProfile.h"

NSString * const TTTProfileIconDidChangeNotification = @"TTTProfileIconDidChangeNotification";

@implementation TTTProfile

- (id)init
{
    self = [super init];
    if (self) {
        _games = [[NSArray alloc] init];
        [self startNewGame];
    }
    return self;
}

static NSString * const TTTProfileEncodingKeyIcon = @"icon";
static NSString * const TTTProfileEncodingKeyCurrentGame = @"currentGame";
static NSString * const TTTProfileEncodingKeyGames = @"games";

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _icon = [coder decodeIntegerForKey:TTTProfileEncodingKeyIcon];
        _currentGame = [coder decodeObjectForKey:TTTProfileEncodingKeyCurrentGame];
        _games = [coder decodeObjectForKey:TTTProfileEncodingKeyGames];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInteger:self.icon forKey:TTTProfileEncodingKeyIcon];
    [coder encodeObject:self.currentGame forKey:TTTProfileEncodingKeyCurrentGame];
    [coder encodeObject:self.games forKey:TTTProfileEncodingKeyGames];
}

+ (TTTProfile *)profileWithContentsOfURL:(NSURL *)url
{
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (data) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

- (BOOL)writeToURL:(NSURL *)url
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    return [data writeToURL:url atomically:YES];
}

- (TTTGame *)startNewGame
{
    if (self.currentGame && (self.currentGame.moves.count == 0)) {
        return self.currentGame;
    }
    
    TTTGame *game = [[TTTGame alloc] init];
    
    NSMutableArray *games = [self.games mutableCopy];
    [games insertObject:game atIndex:0];
    self.games = games;
    
    self.currentGame = game;
    return game;
}

- (void)setIcon:(TTTProfileIcon)value
{
    if (_icon != value) {
        _icon = value;
        [[NSNotificationCenter defaultCenter] postNotificationName:TTTProfileIconDidChangeNotification object:self];
    }
}

- (NSInteger)numberOfGamesWithResult:(TTTGameResult)result
{
    NSInteger count = 0;
    for (TTTGame *game in self.games) {
        if (game.result == result) {
            count++;
        }
    }
    return count;
}

#pragma mark - Images

- (TTTProfileIcon)iconForPlayer:(TTTMovePlayer)player
{
    TTTProfileIcon myIcon = self.icon;
    return ((player == TTTMovePlayerMe) ? myIcon : 1 - myIcon);
}

- (UIImage *)imageForPlayer:(TTTMovePlayer)player
{
    TTTProfileIcon icon = [self iconForPlayer:player];
    return [[self class] imageForIcon:icon];
}

- (UIColor *)colorForPlayer:(TTTMovePlayer)player
{
    TTTProfileIcon icon = [self iconForPlayer:player];
    return [[self class] colorForIcon:icon];
}

+ (UIImage *)imageForIcon:(TTTProfileIcon)icon
{
    NSString *imageName = ((icon == TTTProfileIconX) ? @"x" : @"o");
    return [UIImage imageNamed:imageName];
}

+ (UIImage *)smallImageForIcon:(TTTProfileIcon)icon
{
    NSString *imageName = ((icon == TTTProfileIconX) ? @"smallX" : @"smallO");
    return [UIImage imageNamed:imageName];
}

+ (UIColor *)colorForIcon:(TTTProfileIcon)icon
{
    return ((icon == TTTProfileIconX) ? [UIColor redColor] : [UIColor greenColor]);
}

@end
