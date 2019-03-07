/*
    File: WWDCMapsTitleView.m
Abstract: Displays the title and floor number of the visible floor plan.
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

#import "WWDCMapsTitleView.h"

#import "WWDCMapsCommon.h"

@interface WWDCMapsTitleView ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation WWDCMapsTitleView

#pragma mark - Accessibility

- (NSString *)accessibilityLabel
{
    return self.titleLabel.text;
}

- (NSString *)accessibilityValue
{
    return [NSString stringWithFormat:@"Floor %d", self.floor];
}

- (BOOL)isAccessibilityElement
{
    return YES;
}

#pragma mark - Helpers

- (BOOL)indicatorHighlightedForFloor:(int)floor
{
    return floor == self.floor;
}

- (CGRect)indicatorRectForFloor:(int)floor
{
    CGRect bounds = self.bounds;
    CGFloat indicatorWidth = CGRectGetHeight(bounds) - WWDCMapsPadding * 2.0;
    
    switch ( floor )
    {
        case 1:
            return CGRectMake(CGRectGetMidX(bounds) + CGRectGetWidth(bounds) * 0.25 - indicatorWidth * 1.5 - WWDCMapsPadding * 2.0, WWDCMapsPadding, indicatorWidth, indicatorWidth);
        case 2:
            return CGRectMake(CGRectGetMidX(bounds) + CGRectGetWidth(bounds) * 0.25 - indicatorWidth * 0.5, WWDCMapsPadding, indicatorWidth, indicatorWidth);
        case 3:
            return CGRectMake(CGRectGetMidX(bounds) + CGRectGetWidth(bounds) * 0.25 + indicatorWidth * 0.5 + WWDCMapsPadding * 2.0, WWDCMapsPadding, indicatorWidth, indicatorWidth);
        default:
            // Unsupported floor
            return CGRectZero;
    }
}

#pragma mark - Overrides

- (void)drawRect:(CGRect)rect
{
    for ( int i = WWDCMapsMinimumFloor; i <= WWDCMapsMaximumFloor; ++i )
    {
        BOOL indicatorHighlighted = [self indicatorHighlightedForFloor:i];
        CGRect indicatorRect = [self indicatorRectForFloor:i];
        NSString *indicatorString = [NSString stringWithFormat:@"%d", i];
        
        // Draw indicator
        NSAttributedString *indicatorAttributedString = [[NSAttributedString alloc] initWithString:indicatorString attributes:@{ NSFontAttributeName : [UIFont boldSystemFontOfSize:WWDCMapsFontSize], NSForegroundColorAttributeName : ( indicatorHighlighted ) ? [UIColor blackColor] : [UIColor lightGrayColor] }];
        UIBezierPath *indicatorBezierPath = [UIBezierPath bezierPathWithOvalInRect:indicatorRect];
        indicatorBezierPath.lineWidth = WWDCMapsLineWidth;
        [[UIColor whiteColor] setFill];
        [indicatorBezierPath fill];
        [( indicatorHighlighted ) ? [UIColor blackColor] : [UIColor lightGrayColor] setStroke];
        [indicatorBezierPath stroke];
        [indicatorAttributedString drawAtPoint:CGPointMake(CGRectGetMidX(indicatorRect) - indicatorAttributedString.size.width * 0.5, CGRectGetMidY(indicatorRect) - indicatorAttributedString.size.height * 0.5)];
    }
}

#pragma mark - Properties

- (void)setFloor:(int)floor
{
    // Clamp floor between [WWDCMapsMinimumFloor, WWDCMapsMaximumFloor]
    _floor = MAX(MIN(floor, WWDCMapsMaximumFloor), WWDCMapsMinimumFloor);
    
    [self setNeedsDisplay];
}

@end
