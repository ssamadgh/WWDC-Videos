/*
     File: ASCSlideArchitecture.m
 Abstract: Architecture slide. Presents where Scene Kit stands among the different graphic technologies.
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

@interface ASCSlideArchitecture : ASCSlide
@end

@implementation ASCSlideArchitecture

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentationViewController {
    // Add text
    self.textManager.title = @"Scene Kit";
   
    [self.textManager addBullet:@"High level Objective-C API" atLevel:0];
    [self.textManager addBullet:@"Scene graph" atLevel:0];
    
    // Build the Cocoa graphics stack
    NSColor *redColor    = [NSColor colorWithDeviceRed:168 / 255.0 green:21 / 255.0 blue:1 / 255.0 alpha:1];
    NSColor *grayColor   = [NSColor grayColor];
    NSColor *greenColor  = [NSColor colorWithDeviceRed:105 / 255.0 green:145.0 / 255.0 blue:14.0 / 255.0 alpha:1];
    NSColor *orangeColor = [NSColor orangeColor];
    NSColor *purpleColor = [NSColor colorWithDeviceRed:152 / 255.0 green:57 / 255.0 blue:189 / 255.0 alpha:1];
    
    [self addBoxWithTitle:@"Cocoa" frame:NSMakeRect(0, 0, 500, 70) level:3 color:grayColor];
    [self addBoxWithTitle:@"Core Image" frame:NSMakeRect(0, 0, 100, 70) level:2 color:greenColor];
    [self addBoxWithTitle:@"Core Animation" frame:NSMakeRect(260, 0, 130, 70) level:2 color:greenColor];
    [self addBoxWithTitle:@"GL Kit" frame:NSMakeRect(395, 0, 105, 70) level:2 color:greenColor];
    [self addBoxWithTitle:@"Scene Kit" frame:NSMakeRect(105, 0, 150, 70) level:2 color:orangeColor];
    [self addBoxWithTitle:@"OpenGL" frame:NSMakeRect(0, 0, 500, 70) level:1 color:purpleColor];
    [self addBoxWithTitle:@"Graphics Hardware" frame:NSMakeRect(0, 0, 500, 70) level:0 color:redColor];
}

- (void)addBoxWithTitle:(NSString *)title frame:(NSRect)frame level:(NSUInteger)level color:(NSColor *)color {
    SCNNode *node = [SCNNode asc_boxNodeWithTitle:title frame:frame color:color cornerRadius:2.0 centered:YES];
    node.scale = SCNVector3Make(0.02, 0.02, 0.02);
    node.position = SCNVector3Make(-5, 1.5 * level, 10.0);
    [self.contentNode addChildNode:node];
}

@end
