//
//  TTTPlayViewController.swift
//  TicTacToeApp_Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/12/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class TTTPlayViewController: UIViewController, TTTGameViewDelegate {

	let TTTPlayViewControllerMargin: CGFloat = 20.0
	
	var profile: TTTProfile!
	var profileURL: URL!
	var gameView: TTTGameView!
	
	static func viewController(with profile: TTTProfile, profileURL: URL) -> UIViewController {
		
		let controller: TTTPlayViewController = TTTPlayViewController()
		controller.profile = profile
		controller.profileURL = profileURL
		return controller
	}
	
	init() {
		super.init(nibName: nil, bundle: nil)
		
		self.title = NSLocalizedString("Play", comment: "Play")
		self.tabBarItem.image = UIImage(named: "playTab")
		self.tabBarItem.selectedImage = UIImage(named: "playTabSelected")
		
		NotificationCenter.default.addObserver(self, selector: #selector(iconDidChange(_:)), name: NSNotification.Name(rawValue: TTTProfileIconDidChangeNotification), object: nil)
	}
	
	override convenience init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		self.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	override func loadView() {
		super.loadView()
		
		let view = UIView()
		
		let newButton = UIButton(type: .system)
		newButton.translatesAutoresizingMaskIntoConstraints = false
		newButton.contentHorizontalAlignment = .center
		newButton.setTitle(NSLocalizedString("New Game", comment: "New Game"), for: .normal)
		newButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
		newButton.addTarget(self, action: #selector(newGame(_:)), for: .touchUpInside)
		view.addSubview(newButton)

		let pauseButton = UIButton(type: .system)
		pauseButton.translatesAutoresizingMaskIntoConstraints = false
		pauseButton.contentHorizontalAlignment = .center
		pauseButton.setTitle(NSLocalizedString("Pause", comment: "Pause"), for: .normal)
		pauseButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
		pauseButton.addTarget(self, action: #selector(togglePause(_:)), for: .touchUpInside)
		view.addSubview(pauseButton)

		self.gameView = TTTGameView()
		self.gameView.delegate = self
		self.gameView.translatesAutoresizingMaskIntoConstraints = false
		self.gameView.game = self.profile.currentGame
		view.addSubview(self.gameView)

		let topHeight = UIApplication.shared.statusBarFrame.size.height
		let tabBar = self.tabBarController!.tabBar
		let bottomHeight = tabBar.isTranslucent ? tabBar.frame.size.height : 0.0
		let metrics = ["topHeight" : topHeight + TTTPlayViewControllerMargin, "bottomHeight" : bottomHeight + TTTPlayViewControllerMargin, "margin" : TTTPlayViewControllerMargin]
		let bindings: [String: Any] = ["newButton" : newButton, "pauseButton" : pauseButton, "gameView" : gameView]
		
		view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-margin-[gameView]-margin-|", options: NSLayoutFormatOptions(), metrics: metrics, views: bindings))
		view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-margin-[pauseButton(==newButton)]-[newButton]-margin-|", options: NSLayoutFormatOptions(), metrics: metrics, views: bindings))
		view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-topHeight-[gameView]-margin-[newButton]-bottomHeight-|", options: NSLayoutFormatOptions(), metrics: metrics, views: bindings))
		view.addConstraint(NSLayoutConstraint(item: pauseButton, attribute: NSLayoutAttribute.lastBaseline, relatedBy: NSLayoutRelation.equal, toItem: newButton, attribute: .lastBaseline, multiplier: 1.0, constant: 0.0))
		
		self.view = view
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.updateBackground()
    }
	
	func saveProfile() {
		do {
			try self.profile.write(to: self.profileURL)
		}
		catch {
			fatalError(error.localizedDescription)
		}
	}
	
	@objc func newGame(_ sender: UIButton) {
		UIView.animate(withDuration: 0.3) {
			self.gameView.game = self.profile.startNewGame()
			self.saveProfile()
			self.updateBackground()
		}
	}
	
	@objc func togglePause(_ sender: UIButton) {
		var isPaused = sender.isSelected
		isPaused = !isPaused
		sender.isSelected = isPaused
		self.gameView.isUserInteractionEnabled = !isPaused
		UIView.animate(withDuration: 0.3) {
			self.gameView.alpha = isPaused ? 0.25 : 1.0
		}
	}
	
	//MARK: - Game View
	func gameView(_ gameView: TTTGameView, imageFor player: TTTMovePlayer) -> UIImage {
		return self.profile.image(for: player)
	}
	
	func gameView(_ gameView: TTTGameView, colorFor player: TTTMovePlayer) -> UIColor {
		return self.profile.color(for: player)
	}
	
	func gameView(_ gameView: TTTGameView, canSelect xPosition: TTTMoveXPosition, yPosition: TTTMoveYPosition) -> Bool {
		return gameView.game.canAddMoveWithXPosition(xPosition, yPosition: yPosition)
	}
	
	func gameView(_ gameView: TTTGameView, didSelect xPosition: TTTMoveXPosition, yPosition: TTTMoveYPosition) {
		UIView.animate(withDuration: 0.3) {
			gameView.game.addMoveWithXPosition(xPosition, yPosition: yPosition)
			gameView.updateGameState()
			self.saveProfile()
			self.updateBackground()
		}
	}
	
	@objc func iconDidChange(_ notification: NSNotification) {
		self.gameView.updateGameState()
	}
	
	var isOver: Bool {
		return self.gameView.game?.result != TTTGameResult.inProgress
	}
	
	func updateBackground() {
		let isOver = self.isOver
		self.gameView.gridColor = isOver ? UIColor.white : UIColor.black
		self.view.backgroundColor = isOver ? UIColor.black : UIColor.white
		self.setNeedsStatusBarAppearanceUpdate()
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return self.isOver ? UIStatusBarStyle.lightContent : UIStatusBarStyle.default
	}
	
}
