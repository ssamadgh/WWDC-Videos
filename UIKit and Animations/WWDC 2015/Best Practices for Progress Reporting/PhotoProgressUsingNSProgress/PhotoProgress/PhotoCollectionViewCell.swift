/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
                PhotoCollectionViewCell is a UICollectionViewCell subclass that shows a Photo.
            
*/

import UIKit

/// The KVO context used for all `PhotoCollectionViewCell` instances.
private var photoCollectionViewCellObservationContext = 0

class PhotoCollectionViewCell: UICollectionViewCell {
    // MARK: Properties

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var progressView: UIProgressView!

    fileprivate let fractionCompletedKeyPath = "photoImport.progress.fractionCompleted"

    fileprivate let imageKeyPath = "image"
    
    var photo: Photo? {
        willSet {
            if let formerPhoto = photo {
                formerPhoto.removeObserver(self, forKeyPath: fractionCompletedKeyPath, context: &photoCollectionViewCellObservationContext)
                formerPhoto.removeObserver(self, forKeyPath: imageKeyPath, context: &photoCollectionViewCellObservationContext)
            }
        }

        didSet {
            if let newPhoto = photo {
                newPhoto.addObserver(self, forKeyPath: fractionCompletedKeyPath, options: [], context: &photoCollectionViewCellObservationContext)
                newPhoto.addObserver(self, forKeyPath: imageKeyPath, options: [], context: &photoCollectionViewCellObservationContext)
            }

            updateImageView()
            updateProgressView()
        }
    }
    
    fileprivate func updateProgressView() {
        if let photoImport = photo?.photoImport {
            let fraction = Float(photoImport.progress.fractionCompleted)
            progressView.progress = fraction
            
            progressView.isHidden = false
        }
        else {
            progressView.isHidden = true
        }
    }

    fileprivate func updateImageView() {
        UIView.transition(with: imageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.imageView.image = self.photo?.image
        }, completion: nil)
    }
    
    // MARK: Key-Value Observing
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &photoCollectionViewCellObservationContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        OperationQueue.main.addOperation {
            if keyPath == self.fractionCompletedKeyPath {
                self.updateProgressView()
            }
            else if keyPath == self.imageKeyPath {
                self.updateImageView()
            }
        }
    }
}
