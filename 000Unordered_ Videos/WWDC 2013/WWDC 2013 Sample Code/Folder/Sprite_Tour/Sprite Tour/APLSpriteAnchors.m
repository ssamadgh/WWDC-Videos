/*
     File: APLSpriteAnchors.m
 Abstract: 
 This scene shows how to use anchor points to move the sprite's image relative to its position.
 
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
 
 */

#import "APLSpriteAnchors.h"
#import "APLBlendingSprites.h"



@implementation APLSpriteAnchors


- (void)createSceneContents
{
    [self addAnchorGrid];
    [self addAnimatedAnchor];
    [self addSceneDescriptionLabel];
}

- (void)addAnchorGrid
{
    /*
     Creates a 2-dimensional grid of sprites, each with a different anchor point.
     It shows how a sprite's image moves when the anchor point changes.
     */
    for (int x = 0; x <= 4; x++)
    {
        for (int y = 0; y<= 4; y++)
        {
            SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"rocket.png"];
            [sprite setScale: 0.25];
            sprite.anchorPoint = CGPointMake(0.25*x, 0.25*y);
            sprite.position = CGPointMake(CGRectGetMidX(self.frame)-400+100*x,
                                        CGRectGetMidY(self.frame)-200+100*y);
            [self addChild:sprite];
            [self addAnchorDotToSprite: sprite];
        }
    }
}

- (void)addAnimatedAnchor
{
    /*
     Creates a sprite and animates its anchor point.
     */
    SKSpriteNode *animatedSprite= [SKSpriteNode spriteNodeWithImageNamed:@"rocket.png"];
    
    animatedSprite.position = CGPointMake(CGRectGetMidX(self.frame)+200,
                                        CGRectGetMidY(self.frame));
    animatedSprite.anchorPoint = CGPointZero;
    [self addChild:animatedSprite];
    [self addAnchorDotToSprite: animatedSprite];
    
    [animatedSprite runAction:[self newAnimateAnchorAction]];
}

- (void) addAnchorDotToSprite: (SKSpriteNode*) sprite
{
    // We use a shape node for the dot, using a simple circle.
    SKShapeNode *dot = [[SKShapeNode alloc] init];

    CGMutablePathRef myPath = CGPathCreateMutable();
    CGPathAddArc(myPath, NULL, 0, 0, 3, 0, M_2_PI, YES);
    CGPathCloseSubpath(myPath);

    dot.path = myPath;
    dot.fillColor = [SKColor blueColor];
    dot.lineWidth = 0.0;

    [sprite addChild:dot];
}

- (SKAction *)newAnimateAnchorAction
{
    // Normally, you can't directly animate an anchor point, but you can build a custom action to so do.
    // This method builds a bunch of custom actions, then combines them in a repeating sequence.
    
    SKAction *moveAnchorRight = [SKAction customActionWithDuration:1.0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        SKSpriteNode *sprite = (SKSpriteNode*) node;
        sprite.anchorPoint = CGPointMake(elapsedTime,0.0);
    }];
    
    SKAction *moveAnchorUp = [SKAction customActionWithDuration:1.0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        SKSpriteNode *sprite = (SKSpriteNode*) node;
        sprite.anchorPoint = CGPointMake(1.0,elapsedTime);
    }];
    
    SKAction *moveAnchorLeft = [SKAction customActionWithDuration:1.0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        SKSpriteNode *sprite = (SKSpriteNode*) node;
        sprite.anchorPoint = CGPointMake(1.0-elapsedTime,1.0);
    }];
    
    SKAction *moveAnchorDown = [SKAction customActionWithDuration:1.0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        SKSpriteNode *sprite = (SKSpriteNode*) node;
        sprite.anchorPoint = CGPointMake(0,1.0-elapsedTime);
    }];
    
    SKAction *sequence = [SKAction sequence:@[moveAnchorRight, moveAnchorUp, moveAnchorLeft, moveAnchorDown]];
    return [SKAction repeatActionForever:sequence];
}

- (void)addSceneDescriptionLabel
{
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    myLabel.text = NSLocalizedString(@"The dots mark the actual position of each sprite node.", @"");
    myLabel.fontSize = 18;
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),100);
    [self addChild:myLabel];
}


@end
