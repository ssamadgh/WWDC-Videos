//
//  LoginViewController.swift
//  OperationScreencast
//
//  Created by Ben Scheirman on 7/21/15.
//  Copyright (c) 2015 NSScreencast. All rights reserved.
//

import UIKit

@objc protocol LoginViewControllerDelegate {
    func loginViewControllerDidLogin(loginViewController: LoginViewController)
}

class LoginViewController : UITableViewController, UITextFieldDelegate {
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    var delegate: LoginViewControllerDelegate?
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicator.hidesWhenStopped = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: activityIndicator)
    }
    
    @IBAction func submit(_ button: UIBarButtonItem!) {
		button.isEnabled = false
        activityIndicator.startAnimating()
        
//        let delayInMs = NSEC_PER_MSEC * UInt64(1200)
//		let when = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(delayInMs))
		let when = DispatchTime.now() + DispatchTimeInterval.milliseconds(1200)
		DispatchQueue.main.asyncAfter(deadline: when) {
            self.activityIndicator.stopAnimating()
			button.isEnabled = true
            
			if !self.emailTextField.text!.isEmpty && self.passwordTextField.text == "password" {
                self.loginSuccess()
            } else {
                self.loginFailure()
            }
        }
    }
    
    func loginSuccess() {
		AuthStore.instance.login(authToken: "asdf123")
		delegate?.loginViewControllerDidLogin(loginViewController: self)
		dismiss(animated: true, completion: nil)
    }
    
    func loginFailure() {
		let alert = UIAlertController(title: "Invalid Login", message: "Please check your credentials and try again", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
		present(alert, animated: true, completion: nil)
    }
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            passwordTextField.resignFirstResponder()
			submit(navigationItem.rightBarButtonItem)
        }
        return false
    }
	
}
