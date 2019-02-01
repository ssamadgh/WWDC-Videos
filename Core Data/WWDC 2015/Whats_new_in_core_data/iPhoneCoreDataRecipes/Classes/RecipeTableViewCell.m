/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A table view cell that displays information about a Recipe.  It uses individual subviews of its content view to show the name, picture, description, and preparation time for each recipe.  If the table view switches to editing mode, the cell reformats itself to move the preparation time off-screen, and resizes the name and description fields accordingly.
 */

#import "RecipeTableViewCell.h"

@interface RecipeTableViewCell ()

@property (nonatomic, strong) UIImageView *recipeImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *overviewLabel;
@property (nonatomic, strong) UILabel *prepTimeLabel;

@property (NS_NONATOMIC_IOSONLY, readonly) CGRect _imageViewFrame;
@property (NS_NONATOMIC_IOSONLY, readonly) CGRect _nameLabelFrame;
@property (NS_NONATOMIC_IOSONLY, readonly) CGRect _descriptionLabelFrame;
@property (NS_NONATOMIC_IOSONLY, readonly) CGRect _prepTimeLabelFrame;

@end


#pragma mark -

@implementation RecipeTableViewCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
	if (self = [super initWithCoder:aDecoder]) {
        _recipeImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		self.recipeImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.recipeImageView];
        
        _overviewLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.overviewLabel.font = [UIFont systemFontOfSize:12.0];
        self.overviewLabel.textColor = [UIColor darkGrayColor];
        self.overviewLabel.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:self.overviewLabel];
        
        _prepTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.prepTimeLabel.textAlignment = NSTextAlignmentRight;
        self.prepTimeLabel.font = [UIFont systemFontOfSize:12.0];
        self.prepTimeLabel.textColor = [UIColor blackColor];
        self.prepTimeLabel.highlightedTextColor = [UIColor whiteColor];
		self.prepTimeLabel.minimumScaleFactor = 7.0;
		self.prepTimeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.prepTimeLabel];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.nameLabel.font = [UIFont boldSystemFontOfSize:14.0];
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:self.nameLabel];
    }
    
    return self;
}

// To save space, the prep time label disappears during editing.
- (void)layoutSubviews {
    
    [super layoutSubviews];
	
    self.recipeImageView.frame = [self _imageViewFrame];
    self.nameLabel.frame = [self _nameLabelFrame];
    self.overviewLabel.frame = [self _descriptionLabelFrame];
    self.prepTimeLabel.frame = [self _prepTimeLabelFrame];
    if (self.editing) {
        self.prepTimeLabel.alpha = 0.0;
    } else {
        self.prepTimeLabel.alpha = 1.0;
    }
}


#define IMAGE_SIZE          42.0
#define EDITING_INSET       10.0
#define TEXT_LEFT_MARGIN    8.0
#define TEXT_RIGHT_MARGIN   5.0
#define PREP_TIME_WIDTH     80.0

// Returns the frame of the various subviews -- these are dependent on the editing state of the cell.
- (CGRect)_imageViewFrame {
    
    if (self.editing) {
        return CGRectMake(EDITING_INSET, 0.0, IMAGE_SIZE, IMAGE_SIZE);
    }
	else {
        return CGRectMake(0.0, 0.0, IMAGE_SIZE, IMAGE_SIZE);
    }
}

- (CGRect)_nameLabelFrame {
    
    if (self.editing) {
        return CGRectMake(IMAGE_SIZE + EDITING_INSET + TEXT_LEFT_MARGIN, 4.0, self.contentView.bounds.size.width - IMAGE_SIZE - EDITING_INSET - TEXT_LEFT_MARGIN, 16.0);
    }
	else {
        return CGRectMake(IMAGE_SIZE + TEXT_LEFT_MARGIN, 4.0, self.contentView.bounds.size.width - IMAGE_SIZE - TEXT_RIGHT_MARGIN * 2 - PREP_TIME_WIDTH, 16.0);
    }
}

- (CGRect)_descriptionLabelFrame {
    
    if (self.editing) {
        return CGRectMake(IMAGE_SIZE + EDITING_INSET + TEXT_LEFT_MARGIN, 22.0, self.contentView.bounds.size.width - IMAGE_SIZE - EDITING_INSET - TEXT_LEFT_MARGIN, 16.0);
    }
	else {
        return CGRectMake(IMAGE_SIZE + TEXT_LEFT_MARGIN, 22.0, self.contentView.bounds.size.width - IMAGE_SIZE - TEXT_LEFT_MARGIN, 16.0);
    }
}

- (CGRect)_prepTimeLabelFrame {
    
    CGRect contentViewBounds = self.contentView.bounds;
    return CGRectMake(contentViewBounds.size.width - PREP_TIME_WIDTH - TEXT_RIGHT_MARGIN, 4.0, PREP_TIME_WIDTH, 16.0);
}


#pragma mark - Recipe set accessor

- (void)setRecipe:(Recipe *)newRecipe {
    
    if (newRecipe != _recipe) {
        _recipe = newRecipe;
	}
	self.recipeImageView.image = _recipe.thumbnailImage;
	self.nameLabel.text = (_recipe.name.length > 0) ? _recipe.name : @"-";
	self.overviewLabel.text = (_recipe.overview != nil) ? _recipe.overview : @"-";
	self.prepTimeLabel.text = (_recipe.prepTime != nil) ? _recipe.prepTime : @"-";
}

@end
