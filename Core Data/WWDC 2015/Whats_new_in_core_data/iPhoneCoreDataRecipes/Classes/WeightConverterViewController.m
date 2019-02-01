/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 View controller to manage conversion of metric to imperial units of weight and vice versa.
  The controller uses two UIPicker objects to allow the user to select the weight in metric or imperial units.
 */

#import "WeightConverterViewController.h"

#import "MetricPickerController.h"
#import "ImperialPickerController.h"

@interface WeightConverterViewController ()

@property (nonatomic, strong) IBOutlet UIView *pickerViewContainer;

@property (nonatomic, strong) IBOutlet MetricPickerController *metricPickerController;
@property (nonatomic, strong) IBOutlet UIView *metricPickerViewContainer;

@property (nonatomic, strong) IBOutlet ImperialPickerController *imperialPickerController;
@property (nonatomic, strong) IBOutlet UIView *imperialPickerViewContainer;

@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic, assign) NSUInteger selectedUnit;

@end


#pragma mark -

@implementation WeightConverterViewController

#define METRIC_INDEX 0
#define IMPERIAL_INDEX 1

- (void)viewDidLoad {
    
	[super viewDidLoad];
		
	// Set the currently-selected unit for self and the segmented control.
	self.selectedUnit = METRIC_INDEX;
	self.segmentedControl.selectedSegmentIndex = self.selectedUnit;
	
	[self toggleUnit];
}

- (IBAction)toggleUnit {
	
	/*
	 When the user changes the selection in the segmented control, set the appropriate picker as the current subview of the picker container view (and remove the previous one).
	 */
	_selectedUnit = self.segmentedControl.selectedSegmentIndex;
	if (self.selectedUnit == IMPERIAL_INDEX) {
		[self.metricPickerViewContainer removeFromSuperview];
		[self.pickerViewContainer addSubview:self.imperialPickerViewContainer];
		[self.imperialPickerController updateLabel];
	} else {
		[self.imperialPickerViewContainer removeFromSuperview];
		[self.pickerViewContainer addSubview:self.metricPickerViewContainer];
		[self.metricPickerController updateLabel];
	}
}

@end

