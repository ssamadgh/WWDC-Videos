/*
     File: ASCSlideScenegraph.m
 Abstract:  Scene graph slide. Explains the structure of the scene graph with a schema 
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
#import "ASCSlideSceneGraph.h"
#import "Utils.h"

@implementation ASCSlideSceneGraph

- (NSUInteger)numberOfSteps {
    return 4;
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentation {
    // retrieve the text manager
    ASCSlideTextManager *textManager = [self textManager];
    
    // add some text
    [textManager setTitle:@"Scene Graph"];
    [textManager setSubtitle:@"Scene"];
    [textManager addBullet:@"SCNScene" atLevel:0];
    [textManager addBullet:@"Starting point" atLevel:0];
    
    // setup the schema node tree
    SCNNode *schema = [[self class] sceneKitSchemaModel];
    
    // add it to the ground node attached to this slide
    [self.ground addChildNode:schema];
}

// setup and return a node tree that represents the structure of SceneKit's scene graph
+ (SCNNode *)sceneKitSchemaModel {
    static SCNNode *schema = nil;
    
    if (schema == nil) {
        //-- instanciate a new node
        schema = [SCNNode node];
        
        //-- start transparent
        schema.opacity = 0.0;
        
        //-- scene box
        NSColor* blue = [NSColor colorWithDeviceRed:49.0/255 green:80.0/255 blue:201/255.0 alpha:1];
        SCNNode *box = [SCNNode asc_boxNodeWithTitle:@"Scene" frame:NSMakeRect(-53.5, -25, 107, 50) color:blue cornerRadius:10 centered:YES];
        box.name = @"scene";
        box.scale = SCNVector3Make(0.03, 0.03, 0.03);
        box.position = SCNVector3Make(5.4, 4.8, 0);
        [schema addChildNode:box];
        
        //-- arrow from scene to root node
        SCNNode *arrowNode = [SCNNode node];
        arrowNode.name = @"sceneArrow";
        arrowNode.geometry = [SCNShape shapeWithPath:[NSBezierPath asc_arrowBezierPathWithBaseSize:NSMakeSize(3,0.2) tipSize:NSMakeSize(0.5, 0.7) hollow:0.2 twoSides:NO] extrusionDepth:0];
        arrowNode.scale = SCNVector3Make(20, 20, 1);
        arrowNode.position = SCNVector3Make(-5, 0, 8);
        arrowNode.rotation = SCNVector4Make(0, 0, 1, -M_PI_2);
        arrowNode.geometry.firstMaterial.diffuse.contents = blue;
        [box addChildNode:arrowNode];
        
        //-- root box
        NSColor *green = [NSColor colorWithDeviceRed:154.0/255 green:197.0/255 blue:58.0/255 alpha:1];
        box = [SCNNode asc_boxNodeWithTitle:@"Root Node" frame:NSMakeRect(-40, -36, 80, 72) color:green cornerRadius:10.0 centered:YES];
        box.name = @"rootNode";
        box.scale = SCNVector3Make(0.03, 0.03, 0.03);
        box.position = SCNVector3Make(5.405, 1.8, 0);
        [schema addChildNode:box];
        
        //-- arrows from root node to child nodes
        arrowNode = [arrowNode clone];
        arrowNode.name = @"nodeArrow1";
        
        
        arrowNode.geometry = [SCNShape shapeWithPath:[NSBezierPath asc_arrowBezierPathWithBaseSize:NSMakeSize(5.8,0.15) tipSize:NSMakeSize(0.5, 0.7) hollow:0.2 twoSides:YES] extrusionDepth:0];
        arrowNode.position = SCNVector3Make(0, -30, 8);
        arrowNode.rotation = SCNVector4Make(0, 0, 1, -(M_PI * 0.85));
        arrowNode.geometry.firstMaterial.diffuse.contents = green;
        [box addChildNode:arrowNode];
        
        arrowNode = [arrowNode clone]; // duplicate the previous arrow
        arrowNode.name = @"nodeArrow2";
        arrowNode.position = SCNVector3Make(0, -43, 8);
        arrowNode.rotation = SCNVector4Make(0, 0, 1, -(M_PI * (1-0.85)));
        [box addChildNode:arrowNode];
        
        arrowNode = [arrowNode clone]; // duplicate the previous arrow
        arrowNode.name = @"nodeArrow3";
        arrowNode.geometry = [SCNShape shapeWithPath:[NSBezierPath asc_arrowBezierPathWithBaseSize:NSMakeSize(2.6,0.15) tipSize:NSMakeSize(0.5, 0.7) hollow:0.2 twoSides:YES] extrusionDepth:0];
        arrowNode.position = SCNVector3Make(-4, -38, 8);
        arrowNode.rotation = SCNVector4Make(0, 0, 1, -(M_PI * 0.5));
        arrowNode.geometry.firstMaterial.diffuse.contents = green;
        [box addChildNode:arrowNode];
        
        //-- child boxes
        box = [SCNNode asc_boxNodeWithTitle:@"Child Node" frame:NSMakeRect(-40, -36, 80, 72) color:green cornerRadius:10.0 centered:YES];
        box.name = @"child1";
        box.scale = SCNVector3Make(0.03, 0.03, 0.03);
        box.position = SCNVector3Make(2.405, -2, 0);
        [schema addChildNode:box];
        
        box = [box clone];
        box.name = @"child2";
        box.position = SCNVector3Make(5.405, -2, 0);
        [schema addChildNode:box];
        
        box = [box clone];
        box.name = @"child3";
        box.position = SCNVector3Make(8.405, -2, 0);
        [schema addChildNode:box];
        
        //-- attributes
        NSColor *purple = [NSColor colorWithDeviceRed:190.0/255 green:56.0/255 blue:243.0/255 alpha:1];
        box = [SCNNode asc_boxNodeWithTitle:@"Light" frame:NSMakeRect(-40, -20, 80, 40) color:purple cornerRadius:10 centered:YES];
        box.name = @"light";
        box.scale = SCNVector3Make(0.03, 0.03, 0.03);
        box.position = SCNVector3Make(2.405, -4.8, 0);
        [schema addChildNode:box];
        
        //-- more arrows
        arrowNode = [SCNNode node];
        arrowNode.name = @"lightArrow";
        arrowNode.geometry = [SCNShape shapeWithPath:[NSBezierPath asc_arrowBezierPathWithBaseSize:NSMakeSize(2.0,0.15) tipSize:NSMakeSize(0.5, 0.7) hollow:0.2 twoSides:NO] extrusionDepth:0];
        arrowNode.position = SCNVector3Make(-5, 60, 8);
        arrowNode.scale = SCNVector3Make(20, 20, 1);
        arrowNode.rotation = SCNVector4Make(0, 0, 1, -M_PI_2);
        arrowNode.geometry.firstMaterial.diffuse.contents = purple;
        [box addChildNode:arrowNode];
        
        //-- camera box
        box = [SCNNode asc_boxNodeWithTitle:@"Camera" frame:NSMakeRect(-45, -20, 90, 40) color:purple cornerRadius:10 centered:YES];
        box.name = @"camera";
        box.scale = SCNVector3Make(0.03, 0.03, 0.03);
        box.position = SCNVector3Make(5.25, -4.8, 0);
        [schema addChildNode:box];
        
        //-- more arrows
        arrowNode = [arrowNode clone];
        arrowNode.name = @"cameraArrow";
        arrowNode.position = SCNVector3Make(0, 60, 8);
        [box addChildNode:arrowNode];
        
        //-- geometry box
        box = [SCNNode asc_boxNodeWithTitle:@"Geometry" frame:NSMakeRect(-55, -20, 110, 40) color:purple cornerRadius:10 centered:YES];
        box.name = @"geometry";
        box.scale = SCNVector3Make(0.03, 0.03, 0.03);
        box.position = SCNVector3Make(8.6, -4.8, 0);
        [schema addChildNode:box];
        
        //-- more arrows
        arrowNode = [arrowNode clone];
        arrowNode.name = @"geometryArrow";
        arrowNode.position = SCNVector3Make(-10, 60, 8);
        [box addChildNode:arrowNode];
        
        arrowNode = [arrowNode clone];
        arrowNode.name = @"geometryArrow2";
        arrowNode.geometry = [SCNShape shapeWithPath:[NSBezierPath asc_arrowBezierPathWithBaseSize:NSMakeSize(5.0,0.15) tipSize:NSMakeSize(0.5, 0.7) hollow:0.2 twoSides:NO] extrusionDepth:0];
        arrowNode.geometry.firstMaterial.diffuse.contents = purple;
        arrowNode.position = SCNVector3Make(-105, 53, 8);
        arrowNode.rotation = SCNVector4Make(0, 0, 1, -M_PI / 8);
        [box addChildNode:arrowNode];
        
        //-- materials
        NSColor *red = [NSColor colorWithDeviceRed:168.0/255 green:21.0/255 blue:0.0/255 alpha:1];
        
        //-- materials container box
        SCNNode *materialsBox = [SCNNode asc_boxNodeWithTitle:nil frame:NSMakeRect(-151, -25, 302, 50) color:[NSColor lightGrayColor] cornerRadius:2 centered:YES];
        materialsBox.scale = SCNVector3Make(0.03, 0.03, 0.03);
        materialsBox.name = @"materials";
        materialsBox.position = SCNVector3Make(8.7, -7.1, -0.2);
        [schema addChildNode:materialsBox];
        
        //-- material boxes
        box = [SCNNode asc_boxNodeWithTitle:@"Material" frame:NSMakeRect(-45, -20, 90, 40) color:red cornerRadius:0 centered:YES];
        box.position = SCNVector3Make(-100, 0, 0.2);
        [materialsBox addChildNode:box];
        
        box = [box clone];
        box.position = SCNVector3Make(100, 0, 0.2);
        [materialsBox addChildNode:box];
        
        box = [box clone];
        box.position = SCNVector3Make(0, 0, 0.2);
        [materialsBox addChildNode:box];
        
        //-- one more arrow
        arrowNode = [SCNNode node];
        arrowNode.geometry = [SCNShape shapeWithPath:[NSBezierPath asc_arrowBezierPathWithBaseSize:NSMakeSize(2.0,0.15) tipSize:NSMakeSize(0.5, 0.7) hollow:0.2 twoSides:NO] extrusionDepth:0];
        arrowNode.position = SCNVector3Make(-6, 65, 8);
        arrowNode.scale = SCNVector3Make(20, 20, 1);
        arrowNode.rotation = SCNVector4Make(0, 0, 1, -M_PI_2);
        arrowNode.geometry.firstMaterial.diffuse.contents = red;
        [box addChildNode:arrowNode];
        
        //flatten the material box
        [[materialsBox parentNode] replaceChildNode:materialsBox with:[materialsBox flattenedClone]];
    }
    
    return schema;
}

// highlight the element of the schema with the specified names
+ (void)highlightSchemasParts:(NSArray *)names inNodeTree:(SCNNode *)node {
    for (SCNNode *child in node.childNodes) {
        if ([names containsObject:child.name]) {
            child.opacity = 1;
            [self highlightSchemasParts:names inNodeTree:child];
        }
        else {
            if (child.opacity == 1)
                child.opacity = 0.3;
        }
    }
}

//-- reveal animation
+ (void)showSchemasParts:(NSArray *)names {
    SCNNode *schema = [self sceneKitSchemaModel];
    
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.0];
    
    for (NSString *nodeName in names) {
        SCNNode *node = [schema childNodeWithName:nodeName recursively:YES];
        node.opacity = 1;
        if (node.rotation.z==0)
            node.rotation = SCNVector4Make(0, 1, 0, 0);
    }
    
    [SCNTransaction commit];
}

//-- the slide did order in
- (void)orderInWithPresentionViewController:(ASCPresentationViewController *)controller {
    //-- retrieve the schema model
    SCNNode *schema = [[self class] sceneKitSchemaModel];
    
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.0];
    
    //fade in
    schema.opacity = 1.0;
    
    //rotate
    schema.rotation = SCNVector4Make(1, 0, 0, 0);
    
    //reveal the first component of the schema
    [[self class] showSchemasParts:@[@"scene"]];
    
    [SCNTransaction commit];
}

// reveal and/or highlight some specific parts of the schema depending on the passed step index
+ (void)updateSchemaWithStepIndex:(NSUInteger)stepIndex {
    SCNNode *schema = [[self class] sceneKitSchemaModel];
    
    switch (stepIndex) {
        case 0:
        {
            //reset all to initial state (hide and rotate)
            [schema childNodesPassingTest:^BOOL(SCNNode *child, BOOL *stop) {
                child.opacity = 0.0;
                if (child.rotation.z==0) // don't touch nodes that already have a rotation set
                    child.rotation = SCNVector4Make(0, 1, 0, M_PI_2);
                return NO;
            }];
        }
            break;
        case 1:
            [self showSchemasParts:@[@"sceneArrow", @"rootNode"]];
            break;
        case 2:
            [self showSchemasParts:@[@"child1", @"child2", @"child3", @"nodeArrow1", @"nodeArrow2", @"nodeArrow3"]];
            break;
        case 3:
            [self showSchemasParts:@[@"light", @"camera", @"geometry", @"lightArrow", @"cameraArrow", @"geometryArrow", @"geometryArrow2"]];
            break;
        case 4:
            [self showSchemasParts:@[@"scene", @"sceneArrow", @"rootNode", @"light", @"camera", @"cameraArrow", @"child1", @"child2", @"child3", @"nodeArrow1", @"nodeArrow2", @"nodeArrow3", @"geometry", @"lightArrow", @"geometryArrow", @"geometryArrow2"]];
            [self highlightSchemasParts:@[@"scene", @"sceneArrow", @"rootNode", @"light", @"camera", @"cameraArrow", @"child1", @"child2", @"child3", @"nodeArrow1", @"nodeArrow2", @"nodeArrow3", @"geometry", @"lightArrow", @"geometryArrow", @"geometryArrow2"] inNodeTree:schema];
            break;
        case 5:
            [self showSchemasParts:@[@"scene", @"sceneArrow", @"rootNode", @"light", @"camera", @"cameraArrow", @"child1", @"child2", @"child3", @"nodeArrow1", @"nodeArrow2", @"nodeArrow3", @"geometry", @"lightArrow", @"geometryArrow", @"geometryArrow2", @"materials"]];
            
            [self highlightSchemasParts:@[@"scene", @"sceneArrow", @"rootNode", @"child2", @"child3", @"nodeArrow2", @"nodeArrow3", @"geometry", @"geometryArrow", @"geometryArrow2", @"materials"] inNodeTree:schema];
            break;
        case 6:
            [self highlightSchemasParts:@[@"child3", @"geometryArrow", @"geometry"] inNodeTree:schema];
            break;
        case 7:
            [self showSchemasParts:@[@"scene", @"sceneArrow", @"rootNode", @"light", @"camera", @"cameraArrow", @"child1", @"child2", @"child3", @"nodeArrow1", @"nodeArrow2", @"nodeArrow3", @"geometry", @"lightArrow", @"geometryArrow", @"geometryArrow2", @"materials"]];
            break;
    }
}

// invoked by the controller at every step
- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)controller {
    // update the schema
    [[self class] updateSchemaWithStepIndex:index];
    
    SCNNode *schema = [[self class] sceneKitSchemaModel];
    ASCSlideTextManager *textManager = [self textManager];
    
    switch (index) {
        case 0:
            //hide all at first
            schema.opacity = 0.0;
            schema.position = SCNVector3Make(0.0, 5.0,0.0);
            schema.rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
            break;
        case 1:
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0];
            
            //flip out previous texts
            [textManager flipOutTextType:ASCTextTypeBullet];
            [textManager flipOutTextType:ASCTextTypeSubTitle];
            
            //add some text
            [textManager setSubtitle:@"Node"];
            [textManager addBullet:@"SCNNode" atLevel:0];
            [textManager addBullet:@"A location in 3D space" atLevel:0];
            [textManager addBullet:@"Position / Rotation / Scale" atLevel:1];
            
            //flip in the text we just added
            [textManager flipInTextType:ASCTextTypeSubTitle];
            [textManager flipInTextType:ASCTextTypeBullet];
            
            [SCNTransaction commit];
            break;
        case 2:
            [textManager addBullet:@"Hierarchy of nodes" atLevel:0];
            [textManager addBullet:@"Relative to the parent node" atLevel:1];
            break;
        case 3:
        {
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0];
            
            //flip out previous texts
            [textManager flipOutTextType:ASCTextTypeBullet];
            [textManager flipOutTextType:ASCTextTypeSubTitle];
            
            //add some text
            [textManager setSubtitle:@"Node attributes"];
            [textManager addBullet:@"Geometry" atLevel:0];
            [textManager addBullet:@"Camera" atLevel:0];
            [textManager addBullet:@"Light" atLevel:0];
            [textManager addBullet:@"Can be shared" atLevel:0];
            
            //flip in the text we just added
            [textManager flipInTextType:ASCTextTypeSubTitle];
            [textManager flipInTextType:ASCTextTypeBullet];
            
            [SCNTransaction commit];
            
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            
            //move the schema up otherwise it would intersect with the floor
            schema.position = SCNVector3Make(0.0, schema.position.y+1.0,0.0);
            
            [SCNTransaction commit];
        }
            break;
    }
}

@end
