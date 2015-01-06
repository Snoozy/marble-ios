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

  // MARK: IBOutlets
  
  /// Activity indicator used for network interactions.
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  // MARK: Constants
  
  /// Segue Identifier in Storyboard for this UITableViewController to PostTableViewController.
  override var SegueIdentifierThisToPost: String {
    get {
      return "GroupToPost"
    }
  }
  
  /// Segue Identifier in Storyboard for this UITableViewController to UserTableViewController.
  var SegueIdentifierThisToUser: String {
    get {
      return "GroupToUser"
    }
  }
  
  // MARK: UIViewController
  
  // Initializes commentTree array
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if NSUserDefaults.standardUserDefaults().valueForKey(NSUserDefaults.Auth) != nil {
      retrievePosts()
    }
    
    // Gets rid of Front Page Text on back button
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
  }
  
  // MARK: Helper Functions
  
  /// Used to retrieve posts in the assigned group's feed from Cillo servers.
  ///
  /// Assigns posts property of SingleGroupTableViewController correct values from server calls.
  func retrievePosts() {
    activityIndicator.start()
    DataManager.sharedInstance.getGroupFeed(group.groupID, completion: { (error, result) -> Void in
      self.activityIndicator.stop()
      if error != nil {
        println(error)
        error!.showAlert()
      } else {
        self.posts = result!
      }
    })
    tableView.reloadData()
  }

}
