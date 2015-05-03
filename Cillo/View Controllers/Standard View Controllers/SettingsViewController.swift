//
//  SettingsViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 4/22/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
  
  var user: User = User()
  
  var photoChanged: Bool = false
  
  @IBOutlet weak var fakeNavigationBar: UINavigationBar!
  
  @IBOutlet weak var nameTextView: UITextView!
  
  @IBOutlet weak var usernameTextView: UITextView!
  
  @IBOutlet weak var bioTextView: UITextView!
  
  @IBOutlet weak var changePasswordButton: UIButton!
  
  @IBOutlet weak var updatePhotoButton: UIButton!
  
  @IBOutlet weak var photoButton: UIButton!
  
  class var SegueIdentifierThisToTab: String {
    return "SettingsToTab"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    fakeNavigationBar.barTintColor = UIColor.cilloBlue()
    fakeNavigationBar.translucent = false
    changePasswordButton.tintColor = UIColor.cilloBlue()
    updatePhotoButton.tintColor = UIColor.cilloBlue()
    nameTextView.text = user.name
    usernameTextView.text = user.username
    bioTextView.text = user.bio
    photoButton.setBackgroundImageForState(.Normal, withURL: user.profilePicURL)
    photoButton.setBackgroundImageForState(.Highlighted, withURL: user.profilePicURL)
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == SettingsViewController.SegueIdentifierThisToTab {
      if let sender = sender as? User {
        let destination = segue.destinationViewController as! TabViewController
        if let navController = destination.viewControllers?[2] as? FormattedNavigationViewController {
          if let meVC = navController.topViewController as? MeTableViewController {
            meVC.retrieveData()
          }
        }
      }
    }
  }
  
  /// Used to upload image to Cillo servers.
  ///
  /// :param: completion The completion block for the server call.
  /// :param: mediaID The id of the image uploaded to the Cillo servers.
  /// :param: * Nil if there was an error in the server call.
  func uploadImage(image: UIImage, completion: (mediaID: Int?) -> Void) {
    let imageData = UIImageJPEGRepresentation(image, 0.5)
    let activityIndicator = addActivityIndicatorToCenterWithText("Uploading Image...")
    DataManager.sharedInstance.imageUpload(imageData, completion: { (error, result) -> Void in
      activityIndicator.removeFromSuperview()
      if error != nil {
        println(error!)
        error!.showAlert()
        completion(mediaID: nil)
      } else {
        completion(mediaID: result!)
      }
    })
  }
  
  func updateSettings(completion: (user: User?) -> Void) {
    let activityIndicator = addActivityIndicatorToCenterWithText("Updating Profile...")
    let newName = nameTextView.text != user.name ? nameTextView.text : nil
    let newUsername = usernameTextView.text != user.username ? usernameTextView.text : nil
    let newBio = bioTextView.text != user.bio ? bioTextView.text : nil
    if photoChanged {
      uploadImage(photoButton.backgroundImageForState(.Normal)!, completion: { (mediaID) in
        if mediaID == nil {
          completion(user: nil)
        } else {
          DataManager.sharedInstance.editSelfSettings(newName: newName, newUsername: newUsername, newMediaID: mediaID!, newBio: newBio, completion: { (error, result) -> Void in
            activityIndicator.removeFromSuperview()
            if error != nil {
              println(error!)
              error!.showAlert()
              completion(user: nil)
            } else {
              completion(user: result!)
            }
          })
        }
      })
    } else {
      DataManager.sharedInstance.editSelfSettings(newName: newName, newUsername: newUsername, newMediaID: nil, newBio: newBio, completion: { (error, result) -> Void in
        activityIndicator.removeFromSuperview()
        if error != nil {
          println(error!)
          error!.showAlert()
          completion(user: nil)
        } else {
          completion(user: result!)
        }
      })
    }
    
  }
  
  func updatePassword(#old: String, new: String, completion: (success: Bool) -> Void) {
    DataManager.sharedInstance.updatePassword(oldPassword: old, newPassword: new, completion: { (error, success) in
      if error != nil {
        println(error!)
        error!.showAlert()
        completion(success: false)
      } else {
        completion(success: true)
      }
    })
  }
  
  @IBAction func saveChanges(sender: UIBarButtonItem) {
    updateSettings( { (user) in
      if user != nil {
        self.performSegueWithIdentifier(SettingsViewController.SegueIdentifierThisToTab, sender: user!)
      }
    })
  }
  
  
  @IBAction func changePassword(sender: UIButton) {
    let alert = UIAlertController(title: "Change Password", message: nil, preferredStyle: .Alert)
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
    })
    let okAction = UIAlertAction(title: "OK", style: .Default, handler: { (action) in
      let oldTextField = alert.textFields![0] as! UITextField
      let newTextField = alert.textFields![1] as! UITextField
      let verifyTextField = alert.textFields![2] as! UITextField
      if newTextField.text == verifyTextField.text {
        self.updatePassword(old: oldTextField.text, new: newTextField.text, completion: { (success) in
          if success {
            let successAlert = UIAlertController(title: "Success", message: "Password successfully updated", preferredStyle: .Alert)
            let successOkAction = UIAlertAction(title: "OK", style: .Default, handler: { (action) in
            })
            successAlert.addAction(successOkAction)
            self.presentViewController(successAlert, animated: true, completion: nil)
          } else {
            let failureAlert = UIAlertController(title: "Failure", message: "Failed to update password", preferredStyle: .Alert)
            let failureOkAction = UIAlertAction(title: "OK", style: .Default, handler: { (action) in
            })
            failureAlert.addAction(failureOkAction)
            self.presentViewController(failureAlert, animated: true, completion: nil)
          }
        })
      } else {
        let failureAlert = UIAlertController(title: "Failure", message: "Failed to update password", preferredStyle: .Alert)
        let failureOkAction = UIAlertAction(title: "OK", style: .Default, handler: { (action) in
        })
        failureAlert.addAction(failureOkAction)
        self.presentViewController(failureAlert, animated: true, completion: nil)
      }
    })
    alert.addTextFieldWithConfigurationHandler( { (textField) in
      textField.placeholder = "Old Password"
    })
    alert.addTextFieldWithConfigurationHandler( { (textField) in
      textField.placeholder = "New Password"
    })
    alert.addTextFieldWithConfigurationHandler( { (textField) in
      textField.placeholder = "Verify New Password"
    })
    alert.addAction(okAction)
    alert.addAction(cancelAction)
    presentViewController(alert, animated: true, completion: nil)
  }
  
  @IBAction func changePhoto(sender: UIButton) {
    let actionSheet = UIAlertController(title: "Change Profile Picture", message: nil, preferredStyle: .ActionSheet)
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
    })
    let pickerAction = UIAlertAction(title: "Choose Photo from Library", style: .Default, handler:  { (action) in
      let pickerController = UIImagePickerController()
      pickerController.delegate = self
      self.presentViewController(pickerController, animated: true, completion: nil)
    })
    let cameraAction = UIAlertAction(title: "Take Photo", style: .Default, handler: { (action) in
      let pickerController = UIImagePickerController()
      pickerController.delegate = self
      if UIImagePickerController.isSourceTypeAvailable(.Camera) {
        pickerController.sourceType = .Camera
      }
      self.presentViewController(pickerController, animated: true, completion: nil)
    })
    actionSheet.addAction(cancelAction)
    actionSheet.addAction(pickerAction)
    actionSheet.addAction(cameraAction)
    presentViewController(actionSheet, animated: true, completion: nil)
  }

}

extension SettingsViewController: UIImagePickerControllerDelegate {
  
  // MARK: UIImagePickerControllerDelegate
  
  /// Handles the instance in which an image was picked by a UIImagePickerController presented by this MeTableViewController.
  ///
  /// :param: picker The UIImagePickerController presented by this MeTableViewController.
  /// :param: info The dictionary containing the selected image's data.
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
      photoButton.setBackgroundImage(image, forState: .Normal)
      photoButton.setBackgroundImage(image, forState: .Highlighted)
      photoChanged = true
    }
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  /// Handles the instance in which the user cancels the selection of an image by a UIImagePickerController presented by this MeTableViewController.
  ///
  /// :param: picker The UIImagePickerController presented by this MeTableViewController.
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
}

// Required to implement UINavigationControllerDelegate in order to present UIImagePickerControllers.
extension SettingsViewController: UINavigationControllerDelegate {
  
  // MARK: UINavigationControllerDelegate
  
}

extension SettingsViewController: UIBarPositioningDelegate {
  func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
    return .TopAttached
  }
}
