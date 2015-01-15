//
//  HomeTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 10/23/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

/// Handles first view of Home tab (Front Page of Cillo). 
///
/// Formats TableView to look appealing and be functional.
class HomeTableViewController: MultiplePostsTableViewController {
  
  // MARK: Constants
  
  /// Segue Identifier in Storyboard for this UITableViewController to PostTableViewController.
  override var SegueIdentifierThisToPost: String {
    get {
      return "HomeToPost"
    }
  }
  
  /// Segue Identifier in Storyboard for this UITableViewController to GroupTableViewController.
  override var SegueIdentifierThisToGroup: String {
    get {
      return "HomeToGroup"
    }
  }
  
  /// Segue Identifier in Storyboard for this UITableViewController to UserTableViewController.
  override var SegueIdentifierThisToUser: String {
    get {
      return "HomeToUser"
    }
  }
  
  /// Segue Identifier in Storyboard for this UITableViewController to NewPostViewController.
  override var SegueIdentifierThisToNewPost: String {
    get {
      return "HomeToNewPost"
    }
  }

  // MARK: UIViewController
  
  /// Initializes posts array
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if NSUserDefaults.hasAuthAndUser() {
      retrieveData()
    }
  }
  
  // MARK: Helper Functions
  
  /// Used to retrieve all necessary data to display UITableViewCells in this UIViewController.
  ///
  /// Assigns posts property of MultiplePostsTableViewController correct values from server calls.
  override func retrieveData() {
    retrievePosts( { (posts) -> Void in
      if posts != nil {
        self.posts = posts!
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
      }
    })
  }
  
  /// Used to retrieve posts in the logged in User's feed from Cillo servers.
  ///
  /// :param: completion The completion block for the server call.
  /// :param: posts The posts in the logged in User's home feed.
  /// :param: * Nil if there was an error in the server call.
  func retrievePosts(completion: (posts: [Post]?) -> Void) {
    let activityIndicator = addActivityIndicatorToCenterWithText("Retrieving Posts...")
    DataManager.sharedInstance.getHomePage( { (error, result) -> Void in
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
