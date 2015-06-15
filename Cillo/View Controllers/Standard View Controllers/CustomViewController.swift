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
    if error.domain == NSError.cilloErrorDomain {
      switch error.code {
      case NSError.CilloErrorCodes.userUnauthenticated:
        handleUserUnauthenticatedError(error)
      default:
        error.showAlert()
      }
    }
  }
  
  // MARK: Error Handling Helper Functions
  
  /// Handles a cillo error with code `NSError.CilloErrorCodes.userUnauthenticated`.
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