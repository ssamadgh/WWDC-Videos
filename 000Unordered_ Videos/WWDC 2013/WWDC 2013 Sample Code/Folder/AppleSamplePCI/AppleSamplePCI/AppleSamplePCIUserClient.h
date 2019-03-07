/*
     File: AppleSamplePCIUserClient.h
 Abstract: This class represents the user client object for the driver, which
    will be instantiated by I/O Kit to represent a connection to the client
    process, in response to the client's call to IOServiceOpen().
    It will be destroyed when the connection is closed or the client
    abnormally terminates, so it should track all the resources allocated
    to the client.
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
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

#include <IOKit/IOUserClient.h>
#include "AppleSamplePCI.h"

#define SamplePCIUserClientClassName com_example_apple_samplecode_driver_SamplePCIUserClient

// Forward declarations
class IOBufferMemoryDescriptor;

class SamplePCIUserClientClassName : public IOUserClient
{
	/*
	 * Declare the metaclass information that is used for runtime typechecking of IOKit objects.
	 */
	
	OSDeclareDefaultStructors(com_example_apple_samplecode_driver_SamplePCIUserClient);
	
private:
	SamplePCIClassName*			fDriver;
	IOBufferMemoryDescriptor*	fClientSharedMemory;
	SampleSharedMemory*			fClientShared;
	task_t						fTask;
	int32_t						fOpenCount;
	
public:
	/* IOService overrides */
	virtual bool start(IOService* provider);
	virtual void stop(IOService* provider);
	
	/* IOUserClient overrides */
	virtual bool initWithTask(task_t owningTask, void* securityID,
							  UInt32 type, OSDictionary* properties);
	
	virtual IOReturn clientClose(void);
	
	virtual IOReturn externalMethod(uint32_t selector, IOExternalMethodArguments* arguments,
									IOExternalMethodDispatch* dispatch, OSObject* target, void* reference);
	
	virtual IOReturn clientMemoryForType(UInt32 type,
										 IOOptionBits* options,
										 IOMemoryDescriptor** memory);
	
	/* External methods */
	virtual IOReturn method1(UInt32* dataIn, UInt32* dataOut,
							 IOByteCount inputCount, IOByteCount* outputCount);
	
	virtual IOReturn method2(SampleStructForMethod2* structIn, 
							 SampleResultsForMethod2* structOut,
							 IOByteCount inputSize, IOByteCount* outputSize);
	
};

