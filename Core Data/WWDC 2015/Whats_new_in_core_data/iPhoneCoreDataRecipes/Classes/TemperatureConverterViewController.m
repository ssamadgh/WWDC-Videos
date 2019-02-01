/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 View controller to display cooking temperatures in Centigrade, Fahrenheit, and Gas Mark.
 */

#import "TemperatureConverterViewController.h"
#import "TemperatureCell.h"

@interface TemperatureConverterViewController ()

@property (nonatomic, strong) NSArray *temperatureData;

@end


#pragma mark -

@implementation TemperatureConverterViewController

static NSString *MyIdentifier = @"MyIdentifier";


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.temperatureData.count;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Create a new TemperatureCell.
    TemperatureCell *cell =
        (TemperatureCell *)[aTableView dequeueReusableCellWithIdentifier:MyIdentifier
                                                            forIndexPath:indexPath];
    
    // Configure the temperature cell with the relevant data.
    NSDictionary *temperatureDictionary = (self.temperatureData)[indexPath.row];
    [cell setTemperatureDataFromDictionary:temperatureDictionary];
    
    return cell;
}


#pragma mark - Temperature data

- (NSArray *)temperatureData {
	
	if (_temperatureData == nil) {
		// Get the temperature data from the TemperatureData property list.
		NSString *temperatureDataPath = [[NSBundle mainBundle] pathForResource:@"TemperatureData" ofType:@"plist"];
		NSArray *array = [[NSArray alloc] initWithContentsOfFile:temperatureDataPath];
		self.temperatureData = array;
	}
	return _temperatureData;
}


#pragma mark - Memory management

- (void)didReceiveMemoryWarning {
    
	[super didReceiveMemoryWarning];
	self.temperatureData = nil;
}

@end
