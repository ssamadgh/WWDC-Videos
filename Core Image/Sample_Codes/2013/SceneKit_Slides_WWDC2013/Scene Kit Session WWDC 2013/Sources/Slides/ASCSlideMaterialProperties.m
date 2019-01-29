/*
     File: ASCSlideMaterialProperties.m
 Abstract: Illustrates how the different material properties affect the appearance of an object.
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

@interface ASCSlideMaterialProperties : ASCSlide
@end

@implementation ASCSlideMaterialProperties {
    SCNNode *_earthNode;
    SCNNode *_cloudsNode;
    
    SCNVector3 _cameraOriginalPosition;
}

- (NSUInteger)numberOfSteps {
    return 18;
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentationViewController
{
    // Create a node for Earth and another node to display clouds
    // Use the 'pivot' property to tilt Earth because we don't want to see the north pole.
    _earthNode = [SCNNode node];
    _earthNode.pivot = CATransform3DMakeRotation(M_PI * 0.1, 1, 0, 0);
    _earthNode.position = SCNVector3Make(6, 7.2, -2);
    _earthNode.geometry = [SCNSphere sphereWithRadius:7.2];
    
    _cloudsNode = [SCNNode node];
    _cloudsNode.geometry = [SCNSphere sphereWithRadius:7.9];
    
    [self.groundNode addChildNode:_earthNode];
    [_earthNode addChildNode:_cloudsNode];
    
    // Initially hide everything
    _earthNode.opacity = 0.0;
    _cloudsNode.opacity = 0.0;
    
    _earthNode.geometry.firstMaterial.ambient.intensity = 0;
    _earthNode.geometry.firstMaterial.normal.intensity = 0;
    _earthNode.geometry.firstMaterial.reflective.intensity = 0;
    _earthNode.geometry.firstMaterial.emission.intensity = 0;
    
    // Use a shader modifier to display an environment map independently of the lighting model used
    _earthNode.geometry.shaderModifiers = @{ SCNShaderModifierEntryPointFragment :
                                                 @" _output.color.rgb -= _surface.reflective.rgb * _lightingContribution.diffuse;"
                                             @"_output.color.rgb += _surface.reflective.rgb;" };
    
    // Add animations
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    rotationAnimation.duration = 40.0;
    rotationAnimation.repeatCount = FLT_MAX;
    rotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    [_earthNode addAnimation:rotationAnimation forKey:nil];
    
    rotationAnimation.duration = 100.0;
    [_cloudsNode addAnimation:rotationAnimation forKey:nil];
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.0];
    
    switch (index) {
        case 0:
            // Set the slide's title and add some code
            self.textManager.title = @"Materials";
            
            [self.textManager addBullet:@"Diffuse" atLevel:0];
            [self.textManager addBullet:@"Ambient" atLevel:0];
            [self.textManager addBullet:@"Specular and shininess" atLevel:0];
            [self.textManager addBullet:@"Normal" atLevel:0];
            [self.textManager addBullet:@"Reflective" atLevel:0];
            [self.textManager addBullet:@"Emission" atLevel:0];
            [self.textManager addBullet:@"Transparent" atLevel:0];
            [self.textManager addBullet:@"Multiply" atLevel:0];
            break;
        case 1:
            _earthNode.opacity = 1.0;
            
            [presentationViewController updateLightingWithIntensities:@[@1]];
            break;
        case 2:
            _earthNode.geometry.firstMaterial.diffuse.contents = [NSColor blueColor];
            
            [self.textManager highlightBulletAtIndex:0];
            [self showCodeExample:@"material.#diffuse.contents# = [NSColor blueColor];" illustrationImageName:nil];
            break;
        case 3:
            _earthNode.geometry.firstMaterial.diffuse.contents = [NSImage imageNamed:@"earth-diffuse"];
            
            [self showCodeExample:@"material.#diffuse.contents# =" illustrationImageName:@"earth-diffuse-mini"];
            break;
        case 4:
            _earthNode.geometry.firstMaterial.ambient.contents = [NSImage imageNamed:@"earth-diffuse"];
            _earthNode.geometry.firstMaterial.ambient.intensity = 1;
            
            [self.textManager highlightBulletAtIndex:1];
            [self showCodeExample:@"material.#ambient#.contents =" illustrationImageName:@"earth-diffuse-mini"];
            [presentationViewController updateLightingWithIntensities:self.lightIntensities];
            break;
        case 5:
            _earthNode.geometry.firstMaterial.shininess = 0.1;
            _earthNode.geometry.firstMaterial.specular.contents = [NSColor whiteColor];
            
            [self.textManager highlightBulletAtIndex:2];
            [self showCodeExample:@"material.#specular#.contents = [NSColor whiteColor];" illustrationImageName:nil];
            break;
        case 6:
            _earthNode.geometry.firstMaterial.specular.contents = [NSImage imageNamed:@"earth-specular"];
            
            [self showCodeExample:@"material.#specular#.contents =" illustrationImageName:@"earth-specular-mini"];
            break;
        case 7:
            _earthNode.geometry.firstMaterial.normal.contents = [NSImage imageNamed:@"earth-bump"];
            _earthNode.geometry.firstMaterial.normal.intensity = 1.3;
            
            [self.textManager highlightBulletAtIndex:3];
            [self showCodeExample:@"material.#normal#.contents =" illustrationImageName:@"earth-bump"];
            break;
        case 8:
        {
            _earthNode.geometry.firstMaterial.reflective.contents = [NSImage imageNamed:@"earth-reflective"];
            _earthNode.geometry.firstMaterial.reflective.intensity = 0.7;
            _earthNode.geometry.firstMaterial.specular.intensity = 0.0;
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:2.0];
            [SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            {
                _cameraOriginalPosition = presentationViewController.cameraHandle.position;
                presentationViewController.cameraHandle.position = [presentationViewController.cameraHandle convertPosition:SCNVector3Make(6, 0, -10.11) toNode:  presentationViewController.cameraHandle.parentNode];
                
            }
            [SCNTransaction commit];
            
            [self.textManager highlightBulletAtIndex:4];
            [self showCodeExample:@"material.#reflective#.contents =" illustrationImageName:@"earth-reflective"];
            break;
        }
        case 9:
        {
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            [SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            {
                presentationViewController.cameraHandle.position = _cameraOriginalPosition;
            }
            [SCNTransaction commit];
            break;
        }
        case 10:
            _earthNode.geometry.firstMaterial.emission.contents = [NSImage imageNamed:@"earth-emissive"];
            _earthNode.geometry.firstMaterial.reflective.intensity = 0.3;
            _earthNode.geometry.firstMaterial.emission.intensity = 0.5;
            
            [self.textManager highlightBulletAtIndex:5];
            [self showCodeExample:@"material.#emission#.contents =" illustrationImageName:@"earth-emissive-mini2"];
            break;
        case 11:
            _earthNode.geometry.firstMaterial.emission.intensity = 1.0;
            _earthNode.geometry.firstMaterial.reflective.intensity = 0.1;
            
            [self showCodeExample:nil illustrationImageName:nil];
            [presentationViewController updateLightingWithIntensities:@[@0.01]]; // keeping the intensity non null avoids an unnecessary shader recompilation
            break;
        case 12:
            _earthNode.geometry.firstMaterial.reflective.intensity = 0.3;
            
            [presentationViewController updateLightingWithIntensities:self.lightIntensities];
            break;
        case 13:
            _earthNode.geometry.firstMaterial.emission.intensity = 0.0;
            _cloudsNode.opacity = 0.9;
            
            [self.textManager highlightBulletAtIndex:6];
            break;
        case 14:
        {
            // This effect can also be achieved with an image with some transparency set as the contents of the 'diffuse' property
            _cloudsNode.geometry.firstMaterial.transparent.contents = [NSImage imageNamed:@"cloudsTransparency"];
            _cloudsNode.geometry.firstMaterial.transparencyMode = SCNTransparencyModeRGBZero;
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0];
            {
                _cloudsNode.geometry.firstMaterial.transparency = 0;
            }
            [SCNTransaction commit];
            
            _cloudsNode.geometry.firstMaterial.transparency = 1;
            
            [self showCodeExample:@"material.#transparent#.contents =" illustrationImageName:@"cloudsTransparency-mini"];
            break;
        }
        case 15:
            _earthNode.geometry.firstMaterial.multiply.contents = [NSColor colorWithDeviceRed:1.0 green:204/255.0 blue:102/255.0 alpha:1];
            
            [self.textManager highlightBulletAtIndex:7];
            [self showCodeExample:@"material.#mutliply#.contents = [NSColor yellowColor];" illustrationImageName:nil];
            break;
        case 16:
            _earthNode.geometry.firstMaterial.emission.intensity = 1.0;
            _earthNode.geometry.firstMaterial.reflective.intensity = 0.1;
            
            [self showCodeExample:nil illustrationImageName:nil];
            [presentationViewController updateLightingWithIntensities:@[@0.01]];
            break;
        case 17:
            _earthNode.geometry.firstMaterial.emission.intensity = 0.0;
            _earthNode.geometry.firstMaterial.reflective.intensity = 0.3;
            
            [presentationViewController updateLightingWithIntensities:self.lightIntensities];
            break;
    }
    
    [SCNTransaction commit];
}

- (void)showCodeExample:(NSString *)code illustrationImageName:(NSString *)imageName {
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:0];
    {
        [self.textManager fadeOutTextOfType:ASCTextTypeCode];
        
        if (code) {
            SCNNode *codeNode = [self.textManager addCode:code];
            
            SCNVector3 min, max;
            [codeNode getBoundingBoxMin:&min max:&max];
            
            if (imageName) {
                SCNNode *imageNode = [SCNNode asc_planeNodeWithImageNamed:imageName size:4.0 isLit:NO];
                imageNode.position = SCNVector3Make(max.x + 2.5, min.y + 0.2, 0);
                [codeNode addChildNode:imageNode];
                
                max.x += 4.0;
            }
            
            codeNode.position = SCNVector3Make(6 - (min.x + max.x) / 2, 10 - min.y, 0);
        }
    }
    [SCNTransaction commit];
}

@end
