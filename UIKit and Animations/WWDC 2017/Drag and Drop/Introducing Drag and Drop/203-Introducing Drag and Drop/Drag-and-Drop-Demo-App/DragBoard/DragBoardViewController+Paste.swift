/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Sets up the gestures to display and dismiss the menu performing the paste operation on the pin board.
*/

import UIKit

extension DragBoardViewController {
    
    func setupPasteMenu() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handle(longPress:)))
        view.addGestureRecognizer(longPressGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handle(tap:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func handle(longPress: UILongPressGestureRecognizer) {
        if longPress.state == .began {
            dropPoint = longPress.location(in: view)
            
            // Only show the paste menu if we are
            // not over an image in the pin board.
            if imageIndex(at: dropPoint) == nil {
                view.becomeFirstResponder()
                
                let menu = UIMenuController.shared
                let rect = CGRect(origin: dropPoint, size: CGSize(width: 10, height: 10))
                menu.setTargetRect(rect, in: view)
                menu.setMenuVisible(true, animated: true)
            }
        } else if longPress.state == .cancelled {
            UIMenuController.shared.setMenuVisible(false, animated: true)
        }
    }
    
    @objc
    func handle(tap: UITapGestureRecognizer) {
        UIMenuController.shared.setMenuVisible(false, animated: true)
    }
}
