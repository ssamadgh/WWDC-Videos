//
//  GLTextureViewController.h
//  GLTextureAtlas
//
//  Created by Seyed Samad Gholamzadeh on 2/25/18.
//

#import <UIKit/UIKit.h>

@class EAGLView;

@interface GLTextureViewController : UIViewController
{
	EAGLView *glView;

}

@property (nonatomic, assign) IBOutlet EAGLView *glView;


@end
