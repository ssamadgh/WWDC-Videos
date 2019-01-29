/*
     File: ASCSlideEditor.m
 Abstract: Presents the Xcode Scene Kit editor.
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

@interface ASCSlideEditor : ASCSlide
@end

@implementation ASCSlideEditor

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentationViewController {
    // Set the slide's title and add some text
    self.textManager.title = @"Scene Kit Editor";
    [self.textManager addBullet:@"Built into Xcode" atLevel:0];
    [self.textManager addBullet:@"Scene information" atLevel:0];
    [self.textManager addBullet:@"Preview final rendering" atLevel:0];
    [self.textManager addBullet:@"Scene graph inspection" atLevel:0];
    [self.textManager addBullet:@"Adjust lighting and materials" atLevel:0];
    [self.textManager addBullet:@"Preview animations and performance" atLevel:0];
}

- (void)didOrderInWithPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    // Bring up a screenshot of the editor
    SCNNode *editorScreenshotNode = [SCNNode asc_planeNodeWithImageNamed:@"editor" size:14 isLit:YES];
    editorScreenshotNode.position = SCNVector3Make(17, 4.1, 5);
    editorScreenshotNode.rotation = SCNVector4Make(0, 1, 0, -M_PI / 1.5);
    [self.groundNode addChildNode:editorScreenshotNode];
    
    // Animate it (rotate and move)
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.0];
    {
        editorScreenshotNode.position = SCNVector3Make(7.5, 4.1, 5);
        editorScreenshotNode.rotation = SCNVector4Make(0, 1, 0, -M_PI / 6.0);
    }
    [SCNTransaction commit];
}

@end
