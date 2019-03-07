/*
     File: ASCSlideNodeDelegate.m
 Abstract:  Node delegate rendering slide.  This sample code is not about OpenGL. Please read OpenGL sample for more details about OpenGL
 
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
#import "GLUtils.h"

#import <GLKit/GLKMath.h>
#import <GLKit/GLKTextureLoader.h>

#pragma mark Tool functions

//random [-1 ; +1]
static inline float FloatRand() {
    return ((double)random() / (INT_MAX/2)) - 1.f;
}

//variation function for the particle system
static inline float GetVariation(float iValue, float iVariation)
{
    float variation = FloatRand() * iVariation;
    return iValue + variation;
}

#pragma mark Particle system interface

// structure to represent a particle vertex
typedef struct {
    GLKVector4 position; // xyz: particle position, w: size
    GLKVector3 velocity; // xyz: particle velocity
    GLKVector2 uv; 		 // x:angle, y: life [0..1]
} ASCParticleVertex;

// structure to represent a particle
typedef struct {
    GLKVector4 pos; // w contains size
    GLKVector4 vel; // w contains size
    
    float angle;
    float angleVel;
    
    float life;
    float invLifespan;
    float invMass;
} ASCParticle;

@interface ASCParticleSystem : NSObject <SCNNodeRendererDelegate> {
    // System configuration
    GLKVector3 _initialLocationBoundsOrigin;
    GLKVector3 _initialLocationBoundsSize;
    GLKVector3 _initialVelocity;
    GLKVector3 _initialVelocityVariation;
    float	   _angularVelocity;
    float	   _angularVelocityVariation;
    float	   _initialSize;
    float	   _initialSizeVariation;
    float	   _terminalSize;
    float	   _terminalSizeVariation;
    float	   _lifespan;
    float	   _lifespanVariation; // percentage
    float	   _birthRate; // number of particles emitted per second
    float	   _birthRateVariation; // percentage
    
    // Actuators
    GLKVector3 _gravity;
    float	   _dampening;
    float	   _trailFactor;
    
    // ASCParticle data storage
    ASCParticle *_particles;
    NSInteger    _particlesMaxCount;

    // Emission management
    CFTimeInterval _lastUpdateTime;
    float		   _birthRateRemainder;

    // live particles
    int     *_liveASCParticles;
    GLsizei  _liveASCParticlesCount;
    
    GLKVector3 _bmin;
    GLKVector3 _bmax;
    
    // blend modes
    GLenum _srcBlend;
    GLenum _dstBlend;
    
    BOOL _enableZRead;
    BOOL _enableZWrite;
    
    // GL stuff
    BOOL _glIsInitialized;
    // Vertex array object, capturing all the rendering vertex attribs
    GLuint _vao;
    // Vertex Buffer Object, containing all the particle rendering data
    GLuint _vbo;
    // Index buffer object, contaning triangle indices
    GLuint _ibo;
    // A custom program, containing a vertex, a geometry and a fragment shaders
    GLuint _program;
    // Uniform locations
    GLuint _mvLoc;
    GLuint _projLoc;
    GLuint _trailFactorLoc;
    GLuint _texLoc;
    GLuint _rampLoc;
    GLuint _textureName;
    GLuint _colorRampName;
}

// The position of the emission of particles (can be nil)
@property (nonatomic, retain) SCNNode *emitter;

// The node that will "own" the particle system.
@property (nonatomic, retain) SCNNode *owner;

// OpenGL context
@property (nonatomic, retain) NSOpenGLContext *openGLContext;

- (id)initWithMaxCount:(NSInteger)maxCount node:(SCNNode *)node context:(NSOpenGLContext *)ctx;
- (void)initGL;
- (void)dealloc;

- (void)update;
- (void)prepareVBO;
- (void)sortWithViewDirection:(GLKVector3)viewDir;

- (void)initASCParticle:(ASCParticle *)p;
- (void)updateASCParticle:(ASCParticle *)p deltaTime:(float)deltaTime;

- (void)setupSmoke;
- (void)setupFire;

@end

#pragma mark SlideNodeDelegate interface

@interface ASCSlideNodeDelegate : ASCSlide

@property (strong) ASCParticleSystem *particleSystem;
@property (strong) SCNNode *sword;
@property (strong) SCNNode *localRoot;
@property (strong) SCNNode *smokeRoot;
@property (strong) SCNNode *heroRoot;
@property (strong) SCNNode *holeNode;
@property (strong) CAAnimation *attackAnimation;
@property BOOL stopAttackLoop;

@end

#pragma mark SlideNodeDelegate implementation

@implementation ASCSlideNodeDelegate

@synthesize particleSystem;

- (NSUInteger)numberOfSteps {
    return 3;
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentation {
    //retrieve the text manager
    ASCSlideTextManager *textManager = [self textManager];
    
    //add some text
    [textManager setTitle:@"Extending Scene Kit with OpenGL"];
    [textManager setSubtitle:@"Node delegate rendering"];
    [textManager addBullet:@"Custom OpenGL code per node" atLevel:0];
    [textManager addBullet:@"Overrides Scene Kit’s rendering" atLevel:0];
    [textManager addBullet:@"Transform and geometry information are provided by Scene Kit" atLevel:0];
    
    //create a new node that will own the chemney
    self.smokeRoot = [SCNNode node];
    
    //place it
    [self.smokeRoot setPosition:SCNVector3Make(0,0.01,12)];
    [self.ground addChildNode:self.smokeRoot];
    
    self.holeNode = [SCNNode node];
    self.holeNode.name = @"hole";
    self.holeNode.rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
    self.holeNode.scale = SCNVector3Make(0, 0, 0);
    self.holeNode.geometry = [SCNPlane planeWithWidth:1.7 height:1.7];
    self.holeNode.geometry.firstMaterial.diffuse.contents = [NSImage imageNamed:@"hole"];
    self.holeNode.geometry.firstMaterial.diffuse.mipFilter = SCNFilterModeLinear;
    [self.smokeRoot addChildNode:self.holeNode];
    
    SCNNode *emitter = [SCNNode node];
    emitter.renderingOrder = 100; //make sure the particles are rendered last to render over the text
    [self.smokeRoot addChildNode:emitter];
    
    //instanciate particle system
    self.particleSystem = [[ASCParticleSystem alloc] initWithMaxCount:500 node:emitter context:[presentation.view openGLContext]];
    
    //animate
    {
        [emitter setRotation:SCNVector4Make(0, 1, 0, 0)];
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
        rotationAnimation.duration = 30.0;
        rotationAnimation.repeatCount = FLT_MAX;
        rotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI*2)];
        [emitter addAnimation:rotationAnimation forKey:nil];
    }
    
    self.heroRoot = [SCNNode node];
    self.heroRoot.scale = SCNVector3Make(0.023, 0.023, 0.023);
    self.heroRoot.position = SCNVector3Make(0, 0, 15);
    self.heroRoot.rotation = SCNVector4Make(1, 0, 0, -M_PI/2);
    [self.ground addChildNode:self.heroRoot];
    
    SCNNode *rotateNode = [SCNNode node];
    
    [self.heroRoot addChildNode:rotateNode];
    
    
	SCNScene *scene = [SCNScene sceneNamed:@"hero.dae"];
    
    SCNNode *heroGroup = scene.rootNode.clone;
    heroGroup.name = @"heroGroup";
    self.sword = [heroGroup childNodeWithName:@"Bip01_R_Sword" recursively:YES];

    SCNNode *swordEmitter = [SCNNode node];
    [swordEmitter setPosition:SCNVector3Make(0, 0, 110)];
    [swordEmitter setLight:[SCNLight light]];
    [swordEmitter.light setType:SCNLightTypeOmni];
    [swordEmitter.light setAttribute:@"8.0" forKey:SCNLightAttenuationEndKey];
    [swordEmitter.light setType:SCNLightTypeOmni];
    [swordEmitter.light setColor:[NSColor darkGrayColor]];
    [self.sword addChildNode:swordEmitter];
    
    { // animate a flickering blue light
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"color.b"];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.fromValue = @3.0;
        animation.toValue = @2.0;
        animation.repeatCount = FLT_MAX;
        animation.duration = 0.15;
        [swordEmitter.light addAnimation:animation forKey:nil];
    }
    
    [rotateNode addChildNode:heroGroup];
    [self.heroRoot setHidden:YES];
    
    self.localRoot = [SCNNode node];
    [self.ground addChildNode:self.localRoot];
    
    SCNNode *skell = [heroGroup childNodeWithName:@"skell" recursively:YES];
    
    for (NSString *key in [skell animationKeys]) {
        CAAnimation *animation = [skell animationForKey:key];
    
        animation.usesSceneTimeBase = NO;
        animation.repeatCount = FLT_MAX;
        
        [skell addAnimation:animation forKey:key];
    }

    self.attackAnimation = [self loadHeroAnimation:@"attack" withIdentifier:@"attackID"];
}

//load an animation identified by "identifier" from a dae referenced by "dae"
- (CAAnimation *)loadHeroAnimation:(NSString *)path withIdentifier:(NSString *)identifier {
    //load the DAE using SCNSceneSource to be able to retrieve animation by identifiers
	path = [[NSBundle mainBundle] pathForResource:path ofType:@"dae"];	
	SCNSceneSource *source = [SCNSceneSource sceneSourceWithURL:[NSURL fileURLWithPath:path] options:nil];
    
    //search for the animation
	CAAnimation *animation = [source entryWithIdentifier:identifier withClass:[CAAnimation class]];

    //blend animation for smoother transition
    animation.speed = 0.75;
    [animation setFadeInDuration:0.3];
    [animation setFadeOutDuration:0.3];

    return animation;
}

// launch an animation on the hero
- (void)triggerAttack {
    [self.heroRoot addAnimation:self.attackAnimation forKey:@"attack"];
    
    if (self.stopAttackLoop == NO) {
        double delayInSeconds = 3.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [self triggerAttack];
        });
    }
}

- (void)orderInWithPresentionViewController:(ASCPresentationViewController *)controller {
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:0.5];
    [SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    self.holeNode.scale = SCNVector3Make(1, 1, 1);
    
    [SCNTransaction commit];
}

// change the slide step index
- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)controller {
    NSOpenGLContext *glContext = [controller.view openGLContext];
    [glContext makeCurrentContext];

    CGLLockContext([glContext CGLContextObj]);
    
    switch (index) {
        case 1:
            [self.particleSystem setupSmoke];
            break;
        case 2:
        {
            [self.smokeRoot setHidden:YES];
            [self.heroRoot setHidden:NO];
            [self.particleSystem setOwner:self.localRoot];
            [self.particleSystem setEmitter:self.sword];
            [self.particleSystem setupFire];

            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:2.0];
            [controller updateLightingWithIntensities:@[@0.4, @0.4]];
            [SCNTransaction commit];
            
            
            //animate hero
            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                [self triggerAttack];
            });
        }
            break;
    }

    CGLUnlockContext([glContext CGLContextObj]);
}

// orderOut the slide
- (void)orderOutWithPresentionViewController:(ASCPresentationViewController *)controller {
    self.stopAttackLoop = YES;
}

@end

#pragma mark ASCParticleSystem implementation

// Implementationof the ASCParticle System class
@implementation ASCParticleSystem

// Init a ASCParticle system with a maximum number of particles and a GL context
- (id)initWithMaxCount:(NSInteger)maxCount node:(SCNNode *)node context:(NSOpenGLContext *)ctx {
    if (self = [super init]) {
        self.openGLContext = ctx;

        _particlesMaxCount = maxCount;
        _particles = calloc(sizeof(ASCParticle), maxCount);
        _birthRateRemainder = 0;

        _liveASCParticles = malloc(sizeof(int) * maxCount);
        _liveASCParticlesCount = 0;
        
        _initialLocationBoundsOrigin = GLKVector3Make(0.f, 0.f, 0.f);
        _initialLocationBoundsSize = GLKVector3Make(0.1f, 0.f, .1f);
        _initialVelocity = GLKVector3Make(1, 4, 1);
        _initialVelocityVariation = GLKVector3Make(0.1, 0.2, 0.1);
        
        _srcBlend = GL_ONE;
        _dstBlend = GL_ONE;
        
        _angularVelocity = 0.1;
        _angularVelocityVariation = 0.5;
        
        _initialSize = 0.5;
        _initialSizeVariation = 0.2;
        _terminalSize = 3.0;
        _terminalSizeVariation = 1.0;
        
        _birthRate = 0.f;
        _birthRateVariation = 0.f;

        _lifespan = 5.f;
        _lifespanVariation = 0.5f;
        
        _lastUpdateTime = CFAbsoluteTimeGetCurrent();
        
        _gravity = GLKVector3Make(0.f, 0.f, 0.f);
        _dampening = 0.f;
        _trailFactor = 0;
        
        self.owner = node;
    }
    return self;
}

- (void)setOwner:(SCNNode *)owner {
    // unregister from old owner
    [_owner setRendererDelegate:nil];
    // and set as delegate of the new one
    _owner = owner;
    [_owner setRendererDelegate:self];
}

// GL attribute location
enum {
	ASC_QUAD_ATTRIB_POS,
	ASC_QUAD_ATTRIB_VEL,
	ASC_QUAD_ATTRIB_UV
};

- (void)initGL {
    // Create and bind a VAO
    glGenVertexArraysAPPLE(1, &_vao);
    glBindVertexArrayAPPLE(_vao);
    
    // Create and bind a VBO
    glGenBuffers(1, &_vbo);
    glBindBuffer(GL_ARRAY_BUFFER, _vbo);
    
    // initialize max size
    glBufferData(GL_ARRAY_BUFFER, sizeof(ASCParticleVertex) * _particlesMaxCount, 0, GL_STREAM_DRAW);
    
    // Enable needed vertex attribs
    glVertexAttribPointer(ASC_QUAD_ATTRIB_POS, 4, GL_FLOAT, GL_FALSE, sizeof(ASCParticleVertex), (void*)offsetof(ASCParticleVertex,position));
    glEnableVertexAttribArray(ASC_QUAD_ATTRIB_POS);
    glVertexAttribPointer(ASC_QUAD_ATTRIB_VEL, 3, GL_FLOAT, GL_FALSE, sizeof(ASCParticleVertex), (void*)offsetof(ASCParticleVertex,velocity));
    glEnableVertexAttribArray(ASC_QUAD_ATTRIB_VEL);
    glVertexAttribPointer(ASC_QUAD_ATTRIB_UV, 2, GL_FLOAT, GL_FALSE, sizeof(ASCParticleVertex), (void*)offsetof(ASCParticleVertex,uv));
    glEnableVertexAttribArray(ASC_QUAD_ATTRIB_UV);
    
    // create an IBO and capture it in the VAO
    glGenBuffers(1, &_ibo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _ibo);
    
    // fill triangle indices with the same vertex
    size_t indicesSize = _particlesMaxCount * 3 * sizeof(GLint);
    GLint* indices = malloc(indicesSize);
    for (int i = 0; i < _particlesMaxCount; ++i) {
        indices[i*3+0] = i;
        indices[i*3+1] = i;
        indices[i*3+2] = i;
    }
    
    // upload the indices to the IBO
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indicesSize, indices, GL_STATIC_DRAW);
    free(indices);

    // unbind the VAO
    glBindVertexArrayAPPLE(0);
    
    // associate vertex attribute index with glsl attribute names
    ASCAttribLocation attrib[] = {
        {ASC_QUAD_ATTRIB_POS, "a_pos"},
        {ASC_QUAD_ATTRIB_VEL, "a_vel"},
        {ASC_QUAD_ATTRIB_UV, "a_uv"},
        {0, 0} // NULL terminated array
    };
    
    // Create the program
    _program = ASCCreateProgramWithAttributeLocations(@"ParticleSystem", attrib);
    
    // and retieve the location of needed uniforms
    _mvLoc = glGetUniformLocation ( _program, "u_mv" );
    _projLoc = glGetUniformLocation ( _program, "u_p" );
    _trailFactorLoc = glGetUniformLocation ( _program, "u_trailFactor" );
    _texLoc = glGetUniformLocation ( _program, "u_tex" );
    _rampLoc = glGetUniformLocation ( _program, "u_ramp" );
    
    _glIsInitialized = YES;
}

- (void)dealloc {
    self.owner.rendererDelegate = nil;

    // Clean GL objects (locking the context)
    [self.openGLContext makeCurrentContext];
    CGLLockContext([self.openGLContext CGLContextObj]);

    if (_vbo)
        glDeleteBuffers(1, &_vbo);
    if (_ibo)
        glDeleteBuffers(1, &_ibo);
    if (_vao)
        glDeleteVertexArraysAPPLE(1, &_vao);
    if (_program)
        glDeleteProgram(_program);
    if (_textureName)
        glDeleteTextures(1, &_textureName);
    if (_colorRampName)
        glDeleteTextures(1, &_colorRampName);
    
    CGLUnlockContext([self.openGLContext CGLContextObj]);
    
    free(_particles);
    free(_liveASCParticles);
}

- (void)setupSmoke {
    _initialLocationBoundsOrigin = GLKVector3Make(0.f, 0.f, 0.f);
    _initialLocationBoundsSize = GLKVector3Make(0.1f, 0.f, .1f);
    _initialVelocity = GLKVector3Make(1, 4, 1);
    _initialVelocityVariation = GLKVector3Make(0.1, 0.2, 0.1);
    
    _angularVelocity = 0.1;
    _angularVelocityVariation = 0.5;

    _srcBlend = GL_SRC_ALPHA;
    _dstBlend = GL_ONE_MINUS_SRC_ALPHA;

    _enableZRead = YES;
    _enableZWrite = NO;
    
    _initialSize = 0.5;
    _initialSizeVariation = 0.2;
    _terminalSize = 3.0;
    _terminalSizeVariation = 1.0;
    
    _birthRate = 10.f;
    _birthRateVariation = 0.3f;
    
    _lifespan = 5.f;
    _lifespanVariation = 0.5f;

    _dampening = 0.4f;
    _trailFactor = 0.f;
    _gravity = GLKVector3Make(0.f, 0.f, 0.f);

    if (_textureName)
        glDeleteTextures(1, &_textureName);
    if (_colorRampName)
        glDeleteTextures(1, &_colorRampName);

    _textureName = [[GLKTextureLoader textureWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tex_smoke" ofType:@"png"] options:nil error:nil] name];
    _colorRampName = [[GLKTextureLoader textureWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ramp_smoke" ofType:@"png"] options:nil error:nil] name];
}

- (void)setupFire {
    memset(_particles, 0, sizeof(ASCParticle) * _particlesMaxCount);
    
    _initialLocationBoundsOrigin = GLKVector3Make(20.f, 10.f, 110.f);
    _initialLocationBoundsSize = GLKVector3Make(10.f, 5.f, 60.f);
    
    _initialVelocity = GLKVector3Make(0., 0., 0.);
    _initialVelocityVariation = GLKVector3Make(0., 0., 0.);

    _angularVelocity = 0.1;
    _angularVelocityVariation = 3.5;
    
    _srcBlend = GL_SRC_ALPHA;
    _dstBlend = GL_ONE;

    _enableZRead = YES;
    _enableZWrite = NO;
    
    _initialSize = 0.1;
    _initialSizeVariation = 0.2;
    _terminalSize = 1.0;
    _terminalSizeVariation = 1.0;

    _birthRate = 180.f;
    _birthRateVariation = 0.6f;
    
    _lifespan = 1.f;
    _lifespanVariation = 0.5f;

    _dampening = 0.0f;
    _trailFactor = 0.1;
    _gravity = GLKVector3Make(0.f, 2.98f, 0.f);
    
    if (_textureName)
        glDeleteTextures(1, &_textureName);
    if (_colorRampName)
        glDeleteTextures(1, &_colorRampName);

    _textureName = [[GLKTextureLoader textureWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tex_fire" ofType:@"png"] options:nil error:nil] name];
    _colorRampName = [[GLKTextureLoader textureWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ramp_water" ofType:@"png"] options:nil error:nil] name];
}

// Initialize a particle with current system values
- (void)initASCParticle:(ASCParticle *)p {
    p->life = GetVariation(_lifespan, _lifespan * _lifespanVariation);
    p->invLifespan = 1.f / p->life;
    p->invMass = 1.f;

    p->pos.x = FloatRand() * _initialLocationBoundsSize.x + _initialLocationBoundsOrigin.x;
    p->pos.y = FloatRand() * _initialLocationBoundsSize.y + _initialLocationBoundsOrigin.y;
    p->pos.z = FloatRand() * _initialLocationBoundsSize.z + _initialLocationBoundsOrigin.z;
    p->pos.w = GetVariation(_initialSize, _initialSizeVariation);

    if (_emitter) {
        // Does not work with presentation instance!!!!!!!!
        SCNVector3 lPos = [_owner convertPosition:SCNVector3FromGLKVector3(*(GLKVector3*)&p->pos) fromNode:[_emitter presentationNode]];
        p->pos.x = lPos.x;
        p->pos.y = lPos.y;
        p->pos.z = lPos.z;
    }
    
    p->vel.x = GetVariation(_initialVelocity.x, _initialVelocityVariation.x);
    p->vel.y = GetVariation(_initialVelocity.y, _initialVelocityVariation.y);
    p->vel.z = GetVariation(_initialVelocity.z, _initialVelocityVariation.z);
    p->vel.w = (GetVariation(_terminalSize, _terminalSizeVariation) - p->pos.w) / p->life;
    
    p->angle = FloatRand() * M_PI;
    p->angleVel = GetVariation(_angularVelocity, _angularVelocityVariation);
}

// Update a particle
- (void)updateASCParticle:(ASCParticle *)p deltaTime:(float)dt {
    GLKVector3 gravity = GLKVector3MultiplyScalar(_gravity, dt);

    float dtonmass = dt * p->invMass;
    
    // gravity
    p->vel.x += gravity.x;
    p->vel.y += gravity.y;
    p->vel.z += gravity.z;
    
    // dampening
    float dampdt = _dampening * dtonmass;
    p->vel.x -= dampdt * p->vel.x;
    p->vel.y -= dampdt * p->vel.y;
    p->vel.z -= dampdt * p->vel.z;
    
    p->pos.x += p->vel.x * dt;
    p->pos.y += p->vel.y * dt;
    p->pos.z += p->vel.z * dt;
    p->pos.w += p->vel.w * dt;
    p->angle += p->angleVel * dt;

    // update Bonding Box
    if (p->pos.x < _bmin.x)
        _bmin.x = p->pos.x;
    if (p->pos.y < _bmin.y)
        _bmin.y = p->pos.y;
    if (p->pos.z < _bmin.z)
        _bmin.z = p->pos.z;
    
    if (p->pos.x > _bmax.x)
        _bmax.x = p->pos.x;
    if (p->pos.y > _bmax.y)
        _bmax.y = p->pos.y;
    if (p->pos.z > _bmax.z)
        _bmax.z = p->pos.z;
}

// Update the particle system
- (void)update {
    // compute delta time
    CFTimeInterval currentTime = CFAbsoluteTimeGetCurrent();
    float deltaTime = currentTime - _lastUpdateTime;
    _lastUpdateTime = currentTime;

    // Compute emission count
    float newCount = deltaTime * _birthRate;
    newCount = GetVariation(newCount, newCount * _birthRateVariation);
    newCount += _birthRateRemainder;
    float intCount = truncf(newCount);
    _birthRateRemainder = newCount - intCount;
    
    // Update existing ones and generate new ones
    _bmin = GLKVector3Make(FLT_MAX, FLT_MAX, FLT_MAX);
    _bmax = GLKVector3Make(FLT_MIN, FLT_MIN, FLT_MIN);
    GLsizei liveCount = 0;
    for (int i = 0; i < _particlesMaxCount; ++i) {
        ASCParticle *p = &_particles[i];
        if (p->life > deltaTime) { // still alive
            p->life -= deltaTime;
            [self updateASCParticle:p deltaTime:deltaTime];
            _liveASCParticles[liveCount++] = i;
            
        } else { // particle's dead
            if (intCount > 0.f) { // create a new one
                intCount -= 1.f;
                [self initASCParticle:p];
                _liveASCParticles[liveCount++] = i;
                
            } else {
                if (p->life != 0.f)
                    p->life = 0.f; // ensure dead particle have 0 lifespan
            }
        }
    }
    
    _liveASCParticlesCount = liveCount;
    
    // Update the SCNNode bounding box
    SCNVector3 bmin = SCNVector3FromGLKVector3(_bmin);
    SCNVector3 bmax = SCNVector3FromGLKVector3(_bmax);
    [_owner setBoundingBoxMin:&bmin max:&bmax];
}

// Sort the live particles along the view direction
- (void)sortWithViewDirection:(GLKVector3)viewDir {
    qsort_b(_liveASCParticles, _liveASCParticlesCount, sizeof(int), ^int(const void* a, const void* b) {
        ASCParticle* pa = _particles + *(int *)a;
        ASCParticle* pb = _particles + *(int *)b;
        float aDot = GLKVector3DotProduct(viewDir, *(GLKVector3*)&pa->pos);
        float bDot = GLKVector3DotProduct(viewDir, *(GLKVector3*)&pb->pos);
        return (aDot < bDot) ? -1 : 1;
    });
}

// invoked when updating the VBO with the current live particles
- (void)prepareVBO {
    // Update VBO, filling vertices in the back to front order
    glBindBuffer(GL_ARRAY_BUFFER, _vbo);
    // Buffer orphaning
    glBufferData(GL_ARRAY_BUFFER, sizeof(ASCParticleVertex) * _particlesMaxCount, NULL, GL_STREAM_DRAW);
    // Map the vbo on CPU memory
    ASCParticleVertex* vboVertices = (ASCParticleVertex*)glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
    if (vboVertices) {
        for (int i = 0; i < _liveASCParticlesCount; ++i) {
            ASCParticle *p = &_particles[_liveASCParticles[i]];
            
            vboVertices[i].position = p->pos;
            vboVertices[i].velocity = *(GLKVector3 *)&p->vel;
            vboVertices[i].uv.x = p->angle;
            vboVertices[i].uv.y = 1.f - p->life * p->invLifespan;
        }
        
        // unmap the buffer
        glUnmapBuffer(GL_ARRAY_BUFFER);
    }
    // unbind the VBO, to avoid someone else messing with it
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

// invoked by SceneKit with "node" has to be rendered
- (void)renderNode:(SCNNode *)node renderer:(SCNRenderer *)renderer arguments:(NSDictionary *)arguments {
    //update the particle system. Ideally this should be done outside of the node rendering as the updating of bounding box is done in the update.
    // - (void)renderer:(id <SCNSceneRenderer>)aRenderer willRenderScene:(SCNScene *)scene atTime:(NSTimeInterval)time is a good place to do so.
    [self update];

    // if no particles are alive, nothing to render -> exit
    if (_liveASCParticlesCount == 0)
        return;

    // lazy GL initialization, to ensure that we are creating our resources
    // on the GL context that will effectively be used to render
    if (!_glIsInitialized)
        [self initGL];
    
    // Sort the particles, in the front to back order
    GLKVector3 localView = SCNVector3ToGLKVector3([node convertPosition:SCNVector3Make(0,0,0) fromNode:renderer.pointOfView]);
    [self sortWithViewDirection:GLKVector3Normalize(localView)];

    // upload particle vertices in VBO
    [self prepareVBO];
    
    // Prevent depth buffer reading if needed
    if (!_enableZRead)
        glDisable(GL_DEPTH_TEST);

    // Prevent depth buffer writing if needed
    if (!_enableZWrite)
        glDepthMask(false);
    
    // Enable alpha test (discard fragment with alpha == 0)
    glEnable( GL_ALPHA_TEST);
    glAlphaFunc(GL_GREATER, 0.0f);

    // Enable blending (customizable per system)
    glEnable(GL_BLEND);
	glBlendFunc(_srcBlend, _dstBlend);
    
    // Bind the VAO
    glBindVertexArrayAPPLE(_vao);
    // Bind our program
    glUseProgram(_program);

    // Fill Uniforms

    // ModelView
    GLKMatrix4 mv = GLKMatrix4FromCATransform3D([[arguments objectForKey:SCNModelViewTransform] CATransform3DValue]);
    glUniformMatrix4fv(_mvLoc, 1, NO, mv.m);

    // Projection
    GLKMatrix4 proj = GLKMatrix4FromCATransform3D([[arguments objectForKey:SCNProjectionTransform] CATransform3DValue]);
    glUniformMatrix4fv(_projLoc, 1, NO, proj.m);
    
    // trail factor (length of stretched particles)
    glUniform1f(_trailFactorLoc, _trailFactor);
    
    // Bind samplers
    ASCBindSampler(0, _texLoc, _textureName, GL_TEXTURE_2D);
    ASCBindSampler(1, _rampLoc, _colorRampName, GL_TEXTURE_2D);

    // Draw the particles
    glDrawElements(GL_TRIANGLES, _liveASCParticlesCount * 3, GL_UNSIGNED_INT, 0);

    // restore default VAO
    glBindVertexArrayAPPLE(0);
    
    // Unbind samplers
    ASCUnbindSampler(1, GL_TEXTURE_2D);
    ASCUnbindSampler(0, GL_TEXTURE_2D);

    // Restore default states
    glDisable(GL_BLEND);
    glDisable( GL_ALPHA_TEST);
    if (!_enableZRead)
        glEnable(GL_DEPTH_TEST);
    if (!_enableZWrite)
        glDepthMask(true);
}

@end
