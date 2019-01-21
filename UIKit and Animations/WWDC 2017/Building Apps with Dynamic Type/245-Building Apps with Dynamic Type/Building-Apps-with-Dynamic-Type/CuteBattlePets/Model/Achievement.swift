/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This is the Model class for Achievement.
*/

import UIKit

class Achievement: NSObject {
    let badgeImage: UIImage
    let achievementString: String
    let badgeColor: UIColor
    
    init(badgeImage: UIImage, achievementString: String, badgeColor: UIColor) {
        self.badgeImage = badgeImage
        self.achievementString = achievementString
        self.badgeColor = badgeColor
    }
}
