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
        if let sender = sender as? User {
          destination.endUser = sender
        }
        destination.selectedIndex = destination.homeTabIndex
        destination.forceDataRetrievalUponUnwinding()
      }
      if UIApplication.sharedApplication().respondsToSelector("registerForRemoteNotifications") {
        UIApplication.sharedApplication().registerForRemoteNotifications()
      } else {
        UIApplication.sharedApplication().registerForRemoteNotificationTypes(.Alert | .Badge | .Sound)
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupColorScheme()
    setupOutletAppearances()
    setupOutletDelegates()
  }
  
  // MARK: UIResponder
  
  override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    if emailTextField.isFirstResponder() {
      emailTextField.resignFirstResponder()
    } else if passwordTextField.isFirstResponder() {
      passwordTextField.resignFirstResponder()
    }
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
  func login(completionHandler: (user: User?) -> ()) {
    DataManager.sharedInstance.loginWithEmail(emailTextField.text, andPassword: passwordTextField.text) { result in
      switch result {
      case .Error(let error):
        self.handleError(error)
        completionHandler(user: nil)
      case .Value(let element):
        let (auth, user) = element.unbox
        var success = KeychainWrapper.setAuthToken(auth)
        success = KeychainWrapper.setUserID(user.userID)
        completionHandler(user: user)
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
    DataManager.sharedInstance.getEndUserInfo { result in
      switch result {
      case .Error(let error):
        self.handleError(error)
        completionHandler(success: false)
      case .Value(let element):
        var success = false
        success = KeychainWrapper.setUserID(element.unbox.userID)
        completionHandler(success: success)
      }
    }
  }
  
  // MARK: Error Handling Helper Functions
  
  override func handlePasswordIncorrectError(error: NSError) {
    if objc_getClass("UIAlertController") != nil {
      let alert = UIAlertController(title: "Error", message: "Username and password do not match.", preferredStyle: .Alert)
      alert.addAction(UIAlertAction(title: "Ok", style: .Cancel) { _ in
      })
      presentViewController(alert, animated: true, completion: nil)
    } else {
      let alert = UIAlertView(title: "Error", message: "Username and password do not match.", delegate: nil, cancelButtonTitle: "Ok")
      alert.show()
    }
    
  }
  
  override func handleUserUnauthenticatedError(error: NSError) {
    error.showAlert()
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
    login { user in
      if let user = user {
        let alert = UIAlertView(title: "Login Successful", message: "", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
        self.performSegueWithIdentifier(SegueIdentifiers.loginToTab, sender: user)
        sender.enabled = true
      } else {
        sender.enabled = true
      }
    }
  }
  
  /// Allows RegisterViewController to unwind its modal segue.
  @IBAction func unwindToLogin(sender: UIStoryboardSegue) {
  }
}


