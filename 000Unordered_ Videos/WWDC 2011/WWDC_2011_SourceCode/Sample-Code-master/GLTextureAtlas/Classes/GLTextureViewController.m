//
//  GLTextureViewController.m
//  GLTextureAtlas
//
//  Created by Seyed Samad Gholamzadeh on 2/25/18.
//

#import "GLTextureViewController.h"

@interface GLTextureViewController ()

@end

@implementation GLTextureViewController

@synthesize glView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	[glView startAnimation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [glView release];
    [super dealloc];
}
@end
