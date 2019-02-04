/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Contains the notification service extension for the media service extension in the app.
*/

import MobileCoreServices
import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    var currentDownloadTask: URLSessionDownloadTask?

    /// - Tag: didReceive
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        self.bestAttemptContent = request.content.mutableCopy() as? UNMutableNotificationContent

        if let mutableContent = self.bestAttemptContent,
            let urlString = mutableContent.userInfo["url"] as? String,
            let url = URL(string: urlString) {
                // Create a download task using the url passed in the push payload.
                currentDownloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { fileURL, _, error in

                    if let error = error {
                        // Handle the case where the download task fails.
                        NSLog("download task failed with \(error)")
                        if let mediaType = mutableContent.userInfo["type"] as? String {
                            // Append additional fallback info from push payload.
                            mutableContent.title = NSString.localizedUserNotificationString(forKey: "FALLBACK_TITLE", arguments: [mediaType])
                        }
                    } else {
                        // Handle the case where the download task succeeds.
                        if let fileURL = fileURL,
                            // Temporary files usually do not have a type extension, so get the type of the original url.
                            let fileType = NotificationService.fileType(fileExtension: url.pathExtension),
                            // Pass the type as type hint key to help out.
                            let attachment = try? UNNotificationAttachment(identifier: "pushAttachment", url: fileURL, options: [UNNotificationAttachmentOptionsTypeHintKey: fileType]) {
                                // Add the attachment to the notification content.
                                mutableContent.attachments = [attachment]

                                // Set the category after successfully attaching an image.
                                mutableContent.categoryIdentifier = "imageCategory"
                        }
                    }

                    // Serve the notification ASAP so we don't block notification delivery for our app.
                    contentHandler(mutableContent)
                })

                // Begin download task.
                currentDownloadTask?.resume()
            }
    }

    override func serviceExtensionTimeWillExpire() {
        // Cancel running download task.
        if let downloadTask = currentDownloadTask {
            downloadTask.cancel()
        }
    }

    // Helper function to get a kUTType from a file extension.
    class func fileType(fileExtension: String) -> CFString? {
        return UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)?.takeRetainedValue()
    }
}
