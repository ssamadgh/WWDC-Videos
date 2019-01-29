/*
     File: ASCSlideDOF.m
 Abstract: Explains what the depth of field effect is and shows an example.
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

@interface ASCSlideDOF : ASCSlide
@end

@implementation ASCSlideDOF

- (NSUInteger)numberOfSteps {
    return 6;
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentationViewController {
    // Set the slide's title and subtitle
    self.textManager.title = @"Depth of Field";
    self.textManager.subtitle = @"SCNCamera";

    // Create a node that will contain the chess board
    SCNNode *intermediateNode = [SCNNode node];
    intermediateNode.scale = SCNVector3Make(35.0, 35.0, 35.0);
    intermediateNode.position = SCNVector3Make(0, 2.1, 20);
    intermediateNode.rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
    [self.contentNode addChildNode:intermediateNode];
    
    // Load the chess model and add to "intermediateNode"
    [intermediateNode asc_addChildNodeNamed:@"Line01" fromSceneNamed:@"chess" withScale:1];
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.5];
   
    SCNNode *cameraNode = presentationViewController.cameraNode;
    
    switch (index) {
        case 0:
            break;
        case 1:
            // Add a code snippet
            [self.textManager addCode:
             @"aCamera.#focalDistance# = 16.0; \n"
             @"aCamera.#focalBlurRadius# = 8.0;"];
            break;
        case 2:
            // Turn on DOF to illustrate the code snippet
            cameraNode.camera.focalDistance = 16;
            cameraNode.camera.focalSize = 1.5;
            cameraNode.camera.aperture = 0.3;
            cameraNode.camera.focalBlurRadius = 8;
            break;
        case 3:
            // Focus far away
            cameraNode.camera.focalDistance = 35;
            cameraNode.camera.focalSize = 4;
            cameraNode.camera.aperture = 0.1;
                
            // and update the code snippet
            [self.textManager fadeOutTextOfType:ASCTextTypeCode];
            [self.textManager addEmptyLine];
            [self.textManager addCode:
             @"aCamera.#focalDistance# = #35.0#; \n"
             @"aCamera.#focalBlurRadius# = 8.0;"];
            break;
        case 4:
            // Remove the code
            [self.textManager fadeOutTextOfType:ASCTextTypeSubtitle];
            [self.textManager fadeOutTextOfType:ASCTextTypeCode];
                
            // Move the camera and adjust tje focal distance
            presentationViewController.cameraHandle.position = [presentationViewController.cameraHandle convertPosition:SCNVector3Make(0, -3, -6) toNode:presentationViewController.cameraHandle.parentNode];
            cameraNode.camera.focalDistance = 27;
                
            // Move the light back a little
            presentationViewController.mainLight.position = [presentationViewController.mainLight convertPosition:SCNVector3Make(0, 3, 6) toNode:presentationViewController.mainLight.parentNode];
            break;
        case 5:
            // Focus near
            cameraNode.camera.focalDistance = 10;
            cameraNode.camera.focalSize = 1;
            cameraNode.camera.aperture = 0.3;
            break;
    }
    
    [SCNTransaction commit];
}

- (void)willOrderOutWithPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    // Restore camera settings before leaving this slide
    presentationViewController.view.pointOfView.camera.focalBlurRadius = 0;
}

@end
