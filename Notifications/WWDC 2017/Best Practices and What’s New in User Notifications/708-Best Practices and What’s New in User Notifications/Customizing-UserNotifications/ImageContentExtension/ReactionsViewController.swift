/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Contains the logic for  ReactionsViewController.
*/

import UIKit

protocol ReactionsViewDelegate: class {
    func didSelectReaction(_ reaction: String?)
    func didCompleteReacting()
}

class ReactionsViewController: UIViewController {
    weak var delegate: ReactionsViewDelegate?

    @IBAction func reactionSelected(_ sender: Any) {
        if let button = sender as? UIButton {
            delegate?.didSelectReaction(button.currentTitle)
        }
    }

    @IBAction func doneReacting(_ sender: Any) {
        delegate?.didCompleteReacting()
    }
}
