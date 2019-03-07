/*
     File: ASCSlideCustomProgram.m
 Abstract:  Custom program slide. This sample code is not about OpenGL. Please read OpenGL sample for more details about OpenGL.
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

#import <OpenGL/gl3.h>
#import <GLKit/GLKMath.h>

@interface ASCSlideCustomProgram : ASCSlide
@end

@implementation ASCSlideCustomProgram

- (NSUInteger)numberOfSteps {
    return 3;
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentation {
    ASCSlideTextManager *textManager = [self textManager];
    [textManager setTitle:@"Extending Scene Kit with OpenGL"];
    [textManager setSubtitle:@"Material custom program"];
    [textManager addBullet:@"Custom GLSL code per material" atLevel:0];
    [textManager addBullet:@"Overrides Scene Kit’s rendering" atLevel:0];
    [textManager addBullet:@"Geometry attributes are provided" atLevel:0];
    [textManager addBullet:@"Transform uniforms are also provided" atLevel:0];
    
    SCNNode *object = [self.ground asc_addChildNodeNamed:@"torus" fromSceneNamed:@"torus" withScale:10];
    object.position = SCNVector3Make(8, 8, 4);
    object.name = @"object";
    
    //animate
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    rotationAnimation.duration = 10.0;
    rotationAnimation.repeatCount = FLT_MAX;
    rotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI*2)];
    [object addAnimation:rotationAnimation forKey:nil];
}

//structure to represent a vertex
typedef struct {
    GLKVector3 posSrc; // describe the source position of the morph
    GLKVector3 posDst; // describe the destination position of the morph
    GLKVector2 texCoord; // describe the texture coordinate of the vertex
} ASCMorphVertex;


// This function will create a new SCNGeometry duplicating its vertices
// in 3 instances and assigning each one of them texture coordinates representing
// the 3 corners of a triangle, containing entirely a quad of canonical (0..1) coordinates.
// This is usually done by generating the four vertices of the quad but with a triangle we
// have less 1 less vertex per quad to transform (at the expense of lost fragment bandwith).
//
// v0 (-1.0, -1.0) ---------  v1 (3.0, -1.0)
//                 |===   /
//                 |===  /
//                 |=== /
//                 |   /
//                 |  /
//                 | /
//                 |/
//                 v2 (-1.0, 3.0)
//
// The geometry is created by interleaving vertices data, allowing a more efficient
// vertex pulling by the graphic card.
- (SCNGeometry *)spriteGeometryWithRadius:(CGFloat)radius sourceGeometry:(SCNGeometry *)geometry {
    SCNGeometrySource *vSource = [geometry geometrySourcesForSemantic:SCNGeometrySourceSemanticVertex][0];
    
    NSInteger srcCount = [vSource vectorCount];
    NSInteger vCount = srcCount * 3;
    
    unsigned char *srcVertices = (unsigned char *)[[vSource data] bytes] + [vSource dataOffset];
    NSInteger srcStride = [vSource dataStride];
    
    ASCMorphVertex *dstVertices = malloc(sizeof(ASCMorphVertex) * vCount);
    
    for (NSUInteger i = 0; i < srcCount; ++i) {
        ASCMorphVertex *v0 = &dstVertices[i*3];
        ASCMorphVertex *v1 = &dstVertices[i*3 + 1];
        ASCMorphVertex *v2 = &dstVertices[i*3 + 2];
        
        GLKVector3 v = *(GLKVector3 *)(srcVertices + srcStride * i);

        // source positions
        v0->posSrc = v;
        v1->posSrc = v;
        v2->posSrc = v;

        // compute the destination position, random points mapped on a sphere of specified radius
        v = GLKVector3Make((2.f * (float)rand() / RAND_MAX - 1.f), (2.f * (float)rand() / RAND_MAX - 1.f), (2.f * (float)rand() / RAND_MAX - 1.f));
        v = GLKVector3MultiplyScalar(GLKVector3Normalize(v), radius);
        
        v0->posDst = v;
        v1->posDst = v;
        v2->posDst = v;

        // texture coordinates
        v0->texCoord = GLKVector2Make(-1.f, -1.f);
        v1->texCoord = GLKVector2Make( 3.f, -1.f);
        v2->texCoord = GLKVector2Make(-1.f,  3.f);
    }

    // Allocating an NSData that will contain verticesw data. immutable
    NSData *data = [NSData dataWithBytesNoCopy:dstVertices length:vCount * sizeof(ASCMorphVertex) freeWhenDone:YES];
    
    // create the geometry source
    SCNGeometrySource *source = [SCNGeometrySource geometrySourceWithData:data
                                                                 semantic:SCNGeometrySourceSemanticVertex
                                                              vectorCount:vCount
                                                          floatComponents:YES
                                                      componentsPerVector:3
                                                        bytesPerComponent:sizeof(float)
                                                               dataOffset:offsetof(ASCMorphVertex, posSrc)
                                                               dataStride:sizeof(ASCMorphVertex)];
    
    // create the normal source
    SCNGeometrySource *normalSource = [SCNGeometrySource geometrySourceWithData:data
                                                                       semantic:SCNGeometrySourceSemanticNormal
                                                                    vectorCount:vCount
                                                                floatComponents:YES
                                                            componentsPerVector:3
                                                              bytesPerComponent:sizeof(float)
                                                                     dataOffset:offsetof(ASCMorphVertex, posDst)
                                                                     dataStride:sizeof(ASCMorphVertex)];
    
    
    // create the texcoord source
    SCNGeometrySource *texCoordSource = [SCNGeometrySource geometrySourceWithData:data
                                                                         semantic:SCNGeometrySourceSemanticTexcoord
                                                                      vectorCount:vCount
                                                                  floatComponents:YES
                                                              componentsPerVector:2
                                                                bytesPerComponent:sizeof(float)
                                                                       dataOffset:offsetof(ASCMorphVertex, texCoord)
                                                                       dataStride:sizeof(ASCMorphVertex)];
    
    // Create indices. Each vertex is used only once per triangle.
    GLint *indices = (GLint *)malloc(sizeof(GLint) * vCount);
    for (GLint i = 0; i < vCount; ++i) {
        indices[i] = i;
    }
    
    // Create the geometry element, referencing an immutable NSData that will contain the indices.
    SCNGeometryElement *elements = [SCNGeometryElement geometryElementWithData:[NSData dataWithBytesNoCopy:indices length:vCount * sizeof(GLint) freeWhenDone:YES]
                                                                 primitiveType:SCNGeometryPrimitiveTypeTriangles primitiveCount:vCount/3 bytesPerIndex:4];
    
    // create the geometry, with the 3 geometry sources and one geometry element
    SCNGeometry * newGeometry = [SCNGeometry geometryWithSources:@[source, normalSource, texCoordSource] elements:@[elements]];
    
    // Assign the source materials to the newly created one
    [newGeometry setMaterials:[geometry materials]];
    
    return newGeometry;
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)controller {
    static float morphFactor = 0.0;

    switch (index) {
        case 0:
            // reset the morph factor
            morphFactor = -M_PI_2;
            break;
        case 1:
        {
            CFTimeInterval startTime = CFAbsoluteTimeGetCurrent();

            SCNNode *object = [self.ground childNodeWithName:@"object" recursively:YES];
            // create the supporting geometry and replace the existing geometry
            object.geometry = [self spriteGeometryWithRadius:8. sourceGeometry:object.geometry];
            
            // Create a custom program
            SCNProgram *program = [SCNProgram program];
            // Load the vertex shader and assign it
            NSURL* vertexShaderURL = [[NSBundle mainBundle] URLForResource:@"CustomProgram" withExtension:@"vsh"];
            program.vertexShader = [NSString stringWithContentsOfURL:vertexShaderURL encoding:NSASCIIStringEncoding error:NULL];
            // Load the fragment shader and assign it
            NSURL* fragmentShaderURL = [[NSBundle mainBundle] URLForResource:@"CustomProgram" withExtension:@"fsh"];
            program.fragmentShader = [NSString stringWithContentsOfURL:fragmentShaderURL encoding:NSASCIIStringEncoding error:NULL];

            // Bind the geometry source semantic to our vertex shader attributes
            [program setSemantic:SCNGeometrySourceSemanticVertex forSymbol:@"a_srcPos" options:nil];
            [program setSemantic:SCNGeometrySourceSemanticNormal forSymbol:@"a_dstPos" options:nil];
            [program setSemantic:SCNGeometrySourceSemanticTexcoord forSymbol:@"a_texcoord" options:nil];
            
            // Bind the program uniforms with the "automatic" values, computed and assigned by Scene Kit each frame
            [program setSemantic:SCNModelViewTransform forSymbol:@"u_mv" options:nil];
            [program setSemantic:SCNProjectionTransform forSymbol:@"u_proj" options:nil];

            // Bind blocks to fill the non-automatic uniforms.
            
            // animate a "time" uniform to make the particles spin.
            [object.geometry.firstMaterial handleBindingOfSymbol:@"time" usingBlock:^(unsigned int programID, unsigned int location, SCNNode *renderedNode, SCNRenderer *renderer) {
                glUniform1f(location, CFAbsoluteTimeGetCurrent() - startTime);
            }];
            
            // animate a morph factor to allow to morph back and forth the object in the vertex shader. This is not time based
            [object.geometry.firstMaterial handleBindingOfSymbol:@"factor" usingBlock:^(unsigned int programID, unsigned int location, SCNNode *renderedNode, SCNRenderer *renderer) {
                morphFactor += 0.01;
                glUniform1f(location, sin(morphFactor)*0.5 + 0.5);
            }];
            
            // Configure the material to use our custom program
            object.geometry.firstMaterial.program = program;
            // We do not want to interact at all with depth buffer, to provide an additive effect
            object.geometry.firstMaterial.writesToDepthBuffer = NO;
            object.geometry.firstMaterial.readsFromDepthBuffer = NO;
            // as we don't interact with the depth buffer, we need to be displayed after the rest of the scene
            object.renderingOrder = 100;
            
        }
            break;
        case 2:
        {
            [self.textManager fadeOutTextType:ASCTextTypeBullet];
            
            [self.textManager addEmptyLine];
            [self.textManager addCode:@"[aMaterial #handleBindingOfSymbol:#@\"myUniform\""];
            [self.textManager addCode:@"                      #usingBlock:#"];
            [self.textManager addCode:@"       ^(unsigned int programID,"];
            [self.textManager addCode:@"         unsigned int location,"];
            [self.textManager addCode:@"         SCNNode *node,"];
            [self.textManager addCode:@"         SCNRenderer *renderer) {"];
            [self.textManager addCode:@"    glUniform1f(location, aValue);"];
            [self.textManager addCode:@"}];"];


            
            [self.textManager flipInTextType:ASCTextTypeCode];
        }
            break;
    }
}

@end
