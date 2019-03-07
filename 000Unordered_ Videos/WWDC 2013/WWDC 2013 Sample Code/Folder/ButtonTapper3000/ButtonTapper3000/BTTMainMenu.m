/*
     File: BTTMainMenu.m
 Abstract: Main Game Menu. Demonstrates how to bring up the Game Center View controller. Also how to challenge friends with a made up score, and how to use the Challenge Compose Controller
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

#import "BTTMainMenu.h"
#import "BTTGameSetupMenu.h"
#import "BTTStatsScreen.h"
#import "BTTAppDelegate.h"
#import "BTTGameInfo.h"
#import "BTTMainGame.h"

@interface BTTMainMenu ()

@property (nonatomic, retain) SKLabelNode *startButton;
@property (nonatomic, retain) SKLabelNode *gameCenterButton;
@property (nonatomic, retain) SKLabelNode *gameStatsButton;
@property (nonatomic, retain) SKLabelNode *playChallengeButton;
@property (nonatomic, retain) SKLabelNode *challengeFriendsButton;

@end

@implementation BTTMainMenu

- (void)selectChallenge:(GKScoreChallenge*)challenge
{
    BTTGameInfo *gameInfo = [BTTGameInfo sharedBCTGameInfo];
    
    NSString *leaderboardID = challenge.score.leaderboardIdentifier;
    NSArray *substrings = [leaderboardID componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
    NSString *leaderboardSubstring = [substrings lastObject];
    NSString *timeString = [leaderboardSubstring substringToIndex:9];
    NSString *modeString = [leaderboardSubstring substringFromIndex:9];
    
    if ([timeString isEqualToString:@"15seconds"])
        gameInfo.gameTime = BTTGameTime15;
    else if ([timeString isEqualToString:@"30seconds"])
        gameInfo.gameTime = BTTGameTime30;
    else if ([timeString isEqualToString:@"45seconds"])
        gameInfo.gameTime = BTTGameTime45;
    else //error
        gameInfo.gameTime = BTTGameTime15;
    
    if ([modeString isEqualToString:@"easymode"])
        gameInfo.gameTime = BTTGameModeEasy;
    else if ([modeString isEqualToString:@"hardmode"])
        gameInfo.gameTime = BTTGameModeHard;
    else //error
        gameInfo.gameMode = BTTGameModeEasy;

    gameInfo.challenge = challenge;
    
    _playChallengeButton.hidden = NO;
}

- (void)setupChallengeButton
{
    _playChallengeButton.hidden = YES;
    [GKChallenge loadReceivedChallengesWithCompletionHandler:^(NSArray *challenges, NSError *error) {
        for (GKChallenge *challenge in challenges) {
            if ([challenge isKindOfClass:[GKScoreChallenge class]]) {
                [self selectChallenge:(GKScoreChallenge*)challenge];
                break;
            }
        }
    }];
}

- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        SKLabelNode *title = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        title.text = @"Button Tapper";
        title.fontSize = 30;
        title.position = CGPointMake(CGRectGetMidX(self.frame),
                                     CGRectGetMidY(self.frame) + 60);
        
        _startButton = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        _startButton.text = @"Start Game";
        _startButton.fontSize = 18;
        _startButton.fontColor = [self buttonColor];
        _startButton.position = CGPointMake(CGRectGetMidX(self.frame),
                                      CGRectGetMidY(self.frame));
        
        _gameCenterButton = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        _gameCenterButton.text = @"Game Center";
        _gameCenterButton.fontSize = 18;
        _gameCenterButton.fontColor = [self buttonColor];
        _gameCenterButton.position = CGPointMake(CGRectGetMidX(self.frame),
                                           CGRectGetMidY(self.frame) - 60);
        
        _gameStatsButton = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        _gameStatsButton.text = @"Game Stats";
        _gameStatsButton.fontSize = 18;
        _gameStatsButton.fontColor = [self buttonColor];
        _gameStatsButton.position = CGPointMake(CGRectGetMidX(self.frame),
                                          CGRectGetMidY(self.frame) - 120);
        
        _challengeFriendsButton = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        _challengeFriendsButton.text = @"Challenge Friends";
        _challengeFriendsButton.fontSize = 18;
        _challengeFriendsButton.fontColor = [self buttonColor];
        _challengeFriendsButton.position = CGPointMake(CGRectGetMidX(self.frame),
                                                    CGRectGetMidY(self.frame) - 180);
        
        _playChallengeButton = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        _playChallengeButton.text = @"Play Challenge";
        _playChallengeButton.fontSize = 18;
        _playChallengeButton.fontColor = [self buttonColor];
        _playChallengeButton.position = CGPointMake(CGRectGetMidX(self.frame),
                                                    CGRectGetMidY(self.frame) - 240);
                
        [self setupChallengeButton];
        
        [self addChild:title];
        [self addChild:_startButton];
        [self addChild:_gameCenterButton];
        [self addChild:_gameStatsButton];
        [self addChild:_challengeFriendsButton];
        [self addChild:_playChallengeButton];
        
        [[GKLocalPlayer localPlayer] registerListener:self];
    }
    return self;
}

- (void)challengeFriends
{
    BTTAppDelegate *delegate = [BTTAppDelegate appDelegate];
    
    //We are setting up a dummy score for this example.
    //It would be better to build a challenge based on a score that the player selects, or has just earned
    GKScore *score = [[GKScore alloc] init];
    score.leaderboardIdentifier = @"com.apple.sample.gamekitsamplewwdc2013.15secondseasymode";
    score.context = BTTGame15Easy;
    score.value = 10;
    
    UIViewController *challengeController = [score challengeComposeControllerWithPlayers:[GKLocalPlayer localPlayer].friends message:@"Beat it!" completionHandler:^(UIViewController *composeController, BOOL didIssueChallenge, NSArray *sentPlayerIDs) {
        [delegate.viewController dismissViewControllerAnimated:YES completion:nil];
    }];
    [delegate.viewController presentViewController: challengeController animated: YES completion:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        if (CGRectContainsPoint(self.startButton.frame, location)) {
            SKScene *scene = [BTTGameSetupMenu sceneWithSize:self.view.bounds.size];
            scene.scaleMode = SKSceneScaleModeAspectFill;
            
            SKTransition *transition = [SKTransition moveInWithDirection:SKTransitionDirectionUp duration:0.5];
            
            [self.view presentScene:scene transition:transition];
        }
        
        else if (CGRectContainsPoint(self.gameCenterButton.frame, location)) {
            [[BTTAppDelegate appDelegate] showGameCenter];
        }
        
        else if (CGRectContainsPoint(self.gameStatsButton.frame, location)) {
            SKScene *scene = [BTTStatsScreen sceneWithSize:self.view.bounds.size];
            scene.scaleMode = SKSceneScaleModeAspectFill;
            
            SKTransition *transition = [SKTransition moveInWithDirection:SKTransitionDirectionUp duration:0.5];
            
            [self.view presentScene:scene transition:transition];
        }
        
        else if (CGRectContainsPoint(self.challengeFriendsButton.frame, location)) {
            if (![GKLocalPlayer localPlayer].friends) {
                [[GKLocalPlayer localPlayer] loadFriendsWithCompletionHandler:^(NSArray *friendIDs, NSError *error) {
                    [self challengeFriends];
                }];
            }
            else {
                [self challengeFriends];
            }
        }
        
        else if (CGRectContainsPoint(self.playChallengeButton.frame, location)) {
            SKScene *scene = [BTTMainGame sceneWithSize:self.view.bounds.size];
            scene.scaleMode = SKSceneScaleModeAspectFill;
            
            SKTransition *transition = [SKTransition moveInWithDirection:SKTransitionDirectionUp duration:0.5];
            
            [self.view presentScene:scene transition:transition];
        }
    }
}

- (void)player:(GKPlayer *)player didReceiveChallenge:(GKChallenge *)challenge
{
    if (player == [GKLocalPlayer localPlayer]) {
        if ([challenge isKindOfClass:[GKScoreChallenge class]]) {
            [self selectChallenge:(GKScoreChallenge *)challenge];
        }
    }
}

@end
