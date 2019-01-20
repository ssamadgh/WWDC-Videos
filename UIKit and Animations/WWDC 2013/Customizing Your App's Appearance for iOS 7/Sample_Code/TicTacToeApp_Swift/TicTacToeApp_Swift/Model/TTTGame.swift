//
//  TTTGame.swift
//  TicTacToeApp_Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/9/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

enum TTTGameResult: Int {
	case inProgress, victory, defeat, draw
}

let TTTMoveSidePositionsCount: Int = 3


class TTTGame: NSObject, NSCoding {

	let TTTGameEncodingKeyResult = "result"
	let TTTGameEncodingKeyRating = "rating"
	let TTTGameEncodingKeyDate = "date"
	let TTTGameEncodingKeyMoves = "moves"
	let TTTGameEncodingKeyCurrentPlayer = "currentPlayer"

	var result: TTTGameResult!
	var rating: Int!
	var date: Date!
	var moves: [TTTMove]!
	var currentPlayer: TTTMovePlayer!
	
	override init() {
		super.init()
		self.moves = []
		self.date = Date()
		self.rating = 0
		self.currentPlayer = TTTMovePlayer.me
		self.result = TTTGameResult(rawValue: 0)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init()
		
		self.result = TTTGameResult(rawValue: aDecoder.decodeInteger(forKey: TTTGameEncodingKeyResult))
		let rating = aDecoder.decodeInteger(forKey: TTTGameEncodingKeyRating)
		self.rating = rating
		self.date = aDecoder.decodeObject(forKey: TTTGameEncodingKeyDate) as! Date
		self.moves = aDecoder.decodeObject(forKey: TTTGameEncodingKeyMoves) as! [TTTMove]
		self.currentPlayer = TTTMovePlayer(rawValue: aDecoder.decodeInteger(forKey: TTTGameEncodingKeyCurrentPlayer))
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(self.result.rawValue, forKey: TTTGameEncodingKeyResult)
		let rating = self.rating!
		aCoder.encode(rating, forKey: TTTGameEncodingKeyRating)
		aCoder.encode(self.date, forKey: TTTGameEncodingKeyDate)
		aCoder.encode(self.moves, forKey: TTTGameEncodingKeyMoves)
		aCoder.encode(self.currentPlayer.rawValue, forKey: TTTGameEncodingKeyCurrentPlayer)
	}
	
	func canAddMoveWithXPosition(_ xPositiion: TTTMoveXPosition, yPosition: TTTMoveYPosition) -> Bool {
		if self.result != .inProgress {
			return false
		}
		var player: TTTMovePlayer?
		return !self.hasMoveForXPosition(xPositiion, yPosition: yPosition, player: &player)
	}
	
	func addMoveWithXPosition(_ xPosition: TTTMoveXPosition, yPosition: TTTMoveYPosition) {
		if !self.canAddMoveWithXPosition(xPosition, yPosition: yPosition) {
			return
		}
		
		let move = TTTMove(player: self.currentPlayer, xPosition: xPosition, yPosition: yPosition)
		var moves = self.moves
		moves?.append(move)
		self.moves = moves
		
		self.currentPlayer = self.currentPlayer == .me ? .enemy : .me
		
		self.updateGameResult()
	}
	
	func hasMoveForXPosition(_ xPositiion: TTTMoveXPosition, yPosition: TTTMoveYPosition, player: inout TTTMovePlayer?) -> Bool {
		
		for move in self.moves {
			if move.xPosition == xPositiion && move.yPosition == yPosition {
				if player != nil {
					player = move.player
				}
				return true
			}
		}
		
		return false
	}
	
	func getWinningPlayer(_ playerOut: inout TTTMovePlayer?, startXPosition: inout TTTMoveXPosition?, startYPosition: inout TTTMoveYPosition?, endXPosition: inout TTTMoveXPosition?, endYPosition: inout TTTMoveYPosition?, xPositions:[TTTMoveXPosition], yPositions: [TTTMoveYPosition]) -> Bool {
		
		var hasMove = false
		var player: TTTMovePlayer!
		
		for n in 0..<TTTMoveSidePositionsCount {
			var newPlayer: TTTMovePlayer! = TTTMovePlayer.me
			let newHasMove = self.hasMoveForXPosition(xPositions[n], yPosition: yPositions[n], player: &newPlayer)
			if newHasMove {
				if hasMove {
					if player != newPlayer {
						hasMove = false
						break
					}
				}
				else {
					hasMove = true
					player = newPlayer
				}
			}
			else {
				hasMove = false
				break
			}
		}
		
		if hasMove {
//			if playerOut != nil {
				playerOut = player
//			}
			
//			if startXPosition != nil  {
				startXPosition = xPositions[0]
//			}
			
//			if startYPosition != nil  {
				startYPosition = yPositions[0]
//			}
			
//			if endXPosition != nil {
				endXPosition = xPositions[TTTMoveSidePositionsCount - 1]
//			}
			
//			if endYPosition != nil {
				endYPosition = yPositions[TTTMoveSidePositionsCount - 1]
//			}

		}
		return hasMove
	}
	
	func getWinningPlayer(_ player: inout TTTMovePlayer?, startXPosition: inout TTTMoveXPosition?, startYPosition: inout TTTMoveYPosition?, endXPosition: inout TTTMoveXPosition?, endYPosition: inout TTTMoveYPosition?, xPosition: TTTMoveXPosition) -> Bool {
		
		var xPositions: [TTTMoveXPosition] = [TTTMoveXPosition].init(repeating: TTTMoveXPosition(rawValue: 0)!, count: TTTMoveSidePositionsCount)
		
		for n in 0..<TTTMoveSidePositionsCount {
			xPositions[n] = xPosition
		}
		
		var yPositions: [TTTMoveYPosition] = [TTTMoveYPosition].init(repeating: TTTMoveYPosition(rawValue: 0)!, count: 3)
		yPositions[0] = TTTMoveYPosition.top
		yPositions[1] = TTTMoveYPosition.center
		yPositions[2] = TTTMoveYPosition.bottom

		return self.getWinningPlayer(&player, startXPosition: &startXPosition, startYPosition: &startYPosition, endXPosition: &endXPosition, endYPosition: &endYPosition, xPositions: xPositions, yPositions: yPositions)
	}
	
	func getWinningPlayer(_ player: inout TTTMovePlayer?, startXPosition: inout TTTMoveXPosition?, startYPosition: inout TTTMoveYPosition?, endXPosition: inout TTTMoveXPosition?, endYPosition: inout TTTMoveYPosition?, yPosition: TTTMoveYPosition) -> Bool {
	
		var yPositions: [TTTMoveYPosition] = [TTTMoveYPosition].init(repeating: TTTMoveYPosition(rawValue: 0)!, count: TTTMoveSidePositionsCount)
		
		for n in 0..<TTTMoveSidePositionsCount {
			yPositions[n] = yPosition
		}
		
		var xPositions: [TTTMoveXPosition]! = [TTTMoveXPosition].init(repeating: TTTMoveXPosition(rawValue: 0)!, count: 3)
		xPositions[0] = TTTMoveXPosition.left
		xPositions[1] = TTTMoveXPosition.center
		xPositions[2] = TTTMoveXPosition.right
		
		return self.getWinningPlayer(&player, startXPosition: &startXPosition, startYPosition: &startYPosition, endXPosition: &endXPosition, endYPosition: &endYPosition, xPositions: xPositions, yPositions: yPositions)
	}
	
	func getWinningPlayer(_ player: inout TTTMovePlayer?, startXPosition: inout TTTMoveXPosition?, startYPosition: inout TTTMoveYPosition?, endXPosition: inout TTTMoveXPosition?, endYPosition: inout TTTMoveYPosition?, direction: Int) -> Bool {
	
		var xPositions: [TTTMoveXPosition]! = [TTTMoveXPosition].init(repeating: TTTMoveXPosition(rawValue: 0)!, count: abs(TTTMoveXPosition.right.rawValue-TTTMoveXPosition.left.rawValue) + 1)
		var yPositions: [TTTMoveYPosition]! = [TTTMoveYPosition].init(repeating: TTTMoveYPosition(rawValue: 0)!, count: abs(TTTMoveXPosition.right.rawValue-TTTMoveXPosition.left.rawValue) + 1)

		var n = 0
		
		for xPosition in TTTMoveXPosition.left.rawValue...TTTMoveXPosition.right.rawValue {
			xPositions[n] = TTTMoveXPosition(rawValue: xPosition)!
			yPositions[n] = TTTMoveYPosition(rawValue: xPosition * direction)!
			n += 1
		}
		
		return self.getWinningPlayer(&player, startXPosition: &startXPosition, startYPosition: &startYPosition, endXPosition: &endXPosition, endYPosition: &endYPosition, xPositions: xPositions, yPositions: yPositions)
	}
	
	func getWinningPlayer(_ player: inout TTTMovePlayer?, startXPosition: inout TTTMoveXPosition?, startYPosition: inout TTTMoveYPosition?, endXPosition: inout TTTMoveXPosition?, endYPosition: inout TTTMoveYPosition?) -> Bool {
	
		// Check for columns
		for xPosition in TTTMoveXPosition.left.rawValue...TTTMoveXPosition.right.rawValue {
			let hasWinner = self.getWinningPlayer(&player, startXPosition: &startXPosition, startYPosition: &startYPosition, endXPosition: &endXPosition, endYPosition: &endYPosition, xPosition: TTTMoveXPosition(rawValue: xPosition)!)
			if hasWinner {
				return hasWinner
			}
		}
		
		// Check for rows
		for yPosition in TTTMoveYPosition.top.rawValue...TTTMoveYPosition.bottom.rawValue {
			let hasWinner = self.getWinningPlayer(&player, startXPosition: &startXPosition, startYPosition: &startYPosition, endXPosition: &endXPosition, endYPosition: &endYPosition, yPosition: TTTMoveYPosition(rawValue: yPosition)!)
			if hasWinner {
				return hasWinner
			}
		}
		
		// Check for diagonals
		var hasWinner = getWinningPlayer(&player, startXPosition: &startXPosition, startYPosition: &startYPosition, endXPosition: &endXPosition, endYPosition: &endYPosition, direction: 1)
		if hasWinner {
			return hasWinner
		}
		
		hasWinner = getWinningPlayer(&player, startXPosition: &startXPosition, startYPosition: &startYPosition, endXPosition: &endXPosition, endYPosition: &endYPosition, direction: -1)
		if hasWinner {
			return hasWinner
		}

		return false
	}
	
	func calculateGameResult() -> TTTGameResult {
		var player: TTTMovePlayer!
		var startXPosition: TTTMoveXPosition?
		var startYPosition: TTTMoveYPosition?
		var endXPosition: TTTMoveXPosition?
		var endYPosition: TTTMoveYPosition?

		let hasWinner = self.getWinningPlayer(&player, startXPosition: &startXPosition, startYPosition: &startYPosition, endXPosition: &endXPosition, endYPosition: &endYPosition)
		if hasWinner {
			return player == .me ? .victory : .defeat
		}
		
		// Check for draw
		if self.moves.count == TTTMoveSidePositionsCount * TTTMoveSidePositionsCount {
			return .draw
		}
		
		return .inProgress
	}
	
	func updateGameResult() {
		if self.result == .inProgress {
			self.result = self.calculateGameResult()
		}
	}
	
}
