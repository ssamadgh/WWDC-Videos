/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Controller to managed a picker view displaying imperial weights.
 */

#import "ImperialPickerController.h"

@interface ImperialPickerController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) IBOutlet UIPickerView *pickerView;
@property (nonatomic, strong) IBOutlet UILabel *label;

@end


#pragma mark -

@implementation ImperialPickerController

// Identifiers and widths for the various components.
#define POUNDS_COMPONENT 0
#define POUNDS_COMPONENT_WIDTH 110
#define POUNDS_LABEL_WIDTH 60

#define OUNCES_COMPONENT 1
#define OUNCES_COMPONENT_WIDTH 106
#define OUNCES_LABEL_WIDTH 56


// Identifies for component views.
#define VIEW_TAG 41
#define SUB_LABEL_TAG 42
#define LABEL_TAG 43

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	
	return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	
	// Number of rows depends on the currently-selected unit and the component.
    if (component == POUNDS_COMPONENT) {
		return 29;
	}
	// OUNCES_LABEL_COMPONENT
	return 16;
}

- (UIView *)labelCellWithWidth:(CGFloat)width rightOffset:(CGFloat)offset {
	
	// Create a new view that contains a label offset from the right.
	CGRect frame = CGRectMake(0.0, 0.0, width, 32.0);
	UIView *view = [[UIView alloc] initWithFrame:frame];
	view.tag = VIEW_TAG;
	
	frame.size.width = width - offset;
	UILabel *subLabel = [[UILabel alloc] initWithFrame:frame];
	subLabel.textAlignment = NSTextAlignmentRight;
	subLabel.backgroundColor = [UIColor clearColor];
	subLabel.font = [UIFont systemFontOfSize:24.0];
	subLabel.userInteractionEnabled = NO;
	
	subLabel.tag = SUB_LABEL_TAG;
	
	[view addSubview:subLabel];
	return view;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
	
	UIView *returnView = nil;
	
	// Reuse the label if possible, otherwise create and configure a new one.
	if ((view.tag == VIEW_TAG) || (view.tag == LABEL_TAG)) {
		returnView = view;
	}
	else {
        if (component == POUNDS_COMPONENT) {
            returnView = [self labelCellWithWidth:POUNDS_COMPONENT_WIDTH rightOffset:POUNDS_LABEL_WIDTH];
        }
        else {
            returnView = [self labelCellWithWidth:OUNCES_COMPONENT_WIDTH rightOffset:OUNCES_LABEL_WIDTH];
        }
	}
	
	// The text shown in the component is just the number of the component.
	NSString *text = [NSString stringWithFormat:@"%ld", (long)row];
	
	// Where to set the text in depends on what sort of view it is.
	UILabel *theLabel = nil;
	if (returnView.tag == VIEW_TAG) {
		theLabel = (UILabel *)[returnView viewWithTag:SUB_LABEL_TAG];
	}
	else {
		theLabel = (UILabel *)returnView;
	}
    
	theLabel.text = text;
	return returnView;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
	
	if (component == POUNDS_COMPONENT) {
		return POUNDS_COMPONENT_WIDTH;
	}
	// OUNCES_COMPONENT
	return OUNCES_COMPONENT_WIDTH;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
	// If the user chooses a new row, update the label accordingly.
	[self updateLabel];
}

- (void)updateLabel {

    /*
     If the user has entered imperial units, find the number of pounds and ounces and convert that to kilograms and grams.
     Don't display 0 kg.
     */
    NSInteger ounces = [self.pickerView selectedRowInComponent:OUNCES_COMPONENT];
    ounces += [self.pickerView selectedRowInComponent:POUNDS_COMPONENT] * 16;
    
    float grams = ounces * 28.349;
    if (grams > 1000.0) {
        NSInteger kg = grams / 1000;
        grams -= kg *1000;
        self.label.text = [NSString stringWithFormat:@"%ld kg  %1.0f g", (long)kg, grams];
    }
	else {
        self.label.text = [NSString stringWithFormat:@"%1.0f g", grams];
    }
}
	
@end
