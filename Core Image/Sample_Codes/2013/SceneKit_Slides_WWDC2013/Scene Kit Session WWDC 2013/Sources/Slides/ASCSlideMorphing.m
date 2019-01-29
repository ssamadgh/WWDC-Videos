/*
     File: ASCSlideMorphing.m
 Abstract: Illustrates how morphing can be used.
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

@interface ASCSlideMorphing : ASCSlide
@end

@implementation ASCSlideMorphing {
    SCNNode *_mapNode;
    SCNNode *_gaugeANode, *_gaugeAProgressNode;
    SCNNode *_gaugeBNode, *_gaugeBProgressNode;
}

- (NSUInteger)numberOfSteps {
    return 8;
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentationViewController {
    // Load the scene
    SCNNode *intermediateNode = [SCNNode node];
    intermediateNode.position = SCNVector3Make(6, 9, 0);
    intermediateNode.scale = SCNVector3Make(1.4, 1, 1);
    [self.groundNode addChildNode:intermediateNode];
    
    _mapNode = [intermediateNode asc_addChildNodeNamed:@"Map" fromSceneNamed:@"foldingMap" withScale:25];
    _mapNode.position = SCNVector3Make(0, 0, 0);
    _mapNode.opacity = 0.0;
    
    // Use a bunch of shader modifiers to simulate ambient occlusion when the map is folded
    NSString *geometryModifier = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mapGeometry" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
    NSString *fragmentModifier = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mapFragment" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
    NSString *lightingModifier = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mapLighting" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
    
    _mapNode.geometry.shaderModifiers = @{ SCNShaderModifierEntryPointGeometry      : geometryModifier,
                                           SCNShaderModifierEntryPointFragment      : fragmentModifier,
                                           SCNShaderModifierEntryPointLightingModel : lightingModifier };
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    //animate by default
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.0];
    
    switch (index) {
        case 0:
        {
            [SCNTransaction setAnimationDuration:0.0];
            
            // Set the slide's title and subtitle and add some text
            self.textManager.title = @"Morphing";
            [self.textManager addBullet:@"Linear morph between multiple targets" atLevel:0];
            
            // Initial state, no ambient occlusion
            // This also shows how uniforms from shader modifiers can be set using KVC
            [_mapNode.geometry setValue:@0 forKey:@"ambientOcclusionYFactor"];
            break;
        }
        case 1:
        {
            [self.textManager flipOutTextOfType:ASCTextTypeBullet];
            
            // Reveal the map and show the gauges
            _mapNode.opacity = 1.0;
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0];
            {
                _gaugeANode = [SCNNode asc_gaugeNodeWithTitle:@"Target A" progressNode:&_gaugeAProgressNode];
                _gaugeANode.position = SCNVector3Make(-10.5, 15, -5);
                [self.contentNode addChildNode:_gaugeANode];
                
                _gaugeBNode = [SCNNode asc_gaugeNodeWithTitle:@"Target B" progressNode:&_gaugeBProgressNode];
                _gaugeBNode.position = SCNVector3Make(-10.5, 13, -5);
                [self.contentNode addChildNode:_gaugeBNode];
            }
            [SCNTransaction commit];
            break;
        }
        case 2:
        {
            // Morph and update the gauges
            _gaugeAProgressNode.scale = SCNVector3Make(1, 1, 1);
            [_mapNode.morpher setWeight:0.65 forTargetAtIndex:0];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.1];
            {
                _gaugeAProgressNode.opacity = 1.0;
            }
            [SCNTransaction commit];
            
            SCNNode *shadowPlane = _mapNode.childNodes[0];
            shadowPlane.scale = SCNVector3Make(0.35, 1, 1);
            
            _mapNode.parentNode.rotation = SCNVector4Make(1, 0, 0, -M_PI_4 * 0.75);
            break;
        }
        case 3:
        {
            // Morph and update the gauges
            _gaugeAProgressNode.scale = SCNVector3Make(1, 0.01, 1);
            [_mapNode.morpher setWeight:0 forTargetAtIndex:0];
            
            SCNNode *shadowPlane = _mapNode.childNodes[0];
            shadowPlane.scale = SCNVector3Make(1, 1, 1);
            
            _mapNode.parentNode.rotation = SCNVector4Make(1, 0, 0, 0);
            
            [SCNTransaction setCompletionBlock:^{
                [SCNTransaction begin];
                [SCNTransaction setAnimationDuration:0.5];
                {
                    _gaugeAProgressNode.opacity = 0.0;
                }
                [SCNTransaction commit];
            }];
            break;
        }
        case 4:
        {
            // Morph and update the gauges
            _gaugeBProgressNode.scale = SCNVector3Make(1, 1, 1);
            [_mapNode.morpher setWeight:0.4 forTargetAtIndex:1];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.1];
            {
                _gaugeBProgressNode.opacity = 1.0;
            }
            [SCNTransaction commit];
            
            SCNNode *shadowPlane = _mapNode.childNodes[0];
            shadowPlane.scale = SCNVector3Make(1, 0.6, 1);
            
            _mapNode.parentNode.rotation = SCNVector4Make(0, 1, 0, -M_PI_4 * 0.5);
            break;
        }
        case 5:
        {
            // Morph and update the gauges
            _gaugeBProgressNode.scale = SCNVector3Make(1, 0.01, 1);
            [_mapNode.morpher setWeight:0 forTargetAtIndex:1];
            
            SCNNode *shadowPlane = _mapNode.childNodes[0];
            shadowPlane.scale = SCNVector3Make(1, 1, 1);
            
            _mapNode.parentNode.rotation = SCNVector4Make(0, 1, 0, 0);
            
            [SCNTransaction setCompletionBlock:^{
                [SCNTransaction begin];
                [SCNTransaction setAnimationDuration:0.5];
                {
                    _gaugeBProgressNode.opacity = 0.0;
                }
                [SCNTransaction commit];
            }];
            break;
        }
        case 6:
        {
            // Morph and update the gauges
            _gaugeAProgressNode.scale = SCNVector3Make(1, 1, 1);
            _gaugeBProgressNode.scale = SCNVector3Make(1, 1, 1);
            
            [_mapNode.morpher setWeight:0.65 forTargetAtIndex:0];
            [_mapNode.morpher setWeight:0.30 forTargetAtIndex:1];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.1];
            {
                _gaugeAProgressNode.opacity = 1.0;
                _gaugeBProgressNode.opacity = 1.0;
            }
            [SCNTransaction commit];
            
            SCNNode *shadowPlane = _mapNode.childNodes[0];
            shadowPlane.scale = SCNVector3Make(0.4, 0.7, 1);
            shadowPlane.opacity = 0.2;
            
            [_mapNode.geometry setValue:@0.35 forKey:@"ambientOcclusionYFactor"];
            _mapNode.position = SCNVector3Make(0, 0, 5);
            _mapNode.parentNode.rotation = SCNVector4Make(0, 1, 0, -M_PI_4 * 0.5);
            _mapNode.rotation = SCNVector4Make(1, 0, 0, -M_PI_4 * 0.75);
            break;
        }
        case 7:
        {
            [SCNTransaction setAnimationDuration:0.5];
            
            // Hide everything and update the text
            _mapNode.opacity = 0;
            _gaugeANode.opacity = 0.0;
            _gaugeBNode.opacity = 0.0;
            
            self.textManager.subtitle = @"SCNMorpher";
            [self.textManager addBullet:@"Topology must match" atLevel:0];
            [self.textManager addBullet:@"Can be loaded from DAEs" atLevel:0];
            [self.textManager addBullet:@"Can be created programmatically" atLevel:0];
            
            break;
        }
    }
    [SCNTransaction commit];
}

@end
