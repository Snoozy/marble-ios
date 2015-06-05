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
  
  /// Segue Identifier in Storyboard for segue to PostTableViewController.
  override var segueIdentifierThisToPost: String {
    return SegueIdentifiers.userToPost
  }
  
  /// Segue Identifier in Storyboard for segue to BoardTableViewController.
  override var segueIdentifierThisToBoard: String {
    return SegueIdentifiers.userToBoard
  }
  
  /// Segue Identifier in Storyboard for segue to BoardsTableViewController.
  override var segueIdentifierThisToBoards: String {
    return SegueIdentifiers.userToBoards
  }
  
  // MARK: UIViewController 
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if NSUserDefaults.hasAuthAndUser() && user != User(){
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
  
  // MARK: Networking Helper Functions
  
  /// Used to retrieve the comments made by user from Cillo servers.
  ///
  /// :param: completion The completion block for the server call.
  /// :param: comments The comments made by user.
  /// :param: * Nil if there was an error in the server call.
  func retrieveComments(completion: (comments: [Comment]?) -> Void) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    DataManager.sharedInstance.getUserCommentsByID(lastCommentID: comments.last?.commentID, userID: user.userID) { error, result in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      if let error = error {
        println(error)
        error.showAlert()
        completion(comments: nil)
      } else {
        completion(comments: result!)
      }
    }
  }
  
  /// Used to retrieve all necessary data to display UITableViewCells in this UIViewController.
  ///
  /// Assigns posts and comments properties of SingleUserTableViewController correct values from server calls.
  override func retrieveData() {
    retrievingPage = true
    posts = []
    postsPageNumber = 1
    retrievePosts { posts in
      if let posts = posts {
        self.posts = posts
        self.postsPageNumber++
        self.comments = []
        self.commentsPageNumber = 1
        self.retrieveComments { comments in
          if let comments = comments {
            self.comments = comments
            self.commentsPageNumber++
          }
          self.tableView.reloadData()
          self.refreshControl?.endRefreshing()
          self.retrievingPage = false
        }
      } else {
        self.refreshControl?.endRefreshing()
        self.retrievingPage = false
      }
    }
  }
  
  /// Used to retrieve the posts made by user from Cillo servers.
  ///
  /// :param: completion The completion block for the server call.
  /// :param: posts The posts made by user.
  /// :param: * Nil if there was an error in the server call.
  func retrievePosts(completion: (posts: [Post]?) -> Void) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    DataManager.sharedInstance.getUserPostsByID(lastPostID: posts.last?.postID, userID: user.userID) { error, result in
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
