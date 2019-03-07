AppleSamplePCI is a simple driver example that shows how to build kext deliverables that will function on both OS X v10.8 and OS X v10.9. It matches on the IOPCIFamily, specifically on the graphics card(s) found in all Macintosh computers.

It demonstrates the use of I/O Registry properties to set and retrieve settings properties in your driver.

The sample produces two kexts and a test tool. One kext targets OS X v10.9, is signed with Developer ID, and has its install path set to /Library/Extensions. Its version number is 2.2.0.

The second kext targets OS X 10.8, is unsigned, and has its install path set to /System/Library/Extensions. Its version number is 2.1.0.

It is important that the OS X v10.9 kext have a higher version number than the OS X v10.8 kext. Since both kexts have the same bundle identifier, the kext loading system will favor the one with the higher version number.

The test tool is a command line tool that exercises the driver’s functions.
