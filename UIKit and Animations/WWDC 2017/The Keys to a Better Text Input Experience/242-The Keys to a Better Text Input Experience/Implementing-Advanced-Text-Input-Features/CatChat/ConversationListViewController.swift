/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This is the main conversation list view controller that shows all the conversations. This class
         is also what handles the keyboard shortcuts for going from message to message. The key commands
         themselves, however, are located in the first responder, which should be the ConversationViewController.
*/

import UIKit

class ConversationListViewController: UITableViewController, UISplitViewControllerDelegate, ConversationListNavigationDelegate {
    private static let standardCellReuseIdentifier: String = "standardCell"
    private let chatDataSource = ChatDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        splitViewController?.delegate = self
        splitViewController?.preferredDisplayMode = .allVisible

        navigationItem.title = NSLocalizedString("CAT_CHAT", comment: "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: nil, action: nil)
        tableView.estimatedRowHeight = 120.0
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatDataSource.numberOfConversations
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationListViewController.standardCellReuseIdentifier, for: indexPath)

        let conversation = chatDataSource[indexPath.row]

        cell.textLabel?.text = conversation.otherParticipant!
        cell.detailTextLabel?.text = conversation.chatItems.last?.text
		cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator

        return cell
    }

    // MARK: - Navigation

    var detailViewController: ConversationViewController? {
        if let detailNavController = splitViewController?.viewControllers[1] as? UINavigationController {
            return detailNavController.viewControllers[0] as? ConversationViewController
        }

        return nil
    }

    func goToNextConversation() {
        if let index = chatDataSource.index(of: (detailViewController?.conversation)!) {
            if index + 1 < chatDataSource.numberOfConversations {
                detailViewController?.conversation = chatDataSource[index + 1]
                tableView.selectRow(at: IndexPath(row: index + 1, section: 0), animated: true, scrollPosition: .middle)
            }
        }
    }

    func goToPreviousConversation() {
        if let index = chatDataSource.index(of: (detailViewController?.conversation)!) {
            if index - 1 >= 0 {
                detailViewController?.conversation = chatDataSource[index - 1]
                tableView.selectRow(at: IndexPath(row: index - 1, section: 0), animated: true, scrollPosition: .middle)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPath(for: sender as! UITableViewCell)

        let navController = segue.destination as! UINavigationController
        let conversationViewController = navController.topViewController as! ConversationViewController

        conversationViewController.listNavigationDelegate = self
        conversationViewController.conversation = chatDataSource[indexPath!.row]
    }

    // MARL: - Split View Controller Delegate

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {

        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? ConversationViewController else { return false }

        if topAsDetailController.conversation == nil {
            /*
                 Return true to indicate that we have handled the collapse by doing
                 nothing; the secondary controller will be discarded.
            */
            return true
        }
        return false
    }
}
