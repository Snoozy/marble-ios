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
  @IBOutlet weak var emailTextField: CustomTextField!
  
  /// Field for end user to enter name.
  @IBOutlet weak var nameTextField: CustomTextField!
  
  /// Field for end user to enter password
  @IBOutlet weak var passwordTextField: CustomTextField!
  
  /// Button allowing end user to create a new account.
  @IBOutlet weak var registerButton: UIButton!
  
  /// Field for end user to enter username
  @IBOutlet weak var userTextField: CustomTextField!
  
  // MARK: UIViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupColorScheme()
    setupOutletDelegates()
  }
  
  // MARK: Setup Helper Functions
  
  /// Sets up the colors of the Outlets according to the default scheme of the app.
  private func setupColorScheme() {
    let scheme = ColorScheme.defaultScheme
    emailTextField.backgroundColor = scheme.textFieldBackgroundColor()
    userTextField.backgroundColor = scheme.textFieldBackgroundColor()
    nameTextField.backgroundColor = scheme.textFieldBackgroundColor()
    passwordTextField.backgroundColor = scheme.textFieldBackgroundColor()
    registerButton.backgroundColor = scheme.solidButtonBackgroundColor()
    registerButton.setTitleColor(scheme.solidButtonTextColor(), forState: .Normal)
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
  /// :param: completion The completion block for the registration.
  /// :param: success True if register request was successful. If error was received, it is false.
  func register(completion: (success: Bool) -> Void) {
    let activityIndicator = addActivityIndicatorToCenterWithText("Registering...")
    DataManager.sharedInstance.register(userTextField.text, name: nameTextField.text, password: passwordTextField.text, email: emailTextField.text) { error, success in
      activityIndicator.removeFromSuperview()
      if let error = error {
        println(error)
        error.showAlert()
        completion(success: false)
      } else {
        if success {
          let alert = UIAlertView(title: "Registration Successful", message: "", delegate: nil, cancelButtonTitle: "OK")
          alert.show()
        }
        completion(success: success)
      }
    }
  }
  
  // MARK: IBActions
  
  /// Triggers segue to LoginViewController after registering the new user with the server.
  ///
  /// :param: sender The button that is touched to send this function is registerButton.
  @IBAction func triggerRegisterSegueOnButton(sender: UIButton) {
    register { success in
      if success {
        self.performSegueWithIdentifier(SegueIdentifiers.registerToLogin, sender: sender)
      }
    }
  }
}
