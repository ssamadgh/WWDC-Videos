/*
     File: ASCSlideCreatingGeometries.m
 Abstract:  Create geometry programmatically slide. 
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

// use GLKit to do maths
#import <GLKit/GLKMath.h>

// an example of datastructure to represent a vertex
// this will be used to create custom geometries
typedef struct {
    float x, y, z;
    float nx, ny, nz;
    float s, t;
} ASCVertex;

@interface ASCSlideCreatingGeometries : ASCSlide
@end

@implementation ASCSlideCreatingGeometries

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentation {
    // retrieve the text manager and add a title
    ASCSlideTextManager *textManager = [self textManager];
    [textManager setTitle:@"Creating Geometries"];
}

#pragma mark - primitives

// create a carousel of 3D primitive
- (void)presentPrimitives:(ASCPresentationViewController *)controller {
    //settings of the carousel
#define RADIUS 13.0
#define SIZE 5.0
#define COUNT 9.0
    
    //position X and Y in the carousel for a given index
#define PX(Index) RADIUS*sin(M_PI*2*Index/COUNT)
#define PZ(Index) RADIUS*cos(M_PI*2*Index/COUNT)
    
    /* add a primitive to the carousel:
     create a node
     attach the geometry
     place it
     add an animation
     add as a child of the "carousel" node */
#define ADD_PRIMITIVE(P, Y) { SCNNode *node = [SCNNode node];\
node.geometry = P;\
node.geometry.firstMaterial = material;\
node.position = SCNVector3Make(PX(primitiveIndex), Y, PZ(primitiveIndex));\
primitiveIndex++;\
rotationAnimation.timeOffset = -primitiveIndex*1.0;\
[node addAnimation:rotationAnimation forKey:nil];\
[carousel addChildNode:node];}
    
    int primitiveIndex = 0;
    
    //create the carousel node. We will add the privitive as child node to it
    SCNNode *carousel = [SCNNode node];
    carousel.name = @"carousel";
    carousel.position = SCNVector3Make(0, 0.1, -5);
    carousel.scale = SCNVector3Make(0, 0, 0); //start infinity small
    [self.ground addChildNode:carousel];
    
    //scale up with an animation
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.0];
    carousel.scale = SCNVector3Make(1, 1, 1);
    [SCNTransaction commit];
    
    //rotate the carousel forever
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    rotationAnimation.duration = 40.0;
    rotationAnimation.repeatCount = FLT_MAX;
    rotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI*2)];
    [carousel addAnimation:rotationAnimation forKey:nil];
    
    //setup a shared material for all primitive
    SCNMaterial *material = [SCNMaterial material];
    material.reflective.contents = [NSImage imageNamed:@"envmap"];
    material.reflective.intensity = 0.2;
    material.doubleSided = YES;
    
    /* create and add primitives */
    
    //box
    SCNBox *box = [SCNBox boxWithWidth:SIZE height:SIZE length:SIZE chamferRadius:SIZE*0.05];
    box.widthSegmentCount = 4;
    box.heightSegmentCount = 4;
    box.lengthSegmentCount = 4;
    box.chamferSegmentCount = 4;
    ADD_PRIMITIVE(box, SIZE/2);
    
    //pyramid
    SCNPyramid *pyramid = [SCNPyramid pyramidWithWidth:SIZE*0.8 height:SIZE length:SIZE*0.8];
    pyramid.widthSegmentCount = 4;
    pyramid.heightSegmentCount = 10;
    pyramid.lengthSegmentCount = 4;
    ADD_PRIMITIVE(pyramid, 0);
    
    //cone
    SCNCone *cone = [SCNCone coneWithTopRadius:0 bottomRadius:SIZE/2 height:SIZE];
    cone.radialSegmentCount = 20;
    cone.heightSegmentCount = 4;
    ADD_PRIMITIVE(cone, SIZE/2);
    
    //tube
    SCNTube *tube = [SCNTube tubeWithInnerRadius:SIZE*0.25 outerRadius:SIZE*0.5 height:SIZE];
    tube.heightSegmentCount = 5;
    tube.radialSegmentCount = 40;
    ADD_PRIMITIVE(tube, SIZE/2);
    
    //capsule
    SCNCapsule *capsule = [SCNCapsule capsuleWithCapRadius:SIZE*0.4 height:SIZE*1.4];
    capsule.heightSegmentCount = 5;
    capsule.radialSegmentCount = 20;
    ADD_PRIMITIVE(capsule, SIZE*0.7);
    
    //cylinder
    SCNCylinder *cylinder = [SCNCylinder cylinderWithRadius:SIZE*0.5 height:SIZE];
    cylinder.heightSegmentCount = 5;
    cylinder.radialSegmentCount = 40;
    ADD_PRIMITIVE(cylinder, SIZE/2);
    
    //sphere
    SCNSphere *sphere = [SCNSphere sphereWithRadius:SIZE*0.5];
    sphere.segmentCount = 20;
    ADD_PRIMITIVE(sphere, SIZE/2);
    
    //torus
    SCNTorus *torus = [SCNTorus torusWithRingRadius:SIZE*0.5 pipeRadius:SIZE*0.25];
    torus.ringSegmentCount = 40;
    torus.pipeSegmentCount = 20;
    ADD_PRIMITIVE(torus, SIZE/4);
    
    //plane
    SCNPlane *plane = [SCNPlane planeWithWidth:SIZE height:SIZE];
    plane.widthSegmentCount = 5;
    plane.heightSegmentCount = 5;
    plane.cornerRadius = SIZE*0.1;
    ADD_PRIMITIVE(plane, SIZE/2);
}

#pragma mark - custom geometry

/**
 Compute a Mobius ring strip as a parametric surface.
 
 To compute the vertex normal, we compute derivatives dr/du, dr/dv
 du.x = -sinu - 0.5 * t * sinu  * cosu2 - 0.25 * t * sinu2 * cosu;
 du.y =  cosu + 0.5 * t * cosu2 * cosu  - 0.25 * t * sinu2 * sinu;
 du.z =        0.25 * t * cosu2;
 
 dv.x = 0.5 * cosu2 * cosu;
 dv.y = 0.5 * sinu  * cosu2;
 dv.z = 0.5 * sinu2;
 
 and compute the cross product
 v->nx = du.y * dv.z - dv.y * du.z;
 v->ny = du.z * dv.x - dv.z * du.x;
 v->nz = du.x * dv.y - dv.x * du.y;
 
 which simplifies to
 v->nx = -0.125 * t * sinu  + 0.5  * cosu  * sinu2 + 0.25 * t * cosu2 * sinu2 * cosu;
 v->ny =  0.125 * t * cosu  + 0.5  * sinu2 * sinu  + 0.25 * t * cosu2 * sinu2 * sinu;
 v->nz = -0.5       * cosu2 - 0.25 * cosu2 * cosu2 * t;
 
 */
- (SCNGeometry *)mobiusRingWithSubdivisions:(NSInteger)subdivisions {
    NSInteger hSub = subdivisions;
    NSInteger vSub = subdivisions / 2;
    NSInteger vcount = (hSub + 1) * (vSub + 1);
    NSInteger icount = (hSub * vSub) * 6;
    
    ASCVertex *vertices = malloc(sizeof(ASCVertex) * vcount);
    unsigned short *indices = malloc(sizeof(unsigned short) * icount);
    
    // -- vertices
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
    
    //-- indices
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
    
    // create the geometry source
    SCNGeometrySource *source = [SCNGeometrySource geometrySourceWithData:data
                                                                 semantic:SCNGeometrySourceSemanticVertex
                                                              vectorCount:vcount
                                                          floatComponents:YES
                                                      componentsPerVector:3
                                                        bytesPerComponent:sizeof(float)
                                                               dataOffset:0
                                                               dataStride:sizeof(ASCVertex)];
    
    // create the normal source
    SCNGeometrySource *normalSource = [SCNGeometrySource geometrySourceWithData:data
                                                                       semantic:SCNGeometrySourceSemanticNormal
                                                                    vectorCount:vcount
                                                                floatComponents:YES
                                                            componentsPerVector:3
                                                              bytesPerComponent:sizeof(float)
                                                                     dataOffset:offsetof(ASCVertex, nx)
                                                                     dataStride:sizeof(ASCVertex)];
    
    
    // create the texcoord source
    SCNGeometrySource *texCoordSource = [SCNGeometrySource geometrySourceWithData:data
                                                                         semantic:SCNGeometrySourceSemanticTexcoord
                                                                      vectorCount:vcount
                                                                  floatComponents:YES
                                                              componentsPerVector:2
                                                                bytesPerComponent:sizeof(float)
                                                                       dataOffset:offsetof(ASCVertex, s)
                                                                       dataStride:sizeof(ASCVertex)];
    
    
    // create the geometry element
    SCNGeometryElement *element = [SCNGeometryElement geometryElementWithData:[NSData dataWithBytes:indices length:icount * sizeof(unsigned short)]
                                                                primitiveType:SCNGeometryPrimitiveTypeTriangles
                                                               primitiveCount:icount/3
                                                                bytesPerIndex:sizeof(unsigned short)];
    
    free(indices);
    
    // return the geometry
    return [SCNGeometry geometryWithSources:@[source, normalSource, texCoordSource] elements:@[element]];
}

#pragma mark - stylized 3d text

// creates an attributed string from a string with the font and size we want
- (NSAttributedString *)attributedStringWithString:(NSString *) string {
    NSFont *font = [NSFont fontWithName:@"Avenir Next Heavy" size:288];
    NSDictionary *attributes = @{ NSFontAttributeName : font };
    return [[NSMutableAttributedString alloc] initWithString:string attributes:attributes];
}

// the material used for the front side of the 3d text
- (SCNMaterial *)frontMaterial {
    SCNMaterial *material = [SCNMaterial material];
    material.diffuse.contents = [NSColor blackColor];
    material.reflective.contents = [NSImage imageNamed:@"envmap"];
    material.reflective.intensity = 0.5;
    material.multiply.contents = [NSImage imageNamed:@"gradient2"];
    return material;
}

// the material used for the side and chamfer of the 3d text
- (SCNMaterial *)sideAndChamferMaterial {
    SCNMaterial *material = [SCNMaterial material];
    material.diffuse.contents = [NSColor whiteColor];
    material.reflective.contents = [NSImage imageNamed:@"envmap"];
    material.reflective.intensity = 0.4;
    return material;
}

// the curve we use to chamfer the 3d text
- (NSBezierPath *)chamferProfile {
    NSBezierPath *profile = [NSBezierPath bezierPath];
    [profile moveToPoint:NSMakePoint(0, 1)];
    [profile lineToPoint:NSMakePoint(1.5, 1)];
    [profile lineToPoint:NSMakePoint(1.5, 0)];
    [profile lineToPoint:NSMakePoint(1, 0)];
    return profile;
}

/* creates a node that representes the passed string as a 3D text
 The returned node has one child per letter.
 Each letter is animated */
- (SCNNode *)splittedStylizedTextWithString:(NSString *) string {
    //get the materials to use for the 3d text
    SCNMaterial *frontMaterial = [self frontMaterial];
    SCNMaterial *border = [self sideAndChamferMaterial];
    
    //instanciate the parent node
    SCNNode *textNode = [SCNNode node];
    
    //current x position of the next letter to add
    CGFloat x = 0;
    
    //for every letter
    for (NSUInteger i = 0; i < [string length]; i++) {
        //get the letter as a NSString
        NSString *letterString = [string substringWithRange:NSMakeRange(i, 1)];
        
        //create a node
        SCNNode *letterNode = [SCNNode node];
        
        //create a 3D text
        SCNText *text = [SCNText textWithString:[self attributedStringWithString:letterString] extrusionDepth:50.0];
        
        //use a different fron material for the "heart character"
        SCNMaterial *front = frontMaterial;
        if (i==1) {
            front = [front copy];
            front.diffuse.contents = [NSColor redColor];
            front.reflective.contents = [NSColor blackColor];
            letterNode.scale = SCNVector3Make(1.1, 1.1, 1);
        }
        
        // assign the materials to the text geometry
        text.materials = @[front, front, border, border, border];
        
        //configure the chamfer
        text.chamferRadius = 3.0;
        text.chamferProfile = [self chamferProfile];
        
        //attache the geometry to the node
        letterNode.geometry = text;
        
        //add the node to the parent group
        [textNode addChildNode:letterNode];
        
        //measure the letter we just added to update the next x position for the next letter
        SCNVector3 min, max;
        max = SCNVector3Make(0, 0, 0);
        min = SCNVector3Make(0, 0, 0);
        if ([letterNode getBoundingBoxMin:&min max:&max]) {
            letterNode.position = SCNVector3Make(x-min.x + (max.x+min.x)*0.5, -min.y, 0);
            x += max.x;
        }
        else{
            //if we have no bounding box, this is probably because of the "space" character.
            //in that case, move to the right a little bit.
            x += 50.0;
        }
        
        //make the pivot the center of the letter so that the rotate animation looks good
        letterNode.pivot = CATransform3DMakeTranslation((max.x+min.x)*0.5, 0, 0);
        
        //animate the letter
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"rotation"];
        animation.duration = 4.0;
        
        // rotate during the first 30% , then wait 70%
        animation.keyTimes = @[@0.0, @0.3, @1.0];
        animation.values = @[[NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, 0)],
                             [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI*2)],
                             [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI*2)]];
        CAMediaTimingFunction *tf = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        animation.timingFunctions = @[tf, tf, tf];
        
        //repeat forever
        animation.repeatCount = FLT_MAX;
        
        //desynchronize animations
        animation.beginTime = CACurrentMediaTime() + 1.0 + i*0.2;
        
        //add the animation
        [letterNode addAnimation:animation forKey:nil];
    }
    
    //return that parent node of every text nodes
    return textNode;
}

// return the node that represent the 3D "I love scenekit" text
- (SCNNode *)stylizedTextNode {
    SCNNode *textNode = [self splittedStylizedTextWithString:@"I❤︎SceneKit"];
    
    //the text we create is huge by default, scale it down (and strech horizontally a little bit)
    CGFloat scale = 0.017;
    textNode.scale = SCNVector3Make(scale, scale*1.1, scale);
    
    return textNode;
}

#pragma mark - shapes

// create a shape that represents the plan of a floor
- (NSBezierPath *)mosconeBezierPath {
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

// some constants
static CGFloat const floorExtrusionDepth = 10.0;
static CGFloat const wallExtrusionDepth = 20.0;

// the materials to use for the floor
- (NSArray *)floorMaterials {
    // material for the "ground"
    SCNMaterial *lightGrayMaterial = [SCNMaterial material];
    lightGrayMaterial.diffuse.contents = [NSImage imageNamed:@"shapeMap"];
    lightGrayMaterial.locksAmbientWithDiffuse = YES;
    
    // material for the side
    SCNMaterial *darkGrayMaterial = [SCNMaterial material];
    darkGrayMaterial.diffuse.contents = [NSColor colorWithDeviceWhite:0.8 alpha:1.0];
    darkGrayMaterial.locksAmbientWithDiffuse = YES;
    
    // return in the order the 3d shape geometry wants (front, back, side)
    return @[lightGrayMaterial, lightGrayMaterial, darkGrayMaterial];
}

// the material to use for the walls
- (SCNMaterial *)wallMaterial {
    SCNMaterial *material = [SCNMaterial material];
    material.diffuse.contents = [NSColor colorWithDeviceRed:0.11 green:0.70 blue:0.88 alpha:1.0];
    return material;
}

// create a shape that represents the walls of the room of this floor
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

// the curve to use to extrude the shape
- (NSBezierPath *)chamferProfileForOutline {
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(1, 1)];
    [path lineToPoint:NSMakePoint(1, 0)];
    return path;
}

// create the model that contains both the floor and the walls
- (SCNNode *)level2Node {
    //create the floor
    SCNNode *node = [SCNNode node];
    SCNShape *floor = [SCNShape shapeWithPath:[self mosconeBezierPath] extrusionDepth:floorExtrusionDepth];
    
    node.geometry = floor;
    node.geometry.materials = [self floorMaterials];
    
    //create the walls
    SCNNode *roomsNode = [SCNNode node];
    SCNShape *walls = [SCNShape shapeWithPath:[self mosconeRoomsBezierPath] extrusionDepth:wallExtrusionDepth];
    
    roomsNode.geometry = walls;
    roomsNode.geometry.firstMaterial = [self wallMaterial];
    roomsNode.pivot = CATransform3DMakeTranslation(0, 0, -0.5 * wallExtrusionDepth);
    roomsNode.opacity = 1.0;
    
    [node addChildNode:roomsNode];
    
    return node;
}

// create the model that just show the outline of the floor
- (SCNNode *)level2OutlineNode {
    //create the floor geometry
    SCNNode *node = [SCNNode node];
    SCNShape *floor = [SCNShape shapeWithPath:[self mosconeBezierPath] extrusionDepth:floorExtrusionDepth * 1.01];
    floor.chamferRadius = floorExtrusionDepth;
    floor.chamferProfile = [self chamferProfileForOutline];
    floor.chamferMode = SCNChamferModeFront;
    
    // use a transparent material for everything but the chamfer
    // that way only the outline of the model will be visible
    SCNMaterial *outlineMaterial = [SCNMaterial material];
    outlineMaterial.ambient.contents = outlineMaterial.diffuse.contents = outlineMaterial.specular.contents = [NSColor blackColor];
    outlineMaterial.emission.contents = [NSColor whiteColor];
    
    SCNMaterial *tranparentMaterial = [SCNMaterial material];
    tranparentMaterial.transparency = 0.0;
    
    node.geometry = floor;
    node.geometry.materials = @[tranparentMaterial, tranparentMaterial, tranparentMaterial, outlineMaterial, outlineMaterial];
    
    return node;
}


#pragma mark - steps

- (NSUInteger)numberOfSteps {
    return 7;
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)controller {
    static BOOL cancelElevation = NO;
    
    switch (index) {
        case 0:
            break;
        case 1:
            //-- primitives
            [self.textManager setSubtitle:@"Built-in parametric primitives"];
            [self presentPrimitives:controller];
            break;
        case 2:
            //-- 3d text
        {
            //order out primitives
            [self.textManager flipOutTextType:ASCTextTypeSubTitle];
            SCNNode *node = [self.rootNode childNodeWithName:@"carousel" recursively:YES];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            [SCNTransaction setCompletionBlock:^{
                [node removeFromParentNode];
                
                //order in 3d text
                [SCNTransaction begin];
                [SCNTransaction setAnimationDuration:1.0];
                
                SCNNode *textNode = [self stylizedTextNode];
                textNode.name = @"wwdc-text";
                [textNode setOpacity:0.0];
                textNode.position = SCNVector3Make(-14, 0, 0);
                
                [self.ground addChildNode:textNode];
                [textNode setOpacity:1.0];
                
                [SCNTransaction commit];
                
            }];
            [node setOpacity:0.0];
            
            [SCNTransaction commit];
            
            //add some text to the slide
            [self.textManager setSubtitle:@"Built-in 3D text"];
            [self.textManager addBullet:@"SCNText" atLevel:0];
            [self.textManager flipInTextType:ASCTextTypeSubTitle];
            [self.textManager flipInTextType:ASCTextTypeBullet];
        }
            break;
        case 3:
        {
            //order out text
            SCNNode *node = [self.ground childNodeWithName:@"wwdc-text" recursively:YES];
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            [SCNTransaction setCompletionBlock:^{
                
                //new in 10.9
                controller.showsNewInSceneKitBadge = YES;
                
                [node removeFromParentNode];
                
                //--add some text to the slide about shape
                [self.textManager flipOutTextType:ASCTextTypeSubTitle];
                [self.textManager flipOutTextType:ASCTextTypeBullet];
                [self.textManager setSubtitle:@"3D Shapes"];
                [self.textManager addBullet:@"SCNShape" atLevel:0];
                [self.textManager addBullet:@"Initializes with a NSBezierPath" atLevel:0];
                [self.textManager addBullet:@"Extrusion and chamfer" atLevel:0];
                [self.textManager addCode:@"aNode.geometry = [SCNShape #shapeWithPath:#aBezierPath #extrusionDepth:#10];"];
                [self.textManager flipInTextType:ASCTextTypeSubTitle];
                [self.textManager flipInTextType:ASCTextTypeBullet];
                [self.textManager flipInTextType:ASCTextTypeCode];
            }];
            node.opacity = 0.0;
            [SCNTransaction commit];
            
        }
            break;
        case 4:
        {
            //fade out text
            [self.textManager fadeOutTextType:ASCTextTypeBullet];
            [self.textManager fadeOutTextType:ASCTextTypeCode];
            
            //add shape outline and shape
            SCNNode *level2OutlineNode = [self level2OutlineNode];
            SCNNode *level2 = [self level2Node];
            
            level2OutlineNode.name = @"level2outline";
            level2.name = @"level2";
            
            //make both transparent at first
            level2OutlineNode.opacity = 0.0;
            level2.opacity = 0.0;
            
            //place everything
            level2.position = level2OutlineNode.position = SCNVector3Make(-11, 0, -5);
            level2.rotation = level2OutlineNode.rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
            level2OutlineNode.scale = SCNVector3Make(0.03, 0.03, 0.05);
            level2.scale = SCNVector3Make(level2OutlineNode.scale.x, level2OutlineNode.scale.y, 0);
            
            //add to the scene
            [self.ground addChildNode:level2OutlineNode];
            [self.ground addChildNode:level2];
            
            //reveal shape
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            level2OutlineNode.opacity = 1.0;
            [SCNTransaction commit];
        }
            break;
        case 5:
        {
            //remove new badge
            controller.showsNewInSceneKitBadge = NO;
            
            //reveal the floor plan
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            
            SCNNode *level2 = [self.ground childNodeWithName:@"level2" recursively:YES];
            level2.opacity = 1.0;
            level2.scale = SCNVector3Make(0.03, 0.03, 0.05);
            
            cancelElevation = NO;
            
            [SCNTransaction setCompletionBlock:^{
                if (!cancelElevation) { /* check that we are still on this slide */
                    [SCNTransaction begin];
                    [SCNTransaction setAnimationDuration:1.5];
                    
                    //move the camera a little upper
                    controller.cameraNode.position = SCNVector3Make(0, 7, -3);
                    controller.cameraPitch.rotation = SCNVector4Make(1, 0, 0, -M_PI_4*0.7);
                    
                    [SCNTransaction commit];
                }
            }];
            
            
            [SCNTransaction commit];
        }
            break;
        case 6:
        {
            cancelElevation = YES; /*make sure we cancel animation above if we quickly run through the slides */
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            
            //move back the camera to the previous position
            controller.cameraNode.position = SCNVector3Make(0,0,0);
            controller.cameraPitch.rotation = SCNVector4Make(1, 0, 0, self.pitch * M_PI / 180.0);
            
            [SCNTransaction setCompletionBlock:^{
                // add the custom geometry (moebius)
                SCNNode *node = [SCNNode node];
                node.name = @"custom geometry";
                node.position = SCNVector3Make(0, 2.7, 7);
                
                SCNNode *moebius = [SCNNode node];
                moebius.geometry = [self mobiusRingWithSubdivisions:150];
                moebius.rotation = SCNVector4Make(1, 0, 0, -M_PI_4);
                moebius.scale = SCNVector3Make(4, 2.2, 2.2);
                [node addChildNode:moebius];
                moebius.opacity = 0.0;
                [self.ground addChildNode:node];
                
                //textures
                moebius.geometry.firstMaterial = [SCNMaterial material];
                moebius.geometry.firstMaterial.diffuse.contents = [NSImage imageNamed:@"moebius"];
                moebius.geometry.firstMaterial.diffuse.wrapS = SCNRepeat;
                moebius.geometry.firstMaterial.diffuse.wrapT = SCNRepeat;
                moebius.geometry.firstMaterial.doubleSided = YES;
                moebius.geometry.firstMaterial.reflective.contents = [NSImage imageNamed:@"envmap"];
                moebius.geometry.firstMaterial.reflective.intensity = 0.3;
                
                //animate
                CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
                rotationAnimation.duration = 10.0;
                rotationAnimation.repeatCount = FLT_MAX;
                rotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI*2)];
                [node addAnimation:rotationAnimation forKey:nil];
                
                //reveal
                [SCNTransaction begin];
                [SCNTransaction setAnimationDuration:1.0];
                moebius.opacity = 1.0;
                [SCNTransaction commit];
            }];
            
            //fade out the floor plan
            SCNNode *level2 = [self.ground childNodeWithName:@"level2" recursively:YES];
            level2.opacity = 0.0;
            
            SCNNode *level2outline = [self.ground childNodeWithName:@"level2outline" recursively:YES];
            level2outline.opacity = 0.0;
            
            [SCNTransaction commit];
            
            //add custom geometry titles
            [self.textManager flipOutTextType:ASCTextTypeSubTitle];
            [self.textManager flipOutTextType:ASCTextTypeBullet];
            [self.textManager setSubtitle:@"Custom geometry"];
            [self.textManager addBullet:@"Custom vertices, normals and texture coordinates" atLevel:0];
            [self.textManager addBullet:@"SCNGeometry" atLevel:0];
            [self.textManager flipInTextType:ASCTextTypeSubTitle];
            [self.textManager flipInTextType:ASCTextTypeBullet];
            
            
        }
            break;
    }
}

- (void)orderOutWithPresentionViewController:(ASCPresentationViewController *)controller {
    //make sure the camera is back to its default location before leaving this slide
    controller.cameraNode.position = SCNVector3Make(0, 0, 0);
}


@end
