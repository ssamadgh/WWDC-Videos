/*
     File: TTTGameView.m
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

#import "TTTGameView.h"

#import "TTTGame.h"

@interface TTTGameLineView : UIView
@property (copy, nonatomic) UIBezierPath *path;
@property (strong, nonatomic) UIColor *color;
@end

@implementation TTTGameView {
    NSArray *_horizontalLineViews;
    NSArray *_verticalLineViews;
    NSMutableArray *_moveImageViews;
    NSMutableArray *_moveImageViewReuseQueue;
    TTTGameLineView *_lineView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _gridColor = [UIColor blackColor];
        _horizontalLineViews = @[[self lineView], [self lineView]];
        _verticalLineViews = @[[self lineView], [self lineView]];
        [self updateGridColor];
        
        _moveImageViews = [[NSMutableArray alloc] init];
        _moveImageViewReuseQueue = [[NSMutableArray alloc] init];
        
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGame:)];
        [self addGestureRecognizer:gestureRecognizer];
    }
    return self;
}

- (UIView *)lineView
{
    UIView *view = [[UIView alloc] init];
    [self addSubview:view];
    return view;
}

- (void)tapGame:(UITapGestureRecognizer *)gestureRecognizer
{
    if ((gestureRecognizer.state == UIGestureRecognizerStateRecognized) && [self.delegate respondsToSelector:@selector(gameView:didSelectXPosition:yPosition:)]) {
        CGPoint point = [gestureRecognizer locationInView:self];
        CGRect bounds = self.bounds;
        
        CGPoint normalizedPoint = point;
        normalizedPoint.x -= CGRectGetMidX(bounds);
        normalizedPoint.x *= 3.0 / bounds.size.width;
        normalizedPoint.x = round(normalizedPoint.x);
        normalizedPoint.x = MAX(normalizedPoint.x, -1);
        normalizedPoint.x = MIN(normalizedPoint.x, 1);
        TTTMoveXPosition xPosition = normalizedPoint.x;
        
        normalizedPoint.y -= CGRectGetMidY(bounds);
        normalizedPoint.y *= 3.0 / bounds.size.height;
        normalizedPoint.y = round(normalizedPoint.y);
        normalizedPoint.y = MAX(normalizedPoint.y, -1);
        normalizedPoint.y = MIN(normalizedPoint.y, 1);
        TTTMoveYPosition yPosition = normalizedPoint.y;
        
        if (![self.delegate respondsToSelector:@selector(gameView:canSelectXPosition:yPosition:)] || [self.delegate gameView:self canSelectXPosition:xPosition yPosition:yPosition]) {
            [self.delegate gameView:self didSelectXPosition:xPosition yPosition:yPosition];
        }
    }
}

- (void)setGame:(TTTGame *)value
{
    if (_game != value) {
        _game = value;
        [self updateGameState];
    }
}

- (UIImageView *)moveImageView
{
    UIImageView *moveView = [_moveImageViewReuseQueue firstObject];
    if (moveView) {
        [_moveImageViewReuseQueue removeObject:moveView];
    } else {
        moveView = [[UIImageView alloc] init];
        [self addSubview:moveView];
    }
    [_moveImageViews addObject:moveView];
    return moveView;
}

- (CGPoint)pointForXPosition:(TTTMoveXPosition)xPosition yPosition:(TTTMoveYPosition)yPosition
{
    CGRect bounds = self.bounds;
    CGPoint point = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    point.x += xPosition * bounds.size.width / 3.0;
    point.y += yPosition * bounds.size.height / 3.0;
    return point;
}

- (void)setMove:(TTTMove *)move forView:(UIImageView *)moveView
{
    moveView.image = [self.delegate gameView:self imageForPlayer:move.player];
    moveView.center = [self pointForXPosition:move.xPosition yPosition:move.yPosition];
}

- (void)setVisible:(BOOL)visible forView:(UIImageView *)moveView
{
    if (visible) {
        [moveView sizeToFit];
        moveView.alpha = 1.0;
    } else {
        moveView.bounds = CGRectZero;
        moveView.alpha = 0.0;
    }
}

- (void)updateGameState
{
    NSArray *moves = self.game.moves;
    NSInteger moveCount = moves.count;
    [[_moveImageViews copy] enumerateObjectsUsingBlock:^(UIImageView *moveView, NSUInteger viewIndex, BOOL *stop) {
        if (viewIndex < moveCount) {
            TTTMove *move = moves[viewIndex];
            [self setMove:move forView:moveView];
            [self setVisible:YES forView:moveView];
        } else {
            [self setVisible:NO forView:moveView];
            [_moveImageViewReuseQueue addObject:moveView];
            [_moveImageViews removeObject:moveView];
        }
    }];
    
    for (NSInteger moveIndex = _moveImageViews.count; moveIndex < moveCount; moveIndex++) {
        TTTMove *move = moves[moveIndex];
        UIImageView *moveView = [self moveImageView];
        [UIView performWithoutAnimation:^{
            [self setMove:move forView:moveView];
            [self setVisible:NO forView:moveView];
        }];
        
        [self setVisible:YES forView:moveView];
    }
    
    TTTMovePlayer winningPlayer;
    TTTMoveXPosition startXPosition, endXPosition;
    TTTMoveYPosition startYPosition, endYPosition;
    BOOL hasWinner = [self.game getWinningPlayer:&winningPlayer startXPosition:&startXPosition startYPosition:&startYPosition endXPosition:&endXPosition endYPosition:&endYPosition];
    if (hasWinner) {
        if (!_lineView) {
            _lineView = [[TTTGameLineView alloc] init];
            _lineView.alpha = 0.0;
            [self addSubview:_lineView];
        }
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:[self pointForXPosition:startXPosition yPosition:startYPosition]];
        [path addLineToPoint:[self pointForXPosition:endXPosition yPosition:endYPosition]];
        _lineView.path = path;
        _lineView.color = [self.delegate gameView:self colorForPlayer:winningPlayer];
    }
    _lineView.alpha = (hasWinner ? 1.0 : 0.0);
}

static CGFloat const TTTGameViewLineWidth = 4.0;

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    [_horizontalLineViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger viewIndex, BOOL *stop) {
        view.bounds = CGRectMake(0.0, 0.0, bounds.size.width, TTTGameViewLineWidth);
        view.center = CGPointMake(CGRectGetMidX(bounds), round(bounds.size.height * (viewIndex + 1) / 3.0));
    }];
    [_verticalLineViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger viewIndex, BOOL *stop) {
        view.bounds = CGRectMake(0.0, 0.0, TTTGameViewLineWidth, bounds.size.height);
        view.center = CGPointMake(round(bounds.size.width * (viewIndex + 1) / 3.0), CGRectGetMidY(bounds));
    }];
    [self updateGameState];
}

- (void)setGridColor:(UIColor *)value
{
    if (![_gridColor isEqual:value]) {
        _gridColor = value;
        [self updateGridColor];
    }
}

- (void)updateGridColor
{
    for (UIView *view in _horizontalLineViews) {
        view.backgroundColor = self.gridColor;
    }
    for (UIView *view in _verticalLineViews) {
        view.backgroundColor = self.gridColor;
    }
}

@end

@implementation TTTGameLineView

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (CAShapeLayer *)shapeLayer
{
    return (CAShapeLayer *)[self layer];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.shapeLayer.lineWidth = 2.0;
    }
    return self;
}

- (void)setPath:(UIBezierPath *)value
{
    if (_path != value) {
        _path = [value copy];
        self.shapeLayer.path = [_path CGPath];
    }
}

- (void)setColor:(UIColor *)value
{
    if (![_color isEqual:value]) {
        _color = value;
        self.shapeLayer.strokeColor = [_color CGColor];
    }
}

@end
