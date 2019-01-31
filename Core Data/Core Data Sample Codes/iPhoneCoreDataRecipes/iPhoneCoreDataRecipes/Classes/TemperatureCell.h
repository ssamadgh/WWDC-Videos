/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A table view cell that displays temperature in Centigrade, Fahrenheit, and Gas Mark.
 */

@interface TemperatureCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *cLabel;
@property (nonatomic, strong) IBOutlet UILabel *fLabel;
@property (nonatomic, strong) IBOutlet UILabel *gLabel;

- (void)setTemperatureDataFromDictionary:(NSDictionary *)temperatureDictionary;

@end
