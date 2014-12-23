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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == LogInViewController.SEGUE_IDENTIFIER_THIS_TO_TAB {
            if let destination = segue.destinationViewController as? TabViewController {
                for vc in destination.viewControllers! {
                    if vc is FormattedNavigationViewController {
                        if let visibleVC = vc.visibleViewController as? HomeTableViewController {
                            visibleVC.retrievePosts()
                        }
                    } else if vc is HomeTableViewController {
                        (vc as HomeTableViewController).retrievePosts()
                    }
                }
            }
            
        }
    }
    
    
    //MARK: - IBActions
    
    @IBAction func login(sender: UIButton) {
        activityIndicator.start()
        DataManager.sharedInstance.login(userTextField.text, password: passwordTextField.text, { (error, result) -> Void in
            self.activityIndicator.stop()
            if error != nil {
                println(error)
                error!.showAlert()
            } else {
                
                NSUserDefaults.standardUserDefaults().setValue(result!, forKey: NSUserDefaults.AUTH)
                let alert = UIAlertView(title: "Login Successful", message: "", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                
                self.performSegueWithIdentifier(LogInViewController.SEGUE_IDENTIFIER_THIS_TO_TAB, sender: self)
            }
        })
    }
    
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
