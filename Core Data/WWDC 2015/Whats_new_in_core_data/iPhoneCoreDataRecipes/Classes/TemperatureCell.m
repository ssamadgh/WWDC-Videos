/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A table view cell that displays temperature in Centigrade, Fahrenheit, and Gas Mark.
 */

#import "TemperatureCell.h"

@implementation TemperatureCell

- (void)setTemperatureDataFromDictionary:(NSDictionary *)temperatureDictionary {
    
    // Update text in labels from the dictionary.
    self.cLabel.text = temperatureDictionary[@"c"];
    self.fLabel.text = temperatureDictionary[@"f"];
    self.gLabel.text = temperatureDictionary[@"g"];
}

@end
