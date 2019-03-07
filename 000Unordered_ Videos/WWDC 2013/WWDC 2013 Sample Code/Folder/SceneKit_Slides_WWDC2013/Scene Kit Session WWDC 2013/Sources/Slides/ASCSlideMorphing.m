/*
     File: ASCSlideMorphing.m
 Abstract:  Morphing slide. 
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

@interface ASCSlideMorphing : ASCSlide
@end

@implementation ASCSlideMorphing

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentation {
    //retrieve the text manager
    ASCSlideTextManager *textManager = [self textManager];
    
    //add some text
    [textManager setTitle:@"Morphing"];
    [textManager addBullet:@"Linear morph between multiple targets" atLevel:0];
    
    //create a node that will own the 3d map
    SCNNode *intermediateNode = [SCNNode node];
    
    //place and scale it
    intermediateNode.position = SCNVector3Make(6, 9, 0);
    intermediateNode.scale = SCNVector3Make(1.4, 1, 1);
    
    //add to the slide
    [self.ground addChildNode:intermediateNode];
    
    //load the model named "foldingMap" and add to our "intermediateNode"
    SCNNode *model = [intermediateNode asc_addChildNodeNamed:@"Map" fromSceneNamed:@"foldingMap" withScale:25];
    
    //move model and make hidden
    model.position = SCNVector3Make(0, 0, 0);
    model.opacity = 0.0;
    
    //use a bunch of shader modifiers to simulate an ambient occlusion when the map is folded
    NSString *geomSrc = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mapGeometry" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
    NSString *fragSrc = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mapFragment" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
    NSString *lightSrc = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mapLighting" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
    
    model.geometry.shaderModifiers = @{ SCNShaderModifierEntryPointGeometry      : geomSrc,
                                        SCNShaderModifierEntryPointFragment      : fragSrc,
                                        SCNShaderModifierEntryPointLightingModel : lightSrc };
}

- (NSUInteger)numberOfSteps {
    return 8;
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)controller {
    //animate by default
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.0];
    
    switch (index) {
        case 0:
        {
            //intial state - no ambient occlusion
            [SCNTransaction setAnimationDuration:0.0];
            
            SCNNode *map = [self.rootNode childNodeWithName:@"Map" recursively:YES];
            [map.geometry setValue:@0 forKey:@"ambientOcclusionYFactor"];
        }
            break;
        case 1:
        {
            //reveal the map
            SCNNode *map = [self.rootNode childNodeWithName:@"Map" recursively:YES];
            map.opacity = 1.;
            
            //remove text
            ASCSlideTextManager *textManager = self.textManager;
            [textManager flipOutTextType:ASCTextTypeBullet];
            
            //show gauges
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0];
            
            //gauge for target A
            SCNNode* node = [SCNNode asc_gaugeNodeWithTitle:@"Target A" progressNodeName:@"gauge1"];
            node.name = @"gauge1-group";
            [self.rootNode addChildNode:node];
            node.position = SCNVector3Make(-10.5, 15, -5);
            
            //gauge for target B
            node = [SCNNode asc_gaugeNodeWithTitle:@"Target B" progressNodeName:@"gauge2"];
            node.name = @"gauge2-group";
            [self.rootNode addChildNode:node];
            node.position = SCNVector3Make(-10.5, 13, -5);
            
            [SCNTransaction commit];
        }
            break;
        case 2:
        {
            SCNNode *map = [self.rootNode childNodeWithName:@"Map" recursively:YES];
            
            //update gauge A
            SCNNode *gauge = [self.rootNode childNodeWithName:@"gauge1" recursively:YES];
            gauge.scale = SCNVector3Make(1, 1, 1);
            
            //update morph
            [map.morpher setWeight:0.65 forTargetAtIndex:0];
            SCNNode *shadowPlane = [map childNodes][0];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.1];
            gauge.opacity = 1.0;
            [SCNTransaction commit];
            
            //resize the shadow plane behind the map
            shadowPlane.scale = SCNVector3Make(0.35, 1, 1);
            
            //rotate a little bit
            map.parentNode.rotation = SCNVector4Make(1, 0, 0, -M_PI_4*0.75);
        }
            break;
        case 3:
        {
            SCNNode *map = [self.rootNode childNodeWithName:@"Map" recursively:YES];
            
            //update gauge A
            SCNNode *gauge = [self.rootNode childNodeWithName:@"gauge1" recursively:YES];
            gauge.scale = SCNVector3Make(1, 0.01, 1);
            
            //remove morph
            [map.morpher setWeight:0 forTargetAtIndex:0];
            SCNNode *shadowPlane = [map childNodes][0];
            
            //rescale shadow plane
            shadowPlane.scale = SCNVector3Make(1, 1, 1);
            
            //reset rotation
            map.parentNode.rotation = SCNVector4Make(1, 0, 0, 0);
            
            [SCNTransaction setCompletionBlock:^{
                [SCNTransaction begin];
                [SCNTransaction setAnimationDuration:0.5];
                gauge.opacity = 0.0;
                [SCNTransaction commit];
            }];

        }
            break;
        case 4:
        {
            SCNNode *map = [self.rootNode childNodeWithName:@"Map" recursively:YES];
            
            //update gauge
            SCNNode *gauge = [self.rootNode childNodeWithName:@"gauge2" recursively:YES];
            gauge.scale = SCNVector3Make(1, 1, 1);
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.1];
            gauge.opacity = 1.0;
            [SCNTransaction commit];
            
            //update morph (target2)
            [map.morpher setWeight:0.4 forTargetAtIndex:1];
            SCNNode *shadowPlane = [map childNodes][0];
            
            //rescale shadow plane
            shadowPlane.scale = SCNVector3Make(1, 0.6, 1);
            
            //rotate a little bit
            map.parentNode.rotation = SCNVector4Make(0, 1, 0, -M_PI_4*0.5);
        }
            break;
        case 5:
        {
            SCNNode *map = [self.rootNode childNodeWithName:@"Map" recursively:YES];
            
            //update gauge B
            SCNNode *gauge = [self.rootNode childNodeWithName:@"gauge2" recursively:YES];
            gauge.scale = SCNVector3Make(1, 0.01, 1);
            
            //update morph
            [map.morpher setWeight:0 forTargetAtIndex:1];
            SCNNode *shadowPlane = [map childNodes][0];
            
            //resize shadow plane
            shadowPlane.scale = SCNVector3Make(1, 1, 1);
            
            //reset rotation
            map.parentNode.rotation = SCNVector4Make(0, 1, 0, 0);
            
            [SCNTransaction setCompletionBlock:^{
                [SCNTransaction begin];
                [SCNTransaction setAnimationDuration:0.5];
                gauge.opacity = 0.0;
                [SCNTransaction commit];
            }];
        }
            break;
        case 6:
        {
            SCNNode *map = [self.rootNode childNodeWithName:@"Map" recursively:YES];
            
            //update gauges A and B
            SCNNode *gauge = [self.rootNode childNodeWithName:@"gauge1" recursively:YES];
            gauge.scale = SCNVector3Make(1, 1, 1);
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.1];
            gauge.opacity = 1.0;
            [SCNTransaction commit];
            
            gauge = [self.rootNode childNodeWithName:@"gauge2" recursively:YES];
            gauge.scale = SCNVector3Make(1, 1, 1);
            
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.1];
            gauge.opacity = 1.0;
            [SCNTransaction commit];
            
            //update morph targets
            [map.morpher setWeight:0.65 forTargetAtIndex:0];
            [map.morpher setWeight:0.3 forTargetAtIndex:1];
            
            //rescale shadow plane
            SCNNode *shadowPlane = [map childNodes][0];
            shadowPlane.scale = SCNVector3Make(0.4, 0.7, 1);
            shadowPlane.opacity = 0.2;
            
            //tweak ambient occlusion
            [map.geometry setValue:@0.35 forKey:@"ambientOcclusionYFactor"];
            
            //move and rotate the map a little bit
            map.position = SCNVector3Make(0, 0, 5);
            map.parentNode.rotation = SCNVector4Make(0, 1, 0, -M_PI_4*0.5);
            map.rotation = SCNVector4Make(1, 0, 0, -M_PI_4*0.75);
        }
            break;
        case 7:
        {
            [SCNTransaction setAnimationDuration:0.5];
            
            //hide the map
            SCNNode *map = [self.rootNode childNodeWithName:@"Map" recursively:YES];
            map.opacity = 0;
            
            //hide gauges
            SCNNode *gauge = [self.rootNode childNodeWithName:@"gauge1-group" recursively:YES];
            gauge.opacity = 0.0;
            gauge = [self.rootNode childNodeWithName:@"gauge2-group" recursively:YES];
            gauge.opacity = 0.0;
            
            //show some text
            ASCSlideTextManager *textManager = self.textManager;
            
            [textManager setSubtitle:@"SCNMorpher"];
            [textManager addBullet:@"Topology must match" atLevel:0];
            [textManager addBullet:@"Can be loaded from DAEs" atLevel:0];
            [textManager addBullet:@"Can be created programmatically" atLevel:0];
            
        }
            break;
    }
    [SCNTransaction commit];
}

@end
