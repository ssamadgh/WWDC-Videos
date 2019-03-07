//
//  AAPLPMMacAppDelegate.m
//  PhotoMemories
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "AAPLPMMacAppDelegate.h"

#import <PhotoMemoriesCore/AAPLPMCSImage.h>
#import <PhotoMemoriesCore/AAPLPMCSVideoFeedRenderer.h>

/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  PMMacAppDelegate is responsible for handling user interactions (i.e. pressing the shutter button),
  setting up the video feed renderer and saving the image from the video renderer in a Mac-specific way.
  
 */
@implementation AAPLPMMacAppDelegate
{
    AAPLPMCSVideoFeedRenderer *_videoRenderer;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self.cameraFeedView setWantsLayer:YES];
    
    CALayer *cameraFeedLayer = self.cameraFeedView.layer;
    cameraFeedLayer.backgroundColor = [NSColor blackColor].CGColor;
    
    _videoRenderer = [[AAPLPMCSVideoFeedRenderer alloc] initWithTargetCALayer:cameraFeedLayer];
    [_videoRenderer beginRenderingToLayer];
}

- (IBAction)savePhoto:(id)sender
{
    [_videoRenderer asyncCaptureImageWithCompletionHandler:^(AAPLPMCSImage *image) {
        CGImageRef imageRef = [image CGImage];
        
        NSBitmapImageRep* rep = [[NSBitmapImageRep alloc] initWithCGImage:imageRef];
        NSData *jpegData = [rep representationUsingType:NSJPEGFileType properties:nil];
        
        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"EEEE-MMMM-d-YYYY-h-mm-a"];
        NSString *dateString = [dateFormat stringFromDate:today];
        
        NSString *pathString = [NSString stringWithFormat:@"%@/Pictures/%@.jpg", NSHomeDirectory(), dateString];
        
        NSError *fileWriteError = nil;
        BOOL success = [jpegData writeToFile:pathString options:NSDataWritingAtomic error:&fileWriteError];
        
        // NSAlerts should be triggered on the main thread.
        dispatch_async(dispatch_get_main_queue(), ^{
            NSAlert *alert;
            
            if (!success) {
                alert = [NSAlert alertWithError:fileWriteError];
                NSLog(@"failed to save image: %@", fileWriteError);
            }
            else {
                alert = [[NSAlert alloc] init];
                alert.messageText = [NSString stringWithFormat:@"Photo %@.jpg saved successfully to ~/Pictures.", dateString, nil];
            }
            
            [alert addButtonWithTitle:@"OK"];
            [alert runModal];
        });
    }];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

@end
