/*
     File: ASCSlideCreatingGeometries.m
 Abstract: Presents the different types of geometry that one can create programmatically.
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

#import <GLKit/GLKMath.h>

// Data structure representing a vertex that will be used to create custom geometries
typedef struct {
    float x, y, z;    // position
    float nx, ny, nz; // normal
    float s, t;       // texture coordinates
} ASCVertex;

@interface ASCSlideCreatingGeometries : ASCSlide
@end

@implementation ASCSlideCreatingGeometries {
    SCNNode *_carouselNode;
    SCNNode *_textNode;
    SCNNode *_level2OutlineNode, *_level2Node;
}

- (NSUInteger)numberOfSteps {
    return 7;
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentationViewController {
    // Set the slide's title
    self.textManager.title = @"Creating Geometries";
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    switch (index) {
        case 0:
            break;
        case 1:
            // Set the slide's subtitle and display the primitves
            self.textManager.subtitle = @"Built-in parametric primitives";
            [self presentPrimitives];
            break;
        case 2:
        {
            // Hide the carousel and illustrate SCNText
            [self.textManager flipOutTextOfType:ASCTextTypeSubtitle];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            [SCNTransaction setCompletionBlock:^{
                [_carouselNode removeFromParentNode];
                
                [SCNTransaction begin];
                [SCNTransaction setAnimationDuration:1.0];
                {
                    [self presentTextNode];
                    _textNode.opacity = 1.0;
                }
                [SCNTransaction commit];
                
            }];
            {
                _carouselNode.opacity = 0.0;
            }
            [SCNTransaction commit];
            
            self.textManager.subtitle = @"Built-in 3D text";
            [self.textManager addBullet:@"SCNText" atLevel:0];
            [self.textManager flipInTextOfType:ASCTextTypeSubtitle];
            [self.textManager flipInTextOfType:ASCTextTypeBullet];
            break;
        }
        case 3:
        {
            // Hide the 3D text and introduce SCNShape
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            [SCNTransaction setCompletionBlock:^{
                [_textNode removeFromParentNode];
                
                presentationViewController.showsNewInSceneKitBadge = YES;
                
                [self.textManager flipOutTextOfType:ASCTextTypeSubtitle];
                [self.textManager flipOutTextOfType:ASCTextTypeBullet];
                
                self.textManager.subtitle = @"3D Shapes";
                
                [self.textManager addBullet:@"SCNShape" atLevel:0];
                [self.textManager addBullet:@"Initializes with a NSBezierPath" atLevel:0];
                [self.textManager addBullet:@"Extrusion and chamfer" atLevel:0];
                [self.textManager addCode:@"aNode.geometry = [SCNShape #shapeWithPath:#aBezierPath #extrusionDepth:#10];"];
                
                [self.textManager flipInTextOfType:ASCTextTypeSubtitle];
                [self.textManager flipInTextOfType:ASCTextTypeBullet];
                [self.textManager flipInTextOfType:ASCTextTypeCode];
            }];
            {
                _textNode.opacity = 0.0;
            }
            [SCNTransaction commit];
            break;
        }
        case 4:
        {
            [self.textManager fadeOutTextOfType:ASCTextTypeBullet];
            [self.textManager fadeOutTextOfType:ASCTextTypeCode];
            
            // Illustrate SCNShape, show the floor ouline
            _level2Node = [self level2Node];
            _level2OutlineNode = [self level2OutlineNode];
            
            _level2Node.position = _level2OutlineNode.position = SCNVector3Make(-11, 0, -5);
            _level2Node.rotation = _level2OutlineNode.rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
            _level2Node.opacity = _level2OutlineNode.opacity = 0.0;
            _level2Node.scale = SCNVector3Make(0.03, 0.03, 0);
            _level2OutlineNode.scale = SCNVector3Make(0.03, 0.03, 0.05);
            
            [self.groundNode addChildNode:_level2OutlineNode];
            [self.groundNode addChildNode:_level2Node];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                _level2OutlineNode.opacity = 1.0;
            }
            [SCNTransaction commit];
            break;
        }
        case 5:
        {
            presentationViewController.showsNewInSceneKitBadge = NO;
            
            // Show the extruded floor
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                _level2Node.opacity = 1.0;
                _level2Node.scale = SCNVector3Make(0.03, 0.03, 0.05);
                
                [SCNTransaction setCompletionBlock:^{
                    [SCNTransaction begin];
                    [SCNTransaction setAnimationDuration:1.5];
                    {
                        // move the camera a little higher
                        presentationViewController.cameraNode.position = SCNVector3Make(0, 7, -3);
                        presentationViewController.cameraPitch.rotation = SCNVector4Make(1, 0, 0, -M_PI_4 * 0.7);
                    }
                    [SCNTransaction commit];
                }];
            }
            [SCNTransaction commit];
            break;
        }
        case 6:
        {
            [self.textManager flipOutTextOfType:ASCTextTypeSubtitle];
            [self.textManager flipOutTextOfType:ASCTextTypeBullet];
            
            // Example of a custom geometry (Möbius strip)
            self.textManager.subtitle = @"Custom geometry";
            
            [self.textManager addBullet:@"Custom vertices, normals and texture coordinates" atLevel:0];
            [self.textManager addBullet:@"SCNGeometry" atLevel:0];
            
            [self.textManager flipInTextOfType:ASCTextTypeSubtitle];
            [self.textManager flipInTextOfType:ASCTextTypeBullet];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                // move the camera back to its previous position
                presentationViewController.cameraNode.position = SCNVector3Make(0, 0, 0);
                presentationViewController.cameraPitch.rotation = SCNVector4Make(1, 0, 0, self.pitch * M_PI / 180.0);
                
                _level2Node.opacity = 0.0;
                _level2OutlineNode.opacity = 0.0;
                
                [SCNTransaction setCompletionBlock:^{
                    SCNNode *mobiusNode = [SCNNode node];
                    mobiusNode.geometry = [self mobiusStripWithSubdivisionCount:150];
                    mobiusNode.rotation = SCNVector4Make(1, 0, 0, -M_PI_4);
                    mobiusNode.scale = SCNVector3Make(4, 2.2, 2.2);
                    mobiusNode.opacity = 0.0;
                    
                    SCNNode *rotationNode = [SCNNode node];
                    rotationNode.position = SCNVector3Make(0, 2.7, 7);
                    [rotationNode addChildNode:mobiusNode];
                    [self.groundNode addChildNode:rotationNode];
                    
                    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
                    rotationAnimation.duration = 10.0;
                    rotationAnimation.repeatCount = FLT_MAX;
                    rotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
                    [rotationNode addAnimation:rotationAnimation forKey:nil];
                    
                    [SCNTransaction begin];
                    [SCNTransaction setAnimationDuration:1.0];
                    {
                        mobiusNode.opacity = 1.0;
                    }
                    [SCNTransaction commit];
                }];
            }
            [SCNTransaction commit];
            
            break;
        }
    }
}

- (void)willOrderOutWithPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    // Make sure the camera is back to its default location before leaving the slide
    presentationViewController.cameraNode.position = SCNVector3Make(0, 0, 0);
}

#pragma mark - Primitives

// Create a carousel of 3D primitives
- (void)presentPrimitives {
    
    // Create the carousel node. It will host all the primitives as child nodes.
    _carouselNode = [SCNNode node];
    _carouselNode.position = SCNVector3Make(0, 0.1, -5);
    _carouselNode.scale = SCNVector3Make(0, 0, 0); // start infinitely small
    [self.groundNode addChildNode:_carouselNode];
    
    // Animate the scale to achieve a "grow" effect
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.0];
    {
        _carouselNode.scale = SCNVector3Make(1, 1, 1);
    }
    [SCNTransaction commit];
    
    // Rotate the carousel forever
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    rotationAnimation.duration = 40.0;
    rotationAnimation.repeatCount = FLT_MAX;
    rotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    [_carouselNode addAnimation:rotationAnimation forKey:nil];
    
    // A material shared by all the primitives
    SCNMaterial *sharedMaterial = [SCNMaterial material];
    sharedMaterial.reflective.contents = [NSImage imageNamed:@"envmap"];
    sharedMaterial.reflective.intensity = 0.2;
    sharedMaterial.doubleSided = YES;
    
    __block int primitiveIndex = 0;
    void (^addPrimitive)(SCNGeometry *, CGFloat) = ^(SCNGeometry *geometry, CGFloat yPos) {
        CGFloat xPos = 13.0 * sin(M_PI * 2 * primitiveIndex / 9.0);
        CGFloat zPos = 13.0 * cos(M_PI * 2 * primitiveIndex / 9.0);
        
        SCNNode *node = [SCNNode node];
        node.position = SCNVector3Make(xPos, yPos, zPos);
        node.geometry = geometry;
        node.geometry.firstMaterial = sharedMaterial;
        [_carouselNode addChildNode:node];
        
        primitiveIndex++;
        rotationAnimation.timeOffset = -primitiveIndex;
        [node addAnimation:rotationAnimation forKey:nil];
    };
    
    // SCNBox
    SCNBox *box = [SCNBox boxWithWidth:5.0 height:5.0 length:5.0 chamferRadius:5.0 * 0.05];
    box.widthSegmentCount = 4;
    box.heightSegmentCount = 4;
    box.lengthSegmentCount = 4;
    box.chamferSegmentCount = 4;
    addPrimitive(box, 5.0 / 2);
    
    // SCNPyramid
    SCNPyramid *pyramid = [SCNPyramid pyramidWithWidth:5.0 * 0.8 height:5.0 length:5.0 * 0.8];
    pyramid.widthSegmentCount = 4;
    pyramid.heightSegmentCount = 10;
    pyramid.lengthSegmentCount = 4;
    addPrimitive(pyramid, 0);
    
    // SCNCone
    SCNCone *cone = [SCNCone coneWithTopRadius:0 bottomRadius:5.0 / 2 height:5.0];
    cone.radialSegmentCount = 20;
    cone.heightSegmentCount = 4;
    addPrimitive(cone, 5.0 / 2);
    
    // SCNTube
    SCNTube *tube = [SCNTube tubeWithInnerRadius:5.0 * 0.25 outerRadius:5.0 * 0.5 height:5.0];
    tube.heightSegmentCount = 5;
    tube.radialSegmentCount = 40;
    addPrimitive(tube, 5.0 / 2);
    
    // SCNCapsule
    SCNCapsule *capsule = [SCNCapsule capsuleWithCapRadius:5.0 * 0.4 height:5.0 * 1.4];
    capsule.heightSegmentCount = 5;
    capsule.radialSegmentCount = 20;
    addPrimitive(capsule, 5.0 * 0.7);
    
    // SCNCylinder
    SCNCylinder *cylinder = [SCNCylinder cylinderWithRadius:5.0 * 0.5 height:5.0];
    cylinder.heightSegmentCount = 5;
    cylinder.radialSegmentCount = 40;
    addPrimitive(cylinder, 5.0 / 2);
    
    // SCNSphere
    SCNSphere *sphere = [SCNSphere sphereWithRadius:5.0 * 0.5];
    sphere.segmentCount = 20;
    addPrimitive(sphere, 5.0 / 2);
    
    // SCNTorus
    SCNTorus *torus = [SCNTorus torusWithRingRadius:5.0 * 0.5 pipeRadius:5.0 * 0.25];
    torus.ringSegmentCount = 40;
    torus.pipeSegmentCount = 20;
    addPrimitive(torus, 5.0 / 4);
    
    // SCNPlane
    SCNPlane *plane = [SCNPlane planeWithWidth:5.0 height:5.0];
    plane.widthSegmentCount = 5;
    plane.heightSegmentCount = 5;
    plane.cornerRadius = 5.0 * 0.1;
    addPrimitive(plane, 5.0 / 2);
}

#pragma mark - Custom geometry

- (SCNGeometry *)mobiusStripWithSubdivisionCount:(NSInteger)subdivisionCount {
    NSInteger hSub = subdivisionCount;
    NSInteger vSub = subdivisionCount / 2;
    NSInteger vcount = (hSub + 1) * (vSub + 1);
    NSInteger icount = (hSub * vSub) * 6;
    
    ASCVertex *vertices = malloc(sizeof(ASCVertex) * vcount);
    unsigned short *indices = malloc(sizeof(unsigned short) * icount);
    
    // Vertices
    float sStep = 2.f * M_PI / hSub;
    float tStep = 2.f / vSub;
    ASCVertex *v = vertices;
    float s = 0.f;
    float cosu, cosu2, sinu, sinu2;
    
    for (NSInteger i = 0; i <= hSub; ++i, s += sStep) {
        float t = -1.f;
        for (NSInteger j = 0; j <= vSub; ++j, t += tStep, ++v) {
            sinu = sin(s);
            cosu = cos(s);
            sinu2 = sin(s/2);
            cosu2 = cos(s/2);
            
            v->x = cosu * (1 + 0.5 * t * cosu2);
            v->y = sinu * (1 + 0.5 * t * cosu2);
            v->z = 0.5 * t * sinu2;
            
            v->nx = -0.125 * t * sinu  + 0.5  * cosu  * sinu2 + 0.25 * t * cosu2 * sinu2 * cosu;
            v->ny =  0.125 * t * cosu  + 0.5  * sinu2 * sinu  + 0.25 * t * cosu2 * sinu2 * sinu;
            v->nz = -0.5       * cosu2 - 0.25 * cosu2 * cosu2 * t;
            
            // normalize
            float invLen = 1. / sqrtf(v->nx * v->nx + v->ny * v->ny + v->nz * v->nz);
            v->nx *= invLen;
            v->ny *= invLen;
            v->nz *= invLen;
            
            
            v->s = 3.125 * s / M_PI;
            v->t = t * 0.5 + 0.5;
        }
    }
    
    // Indices
    unsigned short *ind = indices;
    unsigned short stripStart = 0;
    for (NSInteger i = 0; i < hSub; ++i, stripStart += (vSub + 1)) {
        for (NSInteger j = 0; j < vSub; ++j) {
			unsigned short v1	= stripStart + j;
			unsigned short v2	= stripStart + j + 1;
			unsigned short v3	= stripStart + (vSub+1) + j;
			unsigned short v4	= stripStart + (vSub+1) + j + 1;
			
			*ind++	= v1; *ind++	= v3; *ind++	= v2;
			*ind++	= v2; *ind++	= v3; *ind++	= v4;
        }
    }
    
    NSData *data = [NSData dataWithBytes:vertices length:vcount * sizeof(ASCVertex)];
    free(vertices);
    
    // Vertex source
    SCNGeometrySource *vertexSource = [SCNGeometrySource geometrySourceWithData:data
                                                                       semantic:SCNGeometrySourceSemanticVertex
                                                                    vectorCount:vcount
                                                                floatComponents:YES
                                                            componentsPerVector:3
                                                              bytesPerComponent:sizeof(float)
                                                                     dataOffset:0
                                                                     dataStride:sizeof(ASCVertex)];
    
    // Normal source
    SCNGeometrySource *normalSource = [SCNGeometrySource geometrySourceWithData:data
                                                                       semantic:SCNGeometrySourceSemanticNormal
                                                                    vectorCount:vcount
                                                                floatComponents:YES
                                                            componentsPerVector:3
                                                              bytesPerComponent:sizeof(float)
                                                                     dataOffset:offsetof(ASCVertex, nx)
                                                                     dataStride:sizeof(ASCVertex)];
    
    
    // Texture coordinates source
    SCNGeometrySource *texcoordSource = [SCNGeometrySource geometrySourceWithData:data
                                                                         semantic:SCNGeometrySourceSemanticTexcoord
                                                                      vectorCount:vcount
                                                                  floatComponents:YES
                                                              componentsPerVector:2
                                                                bytesPerComponent:sizeof(float)
                                                                       dataOffset:offsetof(ASCVertex, s)
                                                                       dataStride:sizeof(ASCVertex)];
    
    
    // Geometry element
    NSData *indicesData = [NSData dataWithBytes:indices length:icount * sizeof(unsigned short)];
    free(indices);
    
    SCNGeometryElement *element = [SCNGeometryElement geometryElementWithData:indicesData
                                                                primitiveType:SCNGeometryPrimitiveTypeTriangles
                                                               primitiveCount:icount/3
                                                                bytesPerIndex:sizeof(unsigned short)];
    
    // Create the geometry
    SCNGeometry *geometry = [SCNGeometry geometryWithSources:@[vertexSource, normalSource, texcoordSource] elements:@[element]];
    
    // Add textures
    geometry.firstMaterial = [SCNMaterial material];
    geometry.firstMaterial.diffuse.contents = [NSImage imageNamed:@"moebius"];
    geometry.firstMaterial.diffuse.wrapS = SCNWrapModeRepeat;
    geometry.firstMaterial.diffuse.wrapT = SCNWrapModeRepeat;
    geometry.firstMaterial.doubleSided = YES;
    geometry.firstMaterial.reflective.contents = [NSImage imageNamed:@"envmap"];
    geometry.firstMaterial.reflective.intensity = 0.3;
    
    return geometry;
}

#pragma mark - Stylized 3D text

- (NSAttributedString *)attributedStringWithString:(NSString *)string {
    NSFont *font = [NSFont fontWithName:@"Avenir Next Heavy" size:288];
    NSDictionary *attributes = @{ NSFontAttributeName : font };
    return [[NSMutableAttributedString alloc] initWithString:string attributes:attributes];
}

- (SCNMaterial *)textFrontMaterial {
    SCNMaterial *material = [SCNMaterial material];
    material.diffuse.contents = [NSColor blackColor];
    material.reflective.contents = [NSImage imageNamed:@"envmap"];
    material.reflective.intensity = 0.5;
    material.multiply.contents = [NSImage imageNamed:@"gradient2"];
    return material;
}

- (SCNMaterial *)textSideAndChamferMaterial {
    SCNMaterial *material = [SCNMaterial material];
    material.diffuse.contents = [NSColor whiteColor];
    material.reflective.contents = [NSImage imageNamed:@"envmap"];
    material.reflective.intensity = 0.4;
    return material;
}

- (NSBezierPath *)textChamferProfile {
    NSBezierPath *profile = [NSBezierPath bezierPath];
    [profile moveToPoint:NSMakePoint(0, 1)];
    [profile lineToPoint:NSMakePoint(1.5, 1)];
    [profile lineToPoint:NSMakePoint(1.5, 0)];
    [profile lineToPoint:NSMakePoint(1, 0)];
    return profile;
}

// Takes a string an creates a node hierarchy where each letter is an independent geometry that is animated
- (SCNNode *)splittedStylizedTextWithString:(NSString *)string {

    SCNNode *textNode = [SCNNode node];
    SCNMaterial *frontMaterial = [self textFrontMaterial];
    SCNMaterial *border = [self textSideAndChamferMaterial];
    
    // Current x position of the next letter to add
    CGFloat positionX = 0;
    
    // For each letter
    for (NSUInteger i = 0; i < [string length]; i++) {
      
        SCNNode *letterNode = [SCNNode node];
        NSString *letterString = [string substringWithRange:NSMakeRange(i, 1)];
        SCNText *text = [SCNText textWithString:[self attributedStringWithString:letterString] extrusionDepth:50.0];
        
        text.chamferRadius = 3.0;
        text.chamferProfile = [self textChamferProfile];
        
        // use a different material for the "heart" character
        SCNMaterial *finalFrontMaterial = frontMaterial;
        if (i == 1) {
            finalFrontMaterial = [finalFrontMaterial copy];
            finalFrontMaterial.diffuse.contents = [NSColor redColor];
            finalFrontMaterial.reflective.contents = [NSColor blackColor];
            letterNode.scale = SCNVector3Make(1.1, 1.1, 1.0);
        }
        
        text.materials = @[finalFrontMaterial, finalFrontMaterial, border, border, border];
        
        letterNode.geometry = text;
        [textNode addChildNode:letterNode];
        
        // measure the letter we just added to update the position
        SCNVector3 min, max;
        max = SCNVector3Make(0, 0, 0);
        min = SCNVector3Make(0, 0, 0);
        if ([letterNode getBoundingBoxMin:&min max:&max]) {
            letterNode.position = SCNVector3Make(positionX - min.x + ( max.x + min.x) * 0.5, -min.y, 0);
            positionX += max.x;
        }
        else{
            // if we have no bounding box, it is probably because of the "space" character. In that case, move to the right a little bit.
            positionX += 50.0;
        }
        
        // Place the pivot at the center of the letter so that the rotation animation looks good
        letterNode.pivot = CATransform3DMakeTranslation((max.x + min.x) * 0.5, 0, 0);
        
        // Animate the letter
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"rotation"];
        animation.duration = 4.0;
        animation.keyTimes = @[@0.0, @0.3, @1.0];
        animation.values = @[[NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, 0)],
                             [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)],
                             [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)]];
        CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.timingFunctions = @[timingFunction, timingFunction, timingFunction];
        animation.repeatCount = FLT_MAX;
        animation.beginTime = CACurrentMediaTime() + 1.0 + i * 0.2; // desynchronize animations
        [letterNode addAnimation:animation forKey:nil];
    }
    
    return textNode;
}

- (void)presentTextNode {
    _textNode = [self splittedStylizedTextWithString:@"I❤︎SceneKit"];
    _textNode.scale = SCNVector3Make(0.017, 0.0187, 0.017);
    _textNode.opacity = 0.0;
    _textNode.position = SCNVector3Make(-14, 0, 0);
    [self.groundNode addChildNode:_textNode];
}

#pragma mark - SCNShape

- (NSArray *)floorMaterials {
    SCNMaterial *lightGrayMaterial = [SCNMaterial material];
    lightGrayMaterial.diffuse.contents = [NSImage imageNamed:@"shapeMap"];
    lightGrayMaterial.locksAmbientWithDiffuse = YES;

    SCNMaterial *darkGrayMaterial = [SCNMaterial material];
    darkGrayMaterial.diffuse.contents = [NSColor colorWithDeviceWhite:0.8 alpha:1.0];
    darkGrayMaterial.locksAmbientWithDiffuse = YES;

    return @[lightGrayMaterial, lightGrayMaterial, darkGrayMaterial];
}

- (SCNMaterial *)wallMaterial {
    SCNMaterial *material = [SCNMaterial material];
    material.diffuse.contents = [NSColor colorWithDeviceRed:0.11 green:0.70 blue:0.88 alpha:1.0];
    return material;
}

- (SCNNode *)level2Node {
    SCNNode *node = [SCNNode node];
    SCNNode *roomsNode = [SCNNode node];
    
    SCNShape *floor = [SCNShape shapeWithPath:[self mosconeFloorBezierPath] extrusionDepth:10.0];
    SCNShape *walls = [SCNShape shapeWithPath:[self mosconeRoomsBezierPath] extrusionDepth:20.0];
    
    node.geometry = floor;
    node.geometry.materials = [self floorMaterials];
    
    roomsNode.geometry = walls;
    roomsNode.geometry.firstMaterial = [self wallMaterial];
    roomsNode.pivot = CATransform3DMakeTranslation(0, 0, -0.5 * 20.0);
    roomsNode.opacity = 1.0;
    
    [node addChildNode:roomsNode];
    
    return node;
}

- (SCNNode *)level2OutlineNode {
    SCNShape *floor = [SCNShape shapeWithPath:[self mosconeFloorBezierPath] extrusionDepth:10.0 * 1.01];
    floor.chamferRadius = 10.0;
    floor.chamferProfile = [self outlineChamferProfilePath];
    floor.chamferMode = SCNChamferModeFront;
    
    // Use a transparent material for everything except the chamfer. That way only the outline of the model will be visible.
    SCNMaterial *outlineMaterial = [SCNMaterial material];
    outlineMaterial.ambient.contents = outlineMaterial.diffuse.contents = outlineMaterial.specular.contents = [NSColor blackColor];
    outlineMaterial.emission.contents = [NSColor whiteColor];
    
    SCNMaterial *tranparentMaterial = [SCNMaterial material];
    tranparentMaterial.transparency = 0.0;
    
    SCNNode *node = [SCNNode node];
    node.geometry = floor;
    node.geometry.materials = @[tranparentMaterial, tranparentMaterial, tranparentMaterial, outlineMaterial, outlineMaterial];
    
    return node;
}

- (NSBezierPath *)mosconeFloorBezierPath {
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    [path moveToPoint:NSMakePoint(69,0)];
    [path lineToPoint:NSMakePoint(69,-107)];
    [path lineToPoint:NSMakePoint(0,-107)];
    [path lineToPoint:NSMakePoint(0,-480)];
    [path lineToPoint:NSMakePoint(104,-480)];
    [path lineToPoint:NSMakePoint(104,-500)];
    [path lineToPoint:NSMakePoint(184,-480)];
    [path lineToPoint:NSMakePoint(226,-480)];
    [path lineToPoint:NSMakePoint(226,-500)];
    [path lineToPoint:NSMakePoint(306,-480)];
    [path lineToPoint:NSMakePoint(348,-480)];
    [path lineToPoint:NSMakePoint(348,-500)];
    [path lineToPoint:NSMakePoint(428,-480)];
    [path lineToPoint:NSMakePoint(470,-480)];
    [path lineToPoint:NSMakePoint(470,-500)];
    [path lineToPoint:NSMakePoint(550,-480)];
    [path lineToPoint:NSMakePoint(592,-480)];
    [path lineToPoint:NSMakePoint(592,-505)];
    [path lineToPoint:NSMakePoint(752.548776,-460.046343)];
    [path curveToPoint:NSMakePoint(767.32333,-440.999893) controlPoint1:NSMakePoint(760.529967,-457.811609) controlPoint2:NSMakePoint(767.218912,-449.292876)];
    [path curveToPoint:NSMakePoint(700,0) controlPoint1:NSMakePoint(767.32333,-440.999893) controlPoint2:NSMakePoint(776,-291)];
    [path lineToPoint:NSMakePoint(69,0)];
    
    [path moveToPoint:NSMakePoint(676,-238)];
    [path lineToPoint:NSMakePoint(676,-348)];
    [path lineToPoint:NSMakePoint(710,-348)];
    [path lineToPoint:NSMakePoint(710,-238)];
    [path lineToPoint:NSMakePoint(676,-238)];
    [path lineToPoint:NSMakePoint(676,-238)];
    
    return path;
}

- (NSBezierPath *)mosconeRoomsBezierPath {
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    [path moveToPoint:NSMakePoint(553,-387)];
    [path lineToPoint:NSMakePoint(426,-387)];
    [path lineToPoint:NSMakePoint(426,-383)];
    [path lineToPoint:NSMakePoint(549,-383)];
    [path lineToPoint:NSMakePoint(549,-194)];
    [path lineToPoint:NSMakePoint(357,-194)];
    [path lineToPoint:NSMakePoint(357,-383)];
    [path lineToPoint:NSMakePoint(411,-383)];
    [path lineToPoint:NSMakePoint(411,-387)];
    [path lineToPoint:NSMakePoint(255,-387)];
    [path lineToPoint:NSMakePoint(255,-383)];
    [path lineToPoint:NSMakePoint(353,-383)];
    [path lineToPoint:NSMakePoint(353,-194)];
    [path lineToPoint:NSMakePoint(175,-194)];
    [path lineToPoint:NSMakePoint(175,-383)];
    [path lineToPoint:NSMakePoint(240,-383)];
    [path lineToPoint:NSMakePoint(240,-387)];
    [path lineToPoint:NSMakePoint(171,-387)];
    [path lineToPoint:NSMakePoint(171,-190)];
    [path lineToPoint:NSMakePoint(553,-190)];
    [path lineToPoint:NSMakePoint(553,-387)];
    
    [path moveToPoint:NSMakePoint(474,-141)];
    [path lineToPoint:NSMakePoint(474,-14)];
    [path lineToPoint:NSMakePoint(294,-14)];
    [path lineToPoint:NSMakePoint(294,-141)];
    [path lineToPoint:NSMakePoint(407,-141)];
    [path lineToPoint:NSMakePoint(407,-145)];
    [path lineToPoint:NSMakePoint(172,-145)];
    [path lineToPoint:NSMakePoint(172,-141)];
    [path lineToPoint:NSMakePoint(290,-141)];
    [path lineToPoint:NSMakePoint(290,-14)];
    [path lineToPoint:NSMakePoint(124,-14)];
    [path lineToPoint:NSMakePoint(124,-141)];
    [path lineToPoint:NSMakePoint(157,-141)];
    [path lineToPoint:NSMakePoint(157,-145)];
    [path lineToPoint:NSMakePoint(120,-145)];
    [path lineToPoint:NSMakePoint(120,-10)];
    [path lineToPoint:NSMakePoint(478,-10)];
    [path lineToPoint:NSMakePoint(478,-145)];
    [path lineToPoint:NSMakePoint(422,-145)];
    [path lineToPoint:NSMakePoint(422,-141)];
    [path lineToPoint:NSMakePoint(474,-141)];
    
    return path;
}

- (NSBezierPath *)outlineChamferProfilePath {
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(1, 1)];
    [path lineToPoint:NSMakePoint(1, 0)];
    return path;
}

@end
