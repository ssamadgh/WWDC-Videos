/*
     File: ASCSlideCloning.m
 Abstract:  Cloning slide. 
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

@interface ASCSlideCloning : ASCSlide
@end

@implementation ASCSlideCloning {
    NSColor *_red, *_purple, *_green;
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentation {
    //retrieve the text manager
    ASCSlideTextManager *textManager = [self textManager];
    
    //add some text
    [textManager setTitle:@"Performance"];
    [textManager setSubtitle:@"Copying"];
    
    [textManager addBullet:@"Attributes are shared by default" atLevel:0];
    [textManager addBullet:@"Unshare if needed" atLevel:0];
    [textManager addBullet:@"Copying geometries is cheap" atLevel:0];
    
    //setup some colors
    _green = [NSColor colorWithDeviceRed:154.0 / 255.0 green:197.0 / 255.0 blue:58.0 / 255.0 alpha:1];
    _purple = [NSColor colorWithDeviceRed:190.0 / 255.0 green:56.0 / 255.0 blue:243.0 / 255.0 alpha:1];
    _red = [NSColor colorWithDeviceRed:168.0 / 255.0 green:21.0 / 255.0 blue:0.0 / 255.0 alpha:1];
    
    //create the schema
    SCNNode *schema = [self cloningSchemaModel];
    
    //hide it
    schema.opacity = 0.0;
    
    //add to the slide
    [self.rootNode addChildNode:schema];
}

// setup and return a schema that illustrate the cloning mechanism and how to unshare attributes
- (SCNNode *)cloningSchemaModel {
    //create a root node for the schema
    SCNNode *schema = [SCNNode node];
    schema.position = SCNVector3Make(7, 9, 3);
    schema.name = @"schema";
    
    //create a box to represent the scene
    NSColor* blue = [NSColor colorWithDeviceRed:49.0 / 255.0 green:80.0 / 255.0 blue:201 / 255.0 alpha:1];
    SCNNode *box = [SCNNode asc_boxNodeWithTitle:@"Scene" frame:NSMakeRect(-53.5, -25, 107, 50) color:blue cornerRadius:10 centered:YES];
    box.name = @"scene";
    box.scale = SCNVector3Make(0.03, 0.03, 0.03);
    box.position = SCNVector3Make(0, 4.8, 0);
    [schema addChildNode:box];
    
    //an arrow from the scene to the root node
    SCNNode *arrowNode = [SCNNode node];
    arrowNode.name = @"sceneArrow";
    arrowNode.geometry = [SCNShape shapeWithPath:[NSBezierPath asc_arrowBezierPathWithBaseSize:NSMakeSize(3, 0.2) tipSize:NSMakeSize(0.5, 0.7) hollow:0.2 twoSides:NO] extrusionDepth:0];
    arrowNode.scale = SCNVector3Make(20, 20, 1);
    arrowNode.position = SCNVector3Make(-5, 0, 8);
    arrowNode.rotation = SCNVector4Make(0, 0, 1, -M_PI_2);
    arrowNode.geometry.firstMaterial.diffuse.contents = blue;
    [box addChildNode:arrowNode];
    
    //a box to represent the root node
    box = [SCNNode asc_boxNodeWithTitle:@"Root Node" frame:NSMakeRect(-40, -36, 80, 72) color:_green cornerRadius:10 centered:YES];
    box.name = @"rootNode";
    box.scale = SCNVector3Make(0.03, 0.03, 0.03);
    box.position = SCNVector3Make(0.05, 1.8, 0);
    [schema addChildNode:box];
    
    //an arrow from the root node to the child nodes
    arrowNode = [arrowNode clone];
    arrowNode.name = @"arrow";
    arrowNode.geometry = [SCNShape shapeWithPath:[NSBezierPath asc_arrowBezierPathWithBaseSize:NSMakeSize(2.6, 0.15) tipSize:NSMakeSize(0.5, 0.7) hollow:0.2 twoSides:YES] extrusionDepth:0];
    arrowNode.position = SCNVector3Make(-6, -38, 8);
    arrowNode.rotation = SCNVector4Make(0, 0, 1, -(M_PI * 0.5));
    arrowNode.geometry.firstMaterial.diffuse.contents = _green;
    [box addChildNode:arrowNode];
    
    //a box to represent a first child node (node A)
    box = [SCNNode asc_boxNodeWithTitle:@"Node A" frame:NSMakeRect(-55, -36, 110, 50) color:_green cornerRadius:10 centered:YES];
    box.name = @"nodeA";
    box.scale = SCNVector3Make(0.03, 0.03, 0.03);
    box.position = SCNVector3Make(0, -1.4, 0);
    [schema addChildNode:box];
    
    //a box to represent the geometry attribute of A
    box = [SCNNode asc_boxNodeWithTitle:@"Geometry" frame:NSMakeRect(-55, -20, 110, 40) color:_purple cornerRadius:10 centered:YES];
    box.name = @"geometry";
    box.scale = SCNVector3Make(0.03, 0.03, 0.03);
    box.position = SCNVector3Make(0, -4.7, 0);
    [schema addChildNode:box];
    
    //an arrow from node to geometry
    arrowNode = [SCNNode node];
    arrowNode.geometry = [SCNShape shapeWithPath:[NSBezierPath asc_arrowBezierPathWithBaseSize:NSMakeSize(2.6, 0.15) tipSize:NSMakeSize(0.5, 0.7) hollow:0.2 twoSides:NO] extrusionDepth:0];
    arrowNode.position = SCNVector3Make(-5, 74, 8);
    arrowNode.scale = SCNVector3Make(20, 20, 1);
    arrowNode.rotation = SCNVector4Make(0, 0, 1, -M_PI_2);
    arrowNode.geometry.firstMaterial.diffuse.contents = _purple;
    [box addChildNode:arrowNode];
    
    //add a box to represent the material
    box = [SCNNode asc_boxNodeWithTitle:@"Material" frame:NSMakeRect(-55, -20, 110, 40) color:_red cornerRadius:10 centered:YES];
    box.name = @"material";
    box.position = SCNVector3Make(0, -7.5, 0);
    box.scale = SCNVector3Make(0.03, 0.03, 0.03);
    [schema addChildNode:box];
    
    //an arrow from the geometry to the material
    arrowNode = [SCNNode node];
    arrowNode.geometry = [SCNShape shapeWithPath:[NSBezierPath asc_arrowBezierPathWithBaseSize:NSMakeSize(2.7, 0.15) tipSize:NSMakeSize(0.5, 0.7) hollow:0.2 twoSides:NO] extrusionDepth:0];
    arrowNode.position = SCNVector3Make(-6, 74, 8);
    arrowNode.scale = SCNVector3Make(20, 20, 1);
    arrowNode.rotation = SCNVector4Make(0, 0, 1, -M_PI_2);
    arrowNode.geometry.firstMaterial.diffuse.contents = _red;
    [box addChildNode:arrowNode];
    
    return schema;
}

- (NSUInteger)numberOfSteps {
    return 4;
}

- (void)orderInWithPresentionViewController:(ASCPresentationViewController *)controller {
    //once the slide ordered in, reveal the schema
    SCNNode *schema = [self.rootNode childNodeWithName:@"schema" recursively:YES];
    
    //rotate from PI/2 to 0 to animate in
    for (SCNNode *node in [schema childNodes]) {
        node.rotation = SCNVector4Make(0, 1, 0, M_PI_2);
    }
    
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:0.75];
    
    schema.opacity = 1.0; //reveal
    
    // rotate face to the camera
    for (SCNNode *node in [schema childNodes]) {
        node.rotation = SCNVector4Make(0, 1, 0, 0);
    }
    
    [SCNTransaction commit];
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)controller {
    // retrieve the text manager
    ASCSlideTextManager *textManager = self.textManager;
    
    switch (index) {
        case 0:
            break;
        case 1: //clone A to B
        {
            //retrieve node A
            SCNNode *nodeA = [self.rootNode childNodeWithName:@"nodeA" recursively:YES];
            
            //create a box to represent node B
            SCNNode *nodeB = [SCNNode asc_boxNodeWithTitle:@"Node B" frame:NSMakeRect(-55, -36, 110, 50) color:_green cornerRadius:10 centered:YES];
            
            //name it and place it
            nodeB.name = @"nodeB";
            nodeB.position = SCNVector3Make(140, 0, 0);
            nodeB.opacity = 0;
            
            //add as a child of A
            [nodeA addChildNode:nodeB];
            
            //create an arrow from the parent node to B
            SCNNode *arrowNode = [SCNNode node];
            arrowNode.geometry = [SCNShape shapeWithPath:[NSBezierPath asc_arrowBezierPathWithBaseSize:NSMakeSize(140, 3) tipSize:NSMakeSize(10, 14)  hollow:4 twoSides:YES] extrusionDepth:0];
            arrowNode.position = SCNVector3Make(-130, 60, 0);
            arrowNode.rotation = SCNVector4Make(0, 0, 1, -M_PI * 0.12);
            arrowNode.geometry.firstMaterial.diffuse.contents = _green;
            [nodeB addChildNode:arrowNode];
            
            //create an array from B to the shared geometry
            arrowNode = [SCNNode node];
            arrowNode.name = @"arrow-shared-geometry";
            arrowNode.geometry = [SCNShape shapeWithPath:[NSBezierPath asc_arrowBezierPathWithBaseSize:NSMakeSize(140, 3) tipSize:NSMakeSize(10, 14)  hollow:4 twoSides:NO] extrusionDepth:0];
            arrowNode.position = SCNVector3Make(0, -28, 0);
            arrowNode.rotation = SCNVector4Make(0, 0, 1, M_PI * 1.12);
            arrowNode.geometry.firstMaterial.diffuse.contents = _purple;
            [nodeB addChildNode:arrowNode];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1];
            
            //fade in
            nodeB.opacity = 1;
            
            //show the code to do this
            [textManager addCode:@"// Copy a node"];
            [textManager addCode:@"SCNNode *nodeB = [nodeA #copy#];"];
            
            [SCNTransaction commit];
        }
            break;
        case 2://unshare the geometry
        {
            //retrieve the geometry box and the arrow from nodeB to the geometry
            SCNNode *geometryA = [self.rootNode childNodeWithName:@"geometry" recursively:YES];
            SCNNode *oldarrow = [self.rootNode childNodeWithName:@"arrow-shared-geometry" recursively:YES];
            
            //create a box for the geometry copy
            SCNNode *geometryB = [SCNNode asc_boxNodeWithTitle:@"Geometry" frame:NSMakeRect(-55, -20, 110, 40) color:_purple cornerRadius:10 centered:YES];
            geometryB.position = SCNVector3Make(140, 0, 0);
            geometryB.opacity = 0;
            [geometryA addChildNode:geometryB];
            
            //an arrow from B to the new geometry
            SCNNode *arrowNode = [SCNNode node];
            arrowNode.geometry = [SCNShape shapeWithPath:[NSBezierPath asc_arrowBezierPathWithBaseSize:NSMakeSize(55, 3) tipSize:NSMakeSize(10, 14)  hollow:4 twoSides:NO] extrusionDepth:0];
            arrowNode.position = SCNVector3Make(0, 75, 0);
            arrowNode.rotation = SCNVector4Make(0, 0, 1, -(M_PI * 0.5));
            arrowNode.geometry.firstMaterial.diffuse.contents = _purple;
            [geometryB addChildNode:arrowNode];
            
            //an arrow from the new geometry to the material
            arrowNode = [SCNNode node];
            arrowNode.name = @"arrow-shared-material";
            arrowNode.geometry = [SCNShape shapeWithPath:[NSBezierPath asc_arrowBezierPathWithBaseSize:NSMakeSize(140, 3) tipSize:NSMakeSize(10, 14)  hollow:4 twoSides:YES] extrusionDepth:0];
            arrowNode.position = SCNVector3Make(-130, -80, 0);
            arrowNode.rotation = SCNVector4Make(0, 0, 1, +(M_PI * 0.12));
            arrowNode.geometry.firstMaterial.diffuse.contents = _red;
            [geometryB addChildNode:arrowNode];
            
            //reveal all that
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1];
            
            geometryB.opacity = 1;
            oldarrow.opacity = 0;
            
            //show some code
            [textManager addEmptyLine];
            [textManager addCode:@"// Unshare geometry"];
            [textManager addCode:@"nodeB.geometry = [nodeB.geometry #copy#];"];
            
            [SCNTransaction commit];
        }
            break;
        case 3:
        {
            //retrieve the material node and its arrow
            SCNNode *materialA = [self.rootNode childNodeWithName:@"material" recursively:YES];
            SCNNode *oldarrow = [self.rootNode childNodeWithName:@"arrow-shared-material" recursively:YES];
            
            //a new color for the new material
            NSColor *color2 = [NSColor orangeColor];
            
            //create a new box to represent the material copy
            SCNNode *materialB = [SCNNode asc_boxNodeWithTitle:@"Material" frame:NSMakeRect(-55, -20, 110, 40) color:color2 cornerRadius:10 centered:YES];
            materialB.position = SCNVector3Make(140, 0, 0);
            materialB.opacity = 0;
            [materialA addChildNode:materialB];
            
            //an arrow from the unshared geometry to the new material
            SCNNode *arrowNode = [SCNNode node];
            arrowNode.geometry = [SCNShape shapeWithPath:[NSBezierPath asc_arrowBezierPathWithBaseSize:NSMakeSize(55, 3) tipSize:NSMakeSize(10, 14)  hollow:4 twoSides:NO] extrusionDepth:0];
            arrowNode.position = SCNVector3Make(0, 75, 0);
            arrowNode.rotation = SCNVector4Make(0, 0, 1, -(M_PI * 0.5));
            arrowNode.geometry.firstMaterial.diffuse.contents = color2;
            [materialB addChildNode:arrowNode];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1];
            
            //fade in / out
            materialB.opacity = 1;
            oldarrow.opacity = 0;
            
            //show more code on the slide
            [textManager addEmptyLine];
            [textManager addCode:@"// Unshare geometry"];
            [textManager addCode:@"nodeB.geometry = [nodeB.geometry #copy#];"];
            
            [SCNTransaction commit];
        }
            break;
    }
}

@end
