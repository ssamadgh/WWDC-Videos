/*
 
 File:  MorphologicalMinCL.m
 
 Abstract: OpenCL Morphological Min kernel interface
 
 Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by
 Apple Inc. ("Apple") in consideration of your agreement to the
 following terms, and your use, installation, modification or
 redistribution of this Apple software constitutes acceptance of these
 terms.  If you do not agree with these terms, please do not use,
 install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc.
 may be used to endorse or promote products derived from the Apple
 Software without specific prior written permission from Apple.  Except
 as expressly stated in this notice, no other rights or licenses, express
 or implied, are granted by Apple herein, including but not limited to
 any patent rights that may be infringed by your derivative works or by
 other works in which the Apple Software may be incorporated.
 
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
 
 */

#import <OpenCL/opencl.h>
#import <QuartzCore/QuartzCore.h>

#import "MorphologicalMinCL.h"

const char *code =
"__kernel void morphologicalMinX(read_only image2d_t input,write_only image2d_t output,float span)\n"
"{\n"
"    const sampler_t sampler = CLK_NORMALIZED_COORDS_FALSE | CLK_ADDRESS_CLAMP_TO_EDGE | CLK_FILTER_NEAREST;\n"
"    \n"
"    int2 loc = (int2)( get_global_id(0), get_global_id(1) );\n"
"    \n"
"    float4 minV = (float4)(1.0f);\n"
"    \n"
"    for(int i=-(int)floor(span); i<=(int)ceil(span); i++) {\n"
"        float2 readLoc =(float2)(loc.x+i+0.5f,loc.y+0.5f);\n"
"        float4 value = read_imagef(input, sampler, readLoc);\n"
"        minV.xyz = min(minV.xyz,value.xyz);\n"
"    }\n"
"    \n"
"    write_imagef(output, loc ,minV);\n"
"}\n"
"\n"
"__kernel void morphologicalMinY(read_only image2d_t input,write_only image2d_t output,float span)\n"
"{\n"
"    const sampler_t sampler = CLK_NORMALIZED_COORDS_FALSE | CLK_ADDRESS_CLAMP_TO_EDGE | CLK_FILTER_NEAREST;\n"
"    \n"
"    int2 loc = (int2)( get_global_id(0), get_global_id(1) );\n"
"    \n"
"    float4 minV = (float4)(1.0f);\n"
"    \n"
"    for(int j=-(int)floor(span); j<=(int)ceil(span); j++) {\n"
"        float2 readLoc =(float2)(loc.x+0.5f,loc.y+j+0.5f);\n"
"        float4 value = read_imagef(input, sampler, readLoc);\n"
"        \n"
"        if ( (loc.y + (float)j) > 0.0f ) // why isn't clamp to edge working?\n"
"            minV.xyz = min(minV.xyz,value.xyz);\n"
"    }\n"
"    \n"
"    write_imagef(output, loc ,minV);\n"
"}\n";

@implementation MorphologicalMinCL

-(void)_GPUKernelExecDimsForImage:(size_t)work_group_size w:(size_t)w h:(size_t)h global:(size_t *)global local:(size_t *)local maxWorkItemSizes:(const size_t *)maxWorkItemSizes
{
    size_t a, b;
    static const size_t tile_size = 16;
    
    // local[0] and local[1] must be at least 1
    local[0] = tile_size < work_group_size ? tile_size : work_group_size;
    // Ensure that the local work group sizes don't exceed the device limits
    local[0] = local[0] < maxWorkItemSizes[0] ? local[0] : maxWorkItemSizes[0];
    
    local[1] = work_group_size / tile_size > tile_size ? tile_size : MAX(work_group_size / tile_size, 1);
    // Ensure that the local work group sizes don't exceed the device limits
    local[1] = local[1] < maxWorkItemSizes[1] ? local[1] : maxWorkItemSizes[1];
    
    a = w;
    b = (unsigned int) local[0];
    
    global[0] = ((a % b) != 0) ? (a / b + 1) : (a / b);
    global[0] *= local[0];
    
    a = h;
    b = (unsigned int) local[1];
    
    global[1] = ((a % b) != 0) ? (a / b + 1) : (a / b);
    global[1] *= local[1];
}

-(void)_CPUKernelExecDimsForImage:(size_t)work_group_size w:(size_t)w h:(size_t)h global:(size_t *)global local:(size_t *)local maxWorkItemSizes:(const size_t *)maxWorkItemSizes
{
    size_t a, b;

    assert(maxWorkItemSizes[0]);
    assert(work_group_size);
    
    // For the CPU, the local work-group dims need to be (work_group_size, 1, 1)
    // for maximum performance (esp for auto-vectorization).
    local[0] = (work_group_size > maxWorkItemSizes[0]) ? maxWorkItemSizes[0]: work_group_size;
    local[1] = local[2] = 1;

    a = w;
    b = local[0];
    
    global[0] = ((a % b) != 0) ? (a / b + 1) : (a / b);
    global[0] *= local[0];
    
    a = h;
    b = local[1];
    
    global[1] = ((a % b) != 0) ? (a / b + 1) : (a / b);
    global[1] *= local[1];
}


// for a given cl_context find all the underlying devices which are tied
// to it and test each one of those to ensure that it supports the cl mem
// objects of type image.
+(bool)_contextSupportsImages:(cl_context)context
{
    size_t numDevices = 0;
    
    cl_int err = clGetContextInfo(context, CL_CONTEXT_DEVICES, 0, 0, &numDevices);
    
    if ( CL_SUCCESS != err || numDevices <= 0 )
        return false;
    
    numDevices /= sizeof(cl_device_id);
    
    cl_device_id devices[numDevices];
    
    err = clGetContextInfo(context, CL_CONTEXT_DEVICES, sizeof(devices), devices, NULL);
    
    if ( CL_SUCCESS != err )
        return false;
    
    cl_bool imageSupport = false;
    
    for(unsigned int i=0; i < numDevices; i++) {
        err = clGetDeviceInfo(devices[i], CL_DEVICE_IMAGE_SUPPORT, sizeof(imageSupport), &imageSupport, NULL);
        if ( CL_SUCCESS != err || false == imageSupport )
            return false;
    }
    
    return true;
}

-(id)initUsingCGLContext:(CGLContextObj)cglCtx
{
    CGLShareGroupObj shareGroup = cglCtx ? CGLGetShareGroup(cglCtx) : nil;
    
    if ( nil == shareGroup ) // fallback just in case we can't find a share group.
        return [self initUsingDeviceType:CL_DEVICE_TYPE_GPU index:0];
    
    cl_int err = CL_SUCCESS;
    
    cl_context_properties properties[] = { CL_CONTEXT_PROPERTY_USE_CGL_SHAREGROUP_APPLE, (intptr_t) shareGroup, 0 };
    cl_context context = clCreateContext(properties, 0, NULL, NULL, NULL, &err);
    
    size_t numDevices = 0;
    
    err = clGetContextInfo(context, CL_CONTEXT_DEVICES, 0, 0, &numDevices);
    
    if ( CL_SUCCESS != err || numDevices <= 0 )
        return false;
    
    numDevices /= sizeof(cl_device_id);
    
    cl_device_id devices[numDevices];
    
    err = clGetContextInfo(context, CL_CONTEXT_DEVICES, sizeof(devices), devices, NULL);
    
    if ( CL_SUCCESS != err )
        return false;

    //
    // Create queue using first device available; this is probably not _the best_ answer.
    //
    cl_command_queue queue = clCreateCommandQueue(context,devices[0],0,&err);
    clReleaseContext(context);
    
    if ( CL_SUCCESS != err || nil == queue )
        return nil;
    
    return [self initWithCommandQueue:queue];
    
}

-(id)initUsingDeviceType:(cl_device_type)deviceType index:(int)index
{
    cl_context context = 0;
    cl_command_queue queue = 0;
    
    cl_uint nPlatforms = 0;
    cl_uint nDevices = 0;
    cl_platform_id pid;
    cl_device_id device = 0;
    
    cl_int err = clGetPlatformIDs(0, NULL, &nPlatforms);
    
    if ( CL_SUCCESS != err || 0 == nPlatforms )
        return nil;
    
    cl_platform_id platforms[nPlatforms];
    
    err = clGetPlatformIDs(nPlatforms,platforms,&nPlatforms);
    
    if ( CL_SUCCESS != err || nPlatforms <= 0 )
        return nil;
    
    cl_uint maxNDevices = 0;
    
    // Loop on platforms
    for (cl_uint pi=0;pi<nPlatforms;pi++)
    {
        pid = platforms[pi];
        
        err = clGetDeviceIDs(pid,deviceType,0,NULL,&nDevices);
        
        if ( nDevices > maxNDevices )
            maxNDevices = nDevices;
    }
    
    if ( 0 == maxNDevices )
        return nil;
    
    cl_device_id *devices = (cl_device_id *)malloc(sizeof(cl_device_id) * maxNDevices);
    
    if ( ! devices )
        return nil;
    
    bool found = false;

    // Loop on platforms
    for (cl_uint pi=0;pi<nPlatforms;pi++)
    {
        pid = platforms[pi];
        
        err = clGetDeviceIDs(pid,deviceType,0,NULL,&nDevices);
        
        if ( CL_SUCCESS != err || nDevices <= 0 )
            continue;
        
        err = clGetDeviceIDs(pid,deviceType,nDevices,devices,&nDevices);
        
        if ( CL_SUCCESS != err || nDevices <= 0 )
            continue;
        
        if (nDevices < index) {
            index -= nDevices;
            continue;
        } // the requested device is not in this platform
        
        found = true;
        
        break;
    }
    
    if ( found )
        device = devices[index];
    
    free (devices);
    
    if ( ! found )
        return nil;
    
    // Here we found a valid candidate, create the context with the first device
    cl_context_properties props[3] = {0};
    props[0] = CL_CONTEXT_PLATFORM;
    props[1] = (cl_context_properties)pid;
    context = clCreateContext(props,1,&device,0,0,&err);
    
    if ( CL_SUCCESS != err || nil == context )
        return nil;
    
    // Create queue
    queue = clCreateCommandQueue(context,device,0,&err);
    clReleaseContext(context);
    
    if ( CL_SUCCESS != err || nil == queue )
        return nil;
    
    return [self initWithCommandQueue:queue];
}

-(id)initWithCommandQueue:(cl_command_queue)commandQueue
{
    if ( ! commandQueue )
        return nil;
    
    cl_context context = nil;
    
    cl_int err = clGetCommandQueueInfo(commandQueue, CL_QUEUE_CONTEXT, sizeof(cl_context), &context, NULL);
    
    if ( CL_SUCCESS != err || nil == context )
        return nil;
    
    //
    // Make sure all devices tied to this context support images.
    //
    // Note this algorithm could just as easily use buffers but because we're using IOSurfaces we
    // need to ensure we have image support. Otherwise we would have to ask Core Image to render
    // to a CPU buffer instead and use that as the input type. For the sake of keeping things on
    // the GPU and showing off interportability we only implement the IOSurface path instead. It
    // also makes changing this code to run on a CPU a no-op effectively and is the best way to
    // ensure that we keep the data on the GPU for the entire processing pipeline.
    //
    if ( false == [[self class] _contextSupportsImages:context] )
        return nil;
    
    self = [super init];
    
    if ( self ) {
        _commandQueue = commandQueue;
        clRetainCommandQueue(commandQueue);
        
        size_t           lengths[1];
        
#if 0
        //
        // if you're creating an app which has a resource fork (and not just a command line tool)
        // then adding the OpenCL kernel code to a separate file and loading the data this way
        // is a much more elegant way to package things up and is also quite useful for debugging, etc.
        //
        NSError *nsError = nil;
        NSString *clCodePath = [[NSBundle mainBundle] pathForResource:@"dehazingKernels" ofType:@".cl"];
        NSString* source = [NSString stringWithContentsOfFile:clCodePath encoding:NSUTF8StringEncoding error:&nsError];
       
        const char *code = [source UTF8String];
#endif
        
        lengths[0] = strlen(code);
        cl_program program = clCreateProgramWithSource(context, 1, &code, lengths, &err);
        
        if ( CL_SUCCESS != err || nil == program ) {
            [self release];
            return nil;
        }
        
        const char *optionsForDevice = "-cl-denorms-are-zero -cl-mad-enable";
        
        size_t numDevices = 0;
        err = clGetContextInfo(context, CL_CONTEXT_DEVICES, 0, NULL, &numDevices);
        
        if ( CL_SUCCESS != err || numDevices <= 0 ) {
            clReleaseProgram(program);
            [self release];
            return false;
        }
        
        numDevices /= sizeof(cl_device_id);
        
        cl_device_id devices[numDevices];
        
        err = clGetContextInfo(context, CL_CONTEXT_DEVICES, sizeof(devices), devices, NULL);
        
        if ( CL_SUCCESS != err ) {
            clReleaseProgram(program);
            [self release];
            return false;
        }
        
        cl_uint n = (cl_uint)numDevices;
        err = clBuildProgram(program, n, devices, optionsForDevice, NULL, NULL);
        
        if ( CL_SUCCESS != err ) {
            size_t logSize;
            
            for(int i=0; i<numDevices; i++) {
                err = clGetProgramBuildInfo(program, devices[i], CL_PROGRAM_BUILD_LOG, 0, NULL, &logSize);
                
                if ( logSize > 0 && CL_SUCCESS == err ) {
                    char *buildLog = (char *)malloc(logSize+1);
                    
                    if ( buildLog ) {
                        err = clGetProgramBuildInfo(program, devices[i], CL_PROGRAM_BUILD_LOG, logSize, buildLog, NULL);
                        if ( err == CL_SUCCESS ) {
                            buildLog[logSize] = '\0';
                            NSLog(@"build error for device[%d] log = %s",i,buildLog);
                        }
                        free (buildLog);
                    }
                }
            }
            
            clReleaseProgram(program);
            [self release];
            return false;
        }
        
        _morphologicalMinX = clCreateKernel(program, "morphologicalMinX", &err);
        if ( CL_SUCCESS != err || nil == _morphologicalMinX ) {
            [self release];
            return false;
        }
        
        _morphologicalMinY = clCreateKernel(program, "morphologicalMinY", &err);
        if ( CL_SUCCESS != err || nil == _morphologicalMinY ) {
            [self release];
            return false;
        }
        
        clReleaseProgram(program);
    }
    
    return self;
}

- (const cl_image_format)_openCLFormatForIOSurface:(IOSurfaceRef)surface
{
    cl_image_format format = { 0, 0 };
    
    // add support for mucho more formats here ... very incomplete.
    switch(IOSurfaceGetPixelFormat(surface)) {
        case 'BGRA':
            format.image_channel_order = CL_RGBA;
            format.image_channel_data_type = CL_UNORM_INT8;
            break;
            
        case 'RGBA':
            format.image_channel_order = CL_BGRA;
            format.image_channel_data_type = CL_UNORM_INT8;
            break;
            
        default:
        {
            OSType pixelFormatType = IOSurfaceGetPixelFormat(surface);
            char *p = (char *)&pixelFormatType;
            char s[] = { p[3], p[2], p[1], p[0], '\0' };
            NSLog(@"Providing input IOSurface for which we don't (yet) know the mapping to OpenCL. OSType = %s",s);
        }
            
            break;
    }
    
    return format;
}


-(bool)removeHazeFromImage:(IOSurfaceRef)inputSurface outputSurface:(IOSurfaceRef)outputSurface spanX:(float)spanX spanY:(float)spanY
{
    if ( ! _commandQueue || ! inputSurface || ! outputSurface )
        return false;
    
    cl_int err = CL_SUCCESS;
    
    size_t width = IOSurfaceGetWidth(inputSurface);
    size_t height = IOSurfaceGetHeight(inputSurface);
    
    if ( IOSurfaceGetWidth(outputSurface) != width || IOSurfaceGetHeight(outputSurface) != height )
        return false;
    
    cl_image_format inputFormat = [self _openCLFormatForIOSurface:inputSurface];
    cl_image_format outputFormat = [self _openCLFormatForIOSurface:outputSurface];
    
    if ( 0 == inputFormat.image_channel_data_type || 0 == inputFormat.image_channel_order ||  0 == outputFormat.image_channel_data_type || 0 == outputFormat.image_channel_order )
        return false;
    
    cl_context clctx = NULL;
    
    err = clGetCommandQueueInfo(_commandQueue, CL_QUEUE_CONTEXT, sizeof(clctx), &clctx, NULL);
    
    if ( CL_SUCCESS != err || NULL == clctx )
        return false;
    
    cl_mem inputImage = clCreateImageFromIOSurface2DAPPLE(clctx, CL_MEM_READ_ONLY, &inputFormat, width, height, inputSurface, &err);
    if ( NULL == inputImage || CL_SUCCESS != err ) {
        return false;
    }
    
    // we just specify the type of object and the width and height and let OpenCL determine the proper bpr, etc for us.
    const cl_image_desc cid = { CL_MEM_OBJECT_IMAGE2D, width, height, 0, 0, 0, 0, 0, 0, NULL };
    
    // this image will be used as the output for the first pass of the algorithm and as the input for the second pass
    // of the algorithm which is why we mark it read-write.
    cl_mem intermediateImage = clCreateImage(clctx, CL_MEM_READ_WRITE, &outputFormat, &cid, NULL, &err);
    if ( NULL == intermediateImage || CL_SUCCESS != err ) {
        clReleaseMemObject(inputImage);
        return false;
    }
    
    // image where we will store our final result.
    cl_mem outputImage = clCreateImageFromIOSurface2DAPPLE(clctx, CL_MEM_WRITE_ONLY, &outputFormat, width, height, outputSurface, &err);
    if ( NULL == outputImage || CL_SUCCESS != err ) {
        clReleaseMemObject(inputImage);
        clReleaseMemObject(intermediateImage);
        return false;
    }
    
    size_t executionThreads[2] = { 1, 1 };
    size_t executionLocal[2] = { 1, 1 };
    
    cl_uint max_work_item_dims;
    
    size_t numDevices = 0;
    err = clGetContextInfo(clctx, CL_CONTEXT_DEVICES, 0, NULL, &numDevices);
    
    if ( CL_SUCCESS != err || numDevices <= 0 ) {
        clReleaseMemObject(inputImage);
        clReleaseMemObject(intermediateImage);
        return false;
    }
    
    numDevices /= sizeof(cl_device_id);
    
    cl_device_id devices[numDevices];
    
    err = clGetContextInfo(clctx, CL_CONTEXT_DEVICES, sizeof(devices), devices, NULL);
    
    if ( CL_SUCCESS != err ) {
        clReleaseMemObject(inputImage);
        clReleaseMemObject(intermediateImage);
        return false;
    }
    
    cl_device_id device = devices[0]; // just use the first device.
    
    err = clGetDeviceInfo(device,
                          CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS,
                          sizeof(max_work_item_dims),
                          &max_work_item_dims,
                          NULL);
    
    if ( CL_SUCCESS != err || max_work_item_dims == 0 )
        return false;
    
    cl_device_type deviceType;
    
    err = clGetDeviceInfo(device, CL_DEVICE_TYPE, sizeof(cl_device_type), &deviceType, NULL);
    if ( CL_SUCCESS != err )
        return false;
    
    size_t *max_work_item_sizes = (size_t *) malloc(sizeof(size_t) * max_work_item_dims);
    
    if ( ! max_work_item_dims )
        return false;
    
    err = clGetDeviceInfo(device,
                          CL_DEVICE_MAX_WORK_ITEM_SIZES,
                          sizeof(size_t) * max_work_item_dims,
                          max_work_item_sizes,
                          NULL);
    
    if ( CL_SUCCESS != err ) {
        free(max_work_item_sizes);
        return false;
    }
    
    if ( CL_DEVICE_TYPE_CPU == deviceType )
        [self _CPUKernelExecDimsForImage:executionLocal[0] w:width h:height global:executionThreads local:executionLocal maxWorkItemSizes:max_work_item_sizes];
    else if ( CL_DEVICE_TYPE_GPU == deviceType )
        [self _GPUKernelExecDimsForImage:executionLocal[0] w:width h:height global:executionThreads local:executionLocal maxWorkItemSizes:max_work_item_sizes];
    else {
        free((void *)max_work_item_sizes);
        return false;
    }
    
    free(max_work_item_sizes);
    
    //
    // run seperable kernel in X direction first
    //
    
    // set up kernel parameters
    err |= clSetKernelArg(_morphologicalMinX, 0, sizeof(cl_mem), &inputImage);
    err |= clSetKernelArg(_morphologicalMinX, 1, sizeof(cl_mem), &intermediateImage);
    err |= clSetKernelArg(_morphologicalMinX, 2, sizeof(float),  &spanX);
    
    if ( CL_SUCCESS != err ) {
        clReleaseMemObject(inputImage);
        clReleaseMemObject(intermediateImage);
        clReleaseMemObject(outputImage);
        return false;
    }
    
    // run kernel
    err = clEnqueueNDRangeKernel(_commandQueue, _morphologicalMinX, 2, NULL, executionThreads, executionLocal, 0, NULL, NULL);
    
    if ( CL_SUCCESS != err ) {
        clReleaseMemObject(inputImage);
        clReleaseMemObject(intermediateImage);
        clReleaseMemObject(outputImage);
        return false;
    }
    
    err |= clSetKernelArg(_morphologicalMinY, 0, sizeof(cl_mem), &intermediateImage);
    err |= clSetKernelArg(_morphologicalMinY, 1, sizeof(cl_mem), &outputImage);
    err |= clSetKernelArg(_morphologicalMinY, 2, sizeof(float),  &spanY);
    
    if ( CL_SUCCESS != err ) {
        clReleaseMemObject(inputImage);
        clReleaseMemObject(intermediateImage);
        clReleaseMemObject(outputImage);
        return false;
    }
    
    //
    // run seperable kernel in Y direction next
    //
    err = clEnqueueNDRangeKernel(_commandQueue, _morphologicalMinY, 2, NULL, executionThreads, executionLocal, 0, NULL, NULL);
    
    // we need to flush the command queue so that no additional work gets scheduled on the GPU
    // before handing back the IOSurfaces to Core Image. If we don't do this we're likely to see
    // some timing synchronization issues resulting in garabge on screen (because OpenCL won't
    // necessarily have performed the work we asked it to do before we released all the underlying
    // objects and before passing the IOSurface that is used for output back to Core Image as an
    // input surface.
    clFlush(_commandQueue);
    
    clReleaseMemObject(inputImage);
    clReleaseMemObject(intermediateImage);
    clReleaseMemObject(outputImage);
    
    return CL_SUCCESS == err;
}

-(void)dealloc
{
    if ( _commandQueue )
        clReleaseCommandQueue(_commandQueue), _commandQueue = 0;
    if ( _morphologicalMinX )
        clReleaseKernel(_morphologicalMinX), _morphologicalMinX = 0;
    if ( _morphologicalMinY )
        clReleaseKernel(_morphologicalMinY), _morphologicalMinY = 0;
    
    [super dealloc];
}

@end
