/*
     File: TTTGame.m
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

#import "TTTGame.h"

@interface TTTGame ()
@property (copy, nonatomic) NSArray *moves;
@end

@implementation TTTGame

- (id)init
{
    self = [super init];
    if (self) {
        _date = [NSDate date];
        _moves = [[NSArray alloc] init];
    }
    return self;
}

static NSString * const TTTGameEncodingKeyResult = @"result";
static NSString * const TTTGameEncodingKeyRating = @"rating";
static NSString * const TTTGameEncodingKeyDate = @"date";
static NSString * const TTTGameEncodingKeyMoves = @"moves";
static NSString * const TTTGameEncodingKeyCurrentPlayer = @"currentPlayer";

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _result = [coder decodeIntegerForKey:TTTGameEncodingKeyResult];
        _rating = [coder decodeIntegerForKey:TTTGameEncodingKeyRating];
        _date = [coder decodeObjectForKey:TTTGameEncodingKeyDate];
        _moves = [coder decodeObjectForKey:TTTGameEncodingKeyMoves];
        _currentPlayer = [coder decodeIntegerForKey:TTTGameEncodingKeyCurrentPlayer];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInteger:self.result forKey:TTTGameEncodingKeyResult];
    [coder encodeInteger:self.rating forKey:TTTGameEncodingKeyRating];
    [coder encodeObject:self.date forKey:TTTGameEncodingKeyDate];
    [coder encodeObject:self.moves forKey:TTTGameEncodingKeyMoves];
    [coder encodeInteger:self.currentPlayer forKey:TTTGameEncodingKeyCurrentPlayer];
}

- (BOOL)canAddMoveWithXPosition:(TTTMoveXPosition)xPosition yPosition:(TTTMoveYPosition)yPosition
{
    if (self.result != TTTGameResultInProgess) {
        return NO;
    }
    return ![self hasMoveForXPosition:xPosition yPosition:yPosition player:NULL];
}

- (void)addMoveWithXPosition:(TTTMoveXPosition)xPosition yPosition:(TTTMoveYPosition)yPosition
{
    if (![self canAddMoveWithXPosition:xPosition yPosition:yPosition]) {
        return;
    }
    
    TTTMove *move = [[TTTMove alloc] initWithPlayer:self.currentPlayer xPosition:xPosition yPosition:yPosition];
    NSMutableArray *moves = [self.moves mutableCopy];
    [moves addObject:move];
    self.moves = moves;
    
    self.currentPlayer = ((self.currentPlayer == TTTMovePlayerMe) ? TTTMovePlayerEnemy : TTTMovePlayerMe);
    
    [self updateGameResult];
}

- (BOOL)hasMoveForXPosition:(TTTMoveXPosition)xPosition yPosition:(TTTMoveYPosition)yPosition player:(TTTMovePlayer *)player
{
    for (TTTMove *move in self.moves) {
        if ((move.xPosition == xPosition) && (move.yPosition == yPosition)) {
            if (player) {
                *player = move.player;
            }
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)getWinningPlayer:(TTTMovePlayer *)playerOut startXPosition:(TTTMoveXPosition *)startXPosition startYPosition:(TTTMoveYPosition *)startYPosition endXPosition:(TTTMoveXPosition *)endXPosition endYPosition:(TTTMoveYPosition *)endYPosition xPositions:(TTTMoveXPosition[TTTMoveSidePositionsCount])xPositions yPositions:(TTTMoveYPosition[TTTMoveSidePositionsCount])yPositions
{
    BOOL hasMove = NO;
    TTTMovePlayer player;
    
    for (NSInteger n = 0; n < TTTMoveSidePositionsCount; n++) {
        TTTMovePlayer newPlayer;
        BOOL newHasMove = [self hasMoveForXPosition:xPositions[n] yPosition:yPositions[n] player:&newPlayer];
        if (newHasMove) {
            if (hasMove) {
                if (player != newPlayer) {
                    hasMove = NO;
                    break;
                }
            } else {
                hasMove = YES;
                player = newPlayer;
            }
        } else {
            hasMove = NO;
            break;
        }
    }
    
    if (hasMove) {
        if (playerOut) {
            *playerOut = player;
        }
        if (startXPosition) {
            *startXPosition = xPositions[0];
        }
        if (startYPosition) {
            *startYPosition = yPositions[0];
        }
        if (endXPosition) {
            *endXPosition = xPositions[TTTMoveSidePositionsCount - 1];
        }
        if (endYPosition) {
            *endYPosition = yPositions[TTTMoveSidePositionsCount - 1];
        }
    }
    return hasMove;
}

- (BOOL)getWinningPlayer:(TTTMovePlayer *)player startXPosition:(TTTMoveXPosition *)startXPosition startYPosition:(TTTMoveYPosition *)startYPosition endXPosition:(TTTMoveXPosition *)endXPosition endYPosition:(TTTMoveYPosition *)endYPosition xPosition:(TTTMoveXPosition)xPosition
{
    TTTMoveXPosition xPositions[TTTMoveSidePositionsCount];
    for (NSInteger n = 0; n < TTTMoveSidePositionsCount; n++) {
        xPositions[n] = xPosition;
    }
    
    TTTMoveYPosition yPositions[TTTMoveSidePositionsCount];
    yPositions[0] = TTTMoveYPositionTop;
    yPositions[1] = TTTMoveYPositionCenter;
    yPositions[2] = TTTMoveYPositionBottom;
    
    return [self getWinningPlayer:player startXPosition:startXPosition startYPosition:startYPosition endXPosition:endXPosition endYPosition:endYPosition xPositions:xPositions yPositions:yPositions];
}

- (BOOL)getWinningPlayer:(TTTMovePlayer *)player startXPosition:(TTTMoveXPosition *)startXPosition startYPosition:(TTTMoveYPosition *)startYPosition endXPosition:(TTTMoveXPosition *)endXPosition endYPosition:(TTTMoveYPosition *)endYPosition yPosition:(TTTMoveYPosition)yPosition
{
    TTTMoveYPosition yPositions[TTTMoveSidePositionsCount];
    for (NSInteger n = 0; n < TTTMoveSidePositionsCount; n++) {
        yPositions[n] = yPosition;
    }
    
    TTTMoveXPosition xPositions[TTTMoveSidePositionsCount];
    xPositions[0] = TTTMoveXPositionLeft;
    xPositions[1] = TTTMoveXPositionCenter;
    xPositions[2] = TTTMoveXPositionRight;
    
    return [self getWinningPlayer:player startXPosition:startXPosition startYPosition:startYPosition endXPosition:endXPosition endYPosition:endYPosition xPositions:xPositions yPositions:yPositions];
}

- (BOOL)getWinningPlayer:(TTTMovePlayer *)player startXPosition:(TTTMoveXPosition *)startXPosition startYPosition:(TTTMoveYPosition *)startYPosition endXPosition:(TTTMoveXPosition *)endXPosition endYPosition:(TTTMoveYPosition *)endYPosition direction:(NSInteger)direction
{
    TTTMoveXPosition xPositions[TTTMoveSidePositionsCount];
    TTTMoveYPosition yPositions[TTTMoveSidePositionsCount];
    NSInteger n = 0;
    for (TTTMoveXPosition xPosition = TTTMoveXPositionLeft; xPosition <= TTTMoveXPositionRight; xPosition++) {
        xPositions[n] = xPosition;
        yPositions[n] = xPosition * direction;
        n++;
    }
    
    return [self getWinningPlayer:player startXPosition:startXPosition startYPosition:startYPosition endXPosition:endXPosition endYPosition:endYPosition xPositions:xPositions yPositions:yPositions];
}

- (BOOL)getWinningPlayer:(TTTMovePlayer *)player startXPosition:(TTTMoveXPosition *)startXPosition startYPosition:(TTTMoveYPosition *)startYPosition endXPosition:(TTTMoveXPosition *)endXPosition endYPosition:(TTTMoveYPosition *)endYPosition
{
    // Check for columns
    for (TTTMoveXPosition xPosition = TTTMoveXPositionLeft; xPosition <= TTTMoveXPositionRight; xPosition++) {
        BOOL hasWinner = [self getWinningPlayer:player startXPosition:startXPosition startYPosition:startYPosition endXPosition:endXPosition endYPosition:endYPosition xPosition:xPosition];
        if (hasWinner) return hasWinner;
    };
    // Check for rows
    for (TTTMoveYPosition yPosition = TTTMoveYPositionTop; yPosition <= TTTMoveYPositionBottom; yPosition++) {
        BOOL hasWinner = [self getWinningPlayer:player startXPosition:startXPosition startYPosition:startYPosition endXPosition:endXPosition endYPosition:endYPosition yPosition:yPosition];
        if (hasWinner) return hasWinner;
    };
    // Check for diagonals
    BOOL hasWinner = [self getWinningPlayer:player startXPosition:startXPosition startYPosition:startYPosition endXPosition:endXPosition endYPosition:endYPosition direction:1];
    if (hasWinner) return hasWinner;
    
    hasWinner = [self getWinningPlayer:player startXPosition:startXPosition startYPosition:startYPosition endXPosition:endXPosition endYPosition:endYPosition direction:-1];
    if (hasWinner) return hasWinner;
    
    return NO;
}

- (TTTGameResult)calculateGameResult
{
    TTTMovePlayer player;
    BOOL hasWinner = [self getWinningPlayer:&player startXPosition:NULL startYPosition:NULL endXPosition:NULL endYPosition:NULL];
    if (hasWinner) {
        return ((player == TTTMovePlayerMe) ? TTTGameResultVictory : TTTGameResultDefeat);
    }
    
    // Check for draw
    if (self.moves.count == TTTMoveSidePositionsCount * TTTMoveSidePositionsCount) {
        return TTTGameResultDraw;
    }
    
    return TTTGameResultInProgess;
}

- (void)updateGameResult
{
    if (self.result == TTTGameResultInProgess) {
        _result = [self calculateGameResult];
    }
}

@end
