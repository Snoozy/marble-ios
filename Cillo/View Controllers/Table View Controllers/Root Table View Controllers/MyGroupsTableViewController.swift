//
//  MyGroupsViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 11/25/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

// TODO: Look into UI of this controller. Needs search bar to allow access to other unfollowed groups.

/// Handles first view of Groups tab (Groups of logged in User).
///
/// Formats TableView to look appealing and be functional.
class MyGroupsTableViewController: MultipleGroupsTableViewController {

  // MARK: Constants
  
  /// Segue Identifier in Storyboard for this UITableViewController to GroupTableViewController.
  override var SegueIdentifierThisToGroup: String {
    get {
      return "MyGroupsToGroup"
    }
  }
  
  /// Segue Identifier in Storyboard for this UITableViewController to NewGroupViewController.
  override var SegueIdentifierThisToNewGroup: String {
    get {
      return "MyGroupsToNewGroup"
    }
  }
  
  // MARK: UIViewController
  
  /// Initializes groups array
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if NSUserDefaults.hasAuthAndUser() {
      retrieveData()
    }
  }
  
  // MARK: Helper Functions
  
  /// Used to retrieve all necessary data to display UITableViewCells in this UIViewController.
  ///
  /// Assigns groups property of MultipleGroupsTableViewController correct values from server calls.
  override func retrieveData() {
    retrieveGroups( { (groups) -> Void in
      if groups != nil {
        self.groups = groups!
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
      }
    })
  }
  
  /// Used to retrieve groups followed by logged in User from Cillo servers.
  ///
  /// :param: completion The completion block for the server call.
  /// :param: groups The groups that the logged in User follows.
  /// :param: * Nil if there was an error in the server call.
  func retrieveGroups(completion: (groups: [Group]?) -> Void) {
    let activityIndicator = addActivityIndicatorToCenterWithText("Retrieving Groups")
    if let userID = (NSUserDefaults.standardUserDefaults().valueForKey(NSUserDefaults.User) as? Int) {
      DataManager.sharedInstance.getUserGroupsByID(userID, completion: { (error, result) -> Void in
        activityIndicator.removeFromSuperview()
        if error != nil {
          println(error!)
          error!.showAlert()
          completion(groups: nil)
        } else {
          completion(groups: result!)
        }
      })
    }
  }
  
}
