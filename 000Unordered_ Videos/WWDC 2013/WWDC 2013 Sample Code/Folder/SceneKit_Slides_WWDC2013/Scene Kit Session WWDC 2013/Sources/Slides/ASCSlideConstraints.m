/*
     File: ASCSlideConstraints.m
 Abstract:  Constraints slide. 
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

// turn on or off gimbal lock (see SCNConstraints.h)
#define ENABLE_GIMBAL_LOCK 0

@interface ASCSlideConstraints : ASCSlide
@end

@implementation ASCSlideConstraints

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentation {
    //retrieve the text manager and add some bullets
    ASCSlideTextManager *textManager = [self textManager];
    [textManager setTitle:@"Constraints"];
    [textManager setSubtitle:@"SCNConstraint"];
    [textManager addBullet:@"Applied sequentially at render time" atLevel:0];
    [textManager addBullet:@"Only affect presentation values" atLevel:0];
    [textManager addCode:@"aNode.#constraints# = @[aConstraint, anotherConstraint, ...];"];
}

// intialize the scene to use to illustrate the constraints
- (void)setupLookAtScene {
    // create an intermediate node that will own the rest of the scene
    SCNNode *intermediateNode = [SCNNode node];
    
    //place and rescale
#define SCALE 0.5
    intermediateNode.scale = SCNVector3Make(SCALE, SCALE, SCALE);
    intermediateNode.position = SCNVector3Make(0, 0, 10);
    
    //add to the slide
    [self.rootNode addChildNode:intermediateNode];
    
    //create a new material for the ball
    SCNMaterial *material = [SCNMaterial material];
    material.diffuse.contents = [NSImage imageNamed:@"pool_8"]; //"8" texture
    material.specular.contents = [NSColor whiteColor]; //white specular
    material.shininess = 0.9; //shinny
    material.reflective.contents = [NSImage imageNamed:@"color_envmap"]; //reflective
    material.reflective.intensity = 0.5;
    
    /* setup a node hierarchy: model > (rotationAxis & cameraTarget) > ball
     "ball" will own the geometry of the ball and will be rotated so that the "8" faces the camera at first.
     "rotationAxis" will rotate to animate the rolling ball
     "model"
     */
    SCNNode *model = [SCNNode node];
    SCNNode *rotationAxis = [SCNNode node];
    SCNNode *ball = [SCNNode node];
    SCNNode *cameraTarget = [SCNNode node];
    
    //name the nodes for later retrieval
    model.name = @"ball";
    cameraTarget.name = @"cameraTarget";
    ball.name = @"ball-pivot";
    
    // create a 3d sphere (geometry of the ball)
    ball.geometry = [SCNSphere sphereWithRadius:4.0];
    
    //assign the material
    ball.geometry.firstMaterial = material;
    
    //place the elements
    ball.rotation = SCNVector4Make(0, 1, 0, M_PI_2);
    rotationAxis.position = SCNVector3Make(0, 4, 0);
    model.rotation = SCNVector4Make(0, 1, 0, M_PI_4);
    
    //setup the hierarchy
	[intermediateNode addChildNode:model];
    [model addChildNode:rotationAxis];
	[model addChildNode:cameraTarget];
    [rotationAxis addChildNode:ball];
    
    //setup the materials for the arrows
    material = [SCNMaterial material];
    material.diffuse.contents = [NSColor whiteColor];
    material.reflective.contents = [NSImage imageNamed:@"chrome"];
    
    //create a node that will containts the arrows
    SCNNode *arrowContainer = [SCNNode node];
    arrowContainer.name = @"arrowContainer";
    [intermediateNode addChildNode:arrowContainer];
    
    //create 11 arrows
    for (NSUInteger i = 0; i < 11; i++) {
        model = [SCNNode node];
        SCNNode *arrowNode = [SCNNode node];
        
        //place the arrows
        model.position = SCNVector3Make(cos(M_PI*i/10.0) * 20.0, 3 + 18.5*sin(M_PI*i/10.0), 0);
        
        //create a 3D arrow using SCNShape
        arrowNode.geometry = [SCNShape shapeWithPath:[NSBezierPath asc_arrowBezierPathWithBaseSize:NSMakeSize(6,2) tipSize:NSMakeSize(3, 5) hollow:0.5 twoSides:NO] extrusionDepth:1];
        
        //make the pivot (center of rotation) in the middle of the arrow
        arrowNode.pivot = CATransform3DMakeTranslation(0, 2.5, 0);
        
        //chamfer the arrow
        ((SCNShape*)arrowNode.geometry).chamferRadius = 0.2;
        
        //assign the material
        arrowNode.geometry.firstMaterial = material;
        
        //rotate by 90 degree on the Z axis
        arrowNode.rotation = SCNVector4Make(0, 0, 1, M_PI_2);
        
        //add to the scene
        [model addChildNode:arrowNode];
        [arrowContainer addChildNode:model];
    }
}

- (NSUInteger)numberOfSteps {
    return 8;
}

- (void)orderInWithPresentionViewController:(ASCPresentationViewController *)controller {
    //turn on shadows at the end of the orderIn animation
    [controller enableShadows:YES];
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)controller {
    switch (index) {
        case 0:
            //tweak the near clipping plane of the spot light to get a precise shadow map
            [controller.spotLight.light setAttribute:@(10) forKey:SCNLightShadowNearClippingKey];
            break;
        case 1:
        {
            //retrieve the text manager
            ASCSlideTextManager *textManager = [self textManager];
            
            //remove the previous text
            [textManager flipOutTextType:ASCTextTypeSubTitle];
            [textManager flipOutTextType:ASCTextTypeBullet];
            [textManager flipOutTextType:ASCTextTypeCode];
            
            //add the new ones
            [textManager addCode:@"SCNTransformConstraint"];
            [textManager addCode:@"Custom constraint on a node's transform"];
            [textManager addCode:@"aConstraint = [SCNTransformConstraint #transformConstraintInWorldSpace:#YES"];
            [textManager addCode:@"                                                            #withBlock:#"];
            [textManager addCode:@"               ^BOOL(SCNNode *node, CATransform3D *transform) {"];
            [textManager addCode:@"                   transform->m11 = 0.0;"];
            [textManager addCode:@"                   return YES;"];
            [textManager addCode:@"               }];"];

            //animate in the new texts
            [textManager flipInTextType:ASCTextTypeSubTitle];
            [textManager flipInTextType:ASCTextTypeBullet];
            [textManager flipInTextType:ASCTextTypeCode];
        }
            break;
        case 2:
        {
            //retrieve the text manager
            ASCSlideTextManager *textManager = [self textManager];
            
            //remove the previous text
            [textManager flipOutTextType:ASCTextTypeSubTitle];
            [textManager flipOutTextType:ASCTextTypeBullet];
            [textManager flipOutTextType:ASCTextTypeCode];
            
            //add the new ones
            [textManager setSubtitle:@"SCNLookAtConstraint"];
            [textManager addBullet:@"Makes a node to look at another node" atLevel:0];
            [textManager addCode:@"nodeA.constraints = @[SCNLookAtConstraint #lookAtConstraintWithTarget#:nodeB];"];
            
            //animate in the new texts
            [textManager flipInTextType:ASCTextTypeSubTitle];
            [textManager flipInTextType:ASCTextTypeBullet];
            [textManager flipInTextType:ASCTextTypeCode];
        }
            break;
        case 3:
            //setup the constraint scene
            [self setupLookAtScene];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            
            //dim the text
            self.textManager.textNode.opacity = 0.5;
            
            //move back a little bit
            controller.cameraHandle.position = [controller.cameraNode convertPosition:SCNVector3Make(0, 0, 5.0) toNode:controller.cameraHandle.parentNode];
            
            [SCNTransaction commit];
            break;
        case 4:
        {
            //add constraints to the arrows
            SCNNode *ball = [self.rootNode childNodeWithName:@"ball-pivot" recursively:YES];
            SCNNode *container = [self.rootNode childNodeWithName:@"arrowContainer" recursively:YES];
            
            //setup the constaint (look at the ball)
            SCNLookAtConstraint *constraint  = [SCNLookAtConstraint lookAtConstraintWithTarget:ball];
#if ENABLE_GIMBAL_LOCK
            constraint.gimbalLockEnabled = YES;
#endif
            
            //for each arrow...
            NSUInteger i = 0;
            for (SCNNode *arrow in container.childNodes) {
                
                double delayInSeconds = 0.1 * i; //desynchronize the animation of the arrows
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                    [SCNTransaction begin];
                    [SCNTransaction setAnimationDuration:1.0];//animate in the constraint
                    
                    //rotate the arrow
                    ((SCNNode *)arrow.childNodes[0]).rotation = SCNVector4Make(0, 1, 0, M_PI_2);
                    
                    //add the constaint
                    [arrow setConstraints:[NSArray arrayWithObject:constraint]];
                    
                    [SCNTransaction commit];
                });
                
                i++;
            }
        }
            break;
        case 5: //animate the ball
        {
            //retrieve the ball
            SCNNode *ball = [self.rootNode childNodeWithName:@"ball" recursively:YES];
            
            // create a keyframed animation
            CAKeyframeAnimation *kanimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
            
#define N 8.0
#define X 40
#define Y 0
#define Z 20
            
            //keytime and values
            kanimation.keyTimes = @[@0.0, @(1/N), @(2/N), @(3/N), @(4/N), @(5/N), @(6/N), @(7/N), @1.0];
            kanimation.values = @[
                                  [NSValue valueWithSCNVector3:SCNVector3Make(0, Y, 0)],
                                  [NSValue valueWithSCNVector3:SCNVector3Make(X/2, Y, Z)],
                                  [NSValue valueWithSCNVector3:SCNVector3Make(X, Y, 0)],
                                  [NSValue valueWithSCNVector3:SCNVector3Make(X/2, Y, -Z)],
                                  [NSValue valueWithSCNVector3:SCNVector3Make(0, Y, 0)],
                                  [NSValue valueWithSCNVector3:SCNVector3Make(-X/2, Y, Z)],
                                  [NSValue valueWithSCNVector3:SCNVector3Make(-X, Y, 0)],
                                  [NSValue valueWithSCNVector3:SCNVector3Make(-X/2, Y, -Z)],
                                  [NSValue valueWithSCNVector3:SCNVector3Make(0, Y, 0)],
                                  ];
            
            //use a cubic interpolation mode to smooth the movement between keyframes
            kanimation.calculationMode = kCAAnimationCubicPaced;
            kanimation.repeatCount = FLT_MAX;
            kanimation.duration = 10.0;
            kanimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            
            //add the animation to the ball
            [ball addAnimation:kanimation forKey:nil];
            
            /*rotate the ball to give the illusion of a rolling ball
             to do this we need two animations:
             1 rotation to orient the ball in the right direction
             1 rotation to spin the ball
             */
            kanimation = [CAKeyframeAnimation animationWithKeyPath:@"rotation"];
            
            //keys and values
            kanimation.keyTimes = @[@0.0, @(0.7/N), @(1/N), @(2/N), @(3/N), @(3.3/N), @(4.7/N), @(5/N), @(6/N), @(7/N),@(7.3/N), @1.0];
            kanimation.values = @[
                                  [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI_4)],
                                  [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI_4)],
                                  [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI_2)],
                                  [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI)],
                                  [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI+M_PI_2)],
                                  [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI*2 - M_PI_4)],
                                  [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI*2 - M_PI_4)],
                                  [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI*2 - M_PI_2)],
                                  [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI)],
                                  [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI - M_PI_2)],
                                  [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI_4)],
                                  [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI_4)],
                                  ];
            
            kanimation.repeatCount = FLT_MAX;
            kanimation.duration = 10.0;
            kanimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            //add the animation to orient the ball in the right direction over the time
            [ball addAnimation:kanimation forKey:nil];
            
            //make the ball to spin
            CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
            rotationAnimation.duration = 1.0;
            rotationAnimation.repeatCount = FLT_MAX;
            rotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(1, 0, 0, M_PI*2)];
            [ball.childNodes[0] addAnimation:rotationAnimation forKey:nil];
        }
            break;
        case 6:
        {
            //add a constraint to camera
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            
            SCNNode *ball = [self.rootNode childNodeWithName:@"cameraTarget" recursively:YES];
            SCNLookAtConstraint *constraint  = [SCNLookAtConstraint lookAtConstraintWithTarget:ball];
            
            controller.cameraNode.constraints = @[constraint];
            
            [SCNTransaction commit];
        }
            break;
        case 7:
        {
            //add constraint to the light
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            
            SCNNode *ball = [self.rootNode childNodeWithName:@"ball" recursively:YES];
            SCNNode *cameraTarget = [self.rootNode childNodeWithName:@"cameraTarget" recursively:YES];
            SCNLookAtConstraint *constraint  = [SCNLookAtConstraint lookAtConstraintWithTarget:ball];
            
            //move camera up a little bit
            cameraTarget.position = SCNVector3Make(0, 6, 0);
            
            controller.spotLight.constraints = @[constraint];
            [SCNTransaction commit];
        }
            break;
        default:
            break;
    }
}

- (void)orderOutWithPresentionViewController:(ASCPresentationViewController *)controller {
    //remove all constraints before leaving this slide
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.0];
    
    controller.cameraNode.constraints = nil;
    controller.spotLight.constraints = nil;
    
    [SCNTransaction commit];
}

@end
