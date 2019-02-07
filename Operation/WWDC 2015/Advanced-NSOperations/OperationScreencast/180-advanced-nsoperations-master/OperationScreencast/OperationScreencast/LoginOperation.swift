//
//  LoginOperation.swift
//  OperationScreencast
//
//  Created by Ben Scheirman on 7/21/15.
//  Copyright (c) 2015 NSScreencast. All rights reserved.
//

import UIKit

class LoginOperation : ASOperation, LoginViewControllerDelegate {
	
    lazy var storyboard: UIStoryboard = {
        return UIStoryboard(name: "Main", bundle: nil)
    }()
    
    lazy var loginNavController: UINavigationController = {
        let nav = self.storyboard.instantiateViewController(withIdentifier: "loginNavigationController") as! UINavigationController
        let loginVC = nav.viewControllers.first! as! LoginViewController
        loginVC.delegate = self
        return nav
    }()
    
    lazy var presentationContext: UIViewController = {
        return UIApplication.shared.keyWindow!.rootViewController!
    }()
    
    override func execute() {
        if AuthStore.instance.isLoggedIn() {
            finish()
            return
        }

		DispatchQueue.main.async {
            self.presentationContext.present(self.loginNavController, animated: true, completion: nil)
        }
		
    }
    
    func loginViewControllerDidLogin(loginViewController: LoginViewController) {
        finish()
    }
}
