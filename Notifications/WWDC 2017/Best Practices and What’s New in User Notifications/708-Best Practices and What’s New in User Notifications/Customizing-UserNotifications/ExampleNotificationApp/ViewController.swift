/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Application's main view controller.
*/

import UIKit
import UserNotifications

class ViewController: UIViewController {
    /// - Tag: sendLocalNotificationWithAttachment
    @IBAction func sendLocalNotificationWithAttachment(_ sender: Any) {
        let content = UNMutableNotificationContent()

        // Set title and subtitle.
        content.title = NSString.localizedUserNotificationString(forKey: "INCOMING_PHOTO_TITLE", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "INCOMING_PHOTO_BODY", arguments: nil)

        // Attach an image.
        if let fileURL = Bundle.main.url(forResource:"image", withExtension: "jpg"),
           let attachment = try? UNNotificationAttachment(identifier: "localAttachment", url: fileURL, options: nil) {
            content.attachments = [attachment]

            // Set the category after successfully attaching image.
            content.categoryIdentifier = "imageCategory"
        }

        // Send notification after 5 seconds.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        // Set up notification request.
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // Schedule notification request.
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                fatalError("failed to schedule notification request: \(request) with \(error)")
            }
        }
    }
}
