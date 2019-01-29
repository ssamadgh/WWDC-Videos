/*
     File: ASCSlideShaderModifiers.m
 Abstract: Illustrates how shader modifiers work with several examples.
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

#define TEST_13810403 0

@interface ASCSlideShaderModifiers : ASCSlide
@end

@implementation ASCSlideShaderModifiers {
    SCNNode *_planeNode;
    SCNNode *_sphereNode;
    SCNNode *_torusNode;
    SCNNode *_xRayNode;
    SCNNode *_virusNode;
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentationViewController {
    // Set the slide's title and subtitle and add some text
    self.textManager.title = @"Shader Modifiers";
    
    [self.textManager addBullet:@"Inject custom GLSL code" atLevel:0];
    [self.textManager addBullet:@"Combines with Scene Kit’s shaders" atLevel:0];
    [self.textManager addBullet:@"Inject at specific stages" atLevel:0];
}

- (NSUInteger)numberOfSteps {
    return 15;
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    [SCNTransaction begin];
    
    switch (index) {
        case 1:
            [self.textManager flipOutTextOfType:ASCTextTypeBullet];
            
            self.textManager.subtitle = @"API";
            
            [self.textManager addEmptyLine];
            [self.textManager addCode:@"aMaterial.#shaderModifiers# = @{ <Entry Point> : <GLSL Code> };"];
            [self.textManager flipInTextOfType:ASCTextTypeCode];
            [self.textManager flipInTextOfType:ASCTextTypeSubtitle];
            
            break;
        case 2:
            [self.textManager flipOutTextOfType:ASCTextTypeCode];
            
            [self.textManager addEmptyLine];
            [self.textManager addCode:
             @"aMaterial.#shaderModifiers# = @{ \n"
             @"     SCNShaderModifierEntryPointFragment : \n"
             @"     @\"#_output#.color.rgb = vec3(1.0) - #_output#.color.rgb;\" \n"
             @"     };" ];
            
            [self.textManager flipInTextOfType:ASCTextTypeCode];
            
            break;
        case 3:
            [self.textManager flipOutTextOfType:ASCTextTypeCode];
            [self.textManager flipOutTextOfType:ASCTextTypeSubtitle];
            
            self.textManager.subtitle = @"Entry points";
            
            [self.textManager addBullet:@"Geometry" atLevel:0];
            [self.textManager addBullet:@"Surface" atLevel:0];
            [self.textManager addBullet:@"Lighting" atLevel:0];
            [self.textManager addBullet:@"Fragment" atLevel:0];
            [self.textManager flipInTextOfType:ASCTextTypeBullet];
            [self.textManager flipInTextOfType:ASCTextTypeSubtitle];
            
            break;
        case 4:
        {
            [SCNTransaction setAnimationDuration:1];
            
            [self.textManager highlightBulletAtIndex:0];
            
            // Create a (very) tesselated plane
            SCNPlane *plane = [SCNPlane planeWithWidth:10 height:10];
            plane.widthSegmentCount = 200;
            plane.heightSegmentCount = 200;
            
            // Setup the material (same as the floor)
            plane.firstMaterial.diffuse.wrapS = SCNWrapModeMirror;
            plane.firstMaterial.diffuse.wrapT = SCNWrapModeMirror;
            plane.firstMaterial.diffuse.contents = @"/Library/Desktop Pictures/Circles.jpg";
            plane.firstMaterial.diffuse.contentsTransform = CATransform3DScale(CATransform3DMakeRotation(M_PI / 4, 0, 0, 1), 0.5, 0.5, 1.0);
            plane.firstMaterial.specular.contents = [NSColor whiteColor];
            plane.firstMaterial.reflective.contents = [NSImage imageNamed:@"envmap"];
            plane.firstMaterial.reflective.intensity = 0.0;
            
            // Create a node to hold that plane
            _planeNode = [SCNNode node];
            _planeNode.position = SCNVector3Make(0, 0.1, 0);
            _planeNode.rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
            _planeNode.scale = SCNVector3Make(5, 5, 1);
            _planeNode.geometry = plane;
            [self.contentNode addChildNode:_planeNode];
            
            // Attach the "wave" shader modifier, and set an initial intensity value of 0
            NSString *geometryModifier = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"wave" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
            _planeNode.geometry.shaderModifiers = @{ SCNShaderModifierEntryPointGeometry : geometryModifier };
            [_planeNode.geometry setValue:@0.0 forKey:@"intensity"];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0];
            {
                // Show the pseudo code for the deformation
                SCNNode *textNode = [self.textManager addCode:
                                     @"aMaterial.shaderModifiers = @{ \n"
                                     @"    #SCNShaderModifierEntryPointGeometry# : \n"
                                     @"    @\"float len = length(#_geometry#.position.xz); \n"
                                     @"    _geometry.position.y = sin(6.0 * (len + u_time)); \n"
                                     @"    [...] \"};"];
                
                textNode.position = SCNVector3Make(8.5, 7, 0);
            }
            [SCNTransaction commit];
            break;
        }
        case 5:
        {
            // Progressively increase the intensity
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:2];
            {
                [_planeNode.geometry setValue:@1.0 forKey:@"intensity"];
                _planeNode.geometry.firstMaterial.reflective.intensity = 0.3;
            }
            [SCNTransaction commit];
            
            // Redraw forever
            presentationViewController.view.playing = YES;
            presentationViewController.view.loops = YES;
            break;
        }
        case 6:
        {
            [SCNTransaction setAnimationDuration:1.0];
            
            [self.textManager fadeOutTextOfType:ASCTextTypeCode];
            
            // Hide the plane used for the previous modifier
            [_planeNode.geometry setValue:@0.0 forKey:@"intensity"];
            _planeNode.geometry.firstMaterial.reflective.intensity = 0.0;
            _planeNode.opacity = 0.0;
            
            // Create a sphere to illustrate the "car paint" modifier
            SCNSphere *sphere = [SCNSphere sphereWithRadius:6];
            sphere.segmentCount = 100;
            sphere.firstMaterial.diffuse.contents = [NSImage imageNamed:@"noise.png"];
            sphere.firstMaterial.diffuse.wrapS = SCNWrapModeRepeat;
            sphere.firstMaterial.diffuse.wrapT = SCNWrapModeRepeat;
            sphere.firstMaterial.reflective.contents = [NSImage imageNamed:@"envmap3"];
            sphere.firstMaterial.fresnelExponent = 1.3;
            
            _sphereNode = [SCNNode nodeWithGeometry:sphere];
            _sphereNode.position = SCNVector3Make(5, 6, 0);
            [self.groundNode addChildNode:_sphereNode];
            
            // Attach the "car paint" shader modifier
            NSString *surfaceModifier = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"carPaint" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
            sphere.firstMaterial.shaderModifiers = @{ SCNShaderModifierEntryPointSurface : surfaceModifier };
            
            CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
            rotationAnimation.duration = 15.0;
            rotationAnimation.repeatCount = FLT_MAX;
            rotationAnimation.byValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, -M_PI*2)];
            [_sphereNode addAnimation:rotationAnimation forKey:nil];
            
            [self.textManager highlightBulletAtIndex:1];
            break;
        }
        case 7:
        {
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.5];
            [SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            {
                // Move the camera closer
                presentationViewController.cameraNode.position = SCNVector3Make(5, -0.5, -17);
            }
            [SCNTransaction commit];
            break;
        }
        case 8:
        {
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            [SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            {
                // Move back
                presentationViewController.cameraNode.position = SCNVector3Make(0, 0, 0);
            }
            [SCNTransaction commit];
            break;
        }
        case 9:
        {
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            {
                // Hide the sphere used for the previous modifier
                _sphereNode.opacity = 0.0;
                _sphereNode.position = SCNVector3Make(6, 4, -8);
            }
            [SCNTransaction commit];
            
            [SCNTransaction setAnimationDuration:0];
            
            [self.textManager highlightBulletAtIndex:2];
            
            // Load the model, animate
            SCNNode *intermediateNode = [SCNNode node];
            intermediateNode.position = SCNVector3Make(4, 0.1, 10);
            _torusNode = [intermediateNode asc_addChildNodeNamed:@"torus" fromSceneNamed:@"torus" withScale:11];
            
            CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
            rotationAnimation.duration = 10.0;
            rotationAnimation.repeatCount = FLT_MAX;
            rotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
            [_torusNode addAnimation:rotationAnimation forKey:nil];
            
            [self.groundNode addChildNode:intermediateNode];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                intermediateNode.position = SCNVector3Make(4, 0.1, 0);
            }
            [SCNTransaction commit];
            
            break;
        }
        case 10:
        {
            // Attach the shader modifier
            NSString *lightingModifier = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"toon" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
            _torusNode.geometry.shaderModifiers = @{ SCNShaderModifierEntryPointLightingModel : lightingModifier };
            break;
        }
        case 11:
        {
            [SCNTransaction setAnimationDuration:1];
            
            // Hide the torus used for the previous modifier
            _torusNode.position = SCNVector3Make(_torusNode.position.x, _torusNode.position.y, _torusNode.position.z-10);
            _torusNode.opacity = 0.0;
            
            // Load the model, animate
            SCNNode *intermediateNode = [SCNNode node];
            intermediateNode.position = SCNVector3Make(4, -2.6, 14);
            intermediateNode.scale = SCNVector3Make(70, 70, 70);
            
            _xRayNode = [intermediateNode asc_addChildNodeNamed:@"node" fromSceneNamed:@"bunny" withScale:12];
            _xRayNode.position = SCNVector3Make(0, 0, 0);
            _xRayNode.opacity = 0.0;
            
            [self.groundNode addChildNode:intermediateNode];
            
            CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
            rotationAnimation.duration = 10.0;
            rotationAnimation.repeatCount = FLT_MAX;
            rotationAnimation.fromValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, 0)];
            rotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
            [intermediateNode addAnimation:rotationAnimation forKey:nil];
            
            [self.textManager highlightBulletAtIndex:3];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1];
            {
                _xRayNode.opacity = 1.0;
                intermediateNode.position = SCNVector3Make(4, -2.6, -2);
            }
            [SCNTransaction commit];
            break;
        }
        case 12:
        {
            // Attach the "x ray" modifier
            NSString *fragmentModifier = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"xRay" withExtension:@"shader"] encoding:NSASCIIStringEncoding error:NULL];
            _xRayNode.geometry.shaderModifiers = @{ SCNShaderModifierEntryPointFragment : fragmentModifier };
            _xRayNode.geometry.firstMaterial.readsFromDepthBuffer = NO;
            break;
        }
        case 13:
        {
            // Highlight everything
            [self.textManager highlightBulletAtIndex:NSNotFound];
            
            // Hide the node used for the previous modifier
            _xRayNode.opacity = 0.0;
            _xRayNode.parentNode.position = SCNVector3Make(4, -2.6, -5);
            
            // Create the model
            SCNSphere *sphere = [SCNSphere sphereWithRadius:5];
            sphere.segmentCount = 150; // tesselate a lot
            
            _virusNode = [SCNNode nodeWithGeometry:sphere];
            _virusNode.position = SCNVector3Make(3, 6, 0);
            _virusNode.rotation = SCNVector4Make(1, 0, 0, self.pitch * M_PI / 180.0);
            [self.groundNode addChildNode:_virusNode];
            
            // Set the shader modifiers
            NSString *geometryModifier = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sm_geom" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
            NSString *surfaceModifier = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sm_surf" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
            NSString *lightingModifier = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sm_light" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
            NSString *fragmentModifier = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sm_frag" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
            
            _virusNode.geometry.firstMaterial.shaderModifiers = @{ SCNShaderModifierEntryPointGeometry      : geometryModifier,
                                                                   SCNShaderModifierEntryPointSurface       : surfaceModifier,
                                                                   SCNShaderModifierEntryPointLightingModel : lightingModifier,
                                                                   SCNShaderModifierEntryPointFragment      : fragmentModifier };
            break;
        }
        case 14:
        {
            [SCNTransaction setAnimationDuration:1.0];
            
            // Hide the node used for the previous modifier
            _virusNode.opacity = 0.0;
            _virusNode.position = SCNVector3Make(3, 6, -10);
            
            // Change the text
            [self.textManager fadeOutTextOfType:ASCTextTypeCode];
            [self.textManager flipOutTextOfType:ASCTextTypeBullet];
            [self.textManager flipOutTextOfType:ASCTextTypeSubtitle];
            
            self.textManager.subtitle = @"SCNShadable";
            
            [self.textManager addBullet:@"Protocol adopted by SCNMaterial and SCNGeometry" atLevel:0];
            [self.textManager addBullet:@"Shaders parameters are animatable" atLevel:0];
            [self.textManager addBullet:@"Texture samplers are bound to a SCNMaterialProperty" atLevel:0];
            
            [self.textManager addCode:
             @"#SCNMaterialProperty# *aProperty = \n"
             @"        [SCNMaterialProperty #materialPropertyWithContents:#anImage]; \n"
             @"[aMaterial setValue:aProperty forKey:@\"#aSampler#\"];"];
            
            [self.textManager flipInTextOfType:ASCTextTypeSubtitle];
            [self.textManager flipInTextOfType:ASCTextTypeBullet];
            [self.textManager flipInTextOfType:ASCTextTypeCode];
            break;
        }
    }
    
    [SCNTransaction commit];
}

- (void)willOrderOutWithPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    presentationViewController.view.playing = NO;
    presentationViewController.cameraNode.position = SCNVector3Make(0, 0, 0);
}

@end
