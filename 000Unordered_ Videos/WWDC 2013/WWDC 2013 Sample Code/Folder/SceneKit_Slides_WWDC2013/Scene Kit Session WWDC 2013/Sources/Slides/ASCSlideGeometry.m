/*
     File: ASCSlideGeometry.m
 Abstract:  Geometry slide. Explains the structure of the SCNGeometry class 
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
#import <GLKit/GLKMath.h>

// position of the teapots on the x axis
#define TEAPOT_X 4

@interface ASCSlideGeometry : ASCSlide
@end

@implementation ASCSlideGeometry

- (NSUInteger)numberOfSteps {
    return 6;
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentation {
    //retrieve the text manager
    ASCSlideTextManager *textManager = [self textManager];
    
    //add some text
    [textManager setTitle:@"Node Attributes"];
    [textManager setSubtitle:@"Geometry"];
    [textManager addBullet:@"Triangles" atLevel:0];
    [textManager addBullet:@"Vertices" atLevel:0];
    [textManager addBullet:@"Normals" atLevel:0];
    [textManager addBullet:@"UVs" atLevel:0];
    [textManager addBullet:@"Materials" atLevel:0];
    
    //create a container for our teapots
    SCNNode *container = [SCNNode node];
    container.rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
    [self.ground addChildNode:container];
    
    //load the low-res teapot and add to the container
    SCNNode *lowResModel = [container asc_addChildNodeNamed:@"TeapotLowRes" fromSceneNamed:@"teapotLowRes" withScale:17];
    
    //load the high res teapot and add to the container
    SCNNode *highResModel = [container asc_addChildNodeNamed:@"Teapot" fromSceneNamed:@"teapot" withScale:17];
    
    //load the version with the materials and add to the container
    SCNNode *materialModel = [container asc_addChildNodeNamed:@"teapotMaterials" fromSceneNamed:@"teapotMaterial" withScale:17];
    
    //iterate every node / materials and configure a few things
    [materialModel childNodesPassingTest:^BOOL(SCNNode *child, BOOL *stop) {
        for (SCNMaterial *material in child.geometry.materials) {
            //reduce the bump map
            material.normal.intensity = 0.3;
            
            //add a white fresnel reflection
            material.reflective.contents = [NSColor whiteColor];
            material.reflective.intensity = 3.0;
            material.fresnelExponent = 3.0;
        }
        return NO;
    }];
    
    //animate the teapots (rotate forever)
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    rotationAnimation.duration = 40.0;
    rotationAnimation.repeatCount = FLT_MAX;
    rotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 0, 1, M_PI*2)];
    
    //add the animation to the teapots
    [lowResModel addAnimation:rotationAnimation forKey:nil];
    [highResModel addAnimation:rotationAnimation forKey:nil];
    [materialModel addAnimation:rotationAnimation forKey:nil];
    
    //load and assign the explode shader modifier to the low-res teapo
    NSString *shaderFile = [[NSBundle mainBundle] pathForResource:@"explode" ofType:@"shader"];
    NSString *shaderSource = [NSString stringWithContentsOfFile:shaderFile encoding:NSUTF8StringEncoding error:nil];
    lowResModel.geometry.shaderModifiers = @{ SCNShaderModifierEntryPointGeometry : shaderSource};
    
    //create nodes to represent the vertex and normals
    SCNNode *vertexGroup = [SCNNode node];
    SCNNode *normalGroup = [SCNNode node];
    
    //name them
    vertexGroup.name = @"vertex";
    normalGroup.name = @"normals";
    
    //prevent te vertex to be lit
    SCNMaterial *noLightingMaterial = [SCNMaterial material];
    noLightingMaterial.lightingModelName = SCNLightingModelConstant;
    
    //retrieve the vertex and normals from the low-res model
    SCNGeometrySource *vertexSource = [lowResModel.geometry geometrySourcesForSemantic:SCNGeometrySourceSemanticVertex][0];
    SCNGeometrySource *normalSource = [lowResModel.geometry geometrySourcesForSemantic:SCNGeometrySourceSemanticNormal][0];
    
    //get vertex and normal bytes
    float *vertex = (float*)[[vertexSource data] bytes];
    float *normals = (float*)[[normalSource data] bytes];
    
    //get count
    NSInteger cpv = [vertexSource componentsPerVector];
    NSUInteger n = [vertexSource vectorCount];
    
    //iterate on the vertex/normals and create geometries to represent them
    for (NSUInteger i=0; i<n ;i++) {
        //one new node per normal/vertex
        SCNNode *point = [SCNNode node];
        SCNNode *normalNode = [SCNNode node];
        
        //attach one sphere per vertex
        SCNSphere *sphere = [SCNSphere sphereWithRadius:0.5];
        sphere.segmentCount = 4; //use a small segmentation count for better perfs
        sphere.firstMaterial = noLightingMaterial;//no lighting
        point.geometry = sphere;
        
        //one pyramid per normal
        SCNPyramid *pyramid = [SCNPyramid pyramidWithWidth:0.1 height:0.1 length:8];
        pyramid.firstMaterial = noLightingMaterial;//no lighting
        normalNode.geometry = pyramid;
        
        //place the vertex
        point.position = SCNVector3Make(vertex[i*cpv], vertex[i*cpv+1], vertex[i*cpv+2]);
        
        //place the normal
        normalNode.position = point.position;
        
        //some math for the orientation of the normal
        GLKVector3 up = GLKVector3Make(0,0,1);
        GLKVector3 normalVec = GLKVector3Make(normals[i*3], normals[i*3+1], normals[i*3+2]);
        GLKVector3 axis = GLKVector3Normalize(GLKVector3CrossProduct(up, normalVec));
        float dot = GLKVector3DotProduct(up, normalVec);
        normalNode.rotation = SCNVector4Make(axis.x, axis.y, axis.z, acos(dot));
        
        //add the sphere and pyramid to the vertex and normal groups
        [vertexGroup addChildNode:point];
        [normalGroup addChildNode:normalNode];
    }
    
    /* here we must flush to make sure that the parametric geometries (sphere and pyramid)
     are up-to-date before flattening the nodes */
    [SCNTransaction flush];
    
    // flatten vertex and normal so that it can be rendered with 1 draw call
    vertexGroup = [vertexGroup flattenedClone];
    normalGroup = [normalGroup flattenedClone];
    
    //add the normal and vertex objects as a child of the low res model so that it rotate together
    [lowResModel addChildNode:vertexGroup];
    [lowResModel addChildNode:normalGroup];
}


- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)controller {
    switch (index) {
        case 0:
        {
            //adjust the near clipping plane of the spotlight to maximize the precision of the dynamic drop shadows
            [controller.spotLight.light setAttribute:@(30) forKey:SCNLightShadowNearClippingKey];

            //--reset the slide
            
            //hide the vertex, normal and teapots
            SCNNode *model = [self.ground childNodeWithName:@"vertex" recursively:YES];
            model.opacity = 0.0;
            
            model = [self.ground childNodeWithName:@"normals" recursively:YES];
            model.opacity = 0.0;
            
            model = [self.ground childNodeWithName:@"Teapot" recursively:YES];
            model.opacity = 0.0;
            model.position = SCNVector3Make(TEAPOT_X, 0, 0);
            
            model = [self.ground childNodeWithName:@"teapotMaterials" recursively:YES];
            model.opacity = 0.0;
            model.position = SCNVector3Make(TEAPOT_X, 0, 0);

            //show low res teapot
            model = [self.ground childNodeWithName:@"TeapotLowRes" recursively:YES];
            model.opacity = 1.0;
            model.position = SCNVector3Make(TEAPOT_X, 0, 0);
            
            //unhighlight bullet
            [self.textManager highlightBulletAtIndex:NSNotFound];
        }
            break;
        case 1:
        {
            //show triangles bullet
            [self.textManager highlightBulletAtIndex:0];
            
            // retrieve the teapot model
            SCNNode *model = [self.ground childNodeWithName:@"TeapotLowRes" recursively:YES];
            
            //animate the "explodeValue" parameter of the shader modifier
            CABasicAnimation *explodeAnimation = [CABasicAnimation animationWithKeyPath:@"explodeValue"];
            explodeAnimation.duration = 2.0;
            explodeAnimation.repeatCount = FLT_MAX;
            explodeAnimation.autoreverses = YES;
            explodeAnimation.toValue = @20.0;
            explodeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [model.geometry addAnimation:explodeAnimation forKey:@"explode"];
        }
            break;
        case 2:
        {
            //show vertex bullet
            [self.textManager highlightBulletAtIndex:1];

            SCNNode *model = [self.ground childNodeWithName:@"TeapotLowRes" recursively:YES];
            
            //get current explode value
            NSNumber *explode = [[[model presentationNode] geometry] valueForKey:@"explodeValue"];

            //remove the explode animation and freeze to current position
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.0];
            [model.geometry setValue:explode forKey:@"explodeValue"];
            [model.geometry removeAnimationForKey:@"explode"];
            [SCNTransaction commit];

            //revert to no explode
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            
            //on completion show the vertex
            [SCNTransaction setCompletionBlock:^{
                [SCNTransaction begin];
                [SCNTransaction setAnimationDuration:1.0];
                SCNNode *vertex = [self.ground childNodeWithName:@"vertex" recursively:YES];
                vertex.opacity = 1.0; //fade in vertex
                [SCNTransaction commit];
            }];
            
            [model.geometry setValue:@0.0 forKey:@"explodeValue"];
            
            [SCNTransaction commit];
        }
            break;
        case 3:
        {
            //show normals bullet
            [self.textManager highlightBulletAtIndex:2];

            //hide vertex and show normals
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            SCNNode *model = [self.ground childNodeWithName:@"vertex" recursively:YES];
            model.opacity = 0.0;
            
            model = [self.ground childNodeWithName:@"normals" recursively:YES];
            model.opacity = 1.0;
            
            [SCNTransaction commit];
        }
            break;
        case 4:
        {
            //show UVs bullet
            [self.textManager highlightBulletAtIndex:3];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0];

            //hide normals
            SCNNode *model = [self.ground childNodeWithName:@"normals" recursively:YES];
            model.hidden = YES;
            
            //show high-res teapot
            model = [self.ground childNodeWithName:@"Teapot" recursively:YES];
            model.opacity = 1.0;
            
            //hide low res
            model = [self.ground childNodeWithName:@"TeapotLowRes" recursively:YES];
            model.opacity = 0.0;
            
            [SCNTransaction commit];
        }
            break;
        case 5:
            //show materials
            [self.textManager highlightBulletAtIndex:4];

            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0];
            
            //hide UVs
            SCNNode *model = [self.ground childNodeWithName:@"Teapot" recursively:YES];
            model.hidden = YES;

            //show version with materials
            model = [self.ground childNodeWithName:@"teapotMaterials" recursively:YES];
            model.opacity = 1.0;
            
            [SCNTransaction commit];
            break;
    }
}

@end
