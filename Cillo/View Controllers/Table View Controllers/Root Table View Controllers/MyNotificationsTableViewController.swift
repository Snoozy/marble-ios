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
  var newNotificationsView: UIView?
  
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
    if let newNotificationsView = newNotificationsView {
      let newY = tableView.contentOffset.y
      newNotificationsView.frame = CGRect(x: 0.0, y: newY, width: tableView.frame.size.width, height: 46.0)
    }
  }
  
  // MARK: Setup Helper Functions
  
  /// Formats `newNotificationsView` UI correctly.
  func makeNewNotificationsViewWithUnreadCount(count: Int) {
    let scheme = ColorScheme.defaultScheme
    newNotificationsView = UIView(frame: CGRect(x: 0.0, y: tableView.contentOffset.y, width: tableView.frame.size.width, height: 46.0))
    newNotificationsView!.backgroundColor = scheme.barAboveKeyboardColor()
    let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: newNotificationsView!.frame.width, height: 40.0))
    label.center = newNotificationsView!.center
    label.font = UIFont.systemFontOfSize(14)
    label.text = "You have \(count) new notifications"
    label.textColor = scheme.barAboveKeyboardTouchableTextColor()
    label.textAlignment = .Center
    newNotificationsView!.addSubview(label)
  }
  
  // MARK: Networking Helper Functions
  
  /// Sends read notifications request to Cillo Servers for the end user
  ///
  /// :param: completionHandler The completion block for the repost.
  /// :param: success True if the request was successful.
  func readNotifications(completionHandler: (success: Bool) -> ()) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    DataManager.sharedInstance.readEndUserNotifications { error, success in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
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
      if let newNotificationsView = newNotificationsView {
        newNotificationsView.removeFromSuperview()
        self.newNotificationsView = nil
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
    if let newNotificationsView = newNotificationsView {
      newNotificationsView.removeFromSuperview()
      self.newNotificationsView = nil
    }
    if count != 0 {
      makeNewNotificationsViewWithUnreadCount(count)
      view.addSubview(newNotificationsView!)
      view.bringSubviewToFront(newNotificationsView!)
    }
  }
}
