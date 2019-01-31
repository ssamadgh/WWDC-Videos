
/*
     File: APLNormalizedStringTransformer.m
 Abstract: Value transformer subclass for normalizing string data.
 
  Version: 1.3
 
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

#import <CoreFoundation/CFString.h>
#import "APLNormalizedStringTransformer.h"


static NSPredicate *predicateTemplate;


@implementation APLNormalizedStringTransformer

+ (void)initialize
{
    /*
    Pre-parse predicate for quick substitution in reverseTransformedValue: instead of using a 'contains' operator, we simplify the predicate using a check between a high and low bound this allows us to potentially use indexes.
     */
    predicateTemplate = [NSPredicate predicateWithFormat:@"normalizedText >= $lowBound and normalizedText < $highBound"];
}


+ (Class)transformedValueClass 
{ 
    return [NSPredicate class]; 
} 


+ (BOOL)allowsReverseTransformation 
{ 
    return YES; 
} 


- (id)transformedValue:(id)value 
{ 
    // The search field in the nib calls the reverse transform function.
    return value;
}


+ (NSString *)normalizeString:(NSString *)unprocessedValue
{
    if (!unprocessedValue) return nil;
    
    NSMutableString *result = [NSMutableString stringWithString:unprocessedValue];
    
    CFStringNormalize((CFMutableStringRef)result, kCFStringNormalizationFormD);
    CFStringFold((CFMutableStringRef)result, kCFCompareCaseInsensitive | kCFCompareDiacriticInsensitive | kCFCompareWidthInsensitive, NULL);

    return result;
}


// Calculates the next lexically ordered string guaranteed to be greater than text.
+ (NSString *)upperBoundSearchString:(NSString*)text
{
    NSUInteger length = [text length];
    NSString *baseString = nil;
    NSString *incrementedString = nil;
    
    if (length < 1) {
        return text;
    } else if (length > 1) {
        baseString = [text substringToIndex:(length-1)];
    } else {
        baseString = @"";
    }
    UniChar lastChar = [text characterAtIndex:(length-1)];
    UniChar incrementedChar;
    
    // Don't do a simple lastChar + 1 operation here without taking into account
    // unicode surrogate characters (http://unicode.org/faq/utf_bom.html#34).
    
    if ((lastChar >= 0xD800UL) && (lastChar <= 0xDBFFUL)) {         // surrogate high character
        incrementedChar = (0xDBFFUL + 1);
    } else if ((lastChar >= 0xDC00UL) && (lastChar <= 0xDFFFUL)) {  // surrogate low character
        incrementedChar = (0xDFFFUL + 1);
    } else if (lastChar == 0xFFFFUL) {
        if (length > 1 ) baseString = text;
        incrementedChar =  0x1;
    } else {
        incrementedChar = lastChar + 1;
    }
    
    incrementedString = [[NSString alloc] initWithFormat:@"%@%C", baseString, incrementedChar];
    
    return incrementedString;
}


- (id)reverseTransformedValue:(id)value
{
    if (!value) return nil;
    
    NSString *searchString = [[value rightExpression] constantValue];
    NSString *lowBound = [[self class] normalizeString:searchString];
    NSString *highBound = [[self class] upperBoundSearchString:lowBound];
    
    NSDictionary *bindVariables = @{ @"lowBound" : lowBound, @"highBound" : highBound };
    
    NSPredicate *result = [predicateTemplate predicateWithSubstitutionVariables:bindVariables];

    return result;
}


@end
