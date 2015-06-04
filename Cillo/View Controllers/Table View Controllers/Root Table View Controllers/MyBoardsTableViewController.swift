//
//  MyBoardsViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 11/25/14.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Handles first view of Boards tab (Boards of logged in User).
///
/// Formats TableView to look appealing and be functional.
class MyBoardsTableViewController: MultipleBoardsTableViewController {

  // MARK: Properties
  
  /// True if `tableView` is currently displaying boards from search results.
  var searched = false {
    didSet {
      if searched {
        seeAll = true
      }
    }
  }
  
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
    if NSUserDefaults.hasAuthAndUser() {
      retrieveData()
    }
  }
  
  // MARK: UITableViewDataSource
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if tableView == self.tableView {
      return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    } else {
      let cell = UITableViewCell()
      cell.textLabel?.text = searchResults[indexPath.row]
      return cell
    }
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableView == self.tableView {
      return super.tableView(tableView, numberOfRowsInSection: section)
    } else {
      return searchResults.count
    }
  }
  
  // MARK: UITableViewDelegate
  
  override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if tableView == self.tableView && !searched && !retrievingPage && indexPath.row > (pageNumber - 2) * 20 + 10 {
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
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if tableView == self.tableView {
      super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
    } else {
      searchBoards(search: searchResults[indexPath.row]) { boards in
        if let boards = boards {
          self.boards = boards
          self.searched = true
          self.tableView.reloadData()
          self.searchDisplayController?.setActive(false, animated: true)
        }
      }
    }
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if tableView == self.tableView {
      return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    } else {
      return 44
    }
  }
  
  // MARK: Networking Helper Functions
  
  /// Used to display autocomplete results for searches in `searchBar`.
  ///
  /// :param: search The search text to be autocompleted.
  /// :param: completion The completion block for the server call.
  /// :param: names The board names returned from the server call.
  func autocompleteBoards(#search: String, completion: (names: [String]?) -> Void) {
    DataManager.sharedInstance.boardsAutocompleteByName(search) { error, result in
      if let error = error {
        println(error)
        error.showAlert()
        completion(names: nil)
      } else {
        completion(names: result!)
      }
    }
  }
  
  /// Used to retrieve boards followed by end User from Cillo servers.
  ///
  /// :param: completion The completion block for the server call.
  /// :param: boards The boards that the logged in User follows.
  /// :param: * Nil if there was an error in the server call.
  func retrieveBoards(completion: (boards: [Board]?) -> Void) {
    if let userID = (NSUserDefaults.standardUserDefaults().valueForKey(NSUserDefaults.user) as? Int) {
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
  }
  
  /// Used to retrieve all necessary data to display UITableViewCells in this view controller.
  ///
  /// Assigns boards property of MultipleBoardsTableViewController correct values from server calls.
  override func retrieveData() {
    let activityIndicator = addActivityIndicatorToCenterWithText("Retrieving Boards")
    retrievingPage = true
    boards = []
    pageNumber = 1
    seeAll = false
    searched = false
    retrieveBoards { boards in
      activityIndicator.removeFromSuperview()
      if let boards = boards {
        self.pageNumber++
        self.boards = boards
        self.tableView.reloadData()
      }
      self.refreshControl?.endRefreshing()
      self.retrievingPage = false
    }
  }
  
  /// Used to search Cillo servers for boards matching the `search` text.
  ///
  /// :param: search The text of the search.
  /// :param: completion The completion block of the server call.
  /// :param: boards The boards returned from the server call matching the search text.
  func searchBoards(#search: String, completion: (boards: [Board]?) -> Void) {
    DataManager.sharedInstance.boardsSearchByName(search) { error, result in
      if let error = error {
        println(error)
        error.showAlert()
        completion(boards: nil)
      } else {
        completion(boards: result!)
      }
    }
  }
}

// MARK: - UISearchControllerDelegate

extension MyBoardsTableViewController: UISearchControllerDelegate {
  
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    if searchBar.text != "" {
      autocompleteBoards(search: searchBar.text) { names in
        if let names = names {
          self.searchResults = names
          self.searchDisplayController?.searchResultsTableView.reloadData()
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
    searchBoards(search: searchBar.text) { boards in
      if let boards = boards {
        self.boards = boards
        self.searched = true
        self.tableView.reloadData()
        self.searchDisplayController?.setActive(false, animated: true)
      }
    }
  }
}