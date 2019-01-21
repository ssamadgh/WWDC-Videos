/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Adds drag capabilities to the `DragBoardViewController` by implementing a number of drag interaction delegate methods.
*/

import UIKit

extension DragBoardViewController : UIDragInteractionDelegate {
    
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
		let point = session.location(in: interaction.view!)
        
        if let index = imageIndex(at: point) {
            // The location of the touch is over an image in the pin board:
            // we get the model object and wrap it in a UIDragItem.
            let image = images[index]
            let itemProvider = NSItemProvider(object: image)
            let dragItem = UIDragItem(itemProvider: itemProvider)
            
            // We set the `localObject` property to the index of the model object
            // so that when performing a drop we can animate it differently from
            // drag items coming from other applications.
            dragItem.localObject = index
            
            return [ dragItem ]
        }
        return []
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, previewForLifting item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {
        let index = item.localObject as! Int
        return UITargetedDragPreview(view: views[index])
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, willAnimateLiftWith animator: UIDragAnimating, session: UIDragSession) {
        animator.addCompletion { position in
            // If the lift ended and the user is dragging the image,
            // we want to give a visual cue that the original item is
            // involved in a drag session and it is also still in the pin board.
            if position == .end {
                self.fade(items: session.items, alpha: 0.5)
            }
        }
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, item: UIDragItem, willAnimateCancelWith animator: UIDragAnimating) {
        // We restore the alpha of the item being dragged from 0.5 back to 1.
        animator.addAnimations {
            self.fade(items: [item], alpha: 1)
        }
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, session: UIDragSession, willEndWith operation: UIDropOperation) {
        if operation == .copy {
            // The items in the pin board are being copied by another application:
            // this is our chance to change the alpha of the dragged items back to 1.
            fade(items: session.items, alpha: 1)
        }
    }
    
    /// Returns the index of an image in the pin board
    /// at the given point, if any.
    ///
    /// - Parameter point: the point in the pin board coordinate space.
    /// - Returns: The index of an image if the point is over an image in pin board, nothing otherwise.
    func imageIndex(at point: CGPoint) -> Int? {
        if let hitTestView = view?.hitTest(point, with: nil), let index = views.index(of: hitTestView) {
            return index
        }
        return nil
    }
    
}

