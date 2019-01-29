/*
     File: ASCSlideCamera.m
 Abstract: Camera slide. Illustrates the camera node attribute.
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

@interface ASCSlideCamera : ASCSlide
@end

@implementation ASCSlideCamera

- (NSUInteger)numberOfSteps {
    return 9;
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentationViewController {
    // Create a node to own the "sign" model, make it to be close to the camera, rotate by 90 degree because it's oriented with z as the up axis
    SCNNode *intermediateNode = [SCNNode node];
    intermediateNode.position = SCNVector3Make(0, 0, 7);
    intermediateNode.rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
    [self.groundNode addChildNode:intermediateNode];
    
    // Load the "sign" model
    SCNNode *signNode = [intermediateNode asc_addChildNodeNamed:@"sign" fromSceneNamed:@"intersection" withScale:30];
    signNode.position = SCNVector3Make(4, -2, 0.05);
    
    // Re-parent every node that holds a camera otherwise they would inherit the scale from the "sign" model.
    // This is not a problem except that the scale affects the zRange of cameras and so it would be harder to get the transition from one camera to another right
    NSArray *cameraNodes = [signNode childNodesPassingTest:^BOOL(SCNNode *child, BOOL *stop) {
        return (child.camera != nil);
    }];
    
    for (SCNNode *cameraNode in cameraNodes) {
        CATransform3D previousWorldTransform = cameraNode.worldTransform;
        [intermediateNode addChildNode:cameraNode]; // re-parent
        cameraNode.transform = [intermediateNode convertTransform:previousWorldTransform fromNode:nil];
        cameraNode.scale = SCNVector3Make(1, 1, 1);
    }
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    [SCNTransaction begin];
    switch (index) {
        case 0:
        {
            // Set the slide's title and subtitle and add some text
            self.textManager.title = @"Node Attributes";
            self.textManager.subtitle = @"Camera";
            [self.textManager addBullet:@"Point of view for renderers" atLevel:0];
            
            // Start with the "sign" model hidden
            SCNNode *group = [self.contentNode childNodeWithName:@"group" recursively:YES];
            group.scale = SCNVector3Make(0, 0, 0);
            group.hidden = YES;
            break;
        }
        case 1:
        {
            // Reveal the model (unhide then scale)
            SCNNode *group = [self.contentNode childNodeWithName:@"group" recursively:YES];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0];
            {
                group.hidden = NO;
            }
            [SCNTransaction commit];
            
            [SCNTransaction setAnimationDuration:1.0];
            group.scale = SCNVector3Make(1, 1, 1);
            break;
        }
        case 2:
            [self.textManager addCode:
             @"aNode.#camera# = [#SCNCamera# camera]; \n"
             @"aView.#pointOfView# = aNode;"];
            break;
        case 3:
            // Switch to camera1
            [SCNTransaction setAnimationDuration:2.0];
            presentationViewController.view.pointOfView = [self.contentNode childNodeWithName:@"camera1" recursively:YES];
            break;
        case 4:
            // Switch to camera2
            [SCNTransaction setAnimationDuration:2.0];
            presentationViewController.view.pointOfView = [self.contentNode childNodeWithName:@"camera2" recursively:YES];
            break;
        case 5:
        {
            // On completion add some code
            [SCNTransaction setCompletionBlock:^{
                self.textManager.fadesIn = YES;
                [self.textManager addEmptyLine];
                [self.textManager addCode:@"aNode.#camera#.xFov = angleInDegrees;"];
            }];
            
            // Switch back to the default camera
            [SCNTransaction setAnimationDuration:1.0];
            presentationViewController.view.pointOfView = presentationViewController.cameraNode;
            break;
        }
        case 6:
        {
            // Switch to camera 3
            [SCNTransaction setAnimationDuration:1.0];
            SCNNode *target = [self.contentNode childNodeWithName:@"camera3" recursively:YES];
            
            // Don't let the default transition animate the FOV (we will animate the FOV separately)
            double wantedFOV = target.camera.xFov;
            target.camera.xFov = presentationViewController.view.pointOfView.camera.xFov;
            
            // Animate point of view with an ease-in/ease-out function
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            [SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            {
                presentationViewController.view.pointOfView = target;
            }
            [SCNTransaction commit];
            
            // Animate the FOV with the default timing function (for a better looking transition)
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                presentationViewController.view.pointOfView.camera.xFov = wantedFOV;
            }
            [SCNTransaction commit];
            break;
        }
        case 7:
        {
            // Switch to camera 4
            SCNNode *cameraNode = [self.contentNode childNodeWithName:@"camera4" recursively:YES];
            
             // Don't let the default transition animate the FOV (we will animate the FOV separately)
            double wantedFOV = cameraNode.camera.xFov;
            cameraNode.camera.xFov = presentationViewController.view.pointOfView.camera.xFov;
            
            // Animate point of view with the default timing function
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                presentationViewController.view.pointOfView = cameraNode;
            }
            [SCNTransaction commit];
            
            // Animate the FOV with an ease-in/ease-out function
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            [SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            {
                presentationViewController.view.pointOfView.camera.xFov = wantedFOV;
            }
            [SCNTransaction commit];
            break;
        }
        case 8:
        {
            // Quickly switch back to the default camera
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.75];
            {
                presentationViewController.view.pointOfView = presentationViewController.cameraNode;
            }
            [SCNTransaction commit];
            break;
        }
    }
    
    [SCNTransaction commit];
}

- (void)willOrderOutWithPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    [SCNTransaction begin];
    {
        // Restore the default point of view before leaving this slide
        presentationViewController.view.pointOfView = presentationViewController.cameraNode;
    }
    [SCNTransaction commit];
}

@end
