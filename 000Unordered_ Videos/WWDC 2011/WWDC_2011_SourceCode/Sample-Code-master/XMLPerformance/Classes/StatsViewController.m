/*
     File: StatsViewController.m
 Abstract: Displays statistics about each parser, including its average time to download the XML data, parse it, and the total average time from beginning the download to completing the parse.
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
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
*/

#import "StatsViewController.h"
#import "Statistics.h"
#import "CocoaXMLParser.h"
#import "LibXMLParser.h"

@implementation StatsViewController

@synthesize tableView;

- (void)dealloc {
    [tableView release];
	[super dealloc];
}

- (void)viewDidLoad {
    // We use a slightly shorter than usual row height so that all the statistics fit on the page without scrolling.
    // This should be used cautiously, as it can easily result in a user interface that provides a bad experience. It is
    // acceptable here partly because the table does not support any user interaction.
    // 
    // This could also be achieved using the UITableViewDelegate method tableView:heightForRowAtIndexPath:
    // However, this comes with a performance penalty, as it is called for each row in the table. Unless the rows
    // need to be of varying heights, the rowHeight property should be used.
    tableView.allowsSelection = NO;
    tableView.rowHeight = 31;
}

- (void)viewDidUnload {
    self.tableView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kStatisticsCellID = @"StatisticsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kStatisticsCellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kStatisticsCellID] autorelease];
    }
    switch (indexPath.row) {
        case 0: {
            cell.textLabel.text = NSLocalizedString(@"Mean Download Time", @"Mean Download Time format");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.4fs", MeanDownloadTimeForParserType(indexPath.section)];
        } break;
        case 1: {
            cell.textLabel.text = NSLocalizedString(@"Mean Parse Time", @"Mean Parse Time format");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.4fs", MeanParseTimeForParserType(indexPath.section)];
        } break;
        case 2: {
            cell.textLabel.text = NSLocalizedString(@"Mean Total Time", @"Mean Total Time format");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.4fs", MeanTotalTimeForParserType(indexPath.section)];
        } break;
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section {
    NSUInteger numberOfRuns = NumberOfRunsForParserType(section);
    NSString *parserName = (section == 0) ? [CocoaXMLParser parserName] : [LibXMLParser parserName];
    NSString *format = (numberOfRuns == 1) ? NSLocalizedString(@"%@ (%d run):", @"One Run format") : NSLocalizedString(@"%@ (%d runs):", @"Multiple Runs format");
    return [NSString stringWithFormat:format, parserName, numberOfRuns];
}

- (IBAction)resetStatistics {
    ResetStatisticsDatabase();
    [tableView reloadData];
}

@end
