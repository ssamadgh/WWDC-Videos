/*
     File: ASCSlideLOD.m
 Abstract:  Level of detail slide. 
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

@interface ASCSlideLOD : ASCSlide
@end

@implementation ASCSlideLOD

- (NSUInteger)numberOfSteps {
    return 7;
}

//configure the material of a teapot
- (SCNNode *)loadAndAddTeapotWithResolutionIndex:(NSUInteger)index xPosition:(CGFloat)x toParent:(SCNNode *)parent
{
    //load the high-res teapot and add to "parent"
    SCNNode *teapot = [parent asc_addChildNodeNamed:[NSString stringWithFormat:@"Teapot%d", (int)index] fromSceneNamed:@"lod" withScale:11];

    //change the reflective intensity
    teapot.geometry.firstMaterial.reflective.intensity = 0.8;
    
    //change the fresnel exponent
    teapot.geometry.firstMaterial.fresnelExponent = 1.0;
    
    //place the teapot
    CGFloat yOffset = 0;
    if (index != 4)
        yOffset = index * 20.0;

    teapot.position = SCNVector3Make(x, -10 - yOffset, 0.1);
    
    return teapot;
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentation {
    //retrieve the text manager
    ASCSlideTextManager *textManager = [self textManager];
    
    //add a title
    [textManager setTitle:@"Levels of Detail"];

    //create a node that will own the teapots
    SCNNode *intermediateNode = [SCNNode node];
    
    //change orientation (z_up to y_up)
    intermediateNode.rotation = SCNVector4Make(1, 0, 0, -M_PI/2);

    //add to the scene
    [self.ground addChildNode:intermediateNode];
    
    //load the high-res teapot and add to "intermediateNode"
    [self loadAndAddTeapotWithResolutionIndex:0 xPosition:-5 toParent:intermediateNode];
    
    //load the low-res teapot and add to "intermediateNode"
    [self loadAndAddTeapotWithResolutionIndex:4 xPosition:5 toParent:intermediateNode];
    
    //other resolutions
    for (int i=1; i<4;i++) {
        //load this resolution and add to "intermediateNode"
        SCNNode *teapot = [self loadAndAddTeapotWithResolutionIndex:i xPosition:5 toParent:intermediateNode];
        teapot.opacity = 0.0;
    }
}

//remove the number of polygon from the scene
- (void)removeNumbers
{
    for (SCNNode *node in [self.ground childNodes]) {
        if ([node.name isEqualToString:@"number"]) {
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            [SCNTransaction setCompletionBlock:^{
                //on completion remove
                [node removeFromParentNode];
            }];
            //fade and move
            node.opacity = 0.0;
            node.position = SCNVector3Make(node.position.x, node.position.y, node.position.z-20);
            [SCNTransaction commit];
        }
    }
}

//add the polygon count at 'x' into the scene
- (SCNNode *) addNumber:(NSString *)numberString atX:(CGFloat) x
{
    //create a text frame object
    SCNNode *number = [SCNNode asc_labelNodeWithString:numberString];
    
    //extrude
    ((SCNText*)number.geometry).extrusionDepth = 5;
    
    //name it (for later retrieval)
    number.name= @"number";
    
    //configure the material
    number.geometry.firstMaterial.diffuse.contents = [NSColor orangeColor];
    number.geometry.firstMaterial.ambient.contents = [NSColor orangeColor];
    
    //scale and place
    number.scale = SCNVector3Make(0.04, 0.04, 0.04);
    number.position = SCNVector3Make(x, 50, 0);
    
    //add to the scene
    [self.ground addChildNode:number];
    
    return number;
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)controller {
    //retrieve the text manager
    ASCSlideTextManager *textManager = self.textManager;
    
    switch (index) {
        case 0:
            //initial state: hide every teapot
            for (int i=1; i<4; i++) {
                SCNNode *teapot = [self.ground childNodeWithName:[NSString stringWithFormat:@"Teapot%d", i] recursively:YES];
                teapot.opacity = 0.0;
            }
            break;
        case 1:    
            //move the camera back
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:3];
        
            controller.cameraNode.position = SCNVector3Make(0, 0, 200);

            //adjust the clipping plane of the camera
            controller.cameraNode.camera.zFar = 500.0;
            
            [SCNTransaction commit];
            break;
        case 2: //revert to original position
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            controller.cameraNode.position = SCNVector3Make(0, 0, 0);
            controller.cameraNode.camera.zFar = 100.0;
            [SCNTransaction commit];
            break;
        case 3:
        {
            SCNNode *numbers[5];
            
            //show polygon numbers
            numbers[0] = [self addNumber:@"64k" atX:-17];
            numbers[1] = [self addNumber:@"6k" atX:-9];
            numbers[2] = [self addNumber:@"3k" atX:-1];
            numbers[3] = [self addNumber:@"1k" atX:6.5];
            numbers[4] = [self addNumber:@"256" atX:14];
            
            //move the camera a little bit
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            
            controller.cameraHandle.position = SCNVector3Make(controller.cameraHandle.position.x, controller.cameraHandle.position.y+6, controller.cameraHandle.position.z);
            textManager.textNode.position = SCNVector3Make(textManager.textNode.position.x, textManager.textNode.position.y + 6, textManager.textNode.position.z);
            
            //show the other resolutions
            for (int i=0; i<5; i++) {
                SCNNode *teapot = [self.ground childNodeWithName:[NSString stringWithFormat:@"Teapot%d", i] recursively:YES];
                
                numbers[i].position = SCNVector3Make(numbers[i].position.x, 7, -5);
                
                teapot.opacity = 1.0;
                teapot.rotation = SCNVector4Make(0, 0, 1, M_PI_4);
                teapot.position = SCNVector3Make((i-2) * 8, 5, teapot.position.z);
            }
            
            [SCNTransaction commit];
        }
            break;

        case 4:
        {
            //new API-> show the new badge
            controller.showsNewInSceneKitBadge = YES;

            //remove the numbers
            [self removeNumbers];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            
            //add some text
            [textManager setSubtitle:@"SCNLevelOfDetail"];
            [textManager addCode:@"#SCNLevelOfDetail# *lod1 = [SCNLevelOfDetail #levelOfDetailWithGeometry:#aGeometry"];
            [textManager addCode:@"                                                  #worldSpaceDistance:#aDistance];"];
            [textManager addCode:@"geometry.#levelsOfDetail# = @[ lod1, lod2, ..., lodn ];"];
            
            //merge the teapots
            for (int i=0; i<5; i++) {
                SCNNode *teapot = [self.ground childNodeWithName:[NSString stringWithFormat:@"Teapot%d", i] recursively:YES];
                
                teapot.opacity = i==0 ? 1.0 : 0.0;
                teapot.rotation = SCNVector4Make(0, 0, 1, 0);
                teapot.position = SCNVector3Make(0, -5, teapot.position.z);
            }

            //move the camera
            controller.cameraHandle.position = SCNVector3Make(controller.cameraHandle.position.x, controller.cameraHandle.position.y-3, controller.cameraHandle.position.z);

            textManager.textNode.position = SCNVector3Make(textManager.textNode.position.x, textManager.textNode.position.y - 3, textManager.textNode.position.z);

            [SCNTransaction commit];
        }
            break;
        case 5:
        {
            //remove the new badge
            controller.showsNewInSceneKitBadge = NO;

            //change the lighting to remove the front light
            //right the main light
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:3.0];
            [controller updateLightingWithIntensities:@[@1.0, @0.0, @0.0, @0.0, @0.0, @0.3 ]];
            [controller riseMainLight:YES];
            
            //remove the subtitle and the code
            [textManager fadeOutTextType:ASCTextTypeTitle];
            [textManager fadeOutTextType:ASCTextTypeSubTitle];
            [textManager fadeOutTextType:ASCTextTypeCode];
            [SCNTransaction commit];            
            
            //retrieve the main teapot
            SCNNode *teapot = [self.ground childNodeWithName:@"Teapot0" recursively:YES];
            
            //build the LOD array
            NSMutableArray *lods = [NSMutableArray array];
            
            //distances to use for each LOD
            float distances[4] = {30, 50, 90, 150};
            
            //fill the LOD array
            for (int i=1; i<5; i++) {
                //get the geometry to use for this LOD
                SCNGeometry *lod = [self.ground childNodeWithName:[NSString stringWithFormat:@"Teapot%d", i] recursively:YES].geometry;
                
                if (lod != NULL) {
                    //unshare the material because we will highlight the LODs with a different color per LOD in the next step
                    lod.firstMaterial = [lod.firstMaterial copy]; //unshare material
                    
                    //initialize a LOD and add to the LOD array
                    [lods addObject:[SCNLevelOfDetail levelOfDetailWithGeometry:lod worldSpaceDistance:distances[i-1]]];
                }
                
            }
            
            //set the LODs to the main teapot
            [teapot.geometry setLevelsOfDetail:lods];

#define N_ROW 9
#define N_COL 12
#define ANIMATION_DELAY 0.05
#define MARGIN_X 12.0
#define MARGIN_Y 15.0
            
            //duplicate and move the teapots
            CFTimeInterval t0 = CACurrentMediaTime();
            CFTimeInterval delay = 0.2;
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0];
            
            //change the far clipping plane to see far
            controller.cameraNode.camera.zFar = 1000.0;
            
            //duplicate N_COLxN_ROW times
            for (int j=0; j<N_COL; j++) {
                for (int i=0; i<N_ROW; i++) {
                    //clone
                    SCNNode *clone = [teapot clone];
                    
                    //add to the scene
                    [teapot.parentNode addChildNode:clone];
                    
                    //animate
                    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
                    animation.additive = YES;
                    animation.duration = 1.0;
                    animation.toValue = [NSValue valueWithSCNVector3:SCNVector3Make((i-N_ROW/2) * MARGIN_X, 5 + (N_COL-j) * MARGIN_Y, 0)];
                    animation.fromValue = [NSValue valueWithSCNVector3:SCNVector3Make(0 ,0 , 0)];
                    
                    //desynchronize
                    animation.beginTime = t0+delay;
                    
                    //freeze at the end of the animation
                    animation.removedOnCompletion = NO;
                    animation.fillMode = kCAFillModeForwards;
                    
                    //add the animation
                    [clone addAnimation:animation forKey:nil];
                    
                    //animate the hidden property to automatically un-hide when the "move" animation starts
                    animation = [CABasicAnimation animationWithKeyPath:@"hidden"];
                    animation.duration = delay+0.01;
                    animation.fillMode = kCAFillModeBoth;
                    animation.fromValue = @1;
                    animation.toValue = @0;
                    
                    [clone addAnimation:animation forKey:nil];
                    
                    //compute next delay
                    delay += ANIMATION_DELAY;
                }
            }
            
            [SCNTransaction commit];
            
            //animate the camera while we duplicate the nodes
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0 + N_COL*N_ROW*ANIMATION_DELAY];
            
            //move the camera up
            SCNVector3 p = controller.cameraHandle.position;
            controller.cameraHandle.position = SCNVector3Make(p.x, p.y+5, p.z);

            //pitch the camera
            controller.cameraPitch.rotation = SCNVector4Make(1, 0, 0, controller.cameraPitch.rotation.w - (M_PI_4*0.1));
            
            [SCNTransaction commit];
        }
            break;
            
        case 6:
        {
            //highlight the level of details with colors
            SCNNode *teapot = [self.ground childNodeWithName:@"Teapot0" recursively:YES];

            NSArray *colors = @[[NSColor redColor], [NSColor orangeColor], [NSColor yellowColor], [NSColor greenColor]];
            
            //animate
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1];
            
            //set a different color per LOD
            for (int i=0; i<4; i++) {
                SCNLevelOfDetail *lod = teapot.geometry.levelsOfDetail[i];
                lod.geometry.firstMaterial.multiply.contents = colors[i];
            }
            
            [SCNTransaction commit];
        }
            break;
    }
    
}

- (void)orderOutWithPresentionViewController:(ASCPresentationViewController *)controller {
    //reset the camera and lights before leaving this slide
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:2.0];
    controller.cameraNode.camera.zFar = 100.0;
    [SCNTransaction commit];
    
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:0.5];
    [controller riseMainLight:NO];
    [SCNTransaction commit];
}

@end
