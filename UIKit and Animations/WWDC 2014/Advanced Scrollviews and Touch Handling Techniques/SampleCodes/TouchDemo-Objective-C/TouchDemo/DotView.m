//
//  DotView.m
//  TouchDemo
//
//  Created by Antonio081014 on 8/22/15.
//  Copyright (c) 2015 antonio081014.com. All rights reserved.
//

#import "DotView.h"

@interface UIColor (Conversion)
- (UIColor *)lighterColorWithFactor:(CGFloat)factor;
- (UIColor *)darkerColorWithFactor:(CGFloat)factor;
@end

@implementation UIColor (Conversion)

- (UIColor *)lighterColorWithFactor:(CGFloat)factor
{
    CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
    UIColor *lightColor = [UIColor whiteColor];
    
    CGFloat hue = 0.f;
    CGFloat saturation = 0.f;
    CGFloat brightness = 0.f;
    CGFloat alpha = 0.f;
    CGFloat white = 0.f;
    
    switch (colorSpaceModel) {
        case kCGColorSpaceModelRGB:
            if ([self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
                saturation -= saturation * factor;
                brightness += (1.0 - brightness) * factor;
                lightColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
            }
            break;
        case kCGColorSpaceModelMonochrome:
            if ([self getWhite:&white alpha:&alpha]) {
                white += factor;
                white = (white > 1.0) ? 1.0 : white; // set max white
                lightColor = [UIColor colorWithWhite:white alpha:alpha];
            }
            break;
        default:
            break;
    }
    
    return lightColor;
}

- (UIColor *)darkerColorWithFactor:(CGFloat)factor
{
    CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
    UIColor *darkerColor = [UIColor whiteColor];
    
    CGFloat hue = 0.f;
    CGFloat saturation = 0.f;
    CGFloat brightness = 0.f;
    CGFloat alpha = 0.f;
    CGFloat white = 0.f;
    
    switch (colorSpaceModel) {
        case kCGColorSpaceModelRGB:
            if ([self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
                brightness -= brightness * factor;
                saturation += (1.0 - saturation) * factor;
                darkerColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
            }
            break;
        case kCGColorSpaceModelMonochrome:
            if ([self getWhite:&white alpha:&alpha]) {
                white -= factor;
                white = (white < 0.0) ? 0.0 : white; // set min white
                darkerColor = [UIColor colorWithWhite:white alpha:alpha];
            }
            break;
        default:
            break;
    }
    
    return darkerColor;
}

@end

@interface DotView()
@property (nonatomic, copy) UIColor *color;
@property (nonatomic) CGFloat radius;
@property (nonatomic) BOOL highlighted;
@end

@implementation DotView

static const CGFloat kMinimumDotRadius = 10.f;
static const CGFloat kMaximumDotRadius = 44.f;

#pragma mark - Initializer
/// Designated Initializer
- (instancetype)initWithColor:(UIColor *)aColor withRadius:(CGFloat)radius
{
    if (self = [super initWithFrame:CGRectMake(0, 0, radius * 2, radius * 2)]) {
        self.color = aColor;
        self.radius = radius;
        self.highlighted = NO;
        self.layer.cornerRadius = radius;
    }
    return self;
}

/// Convenience Initializer
- (instancetype)init
{
    CGFloat radius = [DotView randomValueFromMinValue:kMinimumDotRadius toMaxValue:kMaximumDotRadius];
    UIColor *color = [UIColor colorWithRed:(arc4random() % 256) / 255.f green:(arc4random() % 256) / 255.f blue:(arc4random() % 256) / 255.f alpha:1.f];
    return [self initWithColor:color withRadius:radius];
}

#pragma mark - Setter
- (void)setHighlighted:(BOOL)highlighted
{
    _highlighted = highlighted;
    // update the view;
    self.backgroundColor = highlighted ? [self.color darkerColorWithFactor:0.5] : self.color;
}

- (void)setColor:(UIColor *)color
{
    _color = [color copy];
    self.backgroundColor = color;
}

#pragma mark - Class Initializer
+ (DotView *)randomDotView
{
    return [[DotView alloc] init];
}

#pragma mark - Arrange Dots in View
+ (void)arrangeDotsRandomlyInView:(UIView *)containerView
{
    for (UIView *subView in containerView.subviews) {
        if ([subView isKindOfClass:[self class]]) {
            DotView *view = (DotView *)subView;
            CGFloat diameter = MAX(CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds)) / 2;
            CGFloat x = [DotView randomValueFromMinValue:diameter toMaxValue:(CGRectGetWidth(containerView.bounds) - diameter)];
            CGFloat y = [DotView randomValueFromMinValue:diameter toMaxValue:(CGRectGetHeight(containerView.bounds) - diameter)];
            view.center = CGPointMake(x, y);
        }
    }
}

+ (void)arrangeDotsNeatlyInView:(UIView *)containerView
{
    CGFloat width = CGRectGetWidth(containerView.bounds);
    NSUInteger horizontalSlotCount = (NSUInteger)(width / kMaximumDotRadius / 2);
    CGFloat totalSlotSpacing = width - 2.f * kMaximumDotRadius * horizontalSlotCount;
    CGFloat slotSpacing = totalSlotSpacing / horizontalSlotCount;
    
    CGFloat dotSlotSide = kMaximumDotRadius * 2.f + slotSpacing;
    CGFloat halfDotSlotSide = dotSlotSide / 2.0;
    
    CGFloat initialX = halfDotSlotSide;
    CGFloat initialY = halfDotSlotSide;
    
    for (UIView *view in containerView.subviews) {
        if ([view isKindOfClass:[self class]]) {
            DotView *dot = (DotView *)view;
            CGFloat neatX = initialX;
            CGFloat neatY = initialY;
            dot.center = CGPointMake(neatX, neatY);
            
            initialX = initialX + dotSlotSide;
            if (initialX >= containerView.bounds.size.width) {
                initialX = halfDotSlotSide;
                initialY = initialY + dotSlotSide;
            }
        }
    }
}

+ (void)arrangeDotsNeatlyInViewWithNiftyAnimation:(UIView *)containerView
{
    [UIView animateWithDuration:.4f animations:^{
        [self arrangeDotsNeatlyInView:containerView];
    }];
}

#pragma mark - Override Touch Event Function
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = YES;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = NO;
}

/// Override function in UIView.
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect touchBounds = self.bounds;
    if (self.radius < 22.f) {
        CGFloat expansion = 22.f - self.radius;
        touchBounds = CGRectInset(touchBounds, -expansion, -expansion);
    }
    return CGRectContainsPoint(touchBounds, point);
}

#pragma mark - Assistant Function
+ (CGFloat)randomValueFromMinValue:(NSInteger)minValue toMaxValue:(NSInteger)maxValue
{
    return (CGFloat)((arc4random() % (maxValue - minValue)) + minValue);
}

@end
