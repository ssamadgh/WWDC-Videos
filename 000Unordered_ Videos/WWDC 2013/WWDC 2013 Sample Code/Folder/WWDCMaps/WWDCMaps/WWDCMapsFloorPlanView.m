/*
    File: WWDCMapsFloorPlanView.m
Abstract: Displays the floor plan associated with the selected floor number.
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

#import "WWDCMapsFloorPlanView.h"

#import "WWDCMapsCommon.h"

static NSString *const WWDCMapsFloorPlanBezierPath = @"WWDCMapsFloorPlanBezierPath";
static NSString *const WWDCMapsFloorPlanString = @"WWDCMapsFloorPlanString";

@interface WWDCMapsFloorPlanView ()

@property (strong, nonatomic) NSMutableArray *accessibilityElements;

@end

@implementation WWDCMapsFloorPlanView

#pragma mark - Accessibility

- (NSArray *)accessibilityElements
{
    if ( _accessibilityElements == nil )
    {
        _accessibilityElements = [NSMutableArray array];
        
        // Create accessibility elements
        [[self floorPlanFeatures] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSDictionary *floorPlanFeature, NSUInteger idx, BOOL *stop) {
            UIAccessibilityElement *accessibilityElement = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
            accessibilityElement.accessibilityLabel = floorPlanFeature[WWDCMapsFloorPlanString];
            accessibilityElement.accessibilityPath = UIAccessibilityConvertPathToScreenCoordinates(floorPlanFeature[WWDCMapsFloorPlanBezierPath], self);
            [_accessibilityElements addObject:accessibilityElement];
        }];
    }
    
    return _accessibilityElements;
}

- (id)accessibilityElementAtIndex:(NSInteger)index
{
    return [self.accessibilityElements objectAtIndex:index];
}

- (NSInteger)accessibilityElementCount
{
    return self.accessibilityElements.count;
}

- (NSInteger)indexOfAccessibilityElement:(id)element
{
    return [self.accessibilityElements indexOfObject:element];
}

#pragma mark - Helpers

- (NSArray *)floorPlanFeatures
{
    static UIBezierPath *exhibitHall1BezierPath = nil;
    static UIBezierPath *exhibitHall2BezierPath = nil;
    static UIBezierPath *lobby1BezierPath = nil;
    static UIBezierPath *lobby2BezierPath = nil;
    
    static UIBezierPath *elevatorsBezierPath = nil;
    static UIBezierPath *escalatorsBezierPath = nil;
    static UIBezierPath *restroomsBezierPath = nil;
    static UIBezierPath *stairsBezierPath = nil;
    
    static UIBezierPath *room2000BezierPath = nil;
    static UIBezierPath *room2001BezierPath = nil;
    static UIBezierPath *room2002BezierPath = nil;
    static UIBezierPath *room2003BezierPath = nil;
    static UIBezierPath *room2004BezierPath = nil;
    static UIBezierPath *room2005BezierPath = nil;
    static UIBezierPath *room2006BezierPath = nil;
    static UIBezierPath *room2007BezierPath = nil;
    static UIBezierPath *room2008BezierPath = nil;
    static UIBezierPath *room2009BezierPath = nil;
    static UIBezierPath *room2010BezierPath = nil;
    static UIBezierPath *room2011BezierPath = nil;
    static UIBezierPath *room2012BezierPath = nil;
    static UIBezierPath *room2014BezierPath = nil;
    static UIBezierPath *room2016BezierPath = nil;
    static UIBezierPath *room2018BezierPath = nil;
    static UIBezierPath *room2020BezierPath = nil;
    static UIBezierPath *room2022BezierPath = nil;
    static UIBezierPath *room2024BezierPath = nil;
    
    static UIBezierPath *coffee1001BezierPath = nil;
    static UIBezierPath *coffee1002BezierPath = nil;
    static UIBezierPath *coffee1003BezierPath = nil;
    static UIBezierPath *coffee1004BezierPath = nil;
    static UIBezierPath *coffee1005BezierPath = nil;
    static UIBezierPath *coffee2001BezierPath = nil;
    static UIBezierPath *coffee2002BezierPath = nil;
    static UIBezierPath *coffee2003BezierPath = nil;
    static UIBezierPath *coffee3001BezierPath = nil;
    static UIBezierPath *coffee3002BezierPath = nil;
    static UIBezierPath *coffee3003BezierPath = nil;
    
    static dispatch_once_t floorPlanBezierPathsOnceToken;
    dispatch_once(&floorPlanBezierPathsOnceToken, ^{
        exhibitHall1BezierPath = [UIBezierPath bezierPath];
        [exhibitHall1BezierPath moveToPoint:CGPointMake(115.0, 70.0)];
        [exhibitHall1BezierPath addLineToPoint:CGPointMake(480.0, 70.0)];
        [exhibitHall1BezierPath addLineToPoint:CGPointMake(480.0, 130.0)];
        [exhibitHall1BezierPath addLineToPoint:CGPointMake(535.0, 130.0)];
        [exhibitHall1BezierPath addLineToPoint:CGPointMake(535.0, 300.0)];
        [exhibitHall1BezierPath addLineToPoint:CGPointMake(480.0, 300.0)];
        [exhibitHall1BezierPath addLineToPoint:CGPointMake(480.0, 375.0)];
        [exhibitHall1BezierPath addLineToPoint:CGPointMake(518.0, 375.0)];
        [exhibitHall1BezierPath addLineToPoint:CGPointMake(518.0, 405.0)];
        [exhibitHall1BezierPath addLineToPoint:CGPointMake(115.0, 405.0)];
        [exhibitHall1BezierPath closePath];
        
        exhibitHall2BezierPath = [UIBezierPath bezierPath];
        [exhibitHall2BezierPath moveToPoint:CGPointMake(115.0, 70.0)];
        [exhibitHall2BezierPath addLineToPoint:CGPointMake(480.0, 70.0)];
        [exhibitHall2BezierPath addLineToPoint:CGPointMake(480.0, 164.0)];
        [exhibitHall2BezierPath addLineToPoint:CGPointMake(535.0, 164.0)];
        [exhibitHall2BezierPath addLineToPoint:CGPointMake(535.0, 300.0)];
        [exhibitHall2BezierPath addLineToPoint:CGPointMake(480.0, 300.0)];
        [exhibitHall2BezierPath addLineToPoint:CGPointMake(480.0, 375.0)];
        [exhibitHall2BezierPath addLineToPoint:CGPointMake(518.0, 375.0)];
        [exhibitHall2BezierPath addLineToPoint:CGPointMake(518.0, 405.0)];
        [exhibitHall2BezierPath addLineToPoint:CGPointMake(480.0, 405.0)];
        [exhibitHall2BezierPath addLineToPoint:CGPointMake(480.0, 444.0)];
        [exhibitHall2BezierPath addLineToPoint:CGPointMake(428.0, 462.0)];
        [exhibitHall2BezierPath addLineToPoint:CGPointMake(428.0, 405.0)];
        [exhibitHall2BezierPath addLineToPoint:CGPointMake(376.0, 405.0)];
        [exhibitHall2BezierPath addLineToPoint:CGPointMake(376.0, 444.0)];
        [exhibitHall2BezierPath addLineToPoint:CGPointMake(324.0, 462.0)];
        [exhibitHall2BezierPath addLineToPoint:CGPointMake(324.0, 405.0)];
        [exhibitHall2BezierPath addLineToPoint:CGPointMake(272.0, 405.0)];
        [exhibitHall2BezierPath addLineToPoint:CGPointMake(272.0, 444.0)];
        [exhibitHall2BezierPath addLineToPoint:CGPointMake(220.0, 462.0)];
        [exhibitHall2BezierPath addLineToPoint:CGPointMake(220.0, 405.0)];
        [exhibitHall2BezierPath addLineToPoint:CGPointMake(168.0, 405.0)];
        [exhibitHall2BezierPath addLineToPoint:CGPointMake(168.0, 444.0)];
        [exhibitHall2BezierPath addLineToPoint:CGPointMake(115.0, 462.0)];
        [exhibitHall2BezierPath closePath];
        
        lobby1BezierPath = [UIBezierPath bezierPath];
        [lobby1BezierPath moveToPoint:CGPointMake(535.0, 130.0)];
        [lobby1BezierPath addLineToPoint:CGPointMake(538.0, 130.0)];
        [lobby1BezierPath addLineToPoint:CGPointMake(538.0, 50.0)];
        [lobby1BezierPath addLineToPoint:CGPointMake(610.0, 50.0)];
        [lobby1BezierPath addLineToPoint:CGPointMake(616.0, 86.0)];
        [lobby1BezierPath addLineToPoint:CGPointMake(644.0, 86.0)];
        [lobby1BezierPath addLineToPoint:CGPointMake(644.0, 410.0)];
        [lobby1BezierPath addLineToPoint:CGPointMake(536.0, 410.0)];
        [lobby1BezierPath addLineToPoint:CGPointMake(536.0, 405.0)];
        [lobby1BezierPath addLineToPoint:CGPointMake(518.0, 405.0)];
        [lobby1BezierPath addLineToPoint:CGPointMake(518.0, 375.0)];
        [lobby1BezierPath addLineToPoint:CGPointMake(538.0, 375.0)];
        [lobby1BezierPath addLineToPoint:CGPointMake(538.0, 230.0)];
        [lobby1BezierPath addLineToPoint:CGPointMake(535.0, 230.0)];
        [lobby1BezierPath closePath];
        
        lobby2BezierPath = [UIBezierPath bezierPath];
        [lobby2BezierPath moveToPoint:CGPointMake(535.0, 164.0)];
        [lobby2BezierPath addLineToPoint:CGPointMake(538.0, 164.0)];
        [lobby2BezierPath addLineToPoint:CGPointMake(538.0, 50.0)];
        [lobby2BezierPath addLineToPoint:CGPointMake(610.0, 50.0)];
        [lobby2BezierPath addLineToPoint:CGPointMake(670.0, 410.0)];
        [lobby2BezierPath addLineToPoint:CGPointMake(536.0, 458.0)];
        [lobby2BezierPath addLineToPoint:CGPointMake(536.0, 405.0)];
        [lobby2BezierPath addLineToPoint:CGPointMake(518.0, 405.0)];
        [lobby2BezierPath addLineToPoint:CGPointMake(518.0, 375.0)];
        [lobby2BezierPath addLineToPoint:CGPointMake(538.0, 375.0)];
        [lobby2BezierPath addLineToPoint:CGPointMake(538.0, 230.0)];
        [lobby2BezierPath addLineToPoint:CGPointMake(535.0, 230.0)];
        [lobby2BezierPath closePath];
        
        elevatorsBezierPath = [UIBezierPath bezierPath];
        [elevatorsBezierPath moveToPoint:CGPointMake(538.0, 98.0)];
        [elevatorsBezierPath addLineToPoint:CGPointMake(535.0, 98.0)];
        [elevatorsBezierPath addLineToPoint:CGPointMake(535.0, 95.0)];
        [elevatorsBezierPath addLineToPoint:CGPointMake(518.0, 95.0)];
        [elevatorsBezierPath addLineToPoint:CGPointMake(518.0, 125.0)];
        [elevatorsBezierPath addLineToPoint:CGPointMake(535.0, 125.0)];
        [elevatorsBezierPath addLineToPoint:CGPointMake(535.0, 122.0)];
        [elevatorsBezierPath addLineToPoint:CGPointMake(538.0, 122.0)];
        [elevatorsBezierPath closePath];
        
        escalatorsBezierPath = [UIBezierPath bezierPath];
        [escalatorsBezierPath moveToPoint:CGPointMake(602.0, 232.0)];
        [escalatorsBezierPath addLineToPoint:CGPointMake(630.0, 232.0)];
        [escalatorsBezierPath addLineToPoint:CGPointMake(630.0, 340.0)];
        [escalatorsBezierPath addLineToPoint:CGPointMake(602.0, 340.0)];
        [escalatorsBezierPath closePath];
        [escalatorsBezierPath moveToPoint:CGPointMake(602.0, 238.0)];
        [escalatorsBezierPath addLineToPoint:CGPointMake(630.0, 238.0)];
        [escalatorsBezierPath moveToPoint:CGPointMake(602.0, 244.0)];
        [escalatorsBezierPath addLineToPoint:CGPointMake(630.0, 244.0)];
        [escalatorsBezierPath moveToPoint:CGPointMake(602.0, 250.0)];
        [escalatorsBezierPath addLineToPoint:CGPointMake(630.0, 250.0)];
        [escalatorsBezierPath moveToPoint:CGPointMake(602.0, 256.0)];
        [escalatorsBezierPath addLineToPoint:CGPointMake(630.0, 256.0)];
        [escalatorsBezierPath moveToPoint:CGPointMake(602.0, 262.0)];
        [escalatorsBezierPath addLineToPoint:CGPointMake(630.0, 262.0)];
        [escalatorsBezierPath moveToPoint:CGPointMake(602.0, 268.0)];
        [escalatorsBezierPath addLineToPoint:CGPointMake(630.0, 268.0)];
        [escalatorsBezierPath moveToPoint:CGPointMake(602.0, 274.0)];
        [escalatorsBezierPath addLineToPoint:CGPointMake(630.0, 274.0)];
        [escalatorsBezierPath moveToPoint:CGPointMake(602.0, 280.0)];
        [escalatorsBezierPath addLineToPoint:CGPointMake(630.0, 280.0)];
        [escalatorsBezierPath moveToPoint:CGPointMake(602.0, 286.0)];
        [escalatorsBezierPath addLineToPoint:CGPointMake(630.0, 286.0)];
        [escalatorsBezierPath moveToPoint:CGPointMake(602.0, 292.0)];
        [escalatorsBezierPath addLineToPoint:CGPointMake(630.0, 292.0)];
        [escalatorsBezierPath moveToPoint:CGPointMake(602.0, 298.0)];
        [escalatorsBezierPath addLineToPoint:CGPointMake(630.0, 298.0)];
        [escalatorsBezierPath moveToPoint:CGPointMake(602.0, 304.0)];
        [escalatorsBezierPath addLineToPoint:CGPointMake(630.0, 304.0)];
        [escalatorsBezierPath moveToPoint:CGPointMake(602.0, 310.0)];
        [escalatorsBezierPath addLineToPoint:CGPointMake(630.0, 310.0)];
        [escalatorsBezierPath moveToPoint:CGPointMake(602.0, 316.0)];
        [escalatorsBezierPath addLineToPoint:CGPointMake(630.0, 316.0)];
        [escalatorsBezierPath moveToPoint:CGPointMake(602.0, 322.0)];
        [escalatorsBezierPath addLineToPoint:CGPointMake(630.0, 322.0)];
        [escalatorsBezierPath moveToPoint:CGPointMake(602.0, 328.0)];
        [escalatorsBezierPath addLineToPoint:CGPointMake(630.0, 328.0)];
        [escalatorsBezierPath moveToPoint:CGPointMake(602.0, 334.0)];
        [escalatorsBezierPath addLineToPoint:CGPointMake(630.0, 334.0)];
        
        restroomsBezierPath = [UIBezierPath bezierPath];
        [restroomsBezierPath moveToPoint:CGPointMake(115.0, 395.0)];
        [restroomsBezierPath addLineToPoint:CGPointMake(80.0, 395.0)];
        [restroomsBezierPath addLineToPoint:CGPointMake(80.0, 370.0)];
        [restroomsBezierPath addLineToPoint:CGPointMake(72.0, 370.0)];
        [restroomsBezierPath addLineToPoint:CGPointMake(72.0, 318.0)];
        [restroomsBezierPath addLineToPoint:CGPointMake(112.0, 318.0)];
        [restroomsBezierPath addLineToPoint:CGPointMake(112.0, 370.0)];
        [restroomsBezierPath addLineToPoint:CGPointMake(115.0, 370.0)];
        [restroomsBezierPath closePath];
        
        stairsBezierPath = [UIBezierPath bezierPath];
        [stairsBezierPath moveToPoint:CGPointMake(578.0, 54.0)];
        [stairsBezierPath addLineToPoint:CGPointMake(598.0, 54.0)];
        [stairsBezierPath addLineToPoint:CGPointMake(598.0, 90.0)];
        [stairsBezierPath addLineToPoint:CGPointMake(578.0, 90.0)];
        [stairsBezierPath closePath];
        [stairsBezierPath moveToPoint:CGPointMake(578.0, 60.0)];
        [stairsBezierPath addLineToPoint:CGPointMake(598.0, 60.0)];
        [stairsBezierPath moveToPoint:CGPointMake(578.0, 66.0)];
        [stairsBezierPath addLineToPoint:CGPointMake(598.0, 66.0)];
        [stairsBezierPath moveToPoint:CGPointMake(578.0, 72.0)];
        [stairsBezierPath addLineToPoint:CGPointMake(598.0, 72.0)];
        [stairsBezierPath moveToPoint:CGPointMake(578.0, 78.0)];
        [stairsBezierPath addLineToPoint:CGPointMake(598.0, 78.0)];
        [stairsBezierPath moveToPoint:CGPointMake(578.0, 84.0)];
        [stairsBezierPath addLineToPoint:CGPointMake(598.0, 84.0)];
        
        room2000BezierPath = [UIBezierPath bezierPath];
        [room2000BezierPath moveToPoint:CGPointMake(465.0, 85.0)];
        [room2000BezierPath addLineToPoint:CGPointMake(465.0, 158.0)];
        [room2000BezierPath addLineToPoint:CGPointMake(425.0, 158.0)];
        [room2000BezierPath addLineToPoint:CGPointMake(425.0, 85.0)];
        [room2000BezierPath closePath];
        
        room2001BezierPath = [UIBezierPath bezierPath];
        [room2001BezierPath moveToPoint:CGPointMake(425.0, 202.0)];
        [room2001BezierPath addLineToPoint:CGPointMake(490.0, 202.0)];
        [room2001BezierPath addLineToPoint:CGPointMake(490.0, 284.0)];
        [room2001BezierPath addLineToPoint:CGPointMake(425.0, 284.0)];
        [room2001BezierPath closePath];
        
        room2002BezierPath = [UIBezierPath bezierPath];
        [room2002BezierPath moveToPoint:CGPointMake(425.0, 70.0)];
        [room2002BezierPath addLineToPoint:CGPointMake(425.0, 158.0)];
        [room2002BezierPath addLineToPoint:CGPointMake(372.0, 158.0)];
        [room2002BezierPath addLineToPoint:CGPointMake(372.0, 70.0)];
        [room2002BezierPath closePath];
        
        room2003BezierPath = [UIBezierPath bezierPath];
        [room2003BezierPath moveToPoint:CGPointMake(372.0, 202.0)];
        [room2003BezierPath addLineToPoint:CGPointMake(425.0, 202.0)];
        [room2003BezierPath addLineToPoint:CGPointMake(425.0, 284.0)];
        [room2003BezierPath addLineToPoint:CGPointMake(372.0, 284.0)];
        [room2003BezierPath closePath];
        
        room2004BezierPath = [UIBezierPath bezierPath];
        [room2004BezierPath moveToPoint:CGPointMake(372.0, 70.0)];
        [room2004BezierPath addLineToPoint:CGPointMake(372.0, 158.0)];
        [room2004BezierPath addLineToPoint:CGPointMake(320.0, 158.0)];
        [room2004BezierPath addLineToPoint:CGPointMake(320.0, 70.0)];
        [room2004BezierPath closePath];
        
        room2005BezierPath = [UIBezierPath bezierPath];
        [room2005BezierPath moveToPoint:CGPointMake(320.0, 202.0)];
        [room2005BezierPath addLineToPoint:CGPointMake(372.0, 202.0)];
        [room2005BezierPath addLineToPoint:CGPointMake(372.0, 284.0)];
        [room2005BezierPath addLineToPoint:CGPointMake(320.0, 284.0)];
        [room2005BezierPath closePath];
        
        room2006BezierPath = [UIBezierPath bezierPath];
        [room2006BezierPath moveToPoint:CGPointMake(320.0, 70.0)];
        [room2006BezierPath addLineToPoint:CGPointMake(320.0, 158.0)];
        [room2006BezierPath addLineToPoint:CGPointMake(268.0, 158.0)];
        [room2006BezierPath addLineToPoint:CGPointMake(268.0, 70.0)];
        [room2006BezierPath closePath];
        
        room2007BezierPath = [UIBezierPath bezierPath];
        [room2007BezierPath moveToPoint:CGPointMake(268.0, 202.0)];
        [room2007BezierPath addLineToPoint:CGPointMake(320.0, 202.0)];
        [room2007BezierPath addLineToPoint:CGPointMake(320.0, 284.0)];
        [room2007BezierPath addLineToPoint:CGPointMake(268.0, 284.0)];
        [room2007BezierPath closePath];
        
        room2008BezierPath = [UIBezierPath bezierPath];
        [room2008BezierPath moveToPoint:CGPointMake(268.0, 70.0)];
        [room2008BezierPath addLineToPoint:CGPointMake(268.0, 158.0)];
        [room2008BezierPath addLineToPoint:CGPointMake(216.0, 158.0)];
        [room2008BezierPath addLineToPoint:CGPointMake(216.0, 70.0)];
        [room2008BezierPath closePath];
        
        room2009BezierPath = [UIBezierPath bezierPath];
        [room2009BezierPath moveToPoint:CGPointMake(216.0, 202.0)];
        [room2009BezierPath addLineToPoint:CGPointMake(268.0, 202.0)];
        [room2009BezierPath addLineToPoint:CGPointMake(268.0, 284.0)];
        [room2009BezierPath addLineToPoint:CGPointMake(216.0, 284.0)];
        [room2009BezierPath closePath];
        
        room2010BezierPath = [UIBezierPath bezierPath];
        [room2010BezierPath moveToPoint:CGPointMake(216.0, 85.0)];
        [room2010BezierPath addLineToPoint:CGPointMake(216.0, 158.0)];
        [room2010BezierPath addLineToPoint:CGPointMake(164.0, 158.0)];
        [room2010BezierPath addLineToPoint:CGPointMake(164.0, 85.0)];
        [room2010BezierPath closePath];
        
        room2011BezierPath = [UIBezierPath bezierPath];
        [room2011BezierPath moveToPoint:CGPointMake(164.0, 202.0)];
        [room2011BezierPath addLineToPoint:CGPointMake(216.0, 202.0)];
        [room2011BezierPath addLineToPoint:CGPointMake(216.0, 284.0)];
        [room2011BezierPath addLineToPoint:CGPointMake(164.0, 284.0)];
        [room2011BezierPath closePath];
        
        room2012BezierPath = [UIBezierPath bezierPath];
        [room2012BezierPath moveToPoint:CGPointMake(164.0, 85.0)];
        [room2012BezierPath addLineToPoint:CGPointMake(164.0, 158.0)];
        [room2012BezierPath addLineToPoint:CGPointMake(115.0, 158.0)];
        [room2012BezierPath addLineToPoint:CGPointMake(115.0, 85.0)];
        [room2012BezierPath closePath];
        
        room2014BezierPath = [UIBezierPath bezierPath];
        [room2014BezierPath moveToPoint:CGPointMake(425.0, 284.0)];
        [room2014BezierPath addLineToPoint:CGPointMake(490.0, 284.0)];
        [room2014BezierPath addLineToPoint:CGPointMake(490.0, 300.0)];
        [room2014BezierPath addLineToPoint:CGPointMake(480.0, 300.0)];
        [room2014BezierPath addLineToPoint:CGPointMake(480.0, 370.0)];
        [room2014BezierPath addLineToPoint:CGPointMake(425.0, 370.0)];
        [room2014BezierPath closePath];
        
        room2016BezierPath = [UIBezierPath bezierPath];
        [room2016BezierPath moveToPoint:CGPointMake(372.0, 284.0)];
        [room2016BezierPath addLineToPoint:CGPointMake(425.0, 284.0)];
        [room2016BezierPath addLineToPoint:CGPointMake(425.0, 370.0)];
        [room2016BezierPath addLineToPoint:CGPointMake(372.0, 370.0)];
        [room2016BezierPath closePath];
        
        room2018BezierPath = [UIBezierPath bezierPath];
        [room2018BezierPath moveToPoint:CGPointMake(320.0, 284.0)];
        [room2018BezierPath addLineToPoint:CGPointMake(372.0, 284.0)];
        [room2018BezierPath addLineToPoint:CGPointMake(372.0, 370.0)];
        [room2018BezierPath addLineToPoint:CGPointMake(320.0, 370.0)];
        [room2018BezierPath closePath];
        
        room2020BezierPath = [UIBezierPath bezierPath];
        [room2020BezierPath moveToPoint:CGPointMake(268.0, 284.0)];
        [room2020BezierPath addLineToPoint:CGPointMake(320.0, 284.0)];
        [room2020BezierPath addLineToPoint:CGPointMake(320.0, 370.0)];
        [room2020BezierPath addLineToPoint:CGPointMake(268.0, 370.0)];
        [room2020BezierPath closePath];
        
        room2022BezierPath = [UIBezierPath bezierPath];
        [room2022BezierPath moveToPoint:CGPointMake(216.0, 284.0)];
        [room2022BezierPath addLineToPoint:CGPointMake(268.0, 284.0)];
        [room2022BezierPath addLineToPoint:CGPointMake(268.0, 370.0)];
        [room2022BezierPath addLineToPoint:CGPointMake(216.0, 370.0)];
        [room2022BezierPath closePath];
        
        room2024BezierPath = [UIBezierPath bezierPath];
        [room2024BezierPath moveToPoint:CGPointMake(164.0, 284.0)];
        [room2024BezierPath addLineToPoint:CGPointMake(216.0, 284.0)];
        [room2024BezierPath addLineToPoint:CGPointMake(216.0, 370.0)];
        [room2024BezierPath addLineToPoint:CGPointMake(164.0, 370.0)];
        [room2024BezierPath closePath];
        
        coffee1001BezierPath = [UIBezierPath bezierPath];
        [coffee1001BezierPath moveToPoint:CGPointMake(348.0, 202.0)];
        [coffee1001BezierPath addLineToPoint:CGPointMake(352.0, 224.0)];
        [coffee1001BezierPath addLineToPoint:CGPointMake(364.0, 224.0)];
        [coffee1001BezierPath addLineToPoint:CGPointMake(368.0, 202.0)];
        [coffee1001BezierPath closePath];
        
        coffee1002BezierPath = [UIBezierPath bezierPath];
        [coffee1002BezierPath moveToPoint:CGPointMake(130.0, 182.0)];
        [coffee1002BezierPath addLineToPoint:CGPointMake(134.0, 204.0)];
        [coffee1002BezierPath addLineToPoint:CGPointMake(146.0, 204.0)];
        [coffee1002BezierPath addLineToPoint:CGPointMake(150.0, 182.0)];
        [coffee1002BezierPath closePath];
        
        coffee1003BezierPath = [UIBezierPath bezierPath];
        [coffee1003BezierPath moveToPoint:CGPointMake(130.0, 262.0)];
        [coffee1003BezierPath addLineToPoint:CGPointMake(134.0, 284.0)];
        [coffee1003BezierPath addLineToPoint:CGPointMake(146.0, 284.0)];
        [coffee1003BezierPath addLineToPoint:CGPointMake(150.0, 262.0)];
        [coffee1003BezierPath closePath];
        
        coffee1004BezierPath = [UIBezierPath bezierPath];
        [coffee1004BezierPath moveToPoint:CGPointMake(368.0, 282.0)];
        [coffee1004BezierPath addLineToPoint:CGPointMake(372.0, 304.0)];
        [coffee1004BezierPath addLineToPoint:CGPointMake(384.0, 304.0)];
        [coffee1004BezierPath addLineToPoint:CGPointMake(388.0, 282.0)];
        [coffee1004BezierPath closePath];
        
        coffee1005BezierPath = [UIBezierPath bezierPath];
        [coffee1005BezierPath moveToPoint:CGPointMake(268.0, 332.0)];
        [coffee1005BezierPath addLineToPoint:CGPointMake(272.0, 354.0)];
        [coffee1005BezierPath addLineToPoint:CGPointMake(284.0, 354.0)];
        [coffee1005BezierPath addLineToPoint:CGPointMake(288.0, 332.0)];
        [coffee1005BezierPath closePath];
        
        coffee2001BezierPath = [UIBezierPath bezierPath];
        [coffee2001BezierPath moveToPoint:CGPointMake(558.0, 222.0)];
        [coffee2001BezierPath addLineToPoint:CGPointMake(562.0, 244.0)];
        [coffee2001BezierPath addLineToPoint:CGPointMake(574.0, 244.0)];
        [coffee2001BezierPath addLineToPoint:CGPointMake(578.0, 222.0)];
        [coffee2001BezierPath closePath];
        
        coffee2002BezierPath = [UIBezierPath bezierPath];
        [coffee2002BezierPath moveToPoint:CGPointMake(598.0, 382.0)];
        [coffee2002BezierPath addLineToPoint:CGPointMake(602.0, 404.0)];
        [coffee2002BezierPath addLineToPoint:CGPointMake(614.0, 404.0)];
        [coffee2002BezierPath addLineToPoint:CGPointMake(618.0, 382.0)];
        [coffee2002BezierPath closePath];
        
        coffee2003BezierPath = [UIBezierPath bezierPath];
        [coffee2003BezierPath moveToPoint:CGPointMake(128.0, 412.0)];
        [coffee2003BezierPath addLineToPoint:CGPointMake(132.0, 434.0)];
        [coffee2003BezierPath addLineToPoint:CGPointMake(144.0, 434.0)];
        [coffee2003BezierPath addLineToPoint:CGPointMake(148.0, 412.0)];
        [coffee2003BezierPath closePath];
        
        coffee3001BezierPath = [UIBezierPath bezierPath];
        [coffee3001BezierPath moveToPoint:CGPointMake(558.0, 202.0)];
        [coffee3001BezierPath addLineToPoint:CGPointMake(562.0, 224.0)];
        [coffee3001BezierPath addLineToPoint:CGPointMake(574.0, 224.0)];
        [coffee3001BezierPath addLineToPoint:CGPointMake(578.0, 202.0)];
        [coffee3001BezierPath closePath];
        
        coffee3002BezierPath = [UIBezierPath bezierPath];
        [coffee3002BezierPath moveToPoint:CGPointMake(568.0, 362.0)];
        [coffee3002BezierPath addLineToPoint:CGPointMake(572.0, 384.0)];
        [coffee3002BezierPath addLineToPoint:CGPointMake(584.0, 384.0)];
        [coffee3002BezierPath addLineToPoint:CGPointMake(588.0, 362.0)];
        [coffee3002BezierPath closePath];
        
        coffee3003BezierPath = [UIBezierPath bezierPath];
        [coffee3003BezierPath moveToPoint:CGPointMake(438.0, 418.0)];
        [coffee3003BezierPath addLineToPoint:CGPointMake(442.0, 440.0)];
        [coffee3003BezierPath addLineToPoint:CGPointMake(454.0, 440.0)];
        [coffee3003BezierPath addLineToPoint:CGPointMake(458.0, 418.0)];
        [coffee3003BezierPath closePath];
    });
    
    NSMutableArray *floorPlanFeatures = [NSMutableArray array];
    
    switch ( self.floor )
    {
        case 1:
        {
            [floorPlanFeatures addObjectsFromArray:@[ @{ WWDCMapsFloorPlanBezierPath : exhibitHall1BezierPath, WWDCMapsFloorPlanString : @"Hall" },
                                                      @{ WWDCMapsFloorPlanBezierPath : lobby1BezierPath, WWDCMapsFloorPlanString : @"Lobby" },
                                                      @{ WWDCMapsFloorPlanBezierPath : elevatorsBezierPath, WWDCMapsFloorPlanString : @"Elevators" },
                                                      @{ WWDCMapsFloorPlanBezierPath : escalatorsBezierPath, WWDCMapsFloorPlanString : @"Escalators" },
                                                      @{ WWDCMapsFloorPlanBezierPath : restroomsBezierPath, WWDCMapsFloorPlanString : @"Restrooms" },
                                                      @{ WWDCMapsFloorPlanBezierPath : stairsBezierPath, WWDCMapsFloorPlanString : @"Stairs" } ]];
            if ( self.showCoffee )
            {
                [floorPlanFeatures addObjectsFromArray:@[ @{ WWDCMapsFloorPlanBezierPath : coffee1001BezierPath, WWDCMapsFloorPlanString : @"Coffee" },
                                                          @{ WWDCMapsFloorPlanBezierPath : coffee1002BezierPath, WWDCMapsFloorPlanString : @"Coffee" },
                                                          @{ WWDCMapsFloorPlanBezierPath : coffee1003BezierPath, WWDCMapsFloorPlanString : @"Coffee" },
                                                          @{ WWDCMapsFloorPlanBezierPath : coffee1004BezierPath, WWDCMapsFloorPlanString : @"Coffee" },
                                                          @{ WWDCMapsFloorPlanBezierPath : coffee1005BezierPath, WWDCMapsFloorPlanString : @"Coffee" } ]];
            }
            break;
        }
        case 2:
        {
            [floorPlanFeatures addObjectsFromArray:@[ @{ WWDCMapsFloorPlanBezierPath : exhibitHall2BezierPath, WWDCMapsFloorPlanString : @"Hall" },
                                                      @{ WWDCMapsFloorPlanBezierPath : lobby2BezierPath, WWDCMapsFloorPlanString : @"Lobby" },
                                                      @{ WWDCMapsFloorPlanBezierPath : elevatorsBezierPath, WWDCMapsFloorPlanString : @"Elevators" },
                                                      @{ WWDCMapsFloorPlanBezierPath : escalatorsBezierPath, WWDCMapsFloorPlanString : @"Escalators" },
                                                      @{ WWDCMapsFloorPlanBezierPath : restroomsBezierPath, WWDCMapsFloorPlanString : @"Restrooms" },
                                                      @{ WWDCMapsFloorPlanBezierPath : stairsBezierPath, WWDCMapsFloorPlanString : @"Stairs" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2000BezierPath, WWDCMapsFloorPlanString : @"2000" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2001BezierPath, WWDCMapsFloorPlanString : @"2001" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2002BezierPath, WWDCMapsFloorPlanString : @"2002" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2003BezierPath, WWDCMapsFloorPlanString : @"2003" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2004BezierPath, WWDCMapsFloorPlanString : @"2004" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2005BezierPath, WWDCMapsFloorPlanString : @"2005" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2006BezierPath, WWDCMapsFloorPlanString : @"2006" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2007BezierPath, WWDCMapsFloorPlanString : @"2007" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2008BezierPath, WWDCMapsFloorPlanString : @"2008" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2009BezierPath, WWDCMapsFloorPlanString : @"2009" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2010BezierPath, WWDCMapsFloorPlanString : @"2010" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2011BezierPath, WWDCMapsFloorPlanString : @"2011" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2012BezierPath, WWDCMapsFloorPlanString : @"2012" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2014BezierPath, WWDCMapsFloorPlanString : @"2014" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2016BezierPath, WWDCMapsFloorPlanString : @"2016" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2018BezierPath, WWDCMapsFloorPlanString : @"2018" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2020BezierPath, WWDCMapsFloorPlanString : @"2020" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2022BezierPath, WWDCMapsFloorPlanString : @"2022" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2024BezierPath, WWDCMapsFloorPlanString : @"2024" } ]];
            if ( self.showCoffee )
            {
                [floorPlanFeatures addObjectsFromArray:@[ @{ WWDCMapsFloorPlanBezierPath : coffee2001BezierPath, WWDCMapsFloorPlanString : @"Coffee" },
                                                          @{ WWDCMapsFloorPlanBezierPath : coffee2002BezierPath, WWDCMapsFloorPlanString : @"Coffee" },
                                                          @{ WWDCMapsFloorPlanBezierPath : coffee2003BezierPath, WWDCMapsFloorPlanString : @"Coffee" } ]];
            }
            break;
        }
        case 3:
        {
            [floorPlanFeatures addObjectsFromArray:@[ @{ WWDCMapsFloorPlanBezierPath : exhibitHall2BezierPath, WWDCMapsFloorPlanString : @"Hall" },
                                                      @{ WWDCMapsFloorPlanBezierPath : lobby2BezierPath, WWDCMapsFloorPlanString : @"Lobby" },
                                                      @{ WWDCMapsFloorPlanBezierPath : elevatorsBezierPath, WWDCMapsFloorPlanString : @"Elevators" },
                                                      @{ WWDCMapsFloorPlanBezierPath : escalatorsBezierPath, WWDCMapsFloorPlanString : @"Escalators" },
                                                      @{ WWDCMapsFloorPlanBezierPath : restroomsBezierPath, WWDCMapsFloorPlanString : @"Restrooms" },
                                                      @{ WWDCMapsFloorPlanBezierPath : stairsBezierPath, WWDCMapsFloorPlanString : @"Stairs" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2000BezierPath, WWDCMapsFloorPlanString : @"3000" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2001BezierPath, WWDCMapsFloorPlanString : @"3001" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2002BezierPath, WWDCMapsFloorPlanString : @"3002" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2003BezierPath, WWDCMapsFloorPlanString : @"3003" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2004BezierPath, WWDCMapsFloorPlanString : @"3004" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2005BezierPath, WWDCMapsFloorPlanString : @"3005" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2006BezierPath, WWDCMapsFloorPlanString : @"3006" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2007BezierPath, WWDCMapsFloorPlanString : @"3007" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2008BezierPath, WWDCMapsFloorPlanString : @"3008" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2009BezierPath, WWDCMapsFloorPlanString : @"3009" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2010BezierPath, WWDCMapsFloorPlanString : @"3010" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2011BezierPath, WWDCMapsFloorPlanString : @"3011" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2012BezierPath, WWDCMapsFloorPlanString : @"3012" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2014BezierPath, WWDCMapsFloorPlanString : @"3014" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2016BezierPath, WWDCMapsFloorPlanString : @"3016" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2018BezierPath, WWDCMapsFloorPlanString : @"3018" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2020BezierPath, WWDCMapsFloorPlanString : @"3020" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2022BezierPath, WWDCMapsFloorPlanString : @"3022" },
                                                      @{ WWDCMapsFloorPlanBezierPath : room2024BezierPath, WWDCMapsFloorPlanString : @"3024" } ]];
            if ( self.showCoffee )
            {
                [floorPlanFeatures addObjectsFromArray:@[ @{ WWDCMapsFloorPlanBezierPath : coffee3001BezierPath, WWDCMapsFloorPlanString : @"Coffee" },
                                                          @{ WWDCMapsFloorPlanBezierPath : coffee3002BezierPath, WWDCMapsFloorPlanString : @"Coffee" },
                                                          @{ WWDCMapsFloorPlanBezierPath : coffee3003BezierPath, WWDCMapsFloorPlanString : @"Coffee" } ]];
            }
            break;
        }
        default:
            // Unsupported floor
            break;
    }
    
    return floorPlanFeatures;
}

#pragma mark - Overrides

- (void)drawRect:(CGRect)rect
{
    // Draw floor plan features
    [[self floorPlanFeatures] enumerateObjectsUsingBlock:^(NSDictionary *floorPlanFeature, NSUInteger idx, BOOL *stop) {
        NSString *floorPlanFeatureString = floorPlanFeature[WWDCMapsFloorPlanString];
        BOOL isCoffee = [floorPlanFeatureString isEqualToString:@"Coffee"];
        BOOL isHall = [floorPlanFeatureString isEqualToString:@"Hall"];
        BOOL isLobby = [floorPlanFeatureString isEqualToString:@"Lobby"];
        NSAttributedString *floorPlanFeatureAttributedString = [[NSAttributedString alloc] initWithString:floorPlanFeatureString attributes:@{ NSFontAttributeName : [UIFont boldSystemFontOfSize:WWDCMapsFontSize], NSForegroundColorAttributeName : [UIColor blackColor] }];
        UIBezierPath *floorPlanFeatureBezierPath = floorPlanFeature[WWDCMapsFloorPlanBezierPath];
        floorPlanFeatureBezierPath.lineWidth = WWDCMapsLineWidth;
        [( isCoffee ) ? [UIColor colorWithRed:0.8 green:0.6 blue:0.4 alpha:1.0] : [UIColor whiteColor] setFill];
        [floorPlanFeatureBezierPath fill];
        [( isCoffee ) ? [UIColor colorWithRed:0.4 green:0.2 blue:0.0 alpha:1.0] : [UIColor lightGrayColor] setStroke];
        [floorPlanFeatureBezierPath stroke];
        if ( !isCoffee && !isHall && !isLobby )
        {
            [floorPlanFeatureAttributedString drawAtPoint:CGPointMake(CGRectGetMidX(floorPlanFeatureBezierPath.bounds) - floorPlanFeatureAttributedString.size.width * 0.5, CGRectGetMidY(floorPlanFeatureBezierPath.bounds) - floorPlanFeatureAttributedString.size.height * 0.5)];
        }
    }];
}

#pragma mark - Properties

- (void)setFloor:(int)floor
{
    // Clamp floor between [WWDCMapsMinimumFloor, WWDCMapsMaximumFloor]
    _floor = MAX(MIN(floor, WWDCMapsMaximumFloor), WWDCMapsMinimumFloor);
    
    self.accessibilityElements = nil;
    
    [self setNeedsDisplay];
}

- (void)setShowCoffee:(BOOL)showCoffee
{
    _showCoffee = showCoffee;
    
    self.accessibilityElements = nil;
    
    [self setNeedsDisplay];
}

@end
