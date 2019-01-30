/*
     File: AVCamPreviewView.m
 Abstract: Code to detect single-tap, double-tap, and triple-tap to the screen and record the location of the actual touch which is then passed along to the view controller code for further processing.
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
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */

#import "AVCamPreviewView.h"

@interface AVCamPreviewView ()
- (void)handleSingleTap:(id)tapPointValue;
- (void)handleDoubleTap:(id)tapPointValue;
- (void)handleTripleTap;
@end


@implementation AVCamPreviewView

@synthesize delegate = _delegate;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([touches count] == 1) {
        UITouch *touch = [touches anyObject];
        CGPoint tapPoint = [touch locationInView:self];
        if ([touch tapCount] == 1) {
            [self performSelector:@selector(handleSingleTap:) withObject:[NSValue valueWithCGPoint:tapPoint] afterDelay:0.3];
        } else if ([touch tapCount] == 2) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            [self performSelector:@selector(handleDoubleTap:) withObject:[NSValue valueWithCGPoint:tapPoint] afterDelay:0.3];
        } else if ([touch tapCount] == 3) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            [self handleTripleTap];
        }
    }
}

- (void)handleSingleTap:(id)tapPointValue
{
    id delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(tapToFocus:)]) {
        [delegate tapToFocus:[tapPointValue CGPointValue]];
    }    
}

- (void)handleDoubleTap:(id)tapPointValue
{
    id delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(tapToExpose:)]) {
        [delegate tapToExpose:[tapPointValue CGPointValue]];
    }    
}

- (void)handleTripleTap
{
    id delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(resetFocusAndExpose)]) {
        [delegate resetFocusAndExpose];
    }    
}

@end
