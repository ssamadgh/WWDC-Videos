/*
     File: ViewController.m
 Abstract: 
The main application view controller.
 
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


#import "ViewController.h"
#import "PreviewView.h"
#import "FaceView.h"

static void displayErrorOnMainQueue(NSError *error, NSString *message);

@interface ViewController ()

@property (weak, nonatomic) IBOutlet PreviewView *preview;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIButton *memeButton;


- (IBAction)meme:(UIButton *)sender;
- (IBAction)sliderChanged:(UISlider *)sender;


@property (strong, nonatomic) AVCaptureSession* session;
@property (strong, nonatomic) AVCaptureDevice* device;
@property (strong, nonatomic) AVCaptureMetadataOutput *metadataOutput;
@property (strong, nonatomic) NSMutableDictionary* faceViews;
@property (strong, nonatomic) NSNumber* lockedFaceID;
@property (assign, nonatomic) CGFloat lockedFaceSize;
@property (assign, nonatomic) double lockTime;
@property (strong, nonatomic) AVPlayer* memeEffect;
@property (strong, nonatomic) AVPlayer* beepEffect;

@end

void* const VideoZoomFactorContext = (void*)&VideoZoomFactorContext;
void* const VideoZoomRampingContext = (void*)&VideoZoomRampingContext;
void* const MemePlaybackContext = (void*)&MemePlaybackContext;
const CGFloat MEME_FLASH_DELAY = 0.7;
const CGFloat MEME_ZOOM_DELAY = 1.1;
const CGFloat MEME_ZOOM_TIME = 0.25;

@implementation ViewController

- (void) setupAVCapture
{
	self.session = [AVCaptureSession new];
	[self.session setSessionPreset:AVCaptureSessionPresetHigh]; // high-res stills, screen-size video
	self.preview.session = self.session;
	
	[self updateCameraSelection];
	
	// For displaying live feed to screen
	CALayer *rootLayer = self.preview.layer;
	[rootLayer setMasksToBounds:YES];
	[(AVCaptureVideoPreviewLayer*)self.preview.layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	[(AVCaptureVideoPreviewLayer*)self.preview.layer setBackgroundColor:[[UIColor blackColor] CGColor]];
	
	// For receiving AV Foundation face detection
	[self setupAVFoundationFaceDetection];
	
	[self.device addObserver:self forKeyPath:@"videoZoomFactor" options:0 context:VideoZoomFactorContext];
	[self.device addObserver:self forKeyPath:@"rampingVideoZoom" options:0 context:VideoZoomRampingContext];
	
	[self.session startRunning];
}

- (void) setupAVFoundationFaceDetection
{
	self.faceViews = [NSMutableDictionary new];
	
	self.metadataOutput = [AVCaptureMetadataOutput new];
	if ( ! [self.session canAddOutput:self.metadataOutput] ) {
		self.metadataOutput = nil;
		return;
	}
	
	// Metadata processing will be fast, and mostly updating UI which should be done on the main thread
	// So just use the main dispatch queue instead of creating a separate one
	[self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
	[self.session addOutput:self.metadataOutput];
	
	if ( ! [self.metadataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeFace] ) {
		// face detection isn't supported via AV Foundation
		[self teardownAVFoundationFaceDetection];
		return;
	}
	self.metadataOutput.metadataObjectTypes = @[ AVMetadataObjectTypeFace ];
	[self updateAVFoundationFaceDetection];
}

- (void) updateAVFoundationFaceDetection
{
	if ( self.metadataOutput )
		[[self.metadataOutput connectionWithMediaType:AVMediaTypeMetadata] setEnabled:YES];
}

- (void) teardownAVFoundationFaceDetection
{
	if ( self.metadataOutput )
		[self.session removeOutput:self.metadataOutput];
	self.metadataOutput = nil;
	self.faceViews = nil;
}

- (void) teardownAVCapture
{
	[self.session stopRunning];
	
	[self teardownAVFoundationFaceDetection];
	
	[self.device unlockForConfiguration];
	[self.device removeObserver:self forKeyPath:@"videoZoomFactor"];
	[self.device removeObserver:self forKeyPath:@"rampingVideoZoom"];
	self.device = nil;
	
	self.session = nil;
}

- (AVCaptureDeviceInput*) pickCamera
{
	AVCaptureDevicePosition desiredPosition = AVCaptureDevicePositionBack;
	BOOL hadError = NO;
	for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
		if ([d position] == desiredPosition) {
			NSError *error = nil;
			AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:d error:&error];
			if (error) {
				hadError = YES;
				displayErrorOnMainQueue(error, @"Could not initialize for AVMediaTypeVideo");
			} else if ( [self.session canAddInput:input] ) {
				return input;
			}
		}
	}
	if ( ! hadError ) {
		// no errors, simply couldn't find a matching camera
		displayErrorOnMainQueue(nil, @"No camera found for requested orientation");
	}
	return nil;
}

- (void) updateCameraSelection
{
	[self.session beginConfiguration];
	
	// have to remove old inputs before we test if we can add a new input
	NSArray* oldInputs = [self.session inputs];
	for (AVCaptureInput *oldInput in oldInputs)
		[self.session removeInput:oldInput];
	
	AVCaptureDeviceInput* input = [self pickCamera];
	if ( ! input ) {
		// failed, restore old inputs
		for (AVCaptureInput *oldInput in oldInputs)
			[self.session addInput:oldInput];
	} else {
		// succeeded, set input and update connection states
		[self.session addInput:input];
		self.device = input.device;
		
		NSError* err;
		if ( ! [self.device lockForConfiguration:&err] ) {
			NSLog(@"Could not lock device: %@",err);
		}

		[self updateAVFoundationFaceDetection];
	}
	
	[self.session commitConfiguration];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)faces fromConnection:(AVCaptureConnection *)connection
{
	NSMutableSet* unseen = [NSMutableSet setWithArray:self.faceViews.allKeys];
	NSMutableSet* seen = [NSMutableSet setWithCapacity:faces.count];
	
	//NSLog(@"Capture output %lu with previous %@",(unsigned long)faces.count,unseen);
	
	// set up callback to be assigned to face views to be called when tapped
	TouchCallback callback = ^(NSInteger faceID, FaceView* view) {
		//NSLog(@"Locked on face %d",faceID);
		self.lockedFaceID = @(faceID);
		self.lockedFaceSize = MAX(view.frame.size.width,view.frame.size.height) / self.device.videoZoomFactor;
		self.lockTime = CACurrentMediaTime();
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3f];
		view.layer.borderColor = [[UIColor redColor] CGColor];
		for (FaceView* f in self.faceViews.allValues) {
			if ( f != view ) {
				f.alpha = 0;
			}
		}
		[UIView commitAnimations];

		[self.beepEffect seekToTime:kCMTimeZero];
		[self.beepEffect play];
	};
		
	// Begin display updates
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

	for ( AVMetadataFaceObject * object in faces ) {
		NSNumber* faceID = @(object.faceID);
		[unseen removeObject:faceID];
		[seen addObject:faceID];
		
		FaceView * view = self.faceViews[faceID];
		if ( ! view ) { // new face, create a layer
			view = [FaceView new];
			view.layer.cornerRadius = 10;
			view.layer.borderWidth = 3;
			view.layer.borderColor = [[UIColor greenColor] CGColor];
			[self.preview addSubview:view];
			self.faceViews[faceID] = view;
			view.faceID = [faceID integerValue];
			view.callback = callback;
			if ( self.lockedFaceID )
				view.alpha = 0;
		}
		
		AVMetadataFaceObject * adjusted = (AVMetadataFaceObject*)[(AVCaptureVideoPreviewLayer*)self.preview.layer transformedMetadataObjectForMetadataObject:object];
		[view setFrame:adjusted.bounds];
		
	}
	
	// remove the faces that weren't detected
	for ( NSNumber* faceID in unseen ) {
		FaceView* view = self.faceViews[faceID];
		[view removeFromSuperview];
		[self.faceViews removeObjectForKey:faceID];
		if ( [faceID isEqual:self.lockedFaceID] ) {
			//NSLog(@"Lost face lock");
			[self clearLockedFace];
		}
	}
	
	if ( self.lockedFaceID ) {
		FaceView * view = self.faceViews[self.lockedFaceID];
		CGFloat size = MAX(view.frame.size.width,view.frame.size.height) / self.device.videoZoomFactor;
		CGFloat zoomDelta = self.lockedFaceSize / size;
		CGFloat lockTime = CACurrentMediaTime() - self.lockTime;
		CGFloat zoomRate = log2(zoomDelta) / lockTime;
		//NSLog(@"Zoom delta %g / %g = %g",self.lockedFaceSize,size,zoomDelta);
		if ( fabs(log2(zoomDelta)) > 0.1 ) // wait until significant motion has occurred
			[self.device rampToVideoZoomFactor:( zoomRate > 0 ? [self getMaxZoom] : 1 ) withRate:zoomRate];
	}

	[CATransaction commit];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ( self.lockedFaceID ) {
		// touch during face-lock cancels the current mode
		[self clearLockedFace];
	} else {
		// otherwise focus at location of touch
		UITouch* touch = [touches anyObject];
		CGPoint point = [touch locationInView:self.preview];
		point = [(AVCaptureVideoPreviewLayer*)self.preview.layer captureDevicePointOfInterestForPoint:point];
		if( self.device.focusPointOfInterestSupported )
			self.device.focusPointOfInterest = point;
		if( self.device.exposurePointOfInterestSupported )
			self.device.exposurePointOfInterest = point;
		if( [self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus] )
			self.device.focusMode = AVCaptureFocusModeAutoFocus;
	}
	[super touchesEnded:touches withEvent:event];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ( context == VideoZoomFactorContext ) {
		[self setZoomSliderValue:self.device.videoZoomFactor];
		self.memeButton.enabled = ( self.device.videoZoomFactor > 1 );
	} else if ( context == VideoZoomRampingContext ) {
		self.slider.enabled = ! self.device.isRampingVideoZoom;
		if ( self.slider.enabled && self.memeEffect.rate == 0 ) {
			[self clearLockedFace];
		}
	} else if ( context == MemePlaybackContext ) {
		if ( self.memeEffect.rate == 0 ) {
			if ( self.device.torchAvailable )
				self.device.torchMode = AVCaptureTorchModeOff;
			[self fadeInFaces];
		}
	} else {
		NSLog(@"Unhandled observation: %@",keyPath);
	}
}

- (void) viewDidLoad
{
    [super viewDidLoad];
	
	NSString *path  = [[NSBundle mainBundle] pathForResource:@"Dramatic2" ofType:@"m4a"];
	if ( path ) {
		self.memeEffect = [AVPlayer playerWithURL:[NSURL fileURLWithPath:path]];
		[self.memeEffect addObserver:self forKeyPath:@"rate" options:0 context:MemePlaybackContext];
	}
	path  = [[NSBundle mainBundle] pathForResource:@"Sosumi" ofType:@"wav"];
	if ( path ) {
		self.beepEffect = [AVPlayer playerWithURL:[NSURL fileURLWithPath:path]];
	}

	[self setupAVCapture];
	
	if( [self getMaxZoom] == 1 ) {
		displayErrorOnMainQueue(nil, @"Device does not support zoom");
		self.slider.enabled = NO;
	}
}

- (void)viewDidUnload
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.memeEffect = nil;
	self.beepEffect = nil;
	[self teardownAVCapture];
    [super viewDidUnload];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[[(AVCaptureVideoPreviewLayer*)self.preview.layer connection] setVideoOrientation:(AVCaptureVideoOrientation)toInterfaceOrientation];
}

- (IBAction)meme:(UIButton *)sender {
	[self.memeEffect seekToTime:kCMTimeZero];
	[self.memeEffect play];
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self performSelector:@selector(flash) withObject:nil afterDelay:MEME_FLASH_DELAY];
	[self performSelector:@selector(startZoom:) withObject:@([self getZoomSliderValue]) afterDelay:MEME_ZOOM_DELAY];
	self.device.videoZoomFactor = 1;
	// let's hide faces until we're done playing the sound effect
	for ( NSNumber* faceID in self.faceViews ) {
		FaceView* view = self.faceViews[faceID];
		view.alpha = 0;
	}
}

- (void) flash {
	if ( self.device.torchAvailable )
		self.device.torchMode = AVCaptureTorchModeOn;
}

- (void) startZoom:(NSNumber*)target {
	CGFloat zoomPower = log2(target.floatValue);
	[self.device rampToVideoZoomFactor:target.floatValue withRate:zoomPower / MEME_ZOOM_TIME];
}

- (IBAction) sliderChanged:(UISlider *)sender {
	if ( ! self.device.isRampingVideoZoom ) // ignore automatic updates
		self.device.videoZoomFactor = [self getZoomSliderValue];
}

- (void) clearLockedFace {
	self.lockedFaceID = nil;
	[self fadeInFaces];
	[self.device cancelVideoZoomRamp];
}

- (void) fadeInFaces {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3f];
	for (FaceView* f in self.faceViews.allValues) {
		f.alpha = 1;
		f.layer.borderColor = [[UIColor greenColor] CGColor];
	}
	[UIView commitAnimations];
}

- (CGFloat) getZoomSliderValue {
	// slightly fancy math to provide a linear feel to the slider
	return pow( [self getMaxZoom], self.slider.value );
}

- (void) setZoomSliderValue:(CGFloat)value {
	// inverse of above: log base max of value
	self.slider.value = log(value) / log([self getMaxZoom]);
}

- (CGFloat) getMaxZoom {
	return MIN( self.device.activeFormat.videoMaxZoomFactor, 6 );
}

@end

void displayErrorOnMainQueue(NSError *error, NSString *message)
{
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		UIAlertView* alert = [UIAlertView new];
		if(error) {
			alert.title = [NSString stringWithFormat:@"%@ (%zd)", message, error.code];
			alert.message = [error localizedDescription];
		} else {
			alert.title = message;
		}
		[alert addButtonWithTitle:@"Dismiss"];
		[alert show];
	});
}

