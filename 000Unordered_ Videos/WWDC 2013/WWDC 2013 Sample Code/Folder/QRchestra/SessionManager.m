/*
     File: SessionManager.m
 Abstract: Manages the video capture session
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

#import "SessionManager.h"

#import <CoreMedia/CMBufferQueue.h>
#import <CoreMedia/CMAudioClock.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/CGImageProperties.h>

#include <objc/runtime.h> // for objc_loadWeak() and objc_storeWeak()

@interface SessionManager () <AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate>
{
	__weak id <SessionManagerDelegate> _delegate; // __weak doesn't actually do anything under non-ARC
	dispatch_queue_t _delegateCallbackQueue;
	
	NSMutableArray *_previousSecondTimestamps;

	AVCaptureDeviceInput *_videoInput;
	AVCaptureSession *_captureSession;
	AVCaptureDevice *_videoDevice;
	AVCaptureConnection *_audioConnection;
	AVCaptureConnection *_videoConnection;
	BOOL _running;
	BOOL _startCaptureSessionOnEnteringForeground;
	id _applicationWillEnterForegroundNotificationObserver;
	
	dispatch_queue_t _sessionQueue;
	
	UIBackgroundTaskIdentifier _pipelineRunningTask;
}

@property (nonatomic,retain) AVCaptureMetadataOutput *metadataOutput;

@end

@implementation SessionManager

- (id)init
{
	if (self = [super init]) {
		_previousSecondTimestamps = [[NSMutableArray alloc] init];
		
		_sessionQueue = dispatch_queue_create( "com.apple.sample.sessionmanager.capture", DISPATCH_QUEUE_SERIAL );
		
		_pipelineRunningTask = UIBackgroundTaskInvalid;
	}
	return self;
}

#pragma mark Delegate

- (void)setDelegate:(id<SessionManagerDelegate>)delegate callbackQueue:(dispatch_queue_t)delegateCallbackQueue // delegate is weak referenced
{
	if ( delegate && ( delegateCallbackQueue == NULL ) )
		@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Caller must provide a delegateCallbackQueue" userInfo:nil];
	
	@synchronized( self ) {
//		objc_storeWeak( &_delegate, delegate ); // unnecessary under ARC, just assign to _delegate directly
		if ( delegateCallbackQueue != _delegateCallbackQueue  ) {
//			if ( delegateCallbackQueue )
//				dispatch_retain( delegateCallbackQueue );
//			if ( _delegateCallbackQueue )
//				dispatch_release( _delegateCallbackQueue );
			_delegateCallbackQueue = delegateCallbackQueue;
		}
	}
}

- (id<SessionManagerDelegate>)delegate
{
	id <SessionManagerDelegate> delegate = nil;
//	@synchronized( self ) {
//		delegate = objc_loadWeak( &_delegate ); // unnecessary under ARC, just assign delegate to _delegate directly
//	}
	return delegate;
}

#pragma mark Capture Session

- (void)startRunning
{
	dispatch_sync( _sessionQueue, ^{
		[self setupCaptureSession];
		
		[_captureSession startRunning];
		_running = YES;
		
		[[self metadataOutput] setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeQRCode, nil]];
	});
}

- (void)stopRunning
{
	dispatch_sync( _sessionQueue, ^{
		_running = NO;
		
		[_captureSession stopRunning];
		
		[self captureSessionDidStopRunning];
		
		[self teardownCaptureSession];
	});
}

- (void)setupCaptureSession
{
	if ( _captureSession )
		return;
	
	_captureSession = [[AVCaptureSession alloc] init];	

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureSessionNotification:) name:nil object:_captureSession];
	_applicationWillEnterForegroundNotificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication] queue:nil usingBlock:^(NSNotification *note) {
		[self applicationWillEnterForeground];
	}];
	
	/* Video */
	AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	_videoDevice = videoDevice;
	AVCaptureDeviceInput *videoIn = [[AVCaptureDeviceInput alloc] initWithDevice:videoDevice error:nil];
	_videoInput = videoIn;
	if ([_captureSession canAddInput:videoIn])
		[_captureSession addInput:videoIn];
		
	[self setMetadataOutput:[[AVCaptureMetadataOutput alloc] init]];
//	[[self metadataOutput] setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeQRCode, nil]];
	dispatch_queue_t metadataQueue = dispatch_queue_create("com.AVCam.metadata", NULL);
	[[self metadataOutput] setMetadataObjectsDelegate:self queue:metadataQueue];
//	dispatch_release(metadataQueue);
	
	if ([_captureSession canAddOutput:[self metadataOutput]]) {
		[_captureSession addOutput:[self metadataOutput]];
	}

	return;
}

- (void)teardownCaptureSession
{
	if ( _captureSession ) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:_captureSession];
		
		[[NSNotificationCenter defaultCenter] removeObserver:_applicationWillEnterForegroundNotificationObserver];
		_applicationWillEnterForegroundNotificationObserver = nil;
		
		_captureSession = nil;
	}
}

- (void)captureSessionNotification:(NSNotification *)notification
{
	dispatch_async( _sessionQueue, ^{
		if ( [[notification name] isEqualToString:AVCaptureSessionWasInterruptedNotification] ) {
			NSLog( @"session interrupted" );
			
			[self captureSessionDidStopRunning];
		}
		else if ( [[notification name] isEqualToString:AVCaptureSessionInterruptionEndedNotification] ) {
			NSLog( @"session interruption ended" );
		}
		else if ( [[notification name] isEqualToString:AVCaptureSessionRuntimeErrorNotification] ) {
			[self captureSessionDidStopRunning];
			
			NSError *error = [[notification userInfo] objectForKey:AVCaptureSessionErrorKey];
			if ( error.code == AVErrorDeviceIsNotAvailableInBackground ) {
				NSLog( @"device not available in background" );

				// Since we can't resume running while in the background we need to remember this for next time we come to the foreground
				if ( _running )
					_startCaptureSessionOnEnteringForeground = YES;
			}
			else if ( error.code == AVErrorMediaServicesWereReset ) {
				NSLog( @"media services were reset" );
			}
			else {
				[self handleNonRecoverableCaptureSessionRuntimeError:error];
			}
		}
		else if ( [[notification name] isEqualToString:AVCaptureSessionDidStartRunningNotification] ) {
			NSLog( @"session started running" );
		}
		else if ( [[notification name] isEqualToString:AVCaptureSessionDidStopRunningNotification] ) {
			NSLog( @"session stopped running" );
		}
	});
}

- (void)handleNonRecoverableCaptureSessionRuntimeError:(NSError *)error
{
	NSLog( @"fatal runtime error %@, code %i", error, (int)error.code );
	
	_running = NO;
	[self teardownCaptureSession];
	
	@synchronized( self ) {
		if ( [self delegate] ) {
			dispatch_async( _delegateCallbackQueue, ^{
				@autoreleasepool {
					[[self delegate] sessionManager:self didStopRunningWithError:error];
				}
			});
		}
	}
}

- (void)captureSessionDidStopRunning
{
	[self teardownVideoPipeline];
}

- (void)applicationWillEnterForeground
{
	NSLog( @"-[%@ %@] called", NSStringFromClass([self class]), NSStringFromSelector(_cmd) );
	
	dispatch_sync( _sessionQueue, ^{
		if ( _startCaptureSessionOnEnteringForeground ) {
			NSLog( @"-[%@ %@] manually restarting session", NSStringFromClass([self class]), NSStringFromSelector(_cmd) );
			
			_startCaptureSessionOnEnteringForeground = NO;
			if ( _running )
				[_captureSession startRunning];
		}
	});
}

#pragma mark Capture Pipeline

// synchronous, blocks until the pipeline is drained, don't call from within the pipeline
- (void)teardownVideoPipeline
{
	[self videoPipelineDidFinishRunning];
}

- (void)videoPipelineWillStartRunning
{
	NSLog( @"-[%@ %@] called", NSStringFromClass([self class]), NSStringFromSelector(_cmd) );
	
	_pipelineRunningTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
		NSLog( @"video capture pipeline background task expired" );
	}];
}

- (void)videoPipelineDidFinishRunning
{
	NSLog( @"-[%@ %@] called", NSStringFromClass([self class]), NSStringFromSelector(_cmd) );
	
//	NSAssert( _pipelineRunningTask != UIBackgroundTaskInvalid, @"should have a background task active when the video pipeline finishes running" );
	
	[[UIApplication sharedApplication] endBackgroundTask:_pipelineRunningTask];
	_pipelineRunningTask = UIBackgroundTaskInvalid;
}

#pragma mark Barcodes

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
	@synchronized(self) {
		self.barcodes = metadataObjects;
	}
}

#pragma mark Focus/Exposure

- (BOOL) supportsFocus
{
    AVCaptureDevice *device = [_videoInput device];
    
    return  [device isFocusModeSupported:AVCaptureFocusModeLocked] ||
    [device isFocusModeSupported:AVCaptureFocusModeAutoFocus] ||
    [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus];
}

- (AVCaptureFocusMode) focusMode
{
    return [[_videoInput device] focusMode];
}

- (void) setFocusMode:(AVCaptureFocusMode)focusMode
{
	// Explicitly disabling the check for whether we're already in this mode, to enable a workaround (single
	// tap on the preview) for the fact that auto-focus doesn't work when we launch into pano mode
	//	if (focusMode != [self focusMode]) {
	AVCaptureDevice *device = [_videoInput device];
	if ([device isFocusModeSupported:focusMode]) {
		NSError *error;
		if ([device lockForConfiguration:&error]) {
			[device setFocusMode:focusMode];
			[device unlockForConfiguration];
		} else {
//			id delegate = [self delegate];
//			if ([delegate respondsToSelector:@selector(acquiringDeviceLockFailedWithError:)]) {
//				[delegate acquiringDeviceLockFailedWithError:error];
//			}
		}
	}
	else {
//		NSLog(@"Focus mode %@ is not supported", [self stringFromFocusMode:focusMode]);
	}
	//	}
}

- (BOOL) supportsExpose
{
    AVCaptureDevice *device = [_videoInput device];
    
    return  [device isExposureModeSupported:AVCaptureExposureModeLocked] ||
    [device isExposureModeSupported:AVCaptureExposureModeAutoExpose] ||
    [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure];
}

- (AVCaptureExposureMode) exposureMode
{
    return [[_videoInput device] exposureMode];
}

- (void) setExposureMode:(AVCaptureExposureMode)exposureMode
{
	if (exposureMode != [self exposureMode]) {
		// AVCaptureExposureModeAutoExpose is not yet supported on any device
		if (exposureMode == AVCaptureExposureModeAutoExpose) {
			exposureMode = AVCaptureExposureModeContinuousAutoExposure;
		}
		
		AVCaptureDevice *device = [_videoInput device];
		if ([device isExposureModeSupported:exposureMode]) {
			NSError *error;
			if ([device lockForConfiguration:&error]) {
				[device setExposureMode:exposureMode];
				[device unlockForConfiguration];
			}		}
		else {
//			NSLog(@"Exposure mode %@ is not supported", [self stringFromFocusMode:exposureMode]);
		}
	}
}

// Perform an auto focus at the specified point. The focus mode will automatically change to locked once the auto focus is complete.
- (void) autoFocusAtPoint:(CGPoint)point
{
//    AVCaptureDevice *device = [[self videoInput] device];
    AVCaptureDevice *device = [_videoInput device];
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setFocusPointOfInterest:point];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            [device unlockForConfiguration];
        }
    }
}

// Switch to continuous auto focus mode at the specified point
- (void) continuousFocusAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = [_videoInput device];
	
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
		NSError *error;
		if ([device lockForConfiguration:&error]) {
			[device setFocusPointOfInterest:point];
			[device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
			[device unlockForConfiguration];
		}
	}
}

- (void) exposeAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = [_videoInput device];
    if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setExposurePointOfInterest:point];
            [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            [device unlockForConfiguration];
        }
    }
}

@end
