/*
     File: ASCSlideMaterialLayer.m
 Abstract: Illustrates how instances of CALayer can be used with material properties.
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
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#import "ASCPresentationViewController.h"
#import "ASCSlideTextManager.h"
#import "ASCSlide.h"
#import "Utils.h"
#import <GLKit/GLKMath.h>
#import <AVFoundation/AVFoundation.h>

@interface ASCSlideMaterialLayer : ASCSlide
@end

@implementation ASCSlideMaterialLayer {
    AVPlayerLayer *_playerLayer1;
    AVPlayerLayer *_playerLayer2;
}

- (NSUInteger)numberOfSteps {
    return 2;
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    switch (index) {
        case 0:
        {
            // Set the slide's title and subtitle and add some text
            self.textManager.title = @"Materials";
            self.textManager.subtitle = @"CALayer as texture";
            
            [self.textManager addCode:
             @"// Map a layer tree on a 3D object. \n"
             @"aNode.geometry.firstMaterial.diffuse.#contents# = #aLayerTree#;"];
            
            // Add the model
            SCNNode *intermediateNode = [SCNNode node];
            intermediateNode.position = SCNVector3Make(0, 3.9, 8);
            intermediateNode.rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
            [self.groundNode addChildNode:intermediateNode];
            [intermediateNode asc_addChildNodeNamed:@"frames" fromSceneNamed:@"frames" withScale:8];
            
            [presentationViewController narrowSpotlight:YES];
            break;
        }
        case 1:
        {
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                // Change the point of view to "frameCamera" (a camera defined in the "frames" scene)
                SCNNode *frameCamera = [self.contentNode childNodeWithName:@"frameCamera" recursively:YES];
                presentationViewController.view.pointOfView = frameCamera;
                
                // The "frames" scene contains animations, update the end time of our main scene and start to play the animations
                [presentationViewController.view.scene setAttribute:@7.33 forKey:SCNSceneEndTimeAttributeKey];
                presentationViewController.view.currentTime = 0;
                presentationViewController.view.playing = YES;
                presentationViewController.view.loops = YES;
                
                // Load movies and display movie layers
                AVPlayerLayer * (^configurePlayer)(NSURL *, NSString *) = ^(NSURL *movieURL, NSString *hostingNodeName) {
                    AVPlayer *player = [AVPlayer playerWithURL:movieURL];
                    player.actionAtItemEnd = AVPlayerActionAtItemEndNone; // loop
                    
                    [[NSNotificationCenter defaultCenter] addObserver:self
                                                             selector:@selector(playerItemDidReachEnd:)
                                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                                               object:player.currentItem];
                    
                    [player play];
                    
                    // Set an arbitrary frame. This frame will be the size of our movie texture so if it is too small it will appear scaled up and blurry, and if it is too big it will be slow
                    AVPlayerLayer *playerLayer = [[AVPlayerLayer alloc] init];
                    playerLayer.player = player;
                    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                    playerLayer.frame = CGRectMake(0,0,600,800);
                    
                    // Use a parent layer with a background color set to black
                    // That way if the movie is stil loading and the frame is transparent, we won't see holes in the model
                    CALayer *backgroundLayer = [CALayer layer];
                    backgroundLayer.backgroundColor = CGColorGetConstantColor(kCGColorBlack);
                    backgroundLayer.frame = CGRectMake(0, 0, 600, 800);
                    [backgroundLayer addSublayer:playerLayer];
                    
                    SCNNode *frameNode = [self.groundNode childNodeWithName:hostingNodeName recursively:YES];
                    SCNMaterial *material = frameNode.geometry.materials[1];
                    material.diffuse.contents = backgroundLayer;
 
                    return playerLayer;
                };
            
                _playerLayer1 = configurePlayer([[NSBundle mainBundle] URLForResource:@"movie1" withExtension:@"mov"], @"PhotoFrame-Vertical");
                _playerLayer2 = configurePlayer([[NSBundle mainBundle] URLForResource:@"movie2" withExtension:@"mov"], @"PhotoFrame-Horizontal");
            
            }
            [SCNTransaction commit];
            break;
        }
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *playerItem = notification.object;
    [playerItem seekToTime:kCMTimeZero];
}

- (void)willOrderOutWithPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerLayer1.player.currentItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerLayer2.player.currentItem];
    
    [_playerLayer1.player pause];
    [_playerLayer2.player pause];
    
    _playerLayer1.player = nil;
    _playerLayer2.player = nil;
    
    // Stop playing scene animations, restore the original point of view and restore the default spot light mode
    presentationViewController.view.playing = NO;
    presentationViewController.view.pointOfView = presentationViewController.cameraNode;
    [presentationViewController narrowSpotlight:NO];
}

@end
