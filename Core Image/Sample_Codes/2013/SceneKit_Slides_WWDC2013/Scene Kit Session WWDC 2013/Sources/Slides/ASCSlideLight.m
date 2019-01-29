/*
     File: ASCSlideLight.m
 Abstract: Illustrates the light attribute.
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

@interface ASCSlideLight : ASCSlide
@end

@implementation ASCSlideLight {
    SCNNode *_lightNode;
    SCNNode *_lightOffImageNode;
    SCNNode *_lightOnImageNode;
}

- (NSUInteger)numberOfSteps {
    return 3;
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:0.0];
    
    switch (index) {
        case 0:
        {
            // Set the slide's title and subtitle and add some text
            self.textManager.title = @"Node Attributes";
            self.textManager.subtitle = @"Lights";
            
            [self.textManager addBullet:@"SCNLight" atLevel:0];
            [self.textManager addBullet:@"Four light types" atLevel:0];
            [self.textManager addBullet:@"Omni" atLevel:1];
            [self.textManager addBullet:@"Directional" atLevel:1];
            [self.textManager addBullet:@"Spot" atLevel:1];
            [self.textManager addBullet:@"Ambient" atLevel:1];
            break;
        }
        case 1:
        {
            // Add some code
            SCNNode *codeExampleNode = [self.textManager addCode:
                                        @"aNode.#light# = [SCNLight light]; \n"
                                        @"aNode.light.type = SCNLightTypeOmni;"];
            
            codeExampleNode.position = SCNVector3Make(14, 11, 1);
            
            // Add a light to the scene
            _lightNode = [SCNNode node];
            _lightNode.light = [SCNLight light];
            _lightNode.light.type = SCNLightTypeOmni;
            _lightNode.light.color = [NSColor blackColor]; // initially off
            [_lightNode.light setAttribute:@30.0 forKey:SCNLightAttenuationStartKey];
            [_lightNode.light setAttribute:@40.0 forKey:SCNLightAttenuationEndKey];
            _lightNode.position = SCNVector3Make(5, 3.5, 0);
            [self.contentNode addChildNode:_lightNode];
            
            // Load two images to help visualize the light (on and off)
            _lightOffImageNode = [SCNNode asc_planeNodeWithImageNamed:@"light-off" size:7 isLit:NO];
            _lightOnImageNode = [SCNNode asc_planeNodeWithImageNamed:@"light-on" size:7 isLit:NO];
            _lightOnImageNode.opacity = 0;
            
            [_lightNode addChildNode:_lightOnImageNode];
            [_lightNode addChildNode:_lightOffImageNode];
            break;
        }
        case 2:
        {
            // Switch the light on
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                _lightNode.light.color = [NSColor colorWithCalibratedRed:1 green:1 blue:0.8 alpha:1];
                _lightOnImageNode.opacity = 1.0;
                _lightOffImageNode.opacity = 0.0;
            }
            [SCNTransaction commit];
            break;
        }
    }
    [SCNTransaction commit];
}

- (void)willOrderOutWithPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    [SCNTransaction begin];
    {
        // Switch the light off
        _lightNode.light = nil;
    }
    [SCNTransaction commit];
}

@end
