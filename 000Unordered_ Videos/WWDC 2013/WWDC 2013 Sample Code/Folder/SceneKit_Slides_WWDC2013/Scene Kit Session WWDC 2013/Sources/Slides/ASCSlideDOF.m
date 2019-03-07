/*
     File: ASCSlideDOF.m
 Abstract:  Depth of field slide. 
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

@interface ASCSlideDOF : ASCSlide
@end

@implementation ASCSlideDOF

- (NSUInteger)numberOfSteps {
    return 6;
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentation {
    //retrieve the text manager and add some text
    ASCSlideTextManager *textManager = [self textManager];
    [textManager setTitle:@"Depth of Field"];
    [textManager setSubtitle:@"SCNCamera"];

    //create a node that will contain the chess board
    SCNNode *intermediateNode = [SCNNode node];
    
    //place and re-orient
#define SCALE 35.0
    intermediateNode.scale = SCNVector3Make(SCALE, SCALE, SCALE);
    intermediateNode.position = SCNVector3Make(0, 2.1, 20);
    intermediateNode.rotation = SCNVector4Make(1, 0, 0, -M_PI/2);
    
    //add to the scene
    [self.rootNode addChildNode:intermediateNode];
    
    //load the chess model and add to "intermediateNode"
    SCNNode *node = [intermediateNode asc_addChildNodeNamed:@"Line01" fromSceneNamed:@"chess" withScale:1];
    
    //retrieve the two materials (black / white) and tweak reflectivity and fresnel exponent to make them shinny
    //the materials are shared so we just need to upate two pieces (1 white / 1 black)
    SCNNode *bishop = [node childNodeWithName:@"bishop" recursively:YES];
    bishop.geometry.firstMaterial.reflective.intensity = 0.7;
    bishop.geometry.firstMaterial.fresnelExponent = 1.5;
    
    SCNNode *L = [node childNodeWithName:@"L" recursively:YES];
    L.geometry.firstMaterial.reflective.intensity = 0.7;
    L.geometry.firstMaterial.fresnelExponent = 1.5;
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)controller {
    //retrieve the camera and the text manager
    SCNNode *cameraNode = controller.cameraNode;
    ASCSlideTextManager *textManager = [self textManager];
    
    //animate by default
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.5];
    
    switch (index) {
        case 0:
            //intitial dof setup
            cameraNode.camera.focalDistance = 16;
            cameraNode.camera.focalSize = 1.5;
            cameraNode.camera.aperture = 0.3;
            break;
        case 1:
            [textManager addCode:@"aCamera.#focalDistance# = 16.0;"];
            [textManager addCode:@"aCamera.#focalBlurRadius# = 8.0;"];
            break;
        case 2:
            //turn on dof
            cameraNode.camera.focalBlurRadius = 8;
            break;
        case 3:
            //focus far
            cameraNode.camera.focalDistance = 35;
            cameraNode.camera.focalSize = 4;
            cameraNode.camera.aperture = 0.1;
                
            //updathe the code
            [textManager fadeOutTextType:ASCTextTypeCode];
            [textManager addEmptyLine];
            [textManager addCode:@"aCamera.#focalDistance# = #35.0#;"];
            [textManager addCode:@"aCamera.#focalBlurRadius# = 8.0;"];
            break;
        case 4:
            //remove the code
            [textManager fadeOutTextType:ASCTextTypeSubTitle];
            [textManager fadeOutTextType:ASCTextTypeCode];
                
            //move the camera and adjust focal distance
            controller.cameraHandle.position = [controller.cameraHandle convertPosition:SCNVector3Make(0, -3, -6) toNode:controller.cameraHandle.parentNode];
            cameraNode.camera.focalDistance = 27;
                
            //move the light back a little bit
            controller.mainLight.position = [controller.mainLight convertPosition:SCNVector3Make(0, 3, 6) toNode:controller.mainLight.parentNode];
            break;
        case 5:
            //focus front
            cameraNode.camera.focalDistance = 10;
            cameraNode.camera.focalSize = 1;
            cameraNode.camera.aperture = 0.3;
            break;
    }
    
    [SCNTransaction commit];
}

- (void)orderOutWithPresentionViewController:(ASCPresentationViewController *)controller {
    //restore camera settings before leaving this slide
    SCNNode *cameraNode = controller.view.pointOfView;
    cameraNode.camera.focalBlurRadius = 0;
}

@end
