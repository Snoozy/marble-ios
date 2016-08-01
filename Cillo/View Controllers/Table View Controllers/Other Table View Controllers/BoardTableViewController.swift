//
//  BoardTableViewController.swift
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
  
  override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if !finishedPaging && !retrievingPage && (indexPath as NSIndexPath).row > posts.count - 25 {
      retrievingPage = true
      retrievePosts { posts in
        if let posts = posts {
          if posts.isEmpty {
            self.finishedPaging = true
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
              self.pageNumber += 1
            }
          }
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
    finishedPaging = false
    posts = []
    pageNumber = 1
    retrievePosts { posts in
      DispatchQueue.main.async {
        self.postsRetrieved = true
        if let posts = posts {
          if posts.isEmpty {
            self.finishedPaging = true
          }
          self.posts = posts
          self.tableView.reloadData()
          self.pageNumber += 1
        }
        self.refreshControl?.endRefreshing()
        self.retrievingPage = false
      }
    }
  }
  
  /// Used to retrieve the feed for this board from Cillo servers.
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: posts The posts in the feed for this board.
  /// :param: * Nil if there was an error in the server call.
  func retrievePosts(_ completionHandler: (posts: [Post]?) -> ()) {
    DataManager.sharedInstance.getBoardFeedByID(board.boardID, lastPostID: posts.last?.postID) { result in
      self.handleSingleElementResponse(result, completionHandler: completionHandler)
    }
  }
}
