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
  
  /// Tag for the menu UIActionSheet to differentiate with the picture UIActionSheet
  let menuActionSheetTag = Int.max
  
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
  
  override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    switch cellsShown {
    case .posts:
      if !postsFinishedPaging && !retrievingPage && (indexPath as NSIndexPath).row > posts.count - 25 {
        retrievingPage = true
        retrievePosts { posts in
          if let posts = posts {
            if posts.isEmpty {
              self.postsFinishedPaging = true
            } else {
              var row = self.posts.count
              var newPaths = [IndexPath]()
              for post in posts {
                self.posts.append(post)
                newPaths.append(IndexPath(row: row, section: 1))
                row += 1
              }
              DispatchQueue.main.async {
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: newPaths, with: .middle)
                self.tableView.endUpdates()
                self.postsPageNumber += 1
              }
            }
          }
          self.retrievingPage = false
        }
      }
    case .comments:
      if !commentsFinishedPaging && !retrievingPage && (indexPath as NSIndexPath).row > comments.count - 25 {
        retrievingPage = true
        retrieveComments { comments in
          if let comments = comments {
            if comments.isEmpty {
              self.commentsFinishedPaging = true
            } else {
              var row = self.comments.count
              var newPaths = [IndexPath]()
              for comment in comments {
                self.comments.append(comment)
                newPaths.append(IndexPath(row: row, section: 1))
                row += 1
              }
              DispatchQueue.main.async {
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: newPaths, with: .middle)
                self.tableView.endUpdates()
                self.commentsPageNumber += 1
              }
            }
          }
          self.retrievingPage = false
        }
      }
    }
  }
  
  // MARK: Setup Helper Functions
  
  /// Presents an AlertController with style `.AlertView` that asks the user for confirmation of logging out.
  func presentLogoutConfirmationAlertView() {
    if objc_getClass("UIAlertController") != nil {
      let alert = UIAlertController(title: "Logout", message: "Are you sure you want to Logout?", preferredStyle: .alert)
      let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
        self.logout { success in
          if success {
            KeychainWrapper.clearAuthToken()
            KeychainWrapper.clearUserID()
            DispatchQueue.main.async {
              if let tabBarController = self.tabBarController as? TabViewController {
                tabBarController.performSegue(withIdentifier: SegueIdentifiers.tabToLogin, sender: self)
              }
            }
          }
        }
      }
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
      }
      alert.addAction(yesAction)
      alert.addAction(cancelAction)
      present(alert, animated: true, completion: nil)
    } else {
      let alert = UIAlertView(title: "Logout", message: "Are you sure you want to Logout?", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "Yes", "Cancel")
      alert.show()
    }
  }
  
  /// Presents an AlertController with style `.ActionSheet` that prompts the user with various possible additional actions.
  func presentMenuActionSheet() {
    if objc_getClass("UIAlertController") != nil {
      let actionSheet = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
      let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
        if let tabBarController = self.tabBarController as? TabViewController {
          tabBarController.performSegue(withIdentifier: SegueIdentifiers.tabToSettings, sender: self.user)
        }
      }
      let logoutAction = UIAlertAction(title: "Logout", style: .default) { _ in
        self.presentLogoutConfirmationAlertView()
      }
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
      }
      actionSheet.addAction(settingsAction)
      actionSheet.addAction(logoutAction)
      actionSheet.addAction(cancelAction)
      if let navigationController = navigationController where UIDevice.current.userInterfaceIdiom == .pad {
        actionSheet.modalPresentationStyle = .popover
        let popPresenter = actionSheet.popoverPresentationController
        popPresenter?.sourceView = navigationController.navigationBar
        popPresenter?.sourceRect = navigationController.navigationBar.frame
      }
      present(actionSheet, animated: true, completion: nil)
    } else {
      let actionSheet = UIActionSheet(title: "More", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Settings", "Logout")
      actionSheet.cancelButtonIndex = 2
      actionSheet.tag = menuActionSheetTag
      if let navigationController = navigationController where UIDevice.current.userInterfaceIdiom == .pad {
        actionSheet.show(from: navigationController.navigationBar.frame, in: view, animated: true)
      } else {
        actionSheet.show(in: view)
      }
    }
  }
  
  // MARK: Networking Helper Functions
  
  /// Used to logout from Cillo servers, invalidating NSUSerDefaults.auth
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: success True if there was no error in the server call. Otherwise, false.
  func logout(_ completionHandler: (success: Bool) -> ()) {
    DataManager.sharedInstance.logout { result in
      self.handleSuccessResponse(result, completionHandler: completionHandler)
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
        DispatchQueue.main.async {
          if posts.isEmpty {
            self.postsFinishedPaging = true
          }
          self.posts = posts
          self.postsPageNumber += 1
          self.comments = []
          self.commentsFinishedPaging = false
          self.commentsPageNumber = 1
        }
        self.retrieveComments { comments in
          DispatchQueue.main.async {
            self.dataRetrieved = true
            if let comments = comments {
              if comments.isEmpty {
                self.commentsFinishedPaging = true
              }
              self.comments = comments
              self.commentsPageNumber += 1
            }
            self.refreshControl?.endRefreshing()
            self.retrievingPage = false
            self.tableView.reloadData()
          }
        }
      } else {
        DispatchQueue.main.async {
          self.dataRetrieved = true
          self.refreshControl?.endRefreshing()
          self.retrievingPage = false
          self.tableView.reloadData()
        }
      }
    }
  }
  
  /// Used to retrieve comments made by end User from Cillo servers.
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: comments The comments that the end user has made.
  /// :param: * Nil if there was an error in the server call.
  func retrieveComments(_ completionHandler: (comments: [Comment]?) -> ()) {
    DataManager.sharedInstance.getUserCommentsByID(user.userID, lastCommentID: comments.last?.commentID) { result in
      self.handleSingleElementResponse(result, completionHandler: completionHandler)
    }
  }
  
  /// Used to retrieve posts made by end User from Cillo servers.
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: posts The posts that the end user has made.
  /// :param: * Nil if there was an error in the server call.
  func retrievePosts(_ completionHandler: (posts: [Post]?) -> ()) {
    DataManager.sharedInstance.getUserPostsByID(user.userID, lastPostID: posts.last?.postID) { result in
      self.handleSingleElementResponse(result, completionHandler: completionHandler)
    }
  }
  
  /// Used to retrieve end User from Cillo servers.
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: user The end user.
  /// :param: * Nil if there was an error in the server call.
  func retrieveUser(_ completionHandler: (user: User?) -> ()) {
    DataManager.sharedInstance.getEndUserInfo { result in
      self.handleSingleElementResponse(result, completionHandler: completionHandler)
    }
  }
  
  /// Used to upload image to Cillo servers.
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: mediaID The id of the image uploaded to the Cillo servers.
  /// :param: * Nil if there was an error in the server call.
  func uploadImage(_ image: UIImage, completionHandler: (mediaID: Int?) -> ()) {
    let imageData = UIImageJPEGRepresentation(image, UIImage.JPEGCompression)
    let activityIndicator = addActivityIndicatorToCenterWithText("Uploading Image...")
    DataManager.sharedInstance.uploadImageData(imageData) { result in
      activityIndicator.removeFromSuperview()
      self.handleSingleElementResponse(result, completionHandler: completionHandler)
    }
  }
  
  /// Sends edit settings request to Cillo Servers for the end user in order to change the profile picture of the end user.
  ///
  /// :param: mediaID The id of the uploaded picture that will be the new profile picture of the end user.
  /// :param: boardName The name of the board that the specified post is being reposted to.
  /// :param: completionHandler The completion block for the repost.
  /// :param: user The User object for the end user after being updated with a new profilePic. Nil if error was received.
  func updateEndUserPhoto(_ mediaID: Int, completionHandler: (user: User?) -> ()) {
    DataManager.sharedInstance.updateEndUserSettingsTo(newMediaID: mediaID) { result in
      self.handleSingleElementResponse(result, completionHandler: completionHandler)
    }
  }
  
  // MARK: IBActions
  
  /// Presents action sheet to logout or edit settings.
  ///
  /// :param: sender The button that is touched to send this function is the right bar button.
  @IBAction func menuPressed(_ sender: UIBarButtonItem) {
    presentMenuActionSheet()
  }
  
  /// Presents action sheet to take a photo or retrieve a photo from the device's library.
  ///
  /// :param: sender The button that is touched to send this function is a pictureButton in a UserCell.
  @IBAction func pictureButtonPressed(_ sender: UIButton) {
    UIImagePickerController.presentActionSheetForPhotoSelectionFromSource(self, withTitle: "Change Profile Picture", iPadReference: sender)
  }

}

// MARK: - UIImagePickerControllerDelegate

extension MeTableViewController: UIImagePickerControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
      uploadImage(image) { mediaID in
        if let mediaID = mediaID {
          self.updateEndUserPhoto(mediaID) { user in
            if let user = user {
              DispatchQueue.main.async {
                self.user = user
                let userIndexPath = IndexPath(row: 0, section: 0)
                self.tableView.reloadRows(at: [userIndexPath], with: .none)
              }
            }
          }
        }
      }
    }
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
  
}

// MARK: - UINavigationControllerDelegate

extension MeTableViewController: UINavigationControllerDelegate {
}

// MARK: - UIActionSheetDelegate

extension MeTableViewController: UIActionSheetDelegate {
  
  func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
    if actionSheet.tag == menuActionSheetTag {
      switch buttonIndex {
      case 0:
        if let tabBarController = self.tabBarController as? TabViewController {
          tabBarController.performSegue(withIdentifier: SegueIdentifiers.tabToSettings, sender: self.user)
        }
      case 1:
        self.presentLogoutConfirmationAlertView()
      default:
        break
      }
    } else {
      UIImagePickerController.defaultActionSheetDelegateImplementationForSource(self, withSelectedIndex: buttonIndex)
    }
  }
}

// MARK: - UIAlertViewDelegate

extension MeTableViewController: UIAlertViewDelegate {
  
  func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
    if buttonIndex == 1 {
      logout { success in
        if success {
          KeychainWrapper.clearAuthToken()
          KeychainWrapper.clearUserID()
          DispatchQueue.main.async {
            if let tabBarController = self.tabBarController as? TabViewController {
              tabBarController.performSegue(withIdentifier: SegueIdentifiers.tabToLogin, sender: self)
            }
          }
        }
      }
    }
  }
}
