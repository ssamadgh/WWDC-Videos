/*
     File: ASCAppDelegate.m
 Abstract: n/a
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

#import "ASCAppDelegate.h"

#import <IOKit/pwr_mgt/IOPMLib.h>

@implementation ASCAppDelegate {
    ASCPresentationViewController *_presentation;
    IOPMAssertionID _assertionID;
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    [self disableDisplaySleeping];
    
    // Create a presentation from a plist file
    _presentation = [[ASCPresentationViewController alloc] initWithContentsOfFile:@"Scene Kit Presentation"];
    _presentation.delegate = self;
    
    // Populate the 'Go' menu for direct access to slides
    [self populateGoMenu];
    
    // Start the presentation
    [self.window.contentView addSubview:_presentation.view];
    _presentation.view.frame = [self.window.contentView bounds];
    _presentation.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
}

#pragma mark -
#pragma mark Presentation delegate

- (void)presentation:(ASCPresentationViewController *)presentation willPresentSlideAtIndex:(NSUInteger)slideIndex step:(NSUInteger)step {
    // Update the window's title depending on the current slide
    if (step == 0) {
        [self.window setTitle:[NSString stringWithFormat:@"SceneKit WWDC 2013 - slide %d", (int)slideIndex]];
    } else {
        [self.window setTitle:[NSString stringWithFormat:@"SceneKit WWDC 2013 - slide %d step %d", (int)slideIndex, (int)step]];
    }
}

#pragma mark -
#pragma mark 'Go' menu

- (void)populateGoMenu {
    for (NSUInteger i = 0; i < [_presentation numberOfSlides]; i++) {
        NSString *slideName = NSStringFromClass([_presentation classOfSlideAtIndex:i]);
        NSString *title = [slideName stringByReplacingCharactersInRange:NSMakeRange(0, 8) withString:[NSString stringWithFormat:@"%lu ", (unsigned long)i]];
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:@selector(goTo:) keyEquivalent:@""];
        item.representedObject = @(i);
        [_goMenu addItem:item];
    }
}

#pragma mark -
#pragma mark Actions

- (IBAction)nextSlide:(id)sender {
    [_presentation goToNextSlideStep];
}

- (IBAction)previousSlide:(id)sender {
    [_presentation goToPreviousSlide];
}

- (IBAction)goTo:(NSMenuItem *)sender {
    NSInteger index = [[sender representedObject] integerValue];
    [_presentation goToSlideAtIndex:index];
}

- (IBAction)toggleCursor:(id)sender {
    static BOOL hidden = NO;
    if (hidden) {
        [NSCursor unhide];
        hidden = NO;
    } else {
        [NSCursor hide];
        hidden = YES;
    }
}

#pragma mark -
#pragma mark NSApplicationDelegate

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [self enableDisplaySleeping];
}

#pragma mark -
#pragma mark Sleep

- (void)disableDisplaySleeping {
    CFStringRef reasonForActivity = CFSTR("Scene Kit Presentation");
    IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep, kIOPMAssertionLevelOn, reasonForActivity, &_assertionID);
}

- (void)enableDisplaySleeping {
    if (_assertionID)
        IOPMAssertionRelease(_assertionID);
}

@end
