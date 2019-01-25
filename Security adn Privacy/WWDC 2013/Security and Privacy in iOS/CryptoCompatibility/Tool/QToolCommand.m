/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Command line tool infrastructure.
 */

#import "QToolCommand.h"

#include <objc/message.h>

#include <getopt.h>

NS_ASSUME_NONNULL_BEGIN

@interface QToolCommand ()

@property (nonatomic, copy,   readwrite) NSArray *  arguments;

@end

NS_ASSUME_NONNULL_END

@implementation QToolCommand

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        self->_arguments = @[];     // because it's marked as non-null
    }
    return self;
}

+ (NSString *)commandName {
    NSAssert(NO, @"implementation required");
    return nil;
}
    
+ (NSString *)commandUsage {
    NSAssert(NO, @"implementation required");
    return nil;
}

- (BOOL)validateOptionsAndArguments:(NSArray *)optionsAndArguments {
    BOOL            success;
    NSUInteger      argc;
    const char **   argv;
    const char *    commandOptionsCStr;
    int             opt;
    
    NSParameterAssert(optionsAndArguments != nil);
    
    optind = 0;
    optreset = 1;
    
    // Create argc and argv to mirror our arguments.
    
    argc = optionsAndArguments.count;
    argv = malloc(argc * sizeof(const char *));
    for (NSUInteger argIndex = 0; argIndex < argc; argIndex++) {
        argv[argIndex] = [optionsAndArguments[argIndex] UTF8String];
    }
    
    success = YES;
    commandOptionsCStr = [self commandOptions].UTF8String;
    do {
        // I'm casting away a const here, which is a bit of a worry.  If getopt 
        // modified the string, I'd be in trouble.  AFAIK this doesn't happen.
        opt = getopt( (int) argc, (char **) argv, commandOptionsCStr);
        if (opt != -1) {
            success = (opt != '?');     // getopt passes us '?' for unrecognised options, but we don't want to pass that to -setOption:[argument:]
            if (success) {
                if (optarg == NULL) {
                    [self setOption:opt];
                } else {
                    NSString *  optargStr;
                    
                    optargStr = @(optarg);
                    if (optargStr == nil) {
                        success = NO;   // not valid UTF-8
                    } else {
                        success = [self setOption:opt argument:optargStr];
                    }
                }
            }
        }
    } while ( (opt != -1) && success );
    
    // Save away the remaining arguments.
    
    if (success) {
        assert(optind >= 0);
        assert( (NSUInteger) optind <= argc);
        self.arguments = [optionsAndArguments subarrayWithRange:NSMakeRange( (NSUInteger) optind, argc - (NSUInteger) (optind) )];
    }
    
    // Clean up.
    
    free(argv);
    
    return success;
}

+ (NSArray *)optionsAndArgumentsFromArgC:(int)argc argV:(char **)argv {
    NSMutableArray *    optionsAndArguments;
    
    optionsAndArguments = [[NSMutableArray alloc] init];
    
    for (int argIndex = 1; argIndex < argc; argIndex++) {
        NSString *  argStr;
        
        argStr = @(argv[argIndex]);
        if (argStr != nil) {
            [optionsAndArguments addObject:argStr];
        } else {
            optionsAndArguments = nil;
            break;
        }
    }
    return optionsAndArguments;
}

- (BOOL)runError:(NSError **)errorPtr {
    #pragma unused(errorPtr)
    NSAssert(NO, @"implementation required");
    return NO;
}

- (NSString *)commandOptions {
    return @"";
}

static BOOL IsValidOption(int option) {
    return ((option >= 'a') && (option <= 'z')) || ((option >= 'A') && (option <= 'Z')) || ((option >= '0') && (option <= '9')) || (option == '_');
}

- (void)setOption:(int)option {
    BOOL        success;
    SEL         sel;
    typedef void (*SetOptionFunc)(id self, SEL sel);
    
    success = IsValidOption(option);
    if (success) {
        sel = NSSelectorFromString([NSString stringWithFormat:@"setOption_%c", option]);
        success = [self respondsToSelector:sel];
    }
    if (success) {
        (void) ((SetOptionFunc) objc_msgSend)(self, sel);
    }
    NSAssert(success, @"-setOption_X method not found");
}

- (BOOL)setOption:(int)option argument:(NSString *)argument {
    BOOL        success;
    SEL         sel;
    typedef BOOL (*SetOptionArgumentFunc)(id self, SEL sel, NSString * argument);
    
    NSParameterAssert(argument != nil);
    
    success = IsValidOption(option);
    if (success) {
        sel = NSSelectorFromString([NSString stringWithFormat:@"setOption_%c_argument:", option]);
        success = [self respondsToSelector:sel];
    }
    if (success) {
        success = ((SetOptionArgumentFunc) objc_msgSend)(self, sel, argument);
    } else {
        NSAssert(NO, @"-setOption_X_argument: method not found");
    }
    return success;
}

@end

NS_ASSUME_NONNULL_BEGIN

@interface QComplexToolCommand ()

@property (nonatomic, strong, readwrite, nullable) QToolCommand *   subcommand;

@end

NS_ASSUME_NONNULL_END

@implementation QComplexToolCommand

+ (NSArray *)subcommandClasses {
    NSAssert(NO, @"implementation required");
    return nil;
}

+ (NSString *)commandUsage {
    NSMutableArray *    result;
    
    result = [[NSMutableArray alloc] init];
    for (Class subcommandClass in [self subcommandClasses]) {
        [result addObject:[subcommandClass commandUsage]];
    }
    return [result componentsJoinedByString:@"\n"];;
}

- (BOOL)validateOptionsAndArguments:(NSArray *)optionsAndArguments {
    BOOL        success;
    NSString *  subcommandName;
    NSArray *   subcommandArguments;
    
    success = [super validateOptionsAndArguments:optionsAndArguments];
    if (success) {
        success = (self.arguments.count != 0);      // must have enough for a subcommand
    }
    if (success) {
        subcommandName = self.arguments[0];
        subcommandArguments = [self.arguments subarrayWithRange:NSMakeRange(1, self.arguments.count - 1)];
        
        for (Class subcommandClass in [[self class] subcommandClasses]) {
            if ( [subcommandName isEqual:[subcommandClass commandName]] ) {
                self.subcommand = [[subcommandClass alloc] init];
                break;
            }
        }
        success = (self.subcommand != nil);
    }
    if (success) {
        success = [self.subcommand validateOptionsAndArguments:subcommandArguments];
    }
    
    return success;
}

- (BOOL)runError:(NSError **)errorPtr {
    assert(self.subcommand != nil);
    return [self.subcommand runError:errorPtr];
}

@end
