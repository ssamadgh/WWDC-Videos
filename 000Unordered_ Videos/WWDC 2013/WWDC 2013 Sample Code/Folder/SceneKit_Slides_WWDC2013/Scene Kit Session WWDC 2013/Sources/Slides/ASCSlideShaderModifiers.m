/*
     File: ASCSlideShaderModifiers.m
 Abstract:  "Shader modifiers" slide. 
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

#define TEST_13810403 0

@interface ASCSlideShaderModifiers : ASCSlide
@end

@implementation ASCSlideShaderModifiers

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentation {
    //retrieve the text manager
    ASCSlideTextManager *textManager = [self textManager];
    
    //add some text
    [textManager setTitle:@"Shader Modifiers"];
    [textManager addBullet:@"Inject custom GLSL code" atLevel:0];
    [textManager addBullet:@"Combines with Scene Kit’s shaders" atLevel:0];
    [textManager addBullet:@"Inject at specific stages" atLevel:0];
}

- (NSUInteger)numberOfSteps {
    return 15;
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)controller {
    ASCSlideTextManager *textManager = self.textManager;
    
    [SCNTransaction begin];
    
    switch (index) {
        case 0:
            break;
        case 1:
        {
            //remove the previous text
            [textManager flipOutTextType:ASCTextTypeBullet];
            
            //and new bullets
            [textManager setSubtitle:@"API"];
            
            [textManager addEmptyLine];
            [textManager addCode:@"aMaterial.#shaderModifiers# = @{ <Entry Point> : <GLSL Code> };"];
            [textManager flipInTextType:ASCTextTypeCode];
            [textManager flipInTextType:ASCTextTypeSubTitle];
        }
            break;
        case 2:
        {
            //remove the previous code
            [textManager flipOutTextType:ASCTextTypeCode];
            
            //add new code
            [textManager addEmptyLine];
            [textManager addCode:@"aMaterial.#shaderModifiers# = @{ "];
            [textManager addCode:@"     SCNShaderModifierEntryPointFragment : "];
            [textManager addCode:@"     @\"#_output#.color.rgb = vec3(1.0) - #_output#.color.rgb;\""];
            [textManager addCode:@"     };" ];
            
            [textManager flipInTextType:ASCTextTypeCode];
        }
            break;
        case 3:
        {
            //remove the previous text
            [textManager flipOutTextType:ASCTextTypeCode];
            [textManager flipOutTextType:ASCTextTypeSubTitle];
            
            //and new bullets
            [textManager setSubtitle:@"Entry points"];
            
            [textManager addBullet:@"Geometry" atLevel:0];
            [textManager addBullet:@"Surface" atLevel:0];
            [textManager addBullet:@"Lighting" atLevel:0];
            [textManager addBullet:@"Fragment" atLevel:0];
            [textManager flipInTextType:ASCTextTypeBullet];
            [textManager flipInTextType:ASCTextTypeSubTitle];
        }
            break;

        case 4: // Geometry shader modifier
        {
            [SCNTransaction setAnimationDuration:1];
            
            //highlight the first bullet
            [textManager highlightBulletAtIndex:0];
            
            //add a new node
            SCNNode *node = [SCNNode node];
            node.name = @"plane";
            node.position = SCNVector3Make(0, 0.1, 0);
            node.rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
            node.scale = SCNVector3Make(5, 5, 1);
            
            //attach a plan to it
            SCNPlane *plane = [SCNPlane planeWithWidth:10 height:10];
            node.geometry = plane;

            //tesselate a lot
            plane.widthSegmentCount = 200;
            plane.heightSegmentCount = 200;
            
            //setup the material (same as the floor)
            plane.firstMaterial.diffuse.contents = @"/Library/Desktop Pictures/Circles.jpg";
            plane.firstMaterial.diffuse.contentsTransform = CATransform3DScale(CATransform3DMakeRotation(M_PI/4, 0, 0, 1), .5,.5,1.0);
            plane.firstMaterial.diffuse.wrapS = SCNMirror;
            plane.firstMaterial.diffuse.wrapT = SCNMirror;
            plane.firstMaterial.reflective.contents = [NSImage imageNamed:@"envmap"];
            plane.firstMaterial.reflective.intensity = 0.0;
            plane.firstMaterial.specular.contents = [NSColor whiteColor];

            //hide
            node.opacity = 0.0;
            
            //add to the scene
            [self.rootNode addChildNode:node];
            
            //fade in
            node.opacity = 1.0;

            //attach wave shader modifier
            NSString *geomSrc = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"wave" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
            node.geometry.shaderModifiers = @{ SCNShaderModifierEntryPointGeometry : geomSrc };
                                               
            //show the pseudo code for the deformation
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0];
            
            //place the code here
            SCNVector3 textPos = SCNVector3Make(8.5, 7, 0);
            
            //add the text for the code
            SCNNode *textNode = [textManager addCode:@"aMaterial.shaderModifiers = @{"];
            textNode.position = textPos;
            textNode = [textManager addCode:@"    #SCNShaderModifierEntryPointGeometry# : "];
            textNode.position = textPos;
            textNode = [textManager addCode:@"    @\"float len = length(#_geometry#.position.xz);"];
            textNode.position = textPos;
            textNode = [textManager addCode:@"    _geometry.position.y = sin(6.0 * (len + u_time));"];
            textNode.position = textPos;
            textNode = [textManager addCode:@"    [...] \"};"];
            textNode.position = textPos;
            
            //disable the shader modifier for now
            [node.geometry setValue:@0.0 forKey:@"intensity"];
            
            [SCNTransaction commit];
        }
            break;
        case 5:
        {
            //retrieve the plane
            SCNNode *node = [self.rootNode childNodeWithName:@"plane" recursively:YES];
            
            //turn on the shader modifier progressively
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:2];
            [node.geometry setValue:@1.0 forKey:@"intensity"];
            node.geometry.firstMaterial.reflective.intensity = 0.3;
            [SCNTransaction commit];
            
            //redraw forever
            controller.view.playing = YES;
            controller.view.loops = YES;
        }
            break;
        case 6: // Surface
        {
            [SCNTransaction setAnimationDuration:1.0];
            
            //remove the pseudo code
            [textManager fadeOutTextType:ASCTextTypeCode];
            
            //hide the plane used from the previous step
            SCNNode *node = [self.rootNode childNodeWithName:@"plane" recursively:YES];
            [node.geometry setValue:@0.0 forKey:@"intensity"];
            node.geometry.firstMaterial.reflective.intensity = 0.0;
            node.opacity = 0.0;
            
            //add a sphere to illustrate the car paint modifier
            SCNSphere *sphereGeom = [SCNSphere sphereWithRadius:6];
            sphereGeom.segmentCount = 100;
            SCNNode *sphere = [SCNNode nodeWithGeometry:sphereGeom];
            sphere.name = @"sphere";
            sphere.position = SCNVector3Make(5, 6, 0);
            [self.ground addChildNode:sphere];

            SCNMaterial *mat = sphereGeom.firstMaterial;

            //rotate the model
            CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
            rotationAnimation.duration = 15.0;
            rotationAnimation.repeatCount = FLT_MAX;
            rotationAnimation.byValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, -M_PI*2)];
            [sphere addAnimation:rotationAnimation forKey:nil];


            // Apply noise texture
            mat.diffuse.contents = [NSImage imageNamed:@"noise.png"];
            mat.diffuse.wrapS = SCNWrapModeRepeat;
            mat.diffuse.wrapT = SCNWrapModeRepeat;
             
            // Apply envMap texture
            mat.reflective.contents = [NSImage imageNamed:@"envmap3"];
            mat.fresnelExponent = 1.3;

            //load shader modifiers
            NSString *surfSrc = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"carPaint" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
            
            //attach shader modifiers
            if (surfSrc)
                mat.shaderModifiers = @{
                                        SCNShaderModifierEntryPointSurface : surfSrc,
                                        };

            //highlight "surface"
            [textManager highlightBulletAtIndex:1];
        }
            break;
        case 7: // move closer
        {
            //move the camera closer
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.5];
            [SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            
            //move
            controller.cameraNode.position = SCNVector3Make(5, -0.5, -17);
            
            [SCNTransaction commit];
        }
            break;
        case 8:
        {
            //move the camera back
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            [SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            
            controller.cameraNode.position = SCNVector3Make(0, 0, 0);
            [SCNTransaction commit];
        }
            break;
        case 9: // Lighting shader modifier
        {
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            
            //hide the sphere of the previous steps
            SCNNode *node = [self.rootNode childNodeWithName:@"sphere" recursively:YES];
            node.opacity = 0.0;
            node.position = SCNVector3Make(6, 4, -8);
            
            [SCNTransaction commit];
            
            //highlight "lighting"
            [textManager highlightBulletAtIndex:2];
            
            [SCNTransaction setAnimationDuration:0];
            
            //create a node that will own the torus and place it
            SCNNode *intermediateNode = [SCNNode node];
            intermediateNode.position = SCNVector3Make(4, 0.1, 10);
            
            //load the torus model
            SCNNode *model = [intermediateNode asc_addChildNodeNamed:@"torus" fromSceneNamed:@"torus" withScale:11];
            
            //rotate the torus
            CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
            rotationAnimation.duration = 10.0;
            rotationAnimation.repeatCount = FLT_MAX;
            rotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI*2)];
            [model addAnimation:rotationAnimation forKey:nil];
            
            //add to the scene
            [self.ground addChildNode:intermediateNode];
            
            //move the torus in
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            
            intermediateNode.position = SCNVector3Make(4, 0.1, 0);
            
            [SCNTransaction commit];
        }
            break;
        case 10:
        {
            //retrieve the torus
            SCNNode *torus = [self.ground childNodeWithName:@"torus" recursively:YES];
            
            //attach a shader modifier
            NSString *lightingModifier = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"toon" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];

            torus.geometry.shaderModifiers = @{ SCNShaderModifierEntryPointLightingModel : lightingModifier };
        }
            break;
        case 11:
        {
            //fragment
            [SCNTransaction setAnimationDuration:1];
            
            //hode the torus
            SCNNode *torus = [self.ground childNodeWithName:@"torus" recursively:YES];
            torus.position = SCNVector3Make(torus.position.x, torus.position.y, torus.position.z-10);
            torus.opacity = 0.0;
            
            //remove on completion
            [SCNTransaction setCompletionBlock:^{
                [torus removeFromParentNode];
            }];
                
            //add a model
            SCNNode *intermediateNode = [SCNNode node];
            SCNNode *model = [intermediateNode asc_addChildNodeNamed:@"node" fromSceneNamed:@"bunny" withScale:12];
            model.name = @"xrayModel";
            
            //adjust the center of rotation of this model
            model.position = SCNVector3Make(0, 0, 0);
            //model.pivot = CATransform3DMakeTranslation(0, , 0.75);
            
            //start hidden
            model.opacity = 0.0;
            
            //place it
            intermediateNode.position = SCNVector3Make(4, -2.6, 14);
            intermediateNode.scale = SCNVector3Make(70, 70, 70);
            
            //add to the scene
            [self.ground addChildNode:intermediateNode];
            
            //retrieve the propeller
            SCNNode *animatedNode = [model childNodeWithName:@"prop" recursively:YES];
                
            //rotate the model
            CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
            rotationAnimation.duration = 10.0;
            rotationAnimation.repeatCount = FLT_MAX;
            rotationAnimation.fromValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, 0)];
            rotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI*2)];
            [intermediateNode addAnimation:rotationAnimation forKey:nil];
                
            //make animation system time based
            for (NSString *key in [animatedNode animationKeys]) {
                CAAnimation *animation = [animatedNode animationForKey:key];
                animation.usesSceneTimeBase = NO;
                animation.repeatCount = FLT_MAX;
                [animatedNode addAnimation:animation forKey:key];
            }
            
            //highlight "fragment"
            [textManager highlightBulletAtIndex:3];
            
            //fade in the model
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1];
            model.opacity = 1.0;
            intermediateNode.position = SCNVector3Make(4, -2.6, -2);
            [SCNTransaction commit];
        }
            break;
        case 12:
        {
            //retrieve the model
            SCNNode *node = [self.ground childNodeWithName:@"xrayModel" recursively:YES];
            
            //attach the xray modifier
            NSURL* shaderURL = [[NSBundle mainBundle] URLForResource:@"xRay" withExtension:@"shader"];
            NSString *shader = [NSString stringWithContentsOfURL:shaderURL encoding:NSASCIIStringEncoding error:NULL];
            node.geometry.shaderModifiers = @{ SCNShaderModifierEntryPointFragment : shader };
            
            //disable reading from the depth buffer
            node.geometry.firstMaterial.readsFromDepthBuffer = NO;            
        }
            break;
        case 13: //All combined
        {
            //highlight all
            [textManager highlightBulletAtIndex:NSNotFound];
            
            //remove the previous model
            SCNNode *node = [self.ground childNodeWithName:@"xrayModel" recursively:YES];
            
            //hide it
            node.opacity = 0.0;
            node.parentNode.position = SCNVector3Make(4, -2.6, -5);

            //create the molecule
            SCNSphere *sphereGeom = [SCNSphere sphereWithRadius:5];
            [sphereGeom setSegmentCount:150]; //tesselate a lot
            
            //create a node and attach the geometry
            SCNNode *virus = [SCNNode nodeWithGeometry:sphereGeom];
            virus.name = @"virus";
            virus.position = SCNVector3Make(3, 6, 0);
            virus.rotation = SCNVector4Make(1, 0, 0, self.pitch * M_PI / 180.0);
            [self.ground addChildNode:virus];
            
            //load shader modifiers
            NSString *geomSrc = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sm_geom" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
            NSString *surfSrc = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sm_surf" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
            NSString *liteSrc = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sm_light" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
            NSString *fragSrc = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sm_frag" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
            
            //attach shader modifiers
            virus.geometry.firstMaterial.shaderModifiers = @{ SCNShaderModifierEntryPointGeometry      : geomSrc,
                                                              SCNShaderModifierEntryPointSurface       : surfSrc,
                                                              SCNShaderModifierEntryPointLightingModel : liteSrc,
                                                              SCNShaderModifierEntryPointFragment      : fragSrc };
        }
            break;
        case 14: // Conclusion
        {
            [SCNTransaction setAnimationDuration:1.0];
            
            //retrieve the xray model
            SCNNode *node = [self.ground childNodeWithName:@"virus" recursively:YES];
            
            //hide it
            node.opacity = 0.0;
            node.position = SCNVector3Make(3, 6, -10);

            //remove the text
            [textManager fadeOutTextType:ASCTextTypeCode];
            [textManager flipOutTextType:ASCTextTypeBullet];
            [textManager flipOutTextType:ASCTextTypeSubTitle];
            
            //add new bullets
            [textManager setSubtitle:@"SCNShadable"];
            [textManager addBullet:@"Protocol adopted by SCNMaterial and SCNGeometry" atLevel:0];
            [textManager addBullet:@"Shaders parameters are animatable" atLevel:0];
            [textManager addBullet:@"Texture samplers are bound to a SCNMaterialProperty" atLevel:0];
            [textManager addCode:@"#SCNMaterialProperty# *aProperty = "];
            [textManager addCode:@"        [SCNMaterialProperty #materialPropertyWithContents:#anImage];"];
            [textManager addCode:@"[aMaterial setValue:aProperty forKey:@\"#aSampler#\"];"];
            
            //flip in the new text
            [textManager flipInTextType:ASCTextTypeSubTitle];
            [textManager flipInTextType:ASCTextTypeBullet];
            [textManager flipInTextType:ASCTextTypeCode];
        } break;
    }
    
    [SCNTransaction commit];
}

- (void)orderOutWithPresentionViewController:(ASCPresentationViewController *)controller {
    //stop playing before leaving this slide
    controller.view.playing = NO;

    controller.cameraNode.position = SCNVector3Make(0,0,0);

}

@end
