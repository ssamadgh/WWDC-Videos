/*
     File: ASCSlideCoreImage.m
 Abstract:  CoreImage slide. 
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

#import "ASCPresentationViewController.h"
#import "ASCSlideTextManager.h"
#import "ASCSlide.h"
#import "Utils.h"
#import <GLKit/GLKMath.h>

// number of contact image available
#define CONTACT_IMAGE_COUNT 44

// last selection index in the demo script
#define PICKED_INDEX 28

// number of row and column in our contact picker UI
#define ROW 4
#define COL 11


// a custom ci filter that glow a selection
@interface ASCGlowFilter : CIFilter

@property (retain, nonatomic) CIImage *inputImage;
@property (retain, nonatomic) NSNumber *inputRadius;
@property (retain, nonatomic) NSNumber *centerX;
@property (retain, nonatomic) NSNumber *centerY;

@end

@implementation ASCGlowFilter

- (NSArray *)attributeKeys {
    return @[@"inputRadius"];
}

/* this filter does:
 1) turn the input image in a monochrome and colorised version (some sort of colorised mask)
 2) scale it a little bit (this is where we need centerX and centerY as the center of the scale)
 3) blur a lot
 4) draw the input image over the blurred-colorised-mask
 */
- (CIImage *)outputImage {
    CIImage *input = [self valueForKey:@"inputImage"];
    
    // if no input - just skip
    if (!input)
        return nil;
    
    //1) mono color
    CIFilter *monochrome = [CIFilter filterWithName:@"CIColorMatrix"];
    [monochrome setDefaults];
    [monochrome setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputRVector"];
    [monochrome setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0.4] forKey:@"inputGVector"];
    [monochrome setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:1] forKey:@"inputBVector"];
    [monochrome setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:1] forKey:@"inputAVector"];
    
    [monochrome setValue:input forKey:@"inputImage"];
    CIImage *glowImage = [monochrome valueForKey:@"outputImage"];
    
    //2) scale
    float x = [self.centerX floatValue];
    float y = [self.centerY floatValue];
    if (x > 0) {
        CIFilter *affine = [CIFilter filterWithName:@"CIAffineTransform"];
        [affine setDefaults];
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform translateXBy:x yBy:y];
        [transform scaleBy:1.2];
        [transform translateXBy:-x yBy:-y];
        [affine setValue:transform forKey:@"inputTransform"];
        [affine setValue:glowImage forKey:@"inputImage"];
        glowImage = [affine valueForKey:@"outputImage"];
    }
    
    //3) blur
    CIFilter *blur = [CIFilter filterWithName:@"CIGaussianBlur"];
    [blur setDefaults];
    [blur setValue:glowImage forKey:@"inputImage"];
    CGFloat radius = [self.inputRadius floatValue];
    [blur setValue:radius ? @(radius) : @10.0 forKey:@"inputRadius"];
    
    glowImage = [blur valueForKey:@"outputImage"];
    
    //4) compose
    CIFilter *blend = [CIFilter filterWithName:@"CISourceOverCompositing"];
    [blend setDefaults];
    
    [blend setValue:glowImage forKey:@"inputBackgroundImage"];
    [blend setValue:input forKey:@"inputImage"];
    
    // return the result
    return [blend valueForKey:@"outputImage"];
}

@end

@interface ASCSlideCoreImage : ASCSlide {
    CGSize _viewport;
}

@end

@implementation ASCSlideCoreImage

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentation {
    //retrive the text manager and add some text
    ASCSlideTextManager *textManager = [self textManager];
    [textManager setTitle:@"Core Image"];
    [textManager setSubtitle:@"CI Filters"];

    [textManager addBullet:@"Screen-space effects" atLevel:0];
    [textManager addBullet:@"Applies to a node hierarchy" atLevel:0];
    [textManager addBullet:@"Filter parameters are animatable" atLevel:0];
    [textManager addCode:@"aNode.#filters# = @[filter1, filter2];"];
    
    //setup image grid now to benefit from the preload mechanism
    SCNNode *node = [self setupImageGrid];
    
    //name it and place it
    node.name = @"grid";
    node.position = SCNVector3Make(0, [self altitude] - 2.8, 18);
    node.opacity = 0.0;
    
    //add to the slide
    [self.ground addChildNode:node];
    
    //
    NSRect frame = [presentation.view convertRectToBacking:presentation.view.frame];
    _viewport = CGSizeMake(frame.size.width, frame.size.height);
}

- (NSUInteger)numberOfSteps {
    return 7;
}

// initialize the contact grid
- (SCNNode *)setupImageGrid {
    //create a root node for the grid
    SCNNode *group = [SCNNode node];
    
    // retrieve the template node to replicate
    SCNScene *scene = [SCNScene sceneNamed:@"contact.dae"];
    SCNNode *model = [scene.rootNode childNodeWithName:@"people" recursively:YES];
    
    // duplicate ROWxCOL times
    for (NSUInteger k = 0, j = 0; j < ROW; j++) {
        for (NSUInteger i = 0; i < COL; i++, k++) {
            //create a parent node
            SCNNode *modelContainer = [SCNNode node];
            
            //clone the template
            SCNNode *node = [model clone];
            
            //name it
            node.name = [NSString stringWithFormat:@"contact%lu", (unsigned long)k];
            
            //add to the hierarchy (group > container > node)
            [group addChildNode:modelContainer];
            [modelContainer addChildNode:node];
            
            // layout is slightly curved
            CGFloat radius = 500.0;
            CGFloat angle = 0.12 * ((COL-1)/2.0 - i);
            angle += M_PI_2;
            CGFloat x = cos(angle)*radius;
            CGFloat z = sin(angle)*radius;
            modelContainer.position = SCNVector3Make(x, j * 60, -z + 400);
            angle -= M_PI_2;
            modelContainer.rotation = SCNVector4Make(0, 1, 0, angle);
            
            /*unshare the material because we want a different image on each elemement
             to do this we need to unshare the geometry first and then unshare the material */
            
            //retrive the node that own the geometry (first child in that case)
            SCNNode *geoNode = node.childNodes[0];
            
            //unshare the geometry
            geoNode.geometry = [[geoNode geometry] copy];
            
            //unshare the material
            SCNMaterial *m = [geoNode.geometry.materials[1] copy];
            [geoNode.geometry replaceMaterialAtIndex:1 withMaterial:m];
            
            //set a contact image
            m.diffuse.contents = [NSImage imageNamed:[NSString stringWithFormat:@"contact%lu", k % CONTACT_IMAGE_COUNT]];
            
            //animate the contacts (rotate forever)
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"rotation"];
            animation.duration = 4.0;
            animation.keyTimes = @[@0.0, @0.3, @1.0];
            animation.values = @[[NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, 0)],
                                 [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI*2)],
                                 [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI*2)]];
                                 
            CAMediaTimingFunction *tf = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animation.timingFunctions = @[tf, tf, tf];
                                 
            animation.repeatCount = FLT_MAX;
            
            //desynchronize the animations
            animation.beginTime = CACurrentMediaTime() + 1.0 + j*0.1 + i*0.05;
            
            //add the animation
            [node addAnimation:animation forKey:nil];
        }
    }
    
    //scale down the whole grid
    group.scale = SCNVector3Make(0.03, 0.03, 0.03);
    
    return group;
}


// unhighlight the node at index 'index' in the grid by removing its CI filter
- (void)unhighlightIndex:(NSUInteger) index {
    SCNNode *object = [self.ground childNodeWithName:[NSString stringWithFormat:@"contact%d", (int)index] recursively:YES];
    object.filters = nil;
    
    //restore original position and scale
    object.scale = SCNVector3Make(1, 1, 1);
    object.position = SCNVector3Make(object.position.x, object.position.y, object.position.z - 50);
}


// highlight the node at index 'index' in the grid by setting a CI filter
- (void)highlightIndex:(NSUInteger)index withController:(ASCPresentationViewController *)presentationViewController {
    //allocate a glow filter
    ASCGlowFilter *glow = [[ASCGlowFilter alloc] init];
    glow.name = @"aGlow";
    [glow setDefaults];
    NSArray *filters = [NSArray arrayWithObject:glow];
    
    //aniate the radius parameter of the glow filter
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"filters.myGlow.inputRadius"];
    animation.toValue = @20;
    animation.fromValue = @10;
    animation.autoreverses = YES;
    animation.repeatCount = FLT_MAX;
    animation.duration = 1.0;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [glow setValue:@10 forKey:@"inputRadius"];
    
    //retrive the node to highlight
    SCNNode *object = [self.ground childNodeWithName:[NSString stringWithFormat:@"contact%d", (int)index] recursively:YES];
    
    //scale up and move front a little bit
    object.scale = SCNVector3Make(1.2, 1.2, 1.2);
    object.position = SCNVector3Make(object.position.x, object.position.y, object.position.z + 50);
    
    //compute the screenspace position of this node because the glow filter needs this info
    SCNVector3 worldPos = [object convertPosition:SCNVector3Make(0, 0, 0) toNode:nil]; //word position
    SCNVector3 screenPos = [presentationViewController.view projectPoint:worldPos]; //screen position (in points)
    CGPoint surfacePos = [presentationViewController.view convertRectToBacking:CGRectMake(screenPos.x, screenPos.y,0,0)].origin; //surface position (in pixels)
    
    //give the screenspace center to the filter
    [glow setValue:@(surfacePos.x) forKey:@"centerX"];
    [glow setValue:@(surfacePos.y) forKey:@"centerY"];
    
    //set the filter to the node
    object.filters = filters;
    
    //animate the radius parameter
    [object addAnimation:animation forKey:@"filterAnimation"];
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)controller {
    switch (index) {
        case 0:
            break;
        case 1:
        {
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            
            //dim text
            self.textManager.textNode.opacity = 0.0;

            //move back a little bit
            controller.cameraHandle.position = [controller.cameraNode convertPosition:SCNVector3Make(0, 0, 5.0) toNode:controller.cameraHandle.parentNode];
            
            [SCNTransaction commit];
            
            //reveal the grid
            SCNNode *others = [self.ground childNodeWithName:@"grid" recursively:YES];
            others.opacity = 1;
        }
            break;
        case 2:
        {
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            
            //highlight an item
            [self highlightIndex:13 withController:controller];
            
            [SCNTransaction commit];
        }
            break;
        case 3:
        {
            __block int index = 13;
            __block int subStep = 0;
            double delayInSeconds = 0;
            double interval = 0.2;

            dispatch_block_t block = ^{
                
                [SCNTransaction begin];
                [SCNTransaction setAnimationDuration:interval];
                
                int oldIndex = index;
                
                subStep++;
                
                if (subStep==3) index+=COL;
                else index = index+1;
                
                [self highlightIndex:index withController:controller];
                [self unhighlightIndex:oldIndex];
                
                [SCNTransaction commit];
            };
            
            
            //select anothers item after a delay
            {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), block);
            }
            
            //select anothers item after a delay
            {
                delayInSeconds += interval;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), block);
            }

            //select anothers item after a delay
            {
                delayInSeconds += interval;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), block);
            }
            
            //select anothers item after a delay
            {
                delayInSeconds += interval;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), block);
            }
            
            //select anothers item after a delay
            {
                delayInSeconds += interval;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), block);
            }
        }
            break;
        case 4: //BLUR+DESATURATE in the background, GLOW in the foreground

        {
            //retrieve the selection and the grid nodes
            SCNNode *selection = [self.ground childNodeWithName:[NSString stringWithFormat:@"contact%d", PICKED_INDEX] recursively:YES];
            SCNNode *others = [self.ground childNodeWithName:@"grid" recursively:YES];
            
            /* Here we will change the hierarchy in order to group all the nodes in the background under a single node
             And have the node in the foreground in anothers node hierarchy.
             This way we can usea single CIFilter to apply the the whole grid at once and have anothers CIFilter for the node in the foreground. */
        
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.0];
            
            //stop the animations of the selected node
            selection.transform = [[selection presentationNode] transform]; //update current rotation with the current presentation value
            [selection removeAllAnimations];

            //re-parent nodes
            SCNNode *selectionParent = selection.parentNode;
            
            //save the world transform before moving under anothers node
            CATransform3D t = [selectionParent worldTransform];
            
            //re-parent the selection
            [[others parentNode] addChildNode:selectionParent];
            
            //set a new transform to the selection so that it's world transform remain the same
            selectionParent.transform = [selectionParent.parentNode convertTransform:t fromNode:nil];

            [SCNTransaction commit];
            
            //at this stage we are done with the re-parenting. let's start adding CIFilters
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.0];
            
            //set -1 to the centerX. This will make the glow effect to stop to scale.
            //This way the glow effect doesn't need any screenspace information to execture properly
            [selection.filters[0] setValue:@-1 forKey:@"centerX"];
            
            //move the selection to the foreground
            selectionParent.rotation = SCNVector4Make(0, 1, 0, 0);
            selection.transform = [self.rootNode convertTransform:CATransform3DMakeTranslation(0, [self altitude], 29) toNode:selection.parentNode];
            selection.scale = SCNVector3Make(1, 1, 1);
            selection.rotation = SCNVector4Make(1, 0, 0, -M_PI_4*0.25);

            [SCNTransaction setCompletionBlock:^{
                //rotate the selection forever
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
                animation.duration = 4.0;
                animation.fromValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, 0)];
                animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI*2)];
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                animation.repeatCount = FLT_MAX;
                
                [selection.childNodes[0] addAnimation:animation forKey:nil];
            }];
            
            //setup a blur filter
            CIFilter *blur = [CIFilter filterWithName:@"CIGaussianBlur"];
            [blur setDefaults];
            blur.name = @"blur";
            [blur setValue:@0 forKey:kCIInputRadiusKey];
            
            //setup a desaturate filter
            CIFilter *desaturate = [CIFilter filterWithName:@"CIColorControls"];
            [desaturate setDefaults];
            desaturate.name = @"desaturate";
            
            //set the filters to the nodes in the background
            others.filters = @[blur, desaturate];
            [SCNTransaction commit];

            //increate the blur and desaturate progressively
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:2.0];
            [others setValue:@10 forKeyPath:@"filters.blur.inputRadius"];
            [others setValue:@0.1 forKeyPath:@"filters.desaturate.inputSaturation"];
            [SCNTransaction commit];
        }
            break;
        case 5: //have fun with core image: BLUR+CIHatchedScreen in the background and a ZOOM-BLUR in the foreground
        {
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.0];
            
            //retrieve the selection and the nodes in the background
            SCNNode *selection = [self.ground childNodeWithName:[NSString stringWithFormat:@"contact%d", PICKED_INDEX] recursively:YES];
            SCNNode *others = [self.ground childNodeWithName:@"grid" recursively:YES];
            
            //setup a blur filter
            CIFilter *blur = [CIFilter filterWithName:@"CIGaussianBlur"];
            [blur setDefaults];
            blur.name = @"blur";
            [blur setValue:@10 forKey:kCIInputRadiusKey];
            
            //setup a zoom blur filter
            CIFilter *fx = [CIFilter filterWithName:@"CIZoomBlur"];
            [fx setDefaults];
            [fx setValue:[CIVector vectorWithX:0.5 * _viewport.width Y:0.5 * _viewport.height] forKey:kCIInputCenterKey];
            fx.name = @"fx";
            
            //setup a hatched screen filter
            CIFilter *fx2 = [CIFilter filterWithName:@"CIHatchedScreen"];
            [fx2 setDefaults];
            fx2.name = @"fx2";

            //assign the filters to the nodes
            others.filters = @[blur, fx2];
            selection.filters = @[fx];
            
            //animate the hatched screen
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"filters.fx2.inputAngle"];
            animation.toValue = @(0.1);
            animation.fromValue = 0;
            animation.autoreverses = YES;
            animation.repeatCount = FLT_MAX;
            animation.duration = 10.0;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [others addAnimation:animation forKey:nil];
            
            //animate the zoom blur amount
            animation = [CABasicAnimation animationWithKeyPath:@"filters.fx.inputAmount"];
            animation.toValue = @40;
            animation.fromValue = @0;
            animation.autoreverses = YES;
            animation.repeatCount = FLT_MAX;
            animation.duration = 1.0;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
            [selection addAnimation:animation forKey:nil];
            
            [SCNTransaction commit];
        }
            break;
        case 6: //have fun with core image: BLUR+PIXELATTE in the background + TWIRL in the foreground
        {
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.0];
            
            //retrieve the selection and the nodes in the background
            SCNNode *selection = [self.ground childNodeWithName:[NSString stringWithFormat:@"contact%d", PICKED_INDEX] recursively:YES];
            SCNNode *others = [self.ground childNodeWithName:@"grid" recursively:YES];
            
            //setup a blur filter
            CIFilter *blur = [CIFilter filterWithName:@"CIGaussianBlur"];
            [blur setDefaults];
            blur.name = @"blur";
            [blur setValue:@10 forKey:kCIInputRadiusKey];
            
            //setup a twirl filter
            CIFilter *fx = [CIFilter filterWithName:@"CITwirlDistortion"];
            [fx setDefaults];
            fx.name = @"fx";
            [fx setValue:[CIVector vectorWithX:0.5 * _viewport.width Y:0.5 * _viewport.height] forKey:kCIInputCenterKey];
            [fx setValue:@1000.0 forKey:kCIInputRadiusKey];

            //setup a pixellate filter
            CIFilter *fx2 = [CIFilter filterWithName:@"CIPixellate"];
            [fx2 setDefaults];
            fx2.name = @"fx2";
            
            //assing the filters
            others.filters = @[fx2, blur];
            selection.filters = @[fx];
            
            //animate the twirl angle
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"filters.fx.inputAngle"];
            animation.toValue = @M_PI;
            animation.fromValue = @-M_PI;
            animation.autoreverses = YES;
            animation.repeatCount = FLT_MAX;
            animation.duration = 1.5;
            animation.timeOffset = -0.75;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [selection addAnimation:animation forKey:nil];
            
            //animate the pixellate scale
            animation = [CABasicAnimation animationWithKeyPath:@"filters.fx2.inputScale"];
            animation.toValue = @50;
            animation.fromValue = @0;
            animation.autoreverses = YES;
            animation.repeatCount = FLT_MAX;
            animation.duration = 2.0;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [others addAnimation:animation forKey:nil];
            
            [SCNTransaction commit];
        }
            break;
    }
}

- (SCNVector3) mainLightPosition {
    //for this slide we want the main light to be a little upper
    return SCNVector3Make(0, 3, 0);
}

@end
