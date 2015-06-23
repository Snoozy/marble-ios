//
//  BoardsTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 1/5/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

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
  
  // MARK: UITableViewDelegate
  
  override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if !retrievingPage && indexPath.row > (pageNumber - 2) * 20 + 10 {
      retrievingPage = true
      retrieveBoards { boards in
        if let boards = boards {
          for board in boards {
            self.boards.append(board)
          }
          self.pageNumber++
          self.tableView.reloadData()
        }
        self.retrievingPage = false
      }
    }
  }
  
  // MARK: Networking Helper Functions
  
  /// Used to retrieve the boards followed by user with userID from Cillo servers.
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: boards The boards followed by user with userID.
  /// :param: * Nil if there was an error in the server call.
  func retrieveBoards(completionHandler: (boards: [Board]?) -> ()) {
    DataManager.sharedInstance.activeRequests++
    DataManager.sharedInstance.getUserBoardsByID(userID, lastBoardID: boards.last?.boardID) { error, result in
      DataManager.sharedInstance.activeRequests--
      if let error = error {
        self.handleError(error)
        completionHandler(boards: nil)
      } else {
        completionHandler(boards: result)
      }
    }
  }
  
  /// Used to retrieve all necessary data to display UITableViewCells in this view controller.
  ///
  /// Assigns boards property of MultipleBoardsTableViewController correct values from server calls.
  override func retrieveData() {
    retrievingPage = true
    boards = []
    pageNumber = 1
    seeAll = true
    retrieveBoards { boards in
      if let boards = boards {
        self.boards = boards
        self.tableView.reloadData()
        self.pageNumber++
      }
      self.refreshControl?.endRefreshing()
      self.retrievingPage = false
    }
  }
}
