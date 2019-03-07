/*
     File: ASCSlideDelegateRendering.m
 Abstract:  Delegate rendering slide. This sample code is not about OpenGL. Please read OpenGL sample for more details about OpenGL
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

// GL attribute locations
enum {
	ASC_QUAD_ATTRIB_POS,
	ASC_QUAD_ATTRIB_UV
};

//structure to represent a vertex
typedef struct {
    GLfloat position[4];
    GLfloat uv0[3]; // we insert the vertex index in the z coord
} ASCVertexUV;

@interface ASCSlideDelegateRendering : ASCSlide <SCNSceneRendererDelegate>
@end

@implementation ASCSlideDelegateRendering {
    //GL's vao and vbo index
    GLuint _quadVAO;
    GLuint _quadVBO;
    
    //GL's program
    GLuint _program;
    
    //GL's uniform locations
    GLuint _timeLoc;
    GLuint _factorLoc;
    GLuint _resolutionLoc;
    CFAbsoluteTime _startTime;
    CGFloat _factor;
    CGFloat _targetFactor;
    
    CGSize _viewport;
}

//this slide uses 3 steps
- (NSUInteger)numberOfSteps {
    return 3;
}

//create a VBO ta renders a quad
- (void)createQuadGeometryInContext:(NSOpenGLContext *)ctx {
    [ctx makeCurrentContext];
    
	glGenVertexArraysAPPLE(1, &_quadVAO);
	glBindVertexArrayAPPLE(_quadVAO);
	
	glGenBuffers(1, &_quadVBO);
	glBindBuffer(GL_ARRAY_BUFFER, _quadVBO);
	
	ASCVertexUV vertices[6] = {
		{{-1.f, 1.f, 0.f, 1.f}, {0.f, 1.f, 0.f}}, // TL
		{{ 1.f, 1.f, 0.f, 1.f}, {1.f, 1.f, 1.f}}, // TR
		{{-1.f,-1.f, 0.f, 1.f}, {0.f, 0.f, 2.f}}, // BL
		{{-1.f,-1.f, 0.f, 1.f}, {0.f, 0.f, 2.f}}, // BL
		{{ 1.f, 1.f, 0.f, 1.f}, {1.f, 1.f, 1.f}}, // TR
		{{ 1.f,-1.f, 0.f, 1.f}, {1.f, 0.f, 3.f}}, // BR
	};
	
	glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
	
	glVertexAttribPointer(ASC_QUAD_ATTRIB_POS, 4, GL_FLOAT, GL_FALSE, sizeof(ASCVertexUV), (void*)offsetof(ASCVertexUV,position));
	glEnableVertexAttribArray(ASC_QUAD_ATTRIB_POS);
	glVertexAttribPointer(ASC_QUAD_ATTRIB_UV, 3, GL_FLOAT, GL_TRUE, sizeof(ASCVertexUV), (void*)offsetof(ASCVertexUV,uv0));
	glEnableVertexAttribArray(ASC_QUAD_ATTRIB_UV);
	
	glBindVertexArrayAPPLE(0);
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentation {
    //retrieve the text manager
    ASCSlideTextManager *textManager = [self textManager];
    
    //add some text
    [textManager setTitle:@"Extending Scene Kit with OpenGL"];
    [textManager setSubtitle:@"Scene delegate rendering"];
    [textManager addBullet:@"Custom GL code, free of constraints" atLevel:0];
    [textManager addBullet:@"Before and/or after scene rendering" atLevel:0];
    [textManager addBullet:@"Works with SCNView, SCNLayer and SCNRenderer" atLevel:0];
    
    //create a VBO to render a quad
    [self createQuadGeometryInContext:[presentation.view openGLContext]];
    
    //load our shader
    ASCAttribLocation attrib[] = {
		{ASC_QUAD_ATTRIB_POS, "position"},
		{ASC_QUAD_ATTRIB_UV, "texcoord0"},
		{0, 0}
	};

    _program = ASCCreateProgramWithAttributeLocations(@"SceneDelegate", attrib);
    
    //get uniforms
    _timeLoc = glGetUniformLocation(_program, "time");
    _factorLoc = glGetUniformLocation(_program, "factor");
    _resolutionLoc = glGetUniformLocation( _program, "resolution");
    
    //get start time
    _startTime = CFAbsoluteTimeGetCurrent();
    
    //
    NSRect frame = [presentation.view convertRectToBacking:presentation.view.frame];
    _viewport = CGSizeMake(frame.size.width, frame.size.height);
}

#pragma mark - delegate callback

/* 
 Invoked by Scene Kit before rendering the scene.
 When this is invoked, SceneKit already installed the viewport and cleared the background.
 */
- (void)renderer:(id <SCNSceneRenderer>)aRenderer willRenderScene:(SCNScene *)scene atTime:(NSTimeInterval)time {
    //disable what's SceneKit enable by default and reset the previous state below
    glDisable(GL_CULL_FACE);
    glDisable(GL_DEPTH_TEST);
    
    //draw our procedural background
    glBindVertexArrayAPPLE(_quadVAO);
    glUseProgram(_program);
    glUniform1f(_timeLoc, CFAbsoluteTimeGetCurrent() - _startTime);
    glUniform1f(_factorLoc, _factor);
    
    glUniform2f(_resolutionLoc, _viewport.width, _viewport.height);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    glBindVertexArrayAPPLE(0);
    
    //restore SceneKit default's states
    glEnable(GL_DEPTH_TEST);
    
    //animate our custom variable
    if (_factor < _targetFactor) {
        _factor+=0.05;
    }
    else if (_factor > _targetFactor) {
        _factor-=0.05;
    }
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)controller {
    switch (index) {
        case 0:
            break;
        case 1:
            //initial state
            _factor = 0; //current factor
            _targetFactor = 1; //wherewe want to go

            //set the delegateof the SCNView to self to activate the delegate rendering
            controller.view.delegate = self;
            
            //redraw forever
            controller.view.playing = YES;
            controller.view.loops = YES;
            break;
        case 2:
            _targetFactor = 0; //go to zero
            break;
    }
}

- (void)orderOutWithPresentionViewController:(ASCPresentationViewController *)controller {
    //before leaving this slide: stop redraw and remove the delegate of the view
    controller.view.delegate = nil;
    controller.view.playing = NO;
}

@end
