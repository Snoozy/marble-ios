//
//  BoardsTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 1/5/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Handles view of many BoardCells corresponding to the followed Boards of a User.
///
/// Formats TableView to look appealing and be functional.
///
/// **Note:** Must assign userID property a relevant value before displaying this BoardsTableViewController.
class BoardsTableViewController: MultipleBoardsTableViewController {
  
  // MARK: Properties
  
  /// User ID of the User that is following the boards displayed in this MyBoardsTableViewController.
  var userID = 0

  // MARK: Constants
  
  /// Segue Identifier in Storyboard for segue to BoardTableViewController.
  override var segueIdentifierThisToBoard: String {
    return SegueIdentifiers.boardsToBoard
  }
  
  // MARK: UIViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if KeychainWrapper.hasAuthAndUser() && userID != 0 {
      refreshControl?.beginRefreshing()
      retrieveData()
    }
  }
  
  // MARK: Networking Helper Functions
  
  /// Used to retrieve the boards followed by user with userID from Cillo servers.
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: boards The boards followed by user with userID.
  /// :param: * Nil if there was an error in the server call.
  func retrieveBoards(completionHandler: (boards: [Board]?) -> ()) {
    DataManager.sharedInstance.getUserBoardsByID(userID) { result in
      self.handleSingleElementResponse(result, completionHandler: completionHandler)
    }
  }
  
  /// Used to retrieve all necessary data to display UITableViewCells in this view controller.
  ///
  /// Assigns boards property of MultipleBoardsTableViewController correct values from server calls.
  override func retrieveData() {
    retrievingPage = true
    boards = []
    retrieveBoards { boards in
      dispatch_async(dispatch_get_main_queue()) {
        if let boards = boards {
          self.boards = boards
          self.tableView.reloadData()
        }
        self.refreshControl?.endRefreshing()
        self.retrievingPage = false
      }
    }
  }
}
