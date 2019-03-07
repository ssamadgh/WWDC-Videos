/*
     File: APLShipSprite.m
 Abstract: 
 This class adds game logic for a ship sprite.
 
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

#import "APLShipSprite.h"
#import "APLSpaceScene.h"

/* Constants used to adjust ship behavior */
/* In an actual game, instead of hard coding these, you might want to load them from a property list */

static const NSInteger startingShipHealth = 10; 
static const NSInteger showDamageBelowHealth = 4;

// Used to configure a ship explosion.
static const CFTimeInterval shipExplosionDuration = 0.6;
static const CGFloat shipChunkMinimumSpeed = 300;
static const CGFloat shipChunkMaximumSpeed = 750;
static const CGFloat shipChunkDispersion = 30;
static const NSUInteger numberOfChunks = 30;
static const CGFloat removeShipTime = 0.35;

// Used to control the ship, usually by applying physics forces to the ship.
static const CGFloat mainEngineThrust = 0.12;
static const CGFloat reverseThrust = 0.03;
static const CGFloat lateralThrust = 0.01;
static const CGFloat firingInterval = 0.1;
static const CGFloat missileLaunchDistance = 45;
static const CGFloat engineIdleAlpha = 0.05;
static const CGFloat missileLaunchImpulse = 0.5;


// Useful random functions.
static inline CGFloat myRandf() {
    return rand() / (CGFloat) RAND_MAX;
}

static inline CGFloat myRand(CGFloat low, CGFloat high) {
    return myRandf() * (high - low) + low;
}

// This enables debug code to show the bounding shape of the ship superimposed over the sprite.
#define SHOW_SHIP_PHYSICS_OVERLAY 0


@interface APLShipSprite()
// Child nodes used to add effects to the ship.
@property SKEmitterNode*    exhaustNode;
@property SKEmitterNode*    visibleDamageNode;

@property CGFloat           engineEngagedAlpha;
@property CFTimeInterval    timeLastFiredMissile;
@end

@implementation APLShipSprite

+ (id) createShip
{
    APLShipSprite* ship = [APLShipSprite spriteNodeWithImageNamed:@"spaceship.png"];
    
    // This is a bounding shape that approximates the rocket.
    CGMutablePathRef boundingPath = CGPathCreateMutable();
    CGPathMoveToPoint(boundingPath, NULL, -12, -38);
    CGPathAddLineToPoint(boundingPath, NULL, 12, -38);
    CGPathAddLineToPoint(boundingPath, NULL, 9, +18);
    CGPathAddLineToPoint(boundingPath, NULL, 2, +38);
    CGPathAddLineToPoint(boundingPath, NULL, -2, +38);
    CGPathAddLineToPoint(boundingPath, NULL, -9, +18);
    CGPathAddLineToPoint(boundingPath, NULL, -12, -38);
    
#if SHOW_SHIP_PHYSICS_OVERLAY
    SKShapeNode *shipOverlayShape = [[SKShapeNode alloc] init];
    shipOverlayShape.path = boundingPath;
    shipOverlayShape.strokeColor = [SKColor clearColor];
    shipOverlayShape.fillColor = [SKColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.5];
    [ship addChild:shipOverlayShape];
#endif
    
    ship.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:boundingPath];
    CGPathRelease(boundingPath);
    
    ship.physicsBody.categoryBitMask = shipCategory;
    ship.physicsBody.collisionBitMask = shipCategory | asteroidCategory | planetCategory | edgeCategory;
    ship.physicsBody.contactTestBitMask = shipCategory | asteroidCategory | planetCategory | edgeCategory;
    
    // The ship doesn't slow down when it moves forward, but it does slow its angular rotation. In practice,
    // this feels better for a game.
    ship.physicsBody.linearDamping = 0;
    ship.physicsBody.angularDamping = 0.5;
    

    
    return ship;
}

- (id)initWithTexture:(SKTexture *)texture color:(SKColor *)color size:(CGSize)size
{
    if (self = [super initWithTexture:texture color: color size: size]) {
        _health = startingShipHealth;
    }
    return self;
}

- (void) showDamage
{
    // When the ship first shows damage, a damage node is created and added as a child.
    // If it takes more damage, then the number of particles is increased.
    
    if (!self.visibleDamageNode)
    {
        self.visibleDamageNode =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"damage" ofType:@"sks"]];
        
        self.visibleDamageNode.name = @"damaged";
        
        // Make the scene the target node because the ship is moving around in the scene. Smoke particles
        // should be spawned based on the ship, but should otherwise exist independently of the ship.
        
        self.visibleDamageNode.targetNode = self.scene;
        
        [self addChild:self.visibleDamageNode];
    }
    else
    {
        self.visibleDamageNode.particleBirthRate = self.visibleDamageNode.particleBirthRate * 2;
    }
}

- (void) makeExhaustNode
{
    SKEmitterNode *emitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"exhaust" ofType:@"sks"]];
    
    // Hard coded position at the back of the ship.
    emitter.position = CGPointMake(0,-40);
    emitter.name = @"exhaust";
    
    // Make the scene the target node because the ship is moving around in the scene. Exhaust particles
    // should be spawned based on the ship, but should otherwise exist independently of the ship.
    
    emitter.targetNode = self.scene;
    
    // The exhaust node is always emitting particles, but the alpha of the particles is adjusted depending on whether
    // the engines are engaged or not. This adds a subtle effect when the ship is idling.
    
    self.engineEngagedAlpha = emitter.particleAlpha;
    emitter.particleAlpha = engineIdleAlpha;
    
    [self addChild:emitter];
    self.exhaustNode = emitter;
}

- (void)makeExhaustNodeIfNeeded
{
    if (!self.exhaustNode)
    {
        [self makeExhaustNode];
    }
}

- (void) applyDamage: (NSInteger) amount
{
    // If the ship takes too much damage, blow it up. Otherwise, decrement the health (and show damage if necessary).
    if (amount >= _health)
    {
        if (_health > 0)
        {
            _health = 0;
            [self explode];
        }
    }
    else
    {
        _health -= amount;
        if (_health < showDamageBelowHealth)
        {
            [self showDamage];
        }
    }
}

- (void)explode
{
    // Create a bunch of explosion emitters and send them flying in all directions. Then remove the ship from the scene.
    
    APLSpaceScene *scene = (APLSpaceScene*) self.scene;
    
    for (int i = 0; i < numberOfChunks; i++)
    {
        SKEmitterNode *explosion = [scene newExplosionNode: shipExplosionDuration];
        CGFloat angle = myRand(0,M_PI*2);
        CGFloat speed = myRand(shipChunkMinimumSpeed,shipChunkMaximumSpeed);
        
        explosion.position = CGPointMake(myRand(self.position.x-shipChunkDispersion, self.position.x+shipChunkDispersion),
                                         myRand(self.position.y-shipChunkDispersion, self.position.y+shipChunkDispersion));
        
        // Use the physics system to animate the movement of the explosion chunks. As implemented, these chunks do not
        // collide or hit anything.
        explosion.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:0.25];
        explosion.physicsBody.collisionBitMask = 0;
        explosion.physicsBody.contactTestBitMask = 0;
        explosion.physicsBody.categoryBitMask = 0;
        
        explosion.physicsBody.velocity = CGPointMake(cos(angle)*speed,sin(angle)*speed);
        [scene addChild:explosion];
    }
    
    // Once the ship is covered with particles it is removed.
    [self runAction:[SKAction sequence:@[[SKAction waitForDuration:removeShipTime],[SKAction removeFromParent]]]];
}

- (CGFloat)shipOrientation
{
    // The ship art is oriented so that it faces the top of the scene, but Sprite Kit's rotation default is to the right.
    // This method calculates the ship orientation for use in other calculations.
    return self.zRotation + M_PI_2;
}

- (CGFloat)shipExhaustAngle
{
    // The ship art is oriented so that it faces the top of the scene, but Sprite Kit's rotation default is to the right.
    // This method calculates the direction for the ship's rear.
   return self.zRotation - M_PI_2;
}


- (void)activateMainEngine
{
    /*
     Add flames out the back and apply thrust to the ship.
     */
    
    CGFloat shipDirection = [self shipOrientation];
    [self.physicsBody applyImpulse:CGPointMake(mainEngineThrust*cosf(shipDirection), mainEngineThrust*sinf(shipDirection))];
    
    [self makeExhaustNodeIfNeeded];
    self.exhaustNode.particleAlpha = self.engineEngagedAlpha;
    self.exhaustNode.emissionAngle = [self shipExhaustAngle];
}

- (void)deactivateMainEngine
{
    /*
     Cut the engine exhaust.
     */
    
    [self makeExhaustNodeIfNeeded];
    self.exhaustNode.particleAlpha = engineIdleAlpha;
    self.exhaustNode.emissionAngle = [self shipExhaustAngle];
}

- (void)reverseThrust
{
    /*
     Apply a small amount of thrust to reduce the ship's speed. (No visible special effect).
     */
    
    CGFloat reverseDirection = [self shipOrientation] +  M_PI;
    
    // calculate an impulse to thrust the ship forward.
    [self.physicsBody applyImpulse:CGPointMake(reverseThrust*cosf(reverseDirection), reverseThrust*sinf(reverseDirection))];
}

- (void)rotateShipLeft
{
    /*
     Apply a small amount of thrust to turn the ship to the left. (No visible special effect).
     */
    [self.physicsBody applyTorque:lateralThrust];
}

- (void)rotateShipRight
{
    /*
     Apply a small amount of thrust to turn the ship to the right. (No visible special effect).
     */
    [self.physicsBody applyTorque:-lateralThrust];
}

- (void)attemptMissileLaunch:(NSTimeInterval)currentTime
{
    /* Fire a missile if there's one ready */
    
    CFTimeInterval timeSinceLastFired = currentTime - self.timeLastFiredMissile;
    if (timeSinceLastFired > firingInterval)
    {
        self.timeLastFiredMissile = currentTime;
        
        CGFloat shipDirection = [self shipOrientation];
        
        APLSpaceScene *scene = (APLSpaceScene*) self.scene;
        
        SKNode *missile = [scene newMissileNode];
        missile.position = CGPointMake(self.position.x + missileLaunchDistance*cosf(shipDirection),
                                       self.position.y + missileLaunchDistance*sinf(shipDirection));
        
        [scene addChild:missile];
        
        // Start with the ship's velocity, and then give it a little kick.
        missile.physicsBody.velocity = self.physicsBody.velocity;
        [missile.physicsBody applyImpulse: CGPointMake(missileLaunchImpulse*cosf(shipDirection),
                                                       missileLaunchImpulse*sinf(shipDirection))];
    }
}


@end
