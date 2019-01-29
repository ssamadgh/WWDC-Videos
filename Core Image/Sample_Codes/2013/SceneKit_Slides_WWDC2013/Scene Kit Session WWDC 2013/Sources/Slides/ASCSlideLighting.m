/*
     File: ASCSlideLighting.m
 Abstract: Performance tips when dealing with lights.
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

@interface ASCSlideLighting : ASCSlide
@end

@implementation ASCSlideLighting {
    SCNNode *_roomNode;
}

- (NSUInteger)numberOfSteps {
    return 4;
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentationViewController {
    // Set the slide's title and subtitle and add some text
    self.textManager.title = @"Performance";
    self.textManager.subtitle = @"Lighting";
    
    [self.textManager addBullet:@"Minimize the number of lights" atLevel:0];
    [self.textManager addBullet:@"Prefer static than dynamic shadows" atLevel:0];
    [self.textManager addBullet:@"Use material's \"multiply\" property" atLevel:0];
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    switch (index) {
        case 1:
        {
            // Load the scene
            SCNNode *intermediateNode = [SCNNode node];
            intermediateNode.position = SCNVector3Make(0.0, 0.1, -24.5);
            intermediateNode.scale = SCNVector3Make(2.3, 1.0, 1.0);
            intermediateNode.opacity = 0.0;
            _roomNode = [intermediateNode asc_addChildNodeNamed:@"Mesh" fromSceneNamed:@"cornell-box" withScale:15];
            [self.contentNode addChildNode:intermediateNode];
            
            // Hide the light maps for now
            for (SCNMaterial *material in _roomNode.geometry.materials) {
                material.multiply.intensity = 0.0;
                material.lightingModelName = SCNLightingModelBlinn;
            }
            
            // Animate the point of view with an implicit animation.
            // On completion add to move the camera from right to left and back and forth.
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.75];
            
            [SCNTransaction setCompletionBlock:^{
                [SCNTransaction begin];
                [SCNTransaction setAnimationDuration:2.0];
                
                [SCNTransaction setCompletionBlock:^{
                    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
                    animation.duration = 10.0;
                    animation.additive = YES;
                    animation.toValue = [NSValue valueWithSCNVector3:SCNVector3Make(-5, 0, 0)];
                    animation.fromValue = [NSValue valueWithSCNVector3:SCNVector3Make(5, 0, 0)];
                    animation.timeOffset = -animation.duration / 2;
                    animation.autoreverses = YES;
                    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                    animation.repeatCount = FLT_MAX;
                    
                    [presentationViewController.cameraNode addAnimation:animation forKey:@"myAnim"];
                }];
                {
                    presentationViewController.cameraHandle.position = [presentationViewController.cameraHandle convertPosition:SCNVector3Make(0, +5, -30) toNode:presentationViewController.cameraHandle.parentNode];
                    presentationViewController.cameraPitch.rotation = SCNVector4Make(1, 0, 0, -M_PI_4 * 0.2);
                }
                [SCNTransaction commit];
            }];
            {
                intermediateNode.opacity = 1.0;
            }
            [SCNTransaction commit];
            break;
        }
        case 2:
        {
            // Remove the lighting by using a constant lighing model (no lighting)
            for (SCNMaterial *material in _roomNode.geometry.materials)
                material.lightingModelName = SCNLightingModelConstant;
            break;
        }
        case 3:
        {
            // Activate the light maps smoothly
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                for (SCNMaterial *material in _roomNode.geometry.materials)
                    material.multiply.intensity = 1.0;
            }
            [SCNTransaction commit];
            break;
        }
    }
}

- (void)willOrderOutWithPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    // Remove the animation from the camera and restore (animate) its position before leaving this slide
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:0.0];
    {
        [presentationViewController.cameraNode removeAnimationForKey:@"myAnim"];
        presentationViewController.cameraNode.position = presentationViewController.cameraNode.presentationNode.position;
    }
    [SCNTransaction commit];
    
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.0];
    {
        presentationViewController.cameraNode.position = SCNVector3Make(0, 0, 0);
    }
    [SCNTransaction commit];
}

@end
