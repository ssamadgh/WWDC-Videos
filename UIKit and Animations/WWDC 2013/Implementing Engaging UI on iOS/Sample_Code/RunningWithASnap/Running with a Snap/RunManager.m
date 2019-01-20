/*
     File: RunManager.m
 Abstract: 
 
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

#import "RunManager.h"
#import "Run.h"

@interface RunManager ()
@property (nonatomic, strong) NSArray *runs;
@end

@implementation RunManager

NSString *_rootDataPath() {
    __strong static NSString *_rootPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSFileManager *fm = [[NSFileManager alloc] init];
        NSString *path = [(NSURL *)[[fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] path];
        _rootPath = [path stringByAppendingPathComponent:@"data"];
        
        if (![fm fileExistsAtPath:[_rootPath stringByAppendingPathComponent:@"runs"]]) {
            [fm createDirectoryAtPath:_rootPath withIntermediateDirectories:YES attributes:nil error:nil];
            [fm createDirectoryAtPath:[_rootPath stringByAppendingPathComponent:@"runs"] withIntermediateDirectories:YES attributes:nil error:nil];
            [fm createDirectoryAtPath:[_rootPath stringByAppendingPathComponent:@"photos"] withIntermediateDirectories:YES attributes:nil error:nil];
            [fm createDirectoryAtPath:[_rootPath stringByAppendingPathComponent:@"interface"] withIntermediateDirectories:YES attributes:nil error:nil];
        }
    });
    
    return _rootPath;
}

+(void)saveRun:(Run *)run {
    NSString *runPath = [NSString stringWithFormat:@"%@/runs/%@", _rootDataPath(), [run identifier]];
    NSData *runData = [NSKeyedArchiver archivedDataWithRootObject:run];
    [runData writeToFile:runPath options:0 error:nil];
}

+(NSString *)photoSavePath {
    return [_rootDataPath() stringByAppendingPathComponent:@"photos"];
}

- (id)init {
    self = [super init];
    if (self != nil) {
        NSFileManager *fm = [[NSFileManager alloc] init];
        NSString *runPath = [_rootDataPath() stringByAppendingPathComponent:@"runs"];
        NSArray *savedRuns = [fm contentsOfDirectoryAtPath:runPath error:nil];
        NSMutableArray *runs = [NSMutableArray arrayWithCapacity:[savedRuns count]];
        for (NSString *runIdentifier in savedRuns) {
            NSData *runData = [NSData dataWithContentsOfFile:[runPath stringByAppendingPathComponent:runIdentifier] options:0 error:nil];
            if (runData) {
                Run *run = [NSKeyedUnarchiver unarchiveObjectWithData:runData];
                [runs addObject:run];
            }
        }
        _runs = runs;
    }
    
    return self;
}

- (NSUInteger)numberOfRuns {
    return [self.runs count];
}

- (Run *)runAtIndex:(NSUInteger)idx {
    return [self.runs objectAtIndex:idx];
}

@end
