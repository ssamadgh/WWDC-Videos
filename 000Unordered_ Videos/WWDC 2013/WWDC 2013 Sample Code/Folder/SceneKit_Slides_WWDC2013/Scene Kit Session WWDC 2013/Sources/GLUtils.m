/*
     File: GLUtils.m
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

#import "GLUtils.h"

// Compile a GLSL shader
static bool ASCCompileShader(GLuint *shader, GLenum type, NSString *file) {
	const GLchar *source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
	if (!source) {
		NSLog(@"Failed to load vertex shader");
		return false;
	}
	
	*shader = glCreateShader(type);
	glShaderSource(*shader, 1, &source, NULL);
	glCompileShader(*shader);
    
    GLint status;
	glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
	if (status == 0) {
        GLsizei length = 0;
        GLcharARB logs[1000];
        logs[0] = '\0';
        glGetShaderInfoLog(*shader, 1000, &length, logs);
        NSLog(@"gl Compile Status: %s", logs);
		glDeleteShader(*shader);
		return false;
	}
	
	return true;
}

// Link a GLSL program
static BOOL ASCLinkProgram(GLuint program) {
	glLinkProgram(program);
    
	GLint status;
	glGetProgramiv(program, GL_LINK_STATUS, &status);
	if (status == 0) {
        GLsizei length = 0;
        GLcharARB logs[1000];
        logs[0] = '\0';
        glGetShaderInfoLog(program, 1000, &length, logs);
        NSLog(@"gl Link Status: %s", logs);
        
		return NO;
	}
	
	return YES;
}

GLuint ASCCreateProgramWithAttributeLocations(NSString *shaderName, ASCAttribLocation *attribLocations) {
	// Create and compile vertex shader.
	NSString *vertShaderPathName = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"vsh"];
	GLuint vertShader = 0;
    if (!ASCCompileShader(&vertShader, GL_VERTEX_SHADER, vertShaderPathName)) {
		NSLog(@"Failed to compile vertex shader");
		return NO;
	}
	
	// Create and compile fragment shader.
	NSString *fragShaderPathName = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"fsh"];
	GLuint fragShader = 0;
    if (!ASCCompileShader(&fragShader, GL_FRAGMENT_SHADER, fragShaderPathName)) {
		NSLog(@"Failed to compile fragment shader");
		return NO;
	}
    
    // Create and compile fragment shader.
    GLuint geomShader = 0;
	NSString *geomShaderPathName = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"gsh"];
	if (geomShaderPathName && !ASCCompileShader(&geomShader, GL_GEOMETRY_SHADER_EXT, geomShaderPathName)) {
		NSLog(@"Failed to compile geometry shader");
	}
    
	GLuint program = glCreateProgram();
	
	// Attach vertex shader to program.
	glAttachShader(program, vertShader);
	
	// Attach fragment shader to program.
	glAttachShader(program, fragShader);
	
    if (geomShader) {
        glAttachShader(program, geomShader);
    }
    
	// Bind attribute locations.
	// This needs to be done prior to linking.
	int i = 0;
	while (true) {
		if (attribLocations[i].name == NULL)
			break; // last attrib
		
		glBindAttribLocation(program, attribLocations[i].index, attribLocations[i].name);
		++i;
	}
    
	if (geomShader) {
        // configure the geometry shader
        glProgramParameteriEXT(program, GL_GEOMETRY_INPUT_TYPE_EXT, GL_TRIANGLES);
        glProgramParameteriEXT(program, GL_GEOMETRY_OUTPUT_TYPE_EXT, GL_TRIANGLE_STRIP);
        glProgramParameteriEXT(program, GL_GEOMETRY_VERTICES_OUT_EXT, 4);
    }
    
	// Link program.
	if (!ASCLinkProgram(program)) {
		NSLog(@"Failed to link program: %d", program);
		
		if (vertShader) {
			glDeleteShader(vertShader);
			vertShader = 0;
		}
        
		if (fragShader) {
			glDeleteShader(fragShader);
			fragShader = 0;
		}
		
        if (geomShader) {
			glDeleteShader(geomShader);
			geomShader = 0;
		}
		
        if (program) {
			glDeleteProgram(program);
			program = 0;
		}
		
		return 0;
	}
	
	// Release vertex, fragment and geometry shaders.
	if (vertShader) {
		glDetachShader(program, vertShader);
		glDeleteShader(vertShader);
	}
    
	if (fragShader) {
		glDetachShader(program, fragShader);
		glDeleteShader(fragShader);
	}

	if (geomShader) {
		glDetachShader(program, geomShader);
		glDeleteShader(geomShader);
	}
	
	return program;
}

int ASCBindSampler(int stage, GLint location, GLuint texture, GLenum target) {
	if (location != -1) {
		glActiveTexture(GL_TEXTURE0 + stage);
        glEnable(target);
		glBindTexture(target, texture);
		glUniform1i(location, stage);
		return stage + 1;
	}
	return stage;
}

void ASCUnbindSampler(int stage, GLenum target) {
    glActiveTexture(GL_TEXTURE0 + stage);
    glBindTexture(target, 0);
    glDisable(target);
}
