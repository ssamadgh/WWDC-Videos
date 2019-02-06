//
//  ShowViewController.swift
//  CoreDataBooks_Swift
//
//  Created by Seyed Samad Gholamzadeh on 2/4/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ShowViewController: DetailViewController<DetailVCPresenter> {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
	

}
