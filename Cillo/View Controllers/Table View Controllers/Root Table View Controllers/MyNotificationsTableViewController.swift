//
//  MyNotificationsTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 6/15/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

/// Handles first view of Notifcations tab.
///
/// Formats TableView to look appealing and be functional.
class MyNotificationsTableViewController: MultipleNotificationTableViewController {
  
  // MARK: Properties
  
  /// View shown under navigation bar when there are new notifications not present in the table view.
  var newNotificationsButton: UIButton?
  
  // MARK: Constants
  
  /// Segue Identifier in Storyboard for segue to PostTableViewController.
  override var segueIdentifierThisToPost: String {
    return SegueIdentifiers.myNotificationsToPost
  }
  
  /// Segue Identifier in Storyboard for segue to UserTableViewController.
  override var segueIdentifierThisToUser: String {
    return SegueIdentifiers.myNotificationsToUser
  }
  
  // MARK: UIViewController
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    if KeychainWrapper.hasAuthAndUser() {
      refreshControl?.beginRefreshing()
      retrieveData()
    }
    if let tabBarController = tabBarController as? TabViewController {
      tabBarController.notificationsDataSource = self
    }
  }
  
  // MARK: UIScrollViewDelegate
  
  override func scrollViewDidScroll(scrollView: UIScrollView) {
    // keeps newNotificationsView correctly positioned in scrollView
    if let newNotificationsButton = newNotificationsButton {
      let newY = tableView.contentOffset.y
      newNotificationsButton.frame = CGRect(x: 0.0, y: newY, width: tableView.frame.size.width, height: 46.0)
    }
  }
  
  // MARK: Button Selectors
  
  /// Button event for `newNotificationsButton` that refreshes the notifications in the table when the button is pressed.
  func refreshNotifications(sender: UIButton) {
    refreshControl?.beginRefreshing()
    retrieveData()
  }
  
  // MARK: Setup Helper Functions
  
  /// Formats `newNotificationsButton` UI correctly.
  func makeNewNotificationsButtonWithUnreadCount(count: Int) {
    let scheme = ColorScheme.defaultScheme
    newNotificationsButton = UIButton(frame: CGRect(x: 0.0, y: tableView.contentOffset.y, width: tableView.frame.size.width, height: 46.0))
    newNotificationsButton!.backgroundColor = scheme.barAboveKeyboardColor()
    newNotificationsButton!.addTarget(self, action: "refreshNotifications:", forControlEvents: .TouchUpInside)
    newNotificationsButton!.setTitle("You have \(count) new notifications", forState: .Normal)
    newNotificationsButton!.setTitleColor(scheme.barAboveKeyboardTouchableTextColor(), forState: .Normal)
    newNotificationsButton!.titleLabel?.font = UIFont.systemFontOfSize(14)
  }
  
  // MARK: Networking Helper Functions
  
  /// Sends read notifications request to Cillo Servers for the end user
  ///
  /// :param: completionHandler The completion block for the repost.
  /// :param: success True if the request was successful.
  func readNotifications(completionHandler: (success: Bool) -> ()) {
    DataManager.sharedInstance.activeRequests++
    DataManager.sharedInstance.readEndUserNotifications { error, success in
      DataManager.sharedInstance.activeRequests--
      if let error = error {
        self.handleError(error)
        completionHandler(success: false)
      } else {
        completionHandler(success: success)
      }
    }
  }
  
  /// Updates and reads the displayedNotifcations to the most recent retrieval by the TabViewController.
  override func retrieveData() {
    if let tabBarController = tabBarController as? TabViewController {
      displayedNotifications = tabBarController.notifications
      if let newNotificationsButton = newNotificationsButton {
        newNotificationsButton.removeFromSuperview()
        self.newNotificationsButton = nil
      }
      refreshControl?.endRefreshing()
      tableView.reloadData()
      readNotifications { success in
        if success {
          tabBarController.setNotificationsBadgeValueTo(0)
        }
      }
    } else {
      refreshControl?.endRefreshing()
    }
  }
}

// MARK: NotificationsDataSource

extension MyNotificationsTableViewController: NotificationsDataSource {
  
  func notificationsRefreshedTo(notifications: [Notification], withUnreadCount count: Int) {
    if let newNotificationsButton = newNotificationsButton {
      newNotificationsButton.removeFromSuperview()
      self.newNotificationsButton = nil
    }
    if count != 0 {
      makeNewNotificationsButtonWithUnreadCount(count)
      view.addSubview(newNotificationsButton!)
      view.bringSubviewToFront(newNotificationsButton!)
    }
  }
}
