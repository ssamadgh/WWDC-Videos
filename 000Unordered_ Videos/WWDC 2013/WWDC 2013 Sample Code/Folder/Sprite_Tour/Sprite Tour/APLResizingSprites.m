/*
     File: APLResizingSprites.m
 Abstract: 
 This scene shows how to resize sprites. It shows how the centerRect property can be used to change how the texture
 is scaled and applied to the sprite.
 
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

#import "APLResizingSprites.h"
#import "APLSpriteAnchors.h"


@implementation APLResizingSprites


- (void)createSceneContents
{
    [self addResizingSprites];
}

- (void) addResizingSprites
{
    /*
     Creates a pair of sprites. One uses the default scaling behavior, and the other uses
     a custom center rect. The corners of the UI button are a fixed size, and the remaining
     part of the texture is scaled.
     */
    SKTexture *texture = [SKTexture textureWithImageNamed:@"stretchable_image.png"];
    SKAction *resizeSpritesAction = [self newResizeSpriteAction:texture];
    
    SKSpriteNode *defaultSprite = [[SKSpriteNode alloc] initWithTexture:texture];
    defaultSprite.position = CGPointMake(CGRectGetMidX(self.frame)-192, CGRectGetMidY(self.frame));
    [self addChild:defaultSprite];
    [defaultSprite runAction: resizeSpritesAction];
    [self addDescription:NSLocalizedString(@"Resized with default stretching", @"") toSprite:defaultSprite];
    
    SKSpriteNode *customSprite = [[SKSpriteNode alloc] initWithTexture:texture];
    customSprite.position = CGPointMake(CGRectGetMidX(self.frame)+192,CGRectGetMidY(self.frame));
    // the center rect calculation is always based on the artwork. In this case
    // the artwork is a 28 x 28 pixel image with a 4 x 4 pixel stretchable center.
    customSprite.centerRect = CGRectMake(12.0/28.0,12.0/28.0,4.0/28.0,4.0/28.0);
    [self addChild:customSprite];
    [customSprite runAction: resizeSpritesAction];
    [self addDescription:NSLocalizedString(@"Resized with custom stretching", @"") toSprite:customSprite];
}


- (SKAction *)newResizeSpriteAction:(SKTexture *)texture
{
    /*
     Creates and returns an action sequence that resizes a sprite through a variety of sizes.
     It then returns the sprite back to its normal default size. 
     */
    SKAction *sequence = [SKAction sequence:@[
                             [SKAction waitForDuration:1.0],
                             [SKAction resizeToWidth:192 height:192 duration:1.0],
                             [SKAction waitForDuration:1.0],
                             [SKAction resizeToWidth:128 height:192 duration:1.0],
                             [SKAction waitForDuration:1.0],
                             [SKAction resizeToWidth:256 height:128 duration:1.0],
                             [SKAction waitForDuration:1.0],
                             [SKAction resizeToWidth:texture.size.width height:texture.size.height duration:1.0]
                          ]];
    return [SKAction repeatActionForever:sequence];
}

- (void)addDescription: (NSString*) description toSprite:(SKSpriteNode *)sprite
{
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    myLabel.text = description;
    myLabel.fontSize = 18;
    myLabel.position = CGPointMake(0,-128);
    [sprite addChild:myLabel];
}

@end
