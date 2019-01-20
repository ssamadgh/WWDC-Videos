Running with a Snap
===================

This sample application demonstrates implementing some of the new features of iOS 7 in the context of a running/photo-taking app. This app uses UIImage templates, UIKit Dynamics, Custom View Controller transitions, Motion events and creates static blurs.

Interesting Methods
===================

-[EditPhotoViewController optionsTapped:]
    This method shows the usage of -[UIImage imageWithRenderingMode:] to convert images into template images

-[PhotoEditorViewController collectionView:didSelectItemAtIndexPath:]
    The entry point to creating a custom view controller presentation and dismissal. Also look at the classes DeletePhotoAnimator and PresentPhotoAnimator.

-[LaunchViewController _applyBackgroundToButton:sourceBlurFromView:]
    The buttons on the main screen have altitude and blur once a background has been set. This method adds both of those effects.

Interesting Classes
===================

DeletePhotoAnimator
FlipbookViewController
    Both of these classes make heavy use of UIKit Dynamics to add physics-like behaviors to animations.

LensFlareView
    A view that has two custom subclasses of UIMotionEffect that use motion effects to do more than just provide altitude to a view.

UIImage+ImageEffects.m
    A collection of recipes for creating the blur effect on images.