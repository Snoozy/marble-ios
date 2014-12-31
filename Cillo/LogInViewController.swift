//
//  LogInViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 12/20/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

// TODO: Revamp this entire VC in storyboard and code to look nice and be more functional.

/// Handles user login and signup actions.
///
/// Note: Present this UIViewController if NSUserDefaults does not have values for the .Auth and .User. keys.
class LogInViewController: UIViewController {
  
  // MARK: - IBOutlets
  
  /// Space for user to enter their username for logging in.
  @IBOutlet weak var userTextField: UITextField!
  
  /// Space for user to enter their password for logging in.
  @IBOutlet weak var passwordTextField: UITextField!
  
  /// Activity indicator used for network interactions.
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  // MARK: - Constants
  
  /// Segue Identifier in Storyboard for this UIViewController to TabViewController
  class var SegueIdentifierThisToTab: String {
    get {
      return "LoginToTab"
    }
  }
  
  // MARK: - UIViewController
  
  // Make Root VCs retrieve their data after user logged in.
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == LogInViewController.SegueIdentifierThisToTab {
      if let destination = segue.destinationViewController as? TabViewController {
        for vc in destination.viewControllers! {
          if vc is FormattedNavigationViewController {
            if let visibleVC = vc.visibleViewController as? HomeTableViewController {
              visibleVC.retrievePosts()
            } else if visibleVC as? MyGroupsTableViewController {
              visibleVC.retrieveGroups()
            } else if visibleVC as? MeTableViewController {
              visibleVC.retrieveData()
            }
          } else if vc as? HomeTableViewController {
            vc.retrievePosts()
          } else if vc as? MyGroupsTableViewController {
            vc.retrieveGroups()
          } else if vc as? MeTableViewController {
            vc.retrieveData()
          }
        }
      }
    }
  }
  
  // MARK: - IBActions
  
  /// Sends login request when Login Button is pressed.
  ///
  /// If successful, sends a SelfInfo request to set up NSUserDefaults.
  ///
  /// If successful, NSUserDefaults will contain a value for .Auth and .User.
  @IBAction func login(sender: UIButton) {
    activityIndicator.start()
    DataManager.sharedInstance.login(userTextField.text, password: passwordTextField.text, { (error, result) -> Void in
      self.activityIndicator.stop()
      if error != nil {
        println(error)
        error!.showAlert()
      } else {
        
        NSUserDefaults.standardUserDefaults().setValue(result!, forKey: NSUserDefaults.Auth)
        
        DataManager.sharedInstance.getSelfInfo( { (error, user) -> Void in
          self.activityIndicator.stop()
          if error != nil {
            println(error)
            error!.showAlert()
          } else {
            
            NSUserDefaults.standardUserDefaults().setValue(user!, forKey: NSUserDefaults.User)
            let alert = UIAlertView(title: "Login Successful", message: "", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            self.performSegueWithIdentifier(LogInViewController.SegueIdentifierThisToTab, sender: self)
          }
        })
      }
    })
    
  }
  
  /// Attempts to register user with server.
  ///
  /// Note: Currently this UIViewController has no space for name and email. Default emails are used as filler.
  ///
  /// Note: User must login after registering.
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
