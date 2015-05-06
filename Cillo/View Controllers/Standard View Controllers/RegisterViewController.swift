//
//  RegisterViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 1/8/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

  // MARK: IBOutlets
  
  /// Space for user to enter their email associated with their account.
  @IBOutlet weak var emailTextField: UITextField!
  
  /// Space for user to enter their username for logging in.
  @IBOutlet weak var userTextField: UITextField!
  
  /// Space for user to enter their display name for logging in.
  @IBOutlet weak var nameTextField: UITextField!
  
  /// Space for user to enter their password for logging in.
  @IBOutlet weak var passwordTextField: UITextField!
  
  @IBOutlet weak var fakeNavigationBar: UINavigationBar!
  
  @IBOutlet weak var registerButton: UIButton!
  
  // MARK: Constants
  
  /// Segue Identifier in Storyboard for this UIViewController to LoginViewController
  var SegueIdentifierThisToLogin: String {
    get {
      return "RegisterToLogin"
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    fakeNavigationBar.barTintColor = UIColor.cilloBlue()
    fakeNavigationBar.translucent = false
    emailTextField.delegate = self
    nameTextField.delegate = self
    passwordTextField.delegate = self
    userTextField.delegate = self
    registerButton.backgroundColor = UIColor.cilloBlue()
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
  // MARK: Helper Functions
  
  /// Attempts to register user with Cillo servers.
  ///
  /// **Note:** User must login after registering.
  ///
  /// :param: completion The completion block for the registration.
  /// :param: success True if register request was successful. If error was received, it is false.
  func register(completion: (success: Bool) -> Void) {
    let activityIndicator = addActivityIndicatorToCenterWithText("Registering...")
    DataManager.sharedInstance.register(userTextField.text, name: nameTextField.text, password: passwordTextField.text, email: emailTextField.text, completion: { (error, success) -> Void in
      activityIndicator.removeFromSuperview()
      if error != nil {
        println(error)
        error!.showAlert()
        completion(success: false)
      } else {
        if success {
          let alert = UIAlertView(title: "Registration Successful", message: "", delegate: nil, cancelButtonTitle: "OK")
          alert.show()
          completion(success: true)
        }
      }
    })
  }
  
  // MARK: IBActions
  
  /// Triggers segue to LoginViewController after registering the new user with the server.
  ///
  /// :param: sender The button that is touched to send this function is registerButton.
  @IBAction func triggerRegisterSegueOnButton(sender: UIButton) {
    register( { (success) -> Void in
      if success {
        self.performSegueWithIdentifier(self.SegueIdentifierThisToLogin, sender: sender)
      }
    })
  }

}

extension RegisterViewController: UIBarPositioningDelegate {
  func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
    return .TopAttached
  }
}

extension RegisterViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
