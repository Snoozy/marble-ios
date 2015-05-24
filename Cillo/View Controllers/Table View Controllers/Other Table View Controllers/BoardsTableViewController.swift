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
    if NSUserDefaults.hasAuthAndUser() && userID != 0 {
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
  /// :param: completion The completion block for the server call.
  /// :param: boards The boards followed by user with userID.
  /// :param: * Nil if there was an error in the server call.
  func retrieveBoards(completion: (boards: [Board]?) -> Void) {
    DataManager.sharedInstance.getUserBoardsByID(lastBoardID: boards.last?.boardID, userID: userID) { error, result in
      if let error = error {
        println(error)
        error.showAlert()
        completion(boards: nil)
      } else {
        completion(boards: result!)
      }
    }
  }
  
  /// Used to retrieve all necessary data to display UITableViewCells in this view controller.
  ///
  /// Assigns boards property of MultipleBoardsTableViewController correct values from server calls.
  override func retrieveData() {
    let activityIndicator = addActivityIndicatorToCenterWithText("Retrieving Boards")
    retrievingPage = true
    boards = []
    pageNumber = 1
    seeAll = true
    retrieveBoards { boards in
      activityIndicator.removeFromSuperview()
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