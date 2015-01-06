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
class GroupsTableViewController: MyGroupsTableViewController {

  // MARK: Properties
  
  var userID: Int = 0
  
  // MARK: Constants
  
  override var SegueIdentifierThisToGroup: String {
    get{
      return "GroupsToGroup"
    }
  }
  
  // MARK: Helper Functions
  
  override func retrieveGroups() {
    activityIndicator.start()
    DataManager.sharedInstance.getUserGroupsByID(userID, completion: { (error, result) -> Void in
      self.activityIndicator.stop()
      if error != nil {
        println(error)
        error!.showAlert()
      } else {
        self.groups = result!
      }
    })
    tableView.reloadData()
  }

}
