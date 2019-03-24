//
//  ViewController.swift
//  TestStringConvertible
//
//  Created by Seyed Samad Gholamzadeh on 2/12/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		let apple = Apple(device: "iPhone")
		print(apple)
	}


}

struct Apple {
	
	var device: String
}

//extension Apple: CustomStringConvertible {
//
//	var description: String { return device }
//
//}

//extension Apple: CustomDebugStringConvertible {
//
//	var debugDescription: String { return device }
//}

extension Apple: CustomReflectable {

	var customMirror: Mirror {
		return Mirror(self, children: ["type of device": device])
	}
}
