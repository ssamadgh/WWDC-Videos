/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A custom view that can handle paste events.
*/

import UIKit

class DragBoardView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "cork"))
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
}
