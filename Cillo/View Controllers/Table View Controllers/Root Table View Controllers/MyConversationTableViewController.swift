//
//  MyConversationTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 7/3/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Handles first view of Messages tab.
///
/// Formats TableView to look appealing and be functional.
class MyConversationTableViewController: MultipleConversationTableViewController {
  
  // MARK: Constants

  /// Segue Identifier in Storyboard for segue to UserTableViewController.
  override var segueIdentifierThisToUser: String {
    return SegueIdentifiers.myConversationsToUser
  }
  
  /// Segue Identifier in Storyboard for segue to MessagesViewController.
  override var segueIdentifierThisToMessages: String {
    return SegueIdentifiers.myConversationsToMessages
  }
  
  // MARK: UIViewController
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if KeychainWrapper.hasAuthAndUser() {
      refreshControl?.beginRefreshing()
      retrieveData()
    }
    if let tabBarController = tabBarController as? TabViewController {
      tabBarController.conversationsDataSource = self
    }
  }
  // MARK: Networking Helper Functions
  
  /// Sends read inbox request to Cillo Servers for the end user.
  ///
  /// :param: completionHandler The completion block for the repost.
  /// :param: success True if the request was successful.
  func readInbox(_ completionHandler: (success: Bool) -> ()) {
    DataManager.sharedInstance.readEndUserInbox { result in
      self.handleSuccessResponse(result, completionHandler: completionHandler)
    }
  }
  
  /// Used to retrieve all necessary data to display UITableViewCells in this view controller.
  ///
  /// Assigns `conversations` correct values from server calls.
  override func retrieveData() {
    if let tabBarController = tabBarController as? TabViewController {
      displayedConversations = tabBarController.conversations
      refreshControl?.endRefreshing()
      tableView.reloadData()
      readInbox { success in
        if success {
          DispatchQueue.main.async {
            tabBarController.setMessagesBadgeValueTo(0)
          }
        }
      }
    } else {
      refreshControl?.endRefreshing()
    }
  }
}

// MARK: ConversationsDataSource

extension MyConversationTableViewController: ConversationsDataSource {
  
  func conversationsRefreshedTo(_ conversations: [Conversation], withUnreadCount count: Int) {
    displayedConversations = conversations
    tableView.reloadData()
  }
}
