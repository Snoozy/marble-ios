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

  // MARK: IBOutlets
  
  /// Activity indicator used for network interactions.
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  // MARK: Constants
  
  /// Segue Identifier in Storyboard for this UITableViewController to GroupTableViewController.
  override var SegueIdentifierThisToGroup: String {
    get {
      return "PostToGroup"
    }
  }
  
  /// Segue Identifier in Storyboard for this UITableViewController to UserTableViewController.
  var SegueIdentifierThisToUser: String {
    get {
      return "PostToUser"
    }
  }
  
  // MARK: UIViewController
  
  // Initializes commentTree array
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if NSUserDefaults.standardUserDefaults().valueForKey(NSUserDefaults.Auth) != nil {
      retrieveCommentTree()
    }
    
    // Gets rid of Front Page Text on back button
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
  }
  
  // MARK: Helper Functions
  
  /// Used to retrieve comment tree from Cillo servers that corresponds to the post passed to this UIViewController.
  ///
  /// Assigns commentTree property of SinglePostTableViewController correct values from server calls.
  func retrieveCommentTree() {
    activityIndicator.start()
    DataManager.sharedInstance.getPostCommentsByID(post.postID, completion: { (error, result) -> Void in
      self.activityIndicator.stop()
      if error != nil {
        println(error)
        error!.showAlert()
      } else {
        self.commentTree = result!
      }
    })
    tableView.reloadData()
  }
  
}
