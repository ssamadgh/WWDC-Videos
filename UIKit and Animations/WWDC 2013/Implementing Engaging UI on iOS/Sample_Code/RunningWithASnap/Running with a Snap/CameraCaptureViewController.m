/*
     File: CameraCaptureViewController.m
 Abstract: 
 
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

#import "CameraCaptureViewController.h"
#import "Run.h"
#import "PreviousRunPickerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface CameraCaptureViewController () <UIAlertViewDelegate>
{
    SystemSoundID lowPowerAlertID;
}
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillOutput;
@property (nonatomic, strong) NSTimer *captureTimer;
@end

@implementation CameraCaptureViewController

- (void)dealloc {
    AudioServicesDisposeSystemSoundID(lowPowerAlertID);
}

- (void)_playAlertSound {
    if (!lowPowerAlertID) {
        NSURL *fileURL = nil;
//        fileURL = [[NSBundle mainBundle] URLForResource:@"<YOUR_ALERT_SOUND>" withExtension:@"wav"];
        if (!fileURL) {
            NSLog(@"Look at -[CameraCaptureViewController _playAlertSound] and provide your own audio file to play when power gets low.");
            return;
        }
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &lowPowerAlertID);
    }
    
    if (lowPowerAlertID) {
        AudioServicesPlayAlertSound(lowPowerAlertID);
    }
}

- (void)_checkBatteryLevel {
    if ([UIDevice currentDevice].batteryMonitoringEnabled) {
        CGFloat batteryLevel = [[UIDevice currentDevice] batteryLevel];
        if (batteryLevel < 0.05) {
            [self _playAlertSound];
        }
    }
}

- (BOOL)_setupCameraStream:(NSError **)error {
    AVCaptureDevice *backCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!backCamera) {
        if (error) {
            *error = [NSError errorWithDomain:@"RunningWithASnap" code:1 userInfo:@{NSLocalizedDescriptionKey : @"Could not find a back camera and one is required."}];
        }
        return NO;
    }
    
    NSError *localError = nil;
    if ([backCamera lockForConfiguration:&localError]) {
        backCamera.focusMode = AVCaptureFocusModeAutoFocus;
// This appears to be bad... pictures are always blurry.
//        backCamera.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        backCamera.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        backCamera.flashMode = AVCaptureFlashModeOff;
        backCamera.torchMode = AVCaptureTorchModeOff;
        backCamera.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
        
        [backCamera unlockForConfiguration];
    }
    else {
        if (error) {
            *error = [NSError errorWithDomain:@"RunningWithASnap" code:2 userInfo:@{NSLocalizedDescriptionKey : @"Failed to lock camera for configuration."}];
        }
        return NO;
    }
    
    AVCaptureDeviceInput *inputCapture = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&localError];
    if (!inputCapture) {
        if (error) {
            *error = localError;
        }
        return NO;
    }
    
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
//    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    if (![self.session canAddInput:inputCapture]) {
        if (error) {
            *error = [NSError errorWithDomain:@"RunningWithASnap" code:3 userInfo:@{NSLocalizedDescriptionKey : @"Unable to add back camera as input to capture session."}];
        }
        return NO;
    }
    [self.session addInput:inputCapture];
    
    self.stillOutput = [[AVCaptureStillImageOutput alloc] init];

    if (![self.session canAddOutput:self.stillOutput]) {
        if (error) {
            *error = [NSError errorWithDomain:@"RunningWithASnap" code:4 userInfo:@{NSLocalizedDescriptionKey : @"Unable to add still image output to capture session."}];
        }
        return NO;
    }
    [self.session addOutput:self.stillOutput];

    AVCaptureConnection *conn = [self.stillOutput connectionWithMediaType:AVMediaTypeVideo];
    conn.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSError *error = nil;
    if (![self _setupCameraStream:&error]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Stream setup error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alert show];
        return;
    }

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
    tap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tap];
    
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.previewLayer.bounds = self.view.bounds;
    self.previewLayer.position = self.view.center;
    [self.videoHostView.layer addSublayer:self.previewLayer];
    
    AVCaptureConnection *previewConnection = [self.previewLayer connection];
    previewConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    [self.session startRunning];
}

- (IBAction)toggleCapture:(id)sender {
    if (self.captureTimer) {
        [UIDevice currentDevice].batteryMonitoringEnabled = NO;
        
        [self.captureTimer invalidate]; self.captureTimer = nil;
        [(UIButton *)sender setTitle:@"Start Capture" forState:UIControlStateNormal];
    }
    else {
        // Start battery monitoring
        [UIDevice currentDevice].batteryMonitoringEnabled = YES;
        
        self.captureTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(attemptStillCapture:) userInfo:nil repeats:YES];
        [(UIButton *)sender setTitle:@"Stop Capture" forState:UIControlStateNormal];
    }
}

- (IBAction)togglePreview:(id)sender {
    AVCaptureConnection *previewConnection = [self.previewLayer connection];
    previewConnection.enabled = !previewConnection.enabled;

    if (previewConnection.enabled) {
        [(UIButton *)sender setTitle:@"Hide Preview" forState:UIControlStateNormal];
    }
    else {
        [(UIButton *)sender setTitle:@"Show Preview" forState:UIControlStateNormal];
    }
}

- (void)attemptStillCapture:(NSTimer *)timer {
    [self _checkBatteryLevel];
    
    AVCaptureConnection *connection = [self.stillOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!connection) {
        NSLog(@"failed to get connection from stillOutput");
        [self _playAlertSound];
        return;
    }
    
    [self.stillOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (error) {
            NSLog(@"captureStillImageAsynchronouslyFromConnection error: %@", error);
            [self _playAlertSound];
        }
        else {
            NSData *imgData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            if (self.run) {
                [self.run savePhotoData:imgData];
            }
        }
    }];
}

- (IBAction)finishCapture:(id)sender {
    if (self.captureTimer) {
        [self.session stopRunning];
        [self.captureTimer invalidate]; self.captureTimer = nil;
        
        NSArray *newViewControllers = @[[self.navigationController.viewControllers objectAtIndex:0], [[PreviousRunPickerViewController alloc] initWithNibName:nil bundle:nil]];
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        [self.navigationController setViewControllers:newViewControllers animated:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)doubleTapped:(UITapGestureRecognizer *)tapGesture {
    [self finishCapture:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self finishCapture:nil];
}

@end
