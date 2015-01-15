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
/// **Note:** Present this UIViewController if NSUserDefaults does not have values for the .Auth and .User. keys.
class LogInViewController: UIViewController {
  
  // MARK: IBOutlets
  
  /// Space for user to enter their username for logging in.
  @IBOutlet weak var userTextView: UITextView!
  
  /// Space for user to enter their password for logging in.
  @IBOutlet weak var passwordTextView: UITextView!
  
  // MARK: Constants
  
  /// Segue Identifier in Storyboard for this UIViewController to TabViewController
  var SegueIdentifierThisToTab: String {
    get {
      return "LoginToTab"
    }
  }
  
  /// Segue Identifier in Storyboard for this UIViewController to RegisterViewController
  var SegueIdentifierThisToRegister: String {
    get {
      return "LoginToRegister"
    }
  }
  
  // MARK: UIViewController
  
  override func viewDidLoad() {
    passwordTextView.secureTextEntry = true
  }
  
  /// Make Root VCs retrieve their data after user logged in.
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == SegueIdentifierThisToTab {
      if let destination = segue.destinationViewController as? TabViewController {
        for vc in destination.viewControllers! {
          if let vc = vc as? FormattedNavigationViewController {
            if let visibleVC = vc.visibleViewController as? HomeTableViewController {
              visibleVC.retrieveData()
            } else if let visibleVC = vc.visibleViewController as? MyGroupsTableViewController {
              visibleVC.retrieveData()
            } else if let visibleVC = vc.visibleViewController as? MeTableViewController {
              visibleVC.retrieveData()
            }
          } else if let vc = vc as? HomeTableViewController {
            vc.retrieveData()
          } else if let vc = vc as? MyGroupsTableViewController {
            vc.retrieveData()
          } else if let vc = vc as? MeTableViewController {
            vc.retrieveData()
          }
        }
      }
    } else if segue.identifier == SegueIdentifierThisToRegister {
      // do not need to pass any data
    }
  }
  
  // MARK: Helper Functions
  
  /// Sends login request to Cillo Servers.
  ///
  /// If successful, NSUserDefaults will contain a value for .Auth.
  ///
  /// :param: completion The completion block for the login.
  /// :param: success True if login request was successful. If error was received, it is false.
  func login(completion: (success: Bool) -> Void) {
    let activityIndicator = addActivityIndicatorToCenterWithText("Logging in...")
    DataManager.sharedInstance.login(userTextView.text, password: passwordTextView.text, { (error, result) -> Void in
      activityIndicator.removeFromSuperview()
      if error != nil {
        println(error!)
        error!.showAlert()
        completion(success: false)
      } else {
        println(result!)
        NSUserDefaults.standardUserDefaults().setValue(result!, forKey: NSUserDefaults.Auth)
        completion(success: true)
      }
    })
  }
  
  /// Sends a request to describe the logged in User to Cillo Servers.
  ///
  /// If successful, NSUserDefaults will contain a value for .User.
  ///
  /// :param: completion The completion block for the request.
  /// :param: success True if desribe request was successful. If error was received, it is false.
  func retrieveMe(completion: (success: Bool) -> Void) {
    let activityIndicator = addActivityIndicatorToCenterWithText("Retrieving User...")
    DataManager.sharedInstance.getSelfInfo( { (error, user) -> Void in
      activityIndicator.removeFromSuperview()
      if error != nil {
        println(error!)
        error!.showAlert()
        completion(success: false)
      } else {
        println(user!)
        NSUserDefaults.standardUserDefaults().setValue(user!.userID, forKey: NSUserDefaults.User)
        completion(success: true)
      }
    })
  }
  
  // MARK: IBActions
  
  /// Triggers segue to RegisterViewController when registerButton is pressed.
  @IBAction func triggerRegisterSegueOnButton(sender: UIButton) {
    self.performSegueWithIdentifier(SegueIdentifierThisToRegister, sender: sender)
  }
  
  /// Triggers segue to TabViewController when loginButton is pressed if a login attempt is successful.
  @IBAction func triggerTabSegueOnButton(sender: UIButton) {
    login( { (loginSuccess) -> Void in
      if loginSuccess {
        self.retrieveMe( { (retrieveMeSuccess) -> Void in
          if retrieveMeSuccess {
            let alert = UIAlertView(title: "Login Successful", message: "", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            self.performSegueWithIdentifier(self.SegueIdentifierThisToTab, sender: sender)
          }
        })
      }
    })
  }
  
  /// Allows RegisterViewController to unwind its modal segue.
  @IBAction func unwindToLogin(sender: UIStoryboardSegue) {
    
  }
  
}
