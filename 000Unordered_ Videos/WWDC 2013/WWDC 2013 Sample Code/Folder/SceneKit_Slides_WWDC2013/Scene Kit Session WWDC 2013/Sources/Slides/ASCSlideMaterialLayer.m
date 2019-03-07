/*
     File: ASCSlideMaterialLayer.m
 Abstract:  "Material layer" slide. 
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

#import "ASCPresentationViewController.h"
#import "ASCSlideTextManager.h"
#import "ASCSlide.h"
#import "Utils.h"
#import <GLKit/GLKMath.h>
#import <AVFoundation/AVFoundation.h>

@interface ASCSlideMaterialLayer : ASCSlide
@end

@implementation ASCSlideMaterialLayer {
    AVPlayerLayer *_layer1;
    AVPlayerLayer *_layer2;
}

- (void)dealloc {
    //stop observing AVFoundation
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//let's use 2 steps
- (NSUInteger)numberOfSteps {
    return 2;
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentation {
    //retrieve the text manager
    ASCSlideTextManager *textManager = [self textManager];
    
    //add some text and code
    [textManager setTitle:@"Materials"];
    [textManager setSubtitle:@"CALayer as texture"];
    
    [textManager addCode:@"// Map a layer tree on a 3D object."];
    [textManager addCode:@"aNode.geometry.firstMaterial.diffuse.#contents# = #aLayerTree#;"];
    
    //create a node
    SCNNode *intermediateNode = [SCNNode node];
    
    //place it
    intermediateNode.position = SCNVector3Make(0, 3.9, 8);
    
    //rotate 90 degree on the X axis because the model we are going to load uses the Z axis as the up axis
    intermediateNode.rotation = SCNVector4Make(1, 0, 0, -M_PI/2);
    
    //add this node to the slide
    [self.ground addChildNode:intermediateNode];
    
    //load the model named "frames" and add as a child of "intermediateNode"
    //rescale to fit in a 8x8x8 unit box
    [intermediateNode asc_addChildNodeNamed:@"frames" fromSceneNamed:@"frames" withScale:8];
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)controller {
    switch (index) {
        case 0:
            //initial state: use a narrow spot light
            [controller narrowSpotlight:YES];
            break;
        case 1:
        {
            //animate
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];

            //change the point of view to "frameCamera" (a camera defined in the "frame" scene)
            SCNNode *frameCamera = [self.rootNode childNodeWithName:@"frameCamera" recursively:YES];
            controller.view.pointOfView = frameCamera;
            
            //the scene "frame" contains some animations
            //update the end time of our main scene and start to play the animations
            [((SCNView *)controller.view).scene setAttribute:@7.33 forKey:SCNSceneEndTimeAttributeKey];
            controller.view.currentTime = 0;
            controller.view.playing = YES;
            controller.view.loops = YES;
            
            //load movies and setup movie layers
            NSURL *url = [[NSBundle mainBundle] URLForResource:@"movie1" withExtension:@"mov"];
            AVPlayer *player1 = [AVPlayer playerWithURL:url];
            _layer1 = [[AVPlayerLayer alloc] init];
            [_layer1 setPlayer:player1];
            _layer1.videoGravity = AVLayerVideoGravityResizeAspectFill;
            
            //play
            [player1 play];
            
            //set an arbitrary frame.
            //This frame will be the size of our movie texture
            //so if it is too small, it will appear scaled up and blurry
            //if it is too big it will be slow
            _layer1.frame = CGRectMake(0,0,600,800);
            
            //use a parent layer with a background color set to black
            //this will prevent from having a hole while the loading is moving (and so rendering as a transparent frame)
            CALayer *bgLayer = [CALayer layer];
            CGColorRef color = CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1);
            [bgLayer setBackgroundColor:color];
            [bgLayer setFrame:CGRectMake(0,0,600,800)];
            [bgLayer addSublayer:_layer1];
            
            //set the bgLayer as the contents of one of our photo frame
            SCNNode *frame = [self.ground childNodeWithName:@"PhotoFrame-Vertical" recursively:YES];
            ((SCNMaterial*)frame.geometry.materials[1]).diffuse.contents = bgLayer;
            
            //Same with 2nd movie
            url = [[NSBundle mainBundle] URLForResource:@"movie2" withExtension:@"mov"];
            AVPlayer *player2 = [AVPlayer playerWithURL:url];
            _layer2 = [[AVPlayerLayer alloc] init];
            [_layer2 setPlayer:player2];
            [player2 play];
            
            _layer2.frame = CGRectMake(0,0,800,600);
            
            bgLayer = [CALayer layer];
            [bgLayer setBackgroundColor:color];
            [bgLayer setFrame:CGRectMake(0,0,800,600)];
            [bgLayer addSublayer:_layer2];
            CFRelease(color);
            
            frame = [self.ground childNodeWithName:@"PhotoFrame-Horizontal" recursively:YES];
            ((SCNMaterial *)frame.geometry.materials[1]).diffuse.contents = bgLayer;
            
            //loop
            player1.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            player2.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:[player1 currentItem]];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:[player2 currentItem]];
            
            [SCNTransaction commit];
            break;
        }
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

- (void)orderOutWithPresentionViewController:(ASCPresentationViewController *)controller {
    //before leaving this frame
    //make sure to stop playing the movie
    [_layer1.player pause];
    [_layer2.player pause];

    [_layer1 setPlayer:nil];
    [_layer2 setPlayer:nil];

    //stop playing scene animations
    controller.view.playing = NO;
    
    //restore the original point of view
    controller.view.pointOfView = controller.cameraNode;
    
    //restore default spot light mode
    [controller narrowSpotlight:NO];
}

@end
