/*
     File: PlayListItem.m
 Abstract: The model class for each row in PlayListViewController's table view. 
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

#import "PlayListItem.h"

@interface AVAsset (AsyncConvenience)
- (void)generateThumbnailInBackgroundAndNotifyOnQueue:(dispatch_queue_t) queue withBlock:(void (^)(CGImageRef thumbnail))block;
- (void)generateTitleInBackgroundAndNotifyOnQueue:(dispatch_queue_t) queue withBlock:(void (^)(NSString* title))block;
@end

@implementation AVAsset (ThumbnailConvenience)
- (void)generateThumbnailInBackgroundAndNotifyOnQueue:(dispatch_queue_t) queue withBlock:(void (^)(CGImageRef thumbnail))block
{
	AVAssetImageGenerator* generator = [[AVAssetImageGenerator allocWithZone:NULL] initWithAsset:self];
	
	[generator setAppliesPreferredTrackTransform:YES];
	[generator setMaximumSize:CGSizeMake(256, 256)];
	
	dispatch_retain(queue);
	
	[generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:CMTimeMake(3, 1)]] completionHandler:
	 ^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error)
	 {
		 CGImageRetain(image);
		 
		 dispatch_async(queue,
						^{
							block(image);
							
							CGImageRelease(image);
							dispatch_release(queue);
						});
		 
		 [generator release];
	 }];
}

- (void)generateTitleInBackgroundAndNotifyOnQueue:(dispatch_queue_t) queue withBlock:(void (^)(NSString* title))block
{
	dispatch_retain(queue);
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
	   ^{
		   NSString* title = nil;
		   
		   for (AVMetadataItem* metadata in [self commonMetadata])
		   {
			   if ([[metadata commonKey] isEqualToString:AVMetadataCommonKeyTitle])
			   {
				   title = [metadata stringValue];
				   break;
			   }
		   }
		   
		   dispatch_async(queue, 
						  ^{
							  block(title);
							  dispatch_release(queue);
						  });
	   });
}
@end

@implementation PlayListItem

@synthesize originalAsset=_originalAsset;

+ (NSString *)titleStringForURL:(NSURL *)url
{
	NSString *temp = [[url lastPathComponent] stringByDeletingPathExtension];
	return [temp stringByReplacingOccurrencesOfString:@"SloPoke_" withString:@""];
}

- (id)initWithURL:(NSURL*)URL
{
	if (!URL)
		return [super init];
	
	if ((self = [super init])) {
		_url = [URL copy];
		_title = [[PlayListItem titleStringForURL:_url] copy];
		_preferredAudioTimePitchAlgorithm = [AVAudioTimePitchAlgorithmSpectral copy];
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
		   ^{
			   AVAsset *asset = [[AVURLAsset alloc] initWithURL:_url options:nil];
			   
			   if (asset) {
				   [asset generateThumbnailInBackgroundAndNotifyOnQueue:dispatch_get_main_queue() withBlock:
					^(CGImageRef image) {
						[_thumbnail release];
						_thumbnail = [[UIImage alloc] initWithCGImage:image];
						[[NSNotificationCenter defaultCenter] postNotificationName:PlayListItemDidChangeNotification object:self];
					}];
				   
				   [asset generateTitleInBackgroundAndNotifyOnQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) withBlock:^(NSString* title) {
						if (!title)
							[URL getResourceValue:&title forKey:NSURLLocalizedNameKey error:NULL];
						
						if (title)
						{
							dispatch_async(dispatch_get_main_queue(),
							   ^{
								   [_title release];
								   _title = [[PlayListItem titleStringForURL:_url] copy];
								   
								   [[NSNotificationCenter defaultCenter] postNotificationName:PlayListItemDidChangeNotification object:self];
							   });
						}
					}];
			   }
			   
			   [asset release];
		   });
	}
	
	return self;
}

- (void)dealloc
{
	[_url release];
	[_originalAsset release];
	[_editedAsset release];
	[_title release];
	[_thumbnail release];
	[_preferredAudioTimePitchAlgorithm release];
	[super dealloc];
}

- (AVAsset *)originalAsset
{
	if ( !_originalAsset ) {
		_originalAsset = [[AVAsset assetWithURL:_url] retain];
	}
	return [[_originalAsset retain] autorelease];
}

- (AVAsset *)editedAsset
{
	AVAsset *returnValue = [[_editedAsset retain] autorelease];
	if ( !returnValue ) {
		returnValue = self.originalAsset;
	}
	return returnValue;
}

@end

NSString* const PlayListItemDidChangeNotification = @"PlayListItemDidChangeNotification";
