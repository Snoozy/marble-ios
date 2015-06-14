//
//  LogInViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 12/20/14.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

/// Handles end user login actions.
///
/// **Note:** Present this UIViewController if NSUserDefaults does not have values for the .Auth or .User. keys.
class LogInViewController: CustomViewController {
  
  // MARK: IBOutlets
  
  /// Field for end user to enter email.
  @IBOutlet weak var emailTextField: BottomBorderedTextField!
  
  /// Button allowing end user to login to their account.
  @IBOutlet weak var loginButton: UIButton!
  
  /// Field for end user to enter password.
  @IBOutlet weak var passwordTextField: BottomBorderedTextField!
  
  /// Button allowing end user to create a new account through RegisterViewController.
  @IBOutlet weak var registerButton: UIButton!
  
  // MARK: UIViewController
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Make Root VCs retrieve their data after user logged in.
    if segue.identifier == SegueIdentifiers.loginToTab {
      if let destination = segue.destinationViewController as? TabViewController {
        destination.forceDataRetrievalUponUnwinding()
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupColorScheme()
    setupOutletAppearances()
    setupOutletDelegates()
  }
  
  // MARK: Setup Helper Functions
  
  /// Sets up the colors of the Outlets according to the default scheme of the app.
  private func setupColorScheme() {
    let scheme = ColorScheme.defaultScheme
    registerButton.setTitleColor(scheme.touchableTextColor(), forState: .Normal)
    loginButton.backgroundColor = scheme.solidButtonBackgroundColor()
    loginButton.setTitleColor(scheme.solidButtonTextColor(), forState: .Normal)
    emailTextField.backgroundColor = scheme.bottomBorderedTextFieldBackgroundColor()
    passwordTextField.backgroundColor = scheme.bottomBorderedTextFieldBackgroundColor()
  }
  
  /// Sets up the appearance of Outlets that were not set in the storyboard.
  private func setupOutletAppearances() {
    loginButton.setupWithRoundedBorderOfStandardWidthAndColor()
  }
  
  /// Sets any delegates of Outlets that were not set in the storyboard.
  private func setupOutletDelegates() {
    passwordTextField.delegate = self
    emailTextField.delegate = self
  }
  
  // MARK: Networking Helper Functions
  
  /// Sends login request to Cillo Servers.
  ///
  /// If successful, NSUserDefaults will contain a value for .Auth.
  ///
  /// :param: completionHandler The completion block for the login.
  /// :param: success True if login request was successful. If error was received, it is false.
  func login(completionHandler: (success: Bool) -> ()) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    DataManager.sharedInstance.loginWithEmail(emailTextField.text, andPassword: passwordTextField.text) { error, result in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      if let error = error {
        println(error)
        error.showAlert()
        completionHandler(success: false)
      } else {
        var success = false
        if let token = result {
          success = KeychainWrapper.setAuthToken(token)
        }
        completionHandler(success: success)
      }
    }
  }
  
  /// Sends a request to describe the end user to Cillo Servers.
  ///
  /// If successful, NSUserDefaults will contain a value for .User.
  ///
  /// :param: completionHandler The completion block for the request.
  /// :param: success True if describe request was successful. If error was received, it is false.
  func retrieveEndUser(completionHandler: (success: Bool) -> ()) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    DataManager.sharedInstance.getEndUserInfo { error, user in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      if let error = error {
        println(error)
        error.showAlert()
        completionHandler(success: false)
      } else {
        let success = KeychainWrapper.setUserID(user!.userID)
        completionHandler(success: success)
      }
    }
  }
  
  // MARK: IBActions
  
  /// Triggers segue to RegisterViewController.
  ///
  /// :param: sender The button that is touched to send this function is registerButton.
  @IBAction func triggerRegisterSegueOnButton(sender: UIButton) {
    performSegueWithIdentifier(SegueIdentifiers.loginToRegister, sender: sender)
  }
  
  /// Triggers segue to TabViewController when loginButton is pressed if a login attempt is successful.
  ///
  /// :param: sender The button that is touched to send this function is loginButton.
  @IBAction func triggerTabSegueOnButton(sender: UIButton) {
    sender.enabled = false
    login { loginSuccess in
      if loginSuccess {
        self.retrieveEndUser { userSuccess in
          if userSuccess {
            let alert = UIAlertView(title: "Login Successful", message: "", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            self.performSegueWithIdentifier(SegueIdentifiers.loginToTab, sender: sender)
          } else {
            sender.enabled = true
          }
        }
      } else {
        sender.enabled = true
      }
    }
  }
  
  /// Allows RegisterViewController to unwind its modal segue.
  @IBAction func unwindToLogin(sender: UIStoryboardSegue) {
  }
}


