/*
     File: SimpleStockViewController.m 
 Abstract: This view controller handles orientation changes and acts as the data source for SimpleStockView. 
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

#import "SimpleStockViewController.h"
#import "DailyTradeInfoSource.h"
#import "SimpleStockView.h"

@implementation SimpleStockViewController

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [(SimpleStockView *)[self view] setDataSource:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	BOOL flag = NO;
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		flag = YES;
	} else {
		if(UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
			flag = YES;
		}
	}
	return flag;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [[self view] setNeedsDisplay];
}

#pragma mark GraphViewDataSource methods

// these methods should be using Core Data rather than a simple in memory
// array, but this sample is focused on 

/*
 * return the number of model objects that will contribute to the graph
 */
- (NSInteger)graphViewDailyTradeInfoCount:(SimpleStockView *)graphView {
    return [[DailyTradeInfoSource dailyTradeInfos] count];
}

/*
 * return the month names to be drawn
 */
- (NSArray *)graphViewSortedMonths:(SimpleStockView *)graphView {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSArray *closingDates = [[DailyTradeInfoSource dailyTradeInfos] valueForKeyPath:@"tradingDate"];
    __block NSCountedSet *months = [NSCountedSet set];
    [closingDates enumerateObjectsUsingBlock:^(id closingDate, NSUInteger index, BOOL *stop) {
        [months addObject:[calendar components:NSCalendarUnitMonth fromDate:closingDate]];
    }];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"month" ascending:YES];
    NSArray *descriptors = [NSArray arrayWithObject:descriptor];
    return [months sortedArrayUsingDescriptors:descriptors];
}

/*
 * For the given month (in components) return the number of trades
 * some months have 20 trading days, some have 23
 * this method makes it possible for us to layout the months names accordingly
 */
- (NSInteger)graphView:(SimpleStockView *)graphView tradeCountForMonth:(NSDateComponents *)components {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSArray *closingDates = [[DailyTradeInfoSource dailyTradeInfos] valueForKeyPath:@"tradingDate"];
    __block NSCountedSet *months = [NSCountedSet set];
    [closingDates enumerateObjectsUsingBlock:^(id closingDate, NSUInteger index, BOOL *stop) {
        [months addObject:[calendar components:NSMonthCalendarUnit fromDate:closingDate]];
    }];
    return [months countForObject:components];
}

/*
 * Return the model objects
 */
- (NSArray *)graphViewDailyTradeInfos:(SimpleStockView *)graphView {
    return [DailyTradeInfoSource dailyTradeInfos];
}

/*
 * Return the max closing price
 */
- (CGFloat)graphViewMaxClosingPrice:(SimpleStockView *)graphView {
    return [[[DailyTradeInfoSource dailyTradeInfos] valueForKeyPath:@"@max.closingPrice"] floatValue];
}

/*
 * Return the min closing price
 */
- (CGFloat)graphViewMinClosingPrice:(SimpleStockView *)graphView {
    return [[[DailyTradeInfoSource dailyTradeInfos] valueForKeyPath:@"@min.closingPrice"] floatValue];
}

/*
 * Return the max trading volume
 */
- (CGFloat)graphViewMaxTradingVolume:(SimpleStockView *)graphView {
    return [[[DailyTradeInfoSource dailyTradeInfos] valueForKeyPath:@"@max.tradingVolume"] floatValue];
}

/*
 * Return the min trading volume
 */
- (CGFloat)graphViewMinTradingVolume:(SimpleStockView *)graphView {
    return [[[DailyTradeInfoSource dailyTradeInfos] valueForKeyPath:@"@min.tradingVolume"] floatValue];
}

@end
