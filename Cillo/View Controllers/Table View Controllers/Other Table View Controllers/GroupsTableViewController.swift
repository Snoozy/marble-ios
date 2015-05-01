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

  var retrievingPage = false
  
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
    let activityIndicator = addActivityIndicatorToCenterWithText("Retrieving Groups")
    retrievingPage = true
    groups = []
    pageNumber = 1
    retrieveGroups( { (groups) -> Void in
      activityIndicator.removeFromSuperview()
      self.retrievingPage = false
      if groups != nil {
        self.groups = groups!
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
        self.pageNumber++
      }
    })
  }
  
  /// Used to retrieve the groups followed by user with userID from Cillo servers.
  ///
  /// :param: completion The completion block for the server call.
  /// :param: groups The groups followed by user with userID.
  /// :param: * Nil if there was an error in the server call.
  func retrieveGroups(completion: (groups: [Group]?) -> Void) {
    DataManager.sharedInstance.getUserGroupsByID(lastGroupID: groups.last?.groupID, userID: userID, completion: { (error, result) -> Void in
      if error != nil {
        println(error!)
        //error!.showAlert()
        completion(groups: nil)
      } else {
        completion(groups: result!)
      }
    })
  }
  
  override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if !retrievingPage && indexPath.row > (pageNumber - 2) * 20 + 10 {
      retrievingPage = true
      retrieveGroups( { (groups) in
        if groups != nil {
          for group in groups! {
            self.groups.append(group)
          }
          self.pageNumber++
          self.tableView.reloadData()
        }
        self.retrievingPage = false
      })
    }
  }

}
