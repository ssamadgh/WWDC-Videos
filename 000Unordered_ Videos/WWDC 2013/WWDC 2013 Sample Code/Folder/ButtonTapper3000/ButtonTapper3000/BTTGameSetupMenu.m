/*
     File: BTTGameSetupMenu.m
 Abstract: Menu to allow the user to select the paramerters for the game they would like to play.
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

#import "BTTGameSetupMenu.h"
#import "BTTMainGame.h"
#import "BTTMainMenu.h"

#import "BTTGameInfo.h"


@interface BTTGameSetupMenu ()

@property (nonatomic, retain) NSArray *timeLabels;
@property (nonatomic, retain) NSArray *modeLabels;
@property (nonatomic, retain) SKLabelNode *startButton;
@property (nonatomic, retain) SKLabelNode *backButton;

@end


@implementation BTTGameSetupMenu

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        SKLabelNode *timeLabel = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        timeLabel.text = @"Time:";
        timeLabel.fontSize = 24;
        timeLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                         CGRectGetMidY(self.frame) + 70);
        
        SKLabelNode *time15Button = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        time15Button.text = @"15";
        time15Button.fontSize = 14;
        time15Button.fontColor = [self unselectedColor];
        time15Button.position = CGPointMake(CGRectGetMidX(self.frame) - 40,
                                      CGRectGetMidY(self.frame) + 40);
        
        SKLabelNode *time30Button = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        time30Button.text = @"30";
        time30Button.fontSize = 14;
        time30Button.fontColor = [self unselectedColor];
        time30Button.position = CGPointMake(CGRectGetMidX(self.frame),
                                      CGRectGetMidY(self.frame) + 40);
        
        SKLabelNode *time45Button = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        time45Button.text = @"45";
        time45Button.fontSize = 14;
        time45Button.fontColor = [self unselectedColor];
        time45Button.position = CGPointMake(CGRectGetMidX(self.frame) + 40,
                                      CGRectGetMidY(self.frame) + 40);
        
        _timeLabels = @[time15Button, time30Button, time45Button];
        
        SKLabelNode *modeLabel = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        modeLabel.text = @"Mode:";
        modeLabel.fontSize = 24;
        modeLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                         CGRectGetMidY(self.frame));
        
        SKLabelNode *modeEasyButton = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        modeEasyButton.text = @"Easy";
        modeEasyButton.fontSize = 14;
        modeEasyButton.fontColor = [self unselectedColor];
        modeEasyButton.position = CGPointMake(CGRectGetMidX(self.frame) - 40,
                                        CGRectGetMidY(self.frame) - 40);
        
        SKLabelNode *modeHardButton = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        modeHardButton.text = @"Hard";
        modeHardButton.fontSize = 14;
        modeHardButton.fontColor = [self unselectedColor];
        modeHardButton.position = CGPointMake(CGRectGetMidX(self.frame) + 40,
                                        CGRectGetMidY(self.frame) - 40);
        
        _modeLabels = @[modeEasyButton, modeHardButton];
        
        _startButton = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        _startButton.text = @"Start!";
        _startButton.fontSize = 30;
        _startButton.fontColor = [self buttonColor];
        _startButton.position = CGPointMake(CGRectGetMidX(self.frame),
                                            CGRectGetMidY(self.frame) - 100);
        
        _backButton = [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
        _backButton.text = @"Back";
        _backButton.fontSize = 18;
        _backButton.fontColor = [self buttonColor];
        _backButton.position = CGPointMake(CGRectGetMidX(self.frame),
                                            CGRectGetMidY(self.frame) - 200);
        
        BTTGameInfo *gameInfo = [BTTGameInfo sharedBCTGameInfo];
        
        ((SKLabelNode *) _timeLabels[gameInfo.gameTime]).fontColor = [self selectedColor];
        ((SKLabelNode *) _modeLabels[gameInfo.gameMode]).fontColor = [self selectedColor];
        
        [gameInfo resetGame];
        
        [self addChild:timeLabel];
        [self addChild:time15Button];
        [self addChild:time30Button];
        [self addChild:time45Button];
        [self addChild:modeLabel];
        [self addChild:modeEasyButton];
        [self addChild:modeHardButton];
        [self addChild:_startButton];
        [self addChild:_backButton];
    }
    return self;
}

- (void)selectTime:(BTTGameTime)time
{
    BTTGameInfo *gameInfo = [BTTGameInfo sharedBCTGameInfo];
    
    ((SKLabelNode *) _timeLabels[gameInfo.gameTime]).fontColor = [self unselectedColor];
    gameInfo.gameTime = time;
    ((SKLabelNode *) _timeLabels[gameInfo.gameTime]).fontColor = [self selectedColor];
}

- (void)selectMode:(BTTGameMode)mode
{
    BTTGameInfo *gameInfo = [BTTGameInfo sharedBCTGameInfo];
    
    ((SKLabelNode *) _modeLabels[gameInfo.gameMode]).fontColor = [self unselectedColor];
    gameInfo.gameMode = mode;
    ((SKLabelNode *) _modeLabels[gameInfo.gameMode]).fontColor = [self selectedColor];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        NSInteger i;
        
        for (i = 0; i < BTTGameTimeMax; i++) {
            if (CGRectContainsPoint(((SKLabelNode *) self.timeLabels[i]).frame, location)) {
                [self selectTime:i];
            }
        }
        
        for (i = 0; i < BTTGameModeMax; i++) {
            if (CGRectContainsPoint(((SKLabelNode *) self.modeLabels[i]).frame, location)) {
                [self selectMode:i];
            }
        }
        if (CGRectContainsPoint(self.startButton.frame, location)) {
            SKScene *scene = [BTTMainGame sceneWithSize:self.view.bounds.size];
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

- (void)update:(CFTimeInterval)currentTime {
}

@end
