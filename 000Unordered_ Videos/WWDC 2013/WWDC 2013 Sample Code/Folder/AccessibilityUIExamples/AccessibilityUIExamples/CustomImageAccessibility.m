/*
 
     File: CustomImageAccessibility.m
 Abstract: Accessibility support for the custom image.
  Version: 2.0
 
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

#import "CustomImage.h"

enum {
    kAccessibilityStage1 = 1,
    kAccessibilityStage2 = 2,
    kAccessibilityStage3 = 3,
    kAccessibilityStage4 = 4
};

// kAccessibilityStage1: Default NSView accessibility support.  This view is not exposed through accessibility hierarchy.
// kAccessibilityStage2: Explicitly expose this custom NSView through accessibility hierarchy.
// kAccessibilityStage3: Define a role for this UI element.
// kAccessibilityStage4: Give this UI element a label description.

@implementation CustomImage (CustomImageAccessibility)

- (BOOL)accessibilityIsIgnored
{
    // NSView returns YES. Must override and return NO for the view to be reachable.
    if ( [self identifierValue] >= kAccessibilityStage2 )
    {
        return NO;
    }
    else
    {
        return [super accessibilityIsIgnored];
    }
}

- (NSArray *)accessibilityAttributeNames
{
    if ( [self identifierValue] >= kAccessibilityStage4 )
    {
        return [[super accessibilityAttributeNames] arrayByAddingObject:NSAccessibilityDescriptionAttribute];
    }
    else
    {
        return [super accessibilityAttributeNames];
    }
}

- (id)accessibilityAttributeValue:(NSString *)attribute
{
    NSInteger identifierValue = [self identifierValue];
    
    if ( identifierValue >= kAccessibilityStage3 )
    {
        if ( [attribute isEqualToString:NSAccessibilityRoleAttribute] )
        {
            // NSAccessibilityRoleAttribute gives the best functional representation of this object
            return NSAccessibilityImageRole;
        }
        
        if ( identifierValue >= kAccessibilityStage4 )
        {
            if ( [attribute isEqualToString:NSAccessibilityDescriptionAttribute] )
            {
                // NSAccessibilityDescriptionAttribute should provide a visual description of the element.
                return NSLocalizedString(@"recycle", @"Accessibility description of the recycle button.");
            }
        }
    }

    return [super accessibilityAttributeValue:attribute];
}

- (BOOL)accessibilityIsAttributeSettable:(NSString *)attribute
{
    if ( [self identifierValue] >= kAccessibilityStage4 )
    {
        if ( [attribute isEqualToString:NSAccessibilityDescriptionAttribute] )
        {
            return NO;
        }
    }

    return [super accessibilityIsAttributeSettable:attribute];
}

@end
