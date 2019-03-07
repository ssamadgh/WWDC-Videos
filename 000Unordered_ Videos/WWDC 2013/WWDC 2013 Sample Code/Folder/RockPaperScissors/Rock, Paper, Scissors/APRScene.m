/*
     File: APRScene.m
 Abstract: The Rock, Paper, Scissors scene.
  Version: 1.1
 
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
 
 */


#import "APRScene.h"
#import "APRAppDelegate.h"

@interface APRScene ()
@property (nonatomic) APRSquare *highlightedSquare;       // As we move a piece around, we highlight it.
@property (nonatomic) APRSquare  *originalSquare;         // If we have a piece picked up, this is its original home.
@property (nonatomic) CGPoint pickedUpPieceOrigin;        // If we have a piece picked up, this holds its original position.
@property (nonatomic) APRPiece *pickedUpPiece;

@property (nonatomic) APRPlayerType currentPlayerType;    // The current player - red or blue.

@property (nonatomic) NSArray *boardSquares;
@property (nonatomic) NSArray *boardPieces;
@property (nonatomic) APRGameStatus gameStatus;
@property (nonatomic) GKTurnBasedMatch *match;
@end


@implementation APRScene

#pragma mark - Initialization
- (instancetype)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self) {
        self.backgroundColor = [SKColor colorWithRed:0.30 green:0.30 blue:0.30 alpha:1.0];
        
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"BackGround.png"];
        [self addChild:background];
        background.position = CGPointMake( size.width * 0.5, size.height * 0.5);
        
        _highlightedSquare = [APRSquare spriteNodeWithImageNamed:@"highlight_square.png"];
        [self addChild:_highlightedSquare];
        _highlightedSquare.hidden = YES;
        _highlightedSquare.zPosition = -1;
        
        _boardSquares = [[NSMutableArray alloc] init];
        for (int y = 0; y < kBoardRows; y++) {
            for (int x = 0; x < kBoardColumns; x++) {
                APRSquare *square = [APRSquare spriteNodeWithImageNamed:@"square.png"];
                square.position = CGPointMake(x * 100 + 80 + 50, y * 100 + 34 + 50);
                [self addChild:square];
                square.pieceType = APRPieceTypeNone;
                square.playerType = APRPlayerTypeNone;
                square.coordinate = APRBoardCoordinateMake(x, y);
                [(NSMutableArray *)_boardSquares addObject:square];
            }
        }
        _gameStatus = APRGameStatusNoGame;
    }
    return self;
}

#pragma mark - Event Handling
- (void)mouseDown:(NSEvent *)theEvent {
     /* Called when a mouse click occurs */
    CGPoint location = [theEvent locationInNode:self];
    
    if (!self.pickedUpPiece && self.gameStatus == APRGameStatusStarted) {
        for (APRPiece *piece in self.boardPieces) {
            if (CGRectContainsPoint(piece.frame, location)) {
                self.pickedUpPiece = piece;
                break;
            }
        }
        
        APRPiece *pickedUpPiece = self.pickedUpPiece;
        if (pickedUpPiece && [self canPickUpPiece:pickedUpPiece]) {
            self.originalSquare = pickedUpPiece.square;
            self.pickedUpPieceOrigin = pickedUpPiece.position;
            [pickedUpPiece setScale:1.4];
            [pickedUpPiece setZPosition:-2];
        } else {
            self.pickedUpPiece = nil;
        }
    }
}

// Mouse moved, check to see if we need to move the piece we may have picked up.
- (void)mouseDragged:(NSEvent *)theEvent {
    CGPoint location = [theEvent locationInNode:self];
    
    APRPiece *pickedUpPiece = self.pickedUpPiece;
    if (pickedUpPiece) {
        pickedUpPiece.position = location;
        
        APRSquare *highlightedSquare = self.highlightedSquare;
        
        highlightedSquare.hidden = YES;
        for (APRSquare *square in self.boardSquares) {
            if (CGRectContainsPoint(square.frame, location)) {
                if ([self canPiece:pickedUpPiece landOn:square]) {
                    highlightedSquare.position = square.position;
                    highlightedSquare.hidden = NO;
                    highlightedSquare.coordinate = square.coordinate;
                    break;
                }
            }
        }
    }
}

// Mouse up, check to see if we can drop the piece here or return it.
- (void) mouseUp:(NSEvent *)theEvent {
    APRPiece *pickedUpPiece = self.pickedUpPiece;
    
    if (pickedUpPiece != nil) {
        APRSquare *highlightedSquare = self.highlightedSquare;
        
        if (highlightedSquare.hidden == NO) {
            APRSquare *destination = [self squareAtBoardCoordinate:highlightedSquare.coordinate];
            SKAction *moveAction  = [SKAction moveTo:highlightedSquare.position duration:0.2];
            [pickedUpPiece runAction:moveAction];
            
            if (destination != self.originalSquare) {
                APRPieceType pieceType = pickedUpPiece.square.pieceType;
                APRPlayerType playerType = pickedUpPiece.square.playerType;
                self.originalSquare.pieceType = APRPieceTypeNone;
                
                if (destination.pieceType != APRPieceTypeNone) {
                    [self destroyPieceOnSquare:destination];
                }
                
                destination.pieceType = pieceType;
                destination.playerType = playerType;
                destination.piece = pickedUpPiece;
                pickedUpPiece.square = destination;
                [self sendMoveToFoe];
            }
        } else {
            SKAction *moveAction  = [SKAction moveTo:self.pickedUpPieceOrigin duration:0.2];
            [pickedUpPiece runAction:moveAction];
        }
        
        SKAction *scaleAction = [SKAction scaleTo:1.0 duration:0.2];
        [pickedUpPiece runAction:scaleAction];
        [pickedUpPiece setZPosition:0];
        self.pickedUpPiece = nil;
        self.originalSquare = nil;
        highlightedSquare.hidden = YES;
    }
}

#pragma mark - Starting the Game
// Starts a new game with new pieces in their places.
- (void)newGame {
    self.currentPlayerType = APRPlayerTypeBlue;
    // fill in left and right
    for (int y = 0; y < kBoardRows; y++) {
        APRPieceType pieceType = APRPieceTypeRock + (y % 3);
        [self setPieceType:pieceType forPlayer:APRPlayerTypeRed atBoardCoordinate:APRBoardCoordinateMake(0, y)];
        [self setPieceType:pieceType forPlayer:APRPlayerTypeBlue atBoardCoordinate:APRBoardCoordinateMake(kBoardColumns - 1, y)];
    }
    
    // fill in first row left and right
    for (int y = 1; y < kBoardRows - 1; y++) {
        APRPieceType pieceType = APRPieceTypeRock + ((y + 1) % 3);
        [self setPieceType:pieceType forPlayer:APRPlayerTypeRed atBoardCoordinate:APRBoardCoordinateMake(1, y)];
        [self setPieceType:pieceType forPlayer:APRPlayerTypeBlue atBoardCoordinate:APRBoardCoordinateMake(kBoardColumns - 2, y)];
    }
    
    // fill in second row left and right
    for (int y = 2; y < kBoardRows - 2; y++) {
        APRPieceType pieceType = APRPieceTypeRock + ((y + 2) % 3);
        [self setPieceType:pieceType forPlayer:APRPlayerTypeRed atBoardCoordinate:APRBoardCoordinateMake(2, y)];
        [self setPieceType:pieceType forPlayer:APRPlayerTypeBlue atBoardCoordinate:APRBoardCoordinateMake(kBoardColumns - 3, y)];
    }
    
    [self addPieces];
    
    self.gameStatus = APRGameStatusStarted;
}

// Either start a game from scratch or start a new turn with some match data from Game Center.
- (void)startGameWithMatch:(GKTurnBasedMatch *)match
{
    if (self.gameStatus != APRGameStatusNoGame && self.gameStatus != APRGameStatusMoveOver) {
        NSLog(@"already in a game state!");
        return;
    }
    
    self.match = match;
    NSData *data = self.match.matchData;
    if ([data length] == 0) {
        // new game
        [self newGame];
    } else {
        [self deconstructMatchData:data];
    }
    [self updateScores];
}

#pragma mark - Board Construction
// Sets the state, typically a piece (empty, red_s etc.) for a specific x/y coordinate.
- (void)setPieceType:(APRPieceType)pieceType forPlayer:(APRPlayerType)playerType atBoardCoordinate:(APRBoardCoordinate)coordinate {
    APRSquare *square = [self squareAtBoardCoordinate:coordinate];
    square.pieceType = pieceType;
    square.playerType = playerType;
    return;
}

// Makes up the APRPiece objects for the board from the board state.
// Although the board knows what piece is on it, the piece is seperate so we can move it around.
- (void)addPieces {
    NSMutableArray *boardPieces = [[NSMutableArray alloc] init];
    
    for (APRSquare *square in self.boardSquares) {
        NSString *pieceTypeSuffix;
        switch (square.pieceType) {
            case APRPieceTypeRock:
                pieceTypeSuffix = @"r";
                break;
            case APRPieceTypePaper:
                pieceTypeSuffix = @"p";
                break;
            case APRPieceTypeScissors:
                pieceTypeSuffix = @"s";
                break;
            default:
                continue;
        }
        
        NSString *playerColor = (square.playerType == APRPlayerTypeBlue) ? @"blue" : @"red";
        
        NSString *imageName = [NSString stringWithFormat:@"%@_%@.png", playerColor, pieceTypeSuffix];
        APRPiece *piece = [APRPiece spriteNodeWithImageNamed:imageName];
        piece.position = square.position;
        piece.square = square;
        [self addChild:piece];
        
        [boardPieces addObject:piece];
    }
    
    self.boardPieces = boardPieces;
}

#pragma mark - Game Logic
// Can this piece be picked up? (Checks to see if player is same as piece color.)
- (BOOL)canPickUpPiece:(APRPiece *)piece {
    return self.currentPlayerType == piece.square.playerType;
}

// Can a piece move to this square? (Checks the up/down/left/right from the current position.)
- (BOOL)canPiece:(APRPiece *)piece landOn:(APRSquare *)square {
    // Original space.
    if (piece.square == square) {
        return YES;
    }
    
    // One of my own pieces.
    if (square.pieceType != APRPieceTypeNone && (piece.square.playerType == square.playerType)) {
        return NO;
    }
    
    // Calculate manhattan distance.
    int distance = abs(piece.square.coordinate.x - square.coordinate.x) + abs(piece.square.coordinate.y - square.coordinate.y);
    // Ensure the movement is no more than 1 in either cardinal direction.
    if (distance != 1) {
        return NO;
    }
    return [self canPiece:piece beatState:square.pieceType];
}

// Can this piece move to this state by either taking the piece, or moving to a blank square?
- (BOOL)canPiece:(APRPiece *)piece beatState:(APRPieceType)state {
    if (state == APRPieceTypeNone) {
        return YES;
    }
    
    return (piece.square.pieceType == APRPieceTypeRock && state == APRPieceTypeScissors) || (piece.square.pieceType == APRPieceTypePaper && state == APRPieceTypeRock) || (piece.square.pieceType == APRPieceTypeScissors && state == APRPieceTypePaper);
}

// One player is "taking" the other persons piece, add an effect for that and remove from board.
- (void)destroyPieceOnSquare:(APRSquare *)square {
    APRPiece *piece = [self pieceForSquare:square];
    if (piece) {
        SKAction *action1 = [SKAction fadeOutWithDuration:1.0];
        SKAction *action2 = [SKAction scaleBy:2.0 duration:1.0];
        SKAction *group = [SKAction group:@[ action1, action2] ];
        [piece runAction:group completion:^{
            [piece removeFromParent];
        }];
    }
}

// Send my move on to the next player via Game Center
- (void)sendMoveToFoe {
    GKTurnBasedMatch *match = self.match;
    GKTurnBasedParticipant *nextPlayer = match.participants[0];
    
    if ([match.currentParticipant.playerID isEqualToString:nextPlayer.playerID]) {
        nextPlayer = match.participants[1];
    }
    
    [match endTurnWithNextParticipants:@[nextPlayer]
                           turnTimeout:60 * 60 * 24 * 7
                             matchData:[self constructMatchData]
                     completionHandler:^(NSError *error) {
                         NSLog(@"sent move to foe");
                     }];
    
    [self updateScores];
    
    self.gameStatus = APRGameStatusMoveOver;
}

#pragma mark - Scoring
// Works out the score for the current board and asks the delegate to display it.
- (void)updateScores {
    int red = 0;
    int blue = 0;
    for (APRPiece *piece in self.boardPieces) {
        switch (piece.square.playerType) {
            case APRPlayerTypeRed:
                red++;
                break;
            case APRPlayerTypeBlue:
                blue++;
                break;
            default:
                break;
        }
    }
    // Red's score is how many pieces of blue he's taken, so 9 - current number of pieces.
    [[NSApp delegate] setGameScoreForPlayer:APRPlayerTypeRed score:(kNumberOfGamePieces - blue)];
    // Blue's score is how many pieces of red he's taken, so 9 - current number of pieces.
    [[NSApp delegate] setGameScoreForPlayer:APRPlayerTypeBlue score:(kNumberOfGamePieces - red)];
}

#pragma mark - Encoding and Decoding Match Data
// Construct the match data for the board state.
- (NSData *)constructMatchData {
    NSMutableArray *board = [[NSMutableArray alloc] init];
    for (APRSquare *square in self.boardSquares) {
        [board addObject:@{ @"x" : @(square.coordinate.x), @"y" : @(square.coordinate.y),
                            @"playerType" : @(square.playerType), @"pieceType" : @(square.pieceType) }];
    }
    
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:board forKey:@"board"];
    [archiver encodeObject:[NSNumber numberWithInt:self.currentPlayerType] forKey:@"currentPlayer"];
    [archiver finishEncoding];
    
    return data;
}

// Interpret some match data and setup the board from the dataset.
- (void)deconstructMatchData:(NSData *)data {
    // Remove all pieces from all squares.
    for (APRSquare *square in self.boardSquares) {
        square.pieceType = APRPieceTypeNone;
    }
    
    for (APRPiece *piece in self.boardPieces) {
        [piece removeFromParent];
    }
    
    // Decode the board.
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSArray *board = [unarchiver decodeObjectForKey:@"board"];
    for (NSDictionary *square in board) {
        int x = [[square objectForKey:@"x"] intValue];
        int y = [[square objectForKey:@"y"] intValue];
        APRPieceType pieceType = [[square objectForKey:@"pieceType"] intValue];
        APRPlayerType playerType = [[square objectForKey:@"playerType"] intValue];
        [self setPieceType:pieceType forPlayer:playerType atBoardCoordinate:APRBoardCoordinateMake(x, y)];
    }
    
    // Swap players.
    APRPlayerType playerType = [[unarchiver decodeObjectForKey:@"currentPlayer"] intValue];
    if (playerType == APRPlayerTypeRed) {
        self.currentPlayerType = APRPlayerTypeBlue;
    } else {
        self.currentPlayerType = APRPlayerTypeRed;
    }
    
    [self addPieces];
    
    self.gameStatus = APRGameStatusStarted;
}

#pragma mark - Turn-Based Event Handler Delegate
- (void)handleInviteFromGameCenter:(NSArray *)playersToInvite {
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.playersToInvite = playersToInvite;
    
    GKTurnBasedMatchmakerViewController *viewController = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
    [[GKDialogController sharedDialogController] presentViewController:viewController];
}

- (void)handleTurnEventForMatch:(GKTurnBasedMatch *)match didBecomeActive:(BOOL)didBecomeActive {
    if ([self.match.matchID isEqualToString:match.matchID]) {
        self.match = match;
        NSData *data = match.matchData;
        [self deconstructMatchData:data];
        [self updateScores];
    }
}

#pragma mark - Utility Methods
// Returns the Square object at a specific x/y coordinate.
- (APRSquare *)squareAtBoardCoordinate:(APRBoardCoordinate)coordinate {
    for (APRSquare *square in self.boardSquares) {
        if (APRBoardCoordinateIsEqualToCoordinate(square.coordinate, coordinate)) {
            return square;
        }
    }
    return nil;
}

// Returns the current APRPiece for a specific square or returns nil if there isn't one.
- (APRPiece *)pieceForSquare:(APRSquare *)square {
    for (APRPiece *piece in self.boardPieces) {
        if (piece.square == square) {
            return piece;
        }
    }
    return nil;
}

#pragma mark - Update Loop
-  (void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end


#pragma mark - Private Classes
@implementation APRPiece
@end

@implementation APRSquare
@end

#pragma mark - Board Coordinate Helper Functions
APRBoardCoordinate APRBoardCoordinateMake(int x, int y) {
    return (APRBoardCoordinate){ x, y };
}

BOOL APRBoardCoordinateIsEqualToCoordinate(APRBoardCoordinate a, APRBoardCoordinate b) {
    return (a.x == b.x) && (a.y == b.y);
}
