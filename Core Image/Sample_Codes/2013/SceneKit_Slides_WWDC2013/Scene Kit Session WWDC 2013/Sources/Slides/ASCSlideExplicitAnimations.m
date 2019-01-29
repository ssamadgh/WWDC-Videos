/*
     File: ASCSlideExplicitAnimations.m
 Abstract: Explains how explicit animations work and shows an example.
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

@interface ASCSlideExplicitAnimations : ASCSlide
@end

@implementation ASCSlideExplicitAnimations {
    SCNNode *_animatedNode;
}

- (NSUInteger)numberOfSteps {
    return 5;
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentationViewController {
    // Set the slide's title and subtitle and add some code
    self.textManager.title = @"Animations";
    self.textManager.subtitle = @"Explicit animations";
    
    [self.textManager addCode:
     @"// Create an animation \n"
     @"animation = [#CABasicAnimation# animationWithKeyPath:@\"rotation\"]; \n\n"
     @"// Configure the animation \n"
     @"animation.#duration# = 2.0; \n"
     @"animation.#toValue# = [NSValue valueWithSCNVector4:SCNVector4Make(0,1,0,M_PI*2)]; \n"
     @"animation.#repeatCount# = FLT_MAX; \n\n"
     @"// Play the animation \n"
     @"[aNode #addAnimation:#animation #forKey:#@\"myAnimation\"];"];
    
    // A simple torus that we will animate to illustrate the code
    _animatedNode = [SCNNode node];
    _animatedNode.position = SCNVector3Make(9, 5.7, 16);
    
    // Use an extra node that we can tilt it and cumulate that with the animation
    SCNNode *torusNode = [SCNNode node];
    torusNode.geometry = [SCNTorus torusWithRingRadius:4.0 pipeRadius:1.5];
    torusNode.rotation = SCNVector4Make(1, 0, 0, -M_PI * 0.5);
    torusNode.geometry.firstMaterial.diffuse.contents = [NSColor cyanColor];
    torusNode.geometry.firstMaterial.specular.contents = [NSColor whiteColor];
    torusNode.geometry.firstMaterial.reflective.contents = [NSImage imageNamed:@"envmap"];
    torusNode.geometry.firstMaterial.fresnelExponent = 0.7;
    
    [_animatedNode addChildNode:torusNode];
    [self.contentNode addChildNode:_animatedNode];
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    // Animate by default
    [SCNTransaction begin];
    
    switch (index) {
        case 0:
            // Disable animations for first step
            [SCNTransaction setAnimationDuration:0];
            
            // Initially hide the torus
            _animatedNode.opacity = 0.0;
            
            [self.textManager highlightCodeChunks:nil];
            break;
        case 1:
            [self.textManager highlightCodeChunks:@[@0]];
            break;
        case 2:
            [self.textManager highlightCodeChunks:@[@1, @2, @3]];
            break;
        case 3:
            [self.textManager highlightCodeChunks:@[@4, @5]];
            break;
        case 4:
        {
            [SCNTransaction setAnimationDuration:0];
            
            // Show the torus
            _animatedNode.opacity = 1.0;
            
            // Animate explicitly
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
            animation.duration = 2.0;
            animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
            animation.repeatCount = FLT_MAX;
            [_animatedNode addAnimation:animation forKey:@"myAnimation"];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                // Dim the text
                self.textManager.textNode.opacity = 0.75;
                
                presentationViewController.cameraHandle.position = [presentationViewController.cameraHandle convertPosition:SCNVector3Make(9, 8, 15) toNode:presentationViewController.cameraHandle.parentNode];
                presentationViewController.cameraPitch.rotation = SCNVector4Make(1, 0, 0, -M_PI / 10);
            }
            [SCNTransaction commit];
            break;
        }
    }
    
    [SCNTransaction commit];
}

@end
