//
//  LogInViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 12/20/14.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

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
  /// :param: completion The completion block for the login.
  /// :param: success True if login request was successful. If error was received, it is false.
  func login(completion: (success: Bool) -> Void) {
    let activityIndicator = addActivityIndicatorToCenterWithText("Logging in...")
    DataManager.sharedInstance.login(emailTextField.text, password: passwordTextField.text) { error, result in
      activityIndicator.removeFromSuperview()
      if let error = error {
        println(error)
        error.showAlert()
        completion(success: false)
      } else {
        NSUserDefaults.standardUserDefaults().setValue(result!, forKey: NSUserDefaults.Auth)
        completion(success: true)
      }
    }
  }
  
  /// Sends a request to describe the logged in User to Cillo Servers.
  ///
  /// If successful, NSUserDefaults will contain a value for .User.
  ///
  /// :param: completion The completion block for the request.
  /// :param: success True if describe request was successful. If error was received, it is false.
  func retrieveMe(completion: (success: Bool) -> Void) {
    let activityIndicator = addActivityIndicatorToCenterWithText("Retrieving User...")
    DataManager.sharedInstance.getSelfInfo { error, user in
      activityIndicator.removeFromSuperview()
      if let error = error {
        println(error)
        error.showAlert()
        completion(success: false)
      } else {
        NSUserDefaults.standardUserDefaults().setValue(user!.userID, forKey: NSUserDefaults.User)
        completion(success: true)
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
    login { loginSuccess in
      if loginSuccess {
        self.retrieveMe { retrieveMeSuccess in
          if retrieveMeSuccess {
            let alert = UIAlertView(title: "Login Successful", message: "", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            self.performSegueWithIdentifier(SegueIdentifiers.loginToTab, sender: sender)
          }
        }
      }
    }
  }
  
  /// Allows RegisterViewController to unwind its modal segue.
  @IBAction func unwindToLogin(sender: UIStoryboardSegue) {
  }
}


