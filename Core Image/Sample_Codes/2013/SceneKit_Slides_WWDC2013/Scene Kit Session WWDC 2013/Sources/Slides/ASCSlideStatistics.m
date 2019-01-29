/*
     File: ASCSlideStatistics.m
 Abstract: Illustrates the new API giving statistics about the scene.
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

@interface ASCSlideStatistics : ASCSlide
@end

@implementation ASCSlideStatistics {
    SCNNode *_fpsNode;
    SCNNode *_panelNode;
    SCNNode *_buttonNode;
    SCNNode *_windowNode;
}

- (NSUInteger)numberOfSteps {
    return 6;
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    switch (index) {
        case 0:
        {
            // Set the slide's title and subtile and add some code
            self.textManager.title = @"Performance";
            self.textManager.subtitle = @"Statistics";
            
            [self.textManager addCode:
             @"// Show statistics \n"
             @"aSCNView.#showsStatistics# = YES;"];
            break;
        }
        case 1:
        {
            // Place a screenshot in the scene and animate it
            _windowNode = [SCNNode asc_planeNodeWithImageNamed:@"statistics" size:20 isLit:YES];
            [self.contentNode addChildNode:_windowNode];
            
            _windowNode.opacity = 0.0;
            _windowNode.position = SCNVector3Make(20, 5.2, 9);
            _windowNode.rotation = SCNVector4Make(0, 1, 0, -M_PI_4);
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                _windowNode.opacity = 1.0;
                _windowNode.position = SCNVector3Make(0, 5.2, 7);
                _windowNode.rotation = SCNVector4Make(0, 1, 0, 0);
            }
            [SCNTransaction commit];
            
            // The screenshot contains transparent areas so we need to make sure it is rendered
            // after the text (which also sets its rendering order)
            _windowNode.renderingOrder = 2;
            
            break;
        }
        case 2:
        {
            _fpsNode = [SCNNode asc_planeNodeWithImageNamed:@"statistics-fps" size:7 isLit:NO];
            [_windowNode addChildNode:_fpsNode];
            
            _fpsNode.scale = SCNVector3Make(0.75, 0.75, 0.75);
            _fpsNode.opacity = 0.0;
            _fpsNode.position = SCNVector3Make(-6, -3, 0.5);
            _fpsNode.renderingOrder = 4;
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            {
                _fpsNode.scale = SCNVector3Make(1.0, 1.0, 1.0);
                _fpsNode.opacity = 1.0;
            }
            [SCNTransaction commit];
            break;
        }
        case 3:
        {
            _buttonNode = [SCNNode asc_planeNodeWithImageNamed:@"statistics-button" size:4 isLit:NO];
            [_windowNode addChildNode:_buttonNode];
            
            _buttonNode.scale = SCNVector3Make(0.75, 0.75, 0.75);
            _buttonNode.opacity = 0.0;
            _buttonNode.position = SCNVector3Make(-7.5, -2.75, 0.5);
            _buttonNode.renderingOrder = 5;

            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            {
                _fpsNode.opacity = 0.0;
                _buttonNode.scale = SCNVector3Make(1.0, 1.0, 1.0);
                _buttonNode.opacity = 1.0;
            }
            [SCNTransaction commit];
            break;
        }
        case 4:
        {
            _panelNode = [SCNNode asc_planeNodeWithImageNamed:@"control-panel" size:10 isLit:NO];
            [_windowNode addChildNode:_panelNode];
            
            _panelNode.scale = SCNVector3Make(0.75, 0.75, 0.75);
            _panelNode.opacity = 0.0;
            _panelNode.position = SCNVector3Make(3.5, -0.5, 1.5);
            _panelNode.renderingOrder = 6;
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            {
                _panelNode.scale = SCNVector3Make(1.0, 1.0, 1.0);
                _panelNode.opacity = 1.0;
            }
            [SCNTransaction commit];
            break;
        }
        case 5:
        {
            SCNNode *detailsNode = [SCNNode asc_planeNodeWithImageNamed:@"statistics-detail" size:9 isLit:NO];
            [_windowNode addChildNode:detailsNode];
            
            detailsNode.scale = SCNVector3Make(0.75, 0.75, 0.75);
            detailsNode.opacity = 0.0;
            detailsNode.position = SCNVector3Make(5, -2.75, 1.5);
            detailsNode.renderingOrder = 7;
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            {
                _panelNode.opacity = 0.0;
                _buttonNode.opacity = 0.0;
                
                detailsNode.scale = SCNVector3Make(1.0, 1.0, 1.0);
                detailsNode.opacity = 1.0;
            }
            [SCNTransaction commit];
            break;
        }
    }
}

@end
