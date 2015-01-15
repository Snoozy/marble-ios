//
//  UserTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 1/5/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Handles view of User with Posts or Comments beneath it for any User that is not the logged in User.
///
/// Formats TableView to look appealing and be functional.
///
/// **Note:** Must assign user property of superclass a relevant value before displaying this SingleUserTableViewController.
class UserTableViewController: SingleUserTableViewController {

  // MARK: Constants
  
  /// Segue Identifier in Storyboard for this UITableViewController to PostTableViewController.
  override var SegueIdentifierThisToPost: String {
    get {
      return "UserToPost"
    }
  }
  
  /// Segue Identifier in Storyboard for this UITableViewController to GroupTableViewController.
  override var SegueIdentifierThisToGroup: String {
    get {
      return "UserToGroup"
    }
  }
  
  /// Segue Identifier in Storyboard for this UITableViewController to GroupsTableViewController.
  override var SegueIdentifierThisToGroups: String {
    get {
      return "UserToGroups"
    }
  }
  
  // MARK: UIViewController 
  
  /// Initializes posts and comments array.
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if NSUserDefaults.hasAuthAndUser() && user != User(){
      retrieveData()
    }
  }
  
  // MARK: Helper Functions
  
  /// Used to retrieve all necessary data to display UITableViewCells in this UIViewController.
  ///
  /// Assigns posts and comments properties of SingleUserTableViewController correct values from server calls.
  override func retrieveData() {
    retrievePosts( { (posts) -> Void in
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
  
  /// Used to retrieve the posts made by user from Cillo servers.
  ///
  /// :param: completion The completion block for the server call.
  /// :param: posts The posts made by user.
  /// :param: * Nil if there was an error in the server call.
  func retrievePosts(completion: (posts: [Post]?) -> Void) {
    let activityIndicator = addActivityIndicatorToCenterWithText("Retrieving Posts")
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
  
  /// Used to retrieve the comments made by user from Cillo servers.
  ///
  /// :param: completion The completion block for the server call.
  /// :param: comments The comments made by user.
  /// :param: * Nil if there was an error in the server call.
  func retrieveComments(completion: (comments: [Comment]?) -> Void) {
    let activityIndicator = addActivityIndicatorToCenterWithText("Retrieving Comments")
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

}
