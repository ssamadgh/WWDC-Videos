/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This is the main detail view controller and the application's first responder. All keyboard shortcuts
        are defined here, as well as the inputAccessoryViewController and custom inputView, if you so desire.
        Also consult this file for an example of how to use textInputContextIdentifier to uniquely identify
        the people you're talking with to the system keyboard so the user's preferred keyboard is persisted.
*/

import UIKit

protocol ConversationListNavigationDelegate: class {
    func goToPreviousConversation()
    func goToNextConversation()
}

class ChatItemTableViewCell: UITableViewCell {
	
    @IBOutlet weak var flippableView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bubbleImageView: UIImageView!

    private let otherBubbleImage = #imageLiteral(resourceName: "chatbubble_other").resizableImage(withCapInsets: UIEdgeInsets(top: 10.0, left: 25.0, bottom: 18.0, right: 10.0))
    private let myBubbleImage = #imageLiteral(resourceName: "chatbubble_me").resizableImage(withCapInsets: UIEdgeInsets(top: 10.0, left: 10.0, bottom: 18.0, right: 25.0))

    var isFromMe: Bool = false {
        didSet {
            bubbleImageView.image = isFromMe ? myBubbleImage : otherBubbleImage
            textView.textAlignment = isFromMe ? .right : .left
            flippableView.semanticContentAttribute = isFromMe ? .forceRightToLeft : .forceLeftToRight
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        bubbleImageView.image = otherBubbleImage
        contentView.backgroundColor = UIColor.clear
    }
}

class ConversationViewController: UITableViewController, UITextViewDelegate {
	
	
    public var conversation: Conversation? {
        didSet {
            navigationItem.title = conversation!.otherParticipant
            tableView.reloadData()
        }
    }

    weak var listNavigationDelegate: ConversationListNavigationDelegate?

    private static let chatCellReuseIdentifier = "chatCell"

    // Custom Input Accessory View
    private let chatInputAccessoryView: ChatInputAccessoryView = {
		let view = ChatInputAccessoryView(frame: CGRect.zero, inputViewStyle: UIInputView.Style.default)
		view.sendButton.addTarget(self, action: #selector(didTapSend(sender:)), for: UIControl.Event.touchUpInside)

        return view
    }()

    // Wrapper view controller for the custom input accessory view
    private let chatInputAccessoryViewController = UIInputViewController()

    private var previousTextContainerHeight: Double = 0.0

    private let customInputViewController = AnimalInputViewController()

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

		tableView.rowHeight = UITableView.automaticDimension

        // Custom keyboard
        // Uncomment this to show a custom input view in your app
        // chatInputAccessoryView.expandingTextView.inputView = customInputViewController.inputView

        // Automatic keyboard dismissal
		tableView.keyboardDismissMode = UIScrollView.KeyboardDismissMode.interactive
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversation != nil ? conversation!.chatItems.count : 0
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationViewController.chatCellReuseIdentifier, for: indexPath) as! ChatItemTableViewCell

        let chatItem = conversation?.chatItems[indexPath.row]
        cell.textView.text = chatItem?.text
        cell.isFromMe = chatItem?.sender == "me"

        return cell
    }

    // MARK: - UIResponder overrides and key commands

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func becomeFirstResponder() -> Bool {
        let didBecome = super.becomeFirstResponder()

        if conversation != nil {
            // We want the input accessory view to become focused when the view controller is pushed/displayed
            chatInputAccessoryView.expandingTextView.becomeFirstResponder()
        }

        return didBecome
    }

    /// - Tag: keycommands
    override var keyCommands: [UIKeyCommand]? {
        return [
            // Command + Down arrow goes to the next conversation
			UIKeyCommand(input: UIKeyCommand.inputDownArrow,
                         modifierFlags: .command,
                         action: #selector(switchToConversationKeyCommandInvoked(sender:)),
                         discoverabilityTitle: NSLocalizedString("GO_TO_NEXT_CONVERSATION", comment: "")),

            // Command + Up arrow goes to the previous conversation
			UIKeyCommand(input: UIKeyCommand.inputUpArrow,
                         modifierFlags: .command,
                         action: #selector(switchToConversationKeyCommandInvoked(sender:)),
                         discoverabilityTitle: NSLocalizedString("GO_TO_PREV_CONVERSATION", comment: ""))
        ]
    }

    @objc
    func switchToConversationKeyCommandInvoked(sender: UIKeyCommand) {
		if sender.input == UIKeyCommand.inputDownArrow {
            listNavigationDelegate?.goToNextConversation()
		} else if sender.input == UIKeyCommand.inputUpArrow {
            listNavigationDelegate?.goToPreviousConversation()
        }
    }

    // MARK: - Input accessory view

    override var inputAccessoryViewController: UIInputViewController? {
        // Ensure our input accessory view controller has it's input view set
        chatInputAccessoryViewController.inputView = chatInputAccessoryView
        // Return our custom input accessory view controller. You could also just return a UIView with
        // override func inputAccessoryView()
        return chatInputAccessoryViewController
    }

    private func sendMessage(message: String) {
        conversation?.chatItems.append(ChatItem(sender: "me", text: message))

        let newIndexPath = IndexPath(row: conversation!.chatItems.count - 1, section: 0)
        tableView.insertRows(at: [newIndexPath], with: .top)
        tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
    }

    @objc
    func didTapSend(sender: Any) {
        let text = chatInputAccessoryView.expandingTextView.text!
        if !text.isEmpty {
            sendMessage(message: text)
            chatInputAccessoryView.expandingTextView.text = ""
        }
    }

    // MARK: - Language identification

    override var textInputContextIdentifier: String? {
        // Returning some unique identifier here allows the keyboard to remember which language the user was
        // typing in when they were last communicating with this person.

        // This can be anything, as long as it's unique to each recipient (here we're just returning the name)
        return conversation?.otherParticipant
    }

}
