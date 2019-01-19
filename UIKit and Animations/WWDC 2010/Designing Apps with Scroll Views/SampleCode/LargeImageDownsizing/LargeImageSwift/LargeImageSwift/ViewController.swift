//
//  ViewController.swift
//  LargeImageSwift
//
//  Created by Seyed Samad Gholamzadeh on 1/7/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

/* Image Constants: for images, we define the resulting image
size and tile size in megabytes. This translates to an amount
of pixels. Keep in mind this is almost always significantly different
from the size of a file on disk for compressed formats such as png, or jpeg.

For an image to be displayed in iOS, it must first be uncompressed (decoded) from
disk. The approximate region of pixel data that is decoded from disk is defined by both,
the clipping rect set onto the current graphics context, and the content/image
offset relative to the current context.

To get the uncompressed file size of an image, use: Width x Height / pixelsPerMB, where
pixelsPerMB = 262144 pixels in a 32bit colospace (which iOS is optimized for).

Supported formats are: PNG, TIFF, JPEG. Unsupported formats: GIF, BMP, interlaced images.
*/
let imageFilename = "large_leaves_70mp.jpg" // 7033x10110 image, 271 MB uncompressed
//let imageFilename = "shakira-7216x5412-4k-8k-10079.jpg" // 7033x10110 image, 271 MB uncompressed

/* The arguments to the downsizing routine are the resulting image size, and
"tile" size. And they are defined in terms of megabytes to simplify the correlation
between images and memory footprint available to your application.

The "tile" is the maximum amount of pixel data to load from the input image into
memory at one time. The size of the tile defines the number of iterations
required to piece together the resulting image.

Choose a resulting size for your image given both: the hardware profile of your
target devices, and the amount of memory taken by the rest of your application.

Maximizing the source image tile size will minimize the time required to complete
the downsize routine. Thus, performance must be balanced with resulting image quality.

Choosing appropriate resulting image size and tile size can be done, but is left as
an exercise to the developer. Note that the device type/version string
(e.g. "iPhone2,1" can be determined at runtime through use of the sysctlbyname function:

size_t size;
sysctlbyname("hw.machine", NULL, &size, NULL, 0);
char *machine = malloc(size);
sysctlbyname("hw.machine", machine, &size, NULL, 0);
NSString* _platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
free(machine);
*/

let destImageSizeMB: Int = 240 // The resulting image will be (x)MB of uncompressed image data.
let sourceImageTileSizeMB: Int = 80 // The tile size will be (x)MB of uncompressed image data.

/* Constants for all other iOS devices are left to be defined by the developer.
The purpose of this sample is to illustrate that device specific constants can
and should be created by you the developer, versus iterating a complete list. */

let bytesPerMB: Int = 1048576
let bytesPerPixel: Int = 4
let pixelsPerMB = ( bytesPerMB / bytesPerPixel ) // 262144 pixels, for 4 bytes per pixel.
let destTotalPixels = destImageSizeMB * pixelsPerMB
let tileTotalPixels = sourceImageTileSizeMB * pixelsPerMB
let destSeamOverlap: Float = 2 // the numbers of pixels to overlap the seams where tiles meet.


import UIKit

class ViewController: UIViewController {
	
	// The input image file
	var sourceImage: UIImage!
	
	// output image file
	// destImage property is specifically thread safe (i.e. no 'nonatomic' attribute)
	// because it is accessed off the main thread.
	var destImage: UIImage!
	
	// sub rect of the input image bounds that represents the
	// maximum amount of pixel data to load into mem at one time.
	var sourceTile: CGRect!
	
	// sub rect of the output image that is proportionate to the
	// size of the sourceTile.
	var destTile: CGRect!
	
	// the ratio of the size of the input image to the output image.
	var imageScale: CGFloat!
	
	// source image width and height
	var sourceResolution: CGSize!
	
	// total number of pixels in the source image
	var sourceTotalPixels: CGFloat!
	
	// total number of megabytes of uncompressed pixel data in the source image.
	var sourceTotalMB: CGFloat!
	
	// output image width and height
	var destResolution: CGSize!
	
	/* the temporary container used to hold the resulting output image pixel
	 data, as it is being assembled. */
	var destContext: CGContext!
	
	// the number of pixels to overlap tiles as they are assembled.
	var sourceSeamOverlap: CGFloat!
	
	// an image view to visualize the image as it is being pieced together
	var progressView: UIImageView!
	
	// a scroll view to display the resulting downsized image
	var scrollView: ImageScrollView!
	
	
	//MARK: - View lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		//--
		self.progressView = UIImageView(frame: self.view.bounds)
		self.progressView.contentMode = .scaleAspectFit
		self.view.addSubview(self.progressView)

		Thread.detachNewThreadSelector(#selector(downSize), toTarget: self, with: nil)

//		self.useSourceImage()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		

	}
	
	
	@objc func useSourceImage() {
		let path = Bundle.main.path(forResource: imageFilename, ofType: nil)!
//		self.sourceImage = UIImage(contentsOfFile: path)
		self.sourceImage = UIImage(named: imageFilename)
		self.scrollView = ImageScrollView(frame: self.view.bounds, image: self.sourceImage)
		self.view.addSubview(self.scrollView)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
		print("Memory warning")
	}
	
	@objc func downSize() {
		// create an autorelease pool to catch calls to -autorelease.
		autoreleasepool {
			
			// create an image from the image filename constant. Note this
			//  doesn't actually read any pixel information from disk, as that
			// is actually done at draw time.
			let path = Bundle.main.path(forResource: imageFilename, ofType: nil)!
			self.sourceImage = UIImage(contentsOfFile: path)
			if self.sourceImage == nil { print("input image not found!") }
			
			// get the width and height of the input image using
			// core graphics image helper functions.
			self.sourceResolution = CGSize(width: CGFloat(self.sourceImage.cgImage!.width), height: CGFloat(self.sourceImage.cgImage!.height))
			
			// use the width and height to calculate the total number of pixels
			// in the input image.
			self.sourceTotalPixels = self.sourceResolution.width * self.sourceResolution.height
			
			// calculate the number of MB that would be required to store
			// this image uncompressed in memory.
			self.sourceTotalMB = sourceTotalPixels / CGFloat(pixelsPerMB)
			
			// determine the scale ratio to apply to the input image
			// that results in an output image of the defined size.
			// see destImageSizeMB, and how it relates to destTotalPixels.
			
//			self.imageScale = CGFloat(destTotalPixels) / sourceTotalPixels
			
			self.imageScale = 1
			
			// use the image scale to calcualte the output image width, height
			self.destResolution = CGSize(width: sourceResolution.width * imageScale, height: sourceResolution.height * imageScale)
			
			// create an offscreen bitmap context that will hold the output image
			// pixel data, as it becomes available by the downscaling routine.
			// use the RGB colorspace as this is the colorspace iOS GPU is optimized for.
			let colorSpace = CGColorSpaceCreateDeviceRGB()
			let bytesPerRow = bytesPerPixel * Int(destResolution.width)
			
			// allocate enough pixel data to hold the output image.
			let destBitmapData = UnsafeMutableRawPointer(bitPattern: bytesPerRow * Int(destResolution.height))
			if destBitmapData == nil { print("failed to allocate space for the output image!") }
			
			// create the output bitmap context
			self.destContext = CGContext(data: nil, width: Int(destResolution.width), height: Int(destResolution.height), bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
			
			// remember CFTypes assign/check for NULL. NSObjects assign/check for nil.
			if destContext == nil {
				print("failed to create the output bitmap context!");
			}

			// flip the output graphics context so that it aligns with the
			// cocoa style orientation of the input document. this is needed
			// because we used cocoa's UIImage -imageNamed to open the input file.
			destContext.translateBy(x: 0, y: destResolution.height)
			destContext.scaleBy(x: 1, y: -1)
			
			// now define the size of the rectangle to be used for the
			// incremental blits from the input image to the output image.
			// we use a source tile width equal to the width of the source
			// image due to the way that iOS retrieves image data from disk.
			// iOS must decode an image from disk in full width 'bands', even
			// if current graphics context is clipped to a subrect within that
			// band. Therefore we fully utilize all of the pixel data that results
			// from a decoding opertion by anchoring our tile size to the full
			// width of the input image.
			sourceTile = CGRect.zero
			sourceTile.size.width = sourceResolution.width
			
			// the source tile height is dynamic. Since we specified the size
			// of the source tile in MB, see how many rows of pixels height
			// can be given the input image width.
			sourceTile.size.height = floor(CGFloat(tileTotalPixels) / sourceTile.size.width)
			print("source tile size: \(sourceTile.size.width) x \(sourceTile.size.height)")
//			sourceTile.origin.x = 0.0
			
			// the output tile is the same proportions as the input tile, but
			// scaled to image scale.
			destTile = CGRect.zero
			destTile.size.width = destResolution.width
			destTile.size.height = sourceTile.size.height * imageScale
//			destTile.origin.x = 0.0
			
			print("source tile size: \(sourceTile.size.width) x \(sourceTile.size.height)")
			
			// the source seam overlap is proportionate to the destination seam overlap.
			// this is the amount of pixels to overlap each tile as we assemble the ouput image.
			sourceSeamOverlap = floor((CGFloat(destSeamOverlap) / destResolution.height) * sourceResolution.height)
			print("dest seam overlap: \(destSeamOverlap), source seam overlap: \(sourceSeamOverlap!)")
			
			var sourceTileImage: CGImage!
			
			// calculate the number of read/write opertions required to assemble the
			// output image.
			var iterations = Int(sourceResolution.height / sourceTile.height)
			
			// if tile height doesn't divide the image height evenly, add another iteration
			// to account for the remaining pixels.
			let remainder = Int(sourceResolution.height.truncatingRemainder(dividingBy: sourceTile.size.height))
			if remainder != 0 {
				iterations += 1
			}
			
			// add seam overlaps to the tiles, but save the original tile height for y coordinate calculations.
			let sourceTileHeightMinusOverlap = sourceTile.size.height
			sourceTile.size.height += sourceSeamOverlap
			destTile.size.height += CGFloat(destSeamOverlap)
			
			print("beginning downsize. iterations: \(iterations), tile height: \(sourceTile.size.height), remainder height: \(remainder)")
			
			for y in 0..<iterations {
				
				// create an autorelease pool to catch calls to -autorelease made within the downsize loop.
				autoreleasepool {

					print("iteration \(y+1) of \(iterations)")
					
					sourceTile.origin.y = CGFloat(y) * sourceTileHeightMinusOverlap + CGFloat(sourceSeamOverlap)
					destTile.origin.y = (destResolution.height ) - ( ( CGFloat(y) + 1 ) * sourceTileHeightMinusOverlap * imageScale + CGFloat(destSeamOverlap))
					
					// create a reference to the source image with its context clipped to the argument rect.
					sourceTileImage = sourceImage.cgImage?.cropping(to: sourceTile)
					
					// if this is the last tile, it's size may be smaller than the source tile height.
					// adjust the dest tile size to account for that difference.
					if y == iterations - 1 && remainder != 0 {
						var dify = destTile.size.height
						destTile.size.height = CGFloat(sourceTileImage.height) * imageScale
						dify -= destTile.size.height
						destTile.origin.y += dify
					}
					
					// read and write a tile sized portion of pixels from the input image to the output image.
					destContext.draw(sourceTileImage, in: destTile)
					
					/* release the source tile portion pixel data. note,
					releasing the sourceTileImageRef doesn't actually release the tile portion pixel
					data that we just drew, but the call afterward does. */
					
					/* while CGImageCreateWithImageInRect lazily loads just the image data defined by the argument rect,
					that data is finally decoded from disk to mem when CGContextDrawImage is called. sourceTileImageRef
					maintains internally a reference to the original image, and that original image both, houses and
					caches that portion of decoded mem. Thus the following call to release the source image. */
					
					// free all objects that were sent -autorelease within the scope of this loop.
				}
				
				// we reallocate the source image after the pool is drained since UIImage -imageNamed
				// returns us an autoreleased object.
				if y < iterations - 1  {
					if let path = Bundle.main.path(forResource: imageFilename, ofType: nil) {
						sourceImage = UIImage(contentsOfFile: path)
					}
					self.performSelector(onMainThread: #selector(updateScrollView), with: nil, waitUntilDone: true)
				}
			}
			
			print("downsize complete.")
			
			self.performSelector(onMainThread: #selector(initializeScrollView), with: nil, waitUntilDone: true)
		}
	}
	
	func createImageFromContext() {
		// create a CGImage from the offscreen image context
		var destImageRef = self.destContext.makeImage()
		if destImageRef == nil { print("destImage is nil.") }
		
		// wrap a UIImage around the CGImage
		self.destImage = UIImage(cgImage: destImageRef!, scale: 1, orientation: UIImageOrientation.downMirrored)
		destImageRef = nil
		// release ownership of the CGImage, since destImage retains ownership of the object now.
		if destImage == nil { print("destImage is nil.") }
	}
	
	
	@objc func updateScrollView() {
		self.createImageFromContext()
		// display the output image on the screen.
		self.progressView.image = destImage
	}
	
	@objc func initializeScrollView() {
		self.progressView.removeFromSuperview()
		self.createImageFromContext()
		
		self.destContext = nil
		self.progressView = nil
		
		// create a scroll view to display the resulting image.
		self.scrollView = ImageScrollView(frame: self.view.bounds, image: self.destImage)
		self.view.addSubview(self.scrollView)
		
		self.destImage = nil
	}
	
	
	
}

