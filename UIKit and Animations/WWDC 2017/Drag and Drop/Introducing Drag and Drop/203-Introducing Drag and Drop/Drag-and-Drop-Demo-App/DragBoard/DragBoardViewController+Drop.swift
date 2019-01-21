/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Adds drop capabilities to the `DragBoardViewController` by implementing a number of drop interaction delegate methods.
*/

import UIKit

extension DragBoardViewController : UIDropInteractionDelegate {
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        let operation: UIDropOperation
        if session.localDragSession == nil {
            operation = .copy
        } else {
            // If a local drag session exists, we only want to move an
            // existing item in the pin board to a different location.
            operation = .move
        }
        return UIDropProposal(operation: operation)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        if session.localDragSession == nil {
			dropPoint = session.location(in: interaction.view!)

            for dragItem in session.items {
                loadImage(dragItem.itemProvider, center: dropPoint)
            }
        }
    }

    func dropInteraction(_ interaction: UIDropInteraction, previewForDropping item: UIDragItem, withDefault defaultPreview: UITargetedDragPreview) -> UITargetedDragPreview? {
        if item.localObject == nil {
            // The item comes from another application: we return nil so that
            // the preview shrinks down and fades out at the current location.
            return nil
        } else {
            // The item already exists in the pin board: we retarget the default
            // preview to its center. By not specifing a transform parameter, the
            // preview will not shrink down.
            dropPoint = defaultPreview.view.center
            let target = UIDragPreviewTarget(container: view, center: dropPoint)
            return defaultPreview.retargetedPreview(with: target)
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, item: UIDragItem, willAnimateDropWith animator: UIDragAnimating) {
        animator.addAnimations {
            // If the item already exists, it fades
            // out the image in the previous location.
            self.fade(items: [item], alpha: 0)
        }
        let movePoint = dropPoint
        animator.addCompletion { _ in
            // If the item already exists, it moves it to
            // the new location and makes it fully opaque.
            if let index = item.localObject as? Int {
                self.views[index].center = movePoint
                self.views[index].alpha = 1.0
            }
        }
    }
}
