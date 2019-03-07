/*
     File: TKDDemo.m
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

#import "TKDDemo.h"

static NSArray *_allDemos;

@interface TKDDemo () {
    NSAttributedString *_attributedText;
}

@property (nonatomic, assign, getter=shouldStripRichFormatting) BOOL stripRichFormatting;
@end

@implementation TKDDemo
+ (NSArray *)allDemos
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *demos = [NSMutableArray array];

        TKDDemo *currentDemo = nil;
        TKDDemoPerson *currentDemoPerson = nil;

        currentDemo = [[TKDDemo alloc] init];
        currentDemo.title = @"Basic Interaction";
        currentDemo.textStoragePath = @"Basic Interaction.rtf";
        currentDemo.viewControllerIdentifier = @"TKDBasicInteractionViewController";
        [demos addObject:currentDemo];
        currentDemo = nil;

        currentDemo = [[TKDDemo alloc] init];
        currentDemo.title = @"Exclusion Paths";
        currentDemo.textStoragePath = @"Exclusion Paths.rtf";
        currentDemo.viewControllerIdentifier = @"TKDExclusionPathsViewController";
        [demos addObject:currentDemo];
        currentDemo = nil;

        currentDemo = [[TKDDemo alloc] init];
        currentDemo.title = @"View Layout";
        currentDemo.textStoragePath = @"View Layout.rtf";
        currentDemo.viewControllerIdentifier = @"TKDPersonViewController";

        currentDemoPerson = [[TKDDemoPerson alloc] init];
        currentDemoPerson.profileImage = [UIImage imageNamed:@"JohnnyProfilePic"];
        currentDemoPerson.name = @"Johhny Appleseed";
        currentDemoPerson.shortDescription = @"In another moment down went Alice after it, never once considering how in the world she was to get out again.";

        currentDemo.person = currentDemoPerson;
        currentDemoPerson = nil;
        
        [demos addObject:currentDemo];
        currentDemo = nil;

        currentDemo = [[TKDDemo alloc] init];
        currentDemo.title = @"Dynamic Coloring";
        currentDemo.textStoragePath = @"Dynamic Coloring.rtf";
        currentDemo.viewControllerIdentifier = @"TKDDynamicColoringViewController";
        [demos addObject:currentDemo];
        currentDemo = nil;

        NSUInteger totalDemos = 20;
        NSUInteger extraDemosNeeded = totalDemos - [demos count];

        for (NSUInteger loopVar = 0; loopVar < extraDemosNeeded; loopVar++) {
            currentDemo = [[TKDDemo alloc] init];
            currentDemo.title = @"Filler Cell";
            currentDemo.textStoragePath = @"Filler Cell.rtf";
            [demos addObject:currentDemo];
            currentDemo = nil;
        }

        _allDemos = [demos copy];
    });
    
    return _allDemos;
}

+ (TKDDemo *)demoForIndexPath:(NSIndexPath *)anIndexPath
{
    return [[self allDemos] objectAtIndex:[anIndexPath row]];
}

+ (NSUInteger)demoCount
{
    return [[self allDemos] count];
}

- (NSAttributedString *)attributedText
{
    if (!_attributedText) {
        NSURL *url = nil;

        if (self.textStoragePath) {
            url = [[NSBundle mainBundle] URLForResource:self.textStoragePath withExtension:nil];
        } else {
            url = [[NSBundle mainBundle] URLForResource:self.title withExtension:@"rtf"];
        }

        if (!url) {
            return [[NSAttributedString alloc] initWithString:@""];
        }

        if (!self.stripRichFormatting) {
            NSMutableAttributedString *attributedTextHolder = [[NSMutableAttributedString alloc] initWithFileURL:url options:@{} documentAttributes:nil error:nil];
            [attributedTextHolder addAttribute:NSFontAttributeName value:[UIFont preferredFontForTextStyle:UIFontTextStyleBody] range:NSMakeRange(0, attributedTextHolder.length)];

            _attributedText = [attributedTextHolder copy];
        } else {
            NSString *newFlatText = [[[NSAttributedString alloc] initWithFileURL:url options:@{} documentAttributes:nil error:nil] string];
            _attributedText = [[NSAttributedString alloc] initWithString:newFlatText attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]}];
        }
    }
    
    return _attributedText;
}
@end

