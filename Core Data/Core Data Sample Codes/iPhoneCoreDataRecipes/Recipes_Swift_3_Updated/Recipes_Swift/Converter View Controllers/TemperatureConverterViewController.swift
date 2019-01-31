/*
  TemperatureConverterViewController.swift
  Recipes_Swift

  Created by Seyed Samad Gholamzadeh on 2/28/18.
  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.

Abstract:
View controller to display cooking temperatures in Centigrade, Fahrenheit, and Gas Mark.
*/


import UIKit

class TemperatureConverterViewController: UITableViewController {

	var temperatureData: [Any]! = {
		// Get the temperature data from the TemperatureData property list.
		let temperatureDataPath = Bundle.main.url(forResource: "TemperatureData", withExtension: "plist")
		let array = NSArray(contentsOf: temperatureDataPath!)
		return array as! [Any]
	}()
	
	let MyIdentifier = "MyIdentifier"
	
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
		self.temperatureData = nil
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.temperatureData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier, for: indexPath) as! TemperatureCell

		// Configure the temperature cell with the relevant data.
		let temperatureDictionary = self.temperatureData[indexPath.row] as! [String: String]
		cell.setTemperatureDataFrom(dictionary: temperatureDictionary)


        return cell
    }

}
