//
//  MeTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 11/13/14.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Handles first view of Me tab (Profile of end User).
///
/// Formats TableView to look appealing and be functional.
class MeTableViewController: SingleUserTableViewController {
  
  // MARK: Constants
  
  /// Segue Identifier in Storyboard for segue to BoardTableViewController.
  override var segueIdentifierThisToBoard: String {
    return SegueIdentifiers.meToBoard
  }
  
  /// Segue Identifier in Storyboard for segue to BoardsTableViewController.
  override var segueIdentifierThisToBoards: String {
    return SegueIdentifiers.meToBoards
  }
  
  /// Segue Identifier in Storyboard for segue to PostTableViewController.
  override var segueIdentifierThisToPost: String {
    return SegueIdentifiers.meToPost
  }
  
  // MARK: UIViewController
 
  override func viewDidLoad() {
    super.viewDidLoad()
    if KeychainWrapper.hasAuthAndUser() {
      retrieveData()
    }
  }
  
  // MARK: UITableViewDelegate
  
  override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    switch cellsShown {
    case .Posts:
      if !postsFinishedPaging && !retrievingPage && indexPath.row > posts.count - 10 {
        retrievingPage = true
        retrievePosts { posts in
          if let posts = posts {
            if posts.isEmpty {
              self.postsFinishedPaging = true
            } else {
              for post in posts {
                self.posts.append(post)
              }
              self.postsPageNumber++
              self.tableView.reloadData()
            }
          }
          self.retrievingPage = false
        }
      }
    case .Comments:
      if !commentsFinishedPaging && !retrievingPage && indexPath.row > comments.count - 10 {
        retrievingPage = true
        retrieveComments { comments in
          if let comments = comments {
            if comments.isEmpty {
              self.commentsFinishedPaging = true
            } else {
              for comment in comments {
                self.comments.append(comment)
              }
              self.commentsPageNumber++
              self.tableView.reloadData()
            }
          }
          self.retrievingPage = false
        }
      }
    }
  }
  
  // MARK: Setup Helper Functions
  
  /// Presents an AlertController with style `.ActionSheet` that asks the user for confirmation of logging out.
  func presentLogoutConfirmationActionSheet() {
    if objc_getClass("UIAlertController") != nil {
      let alert = UIAlertController(title: "Logout", message: "Are you sure you want to Logout?", preferredStyle: .Alert)
      let yesAction = UIAlertAction(title: "Yes", style: .Default) { _ in
        self.logout { success in
          if success {
            KeychainWrapper.clearAuthToken()
            KeychainWrapper.clearUserID()
            if let tabBarController = self.tabBarController as? TabViewController {
              tabBarController.performSegueWithIdentifier(SegueIdentifiers.tabToLogin, sender: self)
            }
          }
        }
      }
      let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { _ in
      }
      alert.addAction(yesAction)
      alert.addAction(cancelAction)
      presentViewController(alert, animated: true, completion: nil)
    } else {
      let alert = UIAlertView(title: "Logout", message: "Are you sure you want to Logout?", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "Yes", "Cancel")
      alert.cancelButtonIndex = 1
      alert.show()
    }
  }
  
  // MARK: Networking Helper Functions
  
  /// Used to logout from Cillo servers, invalidating NSUSerDefaults.auth
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: success True if there was no error in the server call. Otherwise, false.
  func logout(completionHandler: (success: Bool) -> ()) {
    DataManager.sharedInstance.logout { error, success in
      if let error = error {
        self.handleError(error)
        completionHandler(success: false)
      } else {
        completionHandler(success: success)
      }
    }
  }
  
  /// Used to retrieve all necessary data to display UITableViewCells in this view controller.
  ///
  /// Assigns user, posts, and comments properties of SingleUserTableViewController correct values from server calls.
  override func retrieveData() {
    if let tabBarController = tabBarController as? TabViewController, me = tabBarController.endUser where user != me {
      user = me
      tableView.reloadData()
    } else {
      retrieveUser { user in
        if let user = user {
          self.user = user
          if let tabBarController = self.tabBarController as? TabViewController {
            tabBarController.endUser = user
          }
        }
      }
    }
    retrievingPage = true
    self.posts = []
    self.postsFinishedPaging = false
    self.postsPageNumber = 1
    self.retrievePosts { posts in
      if let posts = posts {
        if posts.isEmpty {
          self.postsFinishedPaging = true
        }
        self.posts = posts
        self.postsPageNumber++
        self.comments = []
        self.commentsFinishedPaging = false
        self.commentsPageNumber = 1
        self.retrieveComments { comments in
          self.dataRetrieved = true
          if let comments = comments {
            if comments.isEmpty {
              self.commentsFinishedPaging = true
            }
            self.comments = comments
            self.commentsPageNumber++
          }
          self.refreshControl?.endRefreshing()
          self.retrievingPage = false
          self.tableView.reloadData()
        }
      } else {
        self.dataRetrieved = true
        self.refreshControl?.endRefreshing()
        self.retrievingPage = false
        self.tableView.reloadData()
      }
    }
  }
  
  /// Used to retrieve comments made by end User from Cillo servers.
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: comments The comments that the end user has made.
  /// :param: * Nil if there was an error in the server call.
  func retrieveComments(completionHandler: (comments: [Comment]?) -> ()) {
    DataManager.sharedInstance.getUserCommentsByID(user.userID, lastCommentID: comments.last?.commentID) { error, result in
      if let error = error {
        self.handleError(error)
        completionHandler(comments: nil)
      } else {
        completionHandler(comments: result)
      }
    }
  }
  
  /// Used to retrieve posts made by end User from Cillo servers.
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: posts The posts that the end user has made.
  /// :param: * Nil if there was an error in the server call.
  func retrievePosts(completionHandler: (posts: [Post]?) -> ()) {
    DataManager.sharedInstance.getUserPostsByID(user.userID, lastPostID: posts.last?.postID) { error, result in
      if let error = error {
        self.handleError(error)
        completionHandler(posts: nil)
      } else {
        completionHandler(posts: result)
      }
    }
  }
  
  /// Used to retrieve end User from Cillo servers.
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: user The end user.
  /// :param: * Nil if there was an error in the server call.
  func retrieveUser(completionHandler: (user: User?) -> ()) {
    DataManager.sharedInstance.getEndUserInfo { error, result in
      if let error = error {
        self.handleError(error)
        completionHandler(user: nil)
      } else {
        completionHandler(user: result)
      }
    }
  }
  
  /// Used to upload image to Cillo servers.
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: mediaID The id of the image uploaded to the Cillo servers.
  /// :param: * Nil if there was an error in the server call.
  func uploadImage(image: UIImage, completionHandler: (mediaID: Int?) -> ()) {
    let imageData = UIImageJPEGRepresentation(image, UIImage.JPEGCompression)
    let activityIndicator = addActivityIndicatorToCenterWithText("Uploading Image...")
    DataManager.sharedInstance.uploadImageData(imageData) { error, result in
      activityIndicator.removeFromSuperview()
      if let error = error {
        self.handleError(error)
        completionHandler(mediaID: nil)
      } else {
        completionHandler(mediaID: result)
      }
    }
  }
  
  /// Sends edit settings request to Cillo Servers for the end user in order to change the profile picture of the end user.
  ///
  /// :param: mediaID The id of the uploaded picture that will be the new profile picture of the end user.
  /// :param: boardName The name of the board that the specified post is being reposted to.
  /// :param: completionHandler The completion block for the repost.
  /// :param: user The User object for the end user after being updated with a new profilePic. Nil if error was received.
  func updateEndUserPhoto(mediaID: Int, completionHandler: (user: User?) -> ()) {
    DataManager.sharedInstance.updateEndUserSettingsTo(newMediaID: mediaID) { error, result in
      if let error = error {
        self.handleError(error)
        completionHandler(user: nil)
      } else {
        completionHandler(user: result)
      }
    }
  }
  
  // MARK: IBActions
  
  /// Triggers segue to SettingsViewController.
  ///
  /// :param: sender The button that is touched to send this function is a cogButton in a UserCell.
  @IBAction func cogPressed(sender: UIButton) {
    if let tabBarController = tabBarController as? TabViewController {
      tabBarController.performSegueWithIdentifier(SegueIdentifiers.tabToSettings, sender: user)
    }
  }
  
  /// Presents AlertController with style `.ActionSheet` that asks if the end user wants to logout. If yes is selected, presents the login screen.
  ///
  /// :param: sender The button that is touched to send this function is the Logout bar button item.
  @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
    presentLogoutConfirmationActionSheet()
  }
  
  /// Presents action sheet to take a photo or retrieve a photo from the device's library.
  ///
  /// :param: sender The button that is touched to send this function is a pictureButton in a UserCell.
  @IBAction func pictureButtonPressed(sender: UIButton) {
    UIImagePickerController.presentActionSheetForPhotoSelectionFromSource(self, withTitle: "Change Profile Picture", iPadReference: sender)
  }

}

// MARK: - UIImagePickerControllerDelegate

extension MeTableViewController: UIImagePickerControllerDelegate {
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
      uploadImage(image) { mediaID in
        if let mediaID = mediaID {
          self.updateEndUserPhoto(mediaID) { user in
            if let user = user {
              self.user = user
              let userIndexPath = NSIndexPath(forRow: 0, inSection: 0)
              self.tableView.reloadRowsAtIndexPaths([userIndexPath], withRowAnimation: .None)
            }
          }
        }
      }
    }
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
}

// MARK: - UINavigationControllerDelegate

extension MeTableViewController: UINavigationControllerDelegate {
}

// MARK: - UIActionSheetDelegate

extension MeTableViewController: UIActionSheetDelegate {
  
  func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
    UIImagePickerController.defaultActionSheetDelegateImplementationForSource(self, withSelectedIndex: buttonIndex)
  }
}

extension MeTableViewController: UIAlertViewDelegate {
  
  func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
    if buttonIndex == 0 {
      logout { success in
        if success {
          KeychainWrapper.clearAuthToken()
          KeychainWrapper.clearUserID()
          if let tabBarController = self.tabBarController as? TabViewController {
            tabBarController.performSegueWithIdentifier(SegueIdentifiers.tabToLogin, sender: self)
          }
        }
      }
    }
  }
}
