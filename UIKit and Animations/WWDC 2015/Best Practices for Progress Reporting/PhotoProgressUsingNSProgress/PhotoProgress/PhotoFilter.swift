/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
                PhotoFilter has a class function for returning a filtered image.
            
*/

import UIKit

class PhotoFilter {
    /// This supports implicit progress composition.
    class func filteredImage(_ image: UIImage) -> UIImage? {
        /*
            Set up the progress. First thing! It's indeterminate since we don't
            have any information about how long this is going to take.
            
            `NSProgress(totalUnitCount:)` convenience adds itself as a child to the currentProgress.
        */
        let progress = Progress(totalUnitCount: -1)
        progress.isCancellable = false
        progress.isPausable = false
        
        var outputImage: UIImage?
        
        if let filter = CIFilter(name: "CIPhotoEffectTransfer"), let cgImage = image.cgImage {
            let filterInput = CIImage(cgImage: cgImage)
            
            filter.setValue(filterInput, forKey: "inputImage")
            
            guard let filterOutput = filter.outputImage else { return outputImage }
            
            let context = CIContext(options: [:])
            let outputCGImage = context.createCGImage(filterOutput, from: filterOutput.extent)

            outputImage = UIImage(cgImage: outputCGImage!)
        }
        
        // We have finished.
        progress.completedUnitCount = 1
        progress.totalUnitCount = 1
        
        return outputImage
    }
}
