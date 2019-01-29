
#import "ASCPresentation.h"
#import "ASCTextManager.h"
#import "ASCSlide.h"
#import "Utils.h"

#define TEST_13810403 0

@interface SlideShaderModifiers ()
@property (retain) SCNNode *virus;
@end

@implementation ASCSlideShaderModifiers

- (void) setup:(ASCPresentation *)controller
{
    ASCTextManager *text = [self textManager];
    [text addText:@"Shader Modifiers" withType:ASCTextTypeTitle level:0];
    
    [text addText:@"Inject custom GLSL code" withType:ASCTextTypeBullet level:0];
    [text addText:@"Combines with Scene Kit’s rendering" withType:ASCTextTypeBullet level:0];
    [text addText:@"Inject at specific entry points" withType:ASCTextTypeBullet level:0];
    
    SCNSphere *sphereGeom = [SCNSphere sphereWithRadius:3];
    [sphereGeom setSegmentCount:150];

    self.virus = [SCNNode nodeWithGeometry:sphereGeom];
    self.virus.geometry = sphereGeom;
    self.virus.position = SCNVector3Make(3, 4, 7);
    [self.ground addChildNode:self.virus];
    
    //redraw forever
    controller.view.playing = YES;
    controller.view.loops = YES;

    NSString *geomSrc = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sm_geom" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
    NSString *surfSrc = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sm_surf" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
    NSString *liteSrc = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sm_light" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
    NSString *fragSrc = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sm_frag" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
    self.virus.geometry.firstMaterial.specular.contents = [NSColor whiteColor];
    self.virus.geometry.firstMaterial.shaderModifiers = @{
                                                    SCNShaderModifierEntryPointGeometry : geomSrc,
                                                    SCNShaderModifierEntryPointSurface : surfSrc,
                                                    SCNShaderModifierEntryPointLightingModel : liteSrc,
                                                    SCNShaderModifierEntryPointFragment : fragSrc
                                                    };

    //start hidden
    self.virus.opacity = 0.0;
}

- (NSUInteger) numberOfSteps
{
    return 7;
}

- (void) presentStepIndex:(NSUInteger)index withController:(ASCPresentation *)controller
{
    ASCTextManager *text = self.textManager;
    
    [SCNTransaction begin];
    
    
    switch (index) {
        case 0:
            controller.showNewBadge = YES;
            break;
        case 1:
        {
            [text flipOutTextType:ASCTextTypeBullet];
            
            [text addText:@"Entry Points" withType:ASCTextTypeSubTitle level:0];

            [text addText:@"Geometry" withType:ASCTextTypeBullet level:0];
            [text addText:@"Surface" withType:ASCTextTypeBullet level:0];
            [text addText:@"Lighting" withType:ASCTextTypeBullet level:0];
            [text addText:@"Fragment" withType:ASCTextTypeBullet level:0];
            [text flipInTextType:ASCTextTypeBullet];
        }
            break;

        case 2: // Geometry
        {
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1];
            self.virus.opacity = 1.0;
            [self.virus.geometry.firstMaterial setValue:@1.0 forKey:@"geomIntensity"];
            [SCNTransaction commit];
            
            //geometry
            [text highlightBulletAtIndex:0];
            
            
            //add code
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0];
            SCNVector3 textPos = SCNVector3Make(8, 8, 0);
            
            SCNNode *textNode = [text addText:@"myMaterial.shaderModifiers = @{" withType:ASCTextTypeCode level:0];
            textNode.position = textPos;
            textNode = [text addText:@"    #SCNShaderModifierEntryPointGeometry# : " withType:ASCTextTypeCode level:0];
            textNode.position = textPos;
            textNode = [text addText:@"    @\"float len = length(#_geometry#.position.xy);" withType:ASCTextTypeCode level:0];
            textNode.position = textPos;
            textNode = [text addText:@"    _geometry.position.z = sin(6.0 * (len + u_time));" withType:ASCTextTypeCode level:0];
            textNode.position = textPos;
            textNode = [text addText:@"    [...] \"};" withType:ASCTextTypeCode level:0];
            textNode.position = textPos;
            
            [SCNTransaction commit];
        }
            break;
        case 3: // Surface
        {
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1];
            [self.virus.geometry.firstMaterial setValue:@1.0 forKey:@"surfIntensity"];
            [SCNTransaction commit];
            
            //remove code
            [text fadeOutTextType:ASCTextTypeCode];
            [text highlightBulletAtIndex:1];
            
            // Add Code example
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0];
            SCNVector3 textPos = SCNVector3Make(8, 6, 0);
            
            SCNNode *textNode = [text addText:@"myMaterial.shaderModifiers = @{" withType:ASCTextTypeCode level:0];
            textNode.position = textPos;
            textNode = [text addText:@"    #SCNShaderModifierEntryPointSurface# : " withType:ASCTextTypeCode level:0];
            textNode.position = textPos;
            textNode = [text addText:@"    @\"#uniform# float myFactor=1.0;" withType:ASCTextTypeCode level:0];
            textNode.position = textPos;
            textNode = [text addText:@"    [...] \"};" withType:ASCTextTypeCode level:0];
            textNode.position = textPos;
            
            [SCNTransaction commit];
        }
        break;
            

        case 4: // Lighting
        {
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1];
            [self.virus.geometry.firstMaterial setValue:@1.0 forKey:@"lightIntensity"];
            [SCNTransaction commit];
            
            [text fadeOutTextType:ASCTextTypeCode];
            [text highlightBulletAtIndex:2];
            
            // Add Code example
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0];
            SCNVector3 textPos = SCNVector3Make(8, 6, 0);

            SCNNode *textNode = [text addText:@"myMaterial.shaderModifiers = @{" withType:ASCTextTypeCode level:0];
            textNode.position = textPos;
            textNode = [text addText:@"    #SCNShaderModifierEntryPointLighting# : " withType:ASCTextTypeCode level:0];
            textNode.position = textPos;
            textNode = [text addText:@"    @\"#uniform# float myFactor=1.0;" withType:ASCTextTypeCode level:0];
            textNode.position = textPos;
            textNode = [text addText:@"    [...] \"};" withType:ASCTextTypeCode level:0];
            textNode.position = textPos;

            [SCNTransaction commit];
            
        } break;
        case 5: // Fragment
        {
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1];
            [self.virus.geometry.firstMaterial setValue:@1.0 forKey:@"fragIntensity"];
            [SCNTransaction commit];
            
            [text fadeOutTextType:ASCTextTypeCode];
            [text highlightBulletAtIndex:3];
            
            // Add Code example
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0];
            SCNVector3 textPos = SCNVector3Make(8, 6, 0);

            SCNNode *textNode = [text addText:@"myMaterial.shaderModifiers = @{" withType:ASCTextTypeCode level:0];
            textNode.position = textPos;
            textNode = [text addText:@"    #SCNShaderModifierEntryPointFragment# : " withType:ASCTextTypeCode level:0];
            textNode.position = textPos;
            textNode = [text addText:@"    @\"#uniform# float myFactor=1.0;" withType:ASCTextTypeCode level:0];
            textNode.position = textPos;
            textNode = [text addText:@"    [...] \"};" withType:ASCTextTypeCode level:0];
            textNode.position = textPos;

            [SCNTransaction commit];
        }
            break;
            
        case 6: // Conclusion
        {
            [SCNTransaction setAnimationDuration:1.0];
            self.virus.opacity = 0.0;

            [text fadeOutTextType:ASCTextTypeCode];
            [text flipOutTextType:ASCTextTypeBullet];
            [text flipOutTextType:ASCTextTypeSubTitle];
            
            [text addText:@"SCNShadable" withType:ASCTextTypeSubTitle level:0];
            [text addText:@"Shaders parameters are animatable" withType:ASCTextTypeBullet level:0];
            [text addText:@"protocol adopted by SCNMaterial and SCNGeometry" withType:ASCTextTypeBullet level:0];
            
            [text flipInTextType:ASCTextTypeSubTitle];
            [text flipInTextType:ASCTextTypeBullet];
        } break;
    }
    
    [SCNTransaction commit];
}

//- (NSArray *) lightIntensities
//{
//    return @[@0.0, @0.0, @1.0];
//}

- (void) orderOut:(ASCPresentation *)controller
{
    controller.view.playing = NO;
}

@end
