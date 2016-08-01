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
  func overlayTableViewController(_ table: BoardOverlayTableViewController, didSelectBoard board: Board)
  func overlayTableViewController(_ table: BoardOverlayTableViewController, searchBarBecameFirstResponder searchBar: UISearchBar)
  func overlayTableViewController(_ table: BoardOverlayTableViewController, searchBarResignedFirstResponder searchBar: UISearchBar)
}

// MARK: - Classes

/// Controller of a pop up table view displaying the end user's boards.
class BoardOverlayTableViewController: UITableViewController {

  // MARK: Properties
  
  /// Boards displayed by popup table.
  var boards = [Board]() {
    didSet {
      boards.sorted { first, second in
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
    searchBar.searchBarStyle = .minimal
    searchBar.placeholder = "Search"
    retrieveBoards { boards in
      if let boards = boards {
        self.boards = boards
        self.tableView.reloadData()
      }
    }
  }
  
  // MARK: UITableViewDataSource
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return dequeueAndSetupSimpleBoardCellForIndexPath(indexPath)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return (searchResults ?? boards).count
  }
  
  // MARK: UITableViewDelegate
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    delegate?.overlayTableViewController(self, didSelectBoard: (searchResults ?? boards)[(indexPath as NSIndexPath).row])
  }
  
  // MARK: Setup Helper Functions
  
  /// Makes a SimpleBoardCell for the corresponding board in `boards` based on the passed indexPath.
  ///
  /// :param: indexPath The index path of the cell to be created in the table view.
  ///
  /// :returns: The created SimpleBoardCell.
  func dequeueAndSetupSimpleBoardCellForIndexPath(_ indexPath: IndexPath) -> SimpleBoardCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardIdentifiers.simpleBoardCell) as! SimpleBoardCell
    cell.makeCellFromBoard((searchResults ?? boards)[(indexPath as NSIndexPath).row])
    return cell
  }
  
  // MARK: Networking Helper Functions
  
  /// Used to retrieve boards followed by end User from Cillo servers.
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: boards The boards that the end user follows.
  /// :param: * Nil if there was an error in the server call.
  func retrieveBoards(_ completionHandler: (boards: [Board]?) -> ()) {
    if let userID = KeychainWrapper.userID() {
      DataManager.sharedInstance.getUserBoardsByID(userID) { result in
        switch result {
        case .error(let error):
          self.handleError(error)
          completionHandler(boards: nil)
        case .value(let boards):
          completionHandler(boards: boards.unbox)
        }
      }
    }
  }
  
  /// Handles an error received from a network call within the app.
  ///
  /// :param: error The error to be handled
  func handleError(_ error: NSError) {
    println(error)
    switch error.cilloErrorCode() {
    case .notCilloDomain:
      break
    default:
      error.showAlert()
    }
  }
}

// MARK: - UISearchBarDelegate

extension BoardOverlayTableViewController: UISearchBarDelegate {
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    searchResults = boards.filter { element in
      element.name.rangeOfString(searchBar.text, options: .CaseInsensitiveSearch) != nil
    }
    tableView.reloadData()
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchResults = nil
    searchBar.text = ""
    searchBar.resignFirstResponder()
    tableView.reloadData()
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
  
  func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
    searchBar.showsCancelButton = true
    delegate?.overlayTableViewController(self, searchBarBecameFirstResponder: searchBar)
    return true
  }
  
  func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
    if searchResults == nil {
      searchBar.showsCancelButton = false
    }
    delegate?.overlayTableViewController(self, searchBarResignedFirstResponder: searchBar)
    return true
  }
}
