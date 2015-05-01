//
//  NewGroupViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 1/7/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

// TODO: Put photo upload in UI and handle uploading photos in code

/// Handles creating new Groups.
class NewGroupViewController: UIViewController {
  
  var image: UIImage?

  // MARK: IBOutlets
  
  @IBOutlet weak var fakeNavigationBar: UINavigationBar!
  
  @IBOutlet weak var pictureButton: UIButton!
  
  @IBOutlet weak var choosePictureButton: UIButton!
  
  /// Allows logged in User to enter the Group name for his/her new Group.
  @IBOutlet weak var nameTextView: UITextView!
  
  /// Allows logged in User to enter a description for his/her new Group.
  @IBOutlet weak var descripTextView: UITextView!
  
  /// Set to DescripTextViewHeight after viewDidLayoutSubviews().
  @IBOutlet weak var descripTextViewHeightConstraint: NSLayoutConstraint!
  
  // MARK: Constants
  
  /// Height needed for all components of a NewGroupViewController excluding descripTextView in the Storyboard.
  ///
  /// **Note:** Height of descripTextView must be calculated based on the frame size of the device.
  class var VertSpaceExcludingDescripTextView: CGFloat {
    get {
      return 187
    }
  }
  
  /// Calculated height of descripTextView based on frame size of device.
  var DescripTextViewHeight: CGFloat {
    get {
      return view.frame.height - UITextView.KeyboardHeight - NewGroupViewController.VertSpaceExcludingDescripTextView
    }
  }
  
  var SegueIdentifierThisToTab: String {
    return "NewGroupToTab"
  }
  
  // MARK: UIViewController
  
  /// Resizes postTextView so the keyboard won't overlap any UI elements and sets the group name in groupTextView if a group was passed to this UIViewController.
  override func viewDidLayoutSubviews() {
    descripTextViewHeightConstraint.constant = DescripTextViewHeight
  }
  
  /// Handles passing of data when navigation between UIViewControllers occur.
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // NOTE: currently ignoring segue, found another implementation
    if segue.identifier == SegueIdentifierThisToTab {
      var destination = segue.destinationViewController as! TabViewController
      if let sender = sender as? Group {
        let groupViewController = self.storyboard!.instantiateViewControllerWithIdentifier("Group") as! GroupTableViewController
        if let nav = destination.selectedViewController as? UINavigationController {
          groupViewController.group = sender
          nav.pushViewController(groupViewController, animated: true)
        }
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    choosePictureButton.tintColor = UIColor.cilloBlue()
    fakeNavigationBar.barTintColor = UIColor.cilloBlue()
    fakeNavigationBar.translucent = false
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
  // MARK: Helper Functions
  
  /// Used to create and retrieve a new Group made by the logged in User from Cillo servers.
  ///
  /// :param: mediaID The media id for the uploaded photo that resembles this group.
  /// :param: completion The completion block for the group creation.
  /// :param: group The new Group that was created from calling the servers.
  ///
  /// :param: * Nil if server call passed an error back.
  func createGroup(completion: (group: Group?) -> Void) {
    var descrip: String?
    if descripTextView.text != "" {
      descrip = descripTextView.text
    }
    let activityIndicator = addActivityIndicatorToCenterWithText("Creating Group...")
    if let image = image {
      DataManager.sharedInstance.imageUpload(UIImageJPEGRepresentation(image, 0.5), completion: { (error, mediaID) in
        if error != nil {
          activityIndicator.removeFromSuperview()
          println(error!)
          error!.showAlert()
          completion(group: nil)
        } else {
          DataManager.sharedInstance.createGroup(name: self.nameTextView.text, description: descrip, mediaID: mediaID, completion: { (error, result) -> Void in
            activityIndicator.removeFromSuperview()
            if error != nil {
              println(error)
              error!.showAlert()
              completion(group: nil)
            } else {
              completion(group: result!)
            }
          })
        }
      })
    } else {
      DataManager.sharedInstance.createGroup(name: nameTextView.text, description: descrip, mediaID: nil, completion: { (error, result) -> Void in
        activityIndicator.removeFromSuperview()
        if error != nil {
          println(error)
          error!.showAlert()
          completion(group: nil)
        } else {
          completion(group: result!)
        }
      })
    }
  }
  
  // MARK: IBActions
  
  /// Creates a group. If the creation is successful, presents a GroupTableViewController and removes self from navigationController's stack.
  ///
  /// :param: sender The button that is touched to send this function is createGroupButton.
  @IBAction func triggerTabSegueOnButton(sender: UIButton) {
    // TODO: handle media id and photo uploads
    createGroup({ (group) -> Void in
      if let group = group {
        self.performSegueWithIdentifier(self.SegueIdentifierThisToTab, sender: group)
      }
    })
  }
  
  @IBAction func imageButtonPressed(sender: UIButton) {
    let actionSheet = UIAlertController(title: "Change Profile Picture", message: nil, preferredStyle: .ActionSheet)
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
    })
    let pickerAction = UIAlertAction(title: "Choose Photo from Library", style: .Default, handler:  { (action) in
      let pickerController = UIImagePickerController()
      pickerController.delegate = self
      self.presentViewController(pickerController, animated: true, completion: nil)
    })
    let cameraAction = UIAlertAction(title: "Take Photo", style: .Default, handler: { (action) in
      // TODO: Camera picker
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

extension NewGroupViewController: UIImagePickerControllerDelegate {
  // MARK: UIImagePickerControllerDelegate
  
  /// Handles the instance in which an image was picked by a UIImagePickerController presented by this MeTableViewController.
  ///
  /// :param: picker The UIImagePickerController presented by this MeTableViewController.
  /// :param: info The dictionary containing the selected image's data.
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
      self.image = image
      self.pictureButton.setBackgroundImage(image, forState: .Normal)
      self.pictureButton.setBackgroundImage(image, forState: .Highlighted)
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
extension NewGroupViewController: UINavigationControllerDelegate {
  
  // MARK: UINavigationControllerDelegate
  
}

extension NewGroupViewController: UIBarPositioningDelegate {
  func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
    return .TopAttached
  }
}
