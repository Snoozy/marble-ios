//
//  BoardOverlayTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 9/4/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

// MARK: - Protocols

/// Delegate for an overlay table that allows the controller to pass back a selected board.
protocol BoardOverlayTableViewControllerDelegate {
  func overlayTableViewController(table: BoardOverlayTableViewController, didSelectBoard board: Board)
  func overlayTableViewController(table: BoardOverlayTableViewController, searchBarBecameFirstResponder searchBar: UISearchBar)
  func overlayTableViewController(table: BoardOverlayTableViewController, searchBarResignedFirstResponder searchBar: UISearchBar)
}

// MARK: - Classes

/// Controller of a pop up table view displaying the end user's boards.
class BoardOverlayTableViewController: UITableViewController {

  // MARK: Properties
  
  /// Boards displayed by popup table.
  var boards = [Board]() {
    didSet {
      boards.sort { first, second in
        first.name < second.name
      }
    }
  }
  
  /// Search results on the boards array.
  ///
  /// * Nil signifies that no search is currently taking place.
  var searchResults: [Board]?
  
  /// Delegate for this controller, allowing the selected board to be passed back from the popup.
  var delegate: BoardOverlayTableViewControllerDelegate?
  
  // MARK: UIViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
    tableView.tableHeaderView = searchBar
    searchBar.delegate = self
    searchBar.searchBarStyle = .Minimal
    searchBar.placeholder = "Search"
    retrieveBoards { boards in
      if let boards = boards {
        self.boards = boards
        self.tableView.reloadData()
      }
    }
  }
  
  // MARK: UITableViewDataSource
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    return dequeueAndSetupSimpleBoardCellForIndexPath(indexPath)
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return (searchResults ?? boards).count
  }
  
  // MARK: UITableViewDelegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    delegate?.overlayTableViewController(self, didSelectBoard: (searchResults ?? boards)[indexPath.row])
  }
  
  // MARK: Setup Helper Functions
  
  /// Makes a SimpleBoardCell for the corresponding board in `boards` based on the passed indexPath.
  ///
  /// :param: indexPath The index path of the cell to be created in the table view.
  ///
  /// :returns: The created SimpleBoardCell.
  func dequeueAndSetupSimpleBoardCellForIndexPath(indexPath: NSIndexPath) -> SimpleBoardCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.simpleBoardCell) as! SimpleBoardCell
    cell.makeCellFromBoard((searchResults ?? boards)[indexPath.row])
    return cell
  }
  
  // MARK: Networking Helper Functions
  
  /// Used to retrieve boards followed by end User from Cillo servers.
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: boards The boards that the end user follows.
  /// :param: * Nil if there was an error in the server call.
  func retrieveBoards(completionHandler: (boards: [Board]?) -> ()) {
    if let userID = KeychainWrapper.userID() {
      DataManager.sharedInstance.getUserBoardsByID(userID) { error, result in
        if let error = error {
          self.handleError(error)
          completionHandler(boards: nil)
        } else {
          completionHandler(boards: result)
        }
      }
    }
  }
  
  /// Handles an error received from a network call within the app.
  ///
  /// :param: error The error to be handled
  func handleError(error: NSError) {
    println(error)
    switch error.cilloErrorCode() {
    case .NotCilloDomain:
      break
    default:
      error.showAlert()
    }
  }
}

// MARK: - UISearchBarDelegate

extension BoardOverlayTableViewController: UISearchBarDelegate {
  
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    searchResults = boards.filter { element in
      element.name.rangeOfString(searchBar.text, options: .CaseInsensitiveSearch) != nil
    }
    tableView.reloadData()
  }
  
  func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    searchResults = nil
    searchBar.text = ""
    searchBar.resignFirstResponder()
    tableView.reloadData()
  }
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
  
  func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
    searchBar.showsCancelButton = true
    delegate?.overlayTableViewController(self, searchBarBecameFirstResponder: searchBar)
    return true
  }
  
  func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
    if searchResults == nil {
      searchBar.showsCancelButton = false
    }
    delegate?.overlayTableViewController(self, searchBarResignedFirstResponder: searchBar)
    return true
  }
}
