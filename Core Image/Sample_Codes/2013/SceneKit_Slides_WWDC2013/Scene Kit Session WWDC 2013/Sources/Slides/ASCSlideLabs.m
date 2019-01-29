/*
     File: ASCSlideLabs.m
 Abstract: Labs info.
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

@interface ASCSlideLabs : ASCSlide
@end

@implementation ASCSlideLabs

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    // Set the slide's title
    self.textManager.title = @"Labs";
    
    // Add two labs
    SCNNode *lab1TitleNode = [SCNNode asc_boxNodeWithTitle:@"Scene Kit Lab" frame:NSMakeRect(-375, -35, 750, 70) color:[NSColor colorWithCalibratedWhite:0.15 alpha:1.0] cornerRadius:0.0 centered:NO];
    lab1TitleNode.scale = SCNVector3Make(0.02, 0.02, 0.02);
    lab1TitleNode.position = SCNVector3Make(-2.8, 30.7, 10.0);
    lab1TitleNode.rotation = SCNVector4Make(1, 0, 0, M_PI);
    lab1TitleNode.opacity = 0.0;
    
    SCNNode *lab2TitleNode = [lab1TitleNode copy];
    lab2TitleNode.position = SCNVector3Make(-2.8, 29.2, 10.0);
    
    [self.contentNode addChildNode:lab1TitleNode];
    [self.contentNode addChildNode:lab2TitleNode];
    
    SCNNode *lab1InfoNode = [self addLabInfoNodeWithTitle:@"\nGraphics and Games Lab A\nTuesday 4:00PM" atYPosition:30.7];
    SCNNode *lab2InfoNode = [self addLabInfoNodeWithTitle:@"\nGraphics and Games Lab A\nWednesday 9:00AM" atYPosition:29.2];
    
    double delayInSeconds = 0.75;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:1.0];
        {
            lab1TitleNode.opacity = lab2TitleNode.opacity = 1.0;
            lab1TitleNode.rotation = lab2TitleNode.rotation = SCNVector4Make(1, 0, 0, 0);
            
            lab1InfoNode.opacity = lab2InfoNode.opacity = 1.0;
            lab1InfoNode.rotation = lab2InfoNode.rotation = SCNVector4Make(0, 1, 0, 0);
        }
        [SCNTransaction commit];
    });
}

- (SCNNode *)addLabInfoNodeWithTitle:(NSString *)title atYPosition:(CGFloat)yPosition {
    SCNNode *labInfoNode = [SCNNode asc_boxNodeWithTitle:title frame:NSMakeRect(0, 0, 293.33, 93.33) color:[NSColor colorWithDeviceRed:31.0/255 green:31.0/255 blue:31.0/255 alpha:1] cornerRadius:0.0 centered:NO];
    labInfoNode.scale = SCNVector3Make(0.015, 0.015, 0.015);
    labInfoNode.pivot = CATransform3DMakeTranslation(145.33, 46.66, 5);
    labInfoNode.position = SCNVector3Make(6.9, yPosition, 10.0);
    labInfoNode.rotation = SCNVector4Make(0, 1, 0, M_PI);
    labInfoNode.opacity = 0.0;
    
    SCNNode *colorBox = [SCNNode asc_boxNodeWithTitle:nil frame:NSMakeRect(293.33, 0, 40, 93.33) color:[NSColor colorWithDeviceRed:1 green:214.0/255 blue:37.0/255 alpha:1] cornerRadius:0.0 centered:NO];
    colorBox.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    
    [self.contentNode addChildNode:labInfoNode];
    [labInfoNode addChildNode:colorBox];
    
    return labInfoNode;
}

@end
