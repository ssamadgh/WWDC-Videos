/*
     File: PlacemarkViewController.m
 Abstract: Displays the address data in the placemark acquired from the reverse geocoder.
  Version: 1.2
 
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

#import "PlacemarkViewController.h"


@implementation PlacemarkViewController

@synthesize placemark, tableView;

// used pressed the "Done" button
- (IBAction)done
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [tableView reloadData];
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 9;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kPlacemarkCellID = @"PlacemarkCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPlacemarkCellID];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:kPlacemarkCellID] autorelease];
    }
    
    CGRect frame = cell.textLabel.frame;
    frame.size.width = 200;
    cell.textLabel.frame = frame;
    
    switch (indexPath.row)
    {
        case 0:
        {
            cell.detailTextLabel.text = @"Thoroughfare";
            cell.textLabel.text = placemark.thoroughfare;
        } break;
        case 1:
        {
            cell.detailTextLabel.text = @"Sub-thoroughfare";
            cell.textLabel.text = placemark.subThoroughfare;
        } break;
        case 2:
        {
            cell.detailTextLabel.text = @"Locality";
            cell.textLabel.text = placemark.locality;
        } break;
        case 3:
        {
            cell.detailTextLabel.text = @"Sub-locality";
            cell.textLabel.text = placemark.subLocality;
        } break;
        case 4:
        {
            cell.detailTextLabel.text = @"Administrative Area";
            cell.textLabel.text = placemark.administrativeArea;
        } break;
        case 5:
        {
            cell.detailTextLabel.text = @"Sub-administrative Area";
            cell.textLabel.text = placemark.subAdministrativeArea;
        } break;
        case 6:
        {
            cell.detailTextLabel.text = @"Postal Code";
            cell.textLabel.text = placemark.postalCode;
        } break;
        case 7:
        {
            cell.detailTextLabel.text = @"Country";
            cell.textLabel.text = placemark.country;
        } break;
        case 8:
        {
            cell.detailTextLabel.text = @"Country Code";
            cell.textLabel.text = placemark.countryCode;
        } break;
        default:
        {
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = @"";
        } break;
    }
    
    return cell;
}

- (void)viewDidUnload
{
    self.tableView = nil;
}

- (void)dealloc
{
    [tableView release];
    [placemark release];
    
    [super dealloc];
}

@end

