/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This is the accessory view that sits on top of the keyboard. It has an expanding text view
        that grows as the user types long messages.
*/

import UIKit

class ChatInputAccessoryView: UIInputView {

    private static let preferredHeight: CGFloat = 54.0

    let containerView = UIView()

    let expandingTextView = UITextView()

    let sendButton: UIButton = {
		let button = UIButton(type: UIButton.ButtonType.system)
        let titleString = NSLocalizedString("SEND", comment: "")
		button.setTitle(titleString, for: UIControl.State.normal)

        return button
    }()

    private let separatorView: UIView = {
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)

        return separatorView
    }()

    private let textViewBackground = UIImageView(image: #imageLiteral(resourceName: "TextBkgd"))

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: ChatInputAccessoryView.preferredHeight)
    }

    override var intrinsicContentSize: CGSize {
        var newSize = bounds.size
        if expandingTextView.bounds.size.height > 0.0 {
            newSize.height = expandingTextView.bounds.size.height + 20.0
        }
        if newSize.height < ChatInputAccessoryView.preferredHeight || newSize.height > 120.0 {
            newSize.height = ChatInputAccessoryView.preferredHeight
        }
        return newSize
    }

	override init(frame: CGRect, inputViewStyle: UIInputView.Style) {
        super.init(frame: frame, inputViewStyle: inputViewStyle)

        addSubview(containerView)
        addSubview(separatorView)
        containerView.addSubview(textViewBackground)
        containerView.addSubview(expandingTextView)
        containerView.addSubview(sendButton)

        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.white

        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        separatorView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separatorView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        separatorView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        let guide = layoutMarginsGuide
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true

        expandingTextView.translatesAutoresizingMaskIntoConstraints = false
        expandingTextView.textContainer.heightTracksTextView = true
        expandingTextView.isScrollEnabled = false
        expandingTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        expandingTextView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10.0).isActive = true
        expandingTextView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10.0).isActive = true
        expandingTextView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10.0).isActive = true
        expandingTextView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.0)
		
		expandingTextView.setContentHuggingPriority(.defaultHigh, for: NSLayoutConstraint.Axis.vertical)

        textViewBackground.translatesAutoresizingMaskIntoConstraints = false
        textViewBackground.leadingAnchor.constraint(equalTo: expandingTextView.leadingAnchor, constant: 0.0).isActive = true
        textViewBackground.trailingAnchor.constraint(equalTo: expandingTextView.trailingAnchor, constant: 0.0).isActive = true
        textViewBackground.topAnchor.constraint(equalTo: expandingTextView.topAnchor, constant: 0.0).isActive = true
        textViewBackground.bottomAnchor.constraint(equalTo: expandingTextView.bottomAnchor, constant: 0.0).isActive = true

        sendButton.translatesAutoresizingMaskIntoConstraints = false
		sendButton.setContentHuggingPriority(.defaultHigh, for: NSLayoutConstraint.Axis.horizontal)
		sendButton.setContentCompressionResistancePriority(.defaultHigh, for: NSLayoutConstraint.Axis.horizontal)
        sendButton.bottomAnchor.constraint(equalTo: expandingTextView.bottomAnchor).isActive = true
        sendButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
    }

}
