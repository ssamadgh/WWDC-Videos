/*
     File: ASCSlideCoreImage.m
 Abstract: Shows an example of how Core Image filters can be used to achieve screen-space effects.
  Version: 1.1
 
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
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#import <GLKit/GLKMath.h>

#import "ASCPresentationViewController.h"
#import "ASCSlideTextManager.h"
#import "ASCSlide.h"
#import "Utils.h"

static NSUInteger const kContactImageCount = 44;
static NSUInteger const kRowCount = 4;
static NSUInteger const kColumnCount = 11;

// Custom Core Image filter that will be used to make the selection glow
@interface ASCGlowFilter : CIFilter

@property (strong, nonatomic) CIImage *inputImage;
@property (strong, nonatomic) NSNumber *inputRadius;
@property (strong, nonatomic) NSNumber *centerX;
@property (strong, nonatomic) NSNumber *centerY;

@end

#pragma mark - Core Image slide

@interface ASCSlideCoreImage : ASCSlide
@end

@implementation ASCSlideCoreImage {
    SCNNode *_groupNode;
    SCNNode *_heroNode;
    CGSize _viewportSize;
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentationViewController {
    // Setup the image grid here to benefit from the preloading mechanism
    [self buildImageGrid];
    
    _viewportSize = [presentationViewController.view convertSizeToBacking:presentationViewController.view.frame.size];
}

- (NSUInteger)numberOfSteps {
    return 7;
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    switch (index) {
        case 0:
            // Set the slide's title and subtitle and add some text
            self.textManager.title = @"Core Image";
            self.textManager.subtitle = @"CI Filters";
            
            [self.textManager addBullet:@"Screen-space effects" atLevel:0];
            [self.textManager addBullet:@"Applies to a node hierarchy" atLevel:0];
            [self.textManager addBullet:@"Filter parameters are animatable" atLevel:0];
            [self.textManager addCode:@"aNode.#filters# = @[filter1, filter2];"];
            break;
        case 1:
        {
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                // Dim the text and move back a little
                self.textManager.textNode.opacity = 0.0;
                presentationViewController.cameraHandle.position = [presentationViewController.cameraNode convertPosition:SCNVector3Make(0, 0, 5.0) toNode:presentationViewController.cameraHandle.parentNode];
            }
            [SCNTransaction commit];
            
            // Reveal the grid
            _groupNode.opacity = 1;
            break;
        }
        case 2:
        {
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                // Highlight an item
                [self highlightContactAtIndex:13 withController:presentationViewController];
            }
            [SCNTransaction commit];
            break;
        }
        case 3:
        {
            __block NSInteger index = 13;
            __block NSInteger subStep = 0;
            
            dispatch_block_t block = ^{
                [SCNTransaction begin];
                [SCNTransaction setAnimationDuration:0.2];
                {
                    [self unhighlightContactAtIndex:index];
                    
                    if (subStep++ == 3) index += kColumnCount;
                    else                index++;
                    
                    [self highlightContactAtIndex:index withController:presentationViewController];
                }
                [SCNTransaction commit];
            };
            
            // Successively select items
            for (NSInteger i = 0; i < 5; ++i) {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * 0.2 * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), block);
            }
            
            break;
        }
        case 4:
        {
            // BLUR+DESATURATE in the background, GLOW in the foreground
            
            // Here we will change the node hierarchy in order to group all the nodes in the background under a single node.
            // This way we can use a single Core Image filter and apply it on the whole grid, and have another CI filter for the node in the foreground.
            
            SCNNode *selectionParent = _heroNode.parentNode;
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.0];
            {
                // Stop the animations of the selected node
                _heroNode.transform = _heroNode.presentationNode.transform; // set the current rotation to the current presentation value
                [_heroNode removeAllAnimations];
                
                // Re-parent the node by preserving its world tranform
                CATransform3D wantedWorldTransform = selectionParent.worldTransform;
                [_groupNode.parentNode addChildNode:selectionParent];
                selectionParent.transform = [selectionParent.parentNode convertTransform:wantedWorldTransform fromNode:nil];
            }
            [SCNTransaction commit];
            
            // Add CIFilters
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            {
                // A negative 'centerX' value means no scaling.
                [_heroNode.filters[0] setValue:@-1 forKey:@"centerX"];
                
                // Move the selection to the foreground
                selectionParent.rotation = SCNVector4Make(0, 1, 0, 0);
                _heroNode.transform = [self.contentNode convertTransform:CATransform3DMakeTranslation(0, self.altitude, 29) toNode:selectionParent];
                _heroNode.scale = SCNVector3Make(1, 1, 1);
                _heroNode.rotation = SCNVector4Make(1, 0, 0, -M_PI_4 * 0.25);
                
                // Upon completion, rotate the selection forever
                [SCNTransaction setCompletionBlock:^{
                    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
                    animation.duration = 4.0;
                    animation.fromValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, 0)];
                    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
                    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                    animation.repeatCount = FLT_MAX;
                    
                    [_heroNode.childNodes[0] addAnimation:animation forKey:nil];
                }];
                
                // Add the filters
                CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
                [blurFilter setDefaults];
                blurFilter.name = @"blur";
                [blurFilter setValue:@0 forKey:kCIInputRadiusKey];
                
                CIFilter *desaturateFilter = [CIFilter filterWithName:@"CIColorControls"];
                [desaturateFilter setDefaults];
                desaturateFilter.name = @"desaturate";
                
                _groupNode.filters = @[blurFilter, desaturateFilter];
            }
            [SCNTransaction commit];
            
            // Increate the blur radius and desaturate progressively
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:2.0];
            {
                [_groupNode setValue:@10 forKeyPath:@"filters.blur.inputRadius"];
                [_groupNode setValue:@0.1 forKeyPath:@"filters.desaturate.inputSaturation"];
            }
            [SCNTransaction commit];
            break;
        }
        case 5:
        {
            // BLUR+CIHatchedScreen in the background, ZOOM+BLUR in the foreground
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.0];
            {
                CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
                [blurFilter setDefaults];
                blurFilter.name = @"blur";
                [blurFilter setValue:@10 forKey:kCIInputRadiusKey];
                
                CIFilter *zoomBlurFilter = [CIFilter filterWithName:@"CIZoomBlur"];
                [zoomBlurFilter setDefaults];
                [zoomBlurFilter setValue:[CIVector vectorWithX:0.5 * _viewportSize.width Y:0.5 * _viewportSize.height] forKey:kCIInputCenterKey];
                zoomBlurFilter.name = @"fx1";
                
                CIFilter *hatchedScreenFilter = [CIFilter filterWithName:@"CIHatchedScreen"];
                [hatchedScreenFilter setDefaults];
                hatchedScreenFilter.name = @"fx2";
                
                // Add filters
                _groupNode.filters = @[blurFilter, hatchedScreenFilter];
                _heroNode.filters = @[zoomBlurFilter];
                
                // Animate them
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"filters.fx2.inputAngle"];
                animation.toValue = @(0.1);
                animation.fromValue = 0;
                animation.autoreverses = YES;
                animation.repeatCount = FLT_MAX;
                animation.duration = 10.0;
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                [_groupNode addAnimation:animation forKey:nil];
                
                animation = [CABasicAnimation animationWithKeyPath:@"filters.fx1.inputAmount"];
                animation.toValue = @40;
                animation.fromValue = @0;
                animation.autoreverses = YES;
                animation.repeatCount = FLT_MAX;
                animation.duration = 1.0;
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                [_heroNode addAnimation:animation forKey:nil];
            }
            [SCNTransaction commit];
            break;
        }
        case 6:
        {
            // BLUR+PIXELATTE in the background, TWIRL in the foreground
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.0];
            {
                CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
                [gaussianBlurFilter setDefaults];
                gaussianBlurFilter.name = @"blur";
                [gaussianBlurFilter setValue:@10 forKey:kCIInputRadiusKey];
                
                CIFilter *twirlDistortionFilter = [CIFilter filterWithName:@"CITwirlDistortion"];
                [twirlDistortionFilter setDefaults];
                twirlDistortionFilter.name = @"fx1";
                [twirlDistortionFilter setValue:[CIVector vectorWithX:0.5 * _viewportSize.width Y:0.5 * _viewportSize.height] forKey:kCIInputCenterKey];
                [twirlDistortionFilter setValue:@1000.0 forKey:kCIInputRadiusKey];
                
                CIFilter *pixellateFilter = [CIFilter filterWithName:@"CIPixellate"];
                [pixellateFilter setDefaults];
                pixellateFilter.name = @"fx2";
                
                // Add filters
                _groupNode.filters = @[pixellateFilter, gaussianBlurFilter];
                _heroNode.filters = @[twirlDistortionFilter];
                
                // Animate them
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"filters.fx1.inputAngle"];
                animation.toValue = @M_PI;
                animation.fromValue = @-M_PI;
                animation.autoreverses = YES;
                animation.repeatCount = FLT_MAX;
                animation.duration = 1.5;
                animation.timeOffset = -0.75;
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                [_heroNode addAnimation:animation forKey:nil];
                
                animation = [CABasicAnimation animationWithKeyPath:@"filters.fx2.inputScale"];
                animation.toValue = @50;
                animation.fromValue = @0;
                animation.autoreverses = YES;
                animation.repeatCount = FLT_MAX;
                animation.duration = 2.0;
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                [_groupNode addAnimation:animation forKey:nil];
            }
            [SCNTransaction commit];
            break;
        }
    }
}

- (SCNVector3) mainLightPosition {
    // For this slide we want the main light to be a little upper
    return SCNVector3Make(0, 3, 0);
}


#pragma mark - Grid

- (void)buildImageGrid {
    // Create a root node for the grid
    _groupNode = [SCNNode node];
    
    // Retrieve the template node to replicate
    SCNScene *scene = [SCNScene sceneNamed:@"contact.dae"];
    SCNNode *templateNode = [scene.rootNode childNodeWithName:@"people" recursively:YES];
    
    for (NSUInteger k = 0, j = 0; j < kRowCount; j++) {
        for (NSUInteger i = 0; i < kColumnCount; i++, k++) {
           
            // Hierarchy : _groupNode > container > node
            SCNNode *container = [SCNNode node];
            SCNNode *node = [templateNode clone];
            node.name = [NSString stringWithFormat:@"contact%lu", k];
            
            [_groupNode addChildNode:container];
            [container addChildNode:node];
            
            if (k == 28)
                _heroNode = node;
            
            // Curved layout
            CGFloat angle = 0.12 * ((kColumnCount - 1) / 2.0 - i);
            CGFloat x = cos(angle + M_PI_2) * 500.0;
            CGFloat z = sin(angle + M_PI_2) * 500.0;
            container.position = SCNVector3Make(x, j * 60, -z + 400);
            container.rotation = SCNVector4Make(0, 1, 0, angle);
            
            // We want a different image on each elemement and to do that we need to
            // unshare the geometry first and then unshare the material
            
            SCNNode *geometryNode = node.childNodes[0];
            geometryNode.geometry = [geometryNode.geometry copy];

            SCNMaterial *materialCopy = [geometryNode.geometry.materials[1] copy];
            materialCopy.diffuse.contents = [NSImage imageNamed:[NSString stringWithFormat:@"contact%lu", k % kContactImageCount]];
            [geometryNode.geometry replaceMaterialAtIndex:1 withMaterial:materialCopy];
        
            // Animate (rotate forever)
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"rotation"];
            animation.duration = 4.0;
            animation.keyTimes = @[@0.0, @0.3, @1.0];
            animation.values = @[[NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, 0)],
                                 [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)],
                                 [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)]];
            
            CAMediaTimingFunction *tf = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animation.timingFunctions = @[tf, tf, tf];
            animation.repeatCount = FLT_MAX;
            animation.beginTime = CACurrentMediaTime() + 1.0 + j * 0.1 + i * 0.05; // desynchronize the animations
            [node addAnimation:animation forKey:nil];
        }
    }
    
    // Add the group to the scene
    _groupNode.scale = SCNVector3Make(0.03, 0.03, 0.03);
    _groupNode.position = SCNVector3Make(0, self.altitude - 2.8, 18);
    _groupNode.opacity = 0.0;

    [self.groundNode addChildNode:_groupNode];
}


// Unhighlight the node at index 'index' by removing its CI filter
- (void)unhighlightContactAtIndex:(NSUInteger)index {
    SCNNode *contactNode = [self.groundNode childNodeWithName:[NSString stringWithFormat:@"contact%d", (int)index] recursively:YES];
    contactNode.filters = nil;
    
    // Restore the original position and scale
    contactNode.scale = SCNVector3Make(1, 1, 1);
    contactNode.position = SCNVector3Make(contactNode.position.x, contactNode.position.y, contactNode.position.z - 50);
}

// Highlight the node at index 'index' by setting a CI filter
- (void)highlightContactAtIndex:(NSUInteger)index withController:(ASCPresentationViewController *)presentationViewController {
    // Create a filter
    ASCGlowFilter *glowFilter = [[ASCGlowFilter alloc] init];
    glowFilter.name = @"aGlow";
    [glowFilter setDefaults];
    
    // Retrieve the node to highlight
    // Scale up and move to front a little
    SCNNode *contactNode = [self.groundNode childNodeWithName:[NSString stringWithFormat:@"contact%d", (int)index] recursively:YES];
    contactNode.scale = SCNVector3Make(1.2, 1.2, 1.2);
    contactNode.position = SCNVector3Make(contactNode.position.x, contactNode.position.y, contactNode.position.z + 50);
    
    // Compute the screenspace position of this node because the glow filter needs this info
    SCNVector3 worldPosition = [contactNode convertPosition:SCNVector3Make(0, 0, 0) toNode:nil];
    SCNVector3 screenPosition = [presentationViewController.view projectPoint:worldPosition];
    CGPoint screenPositionInPixels = [presentationViewController.view convertPointToBacking:CGPointMake(screenPosition.x, screenPosition.y)];
    
    [glowFilter setValue:@(screenPositionInPixels.x) forKey:@"centerX"];
    [glowFilter setValue:@(screenPositionInPixels.y) forKey:@"centerY"];
    
    [glowFilter setValue:@10 forKey:@"inputRadius"];
    
    // Set the filter
    contactNode.filters = @[glowFilter];
    
    // Animate the radius parameter of the glow filter
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"filters.aGlow.inputRadius"];
    animation.toValue = @20;
    animation.fromValue = @10;
    animation.autoreverses = YES;
    animation.repeatCount = FLT_MAX;
    animation.duration = 1.0;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [contactNode addAnimation:animation forKey:@"filterAnimation"];
}

@end

#pragma mark - Core Image filter

@implementation ASCGlowFilter

@synthesize inputRadius;

- (NSArray *)attributeKeys {
    return @[@"inputRadius"];
}

- (CIImage *)outputImage {
    CIImage *inputImage = [self valueForKey:@"inputImage"];
    if (!inputImage)
        return nil;
    
    // Monochrome
    CIFilter *monochromeFilter = [CIFilter filterWithName:@"CIColorMatrix"];
    [monochromeFilter setDefaults];
    [monochromeFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputRVector"];
    [monochromeFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0.4] forKey:@"inputGVector"];
    [monochromeFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:1] forKey:@"inputBVector"];
    [monochromeFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:1] forKey:@"inputAVector"];
    [monochromeFilter setValue:inputImage forKey:@"inputImage"];
    CIImage *glowImage = [monochromeFilter valueForKey:@"outputImage"];
    
    // Scale
    float centerX = [self.centerX floatValue];
    float centerY = [self.centerY floatValue];
    if (centerX > 0) {
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform translateXBy:centerX yBy:centerY];
        [transform scaleBy:1.2];
        [transform translateXBy:-centerX yBy:-centerY];
        
        CIFilter *affineTransformFilter = [CIFilter filterWithName:@"CIAffineTransform"];
        [affineTransformFilter setDefaults];
        [affineTransformFilter setValue:transform forKey:@"inputTransform"];
        [affineTransformFilter setValue:glowImage forKey:@"inputImage"];
        glowImage = [affineTransformFilter valueForKey:@"outputImage"];
    }
    
    // Blur
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianBlurFilter setDefaults];
    [gaussianBlurFilter setValue:glowImage forKey:@"inputImage"];
    [gaussianBlurFilter setValue:self.inputRadius ?: @10.0 forKey:@"inputRadius"];
    glowImage = [gaussianBlurFilter valueForKey:@"outputImage"];
    
    // Blend
    CIFilter *blendFilter = [CIFilter filterWithName:@"CISourceOverCompositing"];
    [blendFilter setDefaults];
    [blendFilter setValue:glowImage forKey:@"inputBackgroundImage"];
    [blendFilter setValue:inputImage forKey:@"inputImage"];
    glowImage = [blendFilter valueForKey:@"outputImage"];
    
    return glowImage;
}

@end

