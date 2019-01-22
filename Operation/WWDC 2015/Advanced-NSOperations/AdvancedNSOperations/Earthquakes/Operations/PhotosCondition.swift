/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows an example of implementing the OperationCondition protocol.
*/

#if os(iOS)

import Photos

/// A condition for verifying access to the user's Photos library.
struct PhotosCondition: OperationCondition {
    
    static let name = "Photos"
    static let isMutuallyExclusive = false
    
    init() { }
    
    func dependencyForOperation(_ operation: Operation) -> Foundation.Operation? {
        return PhotosPermissionOperation()
    }
    
    func evaluateForOperation(_ operation: Operation, completion: @escaping (OperationConditionResult) -> Void) {
        switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:
                completion(.satisfied)

            default:
                let error = NSError(code: .conditionFailed, userInfo: [
                    OperationConditionKey: type(of: self).name
                ])

                completion(.failed(error))
        }
    }
}

/**
    A private `Operation` that will request access to the user's Photos, if it
    has not already been granted.
*/
private class PhotosPermissionOperation: Operation {
    override init() {
        super.init()

        addCondition(AlertPresentation())
    }
    
    override func execute() {
        switch PHPhotoLibrary.authorizationStatus() {
            case .notDetermined:
                DispatchQueue.main.async {
                    PHPhotoLibrary.requestAuthorization { status in
                        self.finish()
                    }
                }
     
            default:
                finish()
        }
    }
    
}

#endif
