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
    imitationNavigationBar.isTranslucent = false
  }
  
  // MARK: Networking Helper Functions
  
  /// Handles an error received from a network call within the app.
  ///
  /// :param: error The error to be handled
  func handleError(_ error: NSError) {
    println(error)
    switch error.cilloErrorCode() {
    case .userUnauthenticated:
      handleUserUnauthenticatedError(error)
    case .usernameTaken:
      handleUsernameTakenError(error)
    case .passwordIncorrect:
      handlePasswordIncorrectError(error)
    case .boardNameInvalid:
      handleBoardNameInvalidError(error)
    case .notCilloDomain:
      break
    default:
        error.showAlert()
    }
  }
  
  /// Extracts whether a call was successful or not and handles the error if it was not.
  ///
  /// :param: result The result of the network call.
  /// :param: completionHandler A handler containing what to do if the call fails or succeeds.
  /// :param: success A boolean stating whether the call succeeded.
  func handleSuccessResponse<T>(_ result: ValueOrError<T>, completionHandler: (success: Bool) -> ()) {
    switch result {
    case .error(let error):
      self.handleError(error)
      completionHandler(success: false)
    case .value(_):
      completionHandler(success: true)
    }
  }
  
  /// Extracts whether a call was successful or not and handles the error if it was not, handles the value if it was successful.
  ///
  /// :param: result The result of the network call.
  /// :param: completionHandler A handler containing what to do with the extracted element from `result`.
  /// :param: element The extracted element.
  func handleSingleElementResponse<T>(_ result: ValueOrError<T>, completionHandler: (element: T?) -> ()) {
    switch result {
    case .error(let error):
      self.handleError(error)
      completionHandler(element: nil)
    case .value(let element):
      completionHandler(element: element.unbox)
    }
  }
  
  // MARK: Error Handling Helper Functions
  
  /// Handles a cillo error with code `NSError.CilloErrorCodes.passwordIncorrect`.
  ///
  /// **Note:** Default implementation does nothing.
  ///
  /// :param: error The error to be handled.
  func handlePasswordIncorrectError(_ error: NSError) {
  }
  
  /// Handles a cillo error with code `NSError.CilloErrorCodes.usernameTaken`.
  ///
  /// **Note:** Default implementation does nothing.
  ///
  /// :param: error The error to be handled.
  func handleUsernameTakenError(_ error: NSError) {
  }
  
  /// Handles a cillo error with code `NSError.CilloErrorCodes.boardNameInvalid`.
  ///
  /// **Note:** Default implementation does nothing.
  ///
  /// :param: error The error to be handled.
  func handleBoardNameInvalidError(_ error: NSError) {
  }
  
  /// Handles a cillo error with code `NSError.CilloErrorCodes.userUnauthenticated`.
  ///
  /// **Note:** Default implementation presents a LoginVC.
  ///
  /// :param: error The error to be handled.
  func handleUserUnauthenticatedError(_ error: NSError) {
    let loginViewController = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: StoryboardIdentifiers.login) as! LogInViewController
    present(loginViewController, animated: true, completion: nil)
  }
}

// MARK: - UIBarPositioningDelegate

extension CustomViewController: UIBarPositioningDelegate {
  
  func position(for bar: UIBarPositioning) -> UIBarPosition {
    return .topAttached
  }
}

// MARK: - UITextFieldDelegate

extension CustomViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}

// MARK: - JTSImageViewControllerOptionsDelegate

extension CustomTableViewController: JTSImageViewControllerOptionsDelegate {
  
  /// Makes the screen black behind the image
  func alphaForBackgroundDimmingOverlay(inImageViewer imageViewer: JTSImageViewController!) -> CGFloat {
    return 1.0
  }
}
