# Coverflow Implementation using UICollectionView

## What?

This is an iPhone project implementing Coverflow using iOS 6 UICollectionViews and a custom UICollectionViewLayout

Screenshot: [http://cloud.schwa.io/image/0z0N3A0e2b1l](http://cloud.schwa.io/image/0z0N3A0e2b1l)

View it in action here: [CollectionViewCoverFlow.mov](http://cloud.schwa.io/1120003t3N2Y)

Yes, Apple demoed this at WWDC but I think the interpolation technique I use is rather neat and allows you to easily adjust the layout and behavior of the layout.

## CInterpolator

CInterpolator objects are a little like CAKeyFrameAnimation objects except they're not necessarily time based. You can use them for (linear) key frame interpolation between any keys and values

## TODO

* The "Gloom" layer doesn't do a very good job with alpha backgrounds.
* Aliasing is very obvious on straight edges when rotation.
* Shadow needs to be longer to deal with perspective transform. See next item.
* Need to specify manually the Y position of cells so that we can force cells to draw offscreen (for shadows). Or just rely on UIKit's ability to not clip to bounds.
* Need to properly deal with aspect fill/fit images.
