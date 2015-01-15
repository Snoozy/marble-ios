//
//  GroupsTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 1/5/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Handles view of many GroupCells corresponding to the followed Groups of a User.
///
/// Formats TableView to look appealing and be functional.
///
/// **Note:** Must assign userID property a relevant value before displaying this GroupsTableViewController.
class GroupsTableViewController: MultipleGroupsTableViewController {

  // MARK: Properties
  
  /// User ID of the User that is following the groups displayed in this MyGroupsTableViewController.
  var userID: Int = 0

  // MARK: Constants
  
  /// Segue Identifier in Storyboard for this UITableViewController to GroupTableViewController.
  override var SegueIdentifierThisToGroup: String {
    get{
      return "GroupsToGroup"
    }
  }
  
  /// Segue Identifier in Storyboard for this UITableViewController to NewGroupViewController.
  override var SegueIdentifierThisToNewGroup: String {
    get{
      return "GroupsToNewGroup"
    }
  }
  
  // MARK: UIViewController
  
  override func viewDidLoad() {
    if NSUserDefaults.hasAuthAndUser() && userID != 0 {
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
  
  /// Used to retrieve the groups followed by user with userID from Cillo servers.
  ///
  /// :param: completion The completion block for the server call.
  /// :param: groups The groups followed by user with userID.
  /// :param: * Nil if there was an error in the server call.
  func retrieveGroups(completion: (groups: [Group]?) -> Void) {
    let activityIndicator = addActivityIndicatorToCenterWithText("Retrieving Groups")
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
