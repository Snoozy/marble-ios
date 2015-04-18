//
//  MeTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 11/13/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

// TODO: Implement Update Bio UI

/// Handles first view of Me tab (Profile of logged in User). 
///
/// Formats TableView to look appealing and be functional.
class MeTableViewController: SingleUserTableViewController {

  // MARK: Constants
  
  /// Segue Identifier in Storyboard for this UITableViewController to PostTableViewController.
  override var SegueIdentifierThisToPost: String {
    get {
      return "MeToPost"
    }
  }
  
  /// Segue Identifier in Storyboard for this UITableViewController to GroupTableViewController.
  override var SegueIdentifierThisToGroup: String {
    get {
      return "MeToGroup"
    }
  }
  
  /// Segue Identifier in Storyboard for this UITableViewController to GroupsTableViewController.
  override var SegueIdentifierThisToGroups: String {
    get {
      return "MeToGroups"
    }
  }
  
  // MARK: UIViewController
 
  /// Initializes user
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if NSUserDefaults.hasAuthAndUser() {
      retrieveData()
    }
  }
  
  // MARK: Helper Functions
  
  /// Used to retrieve all necessary data to display UITableViewCells in this UIViewController.
  ///
  /// Assigns user, posts, and comments properties of SingleUserTableViewController correct values from server calls.
  override func retrieveData() {
    retrieveUser( { (user) -> Void in
      if user != nil {
        self.user = user!
        self.retrievePosts( { (posts) -> Void in
          if posts != nil {
            self.posts = posts!
            self.retrieveComments( { (comments) -> Void in
              if comments != nil {
                self.comments = comments!
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
              }
            })
          }
        })
      }
    })
  }
  
  /// Used to retrieve logged in User from Cillo servers.
  ///
  /// :param: completion The completion block for the server call.
  /// :param: user The logged in User.
  /// :param: * Nil if there was an error in the server call.
  func retrieveUser(completion: (user: User?) -> Void) {
    let activityIndicator = addActivityIndicatorToCenterWithText("Retrieving User...")
    DataManager.sharedInstance.getSelfInfo( { (error, result) -> Void in
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
  
  /// Used to retrieve posts made by logged in User from Cillo servers.
  ///
  /// :param: completion The completion block for the server call.
  /// :param: posts The posts that the logged in User has made.
  /// :param: * Nil if there was an error in the server call.
  func retrievePosts(completion: (posts: [Post]?) -> Void) {
    let activityIndicator = addActivityIndicatorToCenterWithText("Retrieving Posts...")
    DataManager.sharedInstance.getUserPostsByID(user.userID, completion: { (error, result) -> Void in
      activityIndicator.removeFromSuperview()
      if error != nil {
        println(error!)
        error!.showAlert()
        completion(posts: nil)
      } else {
        completion(posts: result!)
      }
    })
  }
  
  /// Used to retrieve comments made by logged in User from Cillo servers.
  ///
  /// :param: completion The completion block for the server call.
  /// :param: comments The comments that the logged in User has made.
  /// :param: * Nil if there was an error in the server call.
  func retrieveComments(completion: (comments: [Comment]?) -> Void) {
    let activityIndicator = addActivityIndicatorToCenterWithText("Retrieving Comments...")
    DataManager.sharedInstance.getUserCommentsByID(user.userID, completion: { (error, result) -> Void in
      activityIndicator.removeFromSuperview()
      if error != nil {
        println(error!)
        error!.showAlert()
        completion(comments: nil)
      } else {
        completion(comments: result!)
      }
    })
  }
  
  /// Used to upload image to Cillo servers.
  ///
  /// :param: completion The completion block for the server call.
  /// :param: mediaID The id of the image uploaded to the Cillo servers.
  /// :param: * Nil if there was an error in the server call.
  func uploadImage(image: UIImage, completion: (mediaID: Int?) -> Void) {
    let imageData = UIImagePNGRepresentation(image)
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
  
  /// Sends edit settings request to Cillo Servers for the logged in User in order to change the profile picture of the logged in User.
  ///
  /// :param: mediaID The id of the uploaded picture that will be the new profile picture of the logged in User.
  /// :param: groupName The name of the group that the specified post is being reposted to.
  /// :param: completion The completion block for the repost.
  /// :param: user The User object for the logged in User after being updated with a new profilePic. Nil if error was received.
  func updateProfilePic(mediaID: Int, completion: (user: User?) -> Void) {
    let activityIndicator = addActivityIndicatorToCenterWithText("Updating Profile...")
    DataManager.sharedInstance.editSelfSettings(newName: nil, newMediaID: mediaID, newBio: nil, completion: { (error, result) -> Void in
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
  
  /// Sends edit settings request to Cillo Servers for the logged in User in order to change the name of the logged in User.
  ///
  /// :param: name The new name of the logged in User.
  /// :param: completion The completion block for the repost.
  /// :param: user The User object for the logged in User after being updated with a new name. Nil if error was received.
  func updateName(name: String, completion: (user: User?) -> Void) {
    let activityIndicator = addActivityIndicatorToCenterWithText("Updating Profile...")
    DataManager.sharedInstance.editSelfSettings(newName: name, newMediaID: nil, newBio: nil, completion: { (error, result) -> Void in
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
  
  /// Sends edit settings request to Cillo Servers for the logged in User in order to change the bio of the logged in User.
  ///
  /// :param: bio The new bio of the logged in User.
  /// :param: completion The completion block for the repost.
  /// :param: user The User object for the logged in User after being updated with a new bio. Nil if error was received.
  func updateBio(bio: String, completion: (user: User?) -> Void) {
    let activityIndicator = addActivityIndicatorToCenterWithText("Updating Profile...")
    DataManager.sharedInstance.editSelfSettings(newName: nil, newMediaID: nil, newBio: bio, completion: { (error, result) -> Void in
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
  
  func logout(completion: (success: Bool) -> Void) {
    let activityIndicator = addActivityIndicatorToCenterWithText("Logging Out")
    DataManager.sharedInstance.logout( { (error, success) in
      activityIndicator.removeFromSuperview()
      if error != nil {
        println(error!)
        error!.showAlert()
        completion(success: false)
      } else {
        completion(success: success)
      }
    })
  }
  
  // MARK: IBActions
  
  /// Presents action sheet to take a photo or retrieve a photo from the device's library.
  ///
  /// :param: sender The button that is touched to send this function is a pictureButton in a UserCell.
  @IBAction func pictureButtonPressed(sender: UIButton) {
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
    })
    actionSheet.addAction(cancelAction)
    actionSheet.addAction(pickerAction)
    actionSheet.addAction(cameraAction)
    presentViewController(actionSheet, animated: true, completion: nil)
  }
  
  /// Presents alert with a text field that allows the user to change their name.
  ///
  /// :param: sender The button that is touched to send this function is a nameButton in a UserCell.
  @IBAction func nameButtonPressed(sender: UIButton) {
    let alert = UIAlertController(title: "Change Display Name", message: "Enter new name:", preferredStyle: .Alert)
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
    })
    let okAction = UIAlertAction(title: "OK", style: .Default, handler: { (action) in
      let nameTextField = alert.textFields![0] as! UITextField
      self.updateName(nameTextField.text, completion: { (user) -> Void in
        if user != nil {
          self.user = user!
          let userIndexPath = NSIndexPath(forRow: 0, inSection: 0)
          self.tableView.reloadRowsAtIndexPaths([userIndexPath], withRowAnimation: .None)
        }
      })
    })
    alert.addTextFieldWithConfigurationHandler( { (textField) in
      textField.placeholder = "New Name"
    })
    alert.addAction(okAction)
    alert.addAction(cancelAction)
    presentViewController(alert, animated: true, completion: nil)
  }
  
  @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
    let alert = UIAlertController(title: "Logout", message: "Are you sure you want to Logout?", preferredStyle: .Alert)
    let yesAction = UIAlertAction(title: "Yes", style: .Default, handler: { (action) in
      self.logout( { (success) in
        if success {
          NSUserDefaults.standardUserDefaults().removeObjectForKey(NSUserDefaults.Auth)
          NSUserDefaults.standardUserDefaults().removeObjectForKey(NSUserDefaults.User)
          self.tabBarController?.performSegueWithIdentifier(TabViewController.SegueIdentifierThisToLogin, sender: sender)
        }
      })
    })
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
    })
    alert.addAction(yesAction)
    alert.addAction(cancelAction)
    presentViewController(alert, animated: true, completion: nil)
  }
  
}

extension MeTableViewController: UIImagePickerControllerDelegate {
  
  // MARK: UIImagePickerControllerDelegate
  
  /// Handles the instance in which an image was picked by a UIImagePickerController presented by this MeTableViewController.
  ///
  /// :param: picker The UIImagePickerController presented by this MeTableViewController.
  /// :param: info The dictionary containing the selected image's data.
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
      uploadImage(image, completion: { (mediaID) -> Void in
        if mediaID != nil {
          self.updateProfilePic(mediaID!, completion: { (user) -> Void in
            if user != nil {
              self.user = user!
              let userIndexPath = NSIndexPath(forRow: 0, inSection: 0)
              self.tableView.reloadRowsAtIndexPaths([userIndexPath], withRowAnimation: .None)
            }
          })
        }
      })
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
extension MeTableViewController: UINavigationControllerDelegate {
  
  // MARK: UINavigationControllerDelegate
  
}
