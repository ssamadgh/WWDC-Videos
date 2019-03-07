/*
     File: ReceiveViewController.m
 Abstract: Controls QR preview view
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

#import "ReceiveViewController.h"
#import "SessionManager.h"
#import "Synth.h"

CGMutablePathRef createPathForPoints(NSArray* points)
{
	CGMutablePathRef path = CGPathCreateMutable();
	CGPoint point;
	
	if ([points count] > 0) {
		CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)[points objectAtIndex:0], &point);
		CGPathMoveToPoint(path, nil, point.x, point.y);
		
		int i = 1;
		while (i < [points count]) {
			CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)[points objectAtIndex:i], &point);
			CGPathAddLineToPoint(path, nil, point.x, point.y);
			i++;
		}
		
		CGPathCloseSubpath(path);
	}
	
	return path;
}

@interface ReceiveViewController () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIPopoverController *sendPopoverController;

@property (assign) int barcodeIndex;

- (IBAction)showInfo:(id)sender;
- (IBAction)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer;

@property (strong, nonatomic) IBOutlet UIView *previewView;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, retain) CALayer *barcodeTargetLayer;
@property (strong, nonatomic) SessionManager *sessionManager;
@property (strong, nonatomic) Synth *synth;
@property (strong, nonatomic) NSTimer *stepTimer;
@property (nonatomic, retain) NSTimer *barcodeTimer;

@end

@implementation ReceiveViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

//	self.previewView.bounds = [[UIScreen mainScreen] bounds];

    self.sessionManager = [[SessionManager alloc] init];
	[self.sessionManager startRunning];
		
	AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.sessionManager.captureSession];
	[previewLayer setFrame:self.previewView.bounds];
	[previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	if ([[previewLayer connection] isVideoOrientationSupported]) {
		[[previewLayer connection] setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
	}
	[self.previewView.layer addSublayer:previewLayer];
	[self.previewView.layer setMasksToBounds:YES];
	[self setPreviewLayer:previewLayer];

	// Configure barcode overlay
	CALayer* barcodeTargetLayer = [[CALayer alloc] init];
	CGRect r = self.view.layer.bounds;
	barcodeTargetLayer.frame = r;
	self.barcodeTargetLayer = barcodeTargetLayer;
	[self.view.layer addSublayer:self.barcodeTargetLayer];
	
	self.synth = [[Synth alloc] init];
	[self.synth loadPreset:self];
	
	self.stepTimer = [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(step) userInfo:nil repeats:YES];
}

// A single-tap triggers a focus at the tap point, unless the tap was on a bar code
- (void)handleTap:(UIGestureRecognizer *)recognizer;
{
	CGPoint tapPoint = [recognizer locationInView:self.previewView];
	[self focusAtPoint:tapPoint];
	[self exposeAtPoint:tapPoint];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Send View Controller

- (void)sendViewControllerDidFinish:(SendViewController *)controller
{
        [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showInfo:(id)sender
{
	SendViewController *controller = [[SendViewController alloc] initWithNibName:@"SendViewController" bundle:nil];
	controller.delegate = self;
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Focus/Exposure

- (void)focusAtPoint:(CGPoint)point
{
//    if ([[[self.sessionManager videoInput] device] isFocusPointOfInterestSupported]) {
//		AVCaptureVideoPreviewLayer *videoPreviewLayer = self captureVideoPreviewLayer];
		CGPoint convertedFocusPoint = [self.previewLayer captureDevicePointOfInterestForPoint:point];
        [self.sessionManager autoFocusAtPoint:convertedFocusPoint];
        // Now use video preview layer to convert back the other way, so we get additional API test coverage.
//		point = [videoPreviewLayer pointForCaptureDevicePointOfInterest:convertedFocusPoint];
//        [self drawFocusBoxAtPointOfInterest:point];
//    }
}

- (void)exposeAtPoint:(CGPoint)point
{
//    if ([[[self.sessionManager videoInput] device] isExposurePointOfInterestSupported]) {
//		AVCaptureVideoPreviewLayer *videoPreviewLayer = [self captureVideoPreviewLayer];
		CGPoint convertedExposurePoint = [self.previewLayer captureDevicePointOfInterestForPoint:point];
		[self.sessionManager exposeAtPoint:convertedExposurePoint];
        // Now use video preview layer to convert back the other way, so we get additional API test coverage.
//		point = [videoPreviewLayer pointForCaptureDevicePointOfInterest:convertedExposurePoint];
//        [self drawExposeBoxAtPointOfInterest:point];
//    }
}

- (void)resetFocusAndExposure
{
//	AVCaptureDevice *videoDevice = self.sessionManager.videoInput.device;
//	if ( videoDevice.isAutoFocusRangeRestrictionSupported ) {
//		[videoDevice lockForConfiguration:NULL];
//		[videoDevice setAutoFocusRangeRestriction:AVCaptureAutoFocusRangeRestrictionNone];
//		[videoDevice unlockForConfiguration];
//	}
	
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    [self.sessionManager autoFocusAtPoint:pointOfInterest];
    [self.sessionManager exposeAtPoint:pointOfInterest];
    
//    CGRect bounds = [[self videoPreviewView] bounds];
//    CGPoint screenCenter = CGPointMake(bounds.size.width / 2.f, bounds.size.height / 2.f);
    
//    [self drawFocusBoxAtPointOfInterest:screenCenter];
//    [self drawExposeBoxAtPointOfInterest:screenCenter];
    
    [self.sessionManager setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
}

#pragma mark - Barcode Sequencer

- (void)step
{
	if ( [self.sessionManager.barcodes count] < 1 )
		return;
	
	@synchronized(self.sessionManager) {
		self.barcodeIndex = (self.barcodeIndex + 1) % [self.sessionManager.barcodes count];
		AVMetadataMachineReadableCodeObject *barcode = [self.sessionManager.barcodes objectAtIndex:self.barcodeIndex];
		
		// Draw overlay
		[self.barcodeTimer invalidate];
		self.barcodeTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(removeDetectedBarcodeUI) userInfo:nil repeats:NO];
		AVMetadataMachineReadableCodeObject *transformedBarcode = (AVMetadataMachineReadableCodeObject*)[self.previewLayer transformedMetadataObjectForMetadataObject:barcode];
		CGPathRef barcodeBoundary = createPathForPoints(transformedBarcode.corners);

		[CATransaction begin];
		[CATransaction setDisableActions:YES];
		[self removeDetectedBarcodeUI];
		[self.barcodeTargetLayer addSublayer:[self barcodeOverlayLayerForPath:barcodeBoundary withColor:[[self class ] overlayColor]]];
		[CATransaction commit];
		CFRelease(barcodeBoundary);
		
		// Play note
		NSString *noteString = barcode.stringValue;
		int note = [noteString intValue];
		note -= 24; // Transpose down for demo
		if (note >= 0 && note <= 127) {
			[self.synth startPlayNoteNumber:note];
			usleep(500);
			[self.synth stopPlayNoteNumber:note];
		}
	}
}

- (void)removeDetectedBarcodeUI
{
	[self removeAllSublayersFromLayer:self.barcodeTargetLayer];
}

- (CAShapeLayer*)barcodeOverlayLayerForPath:(CGPathRef)path withColor:(UIColor*)color
{
	CAShapeLayer *maskLayer = [CAShapeLayer layer];
	
	[maskLayer setPath:path];
	[maskLayer setLineJoin:kCALineJoinRound];
	[maskLayer setLineWidth:2.0];
	[maskLayer setStrokeColor:[color CGColor]];
	[maskLayer setFillColor:[[color colorWithAlphaComponent:0.20] CGColor]];
	
	return maskLayer;
}

- (void)removeAllSublayersFromLayer:(CALayer *)layer
{
	if (layer) {
		NSArray* sublayers = [[layer sublayers] copy];
		for( CALayer* l in sublayers ) {
			[l removeFromSuperlayer];
		}
	}
}

+ (UIColor *)overlayColor
{
    static UIColor* color = nil;

    if (color == nil) {
        color = [UIColor greenColor];
    }
	
    return color;
}

@end
