//
//  TTTGameView.swift
//  TicTacToeApp_Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/12/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

let TTTGameViewLineWidth: CGFloat = 4.0

protocol TTTGameViewDelegate: class {
	
	func gameView(_ gameView: TTTGameView, imageFor player: TTTMovePlayer) -> UIImage
	func gameView(_ gameView: TTTGameView, colorFor player: TTTMovePlayer) -> UIColor
	
	func gameView(_ gameView: TTTGameView, canSelect xPosition: TTTMoveXPosition, yPosition:TTTMoveYPosition) -> Bool
	func gameView(_ gameView: TTTGameView, didSelect xPosition: TTTMoveXPosition, yPosition:TTTMoveYPosition)
}

extension TTTGameViewDelegate {
	func gameView(_ gameView: TTTGameView, canSelect xPosition: TTTMoveXPosition, yPosition:TTTMoveYPosition) -> Bool {
		return false
	}
	func gameView(_ gameView: TTTGameView, didSelect xPosition: TTTMoveXPosition, yPosition:TTTMoveYPosition) {
		
	}

}

class TTTGameView: UIView {

	var delegate: TTTGameViewDelegate?
	var game: TTTGame! {
		didSet {
			if self.game != nil {
				self.updateGameState()
			}
		}
	}
	
	var gridColor: UIColor! {
		didSet {
			if self.gridColor != nil {
				self.updateGridColor()
			}
		}
	}
	var horizontalLineViews: [UIView]!
	var verticalLineViews: [UIView]!
	var moveImageViews: [UIImageView]!
	var moveImageViewReuseQueue: [UIImageView]!
	var _lineView: TTTGameLineView!
	
	var moveImageView: UIImageView {
		var moveView = self.moveImageViewReuseQueue.first
		if moveView != nil {
			self.moveImageViewReuseQueue.remove(at: self.moveImageViewReuseQueue.index(of: moveView!)!)
		} else {
			moveView = UIImageView()
			self.addSubview(moveView!)
		}
		
		self.moveImageViews.append(moveView!)
		return moveView!
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.gridColor = UIColor.black
		self.horizontalLineViews =  [self.lineView(), self.lineView()]
		self.verticalLineViews =  [self.lineView(), self.lineView()]
		self.updateGridColor()
		
		self.moveImageViews = []
		self.moveImageViewReuseQueue = []
		
		let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGame(_:)))
		self.addGestureRecognizer(gestureRecognizer)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func lineView() -> UIView {
		let view = UIView()
		self.addSubview(view)
		return view
	}
	
	@objc func tapGame(_ gestureRecognizer: UITapGestureRecognizer) {
		if gestureRecognizer.state == .recognized {
			let point = gestureRecognizer.location(in: self)
			let bounds = self.bounds
			
			var normalizedPoint = point
			normalizedPoint.x -= bounds.midX
			normalizedPoint.x *= 3.0 / bounds.size.width
			normalizedPoint.x = round(normalizedPoint.x)
			normalizedPoint.x = max(normalizedPoint.x, -1)
			normalizedPoint.x = min(normalizedPoint.x, 1)
			let xPosition = normalizedPoint.x;
			
			normalizedPoint.y -= bounds.midY
			normalizedPoint.y *= 3.0 / bounds.size.height
			normalizedPoint.y = round(normalizedPoint.y)
			normalizedPoint.y = max(normalizedPoint.y, -1)
			normalizedPoint.y = min(normalizedPoint.y, 1)
			let yPosition = normalizedPoint.y
			
			if (self.delegate?.gameView(self, canSelect: TTTMoveXPosition(rawValue: Int(xPosition))!, yPosition: TTTMoveYPosition(rawValue: Int(yPosition))!))! {
				self.delegate?.gameView(self, didSelect: TTTMoveXPosition(rawValue: Int(xPosition))!, yPosition: TTTMoveYPosition(rawValue: Int(yPosition))!)
			}

		}
	}
	
	func point(for xPosition: TTTMoveXPosition, yPosition: TTTMoveYPosition) -> CGPoint {
		let bounds = self.bounds;
		var point = CGPoint(x: bounds.midX, y: bounds.midY)
		point.x += CGFloat(xPosition.rawValue) * bounds.size.width / 3.0
		point.y += CGFloat(yPosition.rawValue) * bounds.size.height / 3.0
		return point
	}
	
	func set(_ move: TTTMove, for moveView: UIImageView) {
		moveView.image = self.delegate?.gameView(self, imageFor: move.player)
		moveView.center = self.point(for: move.xPosition, yPosition: move.yPosition)
	}
	
	func setVisible(_ visible: Bool, for moveView: UIImageView) {
		if (visible) {
			moveView.sizeToFit()
			moveView.alpha = 1.0
		} else {
			moveView.bounds = CGRect.zero
			moveView.alpha = 0.0
		}
	}
	
	func updateGameState() {
		let moves = self.game?.moves ?? []
		let moveCount = moves.count
		let moveImageViews = self.moveImageViews ?? []
		
		for (viewIndex, moveView) in moveImageViews.enumerated() {
			if (viewIndex < moveCount) {
				let move = moves[viewIndex]
				self.set(move, for: moveView)
				self.setVisible(true, for: moveView)
			} else {
				self.setVisible(false, for: moveView)
				self.moveImageViewReuseQueue.append(moveView)
				self.moveImageViews.remove(at: self.moveImageViews.index(of: moveView)!)
			}
		}
		
		for moveIndex in self.moveImageViews.count..<moveCount {
			let move = moves[moveIndex]
			let moveView = self.moveImageView
			UIView.performWithoutAnimation {
				self.set(move, for: moveView)
				self.setVisible(false, for: moveView)
			}
			
			self.setVisible(true, for: moveView)
		}
		
		var winningPlayer: TTTMovePlayer!
		var startXPosition, endXPosition: TTTMoveXPosition!
		var startYPosition, endYPosition: TTTMoveYPosition!
		let hasWinner = self.game.getWinningPlayer(&winningPlayer, startXPosition: &startXPosition, startYPosition: &startYPosition, endXPosition: &endXPosition, endYPosition: &endYPosition)
		if hasWinner {
			if self._lineView == nil {
				self._lineView = TTTGameLineView()
				_lineView.alpha = 0.0
				self.addSubview(self._lineView)
			}
			let path = UIBezierPath()
			path.move(to: self.point(for: startXPosition, yPosition: startYPosition))
			path.addLine(to: self.point(for: endXPosition, yPosition: endYPosition))
			self._lineView.path = path
			self._lineView.color = self.delegate?.gameView(self, colorFor: winningPlayer)
		}
		self._lineView?.alpha = hasWinner ? 1.0 : 0.0
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let bounds = self.bounds
		
		for (viewIndex, view) in self.horizontalLineViews.enumerated() {
			view.bounds = CGRect(x: 0, y: 0, width: bounds.size.width, height: TTTGameViewLineWidth)
			view.center = CGPoint(x: bounds.midX, y: round(bounds.size.height * CGFloat(viewIndex + 1) / 3.0))
		}
		
		for (viewIndex, view) in self.verticalLineViews.enumerated() {
			view.bounds = CGRect(x: 0, y: 0, width: TTTGameViewLineWidth, height: bounds.size.height)
			view.center = CGPoint(x: round(bounds.size.width * CGFloat(viewIndex + 1) / 3.0), y: bounds.midY)
		}
		self.updateGameState()
	}

	func updateGridColor() {
		for view in self.horizontalLineViews {
			view.backgroundColor = self.gridColor
		}
		
		for view in self.verticalLineViews {
			view.backgroundColor = self.gridColor
		}
	}
	
}


class TTTGameLineView: UIView {
	var path: UIBezierPath! {
		didSet {
			if self.path != nil {
				self.shapeLayer.path = self.path.cgPath
			}
		}
	}
	
	var color: UIColor! {
		didSet {
			if self.color != nil {
				self.shapeLayer.strokeColor = self.color.cgColor
			}
		}
	}
	
	override class var layerClass: AnyClass {
		return CAShapeLayer.self
	}
	
	var shapeLayer: CAShapeLayer {
		return (self.layer as! CAShapeLayer)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.shapeLayer.lineWidth = 2.0
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
