/*
     File: ASCSlideConstraints.m
 Abstract: Introduces the constraints API and shows severals examples.
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

@interface ASCSlideConstraints : ASCSlide
@end

@implementation ASCSlideConstraints {
    SCNNode *_ballNode;
}

- (NSUInteger)numberOfSteps {
    return 8;
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    switch (index) {
        case 0:
            // Set the slide's title and subtitle and add some text
            self.textManager.title = @"Constraints";
            self.textManager.subtitle = @"SCNConstraint";
            
            [self.textManager addBullet:@"Applied sequentially at render time" atLevel:0];
            [self.textManager addBullet:@"Only affect presentation values" atLevel:0];
            
            [self.textManager addCode:@"aNode.#constraints# = @[aConstraint, anotherConstraint, ...];"];
            
            // Tweak the near clipping plane of the spot light to get a precise shadow map
            [presentationViewController.spotLight.light setAttribute:@(10) forKey:SCNLightShadowNearClippingKey];
            break;
        case 1:
        {
            // Remove previous text
            [self.textManager flipOutTextOfType:ASCTextTypeSubtitle];
            [self.textManager flipOutTextOfType:ASCTextTypeBullet];
            [self.textManager flipOutTextOfType:ASCTextTypeCode];
            
            // Add new text
            self.textManager.subtitle = @"SCNTransformConstraint";
            [self.textManager addBullet:@"Custom constraint on a node's transform" atLevel:0];
            [self.textManager addCode:@"aConstraint = [SCNTransformConstraint #transformConstraintInWorldSpace:#YES \n"
             @"                                                            #withBlock:# \n"
             @"               ^BOOL(SCNNode *node, CATransform3D *transform) { \n"
             @"                   transform->m11 = 0.0; \n"
             @"                   return YES; \n"
             @"               }];"];
            
            [self.textManager flipInTextOfType:ASCTextTypeSubtitle];
            [self.textManager flipInTextOfType:ASCTextTypeBullet];
            [self.textManager flipInTextOfType:ASCTextTypeCode];
            break;
        }
        case 2:
        {
            // Remove previous text
            [self.textManager flipOutTextOfType:ASCTextTypeSubtitle];
            [self.textManager flipOutTextOfType:ASCTextTypeBullet];
            [self.textManager flipOutTextOfType:ASCTextTypeCode];
            
            // Add new text
            self.textManager.subtitle = @"SCNLookAtConstraint";
            [self.textManager addBullet:@"Makes a node to look at another node" atLevel:0];
            [self.textManager addCode:@"nodeA.constraints = @[SCNLookAtConstraint #lookAtConstraintWithTarget#:nodeB];"];
            
            [self.textManager flipInTextOfType:ASCTextTypeSubtitle];
            [self.textManager flipInTextOfType:ASCTextTypeBullet];
            [self.textManager flipInTextOfType:ASCTextTypeCode];
            break;
        }
        case 3:
        {
            // Setup the scene
            [self setupLookAtScene];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                // Dim the text and move back a little bit
                self.textManager.textNode.opacity = 0.5;
                presentationViewController.cameraHandle.position = [presentationViewController.cameraNode convertPosition:SCNVector3Make(0, 0, 5.0) toNode:presentationViewController.cameraHandle.parentNode];
            }
            [SCNTransaction commit];
            break;
        }
        case 4:
        {
            // Add constraints to the arrows
            SCNNode *container = [self.contentNode childNodeWithName:@"arrowContainer" recursively:YES];
            
            // "Look at" constraint
            SCNLookAtConstraint *constraint = [SCNLookAtConstraint lookAtConstraintWithTarget:_ballNode];
            
            NSUInteger i = 0;
            for (SCNNode *arrow in container.childNodes) {
                double delayInSeconds = 0.1 * i++; // desynchronize the different animations
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                    [SCNTransaction begin];
                    [SCNTransaction setAnimationDuration:1.0];
                    {
                        // Animate to the result of applying the constraint
                        ((SCNNode *)arrow.childNodes[0]).rotation = SCNVector4Make(0, 1, 0, M_PI_2);
                        [arrow setConstraints:@[constraint]];
                    }
                    [SCNTransaction commit];
                });
            }
            break;
        }
        case 5:
        {
            // Create a keyframe animation to move the ball
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
            animation.keyTimes = @[@0.0, @(1/8.0), @(2/8.0), @(3/8.0), @(4/8.0), @(5/8.0), @(6/8.0), @(7/8.0), @1.0];
            animation.values = @[[NSValue valueWithSCNVector3:SCNVector3Make(0, 0.0, 0)],
                                 [NSValue valueWithSCNVector3:SCNVector3Make(20.0, 0.0, 20.0)],
                                 [NSValue valueWithSCNVector3:SCNVector3Make(40.0, 0.0, 0)],
                                 [NSValue valueWithSCNVector3:SCNVector3Make(20.0, 0.0, -20.0)],
                                 [NSValue valueWithSCNVector3:SCNVector3Make(0, 0.0, 0)],
                                 [NSValue valueWithSCNVector3:SCNVector3Make(-20.0, 0.0, 20.0)],
                                 [NSValue valueWithSCNVector3:SCNVector3Make(-40.0, 0.0, 0)],
                                 [NSValue valueWithSCNVector3:SCNVector3Make(-20.0, 0.0, -20.0)],
                                 [NSValue valueWithSCNVector3:SCNVector3Make(0, 0.0, 0)]];
            animation.calculationMode = kCAAnimationCubicPaced; // smooth the movement between keyframes
            animation.repeatCount = FLT_MAX;
            animation.duration = 10.0;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            [_ballNode addAnimation:animation forKey:nil];
            
            // Rotate the ball to give the illusion of a rolling ball
            // We need two animations to do that:
            // - one rotation to orient the ball in the right direction
            // - one rotation to spin the ball
            animation = [CAKeyframeAnimation animationWithKeyPath:@"rotation"];
            animation.keyTimes = @[@0.0, @(0.7/8.0), @(1/8.0), @(2/8.0), @(3/8.0), @(3.3/8.0), @(4.7/8.0), @(5/8.0), @(6/8.0), @(7/8.0),@(7.3/8.0), @1.0];
            animation.values = @[[NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI_4)],
                                 [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI_4)],
                                 [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI_2)],
                                 [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI)],
                                 [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI + M_PI_2)],
                                 [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2 - M_PI_4)],
                                 [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2 - M_PI_4)],
                                 [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2 - M_PI_2)],
                                 [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI)],
                                 [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI - M_PI_2)],
                                 [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI_4)],
                                 [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI_4)]];
            animation.repeatCount = FLT_MAX;
            animation.duration = 10.0;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            [_ballNode addAnimation:animation forKey:nil];
            
            CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
            rotationAnimation.duration = 1.0;
            rotationAnimation.repeatCount = FLT_MAX;
            rotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(1, 0, 0, M_PI * 2)];
            [_ballNode.childNodes[1] addAnimation:rotationAnimation forKey:nil];
            break;
        }
        case 6:
        {
            // Add a constraint to the camera
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                SCNLookAtConstraint *constraint = [SCNLookAtConstraint lookAtConstraintWithTarget:_ballNode];
                presentationViewController.cameraNode.constraints = @[constraint];
            }
            [SCNTransaction commit];
            break;
        }
        case 7:
        {
            // Add a constraint to the light
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                SCNNode *cameraTarget = [self.contentNode childNodeWithName:@"cameraTarget" recursively:YES];
                SCNLookAtConstraint *constraint = [SCNLookAtConstraint lookAtConstraintWithTarget:cameraTarget];
             
                presentationViewController.spotLight.constraints = @[constraint];
            }
            [SCNTransaction commit];
            break;
        }
    }
}

- (void)didOrderInWithPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    [presentationViewController enableShadows:YES];
}

- (void)willOrderOutWithPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.0];
    {
        presentationViewController.cameraNode.constraints = nil;
        presentationViewController.spotLight.constraints = nil;
    }
    [SCNTransaction commit];
}

- (void)setupLookAtScene {
    SCNNode *intermediateNode = [SCNNode node];
    intermediateNode.scale = SCNVector3Make(0.5, 0.5, 0.5);
    intermediateNode.position = SCNVector3Make(0, 0, 10);
    [self.contentNode addChildNode:intermediateNode];
    
    SCNMaterial *ballMaterial = [SCNMaterial material];
    ballMaterial.diffuse.contents = [NSImage imageNamed:@"pool_8"];
    ballMaterial.specular.contents = [NSColor whiteColor];
    ballMaterial.shininess = 0.9; // shinny
    ballMaterial.reflective.contents = [NSImage imageNamed:@"color_envmap"];
    ballMaterial.reflective.intensity = 0.5;
    
    // Node hierarchy for the ball :
    //   _ballNode
    //  |__ cameraTarget      : the target for the "look at" constraint
    //  |__ ballRotationNode  : will rotate to animate the rolling ball
    //      |__ ballPivotNode : will own the geometry and will be rotated so that the "8" faces the camera at the beginning
    
    _ballNode = [SCNNode node];
    _ballNode.rotation = SCNVector4Make(0, 1, 0, M_PI_4);
    [intermediateNode addChildNode:_ballNode];
    
    SCNNode *cameraTarget = [SCNNode node];
    cameraTarget.name = @"cameraTarget";
    cameraTarget.position = SCNVector3Make(0, 6, 0);
    [_ballNode addChildNode:cameraTarget];
    
    SCNNode *ballRotationNode = [SCNNode node];
    ballRotationNode.position = SCNVector3Make(0, 4, 0);
    [_ballNode addChildNode:ballRotationNode];
    
    SCNNode *ballPivotNode = [SCNNode node];
    ballPivotNode.geometry = [SCNSphere sphereWithRadius:4.0];
    ballPivotNode.geometry.firstMaterial = ballMaterial;
    ballPivotNode.rotation = SCNVector4Make(0, 1, 0, M_PI_2);
    [ballRotationNode addChildNode:ballPivotNode];
    
    SCNMaterial *arrowMaterial = [SCNMaterial material];
    arrowMaterial.diffuse.contents = [NSColor whiteColor];
    arrowMaterial.reflective.contents = [NSImage imageNamed:@"chrome"];
    
    SCNNode *arrowContainer = [SCNNode node];
    arrowContainer.name = @"arrowContainer";
    [intermediateNode addChildNode:arrowContainer];
    
    NSBezierPath *arrowPath = [NSBezierPath asc_arrowBezierPathWithBaseSize:NSMakeSize(6,2)
                                                                    tipSize:NSMakeSize(3, 5)
                                                                     hollow:0.5
                                                                   twoSides:NO];
    // Create the arrows
    for (NSUInteger i = 0; i < 11; i++) {
        SCNNode *arrowNode = [SCNNode node];
        arrowNode.position = SCNVector3Make(cos(M_PI * i / 10.0) * 20.0, 3 + 18.5 * sin(M_PI * i / 10.0), 0);
        
        SCNShape *arrowGeometry = [SCNShape shapeWithPath:arrowPath extrusionDepth:1];
        arrowGeometry.chamferRadius = 0.2;
        
        SCNNode *arrowSubNode = [SCNNode node];
        arrowSubNode.geometry = arrowGeometry;
        arrowSubNode.geometry.firstMaterial = arrowMaterial;
        arrowSubNode.pivot = CATransform3DMakeTranslation(0, 2.5, 0); // place the pivot (center of rotation) at the middle of the arrow
        arrowSubNode.rotation = SCNVector4Make(0, 0, 1, M_PI_2);
        
        [arrowNode addChildNode:arrowSubNode];
        [arrowContainer addChildNode:arrowNode];
    }
}

@end
