//
//  ViewController2.swift
//  CostumeTransition
//
//  Created by Seyed Samad Gholamzadeh on 11/7/1394 AP.
//  Copyright © 1394 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ViewController2: UIViewController {
    
    @IBOutlet weak var appleButton: UIButton!
    @IBOutlet weak var microsoftButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    }
    
	override func viewWillAppear(_ animated: Bool) {
//        UIView.animateWithDuration(2) { () -> Void in
//            self.view.alpha = 1
//        }

    }
    
	override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
