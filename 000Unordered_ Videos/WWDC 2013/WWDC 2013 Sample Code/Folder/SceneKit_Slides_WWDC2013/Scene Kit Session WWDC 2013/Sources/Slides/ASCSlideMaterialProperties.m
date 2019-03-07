/*
     File: ASCSlideMaterialProperties.m
 Abstract:  Introducing material properties slide. 
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

@interface ASCSlideMaterialProperties : ASCSlide
@end

@implementation ASCSlideMaterialProperties

- (NSUInteger)numberOfSteps {
    return 18;
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentation {
    //retrieve the text manager and add some text
    ASCSlideTextManager *textManager = [self textManager];
    [textManager setTitle:@"Materials"];
    
    [textManager addBullet:@"Diffuse" atLevel:0];
    [textManager addBullet:@"Ambient" atLevel:0];
    [textManager addBullet:@"Specular and shininess" atLevel:0];
    [textManager addBullet:@"Normal" atLevel:0];
    [textManager addBullet:@"Reflective" atLevel:0];
    [textManager addBullet:@"Emission" atLevel:0];
    [textManager addBullet:@"Transparent" atLevel:0];
    [textManager addBullet:@"Multiply" atLevel:0];
    
    /* create 2 nodes to represent and animate the earth model.
     The hierarchy is axis > earth
     "axis" is used to tilt the earth because we don't want to see the pole
     The geometry will be attached to "earth" and the rotation animation will be set to earth as well.
     */
    SCNNode *axis = [SCNNode node];
    SCNNode *earth = [SCNNode node];
    
    //tilt the earth
    axis.rotation = SCNVector4Make(1, 0, 0, M_PI*0.1);
    
    //place it
    axis.position = SCNVector3Make(6, 7.2, -2);
    
    //setup hierarchy
    [axis addChildNode:earth];
    
    //name the eath for later retrieval
    earth.name = @"earth";
    
    //attach the geometry
    earth.geometry = [SCNSphere sphereWithRadius:7.2];
    
    //add to the ground
    [self.ground addChildNode:axis];

    //rotate the earth forever
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    rotationAnimation.duration = 40.0;
    rotationAnimation.repeatCount = FLT_MAX;
    rotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI*2)];
    [earth addAnimation:rotationAnimation forKey:nil];
    
    //create a node that will own the clouds
    SCNNode *clouds = [SCNNode node];
    
    //make the clouds a child of the earth
    [earth addChildNode:clouds];
    
    //name the coulds and attach a geometry
    clouds.name = @"clouds";
    clouds.geometry = [SCNSphere sphereWithRadius:7.9];
    
    //rotate the clouds forever 
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    rotationAnimation.duration = 100.0;
    rotationAnimation.repeatCount = FLT_MAX;
    rotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI*2)];
    [clouds addAnimation:rotationAnimation forKey:nil];
}

- (void)showCode:(NSString *)code withImageNamed:(NSString *)imageName {
    //disable animations when replacing code
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:0];
    
    //remove old code
    [self.textManager fadeOutTextType:ASCTextTypeCode];
    
    //add new code
    if (code) {
        SCNNode *codeNode = [self.textManager addCode:code];
        
        SCNVector3 min, max;
        [codeNode getBoundingBoxMin:&min max:&max];
        
#define IMAGE_SIZE 4
        //add image if any
        if (imageName) {
            SCNNode *imageNode = [SCNNode asc_planeNodeWithImage:[NSImage imageNamed:imageName] size:IMAGE_SIZE isLit:NO];
            imageNode.position = SCNVector3Make(max.x + IMAGE_SIZE/2 + 0.5, min.y + 0.2, 0);
            [codeNode addChildNode:imageNode];
            
            max.x += IMAGE_SIZE;
        }
        
        //place it
        codeNode.position = SCNVector3Make(6 - (min.x + max.x) / 2, 10 - min.y, 0);
    }
    [SCNTransaction commit];
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)controller {
    //retrieve nodes
    SCNNode *earth = [self.ground childNodeWithName:@"earth" recursively:YES];
    SCNNode *clouds = [self.ground childNodeWithName:@"clouds" recursively:YES];
    
    //retrieve the text manager
    ASCSlideTextManager *textManager = self.textManager;

    //will need to save and restore the camera's position
    static SCNVector3 cameraOriginalPosition;
    
    //animate by default
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.0];
    
    switch (index) {
        case 0:
            //initial step
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0];
                
            //hide earth and cloud
            earth.opacity = 0.0;
            clouds.opacity = 0.0;
                
            //disable all properties
            earth.geometry.firstMaterial.ambient.intensity = 0;
            earth.geometry.firstMaterial.normal.intensity = 0;
            earth.geometry.firstMaterial.reflective.intensity = 0;
            earth.geometry.firstMaterial.emission.intensity = 0;
            
            //additive a shader modifier to make the reflective map independant of the lighting
            earth.geometry.shaderModifiers = @{ SCNShaderModifierEntryPointFragment :
                                                    @" _output.color.rgb -= _surface.reflective.rgb * _lightingContribution.diffuse;"
                                                "_output.color.rgb += _surface.reflective.rgb;" };
            [SCNTransaction commit];
            break;
        case 1:
            //add a sphere that will represent the earth
            [controller updateLightingWithIntensities:@[@1]];
                
            //show it
            earth.opacity = 1.0;
            break;
        case 2:
            //add diffuse color to the earth
            [textManager highlightBulletAtIndex:0];
            earth.geometry.firstMaterial.diffuse.contents = [NSColor blueColor];
            
            //show the code to do this
            [self showCode:@"material.#diffuse.contents# = [NSColor blueColor];" withImageNamed:nil];
            break;
        case 3:
            //add diffuse image
            earth.geometry.firstMaterial.diffuse.contents = [NSImage imageNamed:@"earth-diffuse"];
                
            //show the code to do this
            [self showCode:@"material.#diffuse.contents# =" withImageNamed:@"earth-diffuse-mini"];
        break;
        case 4:
            //add some ambient light
            [controller updateLightingWithIntensities:[self lightIntensities]];
                
            //highlight ambient bullet
            [textManager highlightBulletAtIndex:1];
                
            //set an image to the ambient property
            earth.geometry.firstMaterial.ambient.contents = [NSImage imageNamed:@"earth-diffuse"];
            earth.geometry.firstMaterial.ambient.intensity = 1;
        
            //show the code to do this
            [self showCode:@"material.#ambient#.contents =" withImageNamed:@"earth-diffuse-mini"];
            break;
        case 5:
            //highlight next bullet
            [textManager highlightBulletAtIndex:2];
            
            //add a specular color and tweak the shininess
            earth.geometry.firstMaterial.shininess = 0.1;
            earth.geometry.firstMaterial.specular.contents = [NSColor whiteColor];
            
            //show the code to do this
            [self showCode:@"material.#specular#.contents = [NSColor whiteColor];" withImageNamed:nil];
            break;
        case 6:
            //add a specular image
            earth.geometry.firstMaterial.specular.contents = [NSImage imageNamed:@"earth-specular"];

            //show the code to do this
            [self showCode:@"material.#specular#.contents =" withImageNamed:@"earth-specular-mini"];
            break;
        case 7:
            //highlight next bullet
            [textManager highlightBulletAtIndex:3];
                
            //add a normal map
            earth.geometry.firstMaterial.normal.contents = [NSImage imageNamed:@"earth-bump"];
            earth.geometry.firstMaterial.normal.intensity = 1.3;
            
            //show the code to do this
            [self showCode:@"material.#normal#.contents =" withImageNamed:@"earth-bump"];
            break;
        case 8:
        {
            //highlight next bullet
            [textManager highlightBulletAtIndex:4];

            //add a reflective image
            earth.geometry.firstMaterial.reflective.contents = [NSImage imageNamed:@"earth-reflective"];
            earth.geometry.firstMaterial.reflective.intensity = 0.7;
            
            //remove specular highlight
            earth.geometry.firstMaterial.specular.intensity = 0.0;

            //move the camera closer
            SCNVector3 tr = SCNVector3Make(6, 0, -10.11);
            tr = [controller.cameraHandle convertPosition:tr toNode:nil];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:2.0];
            [SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            
            //save previous position
            cameraOriginalPosition = controller.cameraHandle.position;
            
            //move
            controller.cameraHandle.position = SCNVector3Make(tr.x, tr.y, tr.z);
            
            [SCNTransaction commit];
            
            //show the code to do this
            [self showCode:@"material.#reflective#.contents =" withImageNamed:@"earth-reflective"];
        }
            break;
        case 9:
            //move the camera back
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            [SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            
            controller.cameraHandle.position = cameraOriginalPosition;
            
            [SCNTransaction commit];
            break;
        case 10:
            //highlight next bullet
            [textManager highlightBulletAtIndex:5];

            //add an emission image
            earth.geometry.firstMaterial.emission.contents = [NSImage imageNamed:@"earth-emissive"];
            earth.geometry.firstMaterial.reflective.intensity = 0.3;
            earth.geometry.firstMaterial.emission.intensity = 0.5;
                
            //show the code to do this
            [self showCode:@"material.#emission#.contents =" withImageNamed:@"earth-emissive-mini2"];
            break;
        case 11:
            //night mode, turn off lights (keep >0 to avoid unecesssary shader recompilation)
            [controller updateLightingWithIntensities:@[@0.01]];
            
            //push emissive to the max and reduce reflective
            earth.geometry.firstMaterial.emission.intensity = 1.0;
            earth.geometry.firstMaterial.reflective.intensity = 0.1;
            
            //hide the code
            [self showCode:nil withImageNamed:nil];
            break;
        case 12:
            //back to day mode - restore lights
            [controller updateLightingWithIntensities:[self lightIntensities]];

            //restore reflective
            earth.geometry.firstMaterial.reflective.intensity = 0.3;
            break;
        case 13:
            //highlight next bullet
            [textManager highlightBulletAtIndex:6];

            //remove emission
            earth.geometry.firstMaterial.emission.intensity = 0.0;
                
            //show clouds
            clouds.opacity = 0.9;
            break;
        case 14:
            //add transparency to the clouds
            //here we could also use an image with some transparency directly on the diffuse property
            //but we want to illustrate the "transparency" property, so let's use it.
            clouds.geometry.firstMaterial.transparent.contents = [NSImage imageNamed:@"cloudsTransparency"];
            clouds.geometry.firstMaterial.transparencyMode = SCNTransparencyModeRGBZero;
                
            //start at 0%
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0];
            clouds.geometry.firstMaterial.transparency = 0;
            [SCNTransaction commit];
            
            //fade in
            clouds.geometry.firstMaterial.transparency = 1;
                
            //show the code to do this
            [self showCode:@"material.#transparent#.contents =" withImageNamed:@"cloudsTransparency-mini"];
            break;
        case 15:
            //highlight next bullet
            [textManager highlightBulletAtIndex:7];
            
            //set a multiply color
            earth.geometry.firstMaterial.multiply.contents = [NSColor colorWithDeviceRed:1.0 green:204/255.0 blue:102/255.0 alpha:1];
            
            //show the code to do this
            [self showCode:@"material.#mutliply#.contents = [NSColor yellowColor];" withImageNamed:nil];
            break;
        case 16:
            //night mode - switch lights off again
            [controller updateLightingWithIntensities:@[@0.01]];
                
            //tweak emission and reflective factors
            earth.geometry.firstMaterial.emission.intensity = 1.0;
            earth.geometry.firstMaterial.reflective.intensity = 0.1;

            //remove the code
            [self showCode:nil withImageNamed:nil];
            break;
        case 17:
            //day mode - switch on lights
            [controller updateLightingWithIntensities:[self lightIntensities]];
            
            //tweak emission and reflective factors
            earth.geometry.firstMaterial.emission.intensity = 0.0;
            earth.geometry.firstMaterial.reflective.intensity = 0.3;
            break;
        default:
            break;
    }
    
    [SCNTransaction commit];
}

@end
