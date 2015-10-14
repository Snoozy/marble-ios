//
//  HomeTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 10/23/14.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

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

  // MARK: UIViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if KeychainWrapper.hasAuthAndUser() {
      refreshControl?.beginRefreshing()
      retrieveData()
    }
  }
  
  // MARK: UITableViewDataSource
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if posts.isEmpty && !retrievingPage {
      return tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.checkOutDiscoverCell, forIndexPath: indexPath) as! UITableViewCell
    } else {
      return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if posts.isEmpty && !retrievingPage {
      return 1
    } else {
      return super.tableView(tableView, numberOfRowsInSection: section)
    }
  }
  
  // MARK: UITableViewDelegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if posts.isEmpty && !retrievingPage{
      if let tabBarController = tabBarController as? TabViewController {
        tabBarController.selectedIndex = tabBarController.discoverTabIndex
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
      }
    } else {
      super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
    }
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if posts.isEmpty && !retrievingPage {
      return tableView.frame.height
    } else {
      return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
  }
  
  override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if !finishedPaging && !retrievingPage && indexPath.row > posts.count - 10 {
      retrievingPage = true
      retrievePosts { posts in
        dispatch_async(dispatch_get_main_queue()) {
          if let posts = posts {
            if posts.isEmpty {
              self.finishedPaging = true
            } else {
              for post in posts {
                self.posts.append(post)
              }
              self.pageNumber++
              self.tableView.reloadData()
            }
          }
          self.retrievingPage = false
        }
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
    finishedPaging = false
    retrievePosts { posts in
      dispatch_async(dispatch_get_main_queue()) {
        self.retrievingPage = false
        if let posts = posts {
          if posts.isEmpty {
            self.finishedPaging = true
          }
          self.pageNumber++
          self.posts = posts
          self.tableView.reloadData()
        }
        self.refreshControl?.endRefreshing()
      }
      
    }
  }
  
  /// Used to retrieve posts in the end user's feed from Cillo servers.
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: posts The posts in the end user's home feed.
  /// :param: * Nil if there was an error in the server call.
  func retrievePosts(completionHandler: (posts: [Post]?) -> ()) {
    DataManager.sharedInstance.getHomeFeed(lastPostID: posts.last?.postID) { result in
      self.handleSingleElementResponse(result, completionHandler: completionHandler)
    }
  }
}
