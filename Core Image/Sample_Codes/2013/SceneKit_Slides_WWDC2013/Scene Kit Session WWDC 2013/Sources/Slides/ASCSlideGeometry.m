/*
     File: ASCSlideGeometry.m
 Abstract: Explains how geometries are made.
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

#import <GLKit/GLKMath.h>

#import "ASCPresentationViewController.h"
#import "ASCSlideTextManager.h"
#import "ASCSlide.h"
#import "Utils.h"

@interface ASCSlideGeometry : ASCSlide
@end

@implementation ASCSlideGeometry {
    SCNNode *_teapotNodeForPositionsAndNormals;
    SCNNode *_teapotNodeForUVs;
    SCNNode *_teapotNodeForMaterials;
    SCNNode *_positionsVisualizationNode;
    SCNNode *_normalsVisualizationNode;
}

- (NSUInteger)numberOfSteps {
    return 6;
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentationViewController {
    // Set the slide's title and subtile and add some text
    self.textManager.title = @"Node Attributes";
    self.textManager.subtitle = @"Geometry";
    
    [self.textManager addBullet:@"Triangles" atLevel:0];
    [self.textManager addBullet:@"Vertices" atLevel:0];
    [self.textManager addBullet:@"Normals" atLevel:0];
    [self.textManager addBullet:@"UVs" atLevel:0];
    [self.textManager addBullet:@"Materials" atLevel:0];
    
    // We create a container for several versions of the teapot model
    // - one teapot to show positions and normals
    // - one teapot to show texture coordinates
    // - one teapot to show materials
    SCNNode *allTeapotsNode = [SCNNode node];
    allTeapotsNode.rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
    [self.groundNode addChildNode:allTeapotsNode];
    
    _teapotNodeForPositionsAndNormals = [allTeapotsNode asc_addChildNodeNamed:@"TeapotLowRes" fromSceneNamed:@"teapotLowRes" withScale:17];
    _teapotNodeForUVs = [allTeapotsNode asc_addChildNodeNamed:@"Teapot" fromSceneNamed:@"teapot" withScale:17];
    _teapotNodeForMaterials = [allTeapotsNode asc_addChildNodeNamed:@"teapotMaterials" fromSceneNamed:@"teapotMaterial" withScale:17];
    
    _teapotNodeForPositionsAndNormals.position = SCNVector3Make(4, 0, 0);
    _teapotNodeForUVs.position = SCNVector3Make(4, 0, 0);
    _teapotNodeForMaterials.position = SCNVector3Make(4, 0, 0);
    
    [_teapotNodeForMaterials childNodesPassingTest:^BOOL(SCNNode *child, BOOL *stop) {
        for (SCNMaterial *material in child.geometry.materials) {
            material.normal.intensity = 0.3;
            material.reflective.contents = [NSColor whiteColor];
            material.reflective.intensity = 3.0;
            material.fresnelExponent = 3.0;
        }
        return NO;
    }];
    
    // Animate the teapots (rotate forever)
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    rotationAnimation.duration = 40.0;
    rotationAnimation.repeatCount = FLT_MAX;
    rotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 0, 1, M_PI * 2)];
    
    [_teapotNodeForPositionsAndNormals addAnimation:rotationAnimation forKey:nil];
    [_teapotNodeForUVs addAnimation:rotationAnimation forKey:nil];
    [_teapotNodeForMaterials addAnimation:rotationAnimation forKey:nil];
    
    // Load the "explode" shader modifier and add it to the geometry
    NSString *explodeShaderPath = [[NSBundle mainBundle] pathForResource:@"explode" ofType:@"shader"];
    NSString *explodeShaderSource = [NSString stringWithContentsOfFile:explodeShaderPath encoding:NSUTF8StringEncoding error:nil];
    _teapotNodeForPositionsAndNormals.geometry.shaderModifiers = @{ SCNShaderModifierEntryPointGeometry : explodeShaderSource};
    
    // Build nodes that will help visualize the vertices (position and normal)
    [self buildVisualizationsOfNode:_teapotNodeForPositionsAndNormals
                      positionsNode:&_positionsVisualizationNode
                        normalsNode:&_normalsVisualizationNode];
    
    [_teapotNodeForPositionsAndNormals addChildNode:_positionsVisualizationNode];
    [_teapotNodeForPositionsAndNormals addChildNode:_normalsVisualizationNode];
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    switch (index) {
        case 0:
        {
            // Adjust the near clipping plane of the spotlight to maximize the precision of the dynamic drop shadows
            [presentationViewController.spotLight.light setAttribute:@(30) forKey:SCNLightShadowNearClippingKey];
            
            // Show what needs to be shown, hide what needs to be hidden
            _positionsVisualizationNode.opacity = 0.0;
            _normalsVisualizationNode.opacity = 0.0;
            _teapotNodeForUVs.opacity = 0.0;
            _teapotNodeForMaterials.opacity = 0.0;
            
            _teapotNodeForPositionsAndNormals.opacity = 1.0;
            
            // Don't highlight bullets (this is useful when we go back from the next slide)
            [self.textManager highlightBulletAtIndex:NSNotFound];
            break;
        }
        case 1:
        {
            [self.textManager highlightBulletAtIndex:0];
            
            // Animate the "explodeValue" parameter (uniform) of the shader modifier
            CABasicAnimation *explodeAnimation = [CABasicAnimation animationWithKeyPath:@"explodeValue"];
            explodeAnimation.duration = 2.0;
            explodeAnimation.repeatCount = FLT_MAX;
            explodeAnimation.autoreverses = YES;
            explodeAnimation.toValue = @20.0;
            explodeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [_teapotNodeForPositionsAndNormals.geometry addAnimation:explodeAnimation forKey:@"explode"];
            break;
        }
        case 2:
        {
            [self.textManager highlightBulletAtIndex:1];
            
            // Remove the "explode" animation and freeze the "explodeValue" parameter to the current value
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.0];
            {
                NSNumber *explodeValue = [_teapotNodeForPositionsAndNormals.presentationNode.geometry valueForKey:@"explodeValue"];
                [_teapotNodeForPositionsAndNormals.geometry setValue:explodeValue forKey:@"explodeValue"];
                [_teapotNodeForPositionsAndNormals.geometry removeAnimationForKey:@"explode"];
            }
            [SCNTransaction commit];
            
            // Animate to a "no explosion" state and show the positions on completion
            void (^showPositions)(void) = ^{
                [SCNTransaction begin];
                [SCNTransaction setAnimationDuration:1.0];
                {
                    _positionsVisualizationNode.opacity = 1.0;
                }
                [SCNTransaction commit];
            };
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            [SCNTransaction setCompletionBlock:showPositions];
            {
                [_teapotNodeForPositionsAndNormals.geometry setValue:@0.0 forKey:@"explodeValue"];
            }
            [SCNTransaction commit];
            break;
        }
        case 3:
        {
            [self.textManager highlightBulletAtIndex:2];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                _positionsVisualizationNode.opacity = 0.0;
                _normalsVisualizationNode.opacity = 1.0;
            }
            [SCNTransaction commit];
            break;
        }
        case 4:
        {
            [self.textManager highlightBulletAtIndex:3];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0];
            {
                _normalsVisualizationNode.hidden = YES;
                _teapotNodeForUVs.opacity = 1.0;
                _teapotNodeForPositionsAndNormals.opacity = 0.0;
            }
            [SCNTransaction commit];
            break;
        }
        case 5:
        {
            [self.textManager highlightBulletAtIndex:4];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0];
            {
                _teapotNodeForUVs.hidden = YES;
                _teapotNodeForMaterials.opacity = 1.0;
            }
            [SCNTransaction commit];
            break;
        }
    }
}

- (void)buildVisualizationsOfNode:(SCNNode *)node positionsNode:(SCNNode * __strong *)verticesNode normalsNode:(SCNNode * __strong *)normalsNode {
    // A material that will prevent the nodes from being lit
    SCNMaterial *noLightingMaterial = [SCNMaterial material];
    noLightingMaterial.lightingModelName = SCNLightingModelConstant;
    
    // Create nodes to represent the vertex and normals
    SCNNode *positionVisualizationNode = [SCNNode node];
    SCNNode *normalsVisualizationNode = [SCNNode node];
    
    // Retrieve the vertices and normals from the model
    SCNGeometrySource *positionSource = [node.geometry geometrySourcesForSemantic:SCNGeometrySourceSemanticVertex][0];
    SCNGeometrySource *normalSource = [node.geometry geometrySourcesForSemantic:SCNGeometrySourceSemanticNormal][0];
    
    // Get vertex and normal bytes
    float *vertexBuffer = (float *)positionSource.data.bytes;
    float *normalBuffer = (float *)normalSource.data.bytes;
    
    // Iterate and create geometries to represent the positions and normals
    for (NSUInteger i = 0; i < positionSource.vectorCount; i++) {
        // One new node per normal/vertex
        SCNNode *vertexNode = [SCNNode node];
        SCNNode *normalNode = [SCNNode node];
        
        // Attach one sphere per vertex
        SCNSphere *sphere = [SCNSphere sphereWithRadius:0.5];
        sphere.segmentCount = 4; // use a small segment count for better performances
        sphere.firstMaterial = noLightingMaterial;
        vertexNode.geometry = sphere;
        
        // And one pyramid per normal
        SCNPyramid *pyramid = [SCNPyramid pyramidWithWidth:0.1 height:0.1 length:8];
        pyramid.firstMaterial = noLightingMaterial;
        normalNode.geometry = pyramid;
        
        // Place the position node
        NSInteger componentsPerVector = positionSource.componentsPerVector;
        vertexNode.position = SCNVector3Make(vertexBuffer[i * componentsPerVector], vertexBuffer[i * componentsPerVector + 1], vertexBuffer[i * componentsPerVector + 2]);
        
        // Place the normal node
        normalNode.position = vertexNode.position;
        
        // Orientate the normal
        GLKVector3 up = GLKVector3Make(0, 0, 1);
        GLKVector3 normalVec = GLKVector3Make(normalBuffer[i * 3], normalBuffer[i * 3 + 1], normalBuffer[i * 3 + 2]);
        GLKVector3 axis = GLKVector3Normalize(GLKVector3CrossProduct(up, normalVec));
        float dotProduct = GLKVector3DotProduct(up, normalVec);
        normalNode.rotation = SCNVector4Make(axis.x, axis.y, axis.z, acos(dotProduct));
        
        // Add the nodes to their parent
        [positionVisualizationNode addChildNode:vertexNode];
        [normalsVisualizationNode addChildNode:normalNode];
    }
    
    // We must flush the transaction in order to make sure that the parametric geometries (sphere and pyramid)
    // are up-to-date before flattening the nodes
    [SCNTransaction flush];
    
    // Flatten the visualization nodes so that they can be rendered with 1 draw call
    *verticesNode = [positionVisualizationNode flattenedClone];
    *normalsNode = [normalsVisualizationNode flattenedClone];
}

@end
