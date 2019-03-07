/*
     File: ASCSlideAnimationEvents.m
 Abstract:  Animation events slide. 
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

typedef NS_ENUM(NSInteger, ASCCharacterAnimation) {
	ASCCharacterAnimationAttack = 0,
	ASCCharacterAnimationWalk,
	ASCCharacterAnimationDie,
    ASCCharacterAnimationCount
};

@interface ASCSlideAnimationEvents : ASCSlide
@end

@implementation ASCSlideAnimationEvents {
    CAAnimation *_animations[ASCCharacterAnimationCount];
}

SCNAnimationEventBlock deathSound = ^(CAAnimation *animation, id owner, BOOL bw) {
    [[NSSound soundNamed:@"death"] play];
};

SCNAnimationEventBlock swordSound = ^(CAAnimation *animation, id owner, BOOL bw) {
    [[NSSound soundNamed:@"sword"] play];
};

SCNAnimationEventBlock stepSound = ^(CAAnimation *animation, id owner, BOOL bw) {
    [[NSSound soundNamed:@"walk"] play];
};

SCNAnimationEventBlock swipeSound = ^(CAAnimation *animation, id owner, BOOL bw) {
    [[NSSound soundNamed:@"swipe"] play];
};

//load an animation identified by "identifier" from a dae referenced by "dae"
//add the animation in to the animation array at index "index"
- (void)loadAnimation:(NSString *)path identifier:(NSString *)identifier index:(ASCCharacterAnimation)index {
    //load the DAE using SCNSceneSource to be able to retrieve animation by identifiers
	path = [[NSBundle mainBundle] pathForResource:path ofType:@"dae"];
	
	SCNSceneSource *source = [SCNSceneSource sceneSourceWithURL:[NSURL fileURLWithPath:path] options:nil];
    
    //search for the animation
	CAAnimation *animation = [source entryWithIdentifier:identifier withClass:[CAAnimation class]];
    
    //add to the animation array
    _animations[index] = animation;
    
    if (index == ASCCharacterAnimationDie) {
        //we want the "death" animation to remain at its final state at the end of the animation
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeBoth;
        
        //add the events to trigger
        animation.animationEvents = @[[SCNAnimationEvent animationEventWithKeyTime:0.0 block:swipeSound],
                                      [SCNAnimationEvent animationEventWithKeyTime:0.3 block:deathSound]];
    }
    
    if (index == ASCCharacterAnimationAttack) {
        //add the event to trigger forthe attack animation
        animation.animationEvents = @[[SCNAnimationEvent animationEventWithKeyTime:0.4 block:swordSound]];
    }
    
    if (index == ASCCharacterAnimationWalk) {
        animation.repeatCount = 3; //repeat the walk animation 3 times
        
        //add the events to trigger
        animation.animationEvents = @[[SCNAnimationEvent animationEventWithKeyTime:0.2 block:stepSound],
                                      [SCNAnimationEvent animationEventWithKeyTime:0.7 block:stepSound]];
    }
    
    //blend animation for smoother transition
    [_animations[index] setFadeInDuration:0.3];
    [_animations[index] setFadeOutDuration:0.3];
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentation {
    //retrieve the text manager
    ASCSlideTextManager *textManager = [self textManager];
    
    //add some text
    [textManager setTitle:@"Animation Events"];
    [textManager addBullet:@"SCNAnimationEvent" atLevel:0];
    [textManager addCode:@"#SCNAnimationEvent# *anEvent ="];
    [textManager addCode:@"  [SCNAnimationEvent #animationEventWithKeyTime:#0.2 #block:#aBlock];"];
    
    [textManager addCode:@"anAnimation.#animationEvents# = @[anEvent, anotherEvent];"];
    
    /* add the character */
#define SCALE 0.023

    //create a node that will own the character
    SCNNode *intermediateNode = [SCNNode node];
    
    //scale, orient and place it
    intermediateNode.scale = SCNVector3Make(SCALE, SCALE, SCALE);
    intermediateNode.position = SCNVector3Make(0, 0, 15);
    intermediateNode.rotation = SCNVector4Make(1, 0, 0, -M_PI/2);
    
    //add tothe scene
    [self.ground addChildNode:intermediateNode];
    
    //load the character
    SCNNode *heroGroup =[intermediateNode asc_addChildNodeNamed:@"heroGroup" fromSceneNamed:@"hero" withScale:0];
    SCNNode *skell = [heroGroup childNodeWithName:@"skell" recursively:YES];
    
    /* convert sceneTime-based animations into systemTime-based animations:
     animations loaded from DAE files will play according to the "currentTime" of the renderer if this one is playing.
     Here we don't play a specific DAE so we want the animation to animate as soon as we add them to the scene graph
     (i.e have them to play according the time of the system when the animation was added */
    for (NSString *key in [skell animationKeys]) { //for every animation keys
        CAAnimation *animation = [skell animationForKey:key]; //get the animation
        
        animation.usesSceneTimeBase = NO; //make it systemTime based
        animation.repeatCount = FLT_MAX; //repeat forever

        [skell addAnimation:animation forKey:key]; //replace the previous animation
    }

    //load the animations
    [self loadAnimation:@"attack" identifier:@"attackID" index:ASCCharacterAnimationAttack];
	[self loadAnimation:@"death" identifier:@"DeathID" index:ASCCharacterAnimationDie];
	[self loadAnimation:@"walk" identifier:@"WalkID" index:ASCCharacterAnimationWalk];
}

- (NSUInteger)numberOfSteps {
    return 5;
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)controller {
    switch (index) {
        case 0:
            /*preload NSSound by playing an empty sound
             otherwise the first sound may takes time to play and will be desynchronised */
            [[NSSound soundNamed:@"emptySound"] play];
            break;
        case 1:
        case 2:
        {
            // trigger the attack animation
            SCNNode *skell = [self.ground childNodeWithName:@"skell" recursively:YES];
			[skell addAnimation:_animations[ASCCharacterAnimationAttack] forKey:@"attack"];
        }
            break;
        case 3:
        {
            // trigger the walk animation
            SCNNode *skell = [self.ground childNodeWithName:@"skell" recursively:YES];
			[skell addAnimation:_animations[ASCCharacterAnimationWalk] forKey:@"walk"];
        }
            break;
        case 4:
        {
            // trigger the death animation
            SCNNode *skell = [self.ground childNodeWithName:@"skell" recursively:YES];
            [skell removeAllAnimations]; //remove the idle animation
			[skell addAnimation:_animations[ASCCharacterAnimationDie] forKey:@"death"];
            
            //move a little up to prevent to model to intersect with the floor too much
            [SCNTransaction begin];
            skell.parentNode.position = SCNVector3Make(0, -40, 0);
            [SCNTransaction commit];
        }
            break;
        default:
            break;
    }
}

@end
