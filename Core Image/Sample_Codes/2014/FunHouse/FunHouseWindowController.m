/*
     File: FunHouseWindowController.m
 Abstract: n/a
  Version: 2.1
 
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

#import "FunHouseWindowController.h"
#import "CoreImageView.h"
#import "EffectStackController.h"
#import "FunHouseDocument.h"
#import "EffectStack.h"
#import <ApplicationServices/ApplicationServices.h>
#import <Carbon/Carbon.h>

// this is a subclass of NSWindowController

@implementation FunHouseWindowController

// standard window init
- (id)init
{
    self = [super initWithWindowNibName:@"FunHouseWindow"];
    return self;
}

- (void)setUpCoreImageView
{
    [coreImageView setNeedsDisplay:YES];
}

// this is an official init procedure for full screen windwo use
- (id)initFullScreen
{
    NSWindow *w;
    NSRect frame;
    
    // set up the system to hide the menu bar and dock
    [[NSApplication sharedApplication] setPresentationOptions:NSApplicationPresentationAutoHideMenuBar|NSApplicationPresentationAutoHideDock];
    // get the frame of the screen
    frame = [[NSScreen mainScreen] frame];
    // create a new borderless window the size of the entire screen
    w = [[NSWindow alloc] initWithContentRect:frame
      styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];
    // put it up front
    [w makeKeyAndOrderFront:self];
    // and initialize with this window
    self = [super initWithWindow:w];
    return self;
}

- (void)prepFullScreenWindow
{
    NSWindow *w;
    
    w = [self window];
    // create a new core image view (the size of the entire content view) for the full screen window
    coreImageView = [[[CoreImageView alloc] initWithFrame:[[w contentView] bounds]] autorelease];
    // tie us in as its controller
    [coreImageView setFunHouseWindowController:self];
    [self setUpCoreImageView];
    // add the core image view as a subview of the content view
    [[w contentView] addSubview:coreImageView];
    // force an initialization of the core image view
    [coreImageView awakeFromNib];
    // and make the view the first responder (for mouseEntered and mouseExited events...)
    [w makeFirstResponder:coreImageView];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // Balance the -setFunHouseWindowController: that our -windowDidLoad does.
    [coreImageView setFunHouseWindowController:nil];
    [super dealloc];
}

// this gets called when a typical window is loaded from the FunHouseWindow.nib file
- (void)windowDidLoad
{
    CGFloat xwiden, ywiden, xscale, yscale, scale, width, height;
    CIImage *im;
    CGSize imagesize;
    NSSize screensize;
    NSRect R;
    
    [super windowDidLoad];
    // set up a backpointer from the core image view to us
    [coreImageView setFunHouseWindowController:self];
    [self setUpCoreImageView];
    // this is required for mouseEntered and mouseExited events
    [[self window] makeFirstResponder:coreImageView];
    if ([fhdoc hasWindowDimensions])
    {
        width = [fhdoc windowWidth];
        height = [fhdoc windowHeight];
        scale = 1.0;
        [[self window] setContentSize:NSMakeSize(width, height)];
        // set up view transform using scale
        [coreImageView setViewTransformScale:scale];
        [coreImageView setViewTransformOffsetX:0.0 andY:0.0];
        return;
    }
    // resize window to match file size
    im = [[fhdoc effectStack] baseImage];
    if (im != nil)
    {
        imagesize = [im extent].size;
        // if the image is too large to fit on screen in a document window, we must apply a view transform
        screensize = [[NSScreen mainScreen] frame].size;
        R = [NSWindow frameRectForContentRect:NSMakeRect(0, 0, 100, 100) styleMask:NSTitledWindowMask];
        xwiden = R.size.width - 100 - R.origin.x;
        ywiden = R.size.height - 100 - R.origin.y;
        screensize.width -= xwiden;
        screensize.height -= ywiden;
        if (imagesize.width > screensize.width || imagesize.height > screensize.height)
        {
            // compute scale needed
            xscale = screensize.width / imagesize.width;
            yscale = screensize.height / imagesize.height;
            scale = (yscale < xscale) ? yscale : xscale;
            imagesize.width *= scale;
            imagesize.height *= scale;
            imagesize.width = ceil(imagesize.width);
            imagesize.height = ceil(imagesize.height);
        }
        else
            scale = 1.0;
        [[self window] setContentSize:NSMakeSize(imagesize.width, imagesize.height)];
        // set up view transform using scale
        [coreImageView setViewTransformScale:scale];
        [coreImageView setViewTransformOffsetX:0.0 andY:0.0];
    }
}

// set up a document backpointer
- (void)setDocument:(NSDocument *)document
{
    [super setDocument:document];
    fhdoc = (FunHouseDocument *)document;
    [self setUpCoreImageView];
}

// we return a pointer to the core image view buried in our owned window view structure
- (CoreImageView *)coreImageView
{
    return coreImageView;
}

// required for implementing undo
- (NSUndoManager *)windowWillReturnUndoManager
{
    return [[self document] undoManager];
}

- (void)configureToSize:(NSSize)size andFilename:(NSString *)filename
{
    NSRect frame, frame2;
    
    frame = [[self window] frameRectForContentRect:NSMakeRect(0.0, 0.0, size.width, size.height)];
    frame2 = [[self window] frame];
    frame.origin.x = frame2.origin.x;
    frame.origin.y = frame2.origin.y + frame2.size.height - frame.size.height;
    [[self window] setFrame:frame display:YES];
}
@end
