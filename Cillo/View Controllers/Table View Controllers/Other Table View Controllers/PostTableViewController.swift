//
//  PostTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 10/31/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

/// Handles view of expanded Post with Comments beneath it.
///
/// Formats TableView to look appealing and be functional.
///
/// **Note:** Must assign post property of superclass a relevant value before displaying this SinglePostTableViewController.
class PostTableViewController: SinglePostTableViewController {

  // MARK: Constants
  
  /// Segue Identifier in Storyboard for this UITableViewController to GroupTableViewController.
  override var SegueIdentifierThisToGroup: String {
    get {
      return "PostToGroup"
    }
  }
  
  /// Segue Identifier in Storyboard for this UITableViewController to UserTableViewController.
  override var SegueIdentifierThisToUser: String {
    get {
      return "PostToUser"
    }
  }
  
  // MARK: UIViewController
  
  /// Initializes commentTree array.
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if NSUserDefaults.hasAuthAndUser() {
      retrieveData()
    }
  }
  
  // MARK: Helper Functions
  
  /// Used to retrieve all necessary data to display UITableViewCells in this UIViewController.
  ///
  /// Assigns commentTree property of SinglePostTableViewController correct values from server calls.
  override func retrieveData() {
    retrieveCommentTree( { (commentTree) -> Void in
      if commentTree != nil {
        self.commentTree = commentTree!
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
      }
    })
  }
  
  /// Used to retrieve the comment tree for post from Cillo servers.
  ///
  /// :param: completion The completion block for the server call.
  /// :param: comments The comment tree for this post.
  /// :param: * Nil if there was an error in the server call.
  func retrieveCommentTree(completion: (commentTree: [Comment]?) -> Void) {
    let activityIndicator = addActivityIndicatorToCenterWithText("Retrieving Comments")
    DataManager.sharedInstance.getPostCommentsByID(post.postID, completion: { (error, result) -> Void in
      activityIndicator.removeFromSuperview()
      if error != nil {
        println(error!)
        error!.showAlert()
        completion(commentTree: nil)
      } else {
        completion(commentTree: result!)
      }
    })
  }
  
}
