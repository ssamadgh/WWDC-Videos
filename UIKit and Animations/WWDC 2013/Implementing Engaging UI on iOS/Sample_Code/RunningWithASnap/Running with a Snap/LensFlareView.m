/*
     File: LensFlareView.m
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

#import "LensFlareView.h"

CGFloat _randomFloat(CGFloat min, CGFloat max) {
    return ((CGFloat)arc4random() / 0x100000000) * (max - min) + min;
}

@interface LensFlareBlob : UIView
- (id)initWithFrame:(CGRect)frame points:(NSInteger)numberOfPoints startAngle:(CGFloat)angle;
@end

@interface LensFlareDiagonalMotionEffect : UIMotionEffect
@property (nonatomic, assign) CGFloat minValue;
@property (nonatomic, assign) CGFloat maxValue;
@end

@interface LensFlareColorMotionEffect : UIMotionEffect 
{
    CGFloat _hue;
    CGFloat _brightness;
}
@property (nonatomic, strong) UIColor *color;
- (instancetype)initWithColor:(UIColor *)color;
@end




@implementation LensFlareView

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame flareLineEndPoint:CGPointMake(200, CGRectGetHeight(frame))];
}

- (id)initWithFrame:(CGRect)frame flareLineEndPoint:(CGPoint)endPoint {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self _addFlareToEndPoint:endPoint];
        self.alpha = _randomFloat(0.15, 0.25);
    }
    return self;
}

// Assumes a right-to-left downward slope starting at {0,0}
- (void)_addFlareToEndPoint:(CGPoint)endPoint {
    CGFloat hypotenuse = sqrtf(powf(endPoint.x,2) + powf(endPoint.y,2));
    CGFloat degrees = atanf(tanf(endPoint.x / endPoint.y)) * 100;
    CGFloat radians = (90.0 - degrees) * M_PI / 180.0;
    
    CGFloat pointOnHypontenuse = _randomFloat(20, 30);
    CGFloat flareSize = 0.0;
    do {
        CGPoint p = CGPointMake(pointOnHypontenuse * cosf(radians), pointOnHypontenuse * sinf(radians));

        // Create a lens flare
        flareSize = _randomFloat(20, 225); 
        LensFlareBlob *blob = [[LensFlareBlob alloc] initWithFrame:CGRectMake(0, 0, flareSize, flareSize) points:7 startAngle:_randomFloat(0, M_PI)];
        blob.center = p;
        
        // Pick a random color and assign it to a new color motion effect
        UIColor *randomColor = [UIColor colorWithHue:_randomFloat(0, 1) saturation:1.0 brightness:_randomFloat(.2, .6) alpha:1.0];
        LensFlareColorMotionEffect *colorMotion = [[LensFlareColorMotionEffect alloc] initWithColor:randomColor];
        
        // Create a new diagonal motion effect
        LensFlareDiagonalMotionEffect *diagonalEffect = [[LensFlareDiagonalMotionEffect alloc] init];
        diagonalEffect.minValue = -20;
        diagonalEffect.maxValue = 30;

        // Group the motion effects together so they get evaluated simultaneously
        UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
        group.motionEffects = @[colorMotion, diagonalEffect];
        [blob addMotionEffect:group];
        
        [self addSubview:blob];
        
        pointOnHypontenuse += _randomFloat(flareSize * .7, flareSize * .7 + 80);
    } while (pointOnHypontenuse < hypotenuse);
}

@end



@implementation LensFlareBlob

+(Class)layerClass {
    return [CAShapeLayer class];
}

- (id)initWithFrame:(CGRect)frame points:(NSInteger)numberOfPoints startAngle:(CGFloat)angle {
    if (numberOfPoints < 3) {
        NSLog(@"points must be 3 or greater");
        return nil;
    }
    
    // Make us square
    frame.size.height = frame.size.width;
    
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.clipsToBounds = YES;
        NSInteger pointsDrawn = 0;
        UIBezierPath *path = [UIBezierPath bezierPath];
        CGFloat radius = CGRectGetWidth(self.bounds) / 2.0;
        CGPoint p = CGPointMake(radius * cosf(angle) + radius, radius * sinf(angle) + radius);
        [path moveToPoint:p];
        do {
            pointsDrawn++;
            angle += (M_PI * 2) / numberOfPoints;
            p = CGPointMake(radius * cosf(angle) + radius, radius * sinf(angle) + radius);
            [path addLineToPoint:p];
        } while (pointsDrawn < numberOfPoints);
        
        [path closePath];
        
        CAShapeLayer *sl = (CAShapeLayer *)self.layer;
        sl.path = path.CGPath;
    }
    
    return self;
}

@end



@implementation LensFlareDiagonalMotionEffect

- (NSDictionary *)keyPathsAndRelativeValuesForViewerOffset:(UIOffset)viewerOffset {
    // Math!
    CGFloat f = (viewerOffset.horizontal / 2.0) + 0.5;
    CGFloat calculatedValue = self.minValue * (1 - f) + self.maxValue * f;
    
    CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(M_PI_4);
    CGPoint rotatedPoint = CGPointApplyAffineTransform(CGPointMake(calculatedValue, 0), rotationTransform);

    return @{ @"center.x" : @(rotatedPoint.x), @"center.y" : @(rotatedPoint.y) };
}

@end






@implementation LensFlareColorMotionEffect

- (instancetype)initWithColor:(UIColor *)color {
    self = [super init];
    if (self != nil) {
        _color = color;
        
        CGFloat h, b;
        [_color getHue:&h saturation:nil brightness:&b alpha:nil];
        
        _hue = h;
        _brightness = b;
    }
    return self;
}

- (NSDictionary *)keyPathsAndRelativeValuesForViewerOffset:(UIOffset)viewerOffset {
    // Map horizontal movement to brightness and vertical movement to hue. 
    CGFloat hue = 0.0;
    CGFloat brightness = 0.0;
    
    // Math!
    if (viewerOffset.horizontal > 0) {
        brightness = _brightness + (1 - _brightness) * viewerOffset.horizontal;
    }
    else {
        brightness = _brightness + _brightness * viewerOffset.horizontal;
    }
    hue = fabsf(modff(1.0 + _hue + viewerOffset.vertical, &(float){0}));
    
    UIColor *newColor = [UIColor colorWithHue:hue saturation:1.0 brightness:brightness alpha:1.0];
    
    return @{ @"layer.fillColor" : (id)newColor.CGColor };
}

@end
