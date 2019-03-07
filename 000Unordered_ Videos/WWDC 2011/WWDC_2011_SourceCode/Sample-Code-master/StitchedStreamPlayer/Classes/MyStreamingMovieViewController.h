/*
    File: MyStreamingMovieViewController.h
Abstract: 
A UIViewController controller subclass that loads the SecondView nib file that contains its view.
 Contains an action method that is called when the Play Movie button is pressed to play the movie.
 Provides a text edit control for the user to enter a movie URL.
 Manages a collection of transport control UI that allows the user to play/pause and seek.

 Version: 1.4

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

Copyright (C) 2011 Apple Inc. All Rights Reserved.

*/

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>


@class AVPlayer;
@class AVPlayerItem;
@class MyPlayerLayerView;

@interface MyStreamingMovieViewController : UIViewController <UITextFieldDelegate> {

    NSURL *movieURL;
	AVPlayer *player;
    AVPlayerItem *playerItem;
	MyPlayerLayerView *playerLayerView;
    
    UITextField	*movieURLTextField;
    
	UISlider *movieTimeControl;
	BOOL isSeeking;
	BOOL seekToZeroBeforePlay;
	float restoreAfterScrubbingRate;
    
    id timeObserver;	
    
    UIToolbar *toolBar;
    UIBarButtonItem *playButton;
    UIBarButtonItem *stopButton;
    
    UILabel *isPlayingAdText;
    
	NSArray *adList;

}

@property (retain) IBOutlet UIToolbar *toolBar;
@property (retain) IBOutlet UIBarButtonItem *playButton;
@property (retain) IBOutlet UIBarButtonItem *stopButton;

@property (retain) IBOutlet UITextField *movieURLTextField;
@property (retain) IBOutlet UISlider *movieTimeControl;
@property (retain) IBOutlet MyPlayerLayerView *playerLayerView;
@property (retain) AVPlayer *player;
@property (retain) AVPlayerItem *playerItem;
@property (retain) IBOutlet UILabel *isPlayingAdText;

- (IBAction)loadMovieButtonPressed:(id)sender;

- (IBAction)beginScrubbing:(id)sender;
- (IBAction)scrub:(id)sender;
- (IBAction)endScrubbing:(id)sender;

- (IBAction)play:(id)sender;
- (IBAction)pause:(id)sender;

@end
