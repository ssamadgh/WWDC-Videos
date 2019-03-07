/*
     File: AppleSamplePCI.h
 Abstract: This is a tiny driver that attaches to a PCI device and logs information
    about it. It doesn't alter the device in any way. It also supports a
    generic IOUserClient subclass that allows driver-specific client code to
    make various kinds of calls into the driver, and map shared memory
    or portions of hardware memory.
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

#include <IOKit/IOService.h>
#include "AppleSamplePCIShared.h"

// Handy IOLog/printf format strings.
#define UInt32_FORMAT		"%u"
#define UInt32_x_FORMAT		"0x%08x"
#define PhysAddr_FORMAT		"0x%016llx"
#define PhysLen_FORMAT		"%llu"
#define VirtAddr_FORMAT		"0x%016llx"
#define ByteCount_FORMAT	"%llu"

// Forward declarations
class IOPCIDevice;
class IOMemoryDescriptor;

class SamplePCIClassName : public IOService
{
	/*
	 * Declare the metaclass information that is used for runtime
	 * typechecking of I/O Kit objects. Note that the class name is different when targeting PowerPC on 10.4
	 * because that support has to be built as a separate kext. This is because we have to use
	 * older 32-bit-only KPIs for that platform.
	 */
	
	OSDeclareDefaultStructors( com_example_apple_samplecode_driver_SamplePCI );

private:
	IOPCIDevice*			fPCIDevice;
	IOMemoryDescriptor*		fLowMemory;
	
public:
	/* IOService overrides */
	virtual bool start(IOService* provider);
	virtual void stop(IOService* provider);
	virtual IOReturn setProperties(OSObject* properties);
	
	/* Other methods */
	IOMemoryDescriptor* copyGlobalMemory(void);
	IOReturn generateDMAAddresses(IOMemoryDescriptor* memDesc);
	void updateRegistry(UInt32 value);
};


