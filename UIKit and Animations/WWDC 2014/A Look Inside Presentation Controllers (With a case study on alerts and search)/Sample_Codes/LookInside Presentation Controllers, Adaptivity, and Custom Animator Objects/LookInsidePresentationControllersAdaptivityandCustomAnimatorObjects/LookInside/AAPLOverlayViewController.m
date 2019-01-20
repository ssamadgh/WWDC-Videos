/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  AAPLOverlayViewController implementation.
  
 */

#import "AAPLOverlayViewController.h"

@interface AAPLOverlayViewController ()
@property (nonatomic, strong) CIContext *context;
@property (nonatomic, strong) CIImage *baseCIImage;
@property (nonatomic, strong) CIFilter *colorControlsFilter;
@property (nonatomic, strong) CIFilter *hueAdjustFilter;
@end

@implementation AAPLOverlayViewController
{
    dispatch_queue_t processingQueue;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        [self setModalPresentationStyle:UIModalPresentationCustom];
        [self setup];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    foregroundContentView = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect effectForBlurEffect:blurEffect]];
    backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];

    [self configureViews];
}

- (void)configureCIObjects {
    if (!self.context) {
        self.context = [CIContext contextWithOptions:nil];
    }
    
    self.baseCIImage = [CIImage imageWithCGImage:[[[self photoView] image] CGImage]];
}

- (void)setPhotoView:(AAPLPhotoCollectionViewCell *)photoView {
    if (currentPhotoView != photoView) {
        currentPhotoView = photoView;
        
        [self configureCIObjects];
    }
}

- (void)sliderChanged:(id)sender
{
    CGFloat hue = [hueSlider value];
    CGFloat saturation = [saturationSlider value];
    CGFloat brightness = [brightnessSlider value];

    // Update labels

    [hueLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Hue: %f", @"Hue label format."), hue]];
    [saturationLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Saturation: %f", @"Saturation label format."), saturation]];
    [brightnessLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Brightness: %f", @"Brightness label format."), brightness]];

    // Apply effects to image
    
    dispatch_async(processingQueue, ^{
        if (!self.colorControlsFilter) {
            self.colorControlsFilter = [CIFilter filterWithName:@"CIColorControls"];
        }
        [self.colorControlsFilter setValue:self.baseCIImage forKey:kCIInputImageKey];
        [self.colorControlsFilter setValue:@(saturation) forKey:@"inputSaturation"];
        [self.colorControlsFilter setValue:@(brightness) forKey:@"inputBrightness"];
        
        CIImage *coreImageOutputImage = [self.colorControlsFilter valueForKey:kCIOutputImageKey];
        
        if (!self.hueAdjustFilter) {
            self.hueAdjustFilter = [CIFilter filterWithName:@"CIHueAdjust"];
        }
        [self.hueAdjustFilter setValue:coreImageOutputImage forKey:kCIInputImageKey];
        [self.hueAdjustFilter setValue:@(hue) forKey:@"inputAngle"];
        
        coreImageOutputImage = [self.hueAdjustFilter valueForKey:kCIOutputImageKey];
        
        CGImageRef cgImage = [self.context createCGImage:coreImageOutputImage fromRect:CGRectMake(0,0,[[[self photoView] image] size].width, [[[self photoView] image] size].height)];
        UIImage *image = [UIImage imageWithCGImage:cgImage];
        CGImageRelease(cgImage);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [imageView setImage:image];
        });
    });
    
}

- (void)savePushed:(id)sender
{
    [[self photoView] setImage:[imageView image]];
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:NULL];
}

- (UISlider *)configuredOverlaySlider
{
    UISlider *slider = [[UISlider alloc] init];
    [slider setTranslatesAutoresizingMaskIntoConstraints:NO];
    [slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [slider setContinuous:NO];
    return slider;
}

- (void)setup
{
    imageView = [[UIImageView alloc] init];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    
    processingQueue = dispatch_queue_create("image processing queue", DISPATCH_QUEUE_SERIAL);
}

- (void)configureViews
{
    [imageView setImage:[[self photoView] image]];
    [[self view] setBackgroundColor:[UIColor clearColor]];

    [backgroundView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [foregroundContentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    hueLabel = [[AAPLOverlayVibrantLabel alloc] init];
    hueSlider = [self configuredOverlaySlider];
    [hueSlider setMaximumValue:10.0];

    saturationLabel = [[AAPLOverlayVibrantLabel alloc] init];
    saturationSlider = [self configuredOverlaySlider];
    [saturationSlider setValue:1.0];
    [saturationSlider setMaximumValue:2.0];
    
    brightnessLabel = [[AAPLOverlayVibrantLabel alloc] init];
    brightnessSlider = [self configuredOverlaySlider];
    [brightnessSlider setMinimumValue:-0.5];
    [brightnessSlider setMaximumValue:0.5];

    saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [saveButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [saveButton setTitle:NSLocalizedString(@"Save", @"Save button title.") forState:UIControlStateNormal];
    [[saveButton titleLabel] setFont:[UIFont systemFontOfSize:32.0]];
    [saveButton addTarget:self action:@selector(savePushed:) forControlEvents:UIControlEventTouchUpInside];
    
    [[self view] addSubview:backgroundView];
    [[self view] addSubview:foregroundContentView];

    [[foregroundContentView contentView] addSubview:hueLabel];
    [[foregroundContentView contentView] addSubview:hueSlider];

    [[foregroundContentView contentView] addSubview:saturationLabel];
    [[foregroundContentView contentView] addSubview:saturationSlider];

    [[foregroundContentView contentView] addSubview:brightnessLabel];
    [[foregroundContentView contentView] addSubview:brightnessSlider];

    [[foregroundContentView contentView] addSubview:saveButton];

    [[self view] addSubview:imageView];
    
    // add constraints
    NSDictionary *views = NSDictionaryOfVariableBindings(backgroundView, foregroundContentView, hueLabel, hueSlider, saturationLabel, saturationSlider, brightnessLabel, brightnessSlider, saveButton, imageView);
    
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backgroundView]|" options:0 metrics:nil views:views]];
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundView]|" options:0 metrics:nil views:views]];
    
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[foregroundContentView]|" options:0 metrics:nil views:views]];
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[foregroundContentView]|" options:0 metrics:nil views:views]];
    
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[hueLabel]-|" options:0 metrics:nil views:views]];
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[hueSlider]-|" options:0 metrics:nil views:views]];
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[saturationLabel]-|" options:0 metrics:nil views:views]];
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[saturationSlider]-|" options:0 metrics:nil views:views]];
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[brightnessLabel]-|" options:0 metrics:nil views:views]];
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[brightnessSlider]-|" options:0 metrics:nil views:views]];
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[saveButton]-|" options:0 metrics:nil views:views]];
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics:nil views:views]];
    
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=30)-[hueLabel]-[hueSlider]-[saturationLabel]-[saturationSlider]-[brightnessLabel]-[brightnessSlider]-[saveButton]-(>=10)-[imageView]|" options:0 metrics:nil views:views]];
    
    [self sliderChanged:nil];
}

@end

@implementation AAPLOverlayVibrantLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
    return self;
}

- (void)tintColorDidChange
{
    [self setTextColor:[self tintColor]];
}

@end
