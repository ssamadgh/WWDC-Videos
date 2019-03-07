/*
     File: ASCSlideLabs.m
 Abstract:  Labs info slide. 
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

@interface ASCSlideLabs : ASCSlide
@end

@implementation ASCSlideLabs

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentation {
    //retrieve the text manager and add a title
    ASCSlideTextManager *textManager = [self textManager];
    [textManager setTitle:@"Labs"];
    
#define SHAPE_RADIUS 0
#define SHAPE_Z 10
#define SHAPE_Y 30.7
#define SHAPE_Y_2 29.2
#define SCALE 0.75

    // Lab 1
    {
        //create a titled box for the title of the lab
        SCNNode *box = [SCNNode asc_boxNodeWithTitle:@"Scene Kit Lab" frame:NSMakeRect(0, 0, 750, 70) color:[NSColor colorWithCalibratedWhite:0.15 alpha:1.0] cornerRadius:SHAPE_RADIUS centered:NO];
        box.name = @"lab1-box1";
        
        //scale and place it
        box.scale = SCNVector3Make(0.02, 0.02, 0.02);
        
        //set the pivot to the center of the box
        box.pivot = CATransform3DMakeTranslation(375, 35, 5);
        box.position = SCNVector3Make(-2.8, SHAPE_Y, SHAPE_Z);
        box.rotation = SCNVector4Make(1, 0, 0, M_PI);
        
        //hide
        box.opacity = 0.0;
        
        //add to the sene
        [self.rootNode addChildNode:box];
        
        //create a titled box for the location and time
        box = [SCNNode asc_boxNodeWithTitle:@"\nGraphics and Games Lab A\nTuesday 4:00PM" frame:NSMakeRect(0, 0, 220/SCALE, 70/SCALE) color:[NSColor colorWithDeviceRed:31.0/255 green:31.0/255 blue:31.0/255 alpha:1] cornerRadius:SHAPE_RADIUS centered:NO];
        box.name = @"lab1-box2";
        
        //color tag for "graphics" sessions
        SCNNode *colorBox = [SCNNode asc_boxNodeWithTitle:nil frame:NSMakeRect(220/SCALE, 0, 30/SCALE, 70/SCALE) color:[NSColor colorWithDeviceRed:1 green:214.0/255 blue:37.0/255 alpha:1] cornerRadius:SHAPE_RADIUS centered:NO];
        colorBox.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
        [box addChildNode:colorBox];
        
        //scale and place it
        box.scale = SCNVector3Make(0.02*SCALE, 0.02*SCALE, 0.02*SCALE);
        
        //set the pivot to the center of the box
        box.pivot = CATransform3DMakeTranslation(109/SCALE, 35/SCALE, 5);
        box.position = SCNVector3Make(6.9, SHAPE_Y, SHAPE_Z);
        box.rotation = SCNVector4Make(0, 1, 0, M_PI);
        
        //hide
        box.opacity = 0.0;
        
        //add to the scene
        [self.rootNode addChildNode:box];
    }
    
    // Lab 2
    {
        //create a titled box for the title of the lab
        SCNNode *box = [SCNNode asc_boxNodeWithTitle:@"Scene Kit Lab" frame:NSMakeRect(0, 0, 750, 70) color:[NSColor colorWithCalibratedWhite:0.15 alpha:1.0] cornerRadius:SHAPE_RADIUS centered:NO];
        box.name = @"lab2-box1";
        
        //scale and place it
        box.scale = SCNVector3Make(0.02, 0.02, 0.02);
        
        //set the pivot to the center of the box
        box.pivot = CATransform3DMakeTranslation(375, 35, 5);
        box.position = SCNVector3Make(-2.8, SHAPE_Y_2, SHAPE_Z);
        box.rotation = SCNVector4Make(1, 0, 0, M_PI);
        
        //hide
        box.opacity = 0.0;
        
        //add to the sene
        [self.rootNode addChildNode:box];
        
        //create a titled box for the location and time
        box = [SCNNode asc_boxNodeWithTitle:@"\nGraphics and Games Lab A\nTWednesday 9:00AM" frame:NSMakeRect(0, 0, 220/SCALE, 70/SCALE) color:[NSColor colorWithDeviceRed:31.0/255 green:31.0/255 blue:31.0/255 alpha:1] cornerRadius:SHAPE_RADIUS centered:NO];
        box.name = @"lab2-box2";
        
        //color tag for "graphics" sessions
        SCNNode *colorBox = [SCNNode asc_boxNodeWithTitle:nil frame:NSMakeRect(220/SCALE, 0, 30/SCALE, 70/SCALE) color:[NSColor colorWithDeviceRed:1 green:214.0/255 blue:37.0/255 alpha:1] cornerRadius:SHAPE_RADIUS centered:NO];
        colorBox.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
        [box addChildNode:colorBox];
        
        //scale and place it
        box.scale = SCNVector3Make(0.02*SCALE, 0.02*SCALE, 0.02*SCALE);
        
        //set the pivot to the center of the box
        box.pivot = CATransform3DMakeTranslation(109/SCALE, 35/SCALE, 5);
        box.position = SCNVector3Make(6.9, SHAPE_Y_2, SHAPE_Z);
        box.rotation = SCNVector4Make(0, 1, 0, M_PI);
        
        //hide
        box.opacity = 0.0;
        
        //add to the scene
        [self.rootNode addChildNode:box];
    }
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)controller {
    //after some delay rotate and fade in the lab information
    double delayInSeconds = 0.75;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:1.0];
        
        SCNNode *box = [self.rootNode childNodeWithName:@"lab1-box1" recursively:YES];
        box.opacity = 1.0;
        box.rotation = SCNVector4Make(1, 0, 0, 0);
        
        box = [self.rootNode childNodeWithName:@"lab1-box2" recursively:YES];
        box.opacity = 1.0;
        box.rotation = SCNVector4Make(0, 1, 0, 0);
        
        box = [self.rootNode childNodeWithName:@"lab2-box1" recursively:YES];

        
        box.opacity = 1.0;
        box.rotation = SCNVector4Make(1, 0, 0, 0);
        
        box = [self.rootNode childNodeWithName:@"lab2-box2" recursively:YES];

        box.opacity = 1.0;
        box.rotation = SCNVector4Make(0, 1, 0, 0);
        
        [SCNTransaction commit];
    });
}

@end
