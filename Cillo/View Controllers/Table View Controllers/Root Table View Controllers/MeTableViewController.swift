//
//  MeTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 11/13/14.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

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
      refreshControl?.beginRefreshing()
      retrieveData()
    }
  }
  
  // MARK: UITableViewDelegate
  
  override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    switch cellsShown {
    case .Posts:
      if !retrievingPage && indexPath.row > (postsPageNumber - 2) * 20 + 10 {
        retrievingPage = true
        retrievePosts { posts in
          if let posts = posts {
            for post in posts {
              self.posts.append(post)
            }
            self.postsPageNumber++
            self.tableView.reloadData()
          }
          self.retrievingPage = false
        }
      }
    case .Comments:
      if !retrievingPage && indexPath.row > (commentsPageNumber - 2) * 20 + 10 {
        retrievingPage = true
        retrieveComments { comments in
          if let comments = comments {
            for comment in comments {
              self.comments.append(comment)
            }
            self.commentsPageNumber++
            self.tableView.reloadData()
          }
          self.retrievingPage = false
        }
      }
    }
  }
  
  // MARK: Setup Helper Functions
  
  /// Presents an AlertController with style `.ActionSheet` that asks the user for confirmation of logging out.
  func presentLogoutConfirmationActionSheet() {
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
  }
  
  // MARK: Networking Helper Functions
  
  /// Used to logout from Cillo servers, invalidating NSUSerDefaults.auth
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: success True if there was no error in the server call. Otherwise, false.
  func logout(completionHandler: (success: Bool) -> ()) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    DataManager.sharedInstance.logout { error, success in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      if let error = error {
        handleError(error)
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
    retrievingPage = true
    retrieveUser { user in
      if let user = user {
        self.user = user
        self.posts = []
        self.postsPageNumber = 1
        self.retrievePosts { posts in
          if let posts = posts {
            self.posts = posts
            self.postsPageNumber++
            self.comments = []
            self.commentsPageNumber = 1
            self.retrieveComments { comments in
              self.dataRetrieved = true
              if let comments = comments {
                self.comments = comments
                self.tableView.reloadData()
                self.commentsPageNumber++
              }
              self.refreshControl?.endRefreshing()
              self.retrievingPage = false
            }
          } else {
            self.dataRetrieved = true
            self.refreshControl?.endRefreshing()
            self.retrievingPage = false
          }
        }
      } else {
        self.dataRetrieved = true
        self.refreshControl?.endRefreshing()
        self.retrievingPage = false
      }
    }
  }
  
  /// Used to retrieve comments made by end User from Cillo servers.
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: comments The comments that the end user has made.
  /// :param: * Nil if there was an error in the server call.
  func retrieveComments(completionHandler: (comments: [Comment]?) -> ()) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    DataManager.sharedInstance.getUserCommentsByID(user.userID, lastCommentID: comments.last?.commentID) { error, result in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      if let error = error {
        handleError(error)
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
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    DataManager.sharedInstance.getUserPostsByID(user.userID, lastPostID: posts.last?.postID) { error, result in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      if let error = error {
        handleError(error)
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
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    DataManager.sharedInstance.getEndUserInfo { error, result in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      if let error = error {
        handleError(error)
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
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    let activityIndicator = addActivityIndicatorToCenterWithText("Uploading Image...")
    DataManager.sharedInstance.uploadImageData(imageData) { error, result in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      activityIndicator.removeFromSuperview()
      if let error = error {
        handleError(error)
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
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    DataManager.sharedInstance.updateEndUserSettingsTo(newMediaID: mediaID) { error, result in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      if let error = error {
        handleError(error)
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
    UIImagePickerController.presentActionSheetForPhotoSelectionFromSource(self)
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
