/*
     File: ASCSlideLighting.m
 Abstract:  Lighting slide. 
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

@interface ASCSlideLighting : ASCSlide
@end

@implementation ASCSlideLighting

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentation {
    //retrieve the text manager
    ASCSlideTextManager *textManager = [self textManager];
    
    //add some text
    [textManager setTitle:@"Performance"];
    [textManager setSubtitle:@"Lighting"];
    [textManager addBullet:@"Minimize the number of lights" atLevel:0];
    [textManager addBullet:@"Prefer static than dynamic shadows" atLevel:0];
    [textManager addBullet:@"Use material's \"multiply\" property" atLevel:0];
}

//4 steps
- (NSUInteger)numberOfSteps {
    return 4;
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)controller {
    static BOOL cancelAddAnimation = NO;
    
    switch (index) {
        case 0:
            break;
        case 1: //show the dungeon
        {
            //create a new node that will own the dungeon
            SCNNode *intermediateNode = [SCNNode node];
            
            //place and re-orient it (from Z-up to Y-up)
            intermediateNode.position = SCNVector3Make(0, 0.1, -24.5);
            intermediateNode.scale = SCNVector3Make(2.3, 1.0, 1);
            
            //hide
            intermediateNode.opacity = 0.0;
            
            //add to the scene
            [self.rootNode addChildNode:intermediateNode];
            
            //load the dungeon and add to "intermediateNode"
            SCNNode *room = [intermediateNode asc_addChildNodeNamed:@"Mesh" fromSceneNamed:@"cornell-box" withScale:15];
            
            //hide the shadow maps
            for(SCNMaterial *m in room.geometry.materials){
                m.multiply.intensity = 0.0;
                m.lightingModelName = SCNLightingModelBlinn;
            }
            
            //at this stage it is still ok to add the animation after some delay (see below)
            cancelAddAnimation = NO;
            
            //animate the point of view with an implicit animation
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.75];
            
            [SCNTransaction setCompletionBlock:^{
                [SCNTransaction begin];
                [SCNTransaction setAnimationDuration:2.0];
                
                //on completion, add an animation if it is not too late (i.e if we are not already on another slide)
                [SCNTransaction setCompletionBlock:^{
                    //add an animation to move the camera from right to left back and forth
                    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
                    animation.duration = 10.0;
                    animation.additive = YES;
                    animation.toValue = [NSValue valueWithSCNVector3:SCNVector3Make(-5,0,0)];
                    animation.fromValue = [NSValue valueWithSCNVector3:SCNVector3Make(5,0,0)];
                    animation.timeOffset = -animation.duration/2;
                    animation.autoreverses = YES;
                    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                    animation.repeatCount = FLT_MAX;
                    
                    if (cancelAddAnimation == NO) //to check that we are still on the same slide
                        [controller.cameraNode addAnimation:animation forKey:@"myAnim"];
                }];
                
                //move the point of view
                controller.cameraHandle.position = [controller.cameraHandle convertPosition:SCNVector3Make(0, +5, -30) toNode:controller.cameraHandle.parentNode];
                controller.cameraPitch.rotation = SCNVector4Make(1, 0, 0, -M_PI_4*0.2);
                
                [SCNTransaction commit];                
            }];
            
            intermediateNode.opacity = 1.0;
            
            [SCNTransaction commit];
            
        }
            break;
        case 2:
        {
            //remove the lighting by using a constant lighing model (no lighting)
            SCNNode *room = [self.rootNode childNodeWithName:@"Mesh" recursively:YES];
            for(SCNMaterial *m in room.geometry.materials){
                m.lightingModelName = SCNLightingModelConstant;
            }
        }
            break;
        case 3:
        {
            //at this stage it is too late to add an animation to the camera.
            //The user is probably going fast through the slides
            cancelAddAnimation = YES; 
            
            //retrieve the dungeon
            SCNNode *room = [self.rootNode childNodeWithName:@"Mesh" recursively:YES];
            
            //turn on the shadow map smoothly
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            
            for(SCNMaterial *m in room.geometry.materials){
                m.multiply.intensity = 1.0;
            }

            
            [SCNTransaction commit];
        }
            break;            
        default:
            break;
    }
}

- (void)orderOutWithPresentionViewController:(ASCPresentationViewController *)controller {
    //remove the animation from the camera before leaving this slide
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:0.0];
    
    //make the current presentation position the position before removing the animation
    controller.cameraNode.position = [[controller.cameraNode presentationNode] position];
    
    //remove the animation
    [controller.cameraNode removeAnimationForKey:@"myAnim"];
    
    [SCNTransaction commit];

    //restore to original position smoothly
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.0];
    controller.cameraNode.position = SCNVector3Make(0, 0, 0);
    [SCNTransaction commit];
}

@end
