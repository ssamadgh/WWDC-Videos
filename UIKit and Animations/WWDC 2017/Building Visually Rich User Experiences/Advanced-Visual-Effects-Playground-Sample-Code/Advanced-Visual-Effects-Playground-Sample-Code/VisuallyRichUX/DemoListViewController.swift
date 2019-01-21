/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This table view controller presents the list of demos in this sample.
*/
import UIKit

class DemoListViewController: UITableViewController {
    
    var demos: [(String, UIViewController.Type)] =
        [ ("UIKit Customization", SliderCustomizationViewController.self),
          ("Core Image Basics", ImageFilteringViewController.self),
          ("Core Graphics Basics", CoreGraphicsDrawingViewController.self),
          ("Core Animation Basics", CoreAnimationViewController.self),
          ("SpriteKit Basics", SpriteKitViewController.self),
          ("SceneKit Basics", SceneKitViewController.self) ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Demos"
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demos.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let viewController = demos[indexPath.row].1.init(nibName: nil, bundle: nil)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "Cell"
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
        }
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = demos[indexPath.row].0
        return cell
    }
}
