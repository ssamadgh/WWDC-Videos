
#import "ASCPresentation.h"
#import "ASCTextManager.h"
#import "ASCSlide.h"
#import "Utils.h"
#import <GLKit/GLKMath.h>



@interface MyGlow : CIFilter
{
    CIImage *_inputImage;
    NSNumber * inputRadius;
}

@property (retain, nonatomic) CIImage *inputImage;
@property (retain, nonatomic) NSNumber* inputRadius;
@end


@implementation MyGlow

@synthesize inputImage = _inputImage;
@synthesize inputRadius;

- (NSArray *) attributeKeys
{
    return @[@"inputRadius"];
}

- (CIImage *) outputImage
{
    CIImage *input = [self valueForKey:@"inputImage"];
    
    if(!input) return nil;
    
    CIFilter *monochrome = [CIFilter filterWithName:@"CIColorMatrix"];
    [monochrome setDefaults];
    [monochrome setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:1] forKey:@"inputRVector"];
    [monochrome setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0.2] forKey:@"inputGVector"];
    [monochrome setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputBVector"];
    [monochrome setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:1] forKey:@"inputAVector"];
    
    [monochrome setValue:input forKey:@"inputImage"];
    CIImage *glowImage = [monochrome valueForKey:@"outputImage"];
    
    CIFilter *blur = [CIFilter filterWithName:@"CIGaussianBlur"];
    [blur setDefaults];
    [blur setValue:glowImage forKey:@"inputImage"];
    CGFloat radius = [self.inputRadius floatValue];
    [blur setValue:radius ? [NSNumber numberWithFloat:radius] : @10.0 forKey:@"inputRadius"];
    
    glowImage = [blur valueForKey:@"outputImage"];
    
    CIFilter *blend = [CIFilter filterWithName:@"CISourceOverCompositing"];
    [blend setDefaults];
    
    [blend setValue:glowImage forKey:@"inputBackgroundImage"];
    [blend setValue:input forKey:@"inputImage"];
    
    return [blend valueForKey:@"outputImage"];
}

@end


@implementation ASCSlideCoreImage

- (NSUInteger) numberOfSteps
{
    return 2;
}

- (void) setup:(ASCPresentation *)controller
{
    ASCTextManager *text = [self setupTextManager:NO];
    [text addText:@"Core Image" withType:ASCTextTypeTitle level:0];
    [text addText:@"CI Filters" withType:ASCTextTypeSubTitle level:0];
    
    [text addText:@"Applies to the node hierarchy" withType:ASCTextTypeBullet level:0];
    [text addText:@"Filter parameters are animatable" withType:ASCTextTypeBullet level:0];
    [text addText:@"Some limitations" withType:ASCTextTypeBullet level:0];
    [text addText:@"aNode.#filters# = @[aCIFilter];" withType:ASCTextTypeCode level:0];
    
    SCNNode *intermediateNode = [SCNNode node];
#define SCALE 0.02
    intermediateNode.scale = SCNVector3Make(SCALE, SCALE, SCALE);
    intermediateNode.position = SCNVector3Make(5, 0, 15);
    intermediateNode.rotation = SCNVector4Make(1, 0, 0, -M_PI/2);
    [self.slideRoot addChildNode:intermediateNode];
    
    SCNNode *rotateNode = [SCNNode node];
    rotateNode.rotation = SCNVector4Make(0, 0, 1, -M_PI/8);
    [intermediateNode addChildNode:rotateNode];
    intermediateNode = rotateNode;
    
    
	SCNScene *scene = [SCNScene sceneNamed:@"hero.dae"];
    
//    //columns
//	SCNScene *scene2 = [SCNScene sceneNamed:@"column.dae"];
//    SCNNode *column = [scene2.rootNode childNodeWithName:@"column" recursively:YES];
//    
//    SCNNode *frontColumns = [SCNNode node];
//    frontColumns.name = @"frontColumns";
//    [intermediateNode addChildNode:frontColumns];
//    
//    SCNNode *backColumns = [SCNNode node];
//    backColumns.name = @"backColumns";
//    [intermediateNode addChildNode:backColumns];
//    
//    float scale = column.scale.x * 0.82;
//    column.scale = SCNVector3Make(scale, scale, scale);
//    
//    int count = 5;
//    float radius = 250;
//    int i;
//    for(i=0; i<count; i++){
//        if(i==3) continue;
//        
//        float angle = i * (M_PI * 2) / count;
//        
//        SCNNode *newColumn = column.clone;
//        
//        newColumn.position = SCNVector3Make(radius * sin(angle), radius * cos(angle), 0);
//        SCNNode * columnGroup =  newColumn.position.y < 0 ? frontColumns : backColumns;
//        [columnGroup addChildNode:newColumn];
//    }
    
    SCNNode *heroGroup = scene.rootNode.clone;
    [intermediateNode addChildNode:heroGroup];
    
    SCNNode *skell = [heroGroup childNodeWithName:@"skell" recursively:YES];
    
    for(NSString *key in [skell animationKeys]){
        CAAnimation *animation = [skell animationForKey:key];
        
        animation.usesSceneTimeBase = NO;
        animation.repeatCount = MAXFLOAT;
        
        [skell addAnimation:animation forKey:key];
    }
}


//steps: blur/ focus far / move camera / focus near
- (void) presentStepIndex:(NSUInteger)index withController:(ASCPresentation *)controller
{
    switch(index){
        case 0:
            ((TextManager*)self.textManager).textGroup.opacity = 1;
            break;
        case 1:
        {
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.5];
            
            
            MyGlow *glow = [[MyGlow alloc] init];
            glow.name=@"myGlow";
            [glow setDefaults];
            NSArray *filters = [NSArray arrayWithObject:glow];
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"filters.myGlow.inputRadius"];
            animation.toValue = [NSNumber numberWithFloat:50];
            animation.fromValue = [NSNumber numberWithFloat:10];
            animation.autoreverses = YES;
            animation.repeatCount = MAXFLOAT;
            animation.duration = 1.0;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            
            
            [glow setValue:[NSNumber numberWithFloat:50] forKey:@"inputRadius"];
            
            SCNNode *sword = [self.slideRoot childNodeWithName:@"sword" recursively:YES];
            
            sword.filters = filters;
            [sword addAnimation:animation forKey:@"filterAnimation"];
            
            //add a blue light
            SCNNode *handle = [self.slideRoot childNodeWithName:@"Bip01_R_Finger0Nub" recursively:YES];
            SCNNode *lightNode = [SCNNode node];
            lightNode.position = SCNVector3Make(0, -100.0, 40.0);
            lightNode.light = [SCNLight light];
            lightNode.light.type = SCNLightTypeOmni;
            lightNode.light.color = [NSColor redColor];
            [lightNode.light setAttribute:@5 forKey:SCNLightAttenuationEndKey];
            [handle addChildNode:lightNode];
            
            [SCNTransaction commit];
            break;
        }
            
    }
}

- (void) orderOut:(ASCPresentation *)controller
{
    SCNNode *cameraNode = controller.cameraHandle;
    cameraNode.constraints = nil;
    
    //restore original hierarchy
    SCNNode *pivot = cameraNode.parentNode;
    [pivot.parentNode addChildNode:cameraNode];
    [pivot removeFromParentNode];
}


#pragma mark -
#pragma mark lighting

- (SCNVector3) mainLightPosition
{
    return SCNVector3Make(10, 3, 0);
}

@end
