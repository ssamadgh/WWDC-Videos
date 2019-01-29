/*
     File: ASCPresentationViewController.m
 Abstract: ASCPresentationViewController controls the presentation, including ordering the slides in and out, updating the position of the camera, the light intensites and more.
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
    SCNFloor *_floor;
    NSImage  *_floorImage;
    
    // Presentation settings and slides
    NSDictionary        *_settings;
    NSMutableDictionary *_slideCache;
    
    // Managing the "New" badge
    SCNNode     *_newBadgeNode;
    CAAnimation *_newBadgeAnimation;
}

#pragma mark - View controller

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
        // We create three separate nodes to ease the manipulation of the global position, pitch (ie. orientation around the x axis) and relative position
        // - cameraHandle is used to control the global position in world space
        // - cameraPitch  is used to rotate the position around the x axis
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
        
        _floor = [SCNFloor floor];
        _floor.reflectionFalloffEnd = 3.0;
        _floor.firstMaterial = floorMaterial;
        
        SCNNode *floorNode = [SCNNode node];
        floorNode.geometry = _floor;
        [_scene.rootNode addChildNode:floorNode];
        
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

#pragma mark - Presentation outline

- (NSInteger)numberOfSlides {
    return [_settings[@"Slides"] count];
}

- (Class)classOfSlideAtIndex:(NSInteger)slideIndex {
    NSDictionary *info = _settings[@"Slides"][slideIndex];
    NSString *className = info[@"Class"];
    return NSClassFromString(className);
}

#pragma mark - Slide creation and warm up

// This method creates and initializes the slide at the specified index and returns it.
// The new slide is cached in the _slides array.
- (ASCSlide *)slideAtIndex:(NSInteger)slideIndex loadIfNeeded:(BOOL)loadIfNeeded {
    if (slideIndex < 0 || slideIndex >= [_settings[@"Slides"] count])
        return nil;
    
    // Look into the cache first
    ASCSlide *slide = _slideCache[@(slideIndex)];
    if (slide) {
        return slide;
    }
    
    if (!loadIfNeeded)
        return nil;
    
    // Create the new slide
    Class slideClass = [self classOfSlideAtIndex:slideIndex];
    slide = [[slideClass alloc] init];
    
    // Update its parameters
    NSDictionary *info = _settings[@"Slides"][slideIndex];
    NSDictionary *parameters = info[@"Parameters"];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [slide setValue:obj forKey:key];
    }];
    
    _slideCache[@(slideIndex)] = slide;
    
    if (!slide)
        return nil;
    
    // Setup the slide
    [slide  setupSlideWithPresentationViewController:self];
    
    return slide;
}

// Preload the next slide
- (void)prepareSlideAtIndex:(NSInteger)slideIndex {
    // Retrieve the slide to preload
    ASCSlide *slide = [self slideAtIndex:slideIndex loadIfNeeded:YES];
    
    if (slide) {
        [SCNTransaction flush]; // make sure that all pending transactions are flushed otherwise objects not added yet to the scene graph would not be preloaded
        
        // Preload the node tree
        [self.view prepareObject:slide.contentNode shouldAbortBlock:nil];
        
        // Preload the floor image if any
        if ([slide.floorImageName length]) {
            NSImage *image = [[NSBundle mainBundle] imageForResource:slide.floorImageName];
            
            // Create a container for this image to be able to preload it
            SCNMaterial *material = [SCNMaterial material];
            material.diffuse.contents = image;
            material.diffuse.mipFilter = SCNFilterModeLinear; // we also want to preload mipmaps
            
            [SCNTransaction flush]; //make this material ready before warming up
            
            // Preload
            [self.view prepareObject:material shouldAbortBlock:nil];
            
            // Don't release the material now, otherwise we will loose what we just preloaded
            slide.floorWarmupMaterial = material;
        }
    }
}

#pragma mark - Navigating within a presentation

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
    NSUInteger oldIndex = _currentSlideIndex;
    
    // Load the slide at the specified index
    ASCSlide *slide = [self slideAtIndex:slideIndex loadIfNeeded:YES];
    
    if (!slide)
        return;
    
    // Compute the playback direction (did the user select next or previous?)
    float direction = slideIndex >= _currentSlideIndex ? 1 : -1;
    
    // Update badge
    self.showsNewInSceneKitBadge = [slide isNewIn10_9];
    
    // If we are playing backward, we need to use the slide we come from to play the correct transition (backward)
    NSInteger transitionSlideIndex = direction == 1 ? slideIndex : _currentSlideIndex;
    ASCSlide *transitionSlide = [self slideAtIndex:transitionSlideIndex loadIfNeeded:YES];
    
    // Make sure that the next operations are synchronized by using a transaction
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:0];
    {
        SCNNode *rootNode = slide.contentNode;
        SCNNode *textContainer = slide.textManager.textNode;
        
        SCNVector3 offset = SCNVector3Make(transitionSlide.transitionOffsetX, 0.0, transitionSlide.transitionOffsetZ);
        offset.x *= direction;
        offset.z *= direction;
        
        // Rotate offset based on current yaw
        double cosa = cos(-_cameraHandle.rotation.w);
        double sina = sin(-_cameraHandle.rotation.w);
        
        double tmpX = offset.x * cosa - offset.z * sina;
        offset.z = offset.x * sina + offset.z * cosa;
        offset.x = tmpX;
        
        // If we don't move, fade in
        if (offset.x == 0 && offset.y == 0 && offset.z == 0 && transitionSlide.transitionRotation == 0) {
            rootNode.opacity = 0;
        }
        
        // Don't animate the first slide
        BOOL shouldAnimate = !(slideIndex == 0 && _currentSlideIndex == 0);
        
        // Update current slide index
        _currentSlideIndex = slideIndex;
        
        // Go to step 0
        [self goToSlideStep:0];
        
        // Add the slide to the scene graph
        [self.view.scene.rootNode addChildNode:rootNode];
        
        // Fade in, update paramters and notify on completion
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:shouldAnimate ? slide.transitionDuration : 0];
        [SCNTransaction setCompletionBlock:^{
            [self didOrderInSlideAtIndex:slideIndex];
        }];
        {
            rootNode.opacity = 1;
            
            _cameraHandle.position = SCNVector3Make(_cameraHandle.position.x + offset.x, slide.altitude, _cameraHandle.position.z + offset.z);
            _cameraHandle.rotation = SCNVector4Make(0, 1, 0, _cameraHandle.rotation.w + transitionSlide.transitionRotation * M_PI / 180.0 * direction);
            _cameraPitch.rotation = SCNVector4Make(1, 0, 0, slide.pitch * M_PI / 180.0);
            
            [self updateLightingForSlideAtIndex:slideIndex];
            
            _floor.reflectivity = slide.floorReflectivity;
            _floor.reflectionFalloffEnd = slide.floorFalloff;
        }
        [SCNTransaction commit];
        
        // Compute the position of the text (in world space, relative to the camera)
        CATransform3D textWorldTransform = CATransform3DConcat(CATransform3DMakeTranslation(0, -3.3, -28), _cameraNode.worldTransform);
        
        // Place the rest of the slide
        rootNode.transform = textWorldTransform;
        rootNode.position = SCNVector3Make(rootNode.position.x, 0, rootNode.position.z); // clear altitude
        rootNode.rotation = SCNVector4Make(0, 1, 0, _cameraHandle.rotation.w); // use same rotation as the camera to simplify the placement of the elements in slides
        
        // Place the text
        CATransform3D textTransform = [textContainer.parentNode convertTransform:textWorldTransform fromNode:nil];
        textContainer.transform = textTransform;
        
        // Place the ground node
        SCNVector3 localPosition = SCNVector3Make(0, 0, 0);
        SCNVector3 worldPosition = [slide.groundNode.parentNode convertPosition:localPosition toNode:nil];
        worldPosition.y = 0; // make it touch the ground
        
        localPosition = [slide.groundNode.parentNode convertPosition:worldPosition fromNode:nil];
        slide.groundNode.position = localPosition;
        
        // Update the floor image if needed
        NSImage *floorImage = [[NSBundle mainBundle] imageForResource:slide.floorImageName];
        [self updateFloorImage:floorImage forSlide:slide];
    }
    [SCNTransaction commit];
    
    // Preload the next slide after some delay
    double delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self prepareSlideAtIndex:slideIndex + 1];
    });
    
    // Order out previous slide if any
    if (oldIndex != _currentSlideIndex)
        [self willOrderOutSlideAtIndex:oldIndex];
}

- (void)goToSlideStep:(NSInteger)index {
    _currentSlideStep = index;
    
    ASCSlide *slide = [self slideAtIndex:_currentSlideIndex loadIfNeeded:YES];
    if (!slide)
        return;
    
    if ([self.delegate respondsToSelector:@selector(presentationViewController:willPresentSlideAtIndex:step:)]) {
        [self.delegate presentationViewController:self willPresentSlideAtIndex:_currentSlideIndex step:_currentSlideStep];
    }
    
    [slide presentStepIndex:_currentSlideStep withPresentionViewController:self];
}

- (void)didOrderInSlideAtIndex:(NSInteger)slideIndex {
    ASCSlide *slide = [self slideAtIndex:slideIndex loadIfNeeded:NO];
    [slide didOrderInWithPresentionViewController:self];
}

- (void)willOrderOutSlideAtIndex:(NSInteger)slideIndex {
    ASCSlide *slide = [self slideAtIndex:slideIndex loadIfNeeded:NO];
    if (slide) {
        SCNNode *node = slide.contentNode;
        
        // Fade out and remove on completion
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0.75];
        [SCNTransaction setCompletionBlock:^{
            [node removeFromParentNode];
        }];
        {
            node.opacity = 0.0;
        }
        [SCNTransaction commit];
        
        [slide willOrderOutWithPresentionViewController:self];
        
        [_slideCache removeObjectForKey:@(slideIndex)];
    }
}

#pragma mark - Scene decorations

- (void)setShowsNewInSceneKitBadge:(BOOL)showsBadge {
    _showsNewInSceneKitBadge = showsBadge;
    
    if (_newBadgeNode && showsBadge)
        return; // already visible
    
    if (!_newBadgeNode && !showsBadge)
        return; // already invisible
    
    // Load the model and the animation
    if (!_newBadgeNode) {
        _newBadgeNode = [SCNNode node];
        
        SCNNode *badgeNode = [_newBadgeNode asc_addChildNodeNamed:@"newBadge" fromSceneNamed:@"newBadge" withScale:1];
        _newBadgeNode.scale = SCNVector3Make(0.03, 0.03, 0.03);
        _newBadgeNode.opacity = 0;
        _newBadgeNode.position = SCNVector3Make(50, 20, -10);
        _newBadgeNode.rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
        
        SCNNode *imageNode = [_newBadgeNode childNodeWithName:@"badgeImage" recursively:YES];
        imageNode.geometry.firstMaterial.emission.intensity = 0.0;
        
        [self.cameraPitch addChildNode:_newBadgeNode];
        
        _newBadgeAnimation = [badgeNode animationForKey:badgeNode.animationKeys[0]];
        [badgeNode removeAllAnimations];
        
        _newBadgeAnimation.speed = 1.5;
        _newBadgeAnimation.fillMode = kCAFillModeBoth;
        _newBadgeAnimation.usesSceneTimeBase = NO;
        _newBadgeAnimation.removedOnCompletion = NO;
    }
    
    // Play
    if (showsBadge) {
        [_newBadgeNode addAnimation:_newBadgeAnimation forKey:nil];
        
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:2];
        {
            _newBadgeNode.position = SCNVector3Make(14, 8, -20);
            
            [SCNTransaction setCompletionBlock:^{
                [SCNTransaction begin];
                [SCNTransaction setAnimationDuration:3];
                {
                    SCNNode *ropeNode = [_newBadgeNode childNodeWithName:@"rope02" recursively:YES];
                    ropeNode.opacity = 0.0;
                }
                [SCNTransaction commit];
                
            }];
            
            _newBadgeNode.opacity = 1.0;
            SCNNode *imageNode = [_newBadgeNode childNodeWithName:@"badgeImage" recursively:YES];
            imageNode.geometry.firstMaterial.emission.intensity = 0.4;
        }
        [SCNTransaction commit];
    }
    
    // Or hide
    else {
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:1.5];
        {
            [SCNTransaction setCompletionBlock:^{
                [_newBadgeNode removeFromParentNode];
                _newBadgeNode = nil;
            }];
            _newBadgeNode.position = SCNVector3Make(14, 50, -20);
            _newBadgeNode.opacity = 0.0;
        }
        [SCNTransaction commit];
    }
}

#pragma mark - Lighting the scene

- (void)initLighting {
    // Omni light (main light of the scene)
	_lights[ASCLightMain] = [SCNNode node];
    _lights[ASCLightMain].name = @"omni";
    _lights[ASCLightMain].position = SCNVector3Make(0, 3, -13);
	_lights[ASCLightMain].light = [SCNLight light];
	_lights[ASCLightMain].light.type = SCNLightTypeOmni;
    [_lights[ASCLightMain].light setAttribute:@10 forKey:SCNLightAttenuationStartKey];
    [_lights[ASCLightMain].light setAttribute:@50 forKey:SCNLightAttenuationEndKey];
	[_cameraHandle addChildNode:_lights[ASCLightMain]]; //make all lights relative to the camera node
    
    // Front light
	_lights[ASCLightFront] = [SCNNode node];
    _lights[ASCLightFront].name = @"front light";
    _lights[ASCLightFront].position = SCNVector3Make(0, 0, 0);
	_lights[ASCLightFront].light = [SCNLight light];
	_lights[ASCLightFront].light.type = SCNLightTypeDirectional;
	[_cameraHandle addChildNode:_lights[ASCLightFront]];
    
    // Spot light
	_lights[ASCLightSpot] = [SCNNode node];
    _lights[ASCLightSpot].name = @"spot light";
    _lights[ASCLightSpot].position = SCNVector3Make(0, 30, -19);
    _lights[ASCLightSpot].rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
	_lights[ASCLightSpot].light = [SCNLight light];
	_lights[ASCLightSpot].light.type = SCNLightTypeSpot;
    _lights[ASCLightSpot].light.shadowRadius = 10;
    [_lights[ASCLightSpot].light setAttribute:@30 forKey:SCNLightShadowNearClippingKey];
    [_lights[ASCLightSpot].light setAttribute:@50 forKey:SCNLightShadowFarClippingKey];
    [_lights[ASCLightSpot].light setAttribute:@10 forKey:SCNLightSpotInnerAngleKey];
    [_lights[ASCLightSpot].light setAttribute:@45 forKey:SCNLightSpotOuterAngleKey];
	[_cameraHandle addChildNode:_lights[ASCLightSpot]];
    
    // Left light
	_lights[ASCLightLeft] = [SCNNode node];
    _lights[ASCLightLeft].name = @"left light";
    _lights[ASCLightLeft].position = SCNVector3Make(-20, 10, -5);
	_lights[ASCLightLeft].light = [SCNLight light];
	_lights[ASCLightLeft].light.type = SCNLightTypeOmni;
    [_lights[ASCLightLeft].light setAttribute:@30 forKey:SCNLightAttenuationStartKey];
    [_lights[ASCLightLeft].light setAttribute:@80 forKey:SCNLightAttenuationEndKey];
	[_cameraHandle addChildNode:_lights[ASCLightLeft]];
    
    // Right light
	_lights[ASCLightRight] = [SCNNode node];
    _lights[ASCLightRight].name = @"right light";
    _lights[ASCLightRight].position = SCNVector3Make(20, 10, -5);
	_lights[ASCLightRight].light = [SCNLight light];
	_lights[ASCLightRight].light.type = SCNLightTypeOmni;
    [_lights[ASCLightRight].light setAttribute:@30 forKey:SCNLightAttenuationStartKey];
    [_lights[ASCLightRight].light setAttribute:@80 forKey:SCNLightAttenuationEndKey];
	[_cameraHandle addChildNode:_lights[ASCLightRight]];
    
    // Ambient light
	_lights[ASCLightAmbient] = [SCNNode node];
    _lights[ASCLightAmbient].name = @"ambient light";
	_lights[ASCLightAmbient].light = [SCNLight light];
	_lights[ASCLightAmbient].light.type = SCNLightTypeAmbient;
	[_scene.rootNode addChildNode:_lights[ASCLightAmbient]];
    
    // Switch off all the lights
    for (NSInteger i = 0; i < ASCLightCount; i++)
        _lights[i].light.color = [NSColor blackColor];
}

- (void)updateLightingForSlideAtIndex:(NSInteger)slideIndex {
    ASCSlide *slide = [self slideAtIndex:slideIndex loadIfNeeded:YES];
    
    _lights[ASCLightMain].position = slide.mainLightPosition;
    
    [self updateLightingWithIntensities:slide.lightIntensities];
    [self enableShadows:slide.enableShadows];
}

- (void)updateLightingWithIntensities:(NSArray *)intensities {
    for (NSInteger i = 0; i < ASCLightCount; i++) {
        CGFloat intensity = [intensities count] > i ? [intensities[i] floatValue] : 0;
        _lights[i].light.color = [NSColor colorWithDeviceHue:_lightHueAtSlideIndex(i)
                                                  saturation:_lightSaturationAtSlideIndex(i)
                                                  brightness:intensity
                                                       alpha:1];
    }
}

- (void)enableShadows:(BOOL)castsShadows {
    _lights[ASCLightSpot].light.shadowColor = [NSColor colorWithDeviceWhite:0 alpha:castsShadows ? 0.75 : 0.0];
    _lights[ASCLightSpot].light.castsShadow = castsShadows;
}

- (void)narrowSpotlight:(BOOL)narrow {
    if (narrow) {
        [_lights[ASCLightSpot].light setAttribute:@20 forKey:SCNLightSpotInnerAngleKey];
        [_lights[ASCLightSpot].light setAttribute:@30 forKey:SCNLightSpotOuterAngleKey];
    } else {
        [_lights[ASCLightSpot].light setAttribute:@10 forKey:SCNLightSpotInnerAngleKey];
        [_lights[ASCLightSpot].light setAttribute:@45 forKey:SCNLightSpotOuterAngleKey];
    }
}

- (void)riseMainLight:(BOOL)rise {
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

// Updates the secondary image of the floor if needed
- (void)updateFloorImage:(NSImage *)image forSlide:(ASCSlide *)slide {
    // We don't want to animate if we replace the secondary image by a new one
    // Otherwise we want to translate the secondary image to the new location
    BOOL disableAction = NO;
    
    if (_floorImage != image) {
        _floorImage = image;
        disableAction = YES;
        
        if (image) {
            // Set a new material property with this image to the "floorMap" custom property of the floor
            SCNMaterialProperty *property = [SCNMaterialProperty materialPropertyWithContents:image];
            property.wrapS = SCNWrapModeRepeat;
            property.wrapT = SCNWrapModeRepeat;
            property.mipFilter = SCNFilterModeLinear;
            
            [_floor.firstMaterial setValue:property forKey:@"floorMap"];
        }
    }
    
    if (image) {
        SCNVector3 slidePosition = [slide.groundNode convertPosition:SCNVector3Make(0, 0, 10) toNode:nil];
        
        if (disableAction) {
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0];
            {
                [_floor.firstMaterial setValue:[NSValue valueWithSCNVector3:slidePosition] forKey:@"floorImageNamePosition"];
            }
            [SCNTransaction commit];
        } else {
            [_floor.firstMaterial setValue:[NSValue valueWithSCNVector3:slidePosition] forKey:@"floorImageNamePosition"];
        }
    }
}

#pragma mark - Misc

CGFloat _lightSaturationAtSlideIndex(int index) {
    if (index >= 4) return 0.1; // colored
    return 0; // black and white
}

CGFloat _lightHueAtSlideIndex(int index) {
    if (index == 4) return 0; // red
    if (index == 5) return 200/360.0; // blue
    return 0; // black and white
}

@end
