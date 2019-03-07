/*
     File: APLAppDelegate.m
 Abstract: n/a
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
 
 */

#import "APLAppDelegate.h"

#import "APLBasicSprites.h"
#import "APLColorizedSprites.h"
#import "APLResizingSprites.h"
#import "APLSpriteAnchors.h"
#import "APLBlendingSprites.h"
#import "APLAnimatingSprites.h"


@interface APLAppDelegate ()

@property IBOutlet NSWindow *window;
@property (weak) IBOutlet SKView *skView;
@property (weak) IBOutlet NSMatrix *buttonMatrix;

@end


@implementation APLAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.skView.showsFPS = YES;
    self.skView.showsNodeCount = YES;
    self.skView.showsDrawCount = YES;

    NSInteger selectedIndex = [self.buttonMatrix selectedColumn];
    [self presentSceneAtIndex:selectedIndex];
}


- (IBAction)takeSceneIndexFrom:(id)sender
{
    NSInteger selectedIndex = [self.buttonMatrix selectedColumn];
    [self presentSceneAtIndex:selectedIndex];
}


- (void)presentSceneAtIndex:(NSInteger)index
{
    /* Pick a size for the scene */
    CGSize size = CGSizeMake(1024, 768);

    SKScene *scene;

    switch (index) {
        case 0:
            scene = [APLBasicSprites sceneWithSize:size];
            break;

        case 1:
            scene = [APLColorizedSprites sceneWithSize:size];
            break;

        case 2:
            scene = [APLResizingSprites sceneWithSize:size];
            break;

        case 3:
            scene = [APLSpriteAnchors sceneWithSize:size];
            break;

        case 4:
            scene = [APLBlendingSprites sceneWithSize:size];
            break;

        case 5:
            scene = [APLAnimatingSprites sceneWithSize:size];
            break;

        default:
            break;
    }

    /* Set the scale mode to scale to fit the window */
    scene.scaleMode = SKSceneScaleModeAspectFit;
    [self.skView presentScene:scene];
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

@end
