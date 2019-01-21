/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
                PhotoDownload supports NSProgressReporting and "downloads" a file URL.
            
*/

import Foundation

class PhotoDownload: NSObject, ProgressReporting {
    // MARK: Properties

    /// The URL to be downloaded.
    let downloadURL: URL
    
    /**
        The completionHandler is called once the download is finished with either 
        the downloaded data, or an `NSError`.
    */
    var completionHandler: ((_ data: Data?, _ error: NSError?) -> Void)?

    let progress: Progress

    /// A class containing the fake parts of our download.
    fileprivate class DownloadState {
        /// The dispatch queue that all of our callbacks will be invoked on.
        var queue: DispatchQueue!

        /// The timer that drives the "download".
        var downloadTimer: DispatchSourceTimer?
        
        /// The error that our didFail callback should be called with.
        var downloadError: NSError?
 
        /// Whether or not we're paused.
        var isPaused = false
    }

    fileprivate var downloadState: DownloadState

    // MARK: Initializers
    
    init(URL: Foundation.URL) {
        downloadURL = (URL as NSURL).copy() as! Foundation.URL

        downloadState = DownloadState()
        
        progress = Progress()
        
        /*
            The progress starts out as indeterminate, since we don't know how many 
            bytes there are to download yet.
        */
        progress.totalUnitCount = -1

        /*
            Since our units are bytes, we use NSProgressKindFile so the NSProgress's
            localizedDescription and localizedAdditionalDescription return 
            something nicer.
        */
        progress.kind = ProgressKind.file
        
        // We say we're a file operation so the localized descriptions are a little nicer.
        progress.setUserInfoObject(Progress.FileOperationKind.downloading as AnyObject, forKey: ProgressUserInfoKey.fileOperationKindKey)
    }
    
    /// Start the download. Can only be called once.
    func start() {
        assert(nil == downloadState.queue, "`downloadState.queue` must not be nil in \(#function).")
        
        // Fake a download.
        downloadState.queue = DispatchQueue(label: "download queue", attributes: [])
        downloadState.queue.async {
            do {
                // Fetch the data
                let data = try Data(contentsOf: self.downloadURL, options: [])

                // Our parameters for the "download".
                
                // Update every 0.5 seconds.
                let interval: Double = 0.5
                
                // Bytes per second.
                let throughput: Double = 5000
                
                // Create a timer
                let downloadTimer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: self.downloadState.queue)

                self.downloadState.downloadTimer = downloadTimer
                
                var downloadedBytes = 0

                // Add a random delay to the start, to simulate latency.
                let randomMilliseconds = Int64(arc4random_uniform(500))
                
                let delay = DispatchTime.now() + Double(Int64(interval * Double(NSEC_PER_SEC)) - Int64(randomMilliseconds * Int64(NSEC_PER_MSEC))) / Double(NSEC_PER_SEC)
                
                downloadTimer.scheduleRepeating(deadline: delay, interval: interval, leeway: .nanoseconds(0))

                downloadTimer.setEventHandler {
                    // Update the downloaded bytes.
                    downloadedBytes += Int(throughput * interval)
                
                    if downloadedBytes >= data.count {
                        // We've finished!
                        downloadTimer.cancel()
                        return
                    }
                    
                    // Call out that we've "downloaded" new data.
                    self.didDownloadData(data, numberOfBytes: downloadedBytes)
                }
            
                downloadTimer.setCancelHandler {
                    if downloadedBytes >= data.count {
                        // Call out that we finished "downloading" data.
                        self.didFinishDownload(data)
                    }
                    else {
                        // Call out that we finished "downloading" data.
                        self.didFailDownloadWithError(self.downloadState.downloadError!)
                    }
                    
                    self.downloadState.downloadTimer = nil
                }
                
                // Call out that we will begin to "download" data.
                self.willBeginDownload(data.count)
                
                downloadTimer.resume()
            }
            catch let error {
                // Call out that we failed to "download" data.
                self.didFailDownloadWithError(error as NSError)
            }
        }
    }
    
    fileprivate func failDownloadWithError(_ error: NSError) {
        guard let downloadTimer = downloadState.downloadTimer else { return }

        downloadState.queue.async {
            /*
                Set the downloadError, then cancel. The timer's cancellation handler 
                will invoke the fail callback with the error, if we haven't finished
                by then.
            */
            self.downloadState.downloadError = error
            
            // Resume the timer before cancelling it.
            if self.downloadState.isPaused {
                downloadTimer.resume()
            }
            
            downloadTimer.cancel()
        }
    }
    
    fileprivate func suspendDownload() {
        if let downloadTimer = downloadState.downloadTimer {
            downloadState.queue.async {
                // Do not suspend if we're already suspended, or if we're cancelled.
                guard !self.downloadState.isPaused && !downloadTimer.isCancelled else { return }

                // Simply suspend the timer.
                self.downloadState.isPaused = true
                downloadTimer.suspend()
            }
        }
    }
    
    fileprivate func resumeDownload() {
        if let downloadTimer = downloadState.downloadTimer {
            downloadState.queue.async {
                // Only resume if we're suspended and we're not cancelled.
                guard self.downloadState.isPaused && !downloadTimer.isCancelled else { return }
                
                // Simply resume the timer.
                downloadTimer.resume()
                self.downloadState.isPaused = false
            }
        }
    }
    
    fileprivate func callCompletionHandler(data: Data?, error: NSError?) {
        // Call the completion handler if we have one.
        completionHandler?(data, error)
        
        // Break any retain cycles by setting it to nil.
        completionHandler = nil
    }

    // Called when the "download" begins
    func willBeginDownload(_ downloadLength: Int) {
        progress.totalUnitCount = Int64(downloadLength)

        progress.isCancellable = true
        progress.cancellationHandler = {
            let error = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
            self.failDownloadWithError(error)
        }

        progress.isPausable = true

        progress.pausingHandler = {
            self.suspendDownload()
        }
        
        progress.resumingHandler = {
            self.resumeDownload()
        }
    }
    
    /**
        Called periodically as the "download" occurs. data and numberOfBytes are
        aggregated values, and contain the entire download up to that point.
    */
    func didDownloadData(_ data: Data, numberOfBytes: Int) {
        progress.completedUnitCount = Int64(numberOfBytes)
    }
    
    /// Called when the "download" is completed.
    func didFinishDownload(_ downloadedData: Data) {
        progress.completedUnitCount = Int64(downloadedData.count)
        callCompletionHandler(data: downloadedData, error: nil)
    }
    
    /// Called if an error occurs during the "download"
    func didFailDownloadWithError(_ error: NSError) {
        callCompletionHandler(data: nil, error: error)
    }
}
