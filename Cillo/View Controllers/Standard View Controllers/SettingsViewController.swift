//
//  SettingsViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 4/22/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Handles changing settings of end user.
class SettingsViewController: CustomViewController {
  
  // MARK: Properties
  
  /// Flag that stores whether the user has changed their photo.
  var photoChanged = false
  
  /// User that is having their settings changed.
  var user = User()
  
  // MARK: IBOutlets
    
  /// Field for end user to enter a new bio.
  @IBOutlet weak var bioTextView: UITextView!
  
  /// Button allowing end user to change their password.
  @IBOutlet weak var changePasswordButton: UIButton!
  
  /// Field for end user to enter a new name.
  @IBOutlet weak var nameTextField: CustomTextField!
  
  /// Button used to display the end user's selected profile picture.
  @IBOutlet weak var photoButton: UIButton!
  
  /// Button allowing end user to change their profile picture.
  @IBOutlet weak var updatePhotoButton: UIButton!
  
  /// Field for end user to enter a new username.
  @IBOutlet weak var usernameTextField: CustomTextField!
  
  // MARK: UIViewController
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == SegueIdentifiers.settingsToTab {
      if let destination = segue.destinationViewController as? TabViewController {
        destination.forceDataRetrievalUponUnwinding()
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupColorScheme()
    setupOutletAppearances()
  }
  
  // MARK: Setup Helper Functions
  
  /// Sets up the colors of the Outlets according to the default scheme of the app.
  private func setupColorScheme() {
    let scheme = ColorScheme.defaultScheme
    changePasswordButton.setTitleColor(scheme.touchableTextColor(), forState: .Normal)
    updatePhotoButton.setTitleColor(scheme.touchableTextColor(), forState: .Normal)
    nameTextField.backgroundColor = scheme.textFieldBackgroundColor()
    usernameTextField.backgroundColor = scheme.textFieldBackgroundColor()
    bioTextView.backgroundColor = scheme.textFieldBackgroundColor()
  }
  
  /// Sets up the appearance of Outlets that were not set in the storyboard.
  private func setupOutletAppearances() {
    nameTextField.text = user.name
    usernameTextField.text = user.username
    bioTextView.text = user.bio
    photoButton.setBackgroundImageForState(.Normal, withURL: user.profilePicURL)
    photoButton.clipsToBounds = true
    photoButton.layer.cornerRadius = 5.0
  }
  
  // MARK: Network Helper Functions
  
  /// Updates the end user's password on the cillo servers.
  ///
  /// :param: old The old password of the end user.
  /// :param: new The new password of the end user.
  /// :param: completion The completion block for the server call.
  /// :param: success True if this request was successful. If error was received, it is false.
  func updatePasswordFrom(old: String, to new: String, completion: (success: Bool) -> ()) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    DataManager.sharedInstance.updatePassword(old, toNewPassword: new) { error, success in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      if let error = error {
        println(error)
        error.showAlert()
        completion(success: false)
      } else {
        completion(success: true)
      }
    }
  }
  
  /// Updates the end user's settings on Cillo servers.
  ///
  /// :param: completion The completion block for the server call.
  /// :param: user The updated user object after settings are updated.
  /// :param: * Nil if there was an error in the server call.
  func updateSettings(completion: (user: User?) -> ()) {
    let newName = nameTextField.text != user.name ? nameTextField.text : ""
    let newUsername = usernameTextField.text != user.username ? usernameTextField.text : ""
    let newBio = bioTextView.text != user.bio ? bioTextView.text : ""
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    if let photo = photoButton.backgroundImageForState(.Normal) where photoChanged {
      uploadImage(photo) { mediaID in
        if let mediaID = mediaID {
          DataManager.sharedInstance.updateEndUserSettingsTo(newName: newName, newUsername: newUsername, newBio: newBio, newMediaID: mediaID) { error, result in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if let error = error {
              println(error)
              error.showAlert()
              completion(user: nil)
            } else {
              completion(user: result!)
            }
          }
        } else {
          UIApplication.sharedApplication().networkActivityIndicatorVisible = false
          completion(user: nil)
        }
      }
    } else {
      DataManager.sharedInstance.updateEndUserSettingsTo(newName: newName, newUsername: newUsername, newBio: newBio) { error, result in
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        if let error = error {
          println(error)
          error.showAlert()
          completion(user: nil)
        } else {
          completion(user: result!)
        }
      }
    }
  }
  
  /// Used to upload image to Cillo servers.
  ///
  /// :param: completion The completion block for the server call.
  /// :param: mediaID The id of the image uploaded to the Cillo servers.
  /// :param: * Nil if there was an error in the server call.
  func uploadImage(image: UIImage, completion: (mediaID: Int?) -> ()) {
    let imageData = UIImageJPEGRepresentation(image, UIImage.JPEGCompression)
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    let activityIndicator = addActivityIndicatorToCenterWithText("Uploading Image...")
    DataManager.sharedInstance.uploadImageData(imageData) { error, result in
      activityIndicator.removeFromSuperview()
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      if let error = error {
        println(error)
        error.showAlert()
        completion(mediaID: nil)
      } else {
        completion(mediaID: result!)
      }
    }
  }
  
  // MARK: Change Password Alert Related Helper Functions
  
  /// Presents an AlertController that allows the end user to change their password.
  private func presentChangePasswordAlert() {
    let alert = UIAlertController(title: "Change Password", message: nil, preferredStyle: .Alert)
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { _ in
    }
    let okAction = UIAlertAction(title: "OK", style: .Default) { _ in
      let oldTextField = alert.textFields![0] as! UITextField
      let newTextField = alert.textFields![1] as! UITextField
      let verifyTextField = alert.textFields![2] as! UITextField
      if newTextField.text == verifyTextField.text {
        self.updatePasswordFrom(oldTextField.text, to: newTextField.text) { success in
          if success {
            self.presentSuccessfulPasswordUpdateAlert()
          } else {
            self.presentFailedPasswordUpdateAlert()
          }
        }
      } else {
        self.presentFailedPasswordUpdateAlert()
      }
    }
    alert.addTextFieldWithConfigurationHandler { textField in
      textField.placeholder = "Old Password"
    }
    alert.addTextFieldWithConfigurationHandler { textField in
      textField.placeholder = "New Password"
    }
    alert.addTextFieldWithConfigurationHandler { textField in
      textField.placeholder = "Verify New Password"
    }
    alert.addAction(okAction)
    alert.addAction(cancelAction)
    presentViewController(alert, animated: true, completion: nil)
  }
  
  /// Presents an AlertController that tells the end user that their password was not updated successfully.
  private func presentFailedPasswordUpdateAlert() {
    let failureAlert = UIAlertController(title: "Failure", message: "Failed to update password", preferredStyle: .Alert)
    let failureOkAction = UIAlertAction(title: "OK", style: .Default) { _ in
    }
    failureAlert.addAction(failureOkAction)
    presentViewController(failureAlert, animated: true, completion: nil)
  }
  
  /// Presents an AlertController that tells the end user that they successfully updated their password.
  private func presentSuccessfulPasswordUpdateAlert() {
    let successAlert = UIAlertController(title: "Success", message: "Password successfully updated", preferredStyle: .Alert)
    let successOkAction = UIAlertAction(title: "OK", style: .Default) { _ in
    }
    successAlert.addAction(successOkAction)
    presentViewController(successAlert, animated: true, completion: nil)
  }
  
  // MARK: IBActions
  
  /// Presents an AlertController with 3 textfields allowing the end user to change their password. Depending on the result, presents a success or error message.
  ///
  /// :param: sender The button that is touched to send this function is changePasswordButton
  @IBAction func changePassword(sender: UIButton) {
    presentChangePasswordAlert()
  }
  
  /// Presents an AlertController with ActionSheet style that allows the user to choose a new profile picture.
  ///
  /// :param: sender The button that is touched to send this function is changePhotoButton
  @IBAction func changePhoto(sender: UIButton) {
    UIImagePickerController.presentActionSheetForPhotoSelectionFromSource(self)
  }
  /// Saves new settings to server. If successful, unwinds this view controller back to the tab bar.
  ///
  /// :param: sender The bar button item that is labeled Save.
  @IBAction func saveChanges(sender: UIBarButtonItem) {
    sender.enabled = false
    updateSettings { user in
      if let user = user {
        self.performSegueWithIdentifier(SegueIdentifiers.settingsToTab, sender: user)
      } else {
        sender.enabled = true
      }
    }
  }
}

// MARK: - UIImagePickerControllerDelegate

extension SettingsViewController: UIImagePickerControllerDelegate {
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
      photoButton.setBackgroundImage(image, forState: .Normal)
      photoButton.setBackgroundImage(image, forState: .Highlighted)
      photoChanged = true
    }
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    dismissViewControllerAnimated(true, completion: nil)
  }
}

// MARK: - UINavigationControllerDelegate

// Required to implement UINavigationControllerDelegate in order to present UIImagePickerControllers.
extension SettingsViewController: UINavigationControllerDelegate {
}

