//
//  MyBoardsViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 11/25/14.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Handles first view of Boards tab (Boards of end user).
///
/// Formats TableView to look appealing and be functional.
class MyBoardsTableViewController: MultipleBoardsTableViewController {

  // MARK: Properties
  
  /// True if `tableView` is currently displaying boards from search results.
  var searched = false
  
  /// Array of board names that are returned from autocompletion on `searchBar`.
  var searchResults = [String]()
  
  // MARK: IBOutlets
  
  /// Search bar that allows end user to discover new boards in Cillo database.
  @IBOutlet weak var searchBar: UISearchBar!
  
  // MARK: Constants
  
  /// Segue Identifier in Storyboard for segue to BoardTableViewController.
  override var segueIdentifierThisToBoard: String {
    return SegueIdentifiers.myBoardsToBoard
  }
  
  // MARK: UIViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if KeychainWrapper.hasAuthAndUser() {
      refreshControl?.beginRefreshing()
      retrieveData()
    }
  }
  
  // MARK: UITableViewDataSource
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if tableView == self.tableView {
      if indexPath.row >= boards.count {
        return dequeueAndSetupNewBoardCellForIndexPath(indexPath)
      } else {
        return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
      }
    } else {
      let cell = UITableViewCell()
      cell.textLabel?.text = searchResults[indexPath.row]
      return cell
    }
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableView == self.tableView {
      return super.tableView(tableView, numberOfRowsInSection: section) + 1
    } else {
      return searchResults.count
    }
  }
  
  // MARK: UITableViewDelegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if tableView == self.tableView {
      if indexPath.row >= boards.count {
        if let tabBarController = tabBarController as? TabViewController {
          tabBarController.performSegueWithIdentifier(SegueIdentifiers.tabToNewBoard, sender: indexPath)
        }
      } else {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
      }
    } else {
      searchBoardsForName(searchResults[indexPath.row]) { boards in
        if let boards = boards {
          dispatch_async(dispatch_get_main_queue()) {
            self.boards = boards
            self.searched = true
            self.tableView.reloadData()
            self.searchDisplayController?.setActive(false, animated: true)
          }
        }
      }
    }
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if tableView == self.tableView {
      if indexPath.row >= boards.count {
        return heightOfSingleButtonCells
      } else {
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
      }
    } else {
      return 44
    }
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return searched ? "Search Results" : "Trending Boards"
  }
  
  // MARK: Setup Helper Functions
  
  override func separatorHeightForIndexPath(indexPath: NSIndexPath) -> CGFloat {
    if indexPath.row == boards.count - 1 {
      return dividerHeight
    } else {
      return super.separatorHeightForIndexPath(indexPath)
    }
  }
  
  // MARK: Networking Helper Functions
  
  /// Used to display autocomplete results for searches in `searchBar`.
  ///
  /// :param: search The search text to be autocompleted.
  /// :param: completionHandler The completion block for the server call.
  /// :param: names The board names returned from the server call.
  func autocompleteBoardsSearch(search: String, completionHandler: (names: [String]?) -> ()) {
    DataManager.sharedInstance.boardsAutocompleteByName(search) { error, result in
      if let error = error {
        self.handleError(error)
        completionHandler(names: nil)
      } else {
        completionHandler(names: result)
      }
    }
  }
  
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
  
  /// Used to retrieve trending boards for the end User from Cillo servers.
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: boards The trending boards for the end user.
  /// :param: * Nil if there was an error in the server call.
  func retrieveTrendingBoards(completionHandler: (boards: [Board]?) -> ()) {
    if let userID = KeychainWrapper.userID() {
      DataManager.sharedInstance.getEndUserTrendingBoards { error, result in
        if let error = error {
          self.handleError(error)
          completionHandler(boards: nil)
        } else {
          completionHandler(boards: result)
        }
      }
    }
  }
  
  /// Used to retrieve all necessary data to display UITableViewCells in this view controller.
  ///
  /// Assigns boards property of MultipleBoardsTableViewController correct values from server calls.
  override func retrieveData() {
    retrievingPage = true
    boards = []
    searched = false
    retrieveTrendingBoards { boards in
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
  
  /// Used to search Cillo servers for boards matching the `search` text.
  ///
  /// :param: name The text of the search.
  /// :param: completionHandler The completion block of the server call.
  /// :param: boards The boards returned from the server call matching the search text.
  func searchBoardsForName(name: String, completionHandler: (boards: [Board]?) -> ()) {
    DataManager.sharedInstance.boardsSearchByName(name) { error, result in
      if let error = error {
        self.handleError(error)
        completionHandler(boards: nil)
      } else {
        completionHandler(boards: result)
      }
    }
  }
}

// MARK: - UISearchControllerDelegate

extension MyBoardsTableViewController: UISearchControllerDelegate {
  
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    if searchBar.text != "" {
      autocompleteBoardsSearch(searchBar.text) { names in
        if let names = names {
          dispatch_async(dispatch_get_main_queue()) {
            self.searchResults = names
            self.searchDisplayController?.searchResultsTableView.reloadData()
          }
        }
      }
    }
  }
  
  func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    searchResults = []
    searchBar.resignFirstResponder()
  }
}

// MARK: - UISearchBarDelegate

extension MyBoardsTableViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    searchResults = []
    searchBoardsForName(searchBar.text) { boards in
      if let boards = boards {
        dispatch_async(dispatch_get_main_queue()) {
          self.boards = boards
          self.searched = true
          self.tableView.reloadData()
          self.searchDisplayController?.setActive(false, animated: true)
        }
      }
    }
  }
}