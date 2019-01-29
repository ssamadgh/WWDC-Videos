/*
     File: ASCSlideDelegateRendering.m
 Abstract: Explains what scene delegate rendering is and shows an example.
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

// OpenGL attribute locations
NS_ENUM(GLuint, ASCAttrib) {
	ASC_QUAD_ATTRIB_POS,
	ASC_QUAD_ATTRIB_UV
};

// A structure used to represent a vertex
typedef struct {
    GLfloat position[4]; // position
    GLfloat uv0[3];      // texture coordinates + vertex index (stored in the last component)
} ASCVertexUV;

@interface ASCSlideDelegateRendering : ASCSlide <SCNSceneRendererDelegate>
@end

@implementation ASCSlideDelegateRendering {
    // OpenGL-related ivars
    GLuint _quadVAO;
    GLuint _quadVBO;
    GLuint _program;
    GLuint _timeLocation;
    GLuint _factorLocation;
    GLuint _resolutionLocation;
    
    // Other ivars
    GLfloat _fadeFactor;
    GLfloat _fadeFactorDelta;
    CFAbsoluteTime _startTime;
    CGSize _viewport;
}

- (NSUInteger)numberOfSteps {
    return 3;
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentationViewController {
    // Set the slide's title and subtitle and add some text
    self.textManager.title = @"Extending Scene Kit with OpenGL";
    self.textManager.subtitle = @"Scene delegate rendering";
    
    [self.textManager addBullet:@"Custom GL code, free of constraints" atLevel:0];
    [self.textManager addBullet:@"Before and/or after scene rendering" atLevel:0];
    [self.textManager addBullet:@"Works with SCNView, SCNLayer and SCNRenderer" atLevel:0];
    
    // Create a VBO to render a quad
    [self createQuadGeometryInContext:presentationViewController.view.openGLContext];
    
    // Create the program and retrieve the uniform locations
    ASCAttribLocation attrib[] = {
		{ASC_QUAD_ATTRIB_POS, "position"},
		{ASC_QUAD_ATTRIB_UV, "texcoord0"},
		{0, 0}
	};
    
    _program = ASCCreateProgramWithNameAndAttributeLocations(@"SceneDelegate", attrib);

    _timeLocation = glGetUniformLocation(_program, "time");
    _factorLocation = glGetUniformLocation(_program, "factor");
    _resolutionLocation = glGetUniformLocation( _program, "resolution");
    
    // Initialize time and cache the viewport
    NSSize frameSize = [presentationViewController.view convertSizeToBacking:presentationViewController.view.frame.size];
    _viewport = NSSizeToCGSize(frameSize);
    _startTime = CFAbsoluteTimeGetCurrent();
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    switch (index) {
        case 1:
            _fadeFactor = 0; // tunnel is not visible
            _fadeFactorDelta = 0.05; // fade in
            
            // Set self as the scene renderer's delegate and make the view redraw for ever
            presentationViewController.view.delegate = self;
            presentationViewController.view.playing = YES;
            presentationViewController.view.loops = YES;
            break;
        case 2:
            _fadeFactorDelta *= -1; // fade out
            break;
    }
}

- (void)willOrderOutWithPresentionViewController:(ASCPresentationViewController *)presentationViewController {
    presentationViewController.view.delegate = nil;
    presentationViewController.view.playing = NO;
}

// Create a VBO used to render a quad
- (void)createQuadGeometryInContext:(NSOpenGLContext *)context {
    [context makeCurrentContext];
    
	glGenVertexArraysAPPLE(1, &_quadVAO);
	glBindVertexArrayAPPLE(_quadVAO);
    
	glGenBuffers(1, &_quadVBO);
	glBindBuffer(GL_ARRAY_BUFFER, _quadVBO);
	
	ASCVertexUV vertices[] = {
		{{-1.f, 1.f, 0.f, 1.f}, {0.f, 1.f, 0.f}}, // TL
		{{ 1.f, 1.f, 0.f, 1.f}, {1.f, 1.f, 1.f}}, // TR
		{{-1.f,-1.f, 0.f, 1.f}, {0.f, 0.f, 2.f}}, // BL
		{{-1.f,-1.f, 0.f, 1.f}, {0.f, 0.f, 2.f}}, // BL
		{{ 1.f, 1.f, 0.f, 1.f}, {1.f, 1.f, 1.f}}, // TR
		{{ 1.f,-1.f, 0.f, 1.f}, {1.f, 0.f, 3.f}}, // BR
	};
	
	glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
	
	glVertexAttribPointer(ASC_QUAD_ATTRIB_POS, 4, GL_FLOAT, GL_FALSE, sizeof(ASCVertexUV), (void *)offsetof(ASCVertexUV, position));
	glEnableVertexAttribArray(ASC_QUAD_ATTRIB_POS);
	glVertexAttribPointer(ASC_QUAD_ATTRIB_UV, 3, GL_FLOAT, GL_TRUE, sizeof(ASCVertexUV), (void *)offsetof(ASCVertexUV, uv0));
	glEnableVertexAttribArray(ASC_QUAD_ATTRIB_UV);
	
	glBindVertexArrayAPPLE(0);
}

// Invoked by Scene Kit before rendering the scene. When this is invoked, Scene Kit has already installed the viewport and cleared the background.
- (void)renderer:(id <SCNSceneRenderer>)aRenderer willRenderScene:(SCNScene *)scene atTime:(NSTimeInterval)time {
    // Disable what Scene Kit enables by default (and restore upon leaving)
    glDisable(GL_CULL_FACE);
    glDisable(GL_DEPTH_TEST);
    
    // Draw the procedural background
    glBindVertexArrayAPPLE(_quadVAO);
    glUseProgram(_program);
    glUniform1f(_timeLocation, CFAbsoluteTimeGetCurrent() - _startTime);
    glUniform1f(_factorLocation, _fadeFactor);
    glUniform2f(_resolutionLocation, _viewport.width, _viewport.height);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    glBindVertexArrayAPPLE(0);
    
    // Restore Scene Kit default states
    glEnable(GL_DEPTH_TEST);
    
    // Update the fade factor
    _fadeFactor = MAX(0, MIN(1, _fadeFactor + _fadeFactorDelta));
}

@end
