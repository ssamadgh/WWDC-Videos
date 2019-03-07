/*
     File: BTTStatsScreen.m
 Abstract: Several Screens that display the Game Center data in a unique way.
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

#import "BTTStatsScreen.h"
#import "BTTMainMenu.h"
#import "BTTGameInfo.h"

@interface BTTStatsScreen ()

@property (nonatomic, retain) SKLabelNode *leaderboardsButton;
@property (nonatomic, retain) SKLabelNode *achievementsButton;
@property (nonatomic, retain) SKLabelNode *backButton;

@end

@implementation BTTStatsScreen

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        SKLabelNode *title = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        title.text = @"Stats";
        title.fontSize = 30;
        title.position = CGPointMake(CGRectGetMidX(self.frame),
                                     CGRectGetMidY(self.frame) + 60);
        
        _leaderboardsButton = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        _leaderboardsButton.text = @"Leaderboards";
        _leaderboardsButton.fontSize = 18;
        _leaderboardsButton.fontColor = [self buttonColor];
        _leaderboardsButton.position = CGPointMake(CGRectGetMidX(self.frame),
                                      CGRectGetMidY(self.frame));
        
        _achievementsButton = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        _achievementsButton.text = @"Achievements";
        _achievementsButton.fontSize = 18;
        _achievementsButton.fontColor = [self buttonColor];
        _achievementsButton.position = CGPointMake(CGRectGetMidX(self.frame),
                                           CGRectGetMidY(self.frame) - 60);
        
        _backButton = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        _backButton.text = @"Back";
        _backButton.fontSize = 18;
        _backButton.fontColor = [self buttonColor];
        _backButton.position = CGPointMake(CGRectGetMidX(self.frame),
                                          CGRectGetMidY(self.frame) - 200);
        
        
        [self addChild:title];
        [self addChild:_leaderboardsButton];
        [self addChild:_achievementsButton];
        [self addChild:_backButton];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        if (CGRectContainsPoint(self.leaderboardsButton.frame, location)) {
            SKScene *scene = [BTTLeaderboardSetsScreen sceneWithSize:self.view.bounds.size];
            scene.scaleMode = SKSceneScaleModeAspectFill;
            
            SKTransition *transition = [SKTransition moveInWithDirection:SKTransitionDirectionUp duration:0.5];
            
            [self.view presentScene:scene transition:transition];
        }
        
        else if (CGRectContainsPoint(self.achievementsButton.frame, location)) {
            SKScene *scene = [BTTAchievementsScreen sceneWithSize:self.view.bounds.size];
            scene.scaleMode = SKSceneScaleModeAspectFill;
            
            SKTransition *transition = [SKTransition moveInWithDirection:SKTransitionDirectionUp duration:0.5];
            
            [self.view presentScene:scene transition:transition];

        }
        
        else if (CGRectContainsPoint(self.backButton.frame, location)) {
            SKScene *scene = [BTTMainMenu sceneWithSize:self.view.bounds.size];
            scene.scaleMode = SKSceneScaleModeAspectFill;
            
            SKTransition *transition = [SKTransition moveInWithDirection:SKTransitionDirectionUp duration:0.5];
            
            [self.view presentScene:scene transition:transition];
        }
    }
}

@end


@interface BTTAchievementsScreen ()

@property (nonatomic, retain) SKLabelNode *backButton;

@end

@implementation BTTAchievementsScreen

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        SKLabelNode *title = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        title.text = @"Achievements";
        title.fontSize = 30;
        title.position = CGPointMake(CGRectGetMidX(self.frame),
                                     CGRectGetMidY(self.frame) + 200);
        
        _backButton = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        _backButton.text = @"Back";
        _backButton.fontSize = 18;
        _backButton.fontColor = [self buttonColor];
        _backButton.position = CGPointMake(CGRectGetMidX(self.frame),
                                     CGRectGetMidY(self.frame) - 200);
        
        
        SKLabelNode *incompleteLabel = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        incompleteLabel.text = @"Incomplete";
        incompleteLabel.fontSize = 18;
        incompleteLabel.position = CGPointMake(CGRectGetMidX(self.frame) + 75,
                                     CGRectGetMidY(self.frame) + 150);
        
        
        SKLabelNode *completeLabel = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        completeLabel.text = @"Complete";
        completeLabel.fontSize = 18;
        completeLabel.position = CGPointMake(CGRectGetMidX(self.frame) - 75,
                                     CGRectGetMidY(self.frame) + 150);
        
        [self loadAchievementInfo];
        
        [self addChild:title];
        [self addChild:incompleteLabel];
        [self addChild:completeLabel];
        [self addChild:_backButton];
    }
    return self;
}

- (void) loadAchievementInfo
{
    [GKAchievementDescription loadAchievementDescriptionsWithCompletionHandler:^(NSArray *descriptions, NSError *error) {
        
        [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
            
            NSInteger completeOffset = 0;
            NSInteger incompleteOffset = 0;
            
            for(GKAchievementDescription *description in descriptions)
            {
                GKAchievement *playerAchievement;
                
                for (GKAchievement *achievement in achievements)
                    if([description.identifier isEqualToString:achievement.identifier])
                        playerAchievement = achievement;
                
                NSInteger xOffset = (playerAchievement.completed ? -75 : 75);
                NSInteger yOffset = (playerAchievement.completed ? completeOffset : incompleteOffset);
                
                
                SKLabelNode *achievementLabel = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
                achievementLabel.text = description.title;
                achievementLabel.fontSize = 10;
                achievementLabel.position = CGPointMake(CGRectGetMidX(self.frame) + xOffset,
                                                        CGRectGetMidY(self.frame) + 50 + yOffset + 25);
                
                [self addChild:achievementLabel];
                
                [description loadImageWithCompletionHandler:^(UIImage *image, NSError *error) {
                    SKTexture *imageTexture;
                    
                    if (image)
                        imageTexture = [SKTexture textureWithImage:image];
                    else
                        imageTexture = [SKTexture textureWithImageNamed:@"DefaultPlayerPhoto.png"];
                    
                    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:imageTexture size:CGSizeMake(32, 32)];
                    
                    sprite.position = CGPointMake(CGRectGetMidX(self.frame) + xOffset,
                                                  CGRectGetMidY(self.frame) + 50 + yOffset + 50);
                    [self addChild:sprite];
                }];
                if(playerAchievement.completed)
                    completeOffset -= 50;
                else
                    incompleteOffset -= 50;
                
            }
            
        }];
        
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        if (CGRectContainsPoint(self.backButton.frame, location)) {
            SKScene *scene = [BTTStatsScreen sceneWithSize:self.view.bounds.size];
            scene.scaleMode = SKSceneScaleModeAspectFill;
            
            SKTransition *transition = [SKTransition moveInWithDirection:SKTransitionDirectionUp duration:0.5];
            
            [self.view presentScene:scene transition:transition];
        }
    }
}

@end

@interface BTTLeaderboardScoresScreen ()

@property (nonatomic, retain) SKLabelNode *backButton;

@end

@implementation BTTLeaderboardScoresScreen

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
    
        BTTGameInfo *gameInfo = [BTTGameInfo sharedBCTGameInfo];
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        SKLabelNode *title = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        title.text = gameInfo.currentLeaderboard.title;
        title.fontSize = 14;
        title.position = CGPointMake(CGRectGetMidX(self.frame),
                                     CGRectGetMidY(self.frame) + 200);
        
        
        SKTexture *podiumTexture = [SKTexture textureWithImageNamed:@"Podium.png"];
        
        SKSpriteNode *podiumSprite = [SKSpriteNode spriteNodeWithTexture:podiumTexture];
        
        podiumSprite.position = CGPointMake(CGRectGetMidX(self.frame),
                                     CGRectGetMidY(self.frame) + 50);

        
        
        _backButton = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        _backButton.text = @"Back";
        _backButton.fontSize = 18;
        _backButton.fontColor = [self buttonColor];
        _backButton.position = CGPointMake(CGRectGetMidX(self.frame),
                                           CGRectGetMidY(self.frame) - 200);
        
        [self loadLeaderboardScoresInfo:gameInfo.currentLeaderboard];
        
        [self addChild:title];
        [self addChild:_backButton];
        [self addChild:podiumSprite];
    }
    return self;
}

- (void)displayScore:(GKScore *)score withRank:(NSInteger)rank forPlayer:(GKPlayer*)player
{
    
    NSArray *podiumPositions = @[[NSValue valueWithCGPoint:CGPointMake (0, 100)],
                                 [NSValue valueWithCGPoint:CGPointMake (-84, 75)],
                                 [NSValue valueWithCGPoint:CGPointMake (84, 50)]];
    
    CGPoint currentPoint = [podiumPositions[rank] CGPointValue];
    
    SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
    scoreLabel.text = score.formattedValue;
    scoreLabel.fontSize = 14;
    scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame) + currentPoint.x,
                                      CGRectGetMidY(self.frame) + currentPoint.y - 32);
    
    [player loadPhotoForSize:GKPhotoSizeSmall withCompletionHandler:^(UIImage *photo, NSError *error) {
        SKTexture *imageTexture;
        
        if (photo)
            imageTexture = [SKTexture textureWithImage:photo];
        else
            imageTexture = [SKTexture textureWithImageNamed:@"DefaultPlayerPhoto.png"];
        
        SKSpriteNode *image = [SKSpriteNode spriteNodeWithTexture:imageTexture size:CGSizeMake(32, 32)];
        
        image.position = CGPointMake(CGRectGetMidX(self.frame) + currentPoint.x,
                                     CGRectGetMidY(self.frame) + currentPoint.y + 16);
        [self addChild:image];
    }];
    
    
    [self addChild:scoreLabel];
}

- (void) loadLeaderboardScoresInfo:(GKLeaderboard *)leaderboard
{
    leaderboard.range = NSMakeRange(1, 3);
    leaderboard.timeScope = GKLeaderboardTimeScopeAllTime;
    leaderboard.playerScope = GKLeaderboardPlayerScopeGlobal;
    [leaderboard loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
        
        NSMutableArray *players = [[NSMutableArray alloc] initWithCapacity:[scores count]];
        
        for (GKScore *score in scores) {
            [players addObject:score.playerID];
        }
        
        [GKPlayer loadPlayersForIdentifiers:players withCompletionHandler:^(NSArray *players, NSError *error) {
            NSInteger index = 0;
            for (GKScore *score in scores) {
                [self displayScore:score withRank:index forPlayer:players[index]];
                index++;
            }
        }];
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        if (CGRectContainsPoint(self.backButton.frame, location)) {
            SKScene *scene = [BTTLeaderboardsScreen sceneWithSize:self.view.bounds.size];
            scene.scaleMode = SKSceneScaleModeAspectFill;
            
            SKTransition *transition = [SKTransition moveInWithDirection:SKTransitionDirectionUp duration:0.5];
            
            [self.view presentScene:scene transition:transition];
        }
    }
}

@end


@interface BTTLeaderboardsScreen ()

@property (nonatomic, retain) SKLabelNode *backButton;
@property (nonatomic, retain) NSArray *leaderboards;
@property (nonatomic, retain) NSArray *leaderboardButtons;

@end

@implementation BTTLeaderboardsScreen

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        SKLabelNode *title = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        title.text = @"Leaderboards";
        title.fontSize = 30;
        title.position = CGPointMake(CGRectGetMidX(self.frame),
                                     CGRectGetMidY(self.frame) + 200);
        
        _backButton = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        _backButton.text = @"Back";
        _backButton.fontSize = 18;
        _backButton.fontColor = [self buttonColor];
        _backButton.position = CGPointMake(CGRectGetMidX(self.frame),
                                     CGRectGetMidY(self.frame) - 200);
        
        BTTGameInfo *gameInfo = [BTTGameInfo sharedBCTGameInfo];

        [self loadLeaderboardInfoWithSet:gameInfo.currentSet];
        
        [self addChild:title];
        [self addChild:_backButton];
    }
    return self;
}

- (void) loadLeaderboardInfoWithSet:(GKLeaderboardSet *)leaderboardSet
{
    [leaderboardSet loadLeaderboardsWithCompletionHandler:^(NSArray *leaderboards, NSError *error) {
        self.leaderboards = leaderboards;
        
        NSInteger offset = 0;
        NSMutableArray *buttons = [[NSMutableArray alloc] init];
        
        for (GKLeaderboard *leaderboard in leaderboards) {
            SKLabelNode *leaderboardButton = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
            leaderboardButton.text = leaderboard.title;
            leaderboardButton.fontSize = 18;
            leaderboardButton.position = CGPointMake(CGRectGetMidX(self.frame),
                                         CGRectGetMidY(self.frame) + 125 - offset);
            offset += 50;
            
            [self addChild:leaderboardButton];
            [buttons addObject:leaderboardButton];
        }
        self.leaderboardButtons = [NSArray arrayWithArray:buttons];
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        if (CGRectContainsPoint(self.backButton.frame, location)) {
            SKScene *scene = [BTTStatsScreen sceneWithSize:self.view.bounds.size];
            scene.scaleMode = SKSceneScaleModeAspectFill;
            
            SKTransition *transition = [SKTransition moveInWithDirection:SKTransitionDirectionUp duration:0.5];
            
            [self.view presentScene:scene transition:transition];
        }
        NSInteger index = 0;
        for (SKLabelNode * button in self.leaderboardButtons) {
            if (CGRectContainsPoint( button.frame, location)) {
                BTTGameInfo *gameInfo = [BTTGameInfo sharedBCTGameInfo];
                gameInfo.currentLeaderboard = [self.leaderboards objectAtIndex:index];
                SKScene *scene = [BTTLeaderboardScoresScreen sceneWithSize:self.view.bounds.size];
                scene.scaleMode = SKSceneScaleModeAspectFill;
                
                SKTransition *transition = [SKTransition moveInWithDirection:SKTransitionDirectionUp duration:0.5];
                
                [self.view presentScene:scene transition:transition];

            }
            index++;
        }
    }
}

@end



@interface BTTLeaderboardSetsScreen ()

@property (nonatomic, retain) SKLabelNode *backButton;
@property (nonatomic, retain) NSArray *leaderboardSets;
@property (nonatomic, retain) NSArray *leaderboardSetButtons;

@end

@implementation BTTLeaderboardSetsScreen

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        SKLabelNode *title = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        title.text = @"Leaderboards Sets";
        title.fontSize = 30;
        title.position = CGPointMake(CGRectGetMidX (self.frame),
                                     CGRectGetMidY (self.frame) + 200);
        
        _backButton = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        _backButton.text = @"Back";
        _backButton.fontSize = 18;
        _backButton.fontColor = [self buttonColor];
        _backButton.position = CGPointMake(CGRectGetMidX (self.frame),
                                           CGRectGetMidY (self.frame) - 200);
        
        [self loadLeaderboardSetInfo];
        
        [self addChild:title];
        [self addChild:_backButton];
    }
    return self;
}

- (void)loadLeaderboardSetInfo
{
    [GKLeaderboardSet loadLeaderboardSetsWithCompletionHandler:^(NSArray *leaderboardSets, NSError *error) {
        self.leaderboardSets = leaderboardSets;
        
        NSInteger offset = 0;
        NSMutableArray *buttons = [[NSMutableArray alloc] init];
        
        for (GKLeaderboard *leaderboardSet in leaderboardSets) {
            SKLabelNode *leaderboardSetButton = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
            leaderboardSetButton.text = leaderboardSet.title;
            leaderboardSetButton.fontSize = 18;
            leaderboardSetButton.position = CGPointMake(CGRectGetMidX(self.frame),
                                                        CGRectGetMidY(self.frame) + 125 - offset);
            offset += 50;
            
            [self addChild:leaderboardSetButton];
            [buttons addObject:leaderboardSetButton];
        }
        self.leaderboardSetButtons = [NSArray arrayWithArray:buttons];
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        if (CGRectContainsPoint(self.backButton.frame, location)) {
            SKScene *scene = [BTTStatsScreen sceneWithSize:self.view.bounds.size];
            scene.scaleMode = SKSceneScaleModeAspectFill;
            
            SKTransition *transition = [SKTransition moveInWithDirection:SKTransitionDirectionUp duration:0.5];
            
            [self.view presentScene:scene transition:transition];
        }
        NSInteger i = 0;
        for (SKLabelNode * button in self.leaderboardSetButtons) {
            if (CGRectContainsPoint( button.frame, location)) {
                BTTGameInfo *gameInfo = [BTTGameInfo sharedBCTGameInfo];
                
                gameInfo.currentSet = [self.leaderboardSets objectAtIndex:i];
                SKScene *scene = [BTTLeaderboardsScreen sceneWithSize:self.view.bounds.size];
                scene.scaleMode = SKSceneScaleModeAspectFill;
                
                SKTransition *transition = [SKTransition moveInWithDirection:SKTransitionDirectionUp duration:0.5];
                
                [self.view presentScene:scene transition:transition];

            }
            i++;
        }
    }
}

@end









