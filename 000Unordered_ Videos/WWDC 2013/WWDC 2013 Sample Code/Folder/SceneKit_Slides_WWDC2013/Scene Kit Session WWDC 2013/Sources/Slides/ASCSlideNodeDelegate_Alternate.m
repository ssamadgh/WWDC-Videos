
#import "ASCPresentation.h"
#import "ASCTextManager.h"
#import "ASCSlide.h"
#import "Utils.h"
#import "GLUtils.h"

#define FlareWidth 	3.8
#define FlareHeight 3.8
#define kFlareVerticesCount 16
#define kFlareIndicesCount 18*3

enum {
	QUAD_ATTRIB_POS,
	QUAD_ATTRIB_UV
};


GLuint _flareVAO;
GLuint _flareVBO;
GLuint _flareIBO;
GLuint _flareProgram;
GLuint _mvpLoc;


GLuint _timeLoc;
GLuint _factorLoc;
GLuint _resolutionLoc;
CFAbsoluteTime _startTime;
CGFloat _factor;
CGFloat _targetFactor;


@interface MyRendererDelegate : NSObject <SCNNodeRendererDelegate>
@property BOOL showWireframe;
@end


static MyRendererDelegate *rendererDelegate;

typedef struct VertexUV
{
    GLfloat position[3];
    GLfloat uv0[2]; // we insert the vertex index in the z coord
} VertexUV;


@implementation ASCSlideNodeDelegate
{
}

- (void)createFlareGeometry:(ASCPresentation *)controller
{
    NSOpenGLContext *ctx = [controller.view openGLContext];
    [ctx makeCurrentContext];
    
	glGenVertexArraysAPPLE(1, &_flareVAO);
	glBindVertexArrayAPPLE(_flareVAO);
	
	glGenBuffers(1, &_flareVBO);
	glBindBuffer(GL_ARRAY_BUFFER, _flareVBO);
	
	VertexUV vertices[kFlareVerticesCount] = {
		{{-1.f, 1.f, 0.f}, {0.f, 1.f}}, // TL
		{{ 1.f, 1.f, 0.f}, {1.f, 1.f}}, // TR
		{{ 1.f,-1.f, 0.f}, {1.f, 0.f}}, // BR
		{{-1.f,-1.f, 0.f}, {0.f, 0.f}} // BL
	};
	
	glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STREAM_DRAW);
	
	glVertexAttribPointer(QUAD_ATTRIB_POS, 3, GL_FLOAT, GL_FALSE, sizeof(VertexUV), (void*)offsetof(VertexUV,position));
	glEnableVertexAttribArray(QUAD_ATTRIB_POS);
	glVertexAttribPointer(QUAD_ATTRIB_UV, 2, GL_FLOAT, GL_TRUE, sizeof(VertexUV), (void*)offsetof(VertexUV,uv0));
	glEnableVertexAttribArray(QUAD_ATTRIB_UV);
	
    // create an IBO and capture it in the VAO
    glGenBuffers(1, &_flareIBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _flareIBO);
    
    GLchar indices[kFlareIndicesCount] = {
        0,4,5,  0,5,6, 0,6,7, 0,7,1, 1,7,8, 1,8,9,
		15,4,0, 15,0,3, 3,0,1, 3,1,2, 2,1,9, 2,9,10,
		14,15,3, 14,3,13, 13,3,2, 13,2,12, 12,2,11, 11,2,10
    };
    
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

	glBindVertexArrayAPPLE(0);

	AttribLocation attrib[] = {
		{QUAD_ATTRIB_POS, "a_pos"},
		{QUAD_ATTRIB_UV, "a_uv"},
		{0, 0}
	};
	
	_flareProgram = CreateProgramWithAttributesLocation(@"NodeDelegate", attrib);
    _mvpLoc = glGetUniformLocation ( _flareProgram, "u_mvp" );
    
}

- (NSUInteger) numberOfSteps
{
    return 3;
}

- (SCNNode *) createCubeWithFlareWithWidth:(CGFloat)width height:(CGFloat)height length:(CGFloat)length outerMaterial:(SCNMaterial*)outerMaterial
{
    SCNNode *object = [SCNNode node];
    object.geometry = [SCNBox boxWithWidth:width height:height length:length chamferRadius:0.05];
    SCNMaterial *whiteMaterial = [SCNMaterial material];
    whiteMaterial.emission.contents = [NSColor whiteColor];
    
    object.geometry.materials = @[whiteMaterial, outerMaterial, outerMaterial, outerMaterial, outerMaterial, outerMaterial];
    [self.ground addChildNode:object];
    
    
    if(rendererDelegate == nil){
        rendererDelegate = [[MyRendererDelegate alloc] init];
    }
    
    SCNNode *flare = [SCNNode node];
    flare.position = SCNVector3Make(0, 0, length * 0.5 + 0.01);
    flare.geometry = [SCNPlane planeWithWidth:width height:height];
    flare.rendererDelegate = rendererDelegate;
    flare.renderingOrder = 1;
    [object addChildNode:flare];

    return object;
}

- (void) setup:(ASCPresentation *)controller
{
    ASCTextManager *text = [self setupTextManager:NO];
    [text addText:@"Extending Scene Kit with OpenGL" withType:ASCTextTypeTitle level:0];
    [text addText:@"Node delegate rendering" withType:ASCTextTypeSubTitle level:0];
    [text addText:@"Custom OpenGL code per node" withType:ASCTextTypeBullet level:0];
    [text addText:@"Overrides Scene Kit’s rendering" withType:ASCTextTypeBullet level:0];
    [text addText:@"Transform and geometry information are provided by Scene Kit" withType:ASCTextTypeBullet level:0];


    SCNMaterial *redMaterial = [SCNMaterial material];
    redMaterial.diffuse.contents = [NSColor redColor];
    redMaterial.specular.contents = [NSColor whiteColor];
    redMaterial.locksAmbientWithDiffuse = YES;

    SCNNode *object = [self createCubeWithFlareWithWidth:4 height:4 length:4 outerMaterial:redMaterial];
    object.position = SCNVector3Make(0, 2, 8);
    [self.ground addChildNode:object];
    
    [self createFlareGeometry:controller];
    
    //animate
    {
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
        rotationAnimation.duration = 10.0;
        rotationAnimation.repeatCount = MAXFLOAT;
        rotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI*2)];
        [object addAnimation:rotationAnimation forKey:nil];
    }
    
    SCNNode *axis = [SCNNode node];
    [object addChildNode:axis];
    axis.position = SCNVector3Make(0, 2, 0);
    axis.name = @"axis";

    {
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
        rotationAnimation.duration = 3.0;
        rotationAnimation.repeatCount = MAXFLOAT;
        rotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, -M_PI*2)];
        [axis addAnimation:rotationAnimation forKey:nil];
    }
}

- (void) presentStepIndex:(NSUInteger)index withController:(ASCPresentation *)controller
{
    switch (index) {
        case 0:
            break;
        case 1:
            rendererDelegate.showWireframe = YES;
            break;
        case 2:
            rendererDelegate.showWireframe = NO;
            [self.textManager flipOutTextType:ASCTextTypeBullet];
            
            SCNMaterial *redMaterial = [SCNMaterial material];
            redMaterial.diffuse.contents = [NSColor colorWithCalibratedRed:0.4 green:0.01 blue:0.01 alpha:1.0];
            redMaterial.specular.contents = [NSColor whiteColor];
            redMaterial.locksAmbientWithDiffuse = YES;

            SCNNode *axis = [self.ground childNodeWithName:@"axis" recursively:YES];
            for (int i = 0; i < 4; ++i) {

                SCNNode *cube = [self createCubeWithFlareWithWidth:0.5 height:FlareHeight length:0.5 outerMaterial:redMaterial];
                [cube setPosition:SCNVector3Make(sin(M_PI_2*i), FlareHeight/2, cos(M_PI_2*i))];
                [cube setRotation:SCNVector4Make(0, 1, 0, M_PI_2 * i)];
                [axis addChildNode:cube];
                
            }
            
            break;
    }
}

//TODO: Move to Utilities
//NO, TODO: use GLKit

static inline SCNVector3 SCNVector3Add(SCNVector3 a, SCNVector3 b)
{
    return SCNVector3Make(a.x + b.x, a.y + b.y, a.z + b.z);
}

static inline SCNVector3 SCNVector3Sub(SCNVector3 a, SCNVector3 b)
{
    return SCNVector3Make(a.x - b.x, a.y - b.y, a.z - b.z);
}

static inline SCNVector3 SCNVector3Neg(SCNVector3 a)
{
    return SCNVector3Make(-a.x, -a.y, -a.z);
}

static inline SCNVector3 SCNVector3Mul(SCNVector3 a, CGFloat b)
{
    return SCNVector3Make(a.x * b, a.y * b, a.z * b);
}

static inline SCNVector3 SCNVector3Div(SCNVector3 a, CGFloat b)
{
    return SCNVector3Make(a.x / b, a.y / b, a.z / b);
}

static inline SCNVector3 SCNVector3Cross(SCNVector3 a, SCNVector3 b)
{
    return SCNVector3Make(a.y * b.z - b.y * a.z,
                          a.z * b.x - b.z * a.x,
                          a.x * b.y - b.x * a.y);
}

static inline CGFloat SCNVector3Dot(SCNVector3 a, SCNVector3 b)
{
    return a.x * b.x + a.y * b.y + a.z * b.z;
}

static inline CGFloat SCNVector3Length(SCNVector3 a)
{
    return sqrt(SCNVector3Dot(a, a));
}

static inline SCNVector3 SCNVector3Normalize(SCNVector3 a)
{
    CGFloat len = SCNVector3Length(a);
    return SCNVector3Make(a.x / len, a.y / len, a.z / len);
}

typedef struct {
    SCNVector3 normal;
    CGFloat D;
} SCNPlane3;

static inline SCNPlane3 SCNPlane3MakeFromPoints(SCNVector3 p0, SCNVector3 p1, SCNVector3 p2)
{
	SCNPlane3 plane;
    
    plane.normal.x = p0.y*(p1.z-p2.z) + p1.y*(p2.z-p0.z) + p2.y*(p0.z-p1.z);
    plane.normal.y = p0.z*(p1.x-p2.x) + p1.z*(p2.x-p0.x) + p2.z*(p0.x-p1.x);
    plane.normal.z = p0.x*(p1.y-p2.y) + p1.x*(p2.y-p0.y) + p2.x*(p0.y-p1.y);
    
    plane.D = -( p0.x*( p1.y*p2.z - p2.y*p1.z ) +
			   p1.x*(p2.y*p0.z - p0.y*p2.z) +
			   p2.x*(p0.y*p1.z - p1.y*p0.z) );
    
    CGFloat l = SCNVector3Length(plane.normal);
    
    if(l==0){ // fail
        return plane;
    }
    
    plane.normal = SCNVector3Div(plane.normal, l);
    plane.D /= l;
    return plane;
}

@end


typedef struct
{
    SCNVector3 position;
    CGPoint uv0;
} SCNVertexPosUV;



@implementation MyRendererDelegate

- (void)renderNode:(SCNNode *)node renderer:(SCNRenderer *)renderer arguments:(NSDictionary *)arguments
{
    glDisable(GL_CULL_FACE);
    glDisable(GL_DEPTH_TEST);
    glDepthMask(false);
    glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    SCNVector3 bmin, bmax;
    [node getBoundingBoxMin:&bmin max:&bmax];
    
    CGFloat width = (bmax.x - bmin.x) * 0.5;
    CGFloat height = (bmax.y - bmin.y) * 0.5;
    
    SCNVector3 planePts[4];
    planePts[0] = [[node presentationNode] convertPosition:SCNVector3Make(-width,  height, 0) toNode:renderer.pointOfView];
    planePts[1] = [[node presentationNode] convertPosition:SCNVector3Make( width,  height, 0) toNode:renderer.pointOfView];
    planePts[2] = [[node presentationNode] convertPosition:SCNVector3Make( width, -height, 0) toNode:renderer.pointOfView];
    planePts[3] = [[node presentationNode] convertPosition:SCNVector3Make(-width, -height, 0) toNode:renderer.pointOfView];
    
    SCNVector3 viewPos = SCNVector3Make(0, 0, 0);
    
    SCNPlane3 plane = SCNPlane3MakeFromPoints(planePts[0], planePts[2], planePts[1]);
	CGFloat distFromPlane = SCNVector3Dot(plane.normal, viewPos) + plane.D;
	if ( distFromPlane <= 0 ) { // flare is not visible
		return;
	}
    
    SCNVector3 dir = SCNVector3Normalize(planePts[0]);
    CGFloat frontAngle = MIN(- 8.0 * SCNVector3Dot(plane.normal, dir), 1.0);
    
    SCNVertexPosUV vert[kFlareVerticesCount];
    SCNVector3 edgeDir[4][3];
    
	// calculate vector directions
	for ( int i = 0 ; i < 4 ; i++ ) {
		vert[i].position = planePts[ i ];
		vert[i].uv0.x = vert[i].uv0.y = 0.5 * frontAngle;
        
		SCNVector3	toEye = SCNVector3Sub(planePts[ i ], viewPos);
		toEye = SCNVector3Normalize(toEye);
        
		SCNVector3	d1 = SCNVector3Sub(planePts[ (i+1)%4 ], viewPos);
		d1 = SCNVector3Normalize(d1);
        edgeDir[i][1] = SCNVector3Cross(toEye, d1);
        edgeDir[i][1] = SCNVector3Neg(SCNVector3Normalize(edgeDir[i][1]));

		SCNVector3	d2 = SCNVector3Sub(planePts[ (i+3)%4 ], viewPos);
		d2 = SCNVector3Normalize(d2);
        edgeDir[i][0] = SCNVector3Cross(toEye, d2);
        edgeDir[i][0] = SCNVector3Normalize(edgeDir[i][0]);
        
        edgeDir[i][2] = SCNVector3Add(edgeDir[i][0], edgeDir[i][1]);
        edgeDir[i][2] = SCNVector3Normalize(edgeDir[i][2]);
	}
    
    
    CGFloat spread = (width + height) / 2;
//    static float accum = 0.0;
//    accum += 0.01;
//    spread += (spread * 0.15) * sin(7.0*cos(9.0*accum));
    
	// build all the points
	vert[ 4].position = SCNVector3Add(planePts[0], SCNVector3Mul(edgeDir[0][0], spread));
	vert[ 5].position = SCNVector3Add(planePts[0], SCNVector3Mul(edgeDir[0][2], spread));
	vert[ 6].position = SCNVector3Add(planePts[0], SCNVector3Mul(edgeDir[0][1], spread));
	vert[ 7].position = SCNVector3Add(planePts[1], SCNVector3Mul(edgeDir[1][0], spread));
	vert[ 8].position = SCNVector3Add(planePts[1], SCNVector3Mul(edgeDir[1][2], spread));
	vert[ 9].position = SCNVector3Add(planePts[1], SCNVector3Mul(edgeDir[1][1], spread));
	vert[10].position = SCNVector3Add(planePts[2], SCNVector3Mul(edgeDir[2][0], spread));
	vert[11].position = SCNVector3Add(planePts[2], SCNVector3Mul(edgeDir[2][2], spread));
	vert[12].position = SCNVector3Add(planePts[2], SCNVector3Mul(edgeDir[2][1], spread));
	vert[13].position = SCNVector3Add(planePts[3], SCNVector3Mul(edgeDir[3][0], spread));
	vert[14].position = SCNVector3Add(planePts[3], SCNVector3Mul(edgeDir[3][2], spread));
	vert[15].position = SCNVector3Add(planePts[3], SCNVector3Mul(edgeDir[3][1], spread));
    
	for ( int i = 4 ; i < kFlareVerticesCount ; i++ ) {
		SCNVector3	dir = SCNVector3Sub(vert[i].position, viewPos);
		float len = SCNVector3Length(dir);
        dir = SCNVector3Div(dir, len);
        
		float ang = SCNVector3Dot(dir, plane.normal);
		float newLen = -( distFromPlane / ang );
        
		if ( newLen > 0 && newLen < len ) {
            vert[i].position = SCNVector3Add(viewPos, SCNVector3Mul(dir, newLen));
        }
        
		vert[i].uv0.x = 0.0;
		vert[i].uv0.y = 0.0;
	}

    glBindBuffer(GL_ARRAY_BUFFER, _flareVBO);
    VertexUV* vboVertices = (VertexUV*)glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);

    for (int i = 0; i < kFlareVerticesCount; ++i) {
        vboVertices[i].position[0] = vert[i].position.x;
        vboVertices[i].position[1] = vert[i].position.y;
        vboVertices[i].position[2] = vert[i].position.z;
        vboVertices[i].uv0[0] = vert[i].uv0.x;
        vboVertices[i].uv0[1] = vert[i].uv0.y;
    }
    
    //    memcpy(vboVertices, vertices, sizeof(vertices[0]) * kFlareVerticesCount);
    glUnmapBuffer(GL_ARRAY_BUFFER);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    glBindVertexArrayAPPLE(_flareVAO);
    glUseProgram(_flareProgram);
    
    NSValue * mvpVal = [arguments objectForKey:SCNProjectionTransform];
    CATransform3D mvpTrans = [mvpVal CATransform3DValue];
    GLKMatrix4 mvp = GLKMatrix4FromCATransform3D(mvpTrans);
    
    glUniformMatrix4fv(_mvpLoc, 1, NO, mvp.m);
    
    // Debug Wireframe
    if (self.showWireframe) {
        glPolygonMode(GL_FRONT, GL_LINE);
        glPolygonMode(GL_BACK, GL_LINE);
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        glDrawElements(GL_TRIANGLES, kFlareIndicesCount, GL_UNSIGNED_BYTE, 0);
        
        glPolygonMode(GL_FRONT, GL_FILL);
        glPolygonMode(GL_BACK, GL_FILL);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    }
    glDrawElements(GL_TRIANGLES, kFlareIndicesCount, GL_UNSIGNED_BYTE, 0);

    glBindVertexArrayAPPLE(0);

    glDisable(GL_BLEND);
    glEnable(GL_DEPTH_TEST);
    glDepthMask(true);
    glEnable(GL_CULL_FACE);
}

@end
