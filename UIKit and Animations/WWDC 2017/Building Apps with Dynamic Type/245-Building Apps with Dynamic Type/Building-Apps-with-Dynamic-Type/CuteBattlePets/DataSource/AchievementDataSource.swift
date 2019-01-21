/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This is the datasource class for Achievement
*/

import UIKit

class AchievementDataSource: NSObject {
    class func achievementsList() -> [Achievement] {
        let achievementsList = [
            Achievement(badgeImage: #imageLiteral(resourceName: "popularity"),
                        achievementString: "Popularity Badge : Earned this for being popular - having more than 100 friends, fans and followers",
                        badgeColor: #colorLiteral(red: 0.6, green: 0, blue: 0.8, alpha: 1)),
            Achievement(badgeImage: #imageLiteral(resourceName: "health"),
                        achievementString: "Health Badge: Earned this for eating carrots and hopping on the fields to maintain good health",
                        badgeColor: #colorLiteral(red: 1, green: 0.2509803922, blue: 0.4980392157, alpha: 1)),
            Achievement(badgeImage: #imageLiteral(resourceName: "winnings"),
                        achievementString: "Winnings Badge: Earned this for setting a record of winning more than 20 matches among 25 matches",
                        badgeColor: #colorLiteral(red: 1, green: 0.6, blue: 0, alpha: 1))
        ]
        return achievementsList
    }
}
