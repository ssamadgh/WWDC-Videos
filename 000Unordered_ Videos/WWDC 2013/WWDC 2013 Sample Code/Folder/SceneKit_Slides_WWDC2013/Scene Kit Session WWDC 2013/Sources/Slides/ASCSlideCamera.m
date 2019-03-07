/*
     File: ASCSlideCamera.m
 Abstract:  Camera slide. Illustrates the camera attribute 
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

@interface ASCSlideCamera : ASCSlide
@end

@implementation ASCSlideCamera

- (NSUInteger)numberOfSteps {
    return 9;
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentation {
    // retrieve text manger
    ASCSlideTextManager *textManager = [self textManager];
    
    // add text
    [textManager setTitle:@"Node Attributes"];
    [textManager setSubtitle:@"Camera"];
    [textManager addBullet:@"Point of view for renderers" atLevel:0];
    
    // create a node to own the "intersection" model
    SCNNode *intermediateNode = [SCNNode node];
    
    //make closer to the camera
    intermediateNode.position = SCNVector3Make(0, 0, 7);
    
    //rotate by 90 degree because the "intersection model is oriented with z as the up axis
    intermediateNode.rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
    [self.ground addChildNode:intermediateNode];
    
    //load the model and add to "intermediate" node
    SCNNode *model = [intermediateNode asc_addChildNodeNamed:@"sign" fromSceneNamed:@"intersection" withScale:30];
    
    //place it
    model.position = SCNVector3Make(4, -2, 0.05);
    
    /* move every camera under "intermediateNode" otherwise they would inherit from the scale of "model".
     This is not a problem except that the scale affect the zRange of cameras and so it would be harder to get the transition from one camera to another right */
    NSArray *cameraNodes = [model childNodesPassingTest:^BOOL(SCNNode *child, BOOL *stop) {
        return (child.camera != nil);
    }];
    
    for (SCNNode *cameraNode in cameraNodes) {
        CATransform3D worldTransform = cameraNode.worldTransform;
        [intermediateNode addChildNode:cameraNode];
        cameraNode.transform = [intermediateNode convertTransform:worldTransform fromNode:nil];
        cameraNode.scale = SCNVector3Make(1, 1, 1);
    }
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)controller {
    [SCNTransaction begin];
    
    switch (index) {
        case 0:
        {
            //start with the interesction model hidden
            SCNNode *group = [self.rootNode childNodeWithName:@"group" recursively:YES];
            group.scale = SCNVector3Make(0,0,0);
            group.hidden = YES;
        }
            break;
        case 1:
        {
            //reveal the intersection model
            SCNNode *group = [self.rootNode childNodeWithName:@"group" recursively:YES];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0];
            group.hidden = NO;
            [SCNTransaction commit];
            
            [SCNTransaction setAnimationDuration:1.0];
            
            group.scale = SCNVector3Make(1, 1, 1);
        }
            break;
        case 2:
        {
            //add some text
            ASCSlideTextManager *textManager = self.textManager;
            [textManager addCode:@"aNode.#camera# = [#SCNCamera# camera];"];
            [textManager addCode:@"aView.#pointOfView# = aNode;"];
        }
            break;
        case 3:
            //switch to camera1
            [SCNTransaction setAnimationDuration:2.0];
            controller.view.pointOfView = [self.rootNode childNodeWithName:@"camera1" recursively:YES];
            break;
        case 4:
            //switch to camera2
            [SCNTransaction setAnimationDuration:2.0];
            controller.view.pointOfView = [self.rootNode childNodeWithName:@"camera2" recursively:YES];
            break;
            
        case 5:
        {
            //switch back to original camera
            [SCNTransaction setAnimationDuration:1.0];
            
            controller.view.pointOfView = controller.cameraNode;
            
            // on completion add some code
            [SCNTransaction setCompletionBlock:^{
                ASCSlideTextManager *textManager = self.textManager;
                textManager.fadeIn = YES;
                [textManager addEmptyLine];
                [textManager addCode:@"aNode.#camera#.xFov = angleInDegrees;"];
            }];
        }
            break;
        case 6:
        {
            //switch to camera 3
            [SCNTransaction setAnimationDuration:1.0];
            SCNNode *target = [self.rootNode childNodeWithName:@"camera3" recursively:YES];
            
            //don't let the default transition to animate the fov, we will animate the fov separatly
            double dstFov = target.camera.xFov;
            target.camera.xFov = controller.view.pointOfView.camera.xFov;
            
            //animation duration
            float duration = 1.0;
            
            //animate point of view with a ease in/out function
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:duration];
            [SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            
            controller.view.pointOfView = target;
            
            [SCNTransaction commit];
            
            //animate fov with default timing function (for better looking transition)
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:duration];
            
            controller.view.pointOfView.camera.xFov = dstFov;
            
            [SCNTransaction commit];
            
        }
            break;
        case 7:
        {
            //switch to camera 4
            SCNNode *target = [self.rootNode childNodeWithName:@"camera4" recursively:YES];
            
            //don't let the default transition to animate the fov, we will animate the fov separatly
            double dstFov = target.camera.xFov;
            target.camera.xFov = controller.view.pointOfView.camera.xFov;
            
            //long duration
            float duration = 2.0;
            
            //animate the point of view with default timing function
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:duration];
            
            controller.view.pointOfView = target;
            
            [SCNTransaction commit];
            
            //animate the fov with a ease in/out timing function
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:duration];
            [SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            
            controller.view.pointOfView.camera.xFov = dstFov;
            
            [SCNTransaction commit];
        }
            break;
            
        case 8:
        {
            //switch back to original camera quickly
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.75];
            
            controller.view.pointOfView = controller.cameraNode;
            
            [SCNTransaction commit];
        }
            break;
    }
    
    [SCNTransaction commit];
}

- (void)orderOutWithPresentionViewController:(ASCPresentationViewController *)controller {
    //restore default point of view before leaving this slide
    [SCNTransaction begin];
    controller.view.pointOfView = controller.cameraNode;
    [SCNTransaction commit];
}

@end
