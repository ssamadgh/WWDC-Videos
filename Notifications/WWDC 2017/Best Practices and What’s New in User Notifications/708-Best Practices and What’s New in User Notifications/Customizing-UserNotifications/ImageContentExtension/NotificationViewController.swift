/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Contains ImageContentExtension's NotificationViewController.
*/

import UIKit
import UserNotifications
import UserNotificationsUI

/// - Tag: NotificationViewController
class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var likeLabel: UILabel!

    func didReceive(_ notification: UNNotification) {
        guard let attachment = notification.request.content.attachments.first else { return }

        // Get the attachment and set the image view.
        if attachment.url.startAccessingSecurityScopedResource(),
            let data = try? Data(contentsOf: attachment.url) {
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(data: data)

            // Adjust preferred content size based on image.
            if let image = imageView.image {
                let scaledRatio = view.bounds.width / image.size.width
                preferredContentSize = CGSize(width: scaledRatio * image.size.width,
                                              height: scaledRatio * image.size.height)
            }

            attachment.url.stopAccessingSecurityScopedResource()
        }
    }

    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        // Handle various actions.
        if response.actionIdentifier == "likeAction" {
            likeLabel.isHidden = false
        } else if response.actionIdentifier == "reactAction" {
            becomeFirstResponder()
        }

        // Dont dismiss extension to allow further interaction.
        completion(.doNotDismiss)
    }

    override var canBecomeFirstResponder: Bool {
        // Need to become first responder to have custom input view.
        return true
    }

    override var inputView: UIView? {
        // Instantiate and return custom input view.
        let reactionsViewController = ReactionsViewController()
        reactionsViewController.delegate = self
        return reactionsViewController.view
    }
}

extension NotificationViewController: ReactionsViewDelegate {
    func didSelectReaction(_ reaction: String?) {
        let reactionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        reactionLabel.font = UIFont.systemFont(ofSize: 22)
        // Set and position label text to reaction that was selected.
        reactionLabel.textAlignment = .center
        reactionLabel.text = reaction
        // Place label in random location in view.
        let originX = arc4random_uniform(UInt32(view.bounds.width))
        let originY = arc4random_uniform(UInt32(view.bounds.height))
        reactionLabel.center = CGPoint(x: CGFloat(originX), y: CGFloat(originY))
        // Rotate label to a random angle.
        let rotation = Float(arc4random_uniform(360))
        reactionLabel.transform = CGAffineTransform(rotationAngle: CGFloat(.pi * rotation / 180.0))
        self.view.addSubview(reactionLabel)
    }

    func didCompleteReacting() {
        // Resign first responder to dismiss custom input view.
        resignFirstResponder()
    }
}
