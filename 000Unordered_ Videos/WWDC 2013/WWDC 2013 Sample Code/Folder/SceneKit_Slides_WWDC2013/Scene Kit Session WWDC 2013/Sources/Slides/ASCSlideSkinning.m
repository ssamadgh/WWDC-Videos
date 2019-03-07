/*
     File: ASCSlideSkinning.m
 Abstract:  Skinning slide. 
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

@interface ASCSlideSkinning : ASCSlide
@end

@implementation ASCSlideSkinning {
    CAAnimation *_animations[3];
}

/*
 "animationGroup" is a long animation playing 3 successive animations.
 We want to split animationGroup into 3 animations based on the sub time ranges described in the "animations" plist.
 Another option would be to use several DAEs (one per animation)
 */
- (void)splitAnimation:(CAAnimationGroup *) animationGroup {
    NSURL *url = nil;
    
    //load the plist that indicates the time range to use for the sub animations
    url = [[NSBundle mainBundle] URLForResource:@"animations"  withExtension:@"plist"];
    NSDictionary *animationDescriptions = [NSDictionary dictionaryWithContentsOfURL:url];
    
    //get frames
	NSDictionary *idleTimeRange = [animationDescriptions objectForKey:@"idle"];
    CGFloat ti = [[idleTimeRange objectForKey:@"begin"] floatValue];
    CGFloat tf = [[idleTimeRange objectForKey:@"end"] floatValue];
        
    _animations[0] = [CAAnimationGroup animation];
    CAAnimation *animation = [animationGroup copy];
    [animation setTimeOffset:ti];
    [(CAAnimationGroup*)_animations[0] setAnimations:[NSArray arrayWithObject:animation]];
    [_animations[0] setDuration:(tf - ti)];
    [_animations[0] setRepeatCount:FLT_MAX];
    [_animations[0] setAutoreverses:YES];
    
    for (NSUInteger i = 0; i < 2; i++) {
        NSString *key = [NSString stringWithFormat:@"animation%lu", i+1];
        NSDictionary *timeRange = [animationDescriptions objectForKey:key];
        ti = [[timeRange objectForKey:@"begin"] floatValue];
        tf = [[timeRange objectForKey:@"end"] floatValue];
        
        _animations[i+1] = [CAAnimationGroup animation];
        CAAnimation *croppedAnimation = [animationGroup copy];
        [croppedAnimation setTimeOffset:ti];
        [(CAAnimationGroup*)_animations[i+1] setAnimations:[NSArray arrayWithObject:croppedAnimation]];
        [_animations[i+1] setDuration:(tf - ti)];
        [_animations[i+1] setFadeInDuration:0.1];
        [_animations[i+1] setFadeOutDuration:0.5];
    }
}

//recursively assign a shader modifier to nodes
- (void)setShaderModifier:(NSDictionary *)modifier onNode:(SCNNode *)node {
    node.geometry.shaderModifiers = modifier;
    
    for (SCNNode *child in node.childNodes)
        [self setShaderModifier:modifier onNode:child];
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentation {
    //retrieve the text manager and add some text
    ASCSlideTextManager *textManager = [self textManager];
    [textManager setTitle:@"Skinning"];
    [textManager addBullet:@"Animate characters" atLevel:0];
    [textManager addBullet:@"Deform geometries with a skeleton" atLevel:0];
    [textManager addBullet:@"Joints and bones" atLevel:0];

    //create a node that will own the avatar
    SCNNode *intermediateNode = [SCNNode node];
    
    //place it
    intermediateNode.position = SCNVector3Make(5, 0, 12);
    intermediateNode.rotation = SCNVector4Make(0, 1, 0, -M_PI / 8);
    
    //add to slide
    [self.ground addChildNode:intermediateNode];
    
    //load the avatar - use a scene source because we will use it to retrieve some animations
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"skinning" withExtension:@"dae"];
    SCNSceneSource *source = [SCNSceneSource sceneSourceWithURL:url options:nil];
    
    SCNScene *scene = [source sceneWithOptions:nil error:nil];
    
    //retrieve the root of the avatar
    SCNNode *model = [scene.rootNode childNodeWithName:@"avatar_attach" recursively:YES];
    
    //the avatar is huge, scale it down a lot
    float s = 0.004;
    model.scale = SCNVector3Make(s, s, s);
    
    //add to out main scene
    [intermediateNode addChildNode:model];
    
    /* load the animations */
    //retrieve the array of animation IDs contained in the avatar file
    NSArray *animationsID = [source identifiersOfEntriesWithClass:[CAAnimation class]];

    NSUInteger count = [animationsID count];
	CFTimeInterval maxDuration = 0; //compute the maximum duration of all the animations
    
	if (count > 0) {
        //group all the animations in a single animation group object
		CAAnimationGroup *group = [[CAAnimationGroup alloc] init];
		NSMutableArray *animations = [[NSMutableArray alloc] initWithCapacity:count];
		
		for (NSUInteger index = 0; index < count; index++) {
			CAAnimation *animation = [source entryWithIdentifier:animationsID[index] withClass:[CAAnimation class]];
			if (animation) {
				maxDuration = MAX(maxDuration, animation.duration);
				[animations addObject:animation];
			}
		}
		
		group.animations = animations;
		group.duration = maxDuration;
		
        //split the animation group into 3 separate animations
		[self splitAnimation:group];
    }
    
    //set the idle animation to the character
    [model addAnimation:_animations[0] forKey:@"idle"];
    
    //hide the character for now
    model.opacity = 0;
    model.hidden = YES;
    
    //use a shader modifier for the ghost effect (to reveal the bones)
    NSString *fragShader = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"character" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];

    NSDictionary *modifier = @{ SCNShaderModifierEntryPointFragment : fragShader };

    //set the modifier recursively no the node tree
    [self setShaderModifier:modifier onNode:model];
}

//show / hide the bones recursively
- (void)_showBones:(BOOL)show node:(SCNNode *)node scale:(CGFloat)scale {
    //the scale is recursive,
    //so we need to inverse and propagate the scale to child nodes so that every bones have the same size
    scale /= node.scale.x;
    
    //show / hide the bones
    if (node.geometry==NULL || [node.geometry isKindOfClass:[SCNBox class]]) {
        node.geometry = show ? [SCNBox boxWithWidth:6*scale height:6*scale length:6*scale chamferRadius:0.5] : nil;
    }
    
    //recurse
    for (SCNNode *child in node.childNodes)
        [self _showBones:show node:child scale:scale];
}

//show / hide the bones recursively
- (void)_showGhost:(BOOL)show node:(SCNNode *)node {
    // enable/disable the ghost mode
    [node.geometry setValue:show ? @1.0 : @0.0 forKey:@"ghostFactor"];
    for (SCNNode *child in node.childNodes)
        [self _showGhost:show node:child];
}

//how / hide the bones
- (void)showBones:(BOOL)show {
    // apply on the skeleton hierarchy
    SCNNode *node = [self.ground childNodeWithName:@"skeleton" recursively:YES];
    [self _showBones:show node:node scale:1];

    // apply on the avatar
    node = [self.ground childNodeWithName:@"avatar_attach" recursively:YES];
    [self _showGhost:show node:node];
}

- (NSUInteger)numberOfSteps {
    return 6;
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)controller {
    //retrieve the avatar model
    SCNNode *model = [self.ground childNodeWithName:@"avatar_attach" recursively:YES];

    //animate by default
    [SCNTransaction begin];
    
    switch (index) {
        case 0:
        {
            //wait a little bit before showing the avatar - otherwise it may slow down the transition from the previous slide
            double delayInSeconds = 1.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                //un-hide
                [SCNTransaction begin];
                [SCNTransaction setAnimationDuration:0];
                model.hidden = NO;
                [SCNTransaction commit];
                
                [SCNTransaction begin];
                [SCNTransaction setAnimationDuration:1.5];
                [SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
                model.opacity = 1; //reveal
                
                [SCNTransaction commit];
            });
        }
            break;
        case 1:
            //show bones
            [SCNTransaction setAnimationDuration:1.5];
            [self showBones:YES];
            break;
        case 2:
            //add an animation
            [model addAnimation:_animations[1] forKey:@"move"];
            break;
        case 3:
            //back to character
            [SCNTransaction setAnimationDuration:1.5];
            [self showBones:NO];
            break;
        case 4:
            //add an animation
            [model addAnimation:_animations[1] forKey:@"move"];
            break;
        case 5:
        {
            //add some text
            ASCSlideTextManager *textManager = self.textManager;

            [textManager flipOutTextType:ASCTextTypeBullet];
            [textManager setSubtitle:@"SCNSkinner"];
            [textManager addBullet:@"Can be loaded from DAEs" atLevel:0];
            [textManager addBullet:@"Can’t be created programmatically" atLevel:0];
            [textManager flipInTextType:ASCTextTypeBullet];
            [textManager flipInTextType:ASCTextTypeSubTitle];
        }
            break;
        case 6:
            //say good bye
            [model addAnimation:_animations[1] forKey:@"move"];
            break;
    }
    
    [SCNTransaction commit];
}

@end
