/*
See LICENSE folder for this sample’s licensing information.

Abstract:
BattleViewController has a table view of battle opponents.
 It uses estimatedRowHeight, rowHeight, and UITableViewAutomaticDimension to enable self-sizing cells.
 In this view controller, the "Battle" button is usually placed to the right of the pet name and description.
 For larger sizes, this can be moved below the text so that the text has more horizontal room.
 This results in less wrapping/truncation. Similar logic applies to the pet image in this cell,
 so it is moved above the text for larger text sizes.
*/

import UIKit

class BattleViewController: UITableViewController {
    
    fileprivate let petList = PetDataSource.petList()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 148.5
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: - Table view delegate methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petList.count - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let battleCell = tableView.dequeueReusableCell(withIdentifier: "battle", for: indexPath) as? BattleCell else {
            fatalError("Could not dequeue BattleCell with identifier: battle")
        }
        battleCell.pet = petList[indexPath.row + 1]
        battleCell.battleButton.tag = indexPath.row + 1
        battleCell.battleButton.addTarget(self, action: #selector(battleEvent(_:)), for: .touchUpInside)
        return battleCell
    }
    
    @objc
    func battleEvent(_ sender: UIButton) {
        guard let scorecardVC = self.storyboard!.instantiateViewController(withIdentifier: "ScoreCardID") as? ScoreCardViewController else {
            fatalError("Could not instantiate view controller ScoreCardViewController with identifier: ScoreCardID")
        }
        scorecardVC.scorecardID = sender.tag
        self.navigationController?.pushViewController(scorecardVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showPetSegue", sender: indexPath)
    }
    
    // MARK: - Segue methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPetSegue" {
            guard let indexPath = sender as? IndexPath else {
                fatalError("Could not cast sender as IndexPath")
            }
            let destination = segue.destination as? PetViewController
            destination?.pet = petList[indexPath.row + 1]
        }
    }
    
}

