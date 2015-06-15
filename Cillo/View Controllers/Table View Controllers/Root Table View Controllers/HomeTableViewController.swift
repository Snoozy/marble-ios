//
//  HomeTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 10/23/14.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

/// Handles first view of Home tab (Front Page of Cillo). 
///
/// Formats TableView to look appealing and be functional.
class HomeTableViewController: MultiplePostsTableViewController {
  
  // MARK: Constants
  
  /// Segue Identifier in Storyboard for segue to PostTableViewController.
  override var segueIdentifierThisToPost: String {
    return SegueIdentifiers.homeToPost
  }
  
  /// Segue Identifier in Storyboard for segue to BoardTableViewController.
  override var segueIdentifierThisToBoard: String {
    return SegueIdentifiers.homeToBoard
  }
  
  /// Segue Identifier in Storyboard for segue to UserTableViewController.
  override var segueIdentifierThisToUser: String {
    return SegueIdentifiers.homeToUser
  }
  
  /// Segue Identifier in Storyboard for segue to NewPostViewController.
  override var segueIdentifierThisToNewPost: String {
    return SegueIdentifiers.homeToNewPost
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
    if !retrievingPage && indexPath.row > (pageNumber - 2) * 20 + 10 {
      retrievingPage = true
      retrievePosts { posts in
        if let posts = posts {
          for post in posts {
            self.posts.append(post)
          }
          self.pageNumber++
          self.tableView.reloadData()
        }
        self.retrievingPage = false
      }
    }
  }
  
  // MARK: Networking Helper Functions
  
  /// Used to retrieve all necessary data to display UITableViewCells in this view controller.
  ///
  /// Assigns `posts` correct values from server calls.
  override func retrieveData() {
    retrievingPage = true
    posts = []
    pageNumber = 1
    retrievePosts { posts in
      if let posts = posts {
        self.pageNumber++
        self.posts = posts
        self.tableView.reloadData()
      }
      self.refreshControl?.endRefreshing()
      self.retrievingPage = false
    }
  }
  
  /// Used to retrieve posts in the end user's feed from Cillo servers.
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: posts The posts in the end user's home feed.
  /// :param: * Nil if there was an error in the server call.
  func retrievePosts(completionHandler: (posts: [Post]?) -> ()) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    DataManager.sharedInstance.getHomeFeed(lastPostID: posts.last?.postID) { error, result in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      if let error = error {
        handleError(error)
        completionHandler(posts: nil)
      } else {
        completionHandler(posts: result)
      }
    }
  }
}
