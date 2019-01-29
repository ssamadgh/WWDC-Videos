/*
     File: ASCSlideScenegraphSummary.m
 Abstract: Recaps the structure of the scene graph with an example.
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

@interface ASCSlideSceneGraphSummary : ASCSlide {
    SCNNode *_sunNode;
    SCNNode *_sunHaloNode;
    SCNNode *_earthNode;
    SCNNode *_earthGroupNode;
    SCNNode *_moonNode;
    SCNNode *_wireframeBoxNode;
}
@end

@implementation ASCSlideSceneGraphSummary

- (NSUInteger)numberOfSteps {
    return 6;
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    switch (index) {
        case 0:
            // Set the slide's title and subtitle
            self.textManager.title = @"Scene Graph";
            self.textManager.subtitle = @"Summary";
            break;
        case 1:
        {
            // A node that will help visualize the position of the stars
            _wireframeBoxNode = [SCNNode node];
            _wireframeBoxNode.rotation = SCNVector4Make(0, 1, 0, M_PI_4);
            _wireframeBoxNode.geometry = [SCNBox boxWithWidth:1 height:1 length:1 chamferRadius:0];
            _wireframeBoxNode.geometry.firstMaterial.diffuse.contents = [NSImage imageNamed:@"box_wireframe"];
            _wireframeBoxNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant; // no lighting
            _wireframeBoxNode.geometry.firstMaterial.doubleSided = YES; // double sided
            
            // Sun
            _sunNode = [SCNNode node];
            _sunNode.position = SCNVector3Make(0, 30, 0);
            [self.contentNode addChildNode:_sunNode];
            [_sunNode addChildNode:[_wireframeBoxNode copy]];
            
            // Earth-rotation (center of rotation of the Earth around the Sun)
            SCNNode *earthRotationNode = [SCNNode node];
            [_sunNode addChildNode:earthRotationNode];
            
            // Earth-group (will contain the Earth, and the Moon)
            _earthGroupNode = [SCNNode node];
            _earthGroupNode.position = SCNVector3Make(15, 0, 0);
            [earthRotationNode addChildNode:_earthGroupNode];
            
            // Earth
            _earthNode = [_wireframeBoxNode copy];
            _earthNode.position = SCNVector3Make(0, 0, 0);
            [_earthGroupNode addChildNode:_earthNode];
            
            // Rotate the Earth around the Sun
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
            animation.duration = 10.0;
            animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
            animation.repeatCount = FLT_MAX;
            [earthRotationNode addAnimation:animation forKey:@"earth rotation around sun"];
            
            // Rotate the Earth
            animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
            animation.duration = 1.0;
            animation.fromValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, 0)];
            animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
            animation.repeatCount = FLT_MAX;
            [_earthNode addAnimation:animation forKey:@"earth rotation"];
            break;
        }
        case 2:
        {
            // Moon-rotation (center of rotation of the Moon around the Earth)
            SCNNode *moonRotationNode = [SCNNode node];
            [_earthGroupNode addChildNode:moonRotationNode];
       
            // Moon
            _moonNode = [_wireframeBoxNode copy];
            _moonNode.position = SCNVector3Make(5, 0, 0);
            [moonRotationNode addChildNode:_moonNode];
          
            // Rotate the moon around the Earth
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
            animation.duration = 1.5;
            animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
            animation.repeatCount = FLT_MAX;
            [moonRotationNode addAnimation:animation forKey:@"moon rotation around earth"];
            
            // Rotate the moon
            animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
            animation.duration = 1.5;
            animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
            animation.repeatCount = FLT_MAX;
            [_moonNode addAnimation:animation forKey:@"moon rotation"];
            break;
        }
        case 3:
        {
            // Add geometries (spheres) to represent the stars
            _sunNode.geometry = [SCNSphere sphereWithRadius:2.5];
            _earthNode.geometry = [SCNSphere sphereWithRadius:1.5];
            _moonNode.geometry = [SCNSphere sphereWithRadius:0.75];
            
            // Add a textured plane to represent Earth's orbit
            SCNNode *earthOrbit = [SCNNode node];
            earthOrbit.opacity = 0.4;
            earthOrbit.geometry = [SCNPlane planeWithWidth:31 height:31];
            earthOrbit.geometry.firstMaterial.diffuse.contents = [NSImage imageNamed:@"orbit"];
            earthOrbit.geometry.firstMaterial.diffuse.mipFilter = SCNFilterModeLinear;
            earthOrbit.rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
            earthOrbit.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant; // no lighting
            [_sunNode addChildNode:earthOrbit];
            break;
        }
        case 4:
        {
            // Add a halo to the Sun (a simple textured plane that does not write to depth)
            _sunHaloNode = [SCNNode node];
            _sunHaloNode.geometry = [SCNPlane planeWithWidth:30 height:30];
            _sunHaloNode.rotation = SCNVector4Make(1, 0, 0, self.pitch * M_PI / 180.0);
            _sunHaloNode.geometry.firstMaterial.diffuse.contents = [NSImage imageNamed:@"sun-halo"];
            _sunHaloNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant; // no lighting
            _sunHaloNode.geometry.firstMaterial.writesToDepthBuffer = NO; // do not write to depth
            _sunHaloNode.opacity = 0.2;
            [_sunNode addChildNode:_sunHaloNode];
            
            // Add materials to the stars
            _earthNode.geometry.firstMaterial.diffuse.contents = [NSImage imageNamed:@"earth-diffuse-mini"];
            _earthNode.geometry.firstMaterial.emission.contents = [NSImage imageNamed:@"earth-emissive-mini"];
            _earthNode.geometry.firstMaterial.specular.contents = [NSImage imageNamed:@"earth-specular-mini"];
            _moonNode.geometry.firstMaterial.diffuse.contents = [NSImage imageNamed:@"moon"];
            _sunNode.geometry.firstMaterial.multiply.contents = [NSImage imageNamed:@"sun"];
            _sunNode.geometry.firstMaterial.diffuse.contents = [NSImage imageNamed:@"sun"];
            _sunNode.geometry.firstMaterial.multiply.intensity = 0.5;
            _sunNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
            
            _sunNode.geometry.firstMaterial.multiply.wrapS =
            _sunNode.geometry.firstMaterial.diffuse.wrapS  =
            _sunNode.geometry.firstMaterial.multiply.wrapT =
            _sunNode.geometry.firstMaterial.diffuse.wrapT  = SCNWrapModeRepeat;
            
            _earthNode.geometry.firstMaterial.locksAmbientWithDiffuse =
            _moonNode.geometry.firstMaterial.locksAmbientWithDiffuse  =
            _sunNode.geometry.firstMaterial.locksAmbientWithDiffuse   = YES;
            
            _earthNode.geometry.firstMaterial.shininess = 0.1;
            _earthNode.geometry.firstMaterial.specular.intensity = 0.5;
            _moonNode.geometry.firstMaterial.specular.contents = [NSColor grayColor];
            
            // Achieve a lava effect by animating textures
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"contentsTransform"];
            animation.duration = 10.0;
            animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(0, 0, 0), CATransform3DMakeScale(3, 3, 3))];
            animation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(1, 0, 0), CATransform3DMakeScale(3, 3, 3))];
            animation.repeatCount = FLT_MAX;
            [_sunNode.geometry.firstMaterial.diffuse addAnimation:animation forKey:@"sun-texture"];
            
            animation = [CABasicAnimation animationWithKeyPath:@"contentsTransform"];
            animation.duration = 30.0;
            animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(0, 0, 0), CATransform3DMakeScale(5, 5, 5))];
            animation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(1, 0, 0), CATransform3DMakeScale(5, 5, 5))];
            animation.repeatCount = FLT_MAX;
            [_sunNode.geometry.firstMaterial.multiply addAnimation:animation forKey:@"sun-texture2"];
            break;
        }
        case 5:
        {
            // We will turn off all the lights in the scene and add a new light
            // to give the impression that the Sun lights the scene
            SCNNode *lightNode = [SCNNode node];
            lightNode.light = [SCNLight light];
            lightNode.light.color = [NSColor blackColor]; // initially switched off
            lightNode.light.type = SCNLightTypeOmni;
            [_sunNode addChildNode:lightNode];
            
            // Configure attenuation distances because we don't want to light the floor
            [lightNode.light setAttribute:@20 forKey:SCNLightAttenuationEndKey];
            [lightNode.light setAttribute:@19.5 forKey:SCNLightAttenuationStartKey];
            
            // Animation
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1];
            {
                lightNode.light.color = [NSColor whiteColor]; // switch on
                [presentationViewController updateLightingWithIntensities:@[@0.0]]; //switch off all the other lights
                _sunHaloNode.opacity = 0.5; // make the halo stronger
            }
            [SCNTransaction commit];
            break;
        }
    }
}

@end
