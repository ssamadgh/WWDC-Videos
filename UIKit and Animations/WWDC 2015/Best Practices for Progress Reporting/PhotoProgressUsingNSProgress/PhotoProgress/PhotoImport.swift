/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
                PhotoImport represents the import operation of a Photo. It combines both the PhotoDownload and PhotoFilter operations.
            
*/

import UIKit

class PhotoImport: NSObject, ProgressReporting {
    // MARK: Properties

    var completionHandler: ((_ image: UIImage?, _ error: NSError?) -> Void)?

    let progress: Progress

    let download: PhotoDownload

    // MARK: Initializers

    init(URL: Foundation.URL) {
        progress = Progress()
        /* 
            This progress's children are weighted: The download takes up 90% 
            and the filter takes the remaining portion.
        */
        progress.totalUnitCount = 10

        download = PhotoDownload(URL: URL)
    }

    func start() {
        /*
            Use explicit composition to add the download's progress to ours,
            taking 9/10 units.
        */
        progress.addChild(download.progress, withPendingUnitCount: 9)

        download.completionHandler = { data, error in
            guard let imageData = data, let image = UIImage(data: imageData as Data) else {
                self.callCompletionHandler(image: nil, error: error)
                return
            }

            /*
                Make self.progress the currentProgress. Since the filteredImage
                supports implicit progress reporting, it will add its progress
                to ours.
            */
            self.progress.becomeCurrent(withPendingUnitCount: 1)
            let filteredImage = PhotoFilter.filteredImage(image)
            self.progress.resignCurrent()
            
            self.callCompletionHandler(image: filteredImage, error: nil)
        }

        download.start()
    }
    
    fileprivate func callCompletionHandler(image: UIImage?, error: NSError?) {
        completionHandler?(image, error)
        completionHandler = nil
    }
}
