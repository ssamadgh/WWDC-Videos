/*
     File: ASCSlideLOD.m
 Abstract: Explains what levels of detail are and shows an example of how to use them.
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

@interface ASCSlideLOD : ASCSlide
@end

@implementation ASCSlideLOD

- (NSUInteger)numberOfSteps {
    return 7;
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentationViewController {
    // Set the slide's title
    self.textManager.title = @"Levels of Detail";
    
    presentationViewController.view.allowsCameraControl = YES;
    
    // Create a node that will hold the teapots
    SCNNode *intermediateNode = [SCNNode node];
    intermediateNode.rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
    [self.groundNode addChildNode:intermediateNode];
    
    // Load two resolutions
    [self addTeapotWithResolutionIndex:0 positionX:-5 parent:intermediateNode]; // high res
    [self addTeapotWithResolutionIndex:4 positionX:+5 parent:intermediateNode]; // low res
    
    // Load the other resolutions but hide them
    for (NSUInteger i = 1; i < 4; i++) {
        SCNNode *teapotNode = [self addTeapotWithResolutionIndex:i positionX:5 parent:intermediateNode];
        teapotNode.opacity = 0.0;
    }
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    switch (index) {
        case 0:
            // Hide everything (in case the user went backward)
            for (NSUInteger i = 1; i < 4; i++) {
                SCNNode *teapot = [self.groundNode childNodeWithName:[NSString stringWithFormat:@"Teapot%ld", i] recursively:YES];
                teapot.opacity = 0.0;
            }
            break;
        case 1:
        {
            // Move the camera and adjust the clipping plane
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:3];
            {
                presentationViewController.cameraNode.position = SCNVector3Make(0, 0, 200);
                presentationViewController.cameraNode.camera.zFar = 500.0;
            }
            [SCNTransaction commit];
            break;
        }
        case 2:
        {
            // Revert to original position
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                presentationViewController.cameraNode.position = SCNVector3Make(0, 0, 0);
                presentationViewController.cameraNode.camera.zFar = 100.0;
            }
            [SCNTransaction commit];
            break;
        }
        case 3:
        {
            NSArray *numberNodes = @[[self addNodeWithNumber:@"64k" positionX:-17],
                                     [self addNodeWithNumber:@"6k" positionX:-9],
                                     [self addNodeWithNumber:@"3k" positionX:-1],
                                     [self addNodeWithNumber:@"1k" positionX:6.5],
                                     [self addNodeWithNumber:@"256" positionX:14]];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                // Move the camera and the text
                presentationViewController.cameraHandle.position = SCNVector3Make(presentationViewController.cameraHandle.position.x, presentationViewController.cameraHandle.position.y + 6, presentationViewController.cameraHandle.position.z);
                self.textManager.textNode.position = SCNVector3Make(self.textManager.textNode.position.x, self.textManager.textNode.position.y + 6, self.textManager.textNode.position.z);
                
                // Show the remaining resolutions
                for (NSInteger i = 0; i < 5; i++) {
                    SCNNode *numberNode = numberNodes[i];
                    numberNode.position = SCNVector3Make(numberNode.position.x, 7, -5);
                    
                    SCNNode *teapot = [self.groundNode childNodeWithName:[NSString stringWithFormat:@"Teapot%ld", (long)i] recursively:YES];
                    teapot.opacity = 1.0;
                    teapot.rotation = SCNVector4Make(0, 0, 1, M_PI_4);
                    teapot.position = SCNVector3Make((i - 2) * 8, 5, teapot.position.z);
                }
                
                [SCNTransaction commit];
                break;
            }
        }
        case 4:
        {
            presentationViewController.showsNewInSceneKitBadge = YES;
            
            // Remove the numbers
            [self removeNumberNodes];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                // Add some text and code
                self.textManager.subtitle = @"SCNLevelOfDetail";
                
                [self.textManager addCode:
                 @"#SCNLevelOfDetail# *lod1 = [SCNLevelOfDetail #levelOfDetailWithGeometry:#aGeometry \n"
                 @"                                                  #worldSpaceDistance:#aDistance]; \n"
                 @"geometry.#levelsOfDetail# = @[ lod1, lod2, ..., lodn ];"];
                
                // Animation the merge
                for (NSUInteger i = 0; i < 5; i++) {
                    SCNNode *teapot = [self.groundNode childNodeWithName:[NSString stringWithFormat:@"Teapot%lu", (unsigned long)i] recursively:YES];
                    
                    teapot.opacity = i == 0 ? 1.0 : 0.0;
                    teapot.rotation = SCNVector4Make(0, 0, 1, 0);
                    teapot.position = SCNVector3Make(0, -5, teapot.position.z);
                }
                
                // Move the camera and the text
                presentationViewController.cameraHandle.position = SCNVector3Make(presentationViewController.cameraHandle.position.x, presentationViewController.cameraHandle.position.y - 3, presentationViewController.cameraHandle.position.z);
                self.textManager.textNode.position = SCNVector3Make(self.textManager.textNode.position.x, self.textManager.textNode.position.y - 3, self.textManager.textNode.position.z);
            }
            [SCNTransaction commit];
            break;
        }
        case 5:
        {
            presentationViewController.showsNewInSceneKitBadge = NO;
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:3.0];
            {
                // Change the lighting to remove the front light and rise the main light
                [presentationViewController updateLightingWithIntensities:@[@1.0, @0.0, @0.0, @0.0, @0.0, @0.3]];
                [presentationViewController riseMainLight:YES];
                
                // Remove some text
                [self.textManager fadeOutTextOfType:ASCTextTypeTitle];
                [self.textManager fadeOutTextOfType:ASCTextTypeSubtitle];
                [self.textManager fadeOutTextOfType:ASCTextTypeCode];
            }
            [SCNTransaction commit];
            
            // Retrieve the main teapot
            SCNNode *teapot = [self.groundNode childNodeWithName:@"Teapot0" recursively:YES];
            
            // The distances to use for each LOD
            float distances[4] = {30, 50, 90, 150};
            
            // An array of SCNLevelOfDetail instances that we will build
            NSMutableArray *levelsOfDetail = [NSMutableArray array];
            for (NSUInteger i = 1; i < 5; i++) {
                SCNNode *teapotNode = [self.groundNode childNodeWithName:[NSString stringWithFormat:@"Teapot%lu", (unsigned long)i] recursively:YES];
                SCNGeometry *teapot = teapotNode.geometry;
                
                // Unshare the material because we will highlight the different levels of detail with different colors in the next step
                teapot.firstMaterial = [teapot.firstMaterial copy];
                
                // Build the SCNLevelOfDetail instance
                SCNLevelOfDetail *levelOfDetail = [SCNLevelOfDetail levelOfDetailWithGeometry:teapot worldSpaceDistance:distances[i - 1]];
                [levelsOfDetail addObject:levelOfDetail];
            }
            
            teapot.geometry.levelsOfDetail = levelsOfDetail;
            
            // Duplicate and move the teapots
            CFTimeInterval startTime = CACurrentMediaTime();
            CFTimeInterval delay = 0.2;
            
            NSInteger rowCount = 9;
            NSInteger columnCount = 12;
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0];
            {
                // Change the far clipping plane to be able to see far away
                presentationViewController.cameraNode.camera.zFar = 1000.0;
                
                for (NSInteger j = 0; j < columnCount; j++) {
                    for (NSInteger i = 0; i < rowCount; i++) {
                        // Clone
                        SCNNode *clone = [teapot clone];
                        [teapot.parentNode addChildNode:clone];
                        
                        // Animate
                        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
                        animation.additive = YES;
                        animation.duration = 1.0;
                        animation.toValue = [NSValue valueWithSCNVector3:SCNVector3Make((i - rowCount / 2.0) * 12.0, 5 + (columnCount - j) * 15.0, 0)];
                        animation.fromValue = [NSValue valueWithSCNVector3:SCNVector3Make(0, 0, 0)];
                        animation.beginTime = startTime + delay; // desynchronize
                        
                        // Freeze at the end of the animation
                        animation.removedOnCompletion = NO;
                        animation.fillMode = kCAFillModeForwards;
                        
                        [clone addAnimation:animation forKey:nil];
                        
                        // Animate the hidden property to automatically show the node when the position animation starts
                        animation = [CABasicAnimation animationWithKeyPath:@"hidden"];
                        animation.duration = delay + 0.01;
                        animation.fillMode = kCAFillModeBoth;
                        animation.fromValue = @1;
                        animation.toValue = @0;
                        [clone addAnimation:animation forKey:nil];

                        delay += 0.05;
                    }
                }
            }
            [SCNTransaction commit];
            
            // Animate the camera while we duplicate the nodes
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0 + rowCount * columnCount * 0.05];
            {
                SCNVector3 position = presentationViewController.cameraHandle.position;
                presentationViewController.cameraHandle.position = SCNVector3Make(position.x, position.y + 5, position.z);
                presentationViewController.cameraPitch.rotation = SCNVector4Make(1, 0, 0, presentationViewController.cameraPitch.rotation.w - (M_PI_4 * 0.1));
            }
            [SCNTransaction commit];
            break;
        }
        case 6:
        {
            // Highlight the levels of detail with colors
            SCNNode *teapotNode = [self.groundNode childNodeWithName:@"Teapot0" recursively:YES];
            NSArray *colors = @[[NSColor redColor], [NSColor orangeColor], [NSColor yellowColor], [NSColor greenColor]];

            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1];
            {
                for (NSUInteger i = 0; i < 4; i++) {
                    SCNLevelOfDetail *levelOfDetail = teapotNode.geometry.levelsOfDetail[i];
                    levelOfDetail.geometry.firstMaterial.multiply.contents = colors[i];
                }
            }
            [SCNTransaction commit];
            break;
        }
    }
}

- (void)willOrderOutWithPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    // Reset the camera and lights before leaving this slide
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:2.0];
    {
        presentationViewController.cameraNode.camera.zFar = 100.0;
    }
    [SCNTransaction commit];
    
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:0.5];
    {
        [presentationViewController riseMainLight:NO];
    }
    [SCNTransaction commit];
}

- (SCNNode *)addTeapotWithResolutionIndex:(NSUInteger)index positionX:(CGFloat)x parent:(SCNNode *)parent {
    
    SCNNode *teapotNode = [parent asc_addChildNodeNamed:[NSString stringWithFormat:@"Teapot%d", (int)index] fromSceneNamed:@"lod" withScale:11];
    teapotNode.geometry.firstMaterial.reflective.intensity = 0.8;
    teapotNode.geometry.firstMaterial.fresnelExponent = 1.0;
    
    CGFloat yOffset = index == 4 ? 0.0 : index * 20.0;
    teapotNode.position = SCNVector3Make(x, -10 - yOffset, 0.1);
    
    return teapotNode;
}

- (SCNNode *)addNodeWithNumber:(NSString *)numberString positionX:(CGFloat)x {
    SCNNode *numberNode = [SCNNode asc_labelNodeWithString:numberString size:ASCLabelSizeLarge isLit:YES];
    numberNode.geometry.firstMaterial.diffuse.contents = [NSColor orangeColor];
    numberNode.geometry.firstMaterial.ambient.contents = [NSColor orangeColor];
    numberNode.position = SCNVector3Make(x, 50, 0);
    numberNode.name = @"number";
    
    SCNText *text = (SCNText *)numberNode.geometry;
    text.extrusionDepth = 5;
    
    [self.groundNode addChildNode:numberNode];
    
    return numberNode;
}

- (void)removeNumberNodes {
    // Move, fade and remove on completion
    for (SCNNode *node in self.groundNode.childNodes) {
        if ([node.name isEqualToString:@"number"]) {
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            [SCNTransaction setCompletionBlock:^{
                [node removeFromParentNode];
            }];
            {
                node.opacity = 0.0;
                node.position = SCNVector3Make(node.position.x, node.position.y, node.position.z - 20);
            }
            [SCNTransaction commit];
        }
    }
}

@end
