//
//  TTTProfile.swift
//  TicTacToeApp_Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/9/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

enum TTTProfileIcon: Int {
	case X, O
}

let TTTProfileIconDidChangeNotification = "TTTProfileIconDidChangeNotification"


class TTTProfile: NSObject, NSCoding {

	let TTTProfileEncodingKeyIcon = "icon"
	let TTTProfileEncodingKeyCurrentGame = "currentGame"
	let TTTProfileEncodingKeyGames = "games"

	var icon: TTTProfileIcon! {
		didSet {
			NotificationCenter.default.post(name: NSNotification.Name(rawValue: TTTProfileIconDidChangeNotification), object: self)
		}
	}
	
	var currentGame: TTTGame!
	var games: [TTTGame] = []
	
	
	override init() {
		super.init()
		
		self.icon = TTTProfileIcon(rawValue: 0)
		self.currentGame = TTTGame()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init()
		
		self.icon = TTTProfileIcon(rawValue: aDecoder.decodeInteger(forKey: TTTProfileEncodingKeyIcon))
		self.currentGame = aDecoder.decodeObject(forKey: TTTProfileEncodingKeyCurrentGame) as! TTTGame
		self.games = aDecoder.decodeObject(forKey: TTTProfileEncodingKeyGames) as! [TTTGame]
		
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(self.icon.rawValue, forKey: TTTProfileEncodingKeyIcon)
		aCoder.encode(self.currentGame, forKey: TTTProfileEncodingKeyCurrentGame)
		aCoder.encode(self.games, forKey: TTTProfileEncodingKeyGames)
	}
	
	static func profileWithContentsOf(_ url: URL) -> TTTProfile? {
		do {
			let data = try Data(contentsOf: url)
			return NSKeyedUnarchiver.unarchiveObject(with: data) as? TTTProfile
		}
		catch {
			return nil
		}
	}
	
	func write(to url: URL) throws {
		let data = NSKeyedArchiver.archivedData(withRootObject: self)
		try data.write(to: url)
	}
	
	func startNewGame() -> TTTGame {
		
		if self.currentGame != nil && self.currentGame.moves.count == 0 {
			return self.currentGame
		}
		
		let game = TTTGame()
		var games = self.games
		games.insert(game, at: 0)
		self.games = games
		
		self.currentGame = game
		
		return game
	}
	
	func numberOfGames(with result: TTTGameResult) -> Int {
		var count: Int = 0
		
		for game in self.games {
			if game.result == result {
				count += 1
			}
		}
		return count
	}
	
	//MARK: - Images
	
	func icon(for player: TTTMovePlayer) -> TTTProfileIcon {
		let myIcon = self.icon!
		return player == .me ? myIcon : TTTProfileIcon(rawValue: 1 - myIcon.rawValue)!
	}
	
	func image(for player: TTTMovePlayer) -> UIImage {
		let icon = self.icon(for: player)
		return TTTProfile.image(for: icon)
	}

	func color(for player: TTTMovePlayer) -> UIColor {
		let icon = self.icon(for: player)
		return TTTProfile.color(for: icon)
	}

	static func image(for icon: TTTProfileIcon) -> UIImage {
		let imageName: String = icon == .X ? "x" : "o"
		return UIImage(named: imageName)!
	}

	static func smallImage(for icon: TTTProfileIcon) -> UIImage {
		let imageName: String = icon == .X ? "smallX" : "smallO"
		return UIImage(named: imageName)!
	}
	
	static func color(for icon: TTTProfileIcon) -> UIColor {
		return icon == TTTProfileIcon.X ? UIColor.red : UIColor.green
	}
}


