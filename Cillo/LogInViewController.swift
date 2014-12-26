//
//  LogInViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 12/20/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var userTextField: UITextField!

    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    //MARK: - Constants
    
    class var SEGUE_IDENTIFIER_THIS_TO_TAB : String {return "LoginToTab"}
    
    
    //MARK: - UIViewController
    
    ///Make Root VCs retrieve their data after user logged in
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == LogInViewController.SEGUE_IDENTIFIER_THIS_TO_TAB {
            if let destination = segue.destinationViewController as? TabViewController {
                for vc in destination.viewControllers! {
                    if vc is FormattedNavigationViewController {
                        if let visibleVC = vc.visibleViewController as? HomeTableViewController {
                            visibleVC.retrievePosts()
                        } else if visibleVC as? MyGroupsTableViewController {
                            visibleVC.retrieveGroups()
                        }
                    } else if vc as? HomeTableViewController {
                        vc.retrievePosts()
                    } else if vc as? MyGroupsTableViewController {
                        vc.retrieveGroups()
                    }
                }
            }
        }
    }
    
    
    //MARK: - IBActions
    
    ///Sends login request and if successful sends a SelfInfo request to set up NSUserDefaults. If successful, NSUserDefaults will contain a value for .AUTH and .USER
    @IBAction func login(sender: UIButton) {
        activityIndicator.start()
        var login = false
        DataManager.sharedInstance.login(userTextField.text, password: passwordTextField.text, { (error, result) -> Void in
            self.activityIndicator.stop()
            if error != nil {
                println(error)
                error!.showAlert()
            } else {
                
                NSUserDefaults.standardUserDefaults().setValue(result!, forKey: NSUserDefaults.AUTH)
                
                DataManager.sharedInstance.getSelfInfo( { (error, user) -> Void in
                    self.activityIndicator.stop()
                    if error != nil {
                        println(error)
                        error!.showAlert()
                    } else {
                        
                        NSUserDefaults.standardUserDefaults().setValue(user!, forKey: NSUserDefaults.USER)
                        let alert = UIAlertView(title: "Login Successful", message: "", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                        
                        self.performSegueWithIdentifier(LogInViewController.SEGUE_IDENTIFIER_THIS_TO_TAB, sender: self)
                    }
                })
            }
        })
        
    }
    
    ///Attempts to register user to server
    @IBAction func register(sender: UIButton) {
        activityIndicator.start()
        DataManager.sharedInstance.register(userTextField.text, name: "Andrew Daley", password: passwordTextField.text, email: "ajd93@cornell.edu", { (error, success) -> Void in
            self.activityIndicator.stop()
            if error != nil {
                println(error)
                error!.showAlert()
            } else {
                if success {
                    let alert = UIAlertView(title: "Registration Successful", message: "", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
        
            }
        })
    }

}
