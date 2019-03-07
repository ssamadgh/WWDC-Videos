/*
     File: Document.m
 Abstract: The document class. This setups up the AVPlayer used by the document’s AVPlayerView. It also handles showing/hiding the action menu, trim, export, and chapter navigation actions.
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

#import "Document.h"
#import "ExportProgressWindowController.h"

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <objc/runtime.h>

@interface Document () <ExportProgressWindowControllerDelegate>

@property (weak) IBOutlet AVPlayerView *playerView;
@property AVPlayer *player;

@property AVAssetExportSession *exportSession;
@property ExportProgressWindowController *exportProgressWindowController;

@property NSArray *chapterMetadataGroups;

@end

@implementation Document

- (NSString *)windowNibName
{
	return @"Document";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController
{
	[super windowControllerDidLoadNib:windowController];
	
	// Associate AVPlayer with AVPlayerView once the NIB is loaded
	self.playerView.player = _player;
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	_player = [AVPlayer playerWithURL:absoluteURL];
	
	// Load chapters to be used by the next/previous chapter menu items
	[_player.currentItem.asset loadValuesAsynchronouslyForKeys:@[@"availableChapterLocales"] completionHandler:^{
		self.chapterMetadataGroups = [_player.currentItem.asset chapterMetadataGroupsBestMatchingPreferredLanguages:[NSLocale preferredLanguages]];
	}];
	
	return YES;
}

#pragma mark Trim and Export

- (void)trim:(id)sender
{
	// Show trim controls
	[self.playerView beginTrimmingWithCompletionHandler:NULL];
}

- (IBAction)startExport:(id)sender
{
	// Pause playback before starting the export since the user will not be able to interact with transport controls to pause it themselves once the export has started
	[self.playerView.player pause];
	
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel beginSheetModalForWindow:self.windowForSheet completionHandler:^(NSInteger result) {
		if (result == NSFileHandlingPanelOKButton)
		{
			// Order out the save panel here because the export sheet is about to be shown
			[savePanel orderOut:nil];
			
			AVPlayerItem *playerItem = self.player.currentItem;
			AVAsset *asset = playerItem.asset;
			self.exportSession = [AVAssetExportSession exportSessionWithAsset:asset presetName:[AVAssetExportSession exportPresetsCompatibleWithAsset:asset].firstObject];
			self.exportSession.timeRange = CMTimeRangeFromTimeToTime(playerItem.reversePlaybackEndTime, playerItem.forwardPlaybackEndTime);
			self.exportSession.outputFileType = self.exportSession.supportedFileTypes.firstObject;
			self.exportSession.outputURL = savePanel.URL;
			
			self.exportProgressWindowController = [[ExportProgressWindowController alloc] initWithWindowNibName:@"ExportProgress"];
			self.exportProgressWindowController.exportSession = self.exportSession;
			self.exportProgressWindowController.delegate = self;
			[self.windowForSheet beginSheet:self.exportProgressWindowController.window completionHandler:nil];
			
			[self.exportSession exportAsynchronouslyWithCompletionHandler:^{
				[self.windowForSheet endSheet:self.exportProgressWindowController.window];
				self.exportProgressWindowController = nil;
				self.exportSession = nil;
			}];
		}
	}];
}

- (void)exportProgressWindowControllerDidCancel:(ExportProgressWindowController *)exportProgressWindowController
{
	// Ending the sheet will be handled in the export session completion handler
	[self.exportSession cancelExport];
}

#pragma mark Chapter Navigation

- (AVTimedMetadataGroup *)nextChapterTime
{
	AVTimedMetadataGroup *nextChapterGroup;
	
	CMTime currentTime = self.player.currentItem.currentTime;
	CMTime nextChapterTime = kCMTimePositiveInfinity;
	for (AVTimedMetadataGroup *timedMetadataGroup in self.chapterMetadataGroups)
	{
		if (CMTIME_COMPARE_INLINE(timedMetadataGroup.timeRange.start, >, currentTime) && CMTIME_COMPARE_INLINE(timedMetadataGroup.timeRange.start, <, nextChapterTime))
		{
			nextChapterTime = timedMetadataGroup.timeRange.start;
			nextChapterGroup = timedMetadataGroup;
		}
	}
	
	return nextChapterGroup;
}

- (AVTimedMetadataGroup *)previousChapterTime
{
	AVTimedMetadataGroup *previousChapterGroup;
	
	// Give a second of time to seek to the previous chapter, as opposed to the beginning of the current chapter
	CMTime currentTimeMinusASecond = CMTimeSubtract(self.player.currentItem.currentTime, CMTimeMakeWithSeconds(1, 300));
	CMTime previousChapterTime = kCMTimeNegativeInfinity;
	for (AVTimedMetadataGroup *timedMetadataGroup in self.chapterMetadataGroups)
	{
		if (CMTIME_COMPARE_INLINE(timedMetadataGroup.timeRange.start, <, currentTimeMinusASecond) && CMTIME_COMPARE_INLINE(timedMetadataGroup.timeRange.start, >, previousChapterTime))
		{
			previousChapterTime = timedMetadataGroup.timeRange.start;
			previousChapterGroup = timedMetadataGroup;
		}
	}
	
	return previousChapterGroup;
}

- (NSUInteger)chapterNumberForChapterGroup:(AVTimedMetadataGroup *)chapterGroup
{
	return [self.chapterMetadataGroups indexOfObject:chapterGroup] + 1;
}

- (void)seekToChapterTime:(AVTimedMetadataGroup *)chapterGroup
{
	CMTime chapterTime = chapterGroup.timeRange.start;
	if (CMTIME_IS_NUMERIC(chapterTime))
	{
		[self.player.currentItem seekToTime:chapterTime completionHandler:^(BOOL finished) {
			// Flash the current chapter number and title
			[self.playerView flashChapterNumber:[self chapterNumberForChapterGroup:chapterGroup] chapterTitle:[[AVMetadataItem metadataItemsFromArray:chapterGroup.items withKey:AVMetadataCommonKeyTitle keySpace:AVMetadataKeySpaceCommon].firstObject value]];
		}];
	}
}

- (IBAction)nextChapter:(id)sender
{
	[self seekToChapterTime:self.nextChapterTime];
}

- (IBAction)previousChapter:(id)sender
{
	[self seekToChapterTime:self.previousChapterTime];
}

#pragma mark Action Menu

- (void)toggleActionMenu:(id)sender
{
	NSMenu *menu;
	
	if (self.playerView.actionPopUpButtonMenu == nil)
	{
		// In a real application, these menu items would do something more interesting
		menu = [[NSMenu alloc] initWithTitle:@""];
		[menu addItem:[[NSMenuItem alloc] initWithTitle:@"this" action:NULL keyEquivalent:@""]];
		[menu addItem:[[NSMenuItem alloc] initWithTitle:@"is" action:NULL keyEquivalent:@""]];
		[menu addItem:[[NSMenuItem alloc] initWithTitle:@"the" action:NULL keyEquivalent:@""]];
		[menu addItem:[[NSMenuItem alloc] initWithTitle:@"action" action:NULL keyEquivalent:@""]];
		[menu addItem:[[NSMenuItem alloc] initWithTitle:@"menu" action:NULL keyEquivalent:@""]];
	}
	
	self.playerView.actionPopUpButtonMenu = menu;
}

#pragma mark UI Validation

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item
{
	SEL action = [item action];
	
	if (sel_isEqual(action, @selector(trim:)))
	{
		// -canBeginTrimming will return NO when the current AVPlayerItem cannot be trimmed or the trim controls are already shown
		return self.playerView.canBeginTrimming;
	}
	else if (sel_isEqual(action, @selector(startExport:)))
	{
		// Cannot export if there is not an AVAsset
		return self.player.currentItem.asset ? YES : NO;
	}
	else if (sel_isEqual(action, @selector(toggleActionMenu:)))
	{
		// Show a check mark on the menu item when the action popup button is being displayed, otherwise do not
		if ([(NSMenuItem *)item respondsToSelector:@selector(setState:)])
			[(NSMenuItem *)item setState:self.playerView.actionPopUpButtonMenu != nil ? NSOnState : NSOffState];
		return YES;
	}
	else if (sel_isEqual(action, @selector(nextChapter:)) || sel_isEqual(action, @selector(previousChapter:)))
	{
		// Cannot seek chapters if there is no chapter metadata
		return self.chapterMetadataGroups ? YES : NO;
	}
	
	return [super validateUserInterfaceItem:item];
}

@end
