/*
     File: TTTNewMessageViewController.m
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

#import "TTTNewMessageViewController.h"

#import "TTTMessage.h"
#import "TTTMessageServer.h"

@implementation TTTNewMessageViewController {
    UITextView *_messageTextView;
}

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = NSLocalizedString(@"New Message", @"New Message");
        self.view.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [self init];
    return self;
}

- (void)loadView
{
    UIView *baseView = [[UIView alloc] init];
    baseView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.15];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(-100.0, -50.0, 240.0, 120.0)];
    view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"barBackground"]];
    [baseView addSubview:view];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [cancelButton setTitle:NSLocalizedString(@"Cancel", @"Cancel") forState:UIControlStateNormal];
    [view addSubview:cancelButton];
    
    UIButton *postButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [postButton addTarget:self action:@selector(post) forControlEvents:UIControlEventTouchUpInside];
    postButton.translatesAutoresizingMaskIntoConstraints = NO;
    [postButton setTitle:NSLocalizedString(@"Post", @"Post") forState:UIControlStateNormal];
    [view addSubview:postButton];
    
    _messageTextView = [[UITextView alloc] init];
    _messageTextView.backgroundColor = [UIColor clearColor];
    _messageTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:_messageTextView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(postButton, cancelButton, _messageTextView);
    
    [baseView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_messageTextView]-8-|" options:0 metrics:nil views:views]];
    [baseView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[cancelButton]->=20-[postButton]-8-|" options:0 metrics:nil views:views]];
    [baseView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_messageTextView]-[cancelButton]-8-|" options:0 metrics:nil views:views]];
    [baseView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_messageTextView]-[postButton]-8-|" options:0 metrics:nil views:views]];
    
    self.view = baseView;
}

static UIWindow *currentMessageWindow = nil;
static UIWindow *currentMessageSourceWindow = nil;

- (void)presentFromViewController:(UIViewController *)controller
{
    UIView *sourceView = controller.view;
    currentMessageSourceWindow = sourceView.window;
    
    currentMessageWindow = [[UIWindow alloc] initWithFrame:currentMessageSourceWindow.frame];
    currentMessageWindow.tintColor = currentMessageSourceWindow.tintColor;
    currentMessageWindow.rootViewController = self;
    [currentMessageWindow makeKeyAndVisible];
    [_messageTextView becomeFirstResponder];
    self.view.alpha = 0.0;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 1.0;
        currentMessageSourceWindow.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
    }];
}

- (void)close
{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 0.0;
        currentMessageSourceWindow.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
    } completion:^(BOOL finished) {
        currentMessageWindow = nil;
    }];
}

- (void)post
{
    TTTMessage *message = [[TTTMessage alloc] init];
    message.icon = self.profile.icon;
    message.text = _messageTextView.text;
    [[TTTMessageServer sharedMessageServer] addMessage:message];
    
    [self close];
}

@end
