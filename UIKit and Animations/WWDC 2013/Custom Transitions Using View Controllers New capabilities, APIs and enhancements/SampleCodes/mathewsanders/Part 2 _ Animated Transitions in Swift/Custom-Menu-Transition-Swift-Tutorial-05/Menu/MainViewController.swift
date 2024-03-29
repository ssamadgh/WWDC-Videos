//
//  MainViewController.swift
//  Menu
//
//  Created by Mathew Sanders on 9/7/14.
//  Copyright (c) 2014 Mat. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {

	let transitionDelegate = TransitionDelegate()
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func unwindToMainViewController (_ sender: UIStoryboardSegue){
        
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let vc = segue.destination
		vc.transitioningDelegate = self.transitionDelegate
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
