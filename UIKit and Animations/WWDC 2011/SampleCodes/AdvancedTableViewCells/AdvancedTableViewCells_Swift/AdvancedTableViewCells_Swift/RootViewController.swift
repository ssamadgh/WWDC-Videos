//
//  RootViewController.swift
//  AdvancedTableViewCells_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/25/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit


// Define one of the following macros to 1 to control which type of cell will be used.
let USE_INDIVIDUAL_SUBVIEWS_CELL: Bool = true	// use a xib file defining the cell
let USE_COMPOSITE_SUBVIEW_CELL: Bool =  true	// use a single view to draw all the content
let USE_HYBRID_CELL: Bool =              true	// use a single view to draw most of the content + separate label to render the rest of the content


class RootViewController: UITableViewController {

	let cellIdentifier = "ApplicationCell"
	
	/*
	Predefined colors to alternate the background color of each cell row by row
	(see tableView:cellForRowAtIndexPath: and tableView:willDisplayCell:forRowAtIndexPath:).
	*/
	let DARK_BACKGROUND: UIColor = UIColor(red: 151.0/255.0, green: 152.0/255.0, blue: 155.0/255.0, alpha: 1.0)
	let LIGHT_BACKGROUND: UIColor = UIColor(red: 172.0/255.0, green: 173.0/255.0, blue: 175.0/255.0, alpha: 1.0)
	
	@IBOutlet weak var tmpCell: ApplicationCell!
	
	var data: [Data]!
	
	// referring to our xib-based UITableViewCell ('IndividualSubviewsBasedApplicationCell')
	var cellNib: UINib!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationController?.navigationBar.tintColor = UIColor.darkGray
		
		// Configure the table view.
		self.tableView.rowHeight = 73.0
		self.tableView.backgroundColor = DARK_BACKGROUND
		self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
		
		// Load the data.
		let dataURL = Bundle.main.url(forResource: "Data", withExtension: "plist")!
		
		let data = try! Foundation.Data(contentsOf: dataURL)
		let decoder = PropertyListDecoder()

		self.data = try! decoder.decode([Data].self, from: data)
		
		// create our UINib instance which will later help us load and instanciate the
		// UITableViewCells's UI via a xib file.
		//
		// Note:
		// The UINib classe provides better performance in situations where you want to create multiple
		// copies of a nib file’s contents. The normal nib-loading process involves reading the nib file
		// from disk and then instantiating the objects it contains. However, with the UINib class, the
		// nib file is read from disk once and the contents are stored in memory.
		// Because they are in memory, creating successive sets of objects takes less time because it
		// does not require accessing the disk.
		//
		self.cellNib = UINib(nibName: "IndividualSubviewsBasedApplicationCell", bundle: nil)
		self.title = "Advanced Table View Cells"
	}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell: ApplicationCell!

        // Configure the cell...
		
		if USE_INDIVIDUAL_SUBVIEWS_CELL {
			
			self.cellNib.instantiate(withOwner: self, options: nil)
			cell = self.tmpCell
			self.tmpCell = nil
		}
		else if USE_COMPOSITE_SUBVIEW_CELL {
			cell = CompositeSubviewBasedApplicationCell(style: .default, reuseIdentifier: cellIdentifier)
		}
		else if USE_HYBRID_CELL {
			cell = HybridSubviewBasedApplicationCell(style: .default, reuseIdentifier: cellIdentifier)
		}
		
		// Display dark and light background in alternate rows -- see tableView:willDisplayCell:forRowAtIndexPath:.
		cell.useDarkBackground = (indexPath.row % 2 == 0)
		
		// Configure the data for the cell.
		let dataItem = data[indexPath.row]
		cell.icon = UIImage(named: dataItem.icon)
		cell.publisher = dataItem.publisher
		cell.name = dataItem.name
		cell.numRatings = dataItem.numRatings
		cell.rating = dataItem.rating
		cell.price = dataItem.price
		cell.accessoryType = .disclosureIndicator

        return cell
    }
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cell.backgroundColor = (cell as! ApplicationCell).useDarkBackground ? DARK_BACKGROUND : LIGHT_BACKGROUND
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
