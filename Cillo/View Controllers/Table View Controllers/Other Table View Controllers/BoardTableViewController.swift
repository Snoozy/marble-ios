//
//  BoardTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 1/5/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

/// Handles view of expanded Post with Comments beneath it.
///
/// Formats TableView to look appealing and be functional.
///
/// **Note:** Must assign board property of superclass a relevant value before displaying this SingleBoardTableViewController.
class BoardTableViewController: SingleBoardTableViewController {
  
  // MARK: Constants
  
  /// Segue Identifier in Storyboard for segue to PostTableViewController.
  override var segueIdentifierThisToPost: String {
    return SegueIdentifiers.boardToPost
  }
  
  /// Segue Identifier in Storyboard for segue to UserTableViewController.
  override var segueIdentifierThisToUser: String {
    return SegueIdentifiers.boardToUser
  }
  
  /// Segue Identifier in Storyboard for segue to NewPostViewController.
  override var segueIdentifierThisToNewPost: String {
    return SegueIdentifiers.boardToNewPost
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
    if !retrievingPage && indexPath.row > (pageNumber - 1) * 10 + 10 {
      retrievingPage = true
      retrievePosts { posts in
        if let posts = posts {
          for post in posts {
            self.posts.append(post)
          }
          self.tableView.reloadData()
          self.pageNumber++
        }
        self.retrievingPage = false
      }
    }
  }
  
  // MARK: Networking Helper Functions
  
  /// Used to retrieve all necessary data to display UITableViewCells in this view controller.
  ///
  /// Assigns posts property of SingleBoardTableViewController correct values from server calls.
  override func retrieveData() {
    retrievingPage = true
    posts = []
    pageNumber = 1
    retrievePosts { posts in
      self.postsRetrieved = true
      if let posts = posts {
        self.posts = posts
        self.tableView.reloadData()
        self.pageNumber++
      }
      self.refreshControl?.endRefreshing()
      self.retrievingPage = false
    }
  }
  
  /// Used to retrieve the feed for this board from Cillo servers.
  ///
  /// :param: completion The completion block for the server call.
  /// :param: posts The posts in the feed for this board.
  /// :param: * Nil if there was an error in the server call.
  func retrievePosts(completion: (posts: [Post]?) -> ()) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    DataManager.sharedInstance.getBoardFeed(lastPostID: posts.last?.postID, boardID: board.boardID) { error, result in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      if let error = error {
        println(error)
        error.showAlert()
        completion(posts: nil)
      } else {
        completion(posts: result!)
      }
    }
  }
}
