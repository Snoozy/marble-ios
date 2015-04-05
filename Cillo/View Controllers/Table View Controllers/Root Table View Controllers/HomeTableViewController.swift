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
  
  var retrievingPage = false
  
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
    let activityIndicator = addActivityIndicatorToCenterWithText("Retrieving Posts...")
    retrievingPage = true
    retrievePosts( { (posts) -> Void in
      self.retrievingPage = false
      activityIndicator.removeFromSuperview()
      if posts != nil {
        self.posts = posts!
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
        self.pageNumber++
      }
    })
  }
  
  /// Used to retrieve posts in the logged in User's feed from Cillo servers.
  ///
  /// :param: completion The completion block for the server call.
  /// :param: posts The posts in the logged in User's home feed.
  /// :param: * Nil if there was an error in the server call.
  func retrievePosts(completion: (posts: [Post]?) -> Void) {
    DataManager.sharedInstance.getHomePage(pageNumber: pageNumber, completion: { (error, result) -> Void in
      if error != nil {
        println(error!)
        error!.showAlert()
        completion(posts: nil)
      } else {
        completion(posts: result!)
      }
    })
  }
  
  override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if !retrievingPage && indexPath.row > (pageNumber - 1) * 10 + 10 {
      retrievePosts( { (posts) in
        self.retrievingPage = false
        if posts != nil {
          for post in posts! {
            self.posts.append(post)
            self.tableView.reloadData()
            self.pageNumber++
          }
        }
      })
    }
  }
  
}
