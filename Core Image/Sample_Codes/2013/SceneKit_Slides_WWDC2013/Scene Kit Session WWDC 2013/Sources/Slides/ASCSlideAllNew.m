/*
     File: ASCSlideAllNew.m
 Abstract: This slide displays a word cloud introducing the new features added to Scene Kit.
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

@interface ASCSlideAllNew : ASCSlide
@end

@implementation ASCSlideAllNew {
    NSArray *_materials;
    NSFont  *_font;
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentationViewController {
    // Create the font and the materials that will be shared among the features in the word cloud
    _font = [NSFont fontWithName:@"Myriad Set BoldItalic" size:50] ?: [NSFont fontWithName:@"Avenir Heavy Oblique" size:50];
    
    SCNMaterial *frontAndBackMaterial = [SCNMaterial material];
    SCNMaterial *sideMaterial = [SCNMaterial material];
    sideMaterial.diffuse.contents = [NSColor darkGrayColor];
    
    _materials = @[frontAndBackMaterial, sideMaterial, frontAndBackMaterial];
    
    // Add different features to the word cloud
    [self placeFeature:@"Export to DAE" atPoint:NSMakePoint(10,-8) timeOffset:0];
    [self placeFeature:@"OpenGL Core Profile" atPoint:NSMakePoint(-16,-7) timeOffset:0.05];
    [self placeFeature:@"Warmup" atPoint:NSMakePoint(-12,-10) timeOffset:0.1];
    [self placeFeature:@"Constraints" atPoint:NSMakePoint(-10,6) timeOffset:0.15];
    [self placeFeature:@"Custom projection" atPoint:NSMakePoint(4,9) timeOffset:0.2];
    [self placeFeature:@"Skinning" atPoint:NSMakePoint(-4,8) timeOffset:0.25];
    [self placeFeature:@"Morphing" atPoint:NSMakePoint(-3,-8) timeOffset:0.3];
    [self placeFeature:@"Performance Statistics" atPoint:NSMakePoint(-1,6) timeOffset:0.35];
    [self placeFeature:@"CIFilters" atPoint:NSMakePoint(1,5) timeOffset:0.85];
    [self placeFeature:@"GLKit Math" atPoint:NSMakePoint(3,-10) timeOffset:0.45];
    [self placeFeature:@"Depth of Field" atPoint:NSMakePoint(-0.5,0) timeOffset:0.47];
    [self placeFeature:@"Animation Events" atPoint:NSMakePoint(5,3) timeOffset:0.50];
    [self placeFeature:@"Shader Modifiers" atPoint:NSMakePoint(7,2) timeOffset:0.95];
    [self placeFeature:@"GOBO" atPoint:NSMakePoint(-10,1) timeOffset:0.60];
    [self placeFeature:@"Ray testing" atPoint:NSMakePoint(-8,0) timeOffset:0.65];
    [self placeFeature:@"Skybox" atPoint:NSMakePoint(8,-1) timeOffset:0.7];
    [self placeFeature:@"Fresnel" atPoint:NSMakePoint(6,-2) timeOffset:0.75];
    [self placeFeature:@"SCNShape" atPoint:NSMakePoint(-6,-3) timeOffset:0.8];
    [self placeFeature:@"Levels of detail" atPoint:NSMakePoint(-11,3) timeOffset:0.9];
    [self placeFeature:@"Animation blending" atPoint:NSMakePoint(-2,-5) timeOffset:1];
}

- (void)placeFeature:(NSString *)string atPoint:(NSPoint)p timeOffset:(CGFloat)offset {
    // Create and configure a node with a text geometry, and add it to the scene
    SCNText *text = [SCNText textWithString:string extrusionDepth:5];
    text.font = _font;
    text.flatness = 0.4;
    text.materials = _materials;
    
    SCNNode *textNode = [SCNNode node];
    textNode.geometry = text;
    textNode.position = SCNVector3Make(p.x, p.y + self.altitude, 0);
    textNode.scale = SCNVector3Make(0.02, 0.02, 0.02);
    
    [self.contentNode addChildNode:textNode];
    
    // Animation the node's position and opacity
    CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position.z"];
    positionAnimation.fromValue = @(-10);
    positionAnimation.toValue = @10;
    positionAnimation.duration = 5.0;
    positionAnimation.timeOffset = -offset * positionAnimation.duration;
    positionAnimation.repeatCount = FLT_MAX;
    [textNode addAnimation:positionAnimation forKey:nil];
    
    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.keyTimes = @[@0.0, @0.2, @0.9, @1.0];
    opacityAnimation.values = @[@0.0, @1.0, @1.0, @0.0];
    opacityAnimation.duration = positionAnimation.duration;
    opacityAnimation.timeOffset = positionAnimation.timeOffset;
    opacityAnimation.repeatCount = FLT_MAX;
    [textNode addAnimation:opacityAnimation forKey:nil];
}

@end
