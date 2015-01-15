//
//  GroupTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 1/5/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Handles view of expanded Post with Comments beneath it.
///
/// Formats TableView to look appealing and be functional.
///
/// **Note:** Must assign group property of superclass a relevant value before displaying this SingleGroupTableViewController.
class GroupTableViewController: SingleGroupTableViewController {

  // MARK: Constants
  
  /// Segue Identifier in Storyboard for this UITableViewController to PostTableViewController.
  override var SegueIdentifierThisToPost: String {
    get {
      return "GroupToPost"
    }
  }
  
  /// Segue Identifier in Storyboard for this UITableViewController to UserTableViewController.
  override var SegueIdentifierThisToUser: String {
    get {
      return "GroupToUser"
    }
  }
  
  /// Segue Identifier in Storyboard for this UITableViewController to NewPostViewController.
  override var SegueIdentifierThisToNewPost: String {
    get {
      return "GroupToNewPost"
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
  /// Assigns posts property of SingleGroupTableViewController correct values from server calls.
  override func retrieveData() {
    retrievePosts( { (posts) -> Void in
      if posts != nil {
        self.posts = posts!
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
      }
    })
  }
  
  /// Used to retrieve the feed for this group from Cillo servers.
  ///
  /// :param: completion The completion block for the server call.
  /// :param: posts The posts in the feed for this group.
  /// :param: * Nil if there was an error in the server call.
  func retrievePosts(completion: (posts: [Post]?) -> Void) {
    let activityIndicator = addActivityIndicatorToCenterWithText("Retrieving Posts")
    DataManager.sharedInstance.getGroupFeed(group.groupID, completion: { (error, result) -> Void in
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

}
