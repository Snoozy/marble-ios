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
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupColorScheme()
    setupOutletAppearances()
    setupOutletDelegates()
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
  func register(completionHandler: (success: Bool) -> ()) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    DataManager.sharedInstance.registerUserWithName(nameTextField.text, username: userTextField.text, password: passwordTextField.text, andEmail: emailTextField.text) { error, success in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      if let error = error {
        self.handleError(error)
        completionHandler(success: false)
      } else {
        if success {
          let alert = UIAlertView(title: "Registration Successful", message: "", delegate: nil, cancelButtonTitle: "OK")
          alert.show()
        }
        completionHandler(success: success)
      }
    }
  }
  
  
  // MARK: Error Handling Helper Functions
  
  override func handleUserUnauthenticatedError(error: NSError) {
    error.showAlert()
  }
  
  
  // MARK: IBActions
  
  /// Triggers segue to LoginViewController after registering the new user with the server.
  ///
  /// :param: sender The button that is touched to send this function is registerButton.
  @IBAction func triggerRegisterSegueOnButton(sender: UIButton) {
    sender.enabled = false
    register { success in
      if success {
        self.performSegueWithIdentifier(SegueIdentifiers.registerToLogin, sender: sender)
      } else {
        sender.enabled = true
      }
    }
  }
}
