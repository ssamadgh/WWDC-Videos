//
//  TTTNewMessageViewController.swift
//  TicTacToeApp_Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/12/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

var currentMessageWindow: UIWindow!
var currentMessageSourceWindow: UIWindow!


class TTTNewMessageViewController: UIViewController {

	var profile: TTTProfile!
	
	var messageTextView: UITextView!
	
	
	init() {
		super.init(nibName: nil, bundle: nil)
		
		self.title = NSLocalizedString("Messages", comment: "Messages")
		self.view.tintAdjustmentMode = .normal
	}
	
	override convenience init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		self.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		super.loadView()
		
		let baseView = UIView()
		baseView.backgroundColor = UIColor(white: 0.0, alpha: 0.15)
		
		let view = UIView(frame: CGRect(x: -100.0, y: -50.0, width: 240.0, height: 120.0))
		view.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.flexibleLeftMargin.rawValue | UIViewAutoresizing.flexibleRightMargin.rawValue | UIViewAutoresizing.flexibleTopMargin.rawValue | UIViewAutoresizing.flexibleBottomMargin.rawValue)
		
		view.backgroundColor = UIColor(patternImage: UIImage(named: "barBackground")!)
		baseView.addSubview(view)
		
		let cancelButton = UIButton(type: .system)
		cancelButton.addTarget(self, action: #selector(close), for: .touchUpInside)
		cancelButton.translatesAutoresizingMaskIntoConstraints = false
		cancelButton.setTitle(NSLocalizedString("Cancel", comment: "Cancel"), for: .normal)
		view.addSubview(cancelButton)
		
		let postButton = UIButton(type: .system)
		postButton.addTarget(self, action: #selector(post), for: .touchUpInside)
		postButton.translatesAutoresizingMaskIntoConstraints = false
		postButton.setTitle(NSLocalizedString("Post", comment: "Post"), for: .normal)
		view.addSubview(postButton)

		self.messageTextView = UITextView()
		self.messageTextView.backgroundColor = UIColor.clear
		self.messageTextView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(self.messageTextView)
		
		let views = ["postButton" : postButton, "cancelButton" : cancelButton, "messageTextView" : messageTextView] as [String : Any]
		
		baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-8-[messageTextView]-8-|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
		baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-8-[cancelButton]->=20-[postButton]-8-|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
		baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[messageTextView]-[cancelButton]-8-|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
		baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[messageTextView]-[postButton]-8-|", options: NSLayoutFormatOptions(), metrics: nil, views: views))

		self.view = baseView
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

	func present(from viewController: UIViewController) {
		let sourceView = viewController.view
		currentMessageSourceWindow = sourceView!.window
		currentMessageWindow = UIWindow(frame: currentMessageSourceWindow.frame)
		currentMessageWindow.tintColor = currentMessageSourceWindow.tintColor
		currentMessageWindow.rootViewController = self
		currentMessageWindow.makeKeyAndVisible()
		messageTextView.becomeFirstResponder()
		self.view.alpha = 0.0
		
		UIView.animate(withDuration: 0.3) {
			self.view.alpha = 1.0
			currentMessageSourceWindow.tintAdjustmentMode = .dimmed
		}
	}
	
	@objc func close() {
		UIView.animate(withDuration: 0.3, animations: {
			self.view.alpha = 0.0
			currentMessageSourceWindow.tintAdjustmentMode = .automatic
		}) { (finished) in
			currentMessageWindow = nil
		}
	}
	
	@objc func post() {
		let message = TTTMessage()
		message.icon = self.profile.icon
		message.text = self.messageTextView.text
		TTTMessageServer.shared.add(message)
		self.close()
	}
}
