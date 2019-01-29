/*
     File: ASCSlideNodeDelegate.m
 Abstract: Illustrates how node delegate rendering slide can be used for particle systems.
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
#import "ASCSlideTextManager.h"
#import "ASCSlide.h"
#import "Utils.h"
#import "GLUtils.h"

#import <GLKit/GLKMath.h>
#import <GLKit/GLKTextureLoader.h>

#pragma mark Tool functions

static inline float floatRand() {
    return ((double)random() / (INT_MAX / 2)) - 1.f; // in [-1 ; +1]
}

static inline float sample(float value, float variation) {
    return value + floatRand() * variation;
}

#pragma mark Particle system interface

// GL attribute locations
enum {
	ASC_QUAD_ATTRIB_POSITION,
	ASC_QUAD_ATTRIB_VELOCITY,
	ASC_QUAD_ATTRIB_ANGLE_LIFE
};

// Structure to represent a vertex
typedef struct {
    GLKVector4 position;     // xyz = particle position, w = size
    GLKVector3 velocity;     // xyz = particle velocity
    GLKVector2 angleAndLife; // x = angle, y = life
} ASCVertex;

// Structure to represent a particle
typedef struct {
    GLKVector4 position; // w = size
    GLKVector4 velocity; // w = size
    
    float angle;
    float angleVelocity;
    
    float life;
    float invLifespan;
    float invMass;
} ASCParticle;

// A class used to make particle systems
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
    float	   _lifespanVariation;
    float	   _birthRate;
    float	   _birthRateVariation;
    
    // Actuators
    GLKVector3 _gravity;
    float	   _dampening;
    float	   _trailFactor;
    
    // Particle data storage
    ASCParticle *_particles;
    NSInteger    _particlesMaxCount;
    
    // Emission management
    CFTimeInterval _lastUpdateTime;
    float		   _birthRateRemainder;
    
    // Live particles
    int     *_liveASCParticles;
    GLsizei  _liveASCParticlesCount;
    
    // Bounding box
    GLKVector3 _bboxMin;
    GLKVector3 _bboxMax;
    
    // Blend modes
    GLenum _srcBlend;
    GLenum _dstBlend;
    
    BOOL _enableZRead;
    BOOL _enableZWrite;
    
    // GL stuff
    BOOL _glIsInitialized;
    
    GLuint _vao; // Vertex array object, capturing all the rendering vertex attribs
    GLuint _vbo; // Vertex buffer object, containing all the particle rendering data
    GLuint _ibo; // Index buffer object, contaning triangle indices
    
    GLuint _program; // A custom program, containing a vertex, a geometry and a fragment shaders
    
    // Uniform locations
    GLuint _mvLoc;
    GLuint _projLoc;
    GLuint _trailFactorLoc;
    GLuint _texLoc;
    GLuint _rampLoc;
    GLuint _textureName;
    GLuint _colorRampName;
}

@property (nonatomic, retain) SCNNode *emitter;
@property (nonatomic, retain) NSOpenGLContext *openGLContext;

- (id)initWithMaxCount:(NSInteger)maxCount emitter:(SCNNode *)node context:(NSOpenGLContext *)context;

- (void)initGL;
- (void)update;
- (void)prepareVBO;
- (void)sortWithViewDirection:(GLKVector3)viewDir;

- (void)initParticle:(ASCParticle *)particle;
- (void)updateParticle:(ASCParticle *)particle deltaTime:(float)deltaTime;

- (void)setupSmokeParticleSystem;
- (void)setupFireParticleSystem;

@end

#pragma mark - Slide

@interface ASCSlideNodeDelegate : ASCSlide
@end

@implementation ASCSlideNodeDelegate {
    ASCParticleSystem *_particleSystem;
    SCNNode *_swordNode;
    SCNNode *_swordEmitterNode;
    SCNNode *_smokeGroupNode;
    SCNNode *_heroGroupNode;
    SCNNode *_chimneyNode;
    CAAnimation *_attackAnimation;
    BOOL _stopAttackLoop;
}

- (NSUInteger)numberOfSteps {
    return 3;
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentationViewController {
    // Set the slide's title and subtitle and add some text
    self.textManager.title = @"Extending Scene Kit with OpenGL";
    self.textManager.subtitle = @"Node delegate rendering";
    [self.textManager addBullet:@"Custom OpenGL code per node" atLevel:0];
    [self.textManager addBullet:@"Overrides Scene Kit’s rendering" atLevel:0];
    [self.textManager addBullet:@"Transform and geometry information are provided by Scene Kit" atLevel:0];
    
    // Create the node hierarchy for the chimney (first illustration of a particle system)
    // smokeGroupNode
    // |__ chimneyNode (has the geometry)
    // |__ smokeEmitterNode (will be animated and the emitter for the particle system)
    
    _smokeGroupNode = [SCNNode node];
    _smokeGroupNode.position = SCNVector3Make(0, 0.01, 12);
    [self.groundNode addChildNode:_smokeGroupNode];
    
    _chimneyNode = [SCNNode node];
    _chimneyNode.rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
    _chimneyNode.scale = SCNVector3Make(0, 0, 0);
    _chimneyNode.geometry = [SCNPlane planeWithWidth:1.7 height:1.7];
    _chimneyNode.geometry.firstMaterial.diffuse.contents = [NSImage imageNamed:@"hole"];
    _chimneyNode.geometry.firstMaterial.diffuse.mipFilter = SCNFilterModeLinear;
    [_smokeGroupNode addChildNode:_chimneyNode];
    
    SCNNode *smokeEmitterNode = [SCNNode node];
    smokeEmitterNode.rotation = SCNVector4Make(0, 1, 0, 0);
    smokeEmitterNode.renderingOrder = 100; // make sure the particles are rendered last so that they cover the text
    [_smokeGroupNode addChildNode:smokeEmitterNode];
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    rotationAnimation.duration = 30.0;
    rotationAnimation.repeatCount = FLT_MAX;
    rotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    [smokeEmitterNode addAnimation:rotationAnimation forKey:nil];
    
    // Instantiate a particle system
    _particleSystem = [[ASCParticleSystem alloc] initWithMaxCount:500
                                                             emitter:smokeEmitterNode
                                                          context:presentationViewController.view.openGLContext];
    
    // Create the node hierarchy for the soldier (second illustration of a particle system)
    // heroGroupNode
    // |__ heroNode
    //     |__ swordNode
    //         |__ swordEmitterNode (the emitter for the particle system)
    //         |__ swordEmitterLightNode (make the particle system more realistic by adding a blue light)
    
    _heroGroupNode = [SCNNode node];
    _heroGroupNode.hidden = YES; // initially hidden
    _heroGroupNode.scale = SCNVector3Make(0.023, 0.023, 0.023);
    _heroGroupNode.position = SCNVector3Make(0, 0, 15);
    _heroGroupNode.rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
    [self.groundNode addChildNode:_heroGroupNode];
    
	SCNScene *scene = [SCNScene sceneNamed:@"hero.dae"];
    SCNNode *heroNode = scene.rootNode.clone;
    [_heroGroupNode addChildNode:heroNode];
    
    _swordNode = [heroNode childNodeWithName:@"Bip01_R_Sword" recursively:YES];
    
    _swordEmitterNode = [SCNNode node];
    [_swordNode addChildNode:_swordEmitterNode];
    
    SCNNode *swordEmitterLightNode = [SCNNode node];
    swordEmitterLightNode.position = SCNVector3Make(0, 0, 110);
    swordEmitterLightNode.light = [SCNLight light];
    swordEmitterLightNode.light.type = SCNLightTypeOmni;
    [swordEmitterLightNode.light setAttribute:@"8.0" forKey:SCNLightAttenuationEndKey];
    swordEmitterLightNode.light.color = [NSColor darkGrayColor];
    
    // Animate the blue light (flicker effect)
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"color.b"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fromValue = @3.0;
    animation.toValue = @2.0;
    animation.repeatCount = FLT_MAX;
    animation.duration = 0.15;
    [swordEmitterLightNode.light addAnimation:animation forKey:nil];
    
    [_swordNode addChildNode:swordEmitterLightNode];
    
    // Modifiy all the animations to make them system time based and repeat forever
    SCNNode *skeleton = [heroNode childNodeWithName:@"skeleton" recursively:YES];
    for (NSString *key in [skeleton animationKeys]) {
        CAAnimation *animation = [skeleton animationForKey:key];
        animation.usesSceneTimeBase = NO;
        animation.repeatCount = FLT_MAX;
        [skeleton addAnimation:animation forKey:key];
    }
    
    // Retrieve the "attackID" animation from the "attack" scene
    _attackAnimation = [self loadAnimationFromSceneNamed:@"attack" identifier:@"attackID"];
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    NSOpenGLContext *openGLContext = presentationViewController.view.openGLContext;
    [openGLContext makeCurrentContext];
    
    CGLLockContext([openGLContext CGLContextObj]);
    
    switch (index) {
        case 1:
            [_particleSystem setupSmokeParticleSystem];
            break;
        case 2:
        {
            // Change the particle system mode
            _smokeGroupNode.hidden = YES;
            _heroGroupNode.hidden = NO;
            _particleSystem.emitter = _swordEmitterNode;
            [_particleSystem setupFireParticleSystem];
            
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:2.0];
            {
                [presentationViewController updateLightingWithIntensities:@[@0.4, @0.4]];
            }
            [SCNTransaction commit];
            
            // Animate our character
            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                [self triggerAttackAnimation];
            });
            break;
        }
    }
    
    CGLUnlockContext([openGLContext CGLContextObj]);
}

- (void)didOrderInWithPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:0.5];
    [SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    {
        _chimneyNode.scale = SCNVector3Make(1, 1, 1);
    }
    [SCNTransaction commit];
}

- (void)willOrderOutWithPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    _stopAttackLoop = YES;
}

- (CAAnimation *)loadAnimationFromSceneNamed:(NSString *)path identifier:(NSString *)identifier {
    // Use SCNSceneSource to be able to retrieve animations by their identifier
	path = [[NSBundle mainBundle] pathForResource:path ofType:@"dae"];
	SCNSceneSource *sceneSource = [SCNSceneSource sceneSourceWithURL:[NSURL fileURLWithPath:path] options:nil];
    
    // Use animation blending for smoother transitions
	CAAnimation *animation = [sceneSource entryWithIdentifier:identifier withClass:[CAAnimation class]];
    animation.speed = 0.75;
    animation.fadeInDuration = 0.3;
    animation.fadeOutDuration = 0.3;
    
    return animation;
}

- (void)triggerAttackAnimation {
    [_heroGroupNode addAnimation:_attackAnimation forKey:@"attack"];
    
    if (_stopAttackLoop == NO) {
        double delayInSeconds = 3.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [self triggerAttackAnimation];
        });
    }
}

@end

#pragma mark - ASCParticleSystem implementation

@implementation ASCParticleSystem

// Init a ASCParticle system with a maximum number of particles and a GL context
- (id)initWithMaxCount:(NSInteger)maxCount emitter:(SCNNode *)emitter context:(NSOpenGLContext *)openGLContext {
    if (self = [super init]) {
        self.openGLContext = openGLContext;
        
        _particlesMaxCount = maxCount;
        _particles = calloc(sizeof(ASCParticle), maxCount);
        _birthRateRemainder = 0;
        
        _liveASCParticles = malloc(sizeof(int) * maxCount);
        _liveASCParticlesCount = 0;
        
        _initialLocationBoundsOrigin = GLKVector3Make(0, 0, 0);
        _initialLocationBoundsSize = GLKVector3Make(0.1, 0.0, 0.1);
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
        
        self.emitter = emitter;
    }
    return self;
}

- (void)setEmitter:(SCNNode *)emitter {
    _emitter.rendererDelegate = nil;
    _emitter = emitter;
    _emitter.rendererDelegate = self;
}

- (void)initGL {
    // Create and bind a VAO
    glGenVertexArraysAPPLE(1, &_vao);
    glBindVertexArrayAPPLE(_vao);
    
    // Create and bind a VBO
    glGenBuffers(1, &_vbo);
    glBindBuffer(GL_ARRAY_BUFFER, _vbo);
    
    // Initialize max size
    glBufferData(GL_ARRAY_BUFFER, sizeof(ASCVertex) * _particlesMaxCount, 0, GL_STREAM_DRAW);
    
    // Enable needed vertex attribs
    glVertexAttribPointer(ASC_QUAD_ATTRIB_POSITION, 4, GL_FLOAT, GL_FALSE, sizeof(ASCVertex), (void *)offsetof(ASCVertex, position));
    glEnableVertexAttribArray(ASC_QUAD_ATTRIB_POSITION);
    glVertexAttribPointer(ASC_QUAD_ATTRIB_VELOCITY, 3, GL_FLOAT, GL_FALSE, sizeof(ASCVertex), (void *)offsetof(ASCVertex, velocity));
    glEnableVertexAttribArray(ASC_QUAD_ATTRIB_VELOCITY);
    glVertexAttribPointer(ASC_QUAD_ATTRIB_ANGLE_LIFE, 2, GL_FLOAT, GL_FALSE, sizeof(ASCVertex), (void *)offsetof(ASCVertex, angleAndLife));
    glEnableVertexAttribArray(ASC_QUAD_ATTRIB_ANGLE_LIFE);
    
    // Create an IBO and capture it in the VAO
    glGenBuffers(1, &_ibo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _ibo);
    
    // Fill triangle indices with the same vertex
    size_t indicesSize = _particlesMaxCount * 3 * sizeof(GLint);
    GLint *indices = malloc(indicesSize);
    for (int i = 0; i < _particlesMaxCount; ++i) {
        indices[i * 3 + 0] = i;
        indices[i * 3 + 1] = i;
        indices[i * 3 + 2] = i;
    }
    
    // upload the indices to the IBO
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indicesSize, indices, GL_STATIC_DRAW);
    free(indices);
    
    // unbind the VAO
    glBindVertexArrayAPPLE(0);
    
    // associate vertex attribute index with glsl attribute names
    ASCAttribLocation attrib[] = {
        {ASC_QUAD_ATTRIB_POSITION, "a_position"},
        {ASC_QUAD_ATTRIB_VELOCITY, "a_velocity"},
        {ASC_QUAD_ATTRIB_ANGLE_LIFE, "a_positionAndLife"},
        {0, 0} // NULL terminated array
    };
    
    // Create the program
    _program = ASCCreateProgramWithNameAndAttributeLocations(@"ParticleSystem", attrib);
    
    // and retieve the location of needed uniforms
    _mvLoc = glGetUniformLocation ( _program, "u_mv" );
    _projLoc = glGetUniformLocation ( _program, "u_p" );
    _trailFactorLoc = glGetUniformLocation ( _program, "u_trailFactor" );
    _texLoc = glGetUniformLocation ( _program, "u_tex" );
    _rampLoc = glGetUniformLocation ( _program, "u_ramp" );
    
    _glIsInitialized = YES;
}

- (void)dealloc {
    self.emitter.rendererDelegate = nil;
    
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

- (void)setupSmokeParticleSystem {
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

- (void)setupFireParticleSystem {
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
- (void)initParticle:(ASCParticle *)particle {
    particle->life = sample(_lifespan, _lifespan * _lifespanVariation);
    particle->invLifespan = 1.f / particle->life;
    particle->invMass = 1.f;
    
    particle->position.x = floatRand() * _initialLocationBoundsSize.x + _initialLocationBoundsOrigin.x;
    particle->position.y = floatRand() * _initialLocationBoundsSize.y + _initialLocationBoundsOrigin.y;
    particle->position.z = floatRand() * _initialLocationBoundsSize.z + _initialLocationBoundsOrigin.z;
    particle->position.w = sample(_initialSize, _initialSizeVariation);
    
    particle->velocity.x = sample(_initialVelocity.x, _initialVelocityVariation.x);
    particle->velocity.y = sample(_initialVelocity.y, _initialVelocityVariation.y);
    particle->velocity.z = sample(_initialVelocity.z, _initialVelocityVariation.z);
    particle->velocity.w = (sample(_terminalSize, _terminalSizeVariation) - particle->position.w) / particle->life;
    
    particle->angle = floatRand() * M_PI;
    particle->angleVelocity = sample(_angularVelocity, _angularVelocityVariation);
}

// Update a particle
- (void)updateParticle:(ASCParticle *)particle deltaTime:(float)dt {
    // gravity
    GLKVector3 gravity = GLKVector3MultiplyScalar(_gravity, dt);
    particle->velocity.x += gravity.x;
    particle->velocity.y += gravity.y;
    particle->velocity.z += gravity.z;
    
    // dampening
    float dtonmass = dt * particle->invMass;
    float dampdt = _dampening * dtonmass;
    particle->velocity.x -= dampdt * particle->velocity.x;
    particle->velocity.y -= dampdt * particle->velocity.y;
    particle->velocity.z -= dampdt * particle->velocity.z;
    
    particle->position.x += particle->velocity.x * dt;
    particle->position.y += particle->velocity.y * dt;
    particle->position.z += particle->velocity.z * dt;
    particle->position.w += particle->velocity.w * dt;
    particle->angle += particle->angleVelocity * dt;
    
    // bounding box
    if (particle->position.x < _bboxMin.x)
        _bboxMin.x = particle->position.x;
    if (particle->position.y < _bboxMin.y)
        _bboxMin.y = particle->position.y;
    if (particle->position.z < _bboxMin.z)
        _bboxMin.z = particle->position.z;
    
    if (particle->position.x > _bboxMax.x)
        _bboxMax.x = particle->position.x;
    if (particle->position.y > _bboxMax.y)
        _bboxMax.y = particle->position.y;
    if (particle->position.z > _bboxMax.z)
        _bboxMax.z = particle->position.z;
}

// Update the particle system
- (void)update {
    // Compute delta time
    CFTimeInterval currentTime = CFAbsoluteTimeGetCurrent();
    float deltaTime = currentTime - _lastUpdateTime;
    _lastUpdateTime = currentTime;
    
    // Compute emission count
    float decimalEmissionCount = deltaTime * _birthRate;
    decimalEmissionCount = sample(decimalEmissionCount, decimalEmissionCount * _birthRateVariation);
    decimalEmissionCount += _birthRateRemainder;
    float emissionCount = truncf(decimalEmissionCount);
    _birthRateRemainder = decimalEmissionCount - emissionCount;
    
    // Update existing particles and generate new ones
    _bboxMin = GLKVector3Make(FLT_MAX, FLT_MAX, FLT_MAX);
    _bboxMax = GLKVector3Make(FLT_MIN, FLT_MIN, FLT_MIN);
    GLsizei liveCount = 0;
    for (int i = 0; i < _particlesMaxCount; ++i) {
        ASCParticle *particle = &_particles[i];
        
        // particle is still alive
        if (particle->life > deltaTime) {
            particle->life -= deltaTime;
            [self updateParticle:particle deltaTime:deltaTime];
            _liveASCParticles[liveCount++] = i;
            
        }
        
        // particle is dead
        else {
            // create a new one if needed
            if (emissionCount > 0.f) {
                emissionCount -= 1.f;
                [self initParticle:particle];
                _liveASCParticles[liveCount++] = i;
            } else {
                if (particle->life != 0.f)
                    particle->life = 0.f; // ensure dead particle have 0 lifespan
            }
        }
    }
    
    _liveASCParticlesCount = liveCount;
    
    // Update the SCNNode bounding box
    SCNVector3 bmin = SCNVector3FromGLKVector3(_bboxMin);
    SCNVector3 bmax = SCNVector3FromGLKVector3(_bboxMax);
    [_emitter setBoundingBoxMin:&bmin max:&bmax];
}

// Sort the live particles along the view direction
- (void)sortWithViewDirection:(GLKVector3)viewDirection {
    qsort_b(_liveASCParticles, _liveASCParticlesCount, sizeof(int), ^int(const void *a, const void *b) {
        ASCParticle *particleA = _particles + *(int *)a;
        ASCParticle *particleB = _particles + *(int *)b;
        float aDot = GLKVector3DotProduct(viewDirection, *(GLKVector3 *)&particleA->position);
        float bDot = GLKVector3DotProduct(viewDirection, *(GLKVector3 *)&particleB->position);
        return (aDot < bDot) ? -1 : 1;
    });
}

// Invoked when updating the VBO
- (void)prepareVBO {
    // Update VBO
    glBindBuffer(GL_ARRAY_BUFFER, _vbo);
   
    // Buffer orphaning
    glBufferData(GL_ARRAY_BUFFER, sizeof(ASCVertex) * _particlesMaxCount, NULL, GL_STREAM_DRAW);
    
    // Map the VBO to CPU memory
    ASCVertex *vboVertices = (ASCVertex *)glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
    if (vboVertices) {
        for (int i = 0; i < _liveASCParticlesCount; ++i) {
            ASCParticle *particle = &_particles[_liveASCParticles[i]];
            
            vboVertices[i].position = particle->position;
            vboVertices[i].velocity = *(GLKVector3 *)&particle->velocity;
            vboVertices[i].angleAndLife.x = particle->angle;
            vboVertices[i].angleAndLife.y = 1.f - particle->life * particle->invLifespan;
        }
        
        // Unmap the buffer
        glUnmapBuffer(GL_ARRAY_BUFFER);
    }
    
    // Unbind the VBO, to avoid someone else messing with it
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

// Invoked by Scene Kit when "node" has to be rendered
- (void)renderNode:(SCNNode *)node renderer:(SCNRenderer *)renderer arguments:(NSDictionary *)arguments {
    // Update the particle system. Ideally this should be done outside of the node rendering because -update modifies the bounding box.
    // - (void)renderer:(id <SCNSceneRenderer>)aRenderer willRenderScene:(SCNScene *)scene atTime:(NSTimeInterval)time would be a good place to do that.
    [self update];
    
    if (_liveASCParticlesCount == 0)
        return;
    
    if (!_glIsInitialized)
        [self initGL];
    
    // Sort the particles, from front to back
    GLKVector3 localViewDirection = SCNVector3ToGLKVector3([node convertPosition:SCNVector3Make(0, 0, 0) fromNode:renderer.pointOfView]);
    [self sortWithViewDirection:GLKVector3Normalize(localViewDirection)];
    
    // Upload particle vertices
    [self prepareVBO];
    
    // Disable depth buffer reading if needed
    if (!_enableZRead)
        glDisable(GL_DEPTH_TEST);
    
    // Disable depth buffer writing if needed
    if (!_enableZWrite)
        glDepthMask(false);
    
    // Enable alpha test (discard fragment with null alpha)
    glEnable( GL_ALPHA_TEST);
    glAlphaFunc(GL_GREATER, 0.0f);
    
    // Enable blending
    glEnable(GL_BLEND);
	glBlendFunc(_srcBlend, _dstBlend);
    
    // Bind the VAO
    glBindVertexArrayAPPLE(_vao);

    // Bind the program
    glUseProgram(_program);
   
    // Model-view uniform
    GLKMatrix4 mvMatrix = GLKMatrix4FromCATransform3D([arguments[SCNModelViewTransform] CATransform3DValue]);
    glUniformMatrix4fv(_mvLoc, 1, NO, mvMatrix.m);
    
    // Projection uniform
    GLKMatrix4 projMatrix = GLKMatrix4FromCATransform3D([arguments[SCNProjectionTransform] CATransform3DValue]);
    glUniformMatrix4fv(_projLoc, 1, NO, projMatrix.m);
    
    // Trail factor uniform (length of stretched particles)
    glUniform1f(_trailFactorLoc, _trailFactor);
    
    // Bind samplers
    ASCBindSampler(0, _texLoc, _textureName, GL_TEXTURE_2D);
    ASCBindSampler(1, _rampLoc, _colorRampName, GL_TEXTURE_2D);
    
    // Draw the particles
    glDrawElements(GL_TRIANGLES, _liveASCParticlesCount * 3, GL_UNSIGNED_INT, 0);
    
    // Restore the default VAO
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
