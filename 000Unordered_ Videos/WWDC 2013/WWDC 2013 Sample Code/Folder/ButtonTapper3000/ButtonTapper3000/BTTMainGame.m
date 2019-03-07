/*
     File: BTTMainGame.m
 Abstract: The actual game. Also demonstrates how to submitt scores and achievments once the game is completed.
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

#import "BTTMainGame.h"
#import "BTTResultsScreen.h"

#import "BTTGameInfo.h"

@interface BTTMainGame ()

@property (nonatomic, retain) SKLabelNode *button;
@property (nonatomic, retain) SKLabelNode *timerLabel;
@property (nonatomic, retain) SKLabelNode *clicksLabel;
@property (nonatomic, retain) NSTimer *gameTimer;
@property (nonatomic, retain) NSTimer *tickTimer;

@end


@implementation BTTMainGame

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        BTTGameInfo *gameInfo = [BTTGameInfo sharedBCTGameInfo];
        gameInfo.currentTaps = 0;
        _gameTimer = [NSTimer scheduledTimerWithTimeInterval:[gameInfo getGameTimeInSeconds] target:self selector:@selector(timerDone:) userInfo:nil repeats:NO];
        _tickTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        _button = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        
        _button.text = @"Tap Me!";
        _button.fontSize = 18;
        _button.fontColor = [self buttonColor];
        _button.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
        
        _clicksLabel = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Bold"];
        
        _clicksLabel.text = [NSString stringWithFormat:@"%d", gameInfo.currentTaps];
        _clicksLabel.fontSize = 45;
        _clicksLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                            CGRectGetMidY(self.frame) - 120);
        
        _timerLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-CondensedBlack"];
        
        _timerLabel.text = [NSString stringWithFormat:@"%d", gameInfo.currentTicks];
        _timerLabel.fontSize = 45;
        _timerLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                           CGRectGetMidY(self.frame) + 120);
        
        [self addChild:_button];
        [self addChild:_clicksLabel];
        [self addChild:_timerLabel];
    }
    return self;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    BTTGameInfo *gameInfo = [BTTGameInfo sharedBCTGameInfo];
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        if (CGRectContainsPoint(self.button.frame, location)) {
            gameInfo.currentTaps++;
            if (gameInfo.gameMode == BTTGameModeHard) {
                NSInteger x = rand()%100 - 50;
                NSInteger y = rand()%100 - 50;
                _button.position = CGPointMake(CGRectGetMidX(self.frame) + x,
                                               CGRectGetMidY(self.frame) + y);
            }
        }
        
        GKAchievement *tapOnceAchievement = [[GKAchievement alloc] initWithIdentifier:@"com.apple.sample.gamekitsamplewwdc2013.taponce" forPlayer:[GKLocalPlayer localPlayer].playerID];
        tapOnceAchievement.percentComplete = 100;
        [GKAchievement reportAchievements:@[tapOnceAchievement] withCompletionHandler:^(NSError *error) {
        }];
    }
}

- (void)update:(CFTimeInterval)currentTime {
    
    BTTGameInfo *gameInfo = [BTTGameInfo sharedBCTGameInfo];
    
    self.clicksLabel.text = [NSString stringWithFormat:@"%d", gameInfo.currentTaps];
    self.timerLabel.text = [NSString stringWithFormat:@"%d", gameInfo.currentTicks];
    
}

- (void)timerTick:(NSTimer*)theTimer
{
    BTTGameInfo *gameInfo = [BTTGameInfo sharedBCTGameInfo];
    
    gameInfo.currentTicks--;
    
    if (gameInfo.currentTicks < 0) {
        gameInfo.currentTicks = 0;
        [self timerDone:theTimer];
    }
}

- (void)timerDone:(NSTimer*)theTimer
{
    [self.tickTimer invalidate];
    [self reportScore];

    SKScene *scene = [BTTResultsScreen sceneWithSize:self.view.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    SKTransition *transition = [SKTransition moveInWithDirection:SKTransitionDirectionUp duration:0.5];
    
    [self.view presentScene:scene transition:transition];
}

- (void) reportScore
{
    BTTGameInfo *gameInfo = [BTTGameInfo sharedBCTGameInfo];
    NSString *leaderboardIdentifier = nil;
    NSString *gameTypeString = nil;
    BTTGameTypePlayed gameType = 0;
    
    if (gameInfo.gameTime == BTTGameTime15) {
        if (gameInfo.gameMode == BTTGameModeEasy) {
            gameTypeString = @"15secondseasymode";
            gameType = BTTGame15Easy;
        }
        else if (gameInfo.gameMode == BTTGameModeHard) {
            gameTypeString = @"15secondshardmode";
            gameType = BTTGame15Hard;
        }
    }
    else if (gameInfo.gameTime == BTTGameTime30) {
        if (gameInfo.gameMode == BTTGameModeEasy) {
            gameTypeString = @"30secondseasymode";
            gameType = BTTGame30Easy;
        }
        else if (gameInfo.gameMode == BTTGameModeHard) {
            gameTypeString = @"30secondshardmode";
            gameType = BTTGame30Hard;
        }

    }
    else if (gameInfo.gameTime == BTTGameTime45) {
        if (gameInfo.gameMode == BTTGameModeEasy) {
            gameTypeString = @"45secondseasymode";
            gameType = BTTGame45Easy;
        }
        else if (gameInfo.gameMode == BTTGameModeHard) {
            gameTypeString = @"45secondshardmode";
            gameType = BTTGame45Hard;
        }

    }
    
    if (gameTypeString != nil) {
        leaderboardIdentifier = [NSString stringWithFormat:@"com.apple.sample.gamekitsamplewwdc2013.%@",gameTypeString];
    }
    
    if (leaderboardIdentifier != nil) {
        GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:leaderboardIdentifier];
        score.value = gameInfo.currentTaps;
        score.context = 0;
        
        if (gameInfo.challenge) {
            [GKScore reportScores:@[score] withEligibleChallenges:@[gameInfo.challenge] withCompletionHandler:^(NSError *error) {
                if(error != nil) {
                    NSLog(@"Error submitting score for game with challenge: %@", error);
                }

            }];
        }
        else{
            [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
                if(error != nil) {
                    NSLog(@"Error submitting score for game: %@", error);
                }
            }];
        }
    }
    
    if (gameInfo.gameMode == BTTGameModeHard){
        GKAchievement *playHardModeAchievement = [[GKAchievement alloc] initWithIdentifier:@"com.apple.sample.gamekitsamplewwdc2013.playhardmode" forPlayer:[GKLocalPlayer localPlayer].playerID];
        playHardModeAchievement.percentComplete = 100;
        [GKAchievement reportAchievements:@[playHardModeAchievement] withCompletionHandler:^(NSError *error) {
        }];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *playedGameTypes = [defaults objectForKey:@"playedGameTypes"];
    NSInteger playedGameTypesBitField = playedGameTypes.integerValue;
    //set bit for the game we just played
    playedGameTypesBitField |= gameType;
    [defaults setObject:[NSNumber numberWithInt:playedGameTypesBitField] forKey:@"playedGameTypes"];
    [defaults synchronize];
    
    //count up the items in the bitfield to set percent complete
    NSInteger numTypesPlayed = 0;
    NSInteger typesField = playedGameTypesBitField;
    NSInteger i;
    for (i = 0; i < 6 ; i++){
        if (typesField & 0x1)
            numTypesPlayed++;
        typesField >>= 1;
    }
    
    GKAchievement *playAllModesAchievement = [[GKAchievement alloc] initWithIdentifier:@"com.apple.sample.gamekitsamplewwdc2013.playallgametypes" forPlayer:[GKLocalPlayer localPlayer].playerID];
    playAllModesAchievement.percentComplete = numTypesPlayed / 6.0f * 100.0f;
    [GKAchievement reportAchievements:@[playAllModesAchievement] withCompletionHandler:^(NSError *error) {
    }];
    
    [self updateCurrentTapsLeaderboardAndTapAchievements];
        
}



- (void)updateCurrentTapsLeaderboardAndTapAchievements
{    
    NSArray *playerIDs = @[[GKLocalPlayer localPlayer].playerID];
    GKLeaderboard *averageTapLeaderboard = [[GKLeaderboard alloc] initWithPlayerIDs:playerIDs];
    averageTapLeaderboard.identifier = @"com.apple.sample.gamekitsamplewwdc2013.averagetaptime";
    [averageTapLeaderboard loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
        BTTGameInfo *gameInfo = [BTTGameInfo sharedBCTGameInfo];
        
        GKScore *currentScore;
        NSInteger oldTime;
        NSInteger oldTaps;
        NSInteger newTime;
        NSInteger newTaps;
        NSInteger newAverage;
        
        GKScore *newScore = [[GKScore alloc] initWithLeaderboardIdentifier:@"com.apple.sample.gamekitsamplewwdc2013.averagetaptime"];
        
        if(error != nil) {
			NSLog(@"Error collecting scores for average tap time: %@", error);
            return;
		}
        if (scores.count >= 1) {
            currentScore = scores[0];
            oldTaps = currentScore.context;
            oldTime = currentScore.value * oldTaps;
            
            newTime = oldTime + gameInfo.getGameTimeInSeconds * 100;
            newTaps = oldTaps + gameInfo.currentTaps;
            
            newAverage = (int64_t)((float)newTime/(float)newTaps);
            newScore.value = newAverage;
            newScore.context = newTaps;
        }
        
        else { //first time playing, we have no score to average with
            
            newScore.value = (int64_t) (((float)gameInfo.getGameTimeInSeconds / (float)gameInfo.currentTaps) * 100.0f);
            newScore.context = gameInfo.currentTaps;
        }
        
        GKAchievement *playAHundread = [[GKAchievement alloc] initWithIdentifier:@"com.apple.sample.gamekitsamplewwdc2013.tapahundread" forPlayer:[GKLocalPlayer localPlayer].playerID];
        playAHundread.percentComplete = (float)newScore.context / 100.0f * 100.0f;
        [GKAchievement reportAchievements:@[playAHundread] withCompletionHandler:^(NSError *error) {
        }];

        GKAchievement *playAThousand = [[GKAchievement alloc] initWithIdentifier:@"com.apple.sample.gamekitsamplewwdc2013.tapathousand" forPlayer:[GKLocalPlayer localPlayer].playerID];
        playAThousand.percentComplete = (float)newScore.context / 1000.0f * 100.0f;
        [GKAchievement reportAchievements:@[playAThousand] withCompletionHandler:^(NSError *error) {
        }];
        
        [GKScore reportScores:@[newScore] withCompletionHandler:^(NSError *error) {
            if(error != nil) {
                NSLog(@"Error collecting scores for average tap time: %@", error);
            }
        }];

        
        
    }];
}

@end

