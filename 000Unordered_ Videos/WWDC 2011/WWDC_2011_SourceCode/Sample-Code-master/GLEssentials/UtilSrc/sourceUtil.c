/*
     File: sourceUtil.c
 Abstract: Functions for loading source files for shaders.
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
 
 Copyright (C) 2010~2011 Apple Inc. All Rights Reserved.
 
 */

#include "sourceUtil.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

demoSource* srcLoadSource(const char* filepathname)
{
	demoSource* source = (demoSource*) calloc(sizeof(demoSource), 1);
	
	// Check the file name suffix to determine what type of shader this is
	const char* suffixBegin = filepathname + strlen(filepathname) - 4;
	
	if(0 == strncmp(suffixBegin, ".fsh", 4))
	{
		source->shaderType = GL_FRAGMENT_SHADER;
	}
	else if(0 == strncmp(suffixBegin, ".vsh", 4))
	{
		source->shaderType = GL_VERTEX_SHADER;
	}
	else
	{
		// Unknown suffix
		source->shaderType = 0;
	}
	
	FILE* curFile = fopen(filepathname, "r");
	
	// Get the size of the source
	fseek(curFile, 0, SEEK_END);
	GLsizei fileSize = ftell (curFile);
	
	// Add 1 to the file size to include the null terminator for the string
	source->byteSize = fileSize + 1;
	
	// Alloc memory for the string
	source->string = malloc(source->byteSize);
	
	// Read entire file into the string from beginning of the file
	fseek(curFile, 0, SEEK_SET);
	fread(source->string, 1, fileSize, curFile);
	
	fclose(curFile);
	
	// Insert null terminator
	source->string[fileSize] = 0;
	
	return source;
}

void srcDestroySource(demoSource* source)
{
	free(source->string);
	free(source);
}