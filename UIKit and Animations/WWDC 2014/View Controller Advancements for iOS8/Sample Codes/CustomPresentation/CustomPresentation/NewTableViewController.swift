//
//  NewTableViewController.swift
//  CustomPresentation
//
//  Created by Seyed Samad Gholamzadeh on 7/25/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class NewTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		self.tableView.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
		self.tableView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
		self.view.layer.cornerRadius = 20
		self.definesPresentationContext = true
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 10
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.backgroundColor = .clear
		cell.textLabel?.text = "Hello Apple, Im Comming"
        // Configure the cell...

        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let svc = SecondViewController()
		svc.modalPresentationStyle = .overCurrentContext
		self.present(svc, animated: true, completion: nil)
	}

}
