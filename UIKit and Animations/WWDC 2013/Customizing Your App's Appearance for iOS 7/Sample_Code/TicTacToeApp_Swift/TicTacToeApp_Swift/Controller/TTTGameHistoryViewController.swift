//
//  TTTGameHistoryViewController.swift
//  TicTacToeApp_Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/12/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

private let TTTPlayViewControllerMargin: CGFloat = 20.0

class TTTGameHistoryViewController: UIViewController, TTTGameViewDelegate {

	var profile: TTTProfile!
	
	var game: TTTGame! {
		didSet {
			self.gameView?.game = self.game
			self.ratingControl?.rating = self.game.rating
		}
	}
	
	var gameView: TTTGameView!
	var ratingControl: TTTRatingControl!

	init() {
		super.init(nibName: nil, bundle: nil)
		
		self.title = NSLocalizedString("Game", comment: "Game")
		
		self.ratingControl = TTTRatingControl(frame: CGRect(x: 0, y: 0, width: 30*5, height: 30))
		self.ratingControl.addTarget(self, action: #selector(changeRating(_:)), for: .valueChanged)
		self.navigationItem.titleView = self.ratingControl
		
		NotificationCenter.default.addObserver(self, selector: #selector(iconDidChange(_:)), name: NSNotification.Name(rawValue: TTTProfileIconDidChangeNotification), object: nil)
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
		view.backgroundColor = .white
		
		let gameView = TTTGameView()
		gameView.delegate = self
		gameView.isUserInteractionEnabled = false
		gameView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(gameView)
		self.gameView = gameView
		self.gameView.game = self.game
		
		let topHeight = UIApplication.shared.statusBarFrame.size.height + (self.navigationController?.navigationBar.frame.size.height)!
		
		let bindings = ["gameView" : gameView]
		let metrics = ["topHeight" : topHeight + TTTPlayViewControllerMargin, "bottomHeight" : TTTPlayViewControllerMargin, "margin" : TTTPlayViewControllerMargin]
		view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-margin-[gameView]-margin-|", options: NSLayoutFormatOptions(), metrics: metrics, views: bindings))
		view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-topHeight-[gameView]-bottomHeight-|", options: NSLayoutFormatOptions(), metrics: metrics, views: bindings))
		
		self.view = view
	}
	
	@objc func changeRating(_ sender: TTTRatingControl) {
		self.game.rating = sender.rating
	}
	
	//MARK: - Game View
	
	func gameView(_ gameView: TTTGameView, imageFor player: TTTMovePlayer) -> UIImage {
		return self.profile.image(for: player)
	}
	
	func gameView(_ gameView: TTTGameView, colorFor player: TTTMovePlayer) -> UIColor {
		return self.profile.color(for: player)
	}
	
	@objc func iconDidChange(_ notification: Notification) {
		self.gameView.updateGameState()
	}
	
}
