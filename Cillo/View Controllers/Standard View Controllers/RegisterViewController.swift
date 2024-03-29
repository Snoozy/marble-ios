//
//  RegisterViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 1/8/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Handles end user registration.
class RegisterViewController: CustomViewController {

  // MARK: IBOutlets
  
  /// Field for end user to enter email.
  @IBOutlet weak var emailTextField: BottomBorderedTextField!
  
  /// Field for end user to enter name.
  @IBOutlet weak var nameTextField: BottomBorderedTextField!
  
  /// Field for end user to enter password
  @IBOutlet weak var passwordTextField: BottomBorderedTextField!
  
  /// Button allowing end user to create a new account.
  @IBOutlet weak var registerButton: UIButton!
  
  /// Field for end user to enter username
  @IBOutlet weak var userTextField: BottomBorderedTextField!
  
  // MARK: UIViewController
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == SegueIdentifiers.registerToLogin {
      resignTextFieldResponders()
    } else if segue.identifier == SegueIdentifiers.registerToTab {
      if let destination = segue.destinationViewController as? TabViewController {
        if let user = sender as? User {
          destination.endUser = user
        }
        destination.selectedIndex = destination.discoverTabIndex
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
    if nameTextField.isFirstResponder() {
      nameTextField.resignFirstResponder()
    } else if emailTextField.isFirstResponder() {
      emailTextField.resignFirstResponder()
    } else if passwordTextField.isFirstResponder() {
      passwordTextField.resignFirstResponder()
    } else if userTextField.isFirstResponder() {
      userTextField.resignFirstResponder()
    }
  }
  
  // MARK: Setup Helper Functions
  
  /// Hides the keyboard of all textfields.
  private func resignTextFieldResponders() {
    emailTextField.resignFirstResponder()
    nameTextField.resignFirstResponder()
    passwordTextField.resignFirstResponder()
    userTextField.resignFirstResponder()
  }
  
  /// Sets up the colors of the Outlets according to the default scheme of the app.
  private func setupColorScheme() {
    let scheme = ColorScheme.defaultScheme
    emailTextField.backgroundColor = scheme.bottomBorderedTextFieldBackgroundColor()
    userTextField.backgroundColor = scheme.bottomBorderedTextFieldBackgroundColor()
    nameTextField.backgroundColor = scheme.bottomBorderedTextFieldBackgroundColor()
    passwordTextField.backgroundColor = scheme.bottomBorderedTextFieldBackgroundColor()
    registerButton.backgroundColor = scheme.solidButtonBackgroundColor()
    registerButton.setTitleColor(scheme.solidButtonTextColor(), forState: .Normal)
  }
  
  /// Sets up the appearance of Outlets that were not set in the storyboard.
  private func setupOutletAppearances() {
    registerButton.setupWithRoundedBorderOfStandardWidthAndColor()
  }
  
  /// Sets any delegates of Outlets that were not set in the storyboard.
  private func setupOutletDelegates() {
    emailTextField.delegate = self
    nameTextField.delegate = self
    passwordTextField.delegate = self
    userTextField.delegate = self
  }
  
  // MARK: Networking Helper Functions
  
  /// Attempts to register user with Cillo servers.
  ///
  /// **Note:** User must login after registering.
  ///
  /// :param: completionHandler The completion block for the registration.
  /// :param: success True if register request was successful. If error was received, it is false.
  func register(completionHandler: (user: User?) -> ()) {
    DataManager.sharedInstance.registerUserWithName(nameTextField.text, username: userTextField.text, password: passwordTextField.text, andEmail: emailTextField.text) { result in
      switch result {
      case .Error(let error):
        self.handleError(error)
        completionHandler(user: nil)
      case .Value(let element):
        let (auth,user) = element.unbox
        var success = KeychainWrapper.setAuthToken(auth)
        success = KeychainWrapper.setUserID(user.userID)
        completionHandler(user: user)
      }
    }
  }
  
  
  // MARK: Error Handling Helper Functions
  
  override func handleUsernameTakenError(error: NSError) {
    if objc_getClass("UIAlertController") != nil {
      let alert = UIAlertController(title: "Error", message: "Username already taken.", preferredStyle: .Alert)
      alert.addAction(UIAlertAction(title: "Ok", style: .Cancel) { _ in
        })
      presentViewController(alert, animated: true, completion: nil)
    } else {
      let alert = UIAlertView(title: "Error", message: "Username already taken.", delegate: nil, cancelButtonTitle: "Ok")
      alert.show()
    }
  }
  
  override func handleUserUnauthenticatedError(error: NSError) {
    error.showAlert()
  }
  
  
  // MARK: IBActions
  
  
  @IBAction func privacyPressed(sender: UIButton) {
    if let url = NSURL(string: "https://www.themarble.co/legal/privacy.html") {
      UIApplication.sharedApplication().openURL(url)
    }
  }
  
  @IBAction func termsPressed(sender: UIButton) {
    if let url = NSURL(string: "https://www.themarble.co/legal/tos.html") {
      UIApplication.sharedApplication().openURL(url)
    }
  }
  
  /// Triggers segue to LoginViewController after registering the new user with the server.
  ///
  /// :param: sender The button that is touched to send this function is registerButton.
  @IBAction func triggerRegisterSegueOnButton(sender: UIButton) {
    sender.enabled = false
    register { user in
      if let user = user {
        self.performSegueWithIdentifier(SegueIdentifiers.registerToTab, sender: user)
      } else {
        sender.enabled = true
      }
    }
  }
}
