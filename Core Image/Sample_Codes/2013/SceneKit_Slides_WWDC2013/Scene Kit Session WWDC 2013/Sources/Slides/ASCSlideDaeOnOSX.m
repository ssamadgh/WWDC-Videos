/*
     File: ASCSlideDaeOnOSX.m
 Abstract: Presents how dae files are supported on OS X.
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

@interface ASCSlideDaeOnOSX : ASCSlide
@end

@implementation ASCSlideDaeOnOSX

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentationViewController {
    // Slide's title and subtitle
    self.textManager.title = @"Working with DAE Files";
    self.textManager.subtitle = @"DAE Files on OS X";
    
    // DAE icon
    SCNNode *daeIconNode = [SCNNode asc_planeNodeWithImageNamed:@"dae file icon" size:5 isLit:NO];
    daeIconNode.position = SCNVector3Make(0, 2.3, 0);
    [self.groundNode addChildNode:daeIconNode];

    // Preview icon and text
    SCNNode *previewIconNode = [SCNNode asc_planeNodeWithImage:[NSImage asc_imageForApplicationNamed:@"Preview"] size:3 isLit:NO];
    previewIconNode.position = SCNVector3Make(-5, 1.3, 11);
    [self.groundNode addChildNode:previewIconNode];
    
    SCNNode *previewTextNode = [SCNNode asc_labelNodeWithString:@"Preview" size:ASCLabelSizeSmall isLit:NO];
    previewTextNode.position = SCNVector3Make(-5.5, 0, 13);
    [self.groundNode addChildNode:previewTextNode];
    
    // Quicklook icon and text
    SCNNode *qlIconNode = [SCNNode asc_planeNodeWithImage:[NSImage asc_imageForApplicationNamed:@"Finder"] size:3 isLit:NO];
    qlIconNode.position = SCNVector3Make(0, 1.3, 11);
    [self.groundNode addChildNode:qlIconNode];
    
    SCNNode *qlTextNode = [SCNNode asc_labelNodeWithString:@"QuickLook" size:ASCLabelSizeSmall isLit:NO];
    qlTextNode.position = SCNVector3Make(-1.11, 0, 13);
    [self.groundNode addChildNode:qlTextNode];

    // Xcode icon and text
    SCNNode *xcodeIconNode = [SCNNode asc_planeNodeWithImage:[NSImage asc_imageForApplicationNamed:@"Xcode"] size:3 isLit:NO];
    xcodeIconNode.position = SCNVector3Make(5, 1.3, 11);
    [self.groundNode addChildNode:xcodeIconNode];
    
    SCNNode *xcodeTextNode = [SCNNode asc_labelNodeWithString:@"Xcode" size:ASCLabelSizeSmall isLit:NO];
    xcodeTextNode.position = SCNVector3Make(3.8, 0, 13);
    [self.groundNode addChildNode:xcodeTextNode];
}

@end
