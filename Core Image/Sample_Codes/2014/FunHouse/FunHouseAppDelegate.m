/*
     File: FunHouseAppDelegate.m
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

#import "FunHouseAppDelegate.h"
#import "EffectStackController.h"

@implementation FunHouseAppDelegate

+ (void)setupDefaults
{
    NSDictionary *userDefaultsValuesDict;
 
    userDefaultsValuesDict=[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"useSoftwareRenderer"];
 
    // set them in the standard user defaults
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsValuesDict];
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
	[FunHouseAppDelegate setupDefaults];
}

// application delegates implement this to accomplish tasks right after the application launches
// in this case, I copy the example images from the application package to the ~/Library/Application Support/Core Image Fun House/Example Images folder
// we also automatically open a file on launch if we're not already opening one (by drag or double-click)
- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    BOOL isDir;
    NSInteger i, count;
    NSError *err;
    NSOpenPanel *op;
    NSString *path, *path2, *source, *file, *sourcefile, *destfile;
    NSBundle *bundle;
    NSFileManager *manager;
    NSArray *files;
    
    // "Start Dictation..." and "Special Characters..." are not relevant to this application
    // remove these automatically-added entries from the Edit menu
    NSMenu* edit = [[[[NSApplication sharedApplication] mainMenu] itemWithTitle: @"Edit"] submenu];
    if ([[edit itemAtIndex: [edit numberOfItems] - 1] action] == NSSelectorFromString(@"orderFrontCharacterPalette:"))
        [edit removeItemAtIndex: [edit numberOfItems] - 1];
    if ([[edit itemAtIndex: [edit numberOfItems] - 1] action] == NSSelectorFromString(@"startDictation:"))
        [edit removeItemAtIndex: [edit numberOfItems] - 1];
    if ([[edit itemAtIndex: [edit numberOfItems] - 1] isSeparatorItem])
        [edit removeItemAtIndex: [edit numberOfItems] - 1];
    
    [self showEffectStackAction:self];
    // decide if images have yet been copied to ~/Library/Application Support/Core Image Fun House/Example Images
    path = @"~/Library/Application Support/Core Image Fun House";
    path = [path stringByExpandingTildeInPath];
    path2 = [path stringByAppendingString:@"/Example Images Folder"];
    manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path isDirectory:&isDir])
    {
        // otherwise we need to create the ~/Library/Application Support/Core Image Fun House folder
        [manager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&err];
        [manager createDirectoryAtPath:path2 withIntermediateDirectories:NO attributes:nil error:&err];
        bundle = [NSBundle bundleForClass:[self class]];
        source = [[bundle resourcePath] stringByAppendingString:@"/Images"];
        // and copy the files
        files = [manager contentsOfDirectoryAtPath:source error:&err];
        count = [files count];
        for (i = 0; i < count; i++)
        {
            file = [files objectAtIndex:i];
            sourcefile = [[source stringByAppendingString:@"/"] stringByAppendingString:file];
            destfile = [[path2 stringByAppendingString:@"/"] stringByAppendingString:file];
            [manager copyItemAtPath:sourcefile toPath:destfile error:&err];
        }
    }
    // only automatically open a file if none has already been opened
    if ([[[NSDocumentController sharedDocumentController] documents] count] == 0)
    {
        // open a file at launch from the ~/Library/Application Support/Core Image Fun House/Example Images folder
        op = [NSOpenPanel openPanel];
        [op setAllowsMultipleSelection:NO];
        [op setDirectoryURL:[NSURL fileURLWithPath:path2 isDirectory:YES]];
        [op setAllowedFileTypes:[NSArray arrayWithObjects:@"jpeg", @"jpg", @"tiff", @"tif", @"png", @"crw", @"cr2", @"raf", @"mrw", @"nef", @"srf", @"exr", @"funhouse", nil]];
        
        if ([op runModal] == NSOKButton)
            [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[[op URLs] objectAtIndex:0] display:YES error:&err];
    }
}

- (IBAction)showPreferences:(id)sender
{
    if (_preferencesWindowController) {
        [_preferencesWindowController release];
        _preferencesWindowController = nil;
    }
	_preferencesWindowController = [[NSWindowController alloc] initWithWindowNibName:@"Preferences"];
    
	// Make the panel appear in a good default location.
	[[_preferencesWindowController window] center];
    [_preferencesWindowController showWindow:sender];
}

// handle the show effect stack menu item action
- (IBAction)showEffectStackAction:(id)sender
{
    [[EffectStackController sharedEffectStackController] showWindow:sender];
}

// don't open an untitled file at the start
- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
    return NO;
}

// this gets called when gthe application is just ready to quit
- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // close down the effect stack controller so that it's position will be saved in a closed state
    // note: if it's not closed down when the application terminates, then the window will precess
    // down the screen the next time the application is launched
    [[EffectStackController sharedEffectStackController] closeDown];
}

// handle the zoom to full screen menu item action
- (IBAction)zoomToFullScreenAction:(id)sender
{
    [[[NSDocumentController sharedDocumentController] currentDocument] zoomToFullScreenAction:sender];
}

// handle the undo menu item action
- (IBAction)undo:(id)sender
{
    [[[NSDocumentController sharedDocumentController] currentDocument] undo];
}

// handle the redo menu item action
- (IBAction)redo:(id)sender
{
    [[[NSDocumentController sharedDocumentController] currentDocument] redo];
}

// validate (enable/disable) undo and redo menu items
- (BOOL)validateMenuItem:(NSMenuItem *)item
{
    NSUndoManager *um = [[[NSDocumentController sharedDocumentController] currentDocument] undoManager];
    if ([[[item menu] title] isEqualToString:@"Edit"])
    {
        if ([[[item title] substringToIndex:4] isEqualToString:@"Undo"])
        {
            [item setTitle:[um undoMenuItemTitle]];
            return [um canUndo];
        }
        else if ([[[item title] substringToIndex:4] isEqualToString:@"Redo"])
        {
            [item setTitle:[um redoMenuItemTitle]];
            return [um canRedo];
        }
    }
    return YES;
}

@end
