//
//  JumpingText.swift
//  Animation101
//
//  Created by Seyed Samad Gholamzadeh on 3/7/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class JumpingText: NSObject {
	
	var letters: [CALayer]!
	var topOfString: CGFloat!

	func addTextLayers(to layer: CALayer) {
		
		// If necessary, create container for the text layers
		if letters == nil {
			letters = []
		}
		
		for letter in self.letters {
			letter.removeFromSuperlayer()
		}
		
		letters.removeAll()
		
		let font = CGFont("Courier" as CFString)
		let text = "The quick brown fox"
		let fontSize: CGFloat = 28
		// We are using a mono-spaced font, so
		let textWidth = text.count*Int(fontSize)
		// We want to center the text
		let xStart: CGFloat = layer.bounds.midX - CGFloat(textWidth)/2

		for _ in 0 ..< 1 {
			
			var pos = CGPoint(x: xStart, y: layer.bounds.maxY - 50)
			for k in 0 ..< text.count {
				let letter = CATextLayer()
				letter.foregroundColor = UIColor.blue.cgColor
				letter.bounds = CGRect(x: 0, y: 0, width: fontSize, height: fontSize*2)
				letter.position = pos
				letter.font = font
				letter.fontSize = fontSize
				let index = text.index(text.startIndex, offsetBy: k)
				letter.string = String(text[index])
				layer.addSublayer(letter)
				letters.append(letter)
				pos.x += fontSize
			}
		}
		
		topOfString = layer.bounds.maxY - 50
	}
	
	func removeTextLayers() {
		for letter in self.letters {
			letter.removeFromSuperlayer()
		}
	}
	

}
