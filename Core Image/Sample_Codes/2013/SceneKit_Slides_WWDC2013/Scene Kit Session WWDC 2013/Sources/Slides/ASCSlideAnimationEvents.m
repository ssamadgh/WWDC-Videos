/*
     File: ASCSlideAnimationEvents.m
 Abstract: Animation events slide.
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

typedef NS_ENUM(NSInteger, ASCCharacterAnimation) {
	ASCCharacterAnimationAttack = 0,
	ASCCharacterAnimationWalk,
	ASCCharacterAnimationDie,
    ASCCharacterAnimationCount
};

@interface ASCSlideAnimationEvents : ASCSlide
@end

@implementation ASCSlideAnimationEvents {
    SCNNode *_heroSkeletonNode;
    CAAnimation *_animations[ASCCharacterAnimationCount];
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentationViewController {
    // Load the character and add it to the scene
    SCNNode *heroNode = [self.groundNode asc_addChildNodeNamed:@"heroGroup" fromSceneNamed:@"hero" withScale:0.0];
    
    heroNode.scale = SCNVector3Make(0.023, 0.023, 0.023);
    heroNode.position = SCNVector3Make(0.0, 0.0, 15.0);
    heroNode.rotation = SCNVector4Make(1.0, 0.0, 0.0, -M_PI_2);
    
    [self.groundNode addChildNode:heroNode];
    
    // Convert sceneTime-based animations into systemTime-based animations.
    // Animations loaded from DAE files will play according to the `currentTime` property of the scene renderer if this one is playing
    // (see the SCNSceneRenderer protocol). Here we don't play a specific DAE so we want the animations to animate as soon as we add
    // them to the scene (i.e have them to play according the time of the system when the animation was added).
    
    _heroSkeletonNode = [heroNode childNodeWithName:@"skeleton" recursively:YES];
    
    for (NSString *animationKey in _heroSkeletonNode.animationKeys) {
        // Find all the animations. Make them system time based and repeat forever.
        // And finally replace the old animation.
        
        CAAnimation *animation = [_heroSkeletonNode animationForKey:animationKey];
        animation.usesSceneTimeBase = NO;
        animation.repeatCount = FLT_MAX;
        
        [_heroSkeletonNode addAnimation:animation forKey:animationKey];
    }
    
    // Load other animations so that we will use them later
    [self setAnimation:ASCCharacterAnimationAttack withAnimationNamed:@"attackID" fromSceneNamed:@"attack"];
	[self setAnimation:ASCCharacterAnimationDie withAnimationNamed:@"DeathID" fromSceneNamed:@"death"];
	[self setAnimation:ASCCharacterAnimationWalk withAnimationNamed:@"WalkID" fromSceneNamed:@"walk"];
}

- (NSUInteger)numberOfSteps {
    return 5;
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    switch (index) {
        case 0:
        {
            self.textManager.title = @"Animation Events";
            [self.textManager addBullet:@"SCNAnimationEvent" atLevel:0];
            
            [self.textManager addCode:
             @"#SCNAnimationEvent# *anEvent = \n"
             @"  [SCNAnimationEvent #animationEventWithKeyTime:#0.2 #block:#aBlock]; \n"
             @"anAnimation.#animationEvents# = @[anEvent, anotherEvent];"];
            
            // Warm up NSSound by playing an empty sound.
            // Otherwise the first sound may take some time to start playing and will be desynchronised.
            [[NSSound soundNamed:@"emptySound"] play];
            break;
        }
        case 1:
        case 2:
        {
            // Trigger the attack animation
			[_heroSkeletonNode addAnimation:_animations[ASCCharacterAnimationAttack] forKey:@"attack"];
            break;
        }
        case 3:
        {
            // Trigger the walk animation
			[_heroSkeletonNode addAnimation:_animations[ASCCharacterAnimationWalk] forKey:@"walk"];
            break;
        }
        case 4:
        {
            // Trigger the death animation
            // Make sure to remove the "idle" animation and prevent the model from intersecting with the floor.
            
            [_heroSkeletonNode removeAllAnimations];
			[_heroSkeletonNode addAnimation:_animations[ASCCharacterAnimationDie] forKey:@"death"];
            
            [SCNTransaction begin];
            {
                _heroSkeletonNode.parentNode.transform = CATransform3DTranslate(_heroSkeletonNode.parentNode.transform, 0, 0, 40);
            }
            [SCNTransaction commit];
            break;
        }
    }
}

- (void)setAnimation:(ASCCharacterAnimation)index withAnimationNamed:(NSString *)animationName fromSceneNamed:(NSString *)sceneName {
    // Load the DAE using SCNSceneSource in order to be able to retrieve the animation by its identifier
	NSURL *url = [[NSBundle mainBundle] URLForResource:sceneName withExtension:@"dae"];
	SCNSceneSource *sceneSource = [SCNSceneSource sceneSourceWithURL:url options:nil];
    
	CAAnimation *animation = [sceneSource entryWithIdentifier:animationName withClass:[CAAnimation class]];
    _animations[index] = animation;
    
    // Blend animations for smoother transitions
    [animation setFadeInDuration:0.3];
    [animation setFadeOutDuration:0.3];
    
    if (index == ASCCharacterAnimationDie) {
        // We want the "death" animation to remain at its final state at the end of the animation
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeBoth;
        
        // Create animation events and set them to the animation
        SCNAnimationEventBlock swipeSoundEventBlock = ^(CAAnimation *animation, id animatedObject, BOOL playingBackward) {
            [[NSSound soundNamed:@"swipe"] play];
        };
        
        SCNAnimationEventBlock deathSoundEventBlock = ^(CAAnimation *animation, id animatedObject, BOOL playingBackward) {
            [[NSSound soundNamed:@"death"] play];
        };
        
        animation.animationEvents = @[[SCNAnimationEvent animationEventWithKeyTime:0.0 block:swipeSoundEventBlock],
                                      [SCNAnimationEvent animationEventWithKeyTime:0.3 block:deathSoundEventBlock]];
    }
    
    if (index == ASCCharacterAnimationAttack) {
        // Create an animation event and set it to the animation
        SCNAnimationEventBlock swordSoundEventBlock = ^(CAAnimation *animation, id animatedObject, BOOL playingBackward) {
            [[NSSound soundNamed:@"sword"] play];
        };
        
        animation.animationEvents = @[[SCNAnimationEvent animationEventWithKeyTime:0.4 block:swordSoundEventBlock]];
    }
    
    if (index == ASCCharacterAnimationWalk) {
        // Repeat the walk animation 3 times
        animation.repeatCount = 3;
        
        // Create an animation event and set it to the animation
        SCNAnimationEventBlock stepSoundEventBlock = ^(CAAnimation *animation, id animatedObject, BOOL playingBackward) {
            [[NSSound soundNamed:@"walk"] play];
        };
        
        animation.animationEvents = @[[SCNAnimationEvent animationEventWithKeyTime:0.2 block:stepSoundEventBlock],
                                      [SCNAnimationEvent animationEventWithKeyTime:0.7 block:stepSoundEventBlock]];
    }
}

@end
