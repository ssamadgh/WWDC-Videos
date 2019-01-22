/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file contains the code to present more information about an earthquake as a modal sheet.
*/

import Foundation
import SafariServices

/// An `Operation` to display an `NSURL` in an app-modal `SFSafariViewController`.
class MoreInformationOperation: Operation {
    // MARK: Properties

    let URL: Foundation.URL
    
    // MARK: Initialization
    
    init(URL: Foundation.URL) {
        self.URL = URL

        super.init()
        
        addCondition(MutuallyExclusive<UIViewController>())
    }
    
    // MARK: Overrides
 
    override func execute() {
        DispatchQueue.main.async {
            self.showSafariViewController()
        }
    }
    
    fileprivate func showSafariViewController() {
        if let context = UIApplication.shared.keyWindow?.rootViewController {
            let safari = SFSafariViewController(url: URL, entersReaderIfAvailable: false)
            safari.delegate = self
            context.present(safari, animated: true, completion: nil)
        }
        else {
            finish()
        }
    }
}

extension MoreInformationOperation: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        self.finish()
    }
}
