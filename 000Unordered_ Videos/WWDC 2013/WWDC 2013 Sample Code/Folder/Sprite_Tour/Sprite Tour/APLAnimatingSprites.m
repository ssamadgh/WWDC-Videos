/*
     File: APLAnimatingSprites.m
 Abstract: 
 This scene shows how to animate a sprite through a series of textures.
 
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

#import "APLAnimatingSprites.h"
#import "APLBasicSprites.h"

@interface APLAnimatingSprites()
@property NSArray* walkFrames;
@end

const int kDefaultNumberOfWalkFrames = 28;
const float showCharacterFramesOverOneSecond = 1.0f/(float) kDefaultNumberOfWalkFrames;

@implementation APLAnimatingSprites


- (void)createSceneContents
{
    self.walkFrames = [self animationFramesForImageNamePrefix:@"warrior_walk_" frameCount: kDefaultNumberOfWalkFrames];
    
    // Create the sprite with the initial frame.
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:[self.walkFrames objectAtIndex:0]];
    sprite.position = CGPointMake(CGRectGetMidX(self.frame),
                                  CGRectGetMidY(self.frame));
    [self addChild:sprite];

    // Cycle through the frames.
    SKAction *animateFramesAction = [SKAction animateWithTextures:self.walkFrames
                                              timePerFrame:showCharacterFramesOverOneSecond
                                              resize:YES
                                              restore:NO];
    [sprite runAction: [SKAction repeatActionForever:animateFramesAction]];

    [self addSceneDescriptionLabel];
}


- (NSArray *)animationFramesForImageNamePrefix: (NSString*) baseImageName frameCount: (NSInteger) count
{
/* Loads a series of frames from files stored in the app bundle, returning them in an array. */
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
    for (int i = 1; i<= count; i++)
    {
        NSString *imageName = [NSString stringWithFormat:@"%@%04d.png",baseImageName, i];
        SKTexture *t = [SKTexture textureWithImageNamed:imageName];
        [array addObject:t];
    }
    return array;
}


- (void)addSceneDescriptionLabel
{
    /*
     Add a simple label that describes the scene.
     */
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    myLabel.text = NSLocalizedString(@"This sprite is animating through a series of texture images.", @"");
    myLabel.fontSize = 18;
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),100);
    [self addChild:myLabel];
}


@end
