//
//  MyGroupsViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 11/25/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

// TODO: Look into UI of this controller. Needs search bar to allow access to other unfollowed groups.

/// Handles first view of Groups tab (Groups of logged in User).
///
/// Formats TableView to look appealing and be functional.
class MyGroupsTableViewController: MultipleGroupsTableViewController {

  var retrievingPage = false
  
  var searched = false
  
  var searchResults: [String] = []
  
  // MARK: Constants
  
  /// Segue Identifier in Storyboard for this UITableViewController to GroupTableViewController.
  override var SegueIdentifierThisToGroup: String {
    get {
      return "MyGroupsToGroup"
    }
  }
  
  // MARK: UIViewController
  
  /// Initializes groups array
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if NSUserDefaults.hasAuthAndUser() {
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
      if groups != nil {
        self.pageNumber++
        self.groups = groups!
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
      }
      self.retrievingPage = false
    })
  }
  
  /// Used to retrieve groups followed by logged in User from Cillo servers.
  ///
  /// :param: completion The completion block for the server call.
  /// :param: groups The groups that the logged in User follows.
  /// :param: * Nil if there was an error in the server call.
  func retrieveGroups(completion: (groups: [Group]?) -> Void) {
    
    if let userID = (NSUserDefaults.standardUserDefaults().valueForKey(NSUserDefaults.User) as? Int) {
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
  }
  
  // TODO: DOcument
  func searchGroups(#search: String, completion: (groups: [Group]?) -> Void) {
    DataManager.sharedInstance.groupsSearchByName(search, completion: { (error, result) -> Void in
      if error != nil {
        println(error!)
        error!.showAlert()
        completion(groups: nil)
      } else {
        completion(groups: result!)
      }
    })
  }
  
  // TODO: DOcument
  func autocompleteGroups(#search: String, completion: (names: [String]?) -> Void) {
    DataManager.sharedInstance.groupsAutocompleteByName(search, completion: { (error, result) -> Void in
      if error != nil {
        println(error!)
        error!.showAlert()
        completion(names: nil)
      } else {
        completion(names: result!)
      }
    })
  }
  
  override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if tableView == self.tableView && !searched && !retrievingPage && indexPath.row > (pageNumber - 2) * 20 + 10 {
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

extension MyGroupsTableViewController: UISearchControllerDelegate {
  
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    if searchBar.text != "" {
      autocompleteGroups(search: searchBar.text, completion: { (names) in
        if names != nil {
          self.searchResults = names!
          self.searchDisplayController?.searchResultsTableView.reloadData()
        }
      })
    }
  }
  
  func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    searchResults = []
    searchBar.resignFirstResponder()
  }
}

extension MyGroupsTableViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    searchResults = []
    searchGroups(search: searchBar.text, completion: { (groups) in
      if groups != nil {
        self.groups = groups!
        self.tableView.reloadData()
        self.searchDisplayController?.setActive(false, animated: true)
      }
    })
  }
}

extension MyGroupsTableViewController: UITableViewDataSource, UITableViewDelegate {
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableView == self.tableView {
      return super.tableView(tableView, numberOfRowsInSection: section)
    } else {
      return searchResults.count
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if tableView == self.tableView {
      return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    } else {
      let cell = UITableViewCell()
      cell.textLabel?.text = searchResults[indexPath.row]
      return cell
    }
  }
  
  // MARK: UITableViewDelegate
  
  /// Sets height of cell to appropriate value.
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if tableView == self.tableView {
      return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    } else {
      return 44
    }
  }
  
  /// Sends view to GroupTableViewController if GroupCell is selected.
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if tableView == self.tableView {
      super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
    } else {
      searchGroups(search: searchResults[indexPath.row], completion: { (groups) in
        if groups != nil {
          self.groups = groups!
          self.tableView.reloadData()
          self.searchDisplayController?.setActive(false, animated: true)
        }
      })
    }
  }
  
}
