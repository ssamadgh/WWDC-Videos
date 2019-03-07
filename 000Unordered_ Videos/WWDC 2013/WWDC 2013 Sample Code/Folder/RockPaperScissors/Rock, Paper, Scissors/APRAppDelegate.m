/*
     File: APRAppDelegate.m
 Abstract: App Delegate, Game Center View Controllers are displayed from here.
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

#import "APRAppDelegate.h"
#import "APRScene.h"
#import <GameKit/GameKit.h>

@interface APRAppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet SKView *skView;
@property (weak) IBOutlet NSTextField *statusField;
@property (weak) IBOutlet NSTextField *p1scoreField;
@property (weak) IBOutlet NSTextField *p2scoreField;
@property (nonatomic, strong)   GKTurnBasedMatch *match;
@property (nonatomic) APRScene *scene;

@end

@implementation APRAppDelegate

#pragma mark - Application Lifecycle
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self.skView setWantsLayer:YES];
    
    /* Pick a size for the scene */
    APRScene *scene = [APRScene sceneWithSize:CGSizeMake(1024, 768)];
    
    /* Set the scale mode to scale to fit the window */
    scene.scaleMode = SKSceneScaleModeAspectFit;
    
    [self.skView presentScene:scene];
    self.scene = scene;
    
    self.skView.showsFPS = YES;
    self.skView.showsNodeCount = YES;
    
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(authenticationChanged) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
    
    [self authenticateLocalPlayer];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

#pragma mark - Notifications
- (void)authenticationChanged {
    NSLog(@"Authentication Changed!");
}

#pragma mark - Game Center Authentication
- (void)authenticateLocalPlayer {
    [GKDialogController sharedDialogController].parentWindow = self.window;
    
    [GKLocalPlayer localPlayer].authenticateHandler = ^(NSViewController *viewController, NSError *error){
        if (viewController) {
            [[GKDialogController sharedDialogController] presentViewController:(GKGameCenterViewController *)viewController];
        } else if ([GKLocalPlayer localPlayer].isAuthenticated) {
            [self authenticatedPlayer:[GKLocalPlayer localPlayer]];
            [GKTurnBasedEventHandler sharedTurnBasedEventHandler].delegate = self.scene;
        } else {
            [self disableGameCenter];
        }
    };
}

- (void)authenticatedPlayer:(GKPlayer *)player {
    NSLog(@"Authenticated Player!");
    [self startNewGame:nil];
}

- (void) disableGameCenter {
    // We've selected not to use Game Center
}

#pragma mark - Actions
- (IBAction)startNewGame:(id)sender {
    GKMatchRequest *matchRequest = [[GKMatchRequest alloc] init];
    
    static GKTurnBasedMatchmakerViewController *matchmakerController = nil;
    
    matchRequest.minPlayers = 2;
    matchRequest.defaultNumberOfPlayers = 2;
    matchRequest.maxPlayers = 2;
    if (!matchmakerController) {
        matchmakerController = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:matchRequest];
    }
    matchmakerController.showExistingMatches = YES;
	matchmakerController.turnBasedMatchmakerDelegate = self;
	[[GKDialogController sharedDialogController] presentViewController:matchmakerController];
}

#pragma mark - Game Center Controller Delegate
- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
    GKDialogController *sdc = [GKDialogController sharedDialogController];
    [sdc dismiss: self];
}

#pragma mark - Turn-Based Matchmaker View Controller Delegate
// The user has cancelled
- (void)turnBasedMatchmakerViewControllerWasCancelled:(GKTurnBasedMatchmakerViewController *)viewController {
    [[GKDialogController sharedDialogController] dismiss:viewController];
}

// Matchmaking has failed with an error
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    NSLog(@"%s:%d - %@", __FUNCTION__, __LINE__, error);
}

// A turned-based match has been found, the game should start
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFindMatch:(GKTurnBasedMatch *)match {
    GKDialogController *sdc = [GKDialogController sharedDialogController];
    [sdc dismiss:self];
    
    NSLog(@"match found!");
    self.match = match;
    [self.scene startGameWithMatch:match];
}

// Called when a users chooses to quit a match and that player has the current turn.  The developer should call playerQuitInTurnWithOutcome:nextPlayer:matchData:completionHandler: on the match passing in appropriate values.  They can also update matchOutcome for other players as appropriate.
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController playerQuitForMatch:(GKTurnBasedMatch *)match {
    
}

#pragma mark - UI Updates
- (void)setGameScoreForPlayer:(int)player score:(int)score {
    NSTextField *textfield = self.p1scoreField;
    if (player == 2) {
        textfield = self.p2scoreField;
    }
    
    [textfield setStringValue:[NSString localizedStringWithFormat:@"%d", score]];
}

- (void)setGameStatusTo:(NSString *)text {
    [self.statusField setStringValue:text];
}

@end
