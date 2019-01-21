/*
See LICENSE folder for this sample’s licensing information.

Abstract:
AchievementsViewController has table view of badges achieved by your pet.
 This view controller uses estimatedRowHeight, rowHeight, and UITableViewAutomaticDimension to enable self-sizing cells.
 This also uses adjustsImageSizeForAccessibilityContentSizeCategory to scale images at the 5 largest text sizes.
*/

import UIKit

class AchievementsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: - Table view delegate methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let achievementsCell = tableView.dequeueReusableCell(withIdentifier: "achievements", for: indexPath) as? AchievementsCell else {
            fatalError("Could not dequeue AchievementsCell with identifier: achievements")
        }
        let achievement = AchievementDataSource.achievementsList()[indexPath.row]
        achievementsCell.achievement = achievement
        return achievementsCell
    }
    
}
