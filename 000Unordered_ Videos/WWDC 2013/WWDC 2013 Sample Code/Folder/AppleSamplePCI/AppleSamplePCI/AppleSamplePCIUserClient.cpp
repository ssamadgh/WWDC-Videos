/*
     File: AppleSamplePCIUserClient.cpp
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

#include <IOKit/IOLib.h>
#include <IOKit/IOKitKeys.h>
#include <libkern/OSByteOrder.h>
#include <IOKit/assert.h>
#include <IOKit/IOBufferMemoryDescriptor.h>
#include <string.h>
#include "AppleSamplePCIUserClient.h"

/* 
 * Define the metaclass information that is used for runtime
 * typechecking of IOKit objects. We're a subclass of IOUserClient.
 */

#define super IOUserClient
/*
 * Even though we are defining the convenient macro super for the superclass you must use the actual class name
 * in the OS*MetaClass macros.
 */
OSDefineMetaClassAndStructors(com_example_apple_samplecode_driver_SamplePCIUserClient, IOUserClient);

/* 
 * Since this sample uses the IOUserClientClass property in its Info.plist, the SamplePCIUserClient
 * is created automatically in response to IOServiceOpen(). More complex applications
 * might have several kinds of clients each with a different IOUserClient subclass,
 * with different enumerated types. In that case the SamplePCI class must implement
 * the newUserClient() method (see IOService.h headerdoc).
 */

bool SamplePCIUserClientClassName::initWithTask(task_t owningTask, void* securityID,
												 UInt32 type, OSDictionary* properties)
{
	bool success = super::initWithTask(owningTask, securityID, type, properties);
	
	// Can't call getName() until init() has been called.
	IOLog("%s[%p]::%s(type = " UInt32_FORMAT ")\n", getName(), this, __FUNCTION__, type);

    fTask = owningTask;
	fDriver = NULL;
	
    return success;
}

/* 
 * Driver initialization after the matching has completed...
 */
bool SamplePCIUserClientClassName::start(IOService* provider)
{
	IOLog("%s[%p]::%s(provider = %p)\n", getName(), this, __FUNCTION__, provider);
	
    if (!super::start(provider)) {
        return false;
    }
	
    /*
     * Our provider should be a SamplePCI object. Verify that before proceeding.
     */
	
    assert(OSDynamicCast(SamplePCIClassName, provider));
    fDriver = (SamplePCIClassName*) provider;
	
    /*
     * Set up some memory to be shared between this user client instance and its
     * client process. The client will call in to map this memory, and I/O Kit
     * will call clientMemoryForType to obtain this memory descriptor.
     */
	
    fClientSharedMemory = IOBufferMemoryDescriptor::withOptions(kIOMemoryKernelUserShared, sizeof(SampleSharedMemory));
    if (fClientSharedMemory == NULL) {
        return false;
    }

	fClientShared = (SampleSharedMemory*) fClientSharedMemory->getBytesNoCopy();
    
    fClientShared->field1 = 0x11111111; // same in all endianesses...
    fClientShared->field2 = 0x22222222; // ditto
    fClientShared->field3 = 0x33333333; // ditto
	
    (void) strlcpy(fClientShared->string, "some data", sizeof(fClientShared->string));

    fOpenCount = 1;
	
    return true;
}


/*
 * Kill ourselves off if the client closes its connection or the client dies.
 */

IOReturn SamplePCIUserClientClassName::clientClose(void)
{
	IOLog("%s[%p]::%s()\n", getName(), this, __FUNCTION__);
    
	if(!isInactive()) {
        terminate();
    }
	
    return kIOReturnSuccess;
}

/* 
 * stop will be called during the termination process, and should free all resources
 * associated with this client.
 */
void SamplePCIUserClientClassName::stop(IOService* provider)
{
	IOLog("%s[%p]::%s(provider = %p)\n", getName(), this, __FUNCTION__, provider);
	
    if (fClientSharedMemory != NULL) {
        fClientSharedMemory->release();
        fClientSharedMemory = 0;
    }
	
    super::stop(provider);
}

// defining and selecting our external user client methods
IOReturn SamplePCIUserClientClassName::externalMethod(uint32_t selector, IOExternalMethodArguments* arguments,
													  IOExternalMethodDispatch* dispatch, OSObject* target, void* reference)
{
	IOReturn	result;
	
	if (fDriver == NULL || isInactive()) {
		// Return an error if we don't have a provider. This could happen if the user process
		// called either method without calling IOServiceOpen first. Or, the user client could be
		// in the process of being terminated and is thus inactive.
		result = kIOReturnNotAttached;
	}
	else if (!fDriver->isOpen(this)) {
		// Return an error if we do not have the driver open. This could happen if the user process
		// did not call openUserClient before calling this function.
		result = kIOReturnNotOpen;
	}
	
    IOReturn err;
    switch (selector)
    {
		case kSampleMethod1:
			err = method1((UInt32*) arguments->structureInput, 
						  (UInt32*) arguments->structureOutput,
						  arguments->structureInputSize, (IOByteCount *) &arguments->structureOutputSize);
			break;
			
		case kSampleMethod2:
			err = method2((SampleStructForMethod2*) arguments->structureInput, 
						  (SampleResultsForMethod2*) arguments->structureOutput,
						  arguments->structureInputSize, (IOByteCount*) &arguments->structureOutputSize);
			break;
			
		default:
			err = kIOReturnBadArgument;
			break;
    }
	
    IOLog("externalMethod(%d) 0x%x\n", selector, err);
	
    return err;
}

/*
 * Implement each of the external methods described above.
 */

IOReturn SamplePCIUserClientClassName::method1(UInt32* dataIn, UInt32* dataOut,
											   IOByteCount inputSize, IOByteCount* outputSize)
{
    IOReturn	ret;
    IOItemCount	count;
	
    IOLog("SamplePCIUserClient::method1(");
	
    if (*outputSize < inputSize) {
        return(kIOReturnNoSpace);
    }
	
    count = (IOItemCount)(inputSize / sizeof(UInt32));
    for (UInt32 i = 0; i < count; i++) {
        IOLog("" UInt32_x_FORMAT ", ", dataIn[i]);
        dataOut[i] = dataIn[i] ^ 0xffffffff;
    }
	
    ret = kIOReturnSuccess;
    IOLog(")\n");
    *outputSize = count * sizeof(UInt32);
	
    return ret;
}

IOReturn SamplePCIUserClientClassName::method2(SampleStructForMethod2* structIn, 
												SampleResultsForMethod2* structOut,
												IOByteCount inputSize, IOByteCount* outputSize)
{
    IOReturn err;
    IOMemoryDescriptor* memDesc = 0;
    UInt32 param1 = structIn->parameter1;
	
	uint64_t clientAddr = structIn->data_pointer;
	uint64_t size = structIn->data_length;

    IOLog("SamplePCIUserClient::method2(" UInt32_x_FORMAT ")\n", param1);
    IOLog("fClientShared->string == \"%s\"\n", fClientShared->string);
	
    structOut->results1 = 0x87654321;
	
    do {
        memDesc = IOMemoryDescriptor::withAddressRange(clientAddr, size, kIODirectionNone, fTask);
        if (memDesc == NULL) {
            IOLog("IOMemoryDescriptor::withAddresswithAddressRange failed\n");
			err = kIOReturnVMError;
            continue;
        }
        // Wire it and make sure we can write it
        err = memDesc->prepare(kIODirectionOutIn);
        if (kIOReturnSuccess != err) {
            IOLog("IOMemoryDescriptor::prepare failed(0x%08x)\n", err);
            continue;
        }
		
        // Generate a DMA list for the client memory
		err = fDriver->generateDMAAddresses(memDesc);
		
        // Other methods to access client memory:
		
        // readBytes/writeBytes allow programmed I/O to/from an offset in the buffer
        char pioBuffer[200];
        memDesc->readBytes(32, &pioBuffer, sizeof(pioBuffer));
        IOLog("readBytes: \"%s\"\n", pioBuffer);
		
        // map() will create a mapping in the kernel address space.
        IOMemoryMap* memMap = memDesc->map();
        if (memMap) {
            char buf[32];
            char* address = (char*) memMap->getAddress();
            strlcpy(buf, address + 32, sizeof(buf));
            IOLog("kernel mapped: \"%s\"\n", buf);
            memMap->release();
        } else {
            IOLog("memDesc map(kernel) failed\n");
		}
		
        // this will create a mapping in the user's (the client of this IOUserClient) address space.
        memMap = memDesc->createMappingInTask(fTask, 0, kIOMapAnywhere);

		if (memMap != NULL) {
            mach_vm_address_t address64 = memMap->getAddress();
            IOLog("user64 mapped: 0x%016llx\n", address64);
            memMap->release();
        } else {
            IOLog("memDesc map(user) failed\n");
		}
		
        // Done with the I/O now.
        memDesc->complete(kIODirectionOutIn);
    } while (false);
	
    if (memDesc != NULL) {
        memDesc->release();
    }
	
    return err;
}

/*
 * Shared memory support. Supply a IOMemoryDescriptor instance to describe
 * each of the kinds of shared memory available to be mapped into the client
 * process with this user client.
 */

IOReturn SamplePCIUserClientClassName::clientMemoryForType(UInt32 type,
                                                           IOOptionBits* options,
                                                           IOMemoryDescriptor** memory)
{
    // Return a memory descriptor reference for some memory a client has requested 
    // be mapped into its address space.
	
    IOReturn ret;
	
    IOLog("SamplePCIUserClient::clientMemoryForType(" UInt32_FORMAT ")\n", type);
	
    switch (type) {
        case kSamplePCIMemoryType1:
            // give the client access to some shared data structure
            // (shared between this object and the client)
            fClientSharedMemory->retain();
            *memory = fClientSharedMemory;
            ret = kIOReturnSuccess;
            break;
			
        case kSamplePCIMemoryType2:
            // Give the client access to some of the card's memory
            // (all clients get the same)
            *memory = fDriver->copyGlobalMemory();
            ret = kIOReturnSuccess;
            break;
			
        default:
            ret = kIOReturnBadArgument;
            break;
    }
	
    return ret;
}

