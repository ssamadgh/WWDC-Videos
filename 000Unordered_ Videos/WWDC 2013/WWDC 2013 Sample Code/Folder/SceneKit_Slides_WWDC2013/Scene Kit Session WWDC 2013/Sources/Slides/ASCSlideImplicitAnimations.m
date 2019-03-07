/*
     File: ASCSlideImplicitAnimations.m
 Abstract:  "Implicit animations" slide. 
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

@interface ASCSlideImplicitAnimations : ASCSlide
@end

@implementation ASCSlideImplicitAnimations

- (NSUInteger)numberOfSteps {
    return 4;
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentation {
    //retrieve the text manager and add some text and some code
    ASCSlideTextManager *textManager = [self textManager];
    [textManager setTitle:@"Animations"];
    [textManager setSubtitle:@"Implicit animations"];
    [textManager addCode:@"// Begin a transaction"];
    [textManager addCode:@"[#SCNTransaction# begin];"];
    [textManager addCode:@"[#SCNTransaction# setAnimationDuration:2.0];"];
    
    //jump a new line
    [textManager addEmptyLine];
    
    [textManager addCode:@"// Change properties"];
    [textManager addCode:@"aNode.#opacity# = 1.0;"];
    [textManager addCode:@"aNode.#rotation# = SCNVector4(0, 1, 0, M_PI*4);"];
    
    //jump a new line
    [textManager addEmptyLine];
    
    [textManager addCode:@"// Commit the transaction"];
    [textManager addCode:@"[SCNTransaction #commit#];"];
    
    // create a simple torus that we will animate to illustrate the code
    SCNNode *node = [SCNNode node];
    
    //name it for later retrieval
    node.name = @"animatedNode";
    
    //place it
    node.position = SCNVector3Make(10, 7, 0);
    
    //use a child node to attach the geometry
    //that way we can use a rotation on the Y axis for the animation (on "node")
    //and a rotation on the X axis to tilt the torus
    SCNNode *childnode = [SCNNode node];
    childnode.geometry = [SCNTorus torusWithRingRadius:4.0 pipeRadius:1.5];
    childnode.rotation = SCNVector4Make(1, 0, 0, -M_PI * 0.7);
    
    //make it nice looking
    childnode.geometry.firstMaterial.diffuse.contents = [NSColor cyanColor];
    childnode.geometry.firstMaterial.specular.contents = [NSColor whiteColor];
    childnode.geometry.firstMaterial.reflective.contents = [NSImage imageNamed:@"envmap"];
    childnode.geometry.firstMaterial.fresnelExponent = 0.7;

    //setup hierarchy
    [node addChildNode:childnode];
    
    //add tothis slide
    [self.rootNode addChildNode:node];
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)controller {
    //retrieve the torus node
    SCNNode *node = [self.rootNode childNodeWithName:@"animatedNode" recursively:YES];
    
    // animate by default
    [SCNTransaction begin];

    switch (index) {
        case 0:
            //disable animation for step 0
            [SCNTransaction setAnimationDuration:0];
                
            //start dimmed
            node.opacity = 0.25;
            
            //unhighlight all
            [self.textManager highlightCodeLinesInRange:NSMakeRange(0, 0)];
            break;
        case 1:
            //highlight code
            [self.textManager highlightCodeLinesInRange:NSMakeRange(0, 3)];
            break;
        case 2:
            //highlight code
            [self.textManager highlightCodeLinesInRange:NSMakeRange(4, 2)];
            break;
        case 3:
        {
            //highlight code
            [self.textManager highlightCodeLinesInRange:NSMakeRange(7, 2)];

            //animate
            SCNNode *node = [self.rootNode childNodeWithName:@"animatedNode" recursively:YES];

            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:2.0];
            
            node.opacity = 1.0;
            node.rotation = SCNVector4Make(0, 1, 0, M_PI*4);
            
            [SCNTransaction commit];
        }
            break;
        default:
            break;
    }
    
    [SCNTransaction commit];
}

@end
