/*
     File: AppleSamplePCIClient.c
 Abstract: Command line tool that accesses the user client routines of our AppleSamplePCI kext.
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

#include <AvailabilityMacros.h>
#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <pthread.h>
#include <sys/mman.h>
#include <inttypes.h>
#include <IOKit/IOKitLib.h>
#include <CoreFoundation/CoreFoundation.h>
#include "AppleSamplePCIShared.h"

void TestProperties(io_service_t service);
void TestUserClient(io_service_t service);
void TestSharedMemory(io_connect_t connect);

#define arrayCnt(var) (sizeof(var) / sizeof(var[0]))

void TestProperties( io_service_t service )
{
    CFMutableDictionaryRef	properties;
    CFStringRef				cfStr;
    kern_return_t			kr;	
	CFMutableDictionaryRef	dictRef;
    CFNumberRef				numberRef;
    SInt32					constant24 = 24;

	// Create a dictionary to pass to our driver. This dictionary has the key "value"
	// and the value an integer in constant24. 
	printf("Testing sending properties to the driver.\n");
	
	dictRef = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, 
										&kCFTypeDictionaryKeyCallBacks,
										&kCFTypeDictionaryValueCallBacks);
	
	numberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &constant24);    
	CFDictionarySetValue(dictRef, CFSTR("value"), numberRef);
	CFRelease(numberRef);
	
	// This is the function that results in ::setProperties() being called in our
	// kernel driver. The dictionary we created is passed to the driver here.
	kr = IORegistryEntrySetCFProperties(service, dictRef);
	if (KERN_SUCCESS != kr) {
		fprintf(stderr, "IORegistryEntrySetCFProperties returned 0x%08x.\n", kr);
	} else {
		printf("Property setting test succeeded.\n");
	}
	
	// print the value of kIONameMatchedKey property, as an example of 
	// getting properties from the registry. Property based access
	// doesn't require a user client connection.
	// grab a copy of the properties
	printf("Testing fetching driver's properties from the I/O Registry.\n");
	
	kr = IORegistryEntryCreateCFProperties(service, &properties,
										   kCFAllocatorDefault, kNilOptions);
	assert(KERN_SUCCESS == kr);
	
	// finding the name we matched on
	cfStr = CFDictionaryGetValue( properties, CFSTR(kIONameMatchedKey) );
	if (cfStr != NULL) {
		const char* c = NULL;
		char* buffer = NULL;
		c = CFStringGetCStringPtr(cfStr, kCFStringEncodingMacRoman);
		
        if (c == NULL) {
			CFIndex bufferSize = CFStringGetLength(cfStr) + 1;
			buffer = malloc(bufferSize);
			if (buffer) {
				if (CFStringGetCString(cfStr, buffer, bufferSize, kCFStringEncodingMacRoman)) {
					c = buffer;
                }
			}
		}
		
        if (c != NULL) {
			printf("Driver matched on name \"%s\"\n", c);
        }
		
        if (buffer != NULL) {
			free(buffer);
        }
	}
	CFRelease(properties);
	
	printf("Property fetching test completed.\n");
}

void TestUserClient(io_service_t service)
{
    kern_return_t				kr;
    io_connect_t				connect;
    size_t						structureOutputSize;
    SampleStructForMethod2		method2Param;
    SampleResultsForMethod2		method2Results;
    uint32_t					varStructParam[3] = { 1, 2, 3 };
    IOByteCount					bigBufferLen;
    uint32_t*					bigBuffer;
	
	// Connecting to driver
    kr = IOServiceOpen(service, mach_task_self(), kSamplePCIConnectType, &connect);
    assert(KERN_SUCCESS == kr);
	
    // test a simple struct in/out method
    structureOutputSize = sizeof(varStructParam);
	
    kr = IOConnectCallStructMethod(connect, kSampleMethod1,
								   // inputStructure
								   &varStructParam, sizeof(varStructParam),
								   // outputStructure
								   &varStructParam, &structureOutputSize);
	
    assert(KERN_SUCCESS == kr);
    printf("kSampleMethod1 results 0x%08" PRIx32 ", 0x%08" PRIx32 ", 0x%08" PRIx32 "\n",
		   varStructParam[0], varStructParam[1], varStructParam[2]);
	
    // Test shared memory.
    TestSharedMemory(connect);
	
    // Test method with out of line memory.
	// Use anonymous mmap to ensure we get a single VM object.
    bigBufferLen = 0x4321;
    bigBuffer = (uint32_t*) mmap(NULL, bigBufferLen, PROT_READ | PROT_WRITE, MAP_ANON | MAP_SHARED, -1, 0);
    if (bigBuffer == MAP_FAILED) {
        perror("mmap() call error:");
		return;
	}
	
	printf("buffer is created @ %p\n", bigBuffer);
	
    (void) strlcpy((char*)(bigBuffer + (32 / 4)), "some out of line data", bigBufferLen);
	
    method2Param.parameter1   = 0x12345678;
    method2Param.data_pointer = (uintptr_t) bigBuffer;
    method2Param.data_length  = bigBufferLen;
	
    structureOutputSize = sizeof(method2Results);
	
    kr = IOConnectCallStructMethod(connect, kSampleMethod2,
								   // inputStructure
								   &method2Param, sizeof(method2Param),
								   // outputStructure
								   &method2Results, &structureOutputSize);
	
    assert(KERN_SUCCESS == kr);
    printf("kSampleMethod2 result 0x%" PRIx64 "\n", method2Results.results1);
	
    munmap(bigBuffer, bigBufferLen);
}

// When using shared memory you need to decide and manage the word length issues.
//
// An alternative for shared memory for a high speed streaming data queue would be IOStream Family.

void TestSharedMemory(io_connect_t connect)
{
    kern_return_t			kr;
    SampleSharedMemory*     shared;
	
    mach_vm_address_t		addr;
    mach_vm_size_t			size;
    
    kr = IOConnectMapMemory(connect, kSamplePCIMemoryType1,
                            mach_task_self(), &addr, &size,
                            kIOMapAnywhere | kIOMapDefaultCache);
    assert(KERN_SUCCESS == kr);
    assert(size == sizeof(SampleSharedMemory));
	
    shared = (SampleSharedMemory*) addr;
	
    printf("From SampleSharedMemory: %08" PRIx32 ", %08" PRIx32 ", %08" PRIx32 ", \"%s\"\n",
		   shared->field1, shared->field2, shared->field3, shared->string);
	
    (void)strlcpy(shared->string, "some other data", sizeof(shared->string));
}


int main(int argc, char * argv[])
{
    io_iterator_t			iter;
    io_service_t			service;
    kern_return_t			kr;
	bool					driverFound = false;
	
    // Look up the object we wish to open. This example uses simple class
    // matching (IOServiceMatching()) to look up the object that is the
    // SamplePCI driver class instantiated by the kext.
	
    kr = IOServiceGetMatchingServices(kIOMasterPortDefault,
									   IOServiceMatching(kSamplePCIClassName), &iter);
    assert(KERN_SUCCESS == kr);
	
    for ( ; (service = IOIteratorNext(iter)); IOObjectRelease(service)) {
        io_string_t path;
        kr = IORegistryEntryGetPath(service, kIOServicePlane, path);
        assert(KERN_SUCCESS == kr);
        
		driverFound = true;
		printf("Found a device of class "kSamplePCIClassName": %s\n", path);
		
		// Test getting and setting properties
		TestProperties(service);
		
        // Test the user client
        TestUserClient(service);
    }
    IOObjectRelease(iter);
	
	if (driverFound == false) {
		fprintf(stderr, "No matching drivers found.\n");
	}
	
    return EXIT_SUCCESS;
}

