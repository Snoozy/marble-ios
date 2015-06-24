//
//  TabViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 12/20/14.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

/// Data source that allows the TabViewController to tell another controller that it has updated the end user's notifications.
protocol NotificationsDataSource {
  
  /// Function that is called each time the notifications are retrieved via the `notificationRefresher` property of TabViewController.
  func notificationsRefreshedTo(notifications: [Notification], withUnreadCount count: Int)
}

/// Starting UIViewController of Cillo application.
///
/// Has 3 tabs:
///
/// * Home - Root VC is HomeTableViewController
/// * Discover - Root VC is MyBoardsTableViewController
/// * Me - Root VC is MeViewController
///
/// **Note:** Each tab has a FormattedNavigationController as the start of the tab.
class TabViewController: UITabBarController {
  
  // MARK: Properties
  
  /// Cached notifications to display in the notifications screen
  var notifications = [Notification]()
  
  /// Timer that is set to refresh the notifications every minute.
  var notificationRefresher = NSTimer()
  
  /// Data source that will display the notifications cached by this TabViewController.
  var notificationsDataSource: NotificationsDataSource?
  
  // MARK: Constants
  
  /// Index of the notifications tab in tab bar
  let notificationTabIndex = 2
  
  /// Interval that `notificationRefresher` will retrieve notifications at in seconds
  let timerInterval = NSTimeInterval(60)

  // MARK: UIViewController
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == SegueIdentifiers.tabToNewRepost {
      let destination = segue.destinationViewController as! NewRepostViewController
      if let sender = sender as? Repost {
          destination.postToRepost = sender.originalPost
      } else if let sender = sender as? Post {
          destination.postToRepost = sender
      }
    } else if segue.identifier == SegueIdentifiers.tabToSettings {
      let destination = segue.destinationViewController as! SettingsViewController
      if let sender = sender as? User {
        destination.user = sender
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    delegate = UIApplication.sharedApplication().delegate as? UITabBarControllerDelegate
  }
  
  override func viewDidAppear(animated: Bool) {
    // Modally presents LoginViewController if NSUserDefaults doesn't have an Auth Token stored.
    super.viewDidAppear(animated)
    if !KeychainWrapper.hasAuthAndUser() {
      performSegueWithIdentifier(SegueIdentifiers.tabToLogin, sender: self)
    } else {
      println(KeychainWrapper.authToken() ?? "keychain failed to get auth token")
      println(KeychainWrapper.userID() ?? -1)
      notificationRefresher = NSTimer.scheduledTimerWithTimeInterval(timerInterval, target: self, selector: "refreshNotifications:", userInfo: nil, repeats: true)
      notificationRefresher.fire()
    }
  }
  
  // MARK: Timer Selectors
  
  /// Refreshes the `notifications` array to an updated array.
  ///
  /// :param: The timer that calls this function every minute to refresh it.
  func refreshNotifications(sender: NSTimer) {
    getNotifications { notifications in
      if let notifications = notifications {
        self.notifications = notifications
        let unreadCount = notifications.filter { notification in
          !notification.read
        }.count
        self.setNotificationsBadgeValueTo(unreadCount)
        self.notificationsDataSource?.notificationsRefreshedTo(notifications, withUnreadCount: unreadCount)
      }
    }
  }
  
  // MARK: Setup Helper Functions
  
  /// Sets the red circle above the notifications tab to the specified value to signal that there are unread notifications.
  ///
  /// :param: value The value to set the notifcations to.
  func setNotificationsBadgeValueTo(value: Int) {
    if let notificationsTab = tabBar.items?[notificationTabIndex] as? UITabBarItem {
      if value == 0 {
        notificationsTab.badgeValue = nil
      } else {
        notificationsTab.badgeValue = "\(value)"
      }
    }
  }
  
  // MARK: Networking Helper Functions
  
  /// Retrieves the notifications for the end user.
  ///
  /// TabViewController must retrieve notifications in order to display badge.
  ///
  /// :param: completionHandler The completion block for the network request.
  /// :param: notifications The array of notifications retrieved from the server.
  func getNotifications(completionHandler: (notifications: [Notification]?) -> ()) {
    DataManager.sharedInstance.getEndUserNotifications { error, result in
      if let error = error {
        self.handleError(error)
        completionHandler(notifications: nil)
      } else {
        completionHandler(notifications: result)
      }
    }
  }
  
  /// Handles an error received from a network call within the app.
  ///
  /// :param: error The error to be handled
  func handleError(error: NSError) {
    println(error)
    if error.domain == NSError.cilloErrorDomain {
      switch error.code {
      case NSError.CilloErrorCodes.userUnauthenticated:
        handleUserUnauthenticatedError(error)
      default:
        error.showAlert()
      }
    }
  }
  
  // MARK: Error Handling Helper Functions
  
  /// Handles a cillo error with code `NSError.CilloErrorCodes.userUnauthenticated`.
  ///
  /// :param: error The error to be handled.
  func handleUserUnauthenticatedError(error: NSError) {
    performSegueWithIdentifier(SegueIdentifiers.tabToLogin, sender: error)
  }
  
  // MARK: Navigation Helper Functions
  
  /// Makes the displayed view controllers displayed by this TabViewContoller retrieve their data from the Cillo servers.
  func forceDataRetrievalUponUnwinding() {
    for vc in viewControllers! {
      if let vc = vc as? FormattedNavigationViewController, visibleVC = vc.topViewController as? CustomTableViewController {
        visibleVC.retrieveData()
      } else if let vc = vc as? CustomTableViewController {
        vc.retrieveData()
      }
    }
  }
  
  // MARK: IBActions
  
  /// Allows any View Controller to unwind back to the main Tab bar.
  @IBAction func unwindToTab(sender: UIStoryboardSegue) {
  }
}
