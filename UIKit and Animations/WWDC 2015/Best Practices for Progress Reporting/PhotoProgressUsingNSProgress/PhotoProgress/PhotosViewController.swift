/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
                PhotosViewController is our root UIViewController which is responsible for showing the overall progress and a tool bar.
            
*/

import UIKit


/**
    The KVO context used for all `PhotosViewController` instances. This provides a stable
    address to use as the context parameter for the KVO observation methods.
*/
private var photosViewControllerObservationContext = 0

class PhotosViewController: UIViewController {
    // MARK: Properties

    /// The album that the app is importing
    fileprivate var album: Album?
    
    /// Keys that we observe on `overallProgress`.
    fileprivate let overalProgressObservedKeys = [
        "fractionCompleted",
        "completedUnitCount",
        "totalUnitCount",
        "cancelled",
        "paused"
    ]

    /// The overall progress for the import that is shown to the user
    fileprivate var overallProgress: Progress? {
        willSet {
            guard let formerProgress = overallProgress else { return }

            for overalProgressObservedKey in overalProgressObservedKeys {
                formerProgress.removeObserver(self, forKeyPath: overalProgressObservedKey, context: &photosViewControllerObservationContext)
            }
        }

        didSet {
            if let newProgress = overallProgress {
                for overalProgressObservedKey in overalProgressObservedKeys {
                    newProgress.addObserver(self, forKeyPath: overalProgressObservedKey, options: [], context: &photosViewControllerObservationContext)
                }
            }
            
            updateProgressView()
            updateToolbar()
        }
    }
    
    fileprivate var progressViewIsHidden = true
    
    fileprivate var overallProgressIsFinished: Bool {
        let completed = overallProgress!.completedUnitCount
        let total = overallProgress!.totalUnitCount
        
        // An NSProgress is finished if it's not indeterminate, and the completedUnitCount > totalUnitCount.
        return (completed >= total && total > 0 && completed > 0) || (completed > 0 && total == 0)
    }
    
    // MARK: IBOutlets
    
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var progressContainerView: UIView!
    
    @IBOutlet var startToolbarItem: UIBarButtonItem!
    @IBOutlet var cancelToolbarItem: UIBarButtonItem!
    @IBOutlet var pauseToolbarItem: UIBarButtonItem!
    @IBOutlet var resumeToolbarItem: UIBarButtonItem!
    @IBOutlet var resetToolbarItem: UIBarButtonItem!

    // MARK: IBActions
    
    @IBAction func startImport() {
        overallProgress = album?.importPhotos()
    }
    
    @IBAction func cancelImport() {
        overallProgress?.cancel()
    }

    @IBAction func pauseImport() {
        overallProgress?.pause()
    }
    
    @IBAction func resumeImport() {
        overallProgress?.resume()
    }
    
    @IBAction func resetImport() {
        album?.resetPhotos()
        overallProgress = nil
    }

    // MARK: Key-Value Observing
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &photosViewControllerObservationContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        OperationQueue.main.addOperation {
            self.updateProgressView()
            self.updateToolbar()
        }
    }
    
    // MARK: Update UI

    fileprivate func updateProgressView() {
        let shouldHide: Bool

        if let overallProgress = self.overallProgress {
            shouldHide = overallProgressIsFinished || overallProgress.isCancelled

            progressView.progress = Float(overallProgress.fractionCompleted)
        }
        else {
            shouldHide = true
        }
        
        if progressViewIsHidden != shouldHide {
            UIView.animate(withDuration: 0.2, animations: {
                self.progressContainerView.alpha = shouldHide ? 0.0 : 1.0
            }) 

            progressViewIsHidden = shouldHide
        }
    }
    
    fileprivate func updateToolbar() {
        var items = [UIBarButtonItem]()
        
        if let overallProgress = overallProgress {
            if overallProgressIsFinished || overallProgress.isCancelled {
                items.append(resetToolbarItem)
            }
            else {
                // The import is running.
                items.append(cancelToolbarItem)
                
                if overallProgress.isPaused {
                    items.append(resumeToolbarItem)
                }
                else {
                    items.append(pauseToolbarItem)
                }
            }
        }
        else {
            items.append(startToolbarItem)
        }

        navigationController?.toolbar?.setItems(items, animated: true)
    }
    
    // MARK: Nib Loading
    
    override func awakeFromNib() {
        album = Album()
    }
    
    // MARK: Segue Handling

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "collectionView" {
            if let collectionViewController = segue.destination as? PhotosCollectionViewController {
                collectionViewController.album = album
            }
        }
    }
}
