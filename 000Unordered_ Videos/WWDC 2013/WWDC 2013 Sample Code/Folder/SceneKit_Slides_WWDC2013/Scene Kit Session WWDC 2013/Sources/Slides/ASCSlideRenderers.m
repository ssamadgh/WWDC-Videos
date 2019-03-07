/*
     File: ASCSlideRenderers.m
 Abstract:  Renderers slide. Displays 3 images and some text to describe the 3 ways to render a scene 
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

@interface ASCSlideRenderers : ASCSlide
@end

@implementation ASCSlideRenderers

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentation {
    // retrieve the text manager and add some text
    ASCSlideTextManager *textManager = [self textManager];
    [textManager setTitle:@"Renderers"];
    
    //add and place 3 text boxes
#define Z 5
    SCNNode *node = [SCNNode asc_labelNodeWithString:@"SCNView"];
    node.position = SCNVector3Make(-14, 7, 0);
    [self.rootNode addChildNode:node];
    
    node = [SCNNode asc_labelNodeWithString:@"SCNLayer"];
    node.position = SCNVector3Make(-2.2, 7, 0);
    [self.rootNode addChildNode:node];
    
    node = [SCNNode asc_labelNodeWithString:@"SCNRenderer"];
    node.position = SCNVector3Make(9.5, 7, 0);
    [self.rootNode addChildNode:node];
    
    /* add and place 3x3 images */
    
    //render into a view
    SCNNode* box = [SCNNode asc_planeNodeWithImage:[NSImage imageNamed:@"window"] size:8 isLit:YES];
    box.position = SCNVector3Make(-10, 3, Z);
    [self.rootNode addChildNode:box];
    
    //add the teapot image above the view
    box = [SCNNode asc_planeNodeWithImage:[NSImage imageNamed:@"teapotImage"] size:6 isLit:YES];
    box.position = SCNVector3Make(-10, 3, Z+0.1);
    [self.rootNode addChildNode:box];
    
    //render into a layer
    box = [SCNNode asc_planeNodeWithImage:[NSImage imageNamed:@"layer"] size:7.4 isLit:YES];
    box.position = SCNVector3Make(0, 3.5, Z);
    box.rotation = SCNVector4Make(0, 0, 1, M_PI/20);
    [self.rootNode addChildNode:box];
    
    //add the teapot image above the layer
    box = [SCNNode asc_planeNodeWithImage:[NSImage imageNamed:@"teapotImage"] size:6 isLit:YES];
    box.position = SCNVector3Make(0, 3.5, Z+0.1);
    box.rotation = SCNVector4Make(0, 0, 1, M_PI/20);
    [self.rootNode addChildNode:box];

    //renderer into a framebuffer
    box = [SCNNode asc_planeNodeWithImage:[NSImage imageNamed:@"framebuffer"] size:8 isLit:YES];
    box.position = SCNVector3Make(10, 3.2, Z);
    [self.rootNode addChildNode:box];
    
    //add the teapot image above the fbo
    box = [SCNNode asc_planeNodeWithImage:[NSImage imageNamed:@"teapotImage"] size:6 isLit:YES];
    box.position = SCNVector3Make(10, 3, Z+0.1);
    [self.rootNode addChildNode:box];    
}

@end
