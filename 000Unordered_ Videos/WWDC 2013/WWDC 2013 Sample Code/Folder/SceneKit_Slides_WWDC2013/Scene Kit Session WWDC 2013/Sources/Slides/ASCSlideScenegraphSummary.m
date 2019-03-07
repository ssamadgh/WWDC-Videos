/*
     File: ASCSlideScenegraphSummary.m
 Abstract:  Scene graph summary slide. Recap the structure of the scene graph with an example 
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

@interface ASCSlideSceneGraphSummary : ASCSlide
@end

@implementation ASCSlideSceneGraphSummary

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentation {
    // setup the text of this slide
    ASCSlideTextManager *textManager = [self textManager];
    [textManager setTitle:@"Scene Graph"];
    [textManager setSubtitle:@"Summary"];
}

- (NSUInteger)numberOfSteps {
    return 6;
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)controller {
    switch (index) {
        case 0:
            break;
        case 1:
        {
            //add node 1 (sun)
            SCNNode *sunAnchor = [SCNNode node];
            sunAnchor.name = @"sun-anchor";
            sunAnchor.position = SCNVector3Make(0, 30, 0);
            
            // add a child representing a wireframe box
            SCNNode *subNode = [SCNNode node];
            [sunAnchor addChildNode:subNode];
            
            // rotate 45 degree
            subNode.rotation = SCNVector4Make(0, 1, 0, M_PI_4);
            
            // attach a box
            subNode.geometry = [SCNBox boxWithWidth:1 height:1 length:1 chamferRadius:0];
            
            // use the wireframe texture
            subNode.geometry.firstMaterial.diffuse.contents = [NSImage imageNamed:@"box_wireframe"];
            
            // no lighting
            subNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
            
            // two sided
            subNode.geometry.firstMaterial.doubleSided = YES;
            
            [self.rootNode addChildNode:sunAnchor];
            
            //add another child (center of rotation of the earth around the sun)
            SCNNode *earthAxis = [SCNNode node];
            [sunAnchor addChildNode:earthAxis];
            
            // create and place the node that will contain the earth
            SCNNode *earthGroup = [SCNNode node];
            earthGroup.position = SCNVector3Make(15, 0, 0);
            earthGroup.name = @"earth-group";
            
            // create the earh node
            SCNNode *earth = [sunAnchor.childNodes[0] copy];
            earth.position = SCNVector3Make(0, 0, 0);
            earth.name = @"earth-anchor";
            
            // setup hierarchy earthAxis > earthGroup > earth
            [earthAxis addChildNode:earthGroup];
            [earthGroup addChildNode:earth];
            
            //rotate the earth around the sun
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
            animation.duration = 10.0;
            animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0,1,0,M_PI*2)];
            animation.repeatCount = FLT_MAX;
            [earthAxis addAnimation:animation forKey:@"aKey"];
        }
            break;
        case 2:
        {
            //retrieve the sun and earth parent
            SCNNode *earthAnchor = [self.rootNode childNodeWithName:@"earth-group" recursively:YES];
            SCNNode *sun = [self.rootNode childNodeWithName:@"sun-anchor" recursively:YES];
            
            //and a new node (center of rotation of the moon around the earth)
            SCNNode *moonAxis = [SCNNode node];
            [earthAnchor addChildNode:moonAxis];
            
            //add the moon
            SCNNode *moonAnchor = [sun.childNodes[0] copy];
            [moonAxis addChildNode:moonAnchor];
            
            //name and place it
            moonAnchor.name = @"moon-anchor";
            moonAnchor.position = SCNVector3Make(5, 0, 0);
            
            //rotate the moon around the earth
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
            animation.duration = 2 * 28*10.0/365;
            animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0,1,0,M_PI*2)];
            animation.repeatCount = FLT_MAX;
            [moonAxis addAnimation:animation forKey:@"aKey"];
            
            //rotate the moon itself
            animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
            animation.duration = 2 * 28*10.0/365;
            animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0,1,0,M_PI*2)];
            animation.repeatCount = FLT_MAX;
            [moonAnchor addAnimation:animation forKey:@"aKey"];
        }
            break;
        case 3:
        {
            //add geometries (sphere) to represent the planets
            SCNNode *sunAnchor = [self.rootNode childNodeWithName:@"sun-anchor" recursively:YES];
            sunAnchor.geometry = [SCNSphere sphereWithRadius:2.5];
            
            SCNNode *earthAnchor = [self.rootNode childNodeWithName:@"earth-anchor" recursively:YES];
            earthAnchor.geometry = [SCNSphere sphereWithRadius:1.5];
            
            SCNNode *moonAnchor = [self.rootNode childNodeWithName:@"moon-anchor" recursively:YES];
            moonAnchor.geometry = [SCNSphere sphereWithRadius:0.75];
            
            //rotate the earth
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
            animation.duration = 1.0;
            animation.fromValue = [NSValue valueWithSCNVector4:SCNVector4Make(0,1,0,0)];
            animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0,1,0,M_PI*2)];
            animation.repeatCount = FLT_MAX;
            [earthAnchor addAnimation:animation forKey:@"earth rotation"];
            
            //add a plane with a texture to represent the orbits
            SCNNode *orbit = [SCNNode node];
            orbit.opacity = 0.4;
            orbit.geometry = [SCNPlane planeWithWidth:31 height:31];
            orbit.geometry.firstMaterial.diffuse.contents = [NSImage imageNamed:@"orbit"];
            orbit.geometry.firstMaterial.diffuse.mipFilter = SCNLinearFiltering;
            orbit.rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
            //no lighting
            orbit.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
            [sunAnchor addChildNode:orbit];
        }
            break;
        case 4:  //add materials
        {
            SCNNode *sunAnchor = [self.rootNode childNodeWithName:@"sun-anchor" recursively:YES];
            SCNNode *earthAnchor = [self.rootNode childNodeWithName:@"earth-anchor" recursively:YES];
            SCNNode *moonAnchor = [self.rootNode childNodeWithName:@"moon-anchor" recursively:YES];
            
            //add halo to the sun (a simple plane with a texture and no write to depth)
            SCNNode *halo = [SCNNode node];
            halo.geometry = [SCNPlane planeWithWidth:30 height:30];
            halo.rotation = SCNVector4Make(1, 0, 0, self.pitch * M_PI / 180.0);
            halo.geometry.firstMaterial.diffuse.contents = [NSImage imageNamed:@"sun-halo"];
            halo.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
            halo.geometry.firstMaterial.writesToDepthBuffer = 0;
            halo.opacity = 0.2;
            halo.name = @"halo";
            [sunAnchor addChildNode:halo];
            
            // configure the materials
            earthAnchor.geometry.firstMaterial.diffuse.contents = [NSImage imageNamed:@"earth-diffuse-mini"];
            earthAnchor.geometry.firstMaterial.emission.contents = [NSImage imageNamed:@"earth-emissive-mini"];
            earthAnchor.geometry.firstMaterial.specular.contents = [NSImage imageNamed:@"earth-specular-mini"];
            moonAnchor.geometry.firstMaterial.diffuse.contents = [NSImage imageNamed:@"moon"];
            sunAnchor.geometry.firstMaterial.multiply.contents = [NSImage imageNamed:@"sun"];
            sunAnchor.geometry.firstMaterial.diffuse.contents = [NSImage imageNamed:@"sun"];
            sunAnchor.geometry.firstMaterial.multiply.intensity = 0.5;
            sunAnchor.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
            
            //repeat the textures
            sunAnchor.geometry.firstMaterial.multiply.wrapS = SCNRepeat;
            sunAnchor.geometry.firstMaterial.diffuse.wrapS = SCNRepeat;
            sunAnchor.geometry.firstMaterial.multiply.wrapT = SCNRepeat;
            sunAnchor.geometry.firstMaterial.diffuse.wrapT = SCNRepeat;
            
            // use the same texture for ambient and diffuse
            earthAnchor.geometry.firstMaterial.locksAmbientWithDiffuse = YES;
            moonAnchor.geometry.firstMaterial.locksAmbientWithDiffuse = YES;
            sunAnchor.geometry.firstMaterial.locksAmbientWithDiffuse = YES;
            
            // configure highlight of the materials
            earthAnchor.geometry.firstMaterial.shininess = 0.1;
            earthAnchor.geometry.firstMaterial.specular.intensity = 0.5;
            moonAnchor.geometry.firstMaterial.specular.contents = [NSColor grayColor];
            
#define SUN_SCALE_1 3
#define SUN_SCALE_2 5
            
            //animate the sun textures
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"contentsTransform"];
            animation.duration = 10.0;
            animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(0, 0, 0), CATransform3DMakeScale(SUN_SCALE_1, SUN_SCALE_1, SUN_SCALE_1))];
            animation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(1, 0, 0), CATransform3DMakeScale(SUN_SCALE_1, SUN_SCALE_1, SUN_SCALE_1))];
            animation.repeatCount = FLT_MAX;
            [sunAnchor.geometry.firstMaterial.diffuse addAnimation:animation forKey:@"sun-texture"];
            
            animation = [CABasicAnimation animationWithKeyPath:@"contentsTransform"];
            animation.duration = 30.0;
            animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(0, 0, 0), CATransform3DMakeScale(SUN_SCALE_2, SUN_SCALE_2, SUN_SCALE_2))];
            animation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(1, 0, 0), CATransform3DMakeScale(SUN_SCALE_2, SUN_SCALE_2, SUN_SCALE_2))];
            animation.repeatCount = FLT_MAX;
            [sunAnchor.geometry.firstMaterial.multiply addAnimation:animation forKey:@"sun-texture2"];
        }
            break;
        case 5: //add light
        {
            //retrieve the sun
            SCNNode *sunAnchor = [self.rootNode childNodeWithName:@"sun-anchor" recursively:YES];
            SCNNode *halo = [self.rootNode childNodeWithName:@"halo" recursively:YES];
            
            //create a node
            SCNNode *lightNode = [SCNNode node];
            
            //attach a light (off)
            lightNode.light = [SCNLight light];
            lightNode.light.color = [NSColor blackColor];
            lightNode.light.type = SCNLightTypeOmni;
            
            //configure attenuation distances because we don't want to lit the floor
            [lightNode.light setAttribute:@20 forKey:SCNLightAttenuationEndKey];
            [lightNode.light setAttribute:@19.5 forKey:SCNLightAttenuationStartKey];
            
            //add the light
            [sunAnchor addChildNode:lightNode];
            
            //switch on (animated)
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1];
            
            lightNode.light.color = [NSColor whiteColor];
            [controller updateLightingWithIntensities:@[@0.0]]; //switch off other lights
            halo.opacity = 0.5; //make halo stronger
            
            [SCNTransaction commit];
        }
            break;
    }
}

@end
