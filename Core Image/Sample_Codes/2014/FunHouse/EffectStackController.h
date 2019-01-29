/*
     File: EffectStackController.h
 Abstract: This class controls the automatically resizeable effect stack inspector. It must also be able to resize and reconfigure itself when switching documents.
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

#import <AppKit/AppKit.h>

@class CoreImageView;
@class EffectStack;
@class FilterView;
@class CIFilter;

@interface EffectStackController : NSWindowController
{
    IBOutlet NSButton *topPlusButton;           // the plus button at the top of the effect stack inspector (outside of any layer box)
    IBOutlet NSButton *resetButton;             // the reset button at the top of the effect stack inspector (outside of any layer box)
    IBOutlet NSButton *playButton;              // the play button at the top of the effect stack inspector (outside of any layer box)
    CoreImageView *_inspectingCoreImageView;    // pointer to the core image view that is currently associated with the effect stack inspector
    EffectStack *_inspectingEffectStack;        // pointer to the effect stack that is currently associated with the effect stack inspector
    BOOL needsUpdate;                           // set this to re-layout the effect stack inspector on update
    NSMutableArray *boxes;                      // an array of FilterView (subclass of NSBox) that make up the effect stack inspector's UI
    
    // filter palette stuff
    IBOutlet NSWindow *filterPalette;           // the filter palette (called image units)
    IBOutlet NSButton *filterOKButton;          // the apply button, actually
    IBOutlet NSButton *filterCancelButton;      // the cancel button
    IBOutlet NSTableView *categoryTableView;    // the category table view
    IBOutlet NSTableView *filterTableView;      // the filter list table view
    IBOutlet NSButton *filterTextButton;        // the text button
    NSMutableArray *filterPaletteTopLevelObjects;     // an array of the top level objects in the filter palette nib
    
    NSInteger currentCategory;                        // the currently selected row in the category table view
    NSInteger currentFilterRow;                       // the currently selected row in the filter table view
    NSMutableDictionary *categories;            // a dictionary containing all filter category names and the filters that populate the category
    NSString *filterClassname;                  // returned filter's classname from the modal filter palette (when a filter has been selected)
    NSTimer *timer;                             /// playing all transitions
    // globals used in the sequential animation of all transitions
    double transitionStartTime;
    double transitionDuration;
    double transitionEndTime;
}

+ (id)sharedEffectStackController;

- (void)setAutomaticDefaults:(CIFilter *)f atIndex:(NSInteger)index;
- (IBAction)topPlusButtonAction:(id)sender;
- (IBAction)plusButtonAction:(id)sender;
- (IBAction)minusButtonAction:(id)sender;
- (IBAction)resetButtonAction:(id)sender;
- (void)playButtonAction:sender;
- (void)layoutInspector;
- (FilterView *)newUIForFilter:(CIFilter *)f index:(NSInteger)index;
- (FilterView *)newUIForImage:(CIImage *)im filename:(NSString *)filename index:(NSInteger)index;
- (FilterView *)newUIForText:(NSString *)string index:(NSInteger)index;
- (void)_loadFilterListIntoInspector;

- (IBAction)filterOKButtonAction:(id)sender;
- (IBAction)filterCancelButtonAction:(id)sender;
- (IBAction)filterImageButtonAction:(id)sender;
- (IBAction)filterTextButtonAction:(id)sender;
- (IBAction)tableViewDoubleClick:(id)sender;
- (void)setNeedsUpdate:(BOOL)b;
- (void)updateLayout;
- (BOOL)effectStackFilterHasMissingImage:(CIFilter *)f;
- (void)closeDown;
- (void)setLayer:(NSInteger)index image:(CIImage *)im andFilename:(NSString *)filename;
- (void)setChanges;
- (void)setCoreImageView:(CoreImageView *)v;
- (void)removeFilterImageOrTextAtIndex:(NSNumber *)index;
- (void)reconfigureWindow; // called when dragging into or choosing base image to reconfigure the document's window

// for retaining full file names of images
- (void)registerImageLayer:(NSInteger)index imageFilePath:(NSString *)path;
- (void)registerFilterLayer:(CIFilter *)filter key:(NSString *)key imageFilePath:(NSString *)path;
- (NSString *)imageFilePathForImageLayer:(NSInteger)index;
- (NSString *)imageFilePathForFilterLayer:(CIFilter *)filter key:(NSString *)key;
@end

@interface EffectStackBox : NSBox
{
    CIFilter *filter;
    EffectStackController *master;
}

- (void)drawRect:(NSRect)r;
- (void)setFilter:(CIFilter *)f;
- (void)setMaster:(EffectStackController *)m;
@end
