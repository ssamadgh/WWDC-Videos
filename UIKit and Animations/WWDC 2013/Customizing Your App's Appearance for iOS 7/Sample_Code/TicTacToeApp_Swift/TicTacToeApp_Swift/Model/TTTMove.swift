//
//  TTTMove.swift
//  TicTacToeApp_Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/9/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

enum TTTMovePlayer: Int {
	case me, enemy
}

enum TTTMoveXPosition: Int {
	case left = -1
	case center = 0
	case right = 1
}

enum TTTMoveYPosition: Int {
	case top = -1
	case center = 0
	case bottom = 1
}

class TTTMove: NSObject, NSCoding {

	let TTTMoveEncodingKeyPlayer = "player"
	let TTTMoveEncodingKeyXPosition = "xPosition"
	let TTTMoveEncodingKeyYPosition = "yPosition"

	var player: TTTMovePlayer!
	var xPosition: TTTMoveXPosition!
	var yPosition: TTTMoveYPosition!
	
	init(player: TTTMovePlayer, xPosition: TTTMoveXPosition, yPosition: TTTMoveYPosition) {
		super.init()
		self.player = player
		self.xPosition = xPosition
		self.yPosition = yPosition
	}
	
	override convenience init() {
		self.init(player: .me, xPosition: .center, yPosition: .center)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init()
		self.player = TTTMovePlayer(rawValue: aDecoder.decodeInteger(forKey: TTTMoveEncodingKeyPlayer))
		self.xPosition = TTTMoveXPosition(rawValue: aDecoder.decodeInteger(forKey: TTTMoveEncodingKeyXPosition))
		self.yPosition = TTTMoveYPosition(rawValue: aDecoder.decodeInteger(forKey: TTTMoveEncodingKeyYPosition))

	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(self.player.rawValue, forKey: TTTMoveEncodingKeyPlayer)
		aCoder.encode(self.xPosition.rawValue, forKey: TTTMoveEncodingKeyXPosition)
		aCoder.encode(self.yPosition.rawValue, forKey: TTTMoveEncodingKeyYPosition)
	}
	
	override var hash: Int {
		var hash: Int = 1
		hash = 31 * hash + self.player.rawValue
		hash = 31 * hash + self.xPosition.rawValue + 1
		hash = 31 * hash + self.yPosition.rawValue + 1
		return hash
	}
	
	override func isEqual(_ object: Any?) -> Bool {
		if !(object is TTTMove) {
			return false
		}
		
		let move = object as! TTTMove
		return self.player == move.player && self.xPosition == move.xPosition && self.yPosition == move.yPosition
	}
	
}
