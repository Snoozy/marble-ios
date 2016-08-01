//
//  TabViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 12/20/14.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Data source that allows the TabViewController to tell another controller that it has updated the end user's notifications.
protocol NotificationsDataSource {
  
  /// Function that is called each time the notifications are retrieved via the `notificationRefresher` property of TabViewController.
  func notificationsRefreshedTo(_ notifications: [Notification], withUnreadCount count: Int)
}

/// Data source that allows the TabViewController to tell another controller that it has updated the end user's conversations.
protocol ConversationsDataSource {
  
  /// Function that is called each time the notifications are retrieved via the `notificationRefresher` property of TabViewController.
  func conversationsRefreshedTo(_ conversations: [Conversation], withUnreadCount count: Int)
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
  
  /// Cached conversations to display in the messages screen.
  var conversations = [Conversation]()
  
  /// Data source that will display the conversations cached by this TabViewController.
  var conversationsDataSource: ConversationsDataSource?
  
  /// Cached notifications to display in the notifications screen.
  var notifications = [Notification]()
  
  /// Timer that is set to refresh the notifications and conversations every minute.
  var notificationRefresher = Timer()
  
  /// Data source that will display the notifications cached by this TabViewController.
  var notificationsDataSource: NotificationsDataSource?
  
  /// Cached user object representing the end user.
  var endUser: User?
  
  // MARK: Constants
  
  /// Index of the messages tab in tab bar
  let messageTabIndex = 3
  
  /// Index of the notifications tab in tab bar
  let notificationTabIndex = 2
  
  /// Index of the discover tab in tab bar
  let discoverTabIndex = 1
  
  /// Index of the home tab in tab bar
  let homeTabIndex = 0
  
  /// Interval that `notificationRefresher` will retrieve notifications at in seconds
  let timerInterval = TimeInterval(60)

  // MARK: UIViewController
  
  override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == SegueIdentifiers.tabToNewRepost {
      let destination = segue.destination as! NewRepostViewController
      if let sender = sender as? Repost {
          destination.postToRepost = sender.originalPost
      } else if let sender = sender as? Post {
          destination.postToRepost = sender
      }
      destination.endUser = endUser
    } else if segue.identifier == SegueIdentifiers.tabToSettings {
      let destination = segue.destination as! SettingsViewController
      if let sender = sender as? User {
        destination.user = sender
      }
    } else if segue.identifier == SegueIdentifiers.tabToNewPost {
      let destination = segue.destination as! NewPostViewController
      destination.endUser = endUser
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    delegate = UIApplication.shared.delegate as? UITabBarControllerDelegate
  }
  
  override func viewDidAppear(_ animated: Bool) {
    // Modally presents LoginViewController if NSUserDefaults doesn't have an Auth Token stored.
    super.viewDidAppear(animated)
    if !KeychainWrapper.hasAuthAndUser() {
      performSegue(withIdentifier: SegueIdentifiers.tabToLogin, sender: self)
    } else {
      println("Auth token: " + (KeychainWrapper.authToken() ?? "keychain failed to get auth token"))
      println("User ID: \(KeychainWrapper.userID() ?? -1)")
      if endUser == nil {
        retrieveEndUser { user in
          if let user = user {
            if self.endUser == nil {
              self.endUser = user
            }
          }
        }
      }
      notificationRefresher = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(TabViewController.refreshNotifications(_:)), userInfo: nil, repeats: true)
      notificationRefresher.fire()
    }
  }
  
  // MARK: Timer Selectors
  
  /// Refreshes the `notifications` array to an updated array.
  ///
  /// :param: The timer that calls this function every minute to refresh it.
  func refreshNotifications(_ sender: Timer) {
    getNotifications { notifications in
      if let notifications = notifications {
        self.notifications = notifications
        let unreadCount = notifications.filter { notification in
          !notification.read
        }.count
        self.setNotificationsBadgeValueTo(unreadCount)
        self.notificationsDataSource?.notificationsRefreshedTo(notifications, withUnreadCount: unreadCount)
        self.getConversations { conversations, inboxCount in
          if let conversations = conversations, inboxCount = inboxCount {
            self.conversations = conversations
            self.setMessagesBadgeValueTo(inboxCount)
            self.conversationsDataSource?.conversationsRefreshedTo(conversations, withUnreadCount: inboxCount)
          }
        }
      }
    }
  }
  
  // MARK: Setup Helper Functions
  
  /// Sets the red circle above the messages tab to the specified value to signal that there are unread messages.
  ///
  /// :param: value The value to set the unread messages to.
  func setMessagesBadgeValueTo(_ value: Int) {
    if let messagesTab = tabBar.items?[messageTabIndex] as? UITabBarItem {
      if value == 0 {
        messagesTab.badgeValue = nil
      } else {
        messagesTab.badgeValue = "\(value)"
      }
    }
  }
  
  /// Sets the red circle above the notifications tab to the specified value to signal that there are unread notifications.
  ///
  /// :param: value The value to set the notifcations to.
  func setNotificationsBadgeValueTo(_ value: Int) {
    if let notificationsTab = tabBar.items?[notificationTabIndex] as? UITabBarItem {
      if value == 0 {
        notificationsTab.badgeValue = nil
      } else {
        notificationsTab.badgeValue = "\(value)"
      }
    }
  }
  
  // MARK: Networking Helper Functions
  
  /// Retrieves the conversations for the end user.
  ///
  /// TabViewController must retrieve conversations in order to display badge.
  ///
  /// :param: completionHandler The completion block for the network request.
  /// :param: conversations The array of conversations retrieved from the server.
  /// :param: inboxCount The count of unread messages in the end user's inbox retrieved from the server.
  func getConversations(_ completionHandler: (conversations: [Conversation]?, inboxCount: Int?) -> ()) {
    DataManager.sharedInstance.getEndUserConversations { result in
      switch result {
      case .error(let error):
        self.handleError(error)
        completionHandler(conversations: nil, inboxCount: nil)
      case .value(let element):
        let (inboxCount, conversations) = element.unbox
        completionHandler(conversations: conversations, inboxCount: inboxCount)
      }
    }
  }
  
  /// Retrieves the notifications for the end user.
  ///
  /// TabViewController must retrieve notifications in order to display badge.
  ///
  /// :param: completionHandler The completion block for the network request.
  /// :param: notifications The array of notifications retrieved from the server.
  func getNotifications(_ completionHandler: (notifications: [Notification]?) -> ()) {
    DataManager.sharedInstance.getEndUserNotifications { result in
      switch result {
      case .error(let error):
        self.handleError(error)
        completionHandler(notifications: nil)
      case .value(let notifications):
        completionHandler(notifications: notifications.unbox)
      }
    }
  }
  
  /// Used to retrieve end User from Cillo servers.
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: user The end user.
  /// :param: * Nil if there was an error in the server call.
  func retrieveEndUser(_ completionHandler: (user: User?) -> ()) {
    DataManager.sharedInstance.getEndUserInfo { result in
      switch result {
      case .error(let error):
        self.handleError(error)
        completionHandler(user: nil)
      case .value(let user):
        completionHandler(user: user.unbox)
      }
    }
  }
  
  /// Handles an error received from a network call within the app.
  ///
  /// :param: error The error to be handled
  func handleError(_ error: NSError) {
    println(error)
    switch error.cilloErrorCode() {
    case .userUnauthenticated:
      handleUserUnauthenticatedError(error)
    case .notCilloDomain:
      break
    default:
      error.showAlert()
    }
  }
  
  // MARK: Error Handling Helper Functions
  
  /// Handles a cillo error with code `NSError.CilloErrorCodes.userUnauthenticated`.
  ///
  /// :param: error The error to be handled.
  func handleUserUnauthenticatedError(_ error: NSError) {
    performSegue(withIdentifier: SegueIdentifiers.tabToLogin, sender: error)
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
  @IBAction func unwindToTab(_ sender: UIStoryboardSegue) {
  }
}
