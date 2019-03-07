/*
     File: ASCSlideStatistics.m
 Abstract:  Statistics slide. 
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

@interface ASCSlideStatistics : ASCSlide
@end

@implementation ASCSlideStatistics

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentation {
    //retrieve the text manager
    ASCSlideTextManager *textManager = [self textManager];
    
    //add some text and some code
    [textManager setTitle: @"Performance"];
    [textManager setSubtitle: @"Statistics"];
    
    [textManager addCode:@"// Show statistics"];
    [textManager addCode:@"aSCNView.#showsStatistics# = YES;"];
}

- (NSUInteger)numberOfSteps {
    return 6;
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)controller {
    switch (index) {
        case 0:
            break;
        case 1:
        {
            //bring up a screenshot of a SCNView with the statistics turned on
            SCNNode *node = [SCNNode asc_planeNodeWithImage:[NSImage imageNamed:@"statistics"] size:20 isLit:YES];
            
            //name it
            node.name = @"window";
            
            //force to render last otherwise the shadow of the window will clip the text behind the window
            node.renderingOrder = 10;
            
            //place it
            node.position = SCNVector3Make(20, 5.2, 9);
            node.rotation = SCNVector4Make(0, 1, 0, -M_PI_4);
            
            //hide it
            node.opacity = 0.0;
            
            //add to the scene
            [self.rootNode addChildNode:node];
            
            //reveal and animate in
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            
            node.opacity = 1.0;
            node.position = SCNVector3Make(0, 5.2, 7);
            node.rotation = SCNVector4Make(0, 1, 0, 0);
            
            [SCNTransaction commit];
        }
            break;
        case 2:
        {
            //show the fps bigger
            SCNNode* node = [SCNNode asc_planeNodeWithImage:[NSImage imageNamed:@"statistics-fps"] size:7 isLit:NO];
            SCNNode *parent = [self.rootNode childNodeWithName:@"window" recursively:YES];
            
            //name it
            node.name = @"fps";
            
            //render after the window
            node.renderingOrder = 11;
            
            //place it
            node.position = SCNVector3Make(-6, -3, 0.5);
            node.scale = SCNVector3Make(0.75, 0.75, 0.75);
            
            //hide it
            node.opacity = 0.0;
            
            //add to the scene
            [parent addChildNode:node];
            
            //reveal and zoom
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            
            node.opacity = 1.0;
            node.scale = SCNVector3Make(1, 1, 1);
            
            [SCNTransaction commit];
        }
            break;
        case 3:
        {
            //show the button that brings the debug panel
            SCNNode* node = [SCNNode asc_planeNodeWithImage:[NSImage imageNamed:@"statistics-button"] size:4 isLit:NO];
            SCNNode *parent = [self.rootNode childNodeWithName:@"window" recursively:YES];
            SCNNode *old = [self.rootNode childNodeWithName:@"fps" recursively:YES];
            
            //name, place, hide and add to the scene
            node.name = @"button";
            node.renderingOrder = 11;
            node.position = SCNVector3Make(-7.5, -2.75, 0.5);
            node.scale = SCNVector3Make(0.75, 0.75, 0.75);
            node.opacity = 0.0;
            [parent addChildNode:node];
            
            //reveal and hide the fps
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            
            node.opacity = 1.0;
            node.scale = SCNVector3Make(1, 1, 1);
            old.opacity = 0.0;
            
            [SCNTransaction commit];

        }
            break;
        case 4:
        {
            //show the debug panel
            SCNNode* node = [SCNNode asc_planeNodeWithImage:[NSImage imageNamed:@"control-panel"] size:10 isLit:NO];
            SCNNode *parent = [self.rootNode childNodeWithName:@"window" recursively:YES];
            
            //name, place, hide and add to the scene
            node.name = @"panel";
            node.renderingOrder = 11;
            node.position = SCNVector3Make(3.5, -0.5, 1.5);
            node.scale = SCNVector3Make(0.75, 0.75, 0.75);
            node.opacity = 0.0;
            [parent addChildNode:node];
            
            //reveal
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            
            node.opacity = 1.0;
            node.scale = SCNVector3Make(1, 1, 1);
            
            [SCNTransaction commit];
        }
            break;
        case 5:
        {
            //show the statistics details
            SCNNode* node = [SCNNode asc_planeNodeWithImage:[NSImage imageNamed:@"statistics-detail"] size:9 isLit:NO];
            SCNNode *parent = [self.rootNode childNodeWithName:@"window" recursively:YES];
            SCNNode *old1 = [self.rootNode childNodeWithName:@"button" recursively:YES];
            SCNNode *old2 = [self.rootNode childNodeWithName:@"panel" recursively:YES];
            
            //name, place, hide and add to the scene
            node.renderingOrder = 11;
            node.position = SCNVector3Make(5, -2.75, 1.5);
            node.scale = SCNVector3Make(0.75, 0.75, 0.75);
            node.opacity = 0.0;
            [parent addChildNode:node];
            
            //hide debug panel and show the statistics details
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            
            node.opacity = 1.0;
            node.scale = SCNVector3Make(1, 1, 1);
            
            old1.opacity = 0.0;
            old2.opacity = 0.0;
            [SCNTransaction commit];
        }
    }
}

@end
