/*
     File: SendViewController.m
 Abstract: Manages application settings
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

#import "SendViewController.h"
//#import <AVFoundation/AVFoundation.h>

// each image is referred to as a "key", with its note being
// a value in either the mainBank, altBank, or nil.
static NSString *mainBank[] = { @"67", @"71", @"74", @"80" };
static NSString *altBank[] = { @"60", @"64", @"67", @"72" };
static NSUInteger currentBank[] = { 0, 0, 0, 0 }; // 0 is mainBank, 1 is altBank
const NSUInteger kMaxNumberOfBanks = 3;

@interface SendViewController ()

@property (nonatomic, retain) NSString *machineReadableCodeType;

@property (nonatomic, retain) IBOutlet UIImageView *keyImageView1;
@property (nonatomic, retain) IBOutlet UIImageView *keyImageView2;
@property (nonatomic, retain) IBOutlet UIImageView *keyImageView3;
@property (nonatomic, retain) IBOutlet UIImageView *keyImageView4;

@property (nonatomic, retain) IBOutlet UITapGestureRecognizer *tapGestureRecognizer1;
@property (nonatomic, retain) IBOutlet UITapGestureRecognizer *tapGestureRecognizer2;
@property (nonatomic, retain) IBOutlet UITapGestureRecognizer *tapGestureRecognizer3;
@property (nonatomic, retain) IBOutlet UITapGestureRecognizer *tapGestureRecognizer4;

- (IBAction)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer;

- (IBAction)done:(id)sender;

@end

@implementation SendViewController
{
	NSArray *keyImageViews; // for easier iteration
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];

//	self.machineReadableCodeType = AVMetadataObjectTypeQRCode;
	
//	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
//	[singleTap setDelegate:self];
//	[singleTap setNumberOfTapsRequired:1];
//	[self.keyImageView1 addGestureRecognizer:singleTap];
	
	keyImageViews = [[NSArray alloc] initWithObjects:self.keyImageView1,
					 self.keyImageView2,
					 self.keyImageView3,
					 self.keyImageView4,
					 nil];
	
	// Scale using a "nearest neighbor" algorithm on the image layer
	for ( UIImageView *imageView in keyImageViews ) {
		[[imageView layer] setMagnificationFilter:kCAFilterNearest];
	}
	
	[self setNotesToDefaults];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate sendViewControllerDidFinish:self];
}

- (void)setNotesToDefaults
{
	for ( NSUInteger index = 0; index < [keyImageViews count]; index++ ) {
		((UIImageView *)[keyImageViews objectAtIndex:index]).image = [self machineReadableCodeFromMessage:mainBank[index]];
	}
}

- (UIImage *)machineReadableCodeFromMessage:(NSString *)message {
    CIFilter *mrcFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
	NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
    [mrcFilter setValue:messageData forKey:@"inputMessage"];
    
	CIImage *barcodeCIImage = [mrcFilter valueForKey:@"outputImage"];
	CGRect extent = [barcodeCIImage extent];
	
	CGImageRef barcodeCGImage = [getCIContext() createCGImage:barcodeCIImage fromRect:extent];
	UIImage *image = [UIImage imageWithCGImage:barcodeCGImage];
	CGImageRelease(barcodeCGImage);
	return image;
}

// Generate a CIContext into which we can draw the MRC images using the CIFilters.
static CIContext *getCIContext() {
    static CIContext *ciContext = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
        NSDictionary *ciOptions = [[NSDictionary alloc] initWithObjectsAndKeys:(__bridge id)colorspace, kCIContextOutputColorSpace, nil];
        ciContext = [CIContext contextWithOptions:ciOptions];
        CGColorSpaceRelease(colorspace);
    });
    return ciContext;
}

// When a tap is received, determine which key was pressed and toggle
// through the posssible notes in either the main bank, the alt bank, or nothing
- (void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
	if ( [tapGestureRecognizer.view isKindOfClass:[UIImageView class]] ) {
		UIImageView *keyImageView = (UIImageView *)tapGestureRecognizer.view;
		NSUInteger keyIndex = [keyImageViews indexOfObject:keyImageView];
		
		if ( keyIndex == NSNotFound ) {
			return;
		}
		
		currentBank[keyIndex]++;
		if ( currentBank[keyIndex] == kMaxNumberOfBanks ) {
			currentBank[keyIndex] = 0;
		}
		
		if ( currentBank[keyIndex] == 0 ) {
			keyImageView.image = [self machineReadableCodeFromMessage:mainBank[keyIndex]];
		}
		else if ( currentBank[keyIndex] == 1 ) {
			keyImageView.image = [self machineReadableCodeFromMessage:altBank[keyIndex]];
		}
		else if ( currentBank[keyIndex] == 2 ) {
			keyImageView.image = nil;
		}
		
		// slide in the new note value
		[CATransaction begin];
		CATransition *transition = [CATransition animation];
		transition.duration = .3f;
		transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
		transition.type = kCATransitionReveal;
		transition.subtype = kCATransitionFromBottom;
		[keyImageView.layer addAnimation:transition forKey:nil];		
		[CATransaction commit];
	}
}

#pragma mark - UIGestureRecognizerDelegate methods


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return YES; // allow simultaneous recognition of tap gesture recognizers
}

@end
