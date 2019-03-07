/*
     File: RecentSearchesController.h
 Abstract: A table view controller to manage and display a list of recent search strings.
 The search strings are stored in NSUserDefaults to maintain the list between launches of the application.
 The view controller manages two arrays:
 * recentSearches is the array that corresponds to the full set of recent search strings stored in user defaults.
 * displayedRecentSearches is an array derived from recent searches, filtered by the current search string (if any).
 
 The recentSearches array is kept synchronized with user defaults, and avoids the need to query user defaults every time the search string is updated.
 
 The table view displays the contents of the displayedRecentSearches array.
 
 The view controller has a delegate that it notifies if row in the table view is selected.
 
  Version: 1.4
 
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

#import <UIKit/UIKit.h>


extern NSString *RecentSearchesKey;

@class RecentSearchesController;


@protocol RecentSearchesDelegate
// Sent when the user selects a row in the recent searches list.
- (void)recentSearchesController:(RecentSearchesController *)controller didSelectString:(NSString *)searchString;
@end


@interface RecentSearchesController : UITableViewController <UIActionSheetDelegate> {
    id <RecentSearchesDelegate> delegate;
    
    NSArray *recentSearches;
    NSArray *displayedRecentSearches;
    
    UIBarButtonItem *clearButtonItem;
    
    UIActionSheet *confirmSheet;
}

@property (nonatomic, assign) id <RecentSearchesDelegate> delegate;
@property (nonatomic, retain) NSArray *recentSearches;
@property (nonatomic, retain) NSArray *displayedRecentSearches;

@property (nonatomic, retain) UIActionSheet *confirmSheet;

@property (nonatomic, retain) UIBarButtonItem *clearButtonItem;

- (void)addToRecentSearches:(NSString *)searchString;
- (void)filterResultsUsingString:(NSString *)filterString;

@end
