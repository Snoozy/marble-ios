//
//  CustomViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 5/14/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Any UIViewController that is presented modally that still needs a navigation bar should subclass this class.
class CustomViewController: UIViewController {
  
  // MARK: IBOutlets
  
  /// Navigation bar that is presented at the top of the screen, despite this ViewController being presented modally.
  @IBOutlet weak var imitationNavigationBar: UINavigationBar!
  
  // MARK: UIViewController
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return ColorScheme.defaultScheme.statusBarStyle()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    imitationNavigationBar.setupAttributesForColorScheme(ColorScheme.defaultScheme)
    imitationNavigationBar.translucent = false
  }
  
  // MARK: Networking Helper Functions
  
  /// Handles an error received from a network call within the app.
  ///
  /// :param: error The error to be handled
  func handleError(error: NSError) {
    println(error)
    switch error.cilloErrorCode() {
    case .UserUnauthenticated:
      handleUserUnauthenticatedError(error)
    case .UsernameTaken:
      handleUsernameTakenError(error)
    case .PasswordIncorrect:
      handlePasswordIncorrectError(error)
    case .NotCilloDomain:
      break
    default:
        error.showAlert()
    }
  }
  
  // MARK: Error Handling Helper Functions
  
  /// Handles a cillo error with code `NSError.CilloErrorCodes.passwordIncorrect`.
  ///
  /// **Note:** Default implementation does nothing.
  ///
  /// :param: error The error to be handled.
  func handlePasswordIncorrectError(error: NSError) {
  }
  
  /// Handles a cillo error with code `NSError.CilloErrorCodes.usernameTaken`.
  ///
  /// **Note:** Default implementation does nothing.
  ///
  /// :param: error The error to be handled.
  func handleUsernameTakenError(error: NSError) {
  }
  
  /// Handles a cillo error with code `NSError.CilloErrorCodes.userUnauthenticated`.
  ///
  /// **Note:** Default implementation presents a LoginVC.
  ///
  /// :param: error The error to be handled.
  func handleUserUnauthenticatedError(error: NSError) {
    let loginViewController = UIStoryboard.mainStoryboard.instantiateViewControllerWithIdentifier(StoryboardIdentifiers.login) as! LogInViewController
    presentViewController(loginViewController, animated: true, completion: nil)
  }
}

// MARK: - UIBarPositioningDelegate

extension CustomViewController: UIBarPositioningDelegate {
  
  func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
    return .TopAttached
  }
}

// MARK: - UITextFieldDelegate

extension CustomViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}

// MARK: - JTSImageViewControllerOptionsDelegate

extension CustomTableViewController: JTSImageViewControllerOptionsDelegate {
  
  /// Makes the screen black behind the image
  func alphaForBackgroundDimmingOverlayInImageViewer(imageViewer: JTSImageViewController!) -> CGFloat {
    return 1.0
  }
}