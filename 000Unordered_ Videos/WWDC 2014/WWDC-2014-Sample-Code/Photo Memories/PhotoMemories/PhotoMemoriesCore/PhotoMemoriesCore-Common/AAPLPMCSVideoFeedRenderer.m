//
//  AAPLPMCSVideoFeedRenderer.m
//  PhotoMemoriesCore
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "AAPLPMCSVideoFeedRenderer.h"

#import <QuartzCore/CoreAnimation.h>

#if TARGET_OS_IPHONE
#import <CoreImage/CoreImage.h>
#elif TARGET_OS_MAC
#import <QuartzCore/CoreImage.h>
#endif

/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  AAPLPMCSVideoFeedRenderer is a cross-platform object responsible for rendering the contents
  of a user's front-facing video camera as a sublayer of a target CALayer. Moreover, it offers
  the functionality of taking a snapshot, and returns a cross-platform image asynchronously
  when requested.
  
 */
@implementation AAPLPMCSVideoFeedRenderer
{
    AVCaptureSession *_captureSession;
    AVCaptureVideoPreviewLayer *_previewLayer;
    AVCaptureStillImageOutput *_stillImageOutput;
    
    CALayer *_targetLayer;
    
    BOOL _isConfigured;
}

- (instancetype) initWithTargetCALayer:(CALayer*)targetLayer
{
    self = [super init];
    
    if (self != nil) {
        _targetLayer = targetLayer;
    }
    
    return self;
}

#pragma mark - Starting & Stopping

- (void) configure
{
    if (!_isConfigured) {
        
        if (_targetLayer == nil) {
            NSLog(@"We want a target layer to render into before we continue. Bailing out.");
        }
        
        _captureSession = [[AVCaptureSession alloc] init];
        _captureSession.sessionPreset = AVCaptureSessionPresetMedium;
        
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
        _previewLayer.frame = _targetLayer.frame;
        [_targetLayer addSublayer:_previewLayer];
        
        NSError *error = nil;
        AVCaptureDevice *device = [self p_idealCaptureDevice];
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        
        if (error != nil) {
            NSLog(@"Encountered an error while initializing the input: %@", input);
        }
        else {
            [_captureSession addInput:input];
            
            _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
            NSDictionary *outputSettings = @{ AVVideoCodecKey : AVVideoCodecJPEG};
            [_stillImageOutput setOutputSettings:outputSettings];
            
            [_captureSession addOutput:_stillImageOutput];
            
            AVCaptureVideoDataOutput * dataOutput = [[AVCaptureVideoDataOutput alloc] init];
            [dataOutput setAlwaysDiscardsLateVideoFrames:YES];
            [dataOutput setVideoSettings:@{ (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)}];
            
            [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
            
            [_captureSession addOutput:dataOutput];
            
            [_captureSession startRunning];
        }
        
        _isConfigured = YES;
    }
}

- (AVCaptureDevice *) p_idealCaptureDevice
{
    AVCaptureDevice *deviceToUse = nil;
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionFront) {
            deviceToUse = device;
        }
    }
    
    // If we can't find a camera that identifies itself as front-facing, gracefully degrade to the default device.
    if (deviceToUse == nil) {
        deviceToUse = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    return deviceToUse;
}

- (void) beginRenderingToLayer
{
    if (!_isConfigured) {
        [self configure];
    }
    
    [_captureSession startRunning];
}

- (void) stopRenderingToLayer
{
    [_captureSession stopRunning];
}

- (void) asyncCaptureImageWithCompletionHandler:(void (^)(AAPLPMCSImage*))handler
{
    AVCaptureConnection *videoConnection = nil;
    
    for (AVCaptureConnection *connection in _stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        
        if (videoConnection != nil) {
            break;
        }
    }
    
    if (videoConnection.isVideoOrientationSupported) {
        [videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    }
    
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        AAPLPMCSImage *cameraImage = [[AAPLPMCSImage alloc] initWithData:imageData];
        
        handler(cameraImage);
    }];
}

@end
