/*
     File: TTTPlayViewController.m
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

#import "TTTPlayViewController.h"

#import "TTTGame.h"
#import "TTTGameView.h"
#import "TTTProfile.h"

@interface TTTPlayViewController () <TTTGameViewDelegate>
@property (strong, nonatomic) TTTProfile *profile;
@property (copy, nonatomic) NSURL *profileURL;
@end

@implementation TTTPlayViewController {
    TTTGameView *_gameView;
}

+ (UIViewController *)viewControllerWithProfile:(TTTProfile *)profile profileURL:(NSURL *)profileURL;
{
    TTTPlayViewController *controller = [[self alloc] init];
    controller.profile = profile;
    controller.profileURL = profileURL;
    return controller;
}

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = NSLocalizedString(@"Play", @"Play");
        self.tabBarItem.image = [UIImage imageNamed:@"playTab"];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"playTabSelected"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iconDidChange:) name:TTTProfileIconDidChangeNotification object:nil];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [self init];
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

static CGFloat const TTTPlayViewControllerMargin = 20.0;

- (void)loadView
{
    UIView *view = [[UIView alloc] init];
    
    UIButton *newButton = [UIButton buttonWithType:UIButtonTypeSystem];
    newButton.translatesAutoresizingMaskIntoConstraints = NO;
    newButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [newButton setTitle:NSLocalizedString(@"New Game", @"New Game") forState:UIControlStateNormal];
    newButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [newButton addTarget:self action:@selector(newGame:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:newButton];
    
    UIButton *pauseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    pauseButton.translatesAutoresizingMaskIntoConstraints = NO;
    pauseButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [pauseButton setTitle:NSLocalizedString(@"Pause", @"Pause") forState:UIControlStateNormal];
    pauseButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [pauseButton addTarget:self action:@selector(togglePause:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:pauseButton];
    
    _gameView = [[TTTGameView alloc] init];
    _gameView.delegate = self;
    _gameView.translatesAutoresizingMaskIntoConstraints = NO;
    _gameView.game = self.profile.currentGame;
    [view addSubview:_gameView];
    
    CGFloat topHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    UITabBar *tabBar = self.tabBarController.tabBar;
    CGFloat bottomHeight = (tabBar.translucent ? tabBar.frame.size.height : 0.0);
    NSDictionary *metrics = @{@"topHeight" : @(topHeight + TTTPlayViewControllerMargin), @"bottomHeight" : @(bottomHeight + TTTPlayViewControllerMargin), @"margin" : @(TTTPlayViewControllerMargin)};
    NSDictionary *bindings = NSDictionaryOfVariableBindings(newButton, pauseButton, _gameView);
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-margin-[_gameView]-margin-|" options:0 metrics:metrics views:bindings]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-margin-[pauseButton(==newButton)]-[newButton]-margin-|" options:0 metrics:metrics views:bindings]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topHeight-[_gameView]-margin-[newButton]-bottomHeight-|" options:0 metrics:metrics views:bindings]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:pauseButton attribute:NSLayoutAttributeBaseline relatedBy:NSLayoutRelationEqual toItem:newButton attribute:NSLayoutAttributeBaseline multiplier:1.0 constant:0.0]];
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateBackground];
}

- (void)saveProfile
{
    [self.profile writeToURL:self.profileURL];
}

- (void)newGame:(UIButton *)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        _gameView.game = [self.profile startNewGame];
        [self saveProfile];
        [self updateBackground];
    }];
}

- (void)togglePause:(UIButton *)sender
{
    BOOL paused = sender.selected;
    paused = !paused;
    sender.selected = paused;
    _gameView.userInteractionEnabled = !paused;
    [UIView animateWithDuration:0.3 animations:^{
        _gameView.alpha = (paused ? 0.25 : 1.0);
    }];
}

#pragma mark - Game View

- (UIImage *)gameView:(TTTGameView *)gameView imageForPlayer:(TTTMovePlayer)player
{
    return [self.profile imageForPlayer:player];
}

- (UIColor *)gameView:(TTTGameView *)gameView colorForPlayer:(TTTMovePlayer)player
{
    return [self.profile colorForPlayer:player];
}

- (BOOL)gameView:(TTTGameView *)gameView canSelectXPosition:(TTTMoveXPosition)xPosition yPosition:(TTTMoveYPosition)yPosition
{
    return [gameView.game canAddMoveWithXPosition:xPosition yPosition:yPosition];
}

- (void)gameView:(TTTGameView *)gameView didSelectXPosition:(TTTMoveXPosition)xPosition yPosition:(TTTMoveYPosition)yPosition
{
    [UIView animateWithDuration:0.3 animations:^{
        [gameView.game addMoveWithXPosition:xPosition yPosition:yPosition];
        [gameView updateGameState];
        [self saveProfile];
        [self updateBackground];
    }];
}

- (void)iconDidChange:(NSNotification *)notification
{
    [_gameView updateGameState];
}

- (BOOL)isOver
{
    return (_gameView.game.result != TTTGameResultInProgess);
}

- (void)updateBackground
{
    BOOL isOver = [self isOver];
    _gameView.gridColor = (isOver ? [UIColor whiteColor] : [UIColor blackColor]);
    self.view.backgroundColor = [(isOver ? [UIColor blackColor] : [UIColor whiteColor]) colorWithAlphaComponent:0.75];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return ([self isOver] ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault);
}

@end
