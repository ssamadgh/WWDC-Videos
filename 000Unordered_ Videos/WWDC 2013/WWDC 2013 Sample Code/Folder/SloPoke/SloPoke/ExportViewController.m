/*
     File: ExportViewController.m
 Abstract: The view controller that presents the Share-To-Photos-Library export UI.
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

#import "ExportViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ExportViewController ()

@property(nonatomic, assign) IBOutlet UISwitch *constantFrameRateSwitch;
@property(nonatomic, assign) IBOutlet UISlider *frameRateSlider;
@property(nonatomic, assign) IBOutlet UILabel *frameRateLabel;
@property(nonatomic, assign) IBOutlet UISwitch *preservesPitchSwitch;
@property(nonatomic, assign) IBOutlet UISwitch *editedSegmentOnlySwitch;
@property(nonatomic, assign) IBOutlet UILabel *exportingMovieLabel;
@property(nonatomic, assign) IBOutlet UIProgressView *exportingProgress;

- (IBAction)share:(id)sender;
- (IBAction)dismiss:(id)sender;
- (IBAction)adjustExportFrameRate:(id)sender;
- (IBAction)toggleConstantFrameRate:(id)sender;

@property(retain) AVAssetExportSession *session;
@property float srcNominalFrameRate;

@end


@implementation ExportViewController

- (void)showAlertDialogForError:(NSError *)error title:(NSString *)title
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:[error localizedFailureReason] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
	PlayListItem *pli = self.sourcePlayListItem;
	if ( pli ) {
		// put the "Preserves Pitch" toggle in the right position
		NSString *timePitchAlgorithm = pli.preferredAudioTimePitchAlgorithm;
		self.preservesPitchSwitch.on = [timePitchAlgorithm isEqualToString:AVAudioTimePitchAlgorithmSpectral];

		// Get the proper units for the constant frame rate slider
		AVAssetTrack *srcAssetVideoTrack = [[pli.originalAsset tracksWithMediaType:AVMediaTypeVideo] lastObject];
		self.frameRateSlider.maximumValue = srcAssetVideoTrack.nominalFrameRate;
		self.frameRateSlider.minimumValue = 1;
		self.frameRateSlider.value = srcAssetVideoTrack.nominalFrameRate;
		self.frameRateLabel.text = [NSString stringWithFormat:@"%2.2f FPS", srcAssetVideoTrack.nominalFrameRate];
		self.srcNominalFrameRate = srcAssetVideoTrack.nominalFrameRate;
	}
}

- (void)dealloc
{
	self.sourcePlayListItem = nil;
	self.session = nil;
	[super dealloc];
}

- (IBAction)adjustExportFrameRate:(id)sender
{
	float value = ((UISlider *)sender).value;
	self.frameRateLabel.text = [NSString stringWithFormat:@"%2.2f FPS", value];
}

- (IBAction)toggleConstantFrameRate:(id)sender
{
	BOOL enable = ((UISwitch *)sender).isOn;
	self.frameRateSlider.enabled = enable;
	self.frameRateLabel.enabled = enable;
}

- (IBAction)share:(id)sender
{
	// First make sure we can write to camera roll.
	ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
	if ( status == ALAuthorizationStatusRestricted || status == ALAuthorizationStatusDenied ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't share to photos library" message:@"To share to photos library, you need to go to the Settings app and enable Photos writing for this app" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	NSString *preset = self.constantFrameRateSwitch.isOn ? AVAssetExportPresetHighestQuality : AVAssetExportPresetPassthrough;
	PlayListItem *pli = self.sourcePlayListItem;
	AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:pli.editedAsset presetName:preset];
	
	NSString *last = [[pli.url URLByDeletingPathExtension] lastPathComponent];
	NSString *newLast = [NSString stringWithFormat:@"%@_Export.%@", last, pli.url.pathExtension];
	exportSession.outputURL = [[pli.url URLByDeletingLastPathComponent] URLByAppendingPathComponent:newLast];
	exportSession.outputFileType = AVFileTypeQuickTimeMovie;
	
	NSString *timePitchAlgorithm = (self.preservesPitchSwitch.isOn ? AVAudioTimePitchAlgorithmSpectral : AVAudioTimePitchAlgorithmVarispeed);
	exportSession.audioTimePitchAlgorithm = timePitchAlgorithm;
	
	if ( self.editedSegmentOnlySwitch.isOn ) {
		CMTime duration = CMTimeSubtract(pli.endEditDestTime, pli.beginEditSourceTime);
		if ( CMTimeGetSeconds(duration) > 0. ) {
			exportSession.timeRange = CMTimeRangeMake(pli.beginEditSourceTime, duration);
		}
	}
	
	if ( self.constantFrameRateSwitch.isOn ) {
		AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:pli.editedAsset];
		videoComposition.frameDuration = CMTimeMake(1000, self.frameRateSlider.value * 1000);
		exportSession.videoComposition = videoComposition;
	}
	
	__block BOOL done = NO;
	dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
	if (timer) {
		uint64_t milliseconds = 100ull;
		uint64_t interval = milliseconds * NSEC_PER_MSEC;
		uint64_t leeway = 10ull * NSEC_PER_MSEC;
		__block typeof(self) _self = self;
		
		dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), interval, leeway);
		dispatch_source_set_event_handler(timer, ^{
			[_self.exportingProgress setProgress:exportSession.progress animated:YES];
			if ( done ) {
				dispatch_source_cancel(timer);
				dispatch_release(timer);
				_self.exportingMovieLabel.hidden = YES;
				_self.exportingProgress.hidden = YES;
			}
		});
		
		dispatch_resume(timer);
	}
	
	self.exportingMovieLabel.text = [NSString stringWithFormat:@"Exporting %@...", pli.url.lastPathComponent];
	self.exportingMovieLabel.hidden = NO;
	self.exportingProgress.progress = 0.;
	self.exportingProgress.hidden = NO;

	[exportSession exportAsynchronouslyWithCompletionHandler:^{
		NSError *error = exportSession.error;
		if ( ! error ) {
			// Write it to assets library
			ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
			[assetsLibrary writeVideoAtPathToSavedPhotosAlbum:exportSession.outputURL completionBlock:^(NSURL *assetURL, NSError *writeToPhotoLibraryError) {
				if ( writeToPhotoLibraryError )
					[self showAlertDialogForError:writeToPhotoLibraryError title:@"Save to Photo Library Failed"];
				[[NSFileManager defaultManager] removeItemAtURL:exportSession.outputURL error:NULL];
			}];
			[assetsLibrary release];
		}
		else {
			[self showAlertDialogForError:error title:@"Export Failed"];
			[[NSFileManager defaultManager] removeItemAtURL:exportSession.outputURL error:NULL];
		}
		done = YES;
	}];
	
	[exportSession release];
}

- (IBAction)dismiss:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:^{
		//NSLog(@"ExportViewController was dismissed");
	}];
}

@end
