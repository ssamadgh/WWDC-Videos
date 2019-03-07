/*
     File: RecordViewController.m
 Abstract: The view controller for the Recording UI.
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

#import "RecordViewController.h"
#import <AssertMacros.h>

static void *IsAdjustingFocusingContext = &IsAdjustingFocusingContext;

static NSString *UniqueFilePath(void)
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
	if (path) {
		// Unique file name.
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSInteger fileCount = [defaults integerForKey:@"RecordedFileCount"];
		fileCount++;
		[defaults setInteger:fileCount forKey:@"RecordedFileCount"];
		[defaults synchronize];
		path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"SloPoke_%04d.mov", (int)fileCount]];
	}
	return path;
}

static AVCaptureVideoOrientation CaptureOrientationForDeviceOrientation(UIDeviceOrientation devOrientation)
{
	switch (devOrientation) {
		case UIDeviceOrientationLandscapeRight:
			return AVCaptureVideoOrientationLandscapeLeft;
		case UIDeviceOrientationLandscapeLeft:
			return AVCaptureVideoOrientationLandscapeRight;
		case UIDeviceOrientationPortraitUpsideDown:
			return AVCaptureVideoOrientationPortraitUpsideDown;
		default:
			break;
	}
	return AVCaptureVideoOrientationPortrait;
}


@interface RecordViewController ()

@property(nonatomic, assign) IBOutlet UILabel *formatDescriptionLabel;
@property(nonatomic, assign) IBOutlet UILabel *recordDurationLabel;
@property(nonatomic, assign) IBOutlet RecordView *previewView;
@property(nonatomic, assign) IBOutlet UIButton *recordStopButton;

@property(nonatomic, retain) CALayer *adjustingFocusLayer;
@property(nonatomic, retain) AVCaptureSession *session;
@property(nonatomic, retain) AVCaptureMovieFileOutput *movieFileOutput;

@end


@implementation RecordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if ( !self.session ) {
		[self setupSession];
	}
	
	if ( !self.adjustingFocusLayer) {
		CALayer *adjustingFocusBox = [RecordViewController createLayerBoxWithColor:[UIColor colorWithRed:0.f green:0.f blue:1.f alpha:.8f]];
		[self.previewView.layer addSublayer:adjustingFocusBox];
		self.adjustingFocusLayer = adjustingFocusBox;
	}
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraWantsRefocus:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo]];
}

- (void)viewWillAppear:(BOOL)animated
{
	[self.session startRunning];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self.session stopRunning];
}

- (void)showAlertDialogForError:(NSError *)error title:(NSString *)title
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:[error localizedFailureReason] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)configureCameraForHighFrameRate:(AVCaptureDevice *)device
{
	AVCaptureDeviceFormat *bestFormat = nil;
	AVFrameRateRange *bestFrameRateRange = nil;
	int32_t bestPixelArea = 0;
	
	for ( AVCaptureDeviceFormat *format in [device formats] ) {
		CMVideoDimensions dims = CMVideoFormatDescriptionGetDimensions([format formatDescription]);
		int32_t pixelArea = dims.width * dims.height;
		for ( AVFrameRateRange *range in format.videoSupportedFrameRateRanges ) {
			if ( range.maxFrameRate > bestFrameRateRange.maxFrameRate ||
				 ((range.maxFrameRate == bestFrameRateRange.maxFrameRate) && (pixelArea > bestPixelArea)) ) {
				bestFormat = format;
				bestFrameRateRange = range;
				bestPixelArea = pixelArea;
			}
		}
	}
	
	if ( bestFormat ) {
		if ( YES == [device lockForConfiguration:NULL] ) {
			device.activeFormat = bestFormat;
			device.activeVideoMinFrameDuration = bestFrameRateRange.minFrameDuration;
			device.activeVideoMaxFrameDuration = bestFrameRateRange.minFrameDuration;
			[device unlockForConfiguration];
			
			CMFormatDescriptionRef fdesc = bestFormat.formatDescription;
			CMVideoDimensions dims = CMVideoFormatDescriptionGetDimensions(fdesc);
			int32_t pixelType = CMFormatDescriptionGetMediaSubType(fdesc);
			
			self.formatDescriptionLabel.text = [NSString stringWithFormat:@"%c%c%c%c %dx%d@%d FPS", pixelType >> 24 & 0xff, pixelType >> 16 & 0xff, pixelType >> 8 & 0xff, pixelType >> 0 & 0xff, dims.width, dims.height, (int)bestFrameRateRange.maxFrameRate];
		}
		else
			NSLog(@"failed to lock device for configuration!");
	}
}

- (void)setupSession
{
	NSError *error = nil;
	AVCaptureMovieFileOutput *mfo = nil;
	AVCaptureSession *session = [[AVCaptureSession alloc] init];
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	[audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
	[audioSession setActive:YES error:nil];
	
	// Add camera input
	AVCaptureDevice *camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	AVCaptureDeviceInput *cameraInput = [AVCaptureDeviceInput deviceInputWithDevice:camera error:&error];
	require_action( error == nil, bail, [self showAlertDialogForError:error title:@"Couldn't create camera input"]);
	[session addInput:cameraInput];
	[self configureCameraForHighFrameRate:camera];
	[camera addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew context:IsAdjustingFocusingContext];

	// Add microphone input
	AVCaptureDevice *mic = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
	AVCaptureDeviceInput *micInput = [AVCaptureDeviceInput deviceInputWithDevice:mic error:&error];
	require_action( error == nil, bail, [self showAlertDialogForError:error title:@"Couldn't create mic input"]);
	[session addInput:micInput];
	
	// Add movie file output
	mfo = [[AVCaptureMovieFileOutput alloc] init];
	[session addOutput:mfo];
	
	// opt in for video stabilization
	AVCaptureConnection *c = [mfo connectionWithMediaType:AVMediaTypeVideo];
	if ( [c isVideoStabilizationSupported] )
		[c setEnablesVideoStabilizationWhenAvailable:YES];
	
	// Add a video preview layer
	self.previewView.session = session;
	
	self.session = session;
	self.movieFileOutput = mfo;
	
bail:
	[session release];
	[mfo release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	[device removeObserver:self forKeyPath:@"adjustingFocus"];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.session = nil;
	self.movieFileOutput = nil;
	self.adjustingFocusLayer = nil;
	[super dealloc];
}

- (IBAction)toggleRecording:(id)sender
{
	if ( self.movieFileOutput.isRecording ) {
		[self.movieFileOutput stopRecording];
	}
	else {
		// Use Smooth focus
		AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
		if ( YES == [device lockForConfiguration:NULL] ) {
			if ( [device isSmoothAutoFocusSupported] )
				[device setSmoothAutoFocusEnabled:YES];
			AVCaptureFocusMode currentMode = [device focusMode];
			if ( currentMode == AVCaptureFocusModeLocked )
				currentMode = AVCaptureFocusModeAutoFocus; // force one focus.
			if ( [device isFocusModeSupported:currentMode] )
				[device setFocusMode:currentMode];
			[device unlockForConfiguration];
		}
		
		// Set Orientation
		AVCaptureVideoOrientation captureOrientation = CaptureOrientationForDeviceOrientation([[UIDevice currentDevice] orientation]);
		[[self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:captureOrientation];
		
		// Start Recording
		NSURL *url = [NSURL fileURLWithPath:UniqueFilePath()];
		[self.movieFileOutput startRecordingToOutputFileURL:url recordingDelegate:self];
		
		// Update UI
		[self.recordStopButton setImage:[UIImage imageNamed:@"stopbutton"] forState:UIControlStateNormal];
		
		dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
		if (timer) {
			uint64_t milliseconds = 500ull;
			uint64_t interval = milliseconds * NSEC_PER_MSEC;
			uint64_t leeway = 100ull * NSEC_PER_MSEC;
			__block typeof(self) _self = self;
			
			dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), interval, leeway);
			dispatch_source_set_event_handler(timer, ^{
				if ( _self.movieFileOutput.isRecording ) {
					NSTimeInterval duration = CMTimeGetSeconds(_self.movieFileOutput.recordedDuration);
					int hours = duration / (60 * 60);
					int minutes = (duration - (hours*60*60)) / 60;
					int seconds = (duration - (hours*60*60) - (minutes*60));
					_self.recordDurationLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
				}
				else {
					dispatch_source_cancel(timer);
					dispatch_release(timer);
					_self.recordDurationLabel.text = @"00:00:00";
				}
			});
			
			dispatch_resume(timer);
		}
	}
}

- (IBAction)handleTapInPreviewView:(UIGestureRecognizer *)recognizer
{
	CGPoint touchPoint = [recognizer locationInView:self.previewView];
	CGPoint poi = [(AVCaptureVideoPreviewLayer *)self.previewView.layer captureDevicePointOfInterestForPoint:touchPoint];
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if ( YES == [device lockForConfiguration:NULL] ) {
		if ( [device isFocusPointOfInterestSupported] ) {			
			[device setFocusPointOfInterest:poi];
			[device setFocusMode:AVCaptureFocusModeAutoFocus];
			
			// Register for callback when scene has changed substantially
			[device setSubjectAreaChangeMonitoringEnabled:YES];
		}
		if ( [device isExposurePointOfInterestSupported] ) {
			[device setExposurePointOfInterest:poi];
			[device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
			
			// Register for callback when scene has changed substantially
			[device setSubjectAreaChangeMonitoringEnabled:YES];
		}
		[device unlockForConfiguration];
	}
}

- (void)cameraWantsRefocus:(NSNotification *)n
{
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if ( YES == [device lockForConfiguration:NULL] ) {
		if ( [device isFocusPointOfInterestSupported] ) {
			[device setFocusPointOfInterest:CGPointMake(.5, .5)];
			[device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
		}
		if ( [device isExposurePointOfInterestSupported] ) {
			[device setExposurePointOfInterest:CGPointMake(.5, .5)];
			[device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
		}
		[device setSubjectAreaChangeMonitoringEnabled:NO];
		[device unlockForConfiguration];
	}
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL*)url fromConnections:(NSArray *)connections error:(NSError *)error
{
	BOOL success = YES;
	[self.recordStopButton setImage:[UIImage imageNamed:@"recordbutton"] forState:UIControlStateNormal];
	if ( error ) {
		success = [[[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey] boolValue];
		if ( ! success ) {
			[[NSFileManager defaultManager] removeItemAtURL:url error:nil];
			[self.recordStopButton setImage:[UIImage imageNamed:@"stopbutton"] forState:UIControlStateNormal];
			[self showAlertDialogForError:error title:@"Recording Failed"];
		}
	}
	if ( success ) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"RecordingCompleted" object:self userInfo:@{@"URL" : url}];
	}
	
	// Go back to faster focus
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if ( YES == [device lockForConfiguration:NULL] ) {
		if ( [device isSmoothAutoFocusSupported] )
			[device setSmoothAutoFocusEnabled:NO];
		if ( [device isFocusPointOfInterestSupported] )
			[device setFocusPointOfInterest:CGPointMake(.5, .5)];
		if ( [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus] )
			[device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
		[device unlockForConfiguration];
	}
}

+ (CALayer *)createLayerBoxWithColor:(UIColor *)color
{
    NSDictionary *unanimatedActions = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"bounds",[NSNull null], @"frame",[NSNull null], @"position", nil];
    CALayer *box = [[CALayer alloc] init];
    [box setActions:unanimatedActions];
    [box setBorderWidth:1.f];
    [box setBorderColor:[color CGColor]];
    [box setOpacity:0.f];
    [unanimatedActions release];
    
    return [box autorelease];
}

+ (void)addAdjustingAnimationToLayer:(CALayer *)layer removeAnimation:(BOOL)remove
{
    if (remove) {
        [layer removeAnimationForKey:@"animateOpacity"];
    }
    if ([layer animationForKey:@"animateOpacity"] == nil) {
        [layer setHidden:NO];
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [opacityAnimation setDuration:.3f];
        [opacityAnimation setRepeatCount:1.f];
        [opacityAnimation setAutoreverses:YES];
        [opacityAnimation setFromValue:@1.f];
        [opacityAnimation setToValue:@.0f];
        [layer addAnimation:opacityAnimation forKey:@"animateOpacity"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ( context == IsAdjustingFocusingContext ) {
		BOOL isAdjusting = [change[NSKeyValueChangeNewKey] boolValue];
		CALayer *layer = self.adjustingFocusLayer;
		[layer setBorderWidth:2.f];
		[layer setBorderColor:[[UIColor colorWithRed:0.f green:0.f blue:1.f alpha:.7f] CGColor]];
		[layer setCornerRadius:8.f];
		[RecordViewController addAdjustingAnimationToLayer:layer removeAnimation:NO];
		
		if (isAdjusting == YES) {
			// Size the layer
			CGPoint poi = [(AVCaptureDevice *)object focusPointOfInterest];
			CGSize layerSize;
			if ( CGPointEqualToPoint(poi, CGPointMake(.5, .5)) )
				layerSize = CGSizeMake(self.previewView.bounds.size.width * .8, self.previewView.bounds.size.height * .8);
			else {
				CGFloat points = MIN(self.previewView.bounds.size.width * .25, self.previewView.bounds.size.height * .25);
				layerSize = CGSizeMake(points, points);
			}
			poi = [(AVCaptureVideoPreviewLayer *)self.previewView.layer pointForCaptureDevicePointOfInterest:poi];
			[layer setFrame:CGRectMake(0., 0., layerSize.width, layerSize.height)];
			[layer setPosition:poi];
		}
	}
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	AVCaptureVideoPreviewLayer *videoPreviewLayer = (AVCaptureVideoPreviewLayer *)self.previewView.layer;
	videoPreviewLayer.connection.videoOrientation = toInterfaceOrientation;
}

@end
