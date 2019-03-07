/*
     File: TTTGameHistoryViewController.m
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

#import "TTTGameHistoryViewController.h"

#import "TTTGame.h"
#import "TTTGameView.h"
#import "TTTProfile.h"
#import "TTTRatingControl.h"

@interface TTTGameHistoryViewController () <TTTGameViewDelegate>
@end

@implementation TTTGameHistoryViewController {
    TTTGameView *_gameView;
    TTTRatingControl *_ratingControl;
}

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = NSLocalizedString(@"Game", @"Game");
        
        _ratingControl = [[TTTRatingControl alloc] initWithFrame:CGRectMake(0.0, 0.0, 30.0 * 5, 30.0)];
        [_ratingControl addTarget:self action:@selector(changeRating:) forControlEvents:UIControlEventValueChanged];
        self.navigationItem.titleView = _ratingControl;
        
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
    view.backgroundColor = [UIColor whiteColor];
    
    TTTGameView *gameView = [[TTTGameView alloc] init];
    gameView.delegate = self;
    gameView.userInteractionEnabled = NO;
    gameView.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:gameView];
    _gameView = gameView;
    _gameView.game = self.game;
    
    CGFloat topHeight = [[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.frame.size.height;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(gameView);
    NSDictionary *metrics = @{@"topHeight" : @(topHeight + TTTPlayViewControllerMargin), @"bottomHeight" : @(TTTPlayViewControllerMargin), @"margin" : @(TTTPlayViewControllerMargin)};
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-margin-[gameView]-margin-|" options:0 metrics:metrics views:bindings]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topHeight-[gameView]-bottomHeight-|" options:0 metrics:metrics views:bindings]];
    
    self.view = view;
}

- (void)setGame:(TTTGame *)value
{
    if (_game != value) {
        _game = value;
        _gameView.game = _game;
        _ratingControl.rating = _game.rating;
    }
}

- (void)changeRating:(TTTRatingControl *)sender
{
    self.game.rating = sender.rating;
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

- (void)iconDidChange:(NSNotification *)notification
{
    [_gameView updateGameState];
}

@end
