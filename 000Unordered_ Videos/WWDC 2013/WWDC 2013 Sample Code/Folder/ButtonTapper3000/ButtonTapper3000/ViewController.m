//
//  ViewController.m
//  ButtonTapper3000
//
//  Created by Megan Gardner on 5/29/13.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import "ViewController.h"
#import "BTTMainMenu.h"

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated {
    SKScene *scene = [BTTMainMenu sceneWithSize:self.view.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;

    [self.skView presentScene:scene];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}
@end
