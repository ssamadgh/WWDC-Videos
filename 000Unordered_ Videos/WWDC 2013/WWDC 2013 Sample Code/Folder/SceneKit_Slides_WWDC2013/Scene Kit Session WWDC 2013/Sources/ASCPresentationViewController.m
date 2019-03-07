/*
     File: ASCPresentationViewController.m
 Abstract: n/a
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
#import "ASCSlide.h"
#import "ASCSlideTextManager.h"
#import "Utils.h"

typedef NS_ENUM(NSUInteger, ASCLightName) {
    ASCLightMain = 0,
    ASCLightFront,
    ASCLightSpot,
    ASCLightLeft,
    ASCLightRight,
    ASCLightAmbient,
    ASCLightCount
};

@implementation ASCPresentationViewController {
    // Keeping track of the current slide
    NSInteger _currentSlideIndex;
    NSInteger _currentSlideStep;
    
    // The scene used for this presentation
    SCNScene *_scene;
    
    // Light nodes
    SCNNode *_lights[ASCLightCount];
    
    // Other useful nodes
    SCNNode *_cameraNode;
    SCNNode *_cameraPitch;
    SCNNode *_cameraHandle;
    
    // Managing the floor
    SCNNode *_floorNode;
    NSImage *_floorImage;
    
    // Presentation settings and slides
    NSDictionary *_settings;
    NSMutableDictionary *_slideCache;
    
    // Managing the "New" badge
    BOOL _showsNewInSceneKitBadge;
    SCNNode *_newBadgeNode;
    CAAnimation *_newBadgeAnimation;
}

#pragma mark -
#pragma mark View controller

- (SCNView *)view {
    return (SCNView *)[super view];
}

- (id)initWithContentsOfFile:(NSString *)path {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        // Load the presentation settings from the plist file
        NSString *settingsPath = [[NSBundle mainBundle] pathForResource:path ofType:@"plist"];
        _settings = [NSDictionary dictionaryWithContentsOfFile:settingsPath];
        
        _slideCache = [[NSMutableDictionary alloc] init];
        
        // Create a new empty scene
        _scene = [SCNScene scene];
        
         // Create and add a camera to the scene
         // We create three separate nodes to ease the manipulation of the global position, pitch (ie. orientation on the x axis) and relative position
         // - cameraHandle is used to control the global position in world space
         // - cameraPitch  is used to rotate the position on the x axis
         // - cameraNode   is sometimes manipulated by slides to move the camera relatively to the global position (cameraHandle). But this node is supposed to always be repositioned at (0, 0, 0) in the end of a slide.
    
        _cameraHandle = [SCNNode node];
        _cameraHandle.name = @"cameraHandle";
        [_scene.rootNode addChildNode:_cameraHandle];
        
        _cameraPitch = [SCNNode node];
        _cameraPitch.name = @"cameraPitch";
        [_cameraHandle addChildNode:_cameraPitch];
        
        _cameraNode = [SCNNode node];
        _cameraNode.name = @"cameraNode";
        _cameraNode.camera = [SCNCamera camera];
        
        // Set the default field of view to 70 degrees (a relatively strong perspective)
        _cameraNode.camera.xFov = 70.0;
        _cameraNode.camera.yFov = 42.0;
        [_cameraPitch addChildNode:_cameraNode];
        
        // Setup the different lights
        [self initLighting];
        
        // Create and add a reflective floor to the scene
        SCNMaterial *floorMaterial = [SCNMaterial material];
        floorMaterial.ambient.contents = [NSColor blackColor];
        floorMaterial.diffuse.contents = @"/Library/Desktop Pictures/Circles.jpg";
        floorMaterial.diffuse.contentsTransform = CATransform3DScale(CATransform3DMakeRotation(M_PI / 4, 0, 0, 1), 2.0, 2.0, 1.0);
        floorMaterial.specular.wrapS =
        floorMaterial.specular.wrapT =
        floorMaterial.diffuse.wrapS  =
        floorMaterial.diffuse.wrapT  = SCNWrapModeMirror;
        
        SCNFloor *floor = [SCNFloor floor];
        floor.reflectionFalloffEnd = 3.0;
        floor.firstMaterial = floorMaterial;
        
        _floorNode = [SCNNode node];
        _floorNode.geometry = floor;
        [_scene.rootNode addChildNode:_floorNode];
        
        // Use a shader modifier to support a secondary texture for some slides
        NSString *shaderFile = [[NSBundle mainBundle] pathForResource:@"floor" ofType:@"shader"];
        NSString *shaderSource = [NSString stringWithContentsOfFile:shaderFile encoding:NSUTF8StringEncoding error:nil];
        floorMaterial.shaderModifiers = @{ SCNShaderModifierEntryPointSurface : shaderSource };
        
        // Set the scene to the view
        self.view = [[SCNView alloc] init];
        self.view.scene = _scene;
        self.view.backgroundColor = [NSColor blackColor];
        
        // Turn on jittering for better anti-aliasing when the scene is still
        self.view.jitteringEnabled = YES;
        
        // Start the presentation
        [self goToSlideAtIndex:0];
    }
    return self;
}

#pragma mark -
#pragma Presentation outline

- (NSInteger)numberOfSlides {
    return [_settings[@"Slides"] count];
}

- (Class)classOfSlideAtIndex:(NSInteger)slideIndex {
    NSDictionary *info = _settings[@"Slides"][slideIndex];
    NSString *className = info[@"Class"];
    return NSClassFromString(className);
}

#pragma mark -
#pragma Slide creation and warm up

// This method creates and setup the slide at the specified index and returns it.
// The new slide is cached in the _slides array.
- (ASCSlide *)slideAtIndex:(NSInteger)slideIndex loadIfNeeded:(BOOL)loadIfNeeded {
    if (slideIndex < 0 || slideIndex >= [_settings[@"Slides"] count])
        return nil;
    
    // look into the cache first
    ASCSlide *slide = _slideCache[@(slideIndex)];
    if (slide) {
        return slide;
    }
    
    if (!loadIfNeeded)
        return nil;
    
    // create the new slide
    Class slideClass = [self classOfSlideAtIndex:slideIndex];
    slide = [[slideClass alloc] init];
    
    // update its parameters
    NSDictionary *info = _settings[@"Slides"][slideIndex];
    NSDictionary *parameters = info[@"Parameters"];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [slide setValue:obj forKey:key];
    }];

    _slideCache[@(slideIndex)] = slide;
    
    if (!slide)
        return nil;
    
    // setup the slide
    [slide  setupSlideWithPresentationViewController:self];
    
    // return it
    return slide;
}

// preload the next slide
- (void)prepareSlideAtIndex:(NSInteger)slideIndex {
    // retrieve the slide to preload
    ASCSlide *slide = [self slideAtIndex:slideIndex loadIfNeeded:YES];
    
    if (slide) {
        [SCNTransaction flush]; // make sure that all pending transactions are flushed otherwise objects not added to the scene graph yet would not be preloaded
        
        // preload the node tree
        [self.view prepareObject:slide.rootNode shouldAbortBlock:nil];
        
        // also preload the floor image if any
        if ([slide.floorImageName length]) {
            NSImage *image = [[NSBundle mainBundle] imageForResource:slide.floorImageName];
            
            // create a container for this image to be able to preload it
            SCNMaterial *material = [SCNMaterial material];
            material.diffuse.contents = image;
            material.diffuse.mipFilter = SCNLinearFiltering; //we also wan't to preload mipmaps
            
            [SCNTransaction flush]; //make this material ready before warming up
            
            // preload
            [self.view prepareObject:material shouldAbortBlock:nil];
            
            // don't release this material now, otherwise we will loose what we just preloaded
            slide.floorWarmupMaterial = material;
        }
    }
}

#pragma mark -
#pragma mark Navigating within a presentation

- (void)goToNextSlideStep {
    ASCSlide *slide = [self slideAtIndex:_currentSlideIndex loadIfNeeded:NO];
    if (_currentSlideStep + 1 >= [slide numberOfSteps]) {
        [self goToSlideAtIndex:_currentSlideIndex + 1];
    } else {
        [self goToSlideStep:_currentSlideStep + 1];
    }
}

- (void)goToPreviousSlide {
    [self goToSlideAtIndex:_currentSlideIndex - 1];
}

- (void)goToSlideAtIndex:(NSInteger)slideIndex {
    // save previous slide index
    NSUInteger oldIndex = _currentSlideIndex;
    
    // load and retrieve the slide at the specified index
    ASCSlide *slide = [self slideAtIndex:slideIndex loadIfNeeded:YES];
    
    if (!slide)
        return;
    
    // compute the playback direction (did the user select next or previous?)
    float direction = slideIndex >= _currentSlideIndex ? 1 : -1;
    
    // update badge
    self.showsNewInSceneKitBadge = [slide isNewIn10_9];
    
    // if we are playing backward, we need to use the slide we come from to play the correct transition (backward)
    ASCSlide *transitionSlide = [self slideAtIndex:direction == 1 ? slideIndex : _currentSlideIndex loadIfNeeded:YES];
    
    // make sure that the next operations are synchronized by a transaction
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:0];
    
    // retrieve the nodes of the slides to place into the scene graph
    SCNNode *rootNode = slide.rootNode;
    SCNNode *textContainer = slide.textManager.textNode;
    
    // compute transition offset
    SCNVector3 offset = SCNVector3Make(transitionSlide.transitionOffsetX, 0.0, transitionSlide.transitionOffsetZ);
    offset.x *= direction;
    offset.z *= direction;
    
    // rotate offset based on current Yaw
    double cosa = cos(-_cameraHandle.rotation.w);
    double sina = sin(-_cameraHandle.rotation.w);
    
	double tmpX = offset.x * cosa - offset.z * sina;
    offset.z = offset.x * sina + offset.z * cosa;
    offset.x = tmpX;
    
    // if we don't move, fade in
    if (offset.x == 0 && offset.y == 0 && offset.z == 0 && transitionSlide.transitionRotation == 0) {
        rootNode.opacity = 0;
    }
    
    // don't animate the first slide
    BOOL shouldAnimate = !(slideIndex == 0 && _currentSlideIndex == 0);
    
    // update slide index variable
    _currentSlideIndex = slideIndex;
    
    // get number of sub-steps
    [self goToSlideStep:0];
    
    if ([self.delegate respondsToSelector:@selector(presentation:willPresentSlideAtIndex:step:)]) {
        [self.delegate presentation:self willPresentSlideAtIndex:_currentSlideIndex step:_currentSlideStep];
    }
    
    // add the slide to the scene graph
    [self.view.scene.rootNode addChildNode:rootNode];
    
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:shouldAnimate ? slide.transitionDuration : 0];
    [SCNTransaction setCompletionBlock:^{
        // invoke orderIn at the end of the transition
        [self orderInSlideAtIndex:slideIndex];
    }];
    
    // fade in the new slide
    rootNode.opacity = 1;
    
    // place the camera
	_cameraHandle.position = SCNVector3Make(_cameraHandle.position.x + offset.x,
                                            slide.altitude,
                                            _cameraHandle.position.z + offset.z);
    
    // update Yaw
    _cameraHandle.rotation = SCNVector4Make(0, 1, 0, _cameraHandle.rotation.w + transitionSlide.transitionRotation * M_PI / 180.0 * direction);
    
    // update the pitch of the camera
    _cameraPitch.rotation = SCNVector4Make(1, 0, 0, slide.pitch * M_PI / 180.0);
    
    // update the light intensities
    [self updateLightingForSlideAtIndex:slideIndex];
    
    //update the reflectivity of the floor based on the slide settings
    ((SCNFloor *)_floorNode.geometry).reflectivity = [slide floorReflectivity];
    ((SCNFloor *)_floorNode.geometry).reflectionFalloffEnd = [slide floorFalloff];
    
    [SCNTransaction commit];
    
#define TEXT_Y -3.3
#define CAMERA_OFFSET -28
    
    // compute position of text
    CATransform3D slideTextTransform = CATransform3DConcat(CATransform3DMakeTranslation(0, TEXT_Y, CAMERA_OFFSET), _cameraNode.worldTransform);
    
    // place the rest of the slide
    rootNode.transform = slideTextTransform;
    rootNode.position = SCNVector3Make(rootNode.position.x, 0, rootNode.position.z); //clear altitude
    rootNode.rotation = SCNVector4Make(0, 1, 0, _cameraHandle.rotation.w); //use same rotation as the camera to simplify the placement of the elements in slides
    
    CATransform3D slideContentsTransform = rootNode.transform; //final transform for the slide
    
    // make slideTextTransform relative to slideContentsTransform
    slideTextTransform = CATransform3DConcat(slideTextTransform, CATransform3DInvert(slideContentsTransform));
    
    // place the text
    textContainer.transform = slideTextTransform;
    
    // place the ground node of the slide on the ground
    SCNVector3 p = SCNVector3Make(0, 0, 0);
    p = [rootNode convertPosition:p toNode:nil];
    p.y = 0; // move back to the ground
    p = [rootNode convertPosition:p fromNode:nil];
    slide.ground.position = p;
    
    // update the floor image if needed
    NSImage *floorImage = [[NSBundle mainBundle] imageForResource:slide.floorImageName];
    [self updatefloorImage:floorImage forSlide:slide];
    
    [SCNTransaction commit];
    
    // preload the next slide after some delay
    double delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self prepareSlideAtIndex:slideIndex + 1];
    });
    
    // order out previous slide if any
    if (oldIndex != _currentSlideIndex)
        [self orderOutSlideAtIndex:oldIndex];
}

// invoked when seeking to another sub-step of a slide
- (void)goToSlideStep:(NSInteger)index {
    _currentSlideStep = index;
    
    // retrieve the current slide
    ASCSlide *slide = [self slideAtIndex:_currentSlideIndex loadIfNeeded:YES];
    
    if (!slide)
        return;
    
    if ([self.delegate respondsToSelector:@selector(presentation:willPresentSlideAtIndex:step:)]) {
        [self.delegate presentation:self willPresentSlideAtIndex:_currentSlideIndex step:_currentSlideStep];
    }
    
    // present this step
    [slide presentStepIndex:_currentSlideStep withPresentionViewController:self];
}

- (void)orderInSlideAtIndex:(NSInteger)slideIndex {
    // let the subclass do some custom stuff when the slide order in
    ASCSlide *slide = [self slideAtIndex:slideIndex loadIfNeeded:NO];
    [slide orderInWithPresentionViewController:self];
}

- (void)orderOutSlideAtIndex:(NSInteger)slideIndex {
    //retrieve the slide to order out
    ASCSlide *slide = [self slideAtIndex:slideIndex loadIfNeeded:NO];
    if (slide) {
        //get the root node of this slide
        SCNNode *node = slide.rootNode;
        
        //fade it out
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0.75];
        [SCNTransaction setCompletionBlock:^{
            //remove on completion
            [node removeFromParentNode];
        }];
        
        node.opacity = 0.0;
        
        [SCNTransaction commit];
        
        //invoke orderOut for subclasses
        [slide orderOutWithPresentionViewController:self];
        
        //remove from the slides array to free some memory
        [_slideCache removeObjectForKey:@(slideIndex)];
    }
}

#pragma mark -
#pragma mark Scene decorations

- (void)setShowsNewInSceneKitBadge:(BOOL)showsNewInSceneKitBadge {
    _showsNewInSceneKitBadge = showsNewInSceneKitBadge;
    
    if (_newBadgeNode && showsNewInSceneKitBadge)
        return; // already visible
    
    if (!_newBadgeNode && !showsNewInSceneKitBadge)
        return; // already invisible
    
    // load new tag model and animation
    if (!_newBadgeNode) {
        _newBadgeNode = [SCNNode node];
        
        SCNNode *badge = [_newBadgeNode asc_addChildNodeNamed:@"newBadge" fromSceneNamed:@"newBadge" withScale:1];
        _newBadgeNode.scale = SCNVector3Make(0.03, 0.03, 0.03);
        _newBadgeNode.opacity = 0;
        _newBadgeNode.position = SCNVector3Make(50, 20, -10);
        _newBadgeNode.rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
        
        SCNNode *imageNode = [_newBadgeNode childNodeWithName:@"badgeImage" recursively:YES];
        imageNode.geometry.firstMaterial.emission.intensity = 0.0;
        
        [self.cameraPitch addChildNode:_newBadgeNode];
        
        _newBadgeAnimation = [badge animationForKey:[badge animationKeys][0]];
        [badge removeAllAnimations];
        
        _newBadgeAnimation.speed = 1.5;
        _newBadgeAnimation.fillMode = kCAFillModeBoth;
        _newBadgeAnimation.usesSceneTimeBase = NO;
        _newBadgeAnimation.removedOnCompletion = NO;
    }
    
    if (showsNewInSceneKitBadge) {
        //play
        [_newBadgeNode addAnimation:_newBadgeAnimation forKey:nil];
        
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:2];
        
        _newBadgeNode.position = SCNVector3Make(14, 8, -20);
        
        [SCNTransaction setCompletionBlock:^{
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:3];
            SCNNode *rope = [_newBadgeNode childNodeWithName:@"rope02" recursively:YES];
            rope.opacity = 0.0;
            [SCNTransaction commit];
            
        }];
        
        _newBadgeNode.opacity = 1.0;
        SCNNode *imageNode = [_newBadgeNode childNodeWithName:@"badgeImage" recursively:YES];
        imageNode.geometry.firstMaterial.emission.intensity = 0.4;
        [SCNTransaction commit];
    }
    else {
        //hide
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:1.5];
        
        [SCNTransaction setCompletionBlock:^{
            [_newBadgeNode removeFromParentNode];
            _newBadgeNode = nil;
        }];
        
        _newBadgeNode.position = SCNVector3Make(14, 50, -20);
        _newBadgeNode.opacity = 0.0;
        [SCNTransaction commit];
    }
}

- (BOOL)showsNewInSceneKitBadge {
    return _showsNewInSceneKitBadge;
}

#pragma mark -
#pragma mark Lighting the scene

// initialize the lights in the scene
- (void)initLighting {
    // create an omni light (main light of the scene)
	_lights[ASCLightMain] = [SCNNode node];
    _lights[ASCLightMain].name = @"omni";
	_lights[ASCLightMain].light = [SCNLight light];
	_lights[ASCLightMain].light.type = SCNLightTypeOmni;
    _lights[ASCLightMain].position = SCNVector3Make(0, 3, -13);
    [_lights[ASCLightMain].light setAttribute:@10 forKey:SCNLightAttenuationStartKey];
    [_lights[ASCLightMain].light setAttribute:@50 forKey:SCNLightAttenuationEndKey];
	[_cameraHandle addChildNode:_lights[ASCLightMain]]; //make all lights relative to the camera node
    
    // front light
	_lights[ASCLightFront] = [SCNNode node];
    _lights[ASCLightFront].name = @"front light";
	_lights[ASCLightFront].light = [SCNLight light];
	_lights[ASCLightFront].light.type = SCNLightTypeDirectional;
    _lights[ASCLightFront].position = SCNVector3Make(0, 0, 0);
	[_cameraHandle addChildNode:_lights[ASCLightFront]];
    
    // spot light
	_lights[ASCLightSpot] = [SCNNode node];
    _lights[ASCLightSpot].name = @"spot light";
	_lights[ASCLightSpot].light = [SCNLight light];
	_lights[ASCLightSpot].light.type = SCNLightTypeSpot;
    _lights[ASCLightSpot].light.shadowRadius = 10;
    _lights[ASCLightSpot].position = SCNVector3Make(0, 30, -19);
    _lights[ASCLightSpot].rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
    [_lights[ASCLightSpot].light setAttribute:@30 forKey:SCNLightShadowNearClippingKey];
    [_lights[ASCLightSpot].light setAttribute:@50 forKey:SCNLightShadowFarClippingKey];
    [_lights[ASCLightSpot].light setAttribute:@10 forKey:SCNLightSpotInnerAngleKey];
    [_lights[ASCLightSpot].light setAttribute:@45 forKey:SCNLightSpotOuterAngleKey];
	[_cameraHandle addChildNode:_lights[ASCLightSpot]];
    
    // left light
	_lights[ASCLightLeft] = [SCNNode node];
    _lights[ASCLightLeft].name = @"left light";
	_lights[ASCLightLeft].light = [SCNLight light];
	_lights[ASCLightLeft].light.type = SCNLightTypeOmni;
    _lights[ASCLightLeft].position = SCNVector3Make(-20, 10, -5);
    [_lights[ASCLightLeft].light setAttribute:@30 forKey:SCNLightAttenuationStartKey];
    [_lights[ASCLightLeft].light setAttribute:@80 forKey:SCNLightAttenuationEndKey];
	[_cameraHandle addChildNode:_lights[ASCLightLeft]];
    
    // right light
	_lights[ASCLightRight] = [SCNNode node];
    _lights[ASCLightRight].name = @"right light";
	_lights[ASCLightRight].light = [SCNLight light];
	_lights[ASCLightRight].light.type = SCNLightTypeOmni;
    _lights[ASCLightRight].position = SCNVector3Make(20, 10, -5);
    [_lights[ASCLightRight].light setAttribute:@30 forKey:SCNLightAttenuationStartKey];
    [_lights[ASCLightRight].light setAttribute:@80 forKey:SCNLightAttenuationEndKey];
	[_cameraHandle addChildNode:_lights[ASCLightRight]];
    
    // ambient light
	_lights[ASCLightAmbient] = [SCNNode node];
    _lights[ASCLightAmbient].name = @"ambient light";
	_lights[ASCLightAmbient].light = [SCNLight light];
	_lights[ASCLightAmbient].light.type = SCNLightTypeAmbient;
	[_scene.rootNode addChildNode:_lights[ASCLightAmbient]];
    
    // switch off all lights
    for (NSInteger i = 0; i < ASCLightCount; i++)
        _lights[i].light.color = [NSColor blackColor];
}

// install the light intensities for the slide at index slideIndex
- (void)updateLightingForSlideAtIndex:(NSInteger)slideIndex {
    ASCSlide *slide = [self slideAtIndex:slideIndex loadIfNeeded:YES];
    
    //retrieve the slide settings
    NSArray *intensities = slide.lightIntensities;
    
    //let the slide update the position of the main light
    _lights[ASCLightMain].position = [slide mainLightPosition];
    
    //install the new light settings
    [self updateLightingWithIntensities:intensities];
    
    // turn on/off shadows based on the slide settings
    bool shouldCastShadows = [slide enableShadows];
    [self enableShadows:shouldCastShadows];
}

// update the lighting with the specified intensities
- (void)updateLightingWithIntensities:(NSArray *)intensities {
    for (NSInteger i = 0; i < ASCLightCount; i++) {
        CGFloat intensity = [intensities count] > i ? [intensities[i] floatValue] : 0;
        _lights[i].light.color = [NSColor colorWithDeviceHue:_lightHueAtSlideIndex(i)
                                                  saturation:_lightSaturationAtSlideIndex(i)
                                                  brightness:intensity
                                                       alpha:1];
    }
}

- (void)enableShadows:(BOOL) shouldCastShadows {
    //animate shadows in / out
    _lights[ASCLightSpot].light.shadowColor = [NSColor colorWithDeviceWhite:0 alpha:shouldCastShadows ? 0.75 : 0.0];
    _lights[ASCLightSpot].light.castsShadow = shouldCastShadows;
}

// resize the outer angle of the spot light
- (void)narrowSpotlight:(BOOL)narrow {
    if (narrow) {
        [_lights[ASCLightSpot].light setAttribute:@20 forKey:SCNLightSpotInnerAngleKey];
        [_lights[ASCLightSpot].light setAttribute:@30 forKey:SCNLightSpotOuterAngleKey];
    } else {
        [_lights[ASCLightSpot].light setAttribute:@10 forKey:SCNLightSpotInnerAngleKey];
        [_lights[ASCLightSpot].light setAttribute:@45 forKey:SCNLightSpotOuterAngleKey];
    }
}

// move the main light up/down
- (void)riseMainLight:(BOOL) rise {
    if (rise) {
        [_lights[ASCLightMain].light setAttribute:@90 forKey:SCNLightAttenuationStartKey];
        [_lights[ASCLightMain].light setAttribute:@250 forKey:SCNLightAttenuationEndKey];
        _lights[ASCLightMain].position = SCNVector3Make(0, 10, -10);
    } else {
        [_lights[ASCLightMain].light setAttribute:@10 forKey:SCNLightAttenuationStartKey];
        [_lights[ASCLightMain].light setAttribute:@50 forKey:SCNLightAttenuationEndKey];
        _lights[ASCLightMain].position = SCNVector3Make(0, 3, -13);
    }
}

- (SCNNode *)spotLight {
    return _lights[ASCLightSpot];
}

- (SCNNode *)mainLight {
    return _lights[ASCLightMain];
}

#pragma mark - Updating the floor

// updates the secondary image of the floor if needed
- (void)updatefloorImage:(NSImage *)image forSlide:(ASCSlide *)slide {
    /* we don't want to animate if we replace the secondary image by another - otherwise we can translate the secondary image to the new location */
    BOOL disableAction = NO;
    
    if (_floorImage != image) {
        _floorImage = image;
        disableAction = YES;
        
        if (image) {
            //set a new material property with this image to the "floorMap" custom property of the floor
            SCNMaterialProperty *property = [SCNMaterialProperty materialPropertyWithContents:image];
            property.wrapS = SCNWrapModeRepeat;
            property.wrapT = SCNWrapModeRepeat;
            property.mipFilter = SCNFilterModeLinear;
            
            [_floorNode.geometry.firstMaterial setValue:property forKey:@"floorMap"];
        }
    }
    
    if (image) {
        // place the image in 3D space
        SCNVector3 slidePosition = [slide.ground convertPosition:SCNVector3Make(0, 0, 10) toNode:nil];
        
        if (disableAction) {
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0];
        }
        
        [_floorNode.geometry.firstMaterial setValue:[NSValue valueWithSCNVector3:slidePosition] forKey:@"floorImageNamePosition"];
        
        if (disableAction) {
            [SCNTransaction commit];
        }
    }
}

#pragma mark -
#pragma mark TODO

// light colors
CGFloat _lightSaturationAtSlideIndex(int index) {
    if (index >= 4) return 0.1; //colored
    return 0; //black and white
}

CGFloat _lightHueAtSlideIndex(int index) {
    if (index == 4) return 0; //red
    if (index == 5) return 200/360.0; //blue
    return 0; //black and white
}

@end
