/*
     File: DailyTradeInfoSource.m 
 Abstract: The daily trade model data. 
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
  
 Copyright (C) 2011 Apple Inc. All Rights Reserved. 
  
 */

#import "DailyTradeInfoSource.h"
#import "DailyTradeInfo.h"

@implementation DailyTradeInfoSource
static NSArray *data = nil;
static NSArray *rawData = nil;

/*
 * return the static raw data, just strings.
 */
+ (NSArray *)rawData {
    if(nil == rawData) {
        rawData = [[NSArray alloc] initWithObjects:
                //Date           Open       High       Low        Close      Volume        Adj Close
                @"May 26, 2011", @"335.97", @"336.89", @"334.43", @"335.00", @"7,948,600", @"335.00",
                @"May 25, 2011", @"333.43", @"338.56", @"332.85", @"336.78", @"10,500,200", @"336.78",
                @"May 24, 2011", @"335.50", @"335.90", @"331.34", @"332.19", @"11,497,400", @"332.19",
                @"May 23, 2011", @"329.97", @"335.98", @"329.42", @"334.40", @"13,651,700", @"334.40",
                @"May 20, 2011", @"339.56", @"340.95", @"335.02", @"335.22", @"12,070,300", @"335.22",
                @"May 19, 2011", @"342.08", @"342.41", @"338.67", @"340.53", @"9,308,100", @"340.53",
                @"May 18, 2011", @"336.47", @"341.05", @"336.00", @"339.87", @"11,931,800", @"339.87",
                @"May 17, 2011", @"332.00", @"336.14", @"330.73", @"336.14", @"16,154,800", @"336.14",
                @"May 16, 2011", @"339.20", @"341.22", @"332.60", @"333.30", @"16,063,400", @"333.30",
                @"May 13, 2011", @"345.66", @"346.25", @"340.35", @"340.50", @"11,647,000", @"340.50",
                @"May 12, 2011", @"346.12", @"347.12", @"342.27", @"346.57", @"11,400,000", @"346.57",
                @"May 11, 2011", @"349.02", @"350.00", @"345.24", @"347.23", @"11,952,700", @"347.23",
                @"May 10, 2011", @"348.89", @"349.69", @"346.66", @"349.45", @"10,191,300", @"349.45",
                @"May 9, 2011", @"347.86", @"349.20", @"346.53", @"347.60", @"7,312,400", @"347.60",
                @"May 6, 2011", @"349.69", @"350.00", @"346.21", @"346.66", @"10,004,800", @"346.66",
                @"May 5, 2011", @"348.40", @"350.95", @"346.05", @"346.75", @"11,998,900", @"346.75",
                @"May 4, 2011", @"348.26", @"351.83", @"346.88", @"349.57", @"13,956,600", @"349.57",
                @"May 3, 2011", @"347.99", @"349.89", @"345.62", @"348.20", @"11,191,000", @"348.20",
                @"May 2, 2011", @"349.74", @"350.47", @"345.50", @"346.28", @"15,779,900", @"346.28",
                @"Apr 29, 2011", @"346.78", @"353.95", @"346.67", @"350.13", @"35,900,000", @"350.13",
                @"Apr 28, 2011", @"346.19", @"349.75", @"345.52", @"346.75", @"12,891,400", @"346.75",
                @"Apr 27, 2011", @"352.24", @"352.35", @"347.10", @"350.15", @"12,696,100", @"350.15",
                @"Apr 26, 2011", @"353.62", @"354.99", @"349.35", @"350.42", @"12,065,100", @"350.42",
                @"Apr 25, 2011", @"350.34", @"353.75", @"350.30", @"353.01", @"9,497,500", @"353.01",
                @"Apr 21, 2011", @"355.00", @"355.13", @"348.52", @"350.70", @"26,921,800", @"350.70",
                @"Apr 20, 2011", @"343.51", @"345.75", @"341.50", @"342.41", @"25,023,800", @"342.41",
                @"Apr 19, 2011", @"333.10", @"337.98", @"331.71", @"337.86", @"14,977,800", @"337.86",
                @"Apr 18, 2011", @"326.10", @"332.23", @"320.16", @"331.85", @"21,782,100", @"331.85",
                @"Apr 15, 2011", @"333.30", @"333.64", @"326.80", @"327.46", @"16,200,200", @"327.46",
                @"Apr 14, 2011", @"334.80", @"336.00", @"332.06", @"332.42", @"10,778,600", @"332.42",
                @"Apr 13, 2011", @"335.02", @"336.14", @"332.52", @"336.13", @"12,365,000", @"336.13",
                @"Apr 12, 2011", @"330.49", @"333.73", @"330.20", @"332.40", @"15,201,400", @"332.40",
                @"Apr 11, 2011", @"334.06", @"335.67", @"330.02", @"330.80", @"14,248,100", @"330.80",
                @"Apr 8, 2011", @"339.92", @"340.15", @"333.95", @"335.06", @"13,483,400", @"335.06",
                @"Apr 7, 2011", @"338.10", @"340.43", @"336.03", @"338.08", @"13,337,400", @"338.08",
                @"Apr 6, 2011", @"341.22", @"343.90", @"337.14", @"338.04", @"14,376,400", @"338.04",
                @"Apr 5, 2011", @"336.99", @"342.25", @"336.00", @"338.89", @"17,240,400", @"338.89",
                @"Apr 4, 2011", @"344.31", @"344.60", @"338.40", @"341.19", @"16,431,600", @"341.19",
                @"Apr 1, 2011", @"351.11", @"351.59", @"343.30", @"344.56", @"14,952,200", @"344.56",
                @"Mar 31, 2011", @"346.36", @"349.80", @"346.06", @"348.51", @"9,786,400", @"348.51",
                @"Mar 30, 2011", @"350.64", @"350.88", @"347.44", @"348.63", @"11,764,500", @"348.63",
                @"Mar 29, 2011", @"347.66", @"350.96", @"346.06", @"350.96", @"12,603,600", @"350.96",
                @"Mar 28, 2011", @"353.15", @"354.32", @"350.44", @"350.44", @"11,048,400", @"350.44",
                @"Mar 25, 2011", @"348.07", @"352.06", @"347.02", @"351.54", @"16,032,500", @"351.54",
                @"Mar 24, 2011", @"341.85", @"346.00", @"338.86", @"344.97", @"14,454,000", @"344.97",
                @"Mar 23, 2011", @"339.28", @"340.22", @"335.95", @"339.19", @"13,321,300", @"339.19",
                @"Mar 22, 2011", @"342.56", @"342.62", @"339.14", @"341.20", @"11,640,100", @"341.20",
                @"Mar 21, 2011", @"335.99", @"339.74", @"335.26", @"339.30", @"14,621,500", @"339.30",
                @"Mar 18, 2011", @"337.13", @"338.20", @"330.00", @"330.67", @"26,900,500", @"330.67",
                @"Mar 17, 2011", @"336.83", @"339.61", @"330.66", @"334.64", @"23,550,800", @"334.64",
                @"Mar 16, 2011", @"342.00", @"343.00", @"326.26", @"330.01", @"41,500,400", @"330.01",
                @"Mar 15, 2011", @"342.10", @"347.84", @"340.10", @"345.43", @"25,752,900", @"345.43",
                @"Mar 14, 2011", @"353.18", @"356.48", @"351.31", @"353.56", @"15,569,900", @"353.56",
                @"Mar 11, 2011", @"345.33", @"352.32", @"345.00", @"351.99", @"16,824,300", @"351.99",
                @"Mar 10, 2011", @"349.12", @"349.77", @"344.90", @"346.67", @"18,126,400", @"346.67",
                @"Mar 9, 2011", @"354.69", @"354.76", @"350.60", @"352.47", @"16,189,500", @"352.47",
                @"Mar 8, 2011", @"354.91", @"357.40", @"352.25", @"355.76", @"12,725,600", @"355.76",
                @"Mar 7, 2011", @"361.40", @"361.67", @"351.31", @"355.36", @"19,504,400", @"355.36",
                @"Mar 4, 2011", @"360.07", @"360.29", @"357.75", @"360.00", @"16,188,100", @"360.00",
                @"Mar 3, 2011", @"357.19", @"359.79", @"355.92", @"359.56", @"17,885,300", @"359.56",
                @"Mar 2, 2011", @"349.96", @"354.35", @"348.40", @"352.12", @"21,521,100", @"352.12",
                @"Mar 1, 2011", @"355.47", @"355.72", @"347.68", @"349.31", @"16,290,600", @"349.31",
                @"Feb 28, 2011", @"351.24", @"355.05", @"351.12", @"353.21", @"14,395,500", @"353.21",
                @"Feb 25, 2011", @"345.26", @"348.43", @"344.80", @"348.16", @"13,572,100", @"348.16", nil];
    }
    return rawData;
}

/*
 * Uses the static raw data, parses it into NSNumbers, NSDates etc then sorts it
 * using the compare method defined on DailyTradeInfo and returns the sorted data.
 */
+ (NSArray *)dailyTradeInfos {
    if(nil == data) {
        NSLocale *parsingLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:parsingLocale];
        [dateFormatter setDateFormat:@"MMM d, yyyy"];
        NSNumberFormatter *priceFormatter = [[NSNumberFormatter alloc] init];
        [priceFormatter setLocale:parsingLocale];
        [priceFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumberFormatter *volumeFormatter = [[NSNumberFormatter alloc] init];
        [volumeFormatter setLocale:parsingLocale];
        [volumeFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [volumeFormatter setPositiveFormat:@"###,###,###"];
        NSArray *raw = [self rawData];
        NSMutableArray *stockPrices = [NSMutableArray array];
        int count = [raw count];
        for(int i = 0;i < count;i += 7) {
            //Date           Open       High       Low        Close      Volume        Adj Close
            DailyTradeInfo *stock = [[DailyTradeInfo alloc] init];
            [stock setTradingDate:[dateFormatter dateFromString:[raw objectAtIndex:i]]];
            [stock setOpeningPrice:[priceFormatter numberFromString:[raw objectAtIndex:i + 1]]];
            [stock setHighPrice:[priceFormatter numberFromString:[raw objectAtIndex:i + 2]]];
            [stock setLowPrice:[priceFormatter numberFromString:[raw objectAtIndex:i + 3]]];
            [stock setClosingPrice:[priceFormatter numberFromString:[raw objectAtIndex:i + 4]]];
            [stock setTradingVolume:[volumeFormatter numberFromString:[raw objectAtIndex:i + 5]]];
            [stockPrices addObject:stock];
            [stock release];
        }
        data = [stockPrices sortedArrayUsingComparator:^(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        [data retain];
        [dateFormatter release];
        [priceFormatter release];
        [volumeFormatter release];
    }
    return data;
}

@end
