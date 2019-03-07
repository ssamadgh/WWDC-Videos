/*
     File: PlayerViewController.m
 Abstract: The view controller that handles the playback/editing/export UI
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

#import "PlayerViewController.h"
#import "ExportViewController.h"

static void *PlayerViewControllerDurationObservationContext = &PlayerViewControllerDurationObservationContext;
static void *PlayerViewControllerRateObservationContext = &PlayerViewControllerRateObservationContext;

@interface PlayerViewController ()

@property(nonatomic, assign) IBOutlet PlayerView *playerView;
@property(nonatomic, assign) IBOutlet UISlider *scrubber;
@property(nonatomic, assign) IBOutlet UIView *beginEditsView;
@property(nonatomic, assign) IBOutlet UIView *endEditsView;
@property(nonatomic, assign) IBOutlet UILabel *editRateLabel;
@property(nonatomic, assign) IBOutlet UISlider *editRateSlider;
@property(nonatomic, assign) IBOutlet UILabel *rateLabel;
@property(retain) AVPlayer *player;

- (IBAction)beginScrubbing:(id)sender;
- (IBAction)scrub:(id)sender;
- (IBAction)endScrubbing:(id)sender;

- (IBAction)toggleChipmunks:(id)sender;

- (IBAction)applyScaledEdit:(id)sender;
- (IBAction)editRateChanged:(id)sender;

@property id timeObserver;
@property float restoreAfterScrubbingRate;

@end



@implementation PlayerViewController

- (void)dealloc
{
	if (_timeObserver)
	{
		[_player removeTimeObserver:_timeObserver];
		[_timeObserver release];
	}
	[_player removeObserver:self forKeyPath:@"rate"];
	[_player removeObserver:self forKeyPath:@"currentItem.asset.duration"];
	self.player = nil;
	self.playListItem = nil;
	
	[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_beginEditsView.layer.cornerRadius = 8.f;
	_beginEditsView.hidden = YES;
	_endEditsView.layer.cornerRadius = 8.f;
	_endEditsView.hidden = YES;

	_player = [[AVPlayer alloc] init];
	PlayListItem *pli = self.playListItem;
	if ( pli ) {
		AVAsset *asset = pli.editedAsset;
		AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
		item.audioTimePitchAlgorithm = pli.preferredAudioTimePitchAlgorithm;
		[_player replaceCurrentItemWithPlayerItem:item];
	}
	[_player addObserver:self forKeyPath:@"currentItem.asset.duration" options:0 context:PlayerViewControllerDurationObservationContext];
	[_player addObserver:self forKeyPath:@"rate" options:0 context:PlayerViewControllerRateObservationContext];
	self.playerView.player = self.player;
	
	double interval = .1f;
	AVAsset* asset = _player.currentItem.asset;
	
	if ( CMTIME_COMPARE_INLINE(asset.duration, >=, pli.savedCurrentTime) )
		[_player seekToTime:pli.savedCurrentTime];
	
	if (asset) {
		double duration = CMTimeGetSeconds(asset.duration);
		
		if (isfinite(duration)) {
			CGFloat width = CGRectGetWidth(_scrubber.bounds);
			interval = 0.5f * duration / width;
		}
	}
	
	if ( _timeObserver )
	{
		[_player removeTimeObserver:_timeObserver];
		[_timeObserver release];
	}
	
	_timeObserver = [[_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:
					  ^(CMTime time) {
						  [self syncScrubber];
					  }] retain];
	
	[self syncScrubber];
}

- (void)viewWillAppear:(BOOL)animated
{
	NSError *error = nil;
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	if ( YES == [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error] ) {
		[audioSession setActive:YES error:&error];
	}
	if ( error )
		NSLog(@"AVAudioSession failure %@", error);
	
	self.navigationController.navigationBarHidden = YES;
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[_player pause];
	self.playListItem.savedCurrentTime = _player.currentTime;
	self.navigationController.navigationBarHidden = NO;
	self.hidesBottomBarWhenPushed = NO;
	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toggleChipmunks:(id)sender
{
	PlayListItem *pli = self.playListItem;
	AVPlayerItem *item = _player.currentItem;
	NSString *algorithm = pli.preferredAudioTimePitchAlgorithm;
	if ( [algorithm isEqualToString:AVAudioTimePitchAlgorithmVarispeed] ) {
		// switch to Spectral (constant pitch)
		pli.preferredAudioTimePitchAlgorithm = item.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmSpectral;
		[sender setImage:[UIImage imageNamed:@"chipmunk"] forState:UIControlStateNormal];
	}
	else if ( [algorithm isEqualToString:AVAudioTimePitchAlgorithmSpectral] ) {
		// switch to Varispeed (chipmunks)
		pli.preferredAudioTimePitchAlgorithm = item.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmVarispeed;
		[sender setImage:[UIImage imageNamed:@"chipmunk_glow"] forState:UIControlStateNormal];
	}
}

- (IBAction)handleSwipeUp:(id)sender
{
	CMTime endTime = _player.currentTime;
	if ( CMTIME_COMPARE_INLINE(endTime, >, self.playListItem.beginEditSourceTime) )
		self.endEditsView.hidden = NO;
}

- (IBAction)applyScaledEdit:(id)sender
{
	NSError *error = nil;
	PlayListItem *pli = self.playListItem;
	AVMutableComposition *composition = [AVMutableComposition composition];
	
	CMTime endTime = _player.currentTime;
	pli.endEditSourceTime = endTime;
	
	// insert the whole source movie into our composition's timeline.
	CMTime srcDuration = pli.originalAsset.duration;
	CMTimeRange srcTimeRange = CMTimeRangeFromTimeToTime(kCMTimeZero, srcDuration);
	[composition insertTimeRange:srcTimeRange ofAsset:pli.originalAsset atTime:kCMTimeZero error:&error];
	if (error)
		NSLog(@"Inserting source asset into composition failed (%@)", error);
	
	// Perform the scaled edit
	srcDuration = CMTimeSubtract(pli.endEditSourceTime, pli.beginEditSourceTime);
	srcTimeRange = CMTimeRangeMake(pli.beginEditSourceTime, srcDuration);
	pli.editRate = [self.editRateSlider value];
	CMTime destDuration = CMTimeMultiplyByFloat64(srcDuration, 1 / pli.editRate);
	pli.endEditDestTime = CMTimeAdd(pli.beginEditSourceTime, destDuration);
	[composition scaleTimeRange:srcTimeRange toDuration:destDuration];
	
	
	// fix orientation of composition
	for ( AVMutableCompositionTrack *track in [composition tracks] ) {
		if ( [[track mediaType] isEqualToString:AVMediaTypeVideo] ) {
			AVAssetTrack *srcAssetVideoTrack = [[pli.originalAsset tracksWithMediaType:AVMediaTypeVideo] lastObject];
			[track setPreferredTransform:[srcAssetVideoTrack preferredTransform]];
		}
	}
	
	// Replace our current player item with a new player item for this composition.
	// Remember, an AVMutableComposition _is_ an AVAsset
	pli.editedAsset = composition;
	AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:composition];
	item.audioTimePitchAlgorithm = pli.preferredAudioTimePitchAlgorithm;
	[_player replaceCurrentItemWithPlayerItem:item];
	
	// Now seek to the correct time in the new item
	CMTime seekToTime = [self scaledCompositionTimeForOriginalAssetTime:endTime];
	[_player seekToTime:seekToTime];
}

- (CMTime)scaledCompositionTimeForOriginalAssetTime:(CMTime)srcTime
{
	PlayListItem *pli = self.playListItem;
	// Is it before the edit?
	if ( CMTIME_COMPARE_INLINE(srcTime, <=, pli.beginEditSourceTime) )
		return srcTime;
	
	// In the middle of the edit?
	CMTimeRange editRangeInSrcTime = CMTimeRangeMake(pli.beginEditSourceTime, CMTimeSubtract(pli.endEditSourceTime, pli.beginEditSourceTime));
	if ( CMTimeRangeContainsTime(editRangeInSrcTime, srcTime) ) {
		CMTime scaledTime = CMTimeSubtract(srcTime, pli.beginEditSourceTime);
		scaledTime = CMTimeMultiplyByFloat64(scaledTime, 1/pli.editRate);
		return CMTimeAdd(pli.beginEditSourceTime, scaledTime);
	}
	// Or after the edit?
	else {
		CMTime postEditDifference = CMTimeSubtract(pli.endEditSourceTime, srcTime);
		CMTime scaledDuration = CMTimeMultiplyByFloat64(editRangeInSrcTime.duration, 1/pli.editRate);
		CMTime result = CMTimeAdd(pli.beginEditSourceTime, scaledDuration);
		result = CMTimeAdd(result, postEditDifference);
		return result;
	}
	return kCMTimeZero;
}

- (CMTime)originalAssetTimeForScaledCompositionTime:(CMTime)compTime
{
	PlayListItem *pli = self.playListItem;
	// Is it before the edit?
	if ( CMTIME_COMPARE_INLINE(compTime, <=, pli.beginEditSourceTime) )
		return compTime;
	
	// In the middle of the edit?
	CMTimeRange scaledEditRange = CMTimeRangeMake(pli.beginEditSourceTime, CMTimeSubtract(pli.endEditDestTime, pli.beginEditSourceTime));
	if ( CMTimeRangeContainsTime(scaledEditRange, compTime) ) {
		CMTime unscaledTime = CMTimeSubtract(compTime, pli.beginEditSourceTime);
		unscaledTime = CMTimeMultiplyByFloat64(unscaledTime, pli.editRate);
		return CMTimeAdd(pli.beginEditSourceTime, unscaledTime);
	}
	// Or after the edit ?
	else {
		CMTime postEditDifference = CMTimeSubtract(pli.endEditSourceTime, compTime);
		CMTime unscaledDuration = CMTimeMultiplyByFloat64(scaledEditRange.duration, pli.editRate);
		CMTime result = CMTimeAdd(pli.beginEditSourceTime, unscaledDuration);
		result = CMTimeAdd(result, postEditDifference);
		return result;
	}
	return kCMTimeZero;
}

- (IBAction)editRateChanged:(id)sender
{
	self.editRateLabel.text = [NSString stringWithFormat:@"%.2f", [(UISlider *)sender value]];
}

- (IBAction)handleSwipeDown:(id)sender
{
	PlayListItem *pli = self.playListItem;
	// Begin edit
	_player.rate = 0;
	CMTime currentTime = _player.currentTime;
	if ( _player.currentItem.asset != pli.originalAsset ) {
		currentTime = [self originalAssetTimeForScaledCompositionTime:currentTime];
		
		pli.editedAsset = nil;
		AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:pli.originalAsset];
		item.audioTimePitchAlgorithm = pli.preferredAudioTimePitchAlgorithm;
		[_player replaceCurrentItemWithPlayerItem:item];
		
		[_player seekToTime:currentTime];
	}
	pli.beginEditSourceTime = pli.endEditSourceTime = currentTime;
	self.editRateSlider.value = 1.;
	[self editRateChanged:self.editRateSlider];
	[self toggleEditViewsHiddenForTime:currentTime];
}

static float kPlayRates[] = { .25, .5, .75, 1, 1.5, 2 };

- (IBAction)handleSwipeRight:(id)sender
{
	// Swipe right means different things when you're playing or stopped.
	// Stopped == flip back by a frame
	// Playing == fast forward
	
	float rate = _player.rate;
	if ( rate == 0 ) {
		[_player.currentItem stepByCount:-1];
		[self toggleEditViewsHiddenForTime:_player.currentTime];
	}
	else {
		int i, numPlayRates = sizeof(kPlayRates) / sizeof(float);
		for ( i = 0; i < numPlayRates; i++ ) {
			if ( kPlayRates[i] == rate ) {
				if ( i + 1 < numPlayRates ) {
					rate = kPlayRates[i+1];
					_player.rate = rate;
				}
				break;
			}
		}
	}
}

- (IBAction)handleSwipeLeft:(id)sender
{
	// Swipe left means different things when you're playing or stopped.
	// Stopped == flip forward by a frame
	// Playing == slow down
	
	float rate = _player.rate;
	if ( rate == 0 ) {
		[_player.currentItem stepByCount:1];
		[self toggleEditViewsHiddenForTime:_player.currentTime];
	}
	else {
		int i, numPlayRates = sizeof(kPlayRates) / sizeof(float);
		for ( i = 0; i < numPlayRates; i++ ) {
			if ( kPlayRates[i] == rate ) {
				if ( i - 1 >= 0 ) {
					rate = kPlayRates[i-1];
					_player.rate = rate;
				}
				break;
			}
		}
	}
}

- (IBAction)handleTwoFingerSwipeDown:(id)sender
{
	self.navigationController.navigationBarHidden = NO;
}

- (IBAction)handleTwoFingerSwipeUp:(id)sender
{
	self.navigationController.navigationBarHidden = YES;
}

- (IBAction)togglePlayback:(id)sender
{
	float newRate = (_player.rate != 0.f ? 0.f : 1.f);
	if ( newRate != 0 ) {
		if ( CMTIME_COMPARE_INLINE(_player.currentTime, ==, _player.currentItem.duration) ) {
			[_player seekToTime:kCMTimeZero];
		}
	}
	_player.rate = newRate;
	if ( newRate == 0 ) {
		[self toggleEditViewsHiddenForTime:_player.currentTime];
	}
	else {
		[self toggleEditViewsHiddenForTime:kCMTimePositiveInfinity];
	}
}

- (void)toggleEditViewsHiddenForTime:(CMTime)time
{
	PlayListItem *pli = self.playListItem;
	BOOL showBeginEditsView = ( CMTIME_COMPARE_INLINE(time, ==, pli.beginEditSourceTime) );
	BOOL showEndEditsView = ( CMTIME_COMPARE_INLINE(time, ==, pli.endEditDestTime) );
	self.beginEditsView.hidden = !showBeginEditsView;
	self.endEditsView.hidden = !showEndEditsView;
}

- (void)syncScrubber
{
	AVAsset* asset = _player.currentItem.asset;
	
	if (!asset)
		return;
	
	double duration = CMTimeGetSeconds([asset duration]);
	
	if (isfinite(duration)) {
		float minValue = _scrubber.minimumValue;
		float maxValue = _scrubber.maximumValue;
		double time = CMTimeGetSeconds(_player.currentTime);
		
		_scrubber.value = (maxValue - minValue) * time / duration + minValue;
	}
}

- (void)beginScrubbing:(id)sender
{
	_restoreAfterScrubbingRate = _player.rate;
	_player.rate = 0.f;
	
	// Don't listen for periodic time change callbacks while scrubbing
	if (_timeObserver) {
		[_player removeTimeObserver:_timeObserver];
		[_timeObserver release];
		_timeObserver = nil;
	}
}

- (void)scrub:(id)sender
{
	if ([sender isKindOfClass:[UISlider class]])
	{
		UISlider* slider = sender;
		
		AVAsset* asset = _player.currentItem.asset;
		
		if (!asset)
			return;
		
		double duration = CMTimeGetSeconds(asset.duration);
		
		if (isfinite(duration)) {
			float minValue = slider.minimumValue;
			float maxValue = slider.maximumValue;
			float value = slider.value;
			CGFloat width = CGRectGetWidth(slider.bounds);
			
			double time = duration * (value - minValue) / (maxValue - minValue);
			double tolerance = 0.5f * duration / width;
			
			[_player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) toleranceBefore:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) toleranceAfter:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC)];
			[self toggleEditViewsHiddenForTime:_player.currentTime];
		}
	}
}

- (void)endScrubbing:(id)sender
{
	if (!_timeObserver) {
		AVAsset* asset = _player.currentItem.asset;
		
		if (!asset)
			return;
		
		double duration = CMTimeGetSeconds(asset.duration);
		
		if (isfinite(duration)) {
			CGFloat width = CGRectGetWidth(_scrubber.bounds);
			double tolerance = 0.5f * duration / width;
			
			_timeObserver = [[_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:
							  ^(CMTime time)
							  {
								  [self syncScrubber];
							  }] retain];
		}
	}
	
	
	if (_restoreAfterScrubbingRate) {
		_player.rate = _restoreAfterScrubbingRate;
		_restoreAfterScrubbingRate = 0.f;
		_beginEditsView.hidden = YES;
		_endEditsView.hidden = YES;
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ( context == PlayerViewControllerDurationObservationContext ) {
		dispatch_async(dispatch_get_main_queue(),
					   ^{
						   [self syncScrubber];
					   });
	}
	else if ( context == PlayerViewControllerRateObservationContext ) {
		dispatch_async(dispatch_get_main_queue(), ^{
			float newRate = _player.rate;
			if ( newRate == 0 ) {
				self.rateLabel.hidden = YES;
			}
			else {
				self.rateLabel.text = [NSString stringWithFormat:@"%.2fx", newRate];
				self.rateLabel.hidden = NO;
			}
		});
	}
	else
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ( [segue.identifier isEqual:@"showExportView"] ) {
		ExportViewController *exportViewController = segue.destinationViewController;
		exportViewController.sourcePlayListItem = self.playListItem;
	}
	[super prepareForSegue:segue sender:sender];
}

@end
