
#import "ASCPresentationViewController.h"
#import "ASCSlideTextManager.h"
#import "ASCSlide.h"
#import "Utils.h"

@interface ASCSlideAllNew : ASCSlide
@end

@implementation ASCSlideAllNew

- (void)addText:(NSString *)string atPoint:(NSPoint)p scale:(CGFloat)scale offset:(CGFloat)offset {
    p.y += [self altitude];
    
    //setup materials
    SCNMaterial *front = [SCNMaterial material];
    SCNMaterial *side  = [SCNMaterial material];
    side.diffuse.contents = [NSColor darkGrayColor];
    
    //setup text
    SCNText *text = [SCNText textWithString:string extrusionDepth:5];
    text.font = [NSFont fontWithName:@"Myriad Set BoldItalic" size:50] ?: [NSFont fontWithName:@"Avenir Heavy Oblique" size:50];
    text.flatness = 0.4;
    text.materials = @[front, side, front];

    //setup node
    SCNNode *node = [SCNNode node];
    node.geometry = text;
    node.position = SCNVector3Make(p.x, p.y, 0);
    node.scale = SCNVector3Make(0.02 * scale, 0.02 * scale, 0.02 * scale);
    
    //add
    [self.rootNode addChildNode:node];
    
    //animate
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.z"];
    animation.fromValue = @-10;
    animation.toValue = @10;
    animation.duration = 5.0;
    animation.timeOffset = -offset * animation.duration;
    animation.repeatCount = FLT_MAX;
    [node addAnimation:animation forKey:nil];

    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.keyTimes = @[@0.0, @0.2, @0.9, @1.0];
    opacityAnimation.values = @[@0.0, @1.0, @1.0, @0.0];
    opacityAnimation.duration = animation.duration;
    opacityAnimation.timeOffset = animation.timeOffset;
    opacityAnimation.repeatCount = FLT_MAX;
    [node addAnimation:opacityAnimation forKey:nil];
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentation {
    [self addText:@"Export to DAE" atPoint:NSMakePoint(10,-8) scale:1 offset:0];
    [self addText:@"OpenGL Core Profile" atPoint:NSMakePoint(-16,-7) scale:1 offset:0.05];
    [self addText:@"Warmup" atPoint:NSMakePoint(-12,-10) scale:1 offset:0.1];
    [self addText:@"Constraints" atPoint:NSMakePoint(-10,6) scale:1 offset:0.15];
    [self addText:@"Custom projection" atPoint:NSMakePoint(4,9) scale:1 offset:0.2];
    [self addText:@"Skinning" atPoint:NSMakePoint(-4,8) scale:1 offset:0.25];
    [self addText:@"Morphing" atPoint:NSMakePoint(-3,-8) scale:1 offset:0.3];
    [self addText:@"Performance Statistics" atPoint:NSMakePoint(-1,6) scale:1 offset:0.35];
    [self addText:@"CIFilters" atPoint:NSMakePoint(1,5) scale:1 offset:0.85];
    [self addText:@"GLKit Math" atPoint:NSMakePoint(3,-10) scale:1 offset:0.45];
    [self addText:@"Depth of Field" atPoint:NSMakePoint(-0.5,0) scale:1 offset:0.47];
    [self addText:@"Animation Events" atPoint:NSMakePoint(5,3) scale:1 offset:0.50];
    [self addText:@"Shader Modifiers" atPoint:NSMakePoint(7,2) scale:1 offset:0.95];
    [self addText:@"GOBO" atPoint:NSMakePoint(-10,1) scale:1 offset:0.60];
    [self addText:@"Ray testing" atPoint:NSMakePoint(-8,0) scale:1 offset:0.65];
    [self addText:@"Skybox" atPoint:NSMakePoint(8,-1) scale:1 offset:0.7];
    [self addText:@"Fresnel" atPoint:NSMakePoint(6,-2) scale:1 offset:0.75];
    [self addText:@"SCNShape" atPoint:NSMakePoint(-6,-3) scale:1 offset:0.8];
    [self addText:@"Levels of detail" atPoint:NSMakePoint(-11,3) scale:1 offset:0.9];
    [self addText:@"Animation blending" atPoint:NSMakePoint(-2,-5) scale:1 offset:1];
}

@end
