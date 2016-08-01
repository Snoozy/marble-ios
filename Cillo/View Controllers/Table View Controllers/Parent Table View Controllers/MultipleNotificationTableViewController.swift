//
//  MultipleNotificationTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 6/15/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Inherit this class for any UITableViewController that is only a table of NotificationCells.
///
/// **Note:** Subclasses must override segueIdentifierThisToPost and segueIdentifierThisToUser.
class MultipleNotificationTableViewController: CustomTableViewController {

  // MARK: Properties
  
  /// Notifications to be displayed in the `tableView`
  var displayedNotifications = [Notification]()
  
  // MARK: Constants
  
  /// The height on screen of the cells containing only single labels
  var heightOfSingleLabelCells: CGFloat {
    return 40.0
  }
  
  /// The standard dividerHeight between NotificaitonCells in `tableView`.
  let notificationDividerHeight = DividerScheme.defaultScheme.multipleNotificationsDividerHeight()

  /// Segue Identifier in Storyboard for segue to PostTableViewController.
  ///
  /// **Note:** Subclasses must override this Constant.
  var segueIdentifierThisToPost: String {
    fatalError("Subclasses of MultipleNotificationTableViewController must override segue identifiers")
  }
  
  /// Segue Identifier in Storyboard for segue to UserTableViewController.
  ///
  /// **Note:** Subclasses must override this Constant.
  var segueIdentifierThisToUser: String {
    fatalError("Subclasses of MultipleNotificationTableViewController must override segue identifiers")
  }
  
  // MARK: UIViewController
  
  override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == segueIdentifierThisToPost {
      let destination = segue.destination as! PostTableViewController
      if let sender = sender as? Post {
        destination.post = sender
      }
    } else if segue.identifier == segueIdentifierThisToUser {
      let destination = segue.destination as! UserTableViewController
      if let sender = sender as? UIButton {
        destination.user = displayedNotifications[sender.tag].titleUser
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.separatorStyle = .none
  }
  
  // MARK: UITableViewDataSource
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if displayedNotifications.count != 0 {
      return dequeueAndSetupNotificationCellForIndexPath(indexPath)
    } else {
      return dequeueAndSetupNoNotificationsCellForIndexPath(indexPath)
    }
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return displayedNotifications.count != 0 ? displayedNotifications.count : 1
  }
  
  // MARK: UITableViewDelegate
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if displayedNotifications.count != 0 {
      tableView.isUserInteractionEnabled = false
      getPostForNotification(displayedNotifications[(indexPath as NSIndexPath).row]) { post in
        tableView.isUserInteractionEnabled = true
        if let post = post {
          self.performSegue(withIdentifier: self.segueIdentifierThisToPost, sender: post)
        }
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if displayedNotifications.count != 0 {
      return NotificationCell.heightOfNotificationCellForNotification(displayedNotifications[(indexPath as NSIndexPath).row], withElementWidth: tableViewWidthWithMargins, andDividerHeight: notificationDividerHeight)
    } else {
      return heightOfSingleLabelCells
    }
  }
  
  // MARK: Setup Helper Functions
  
  /// Makes a NotificationCell for the corresponding notification in `displayedNotifications` based on the passed indexPath..
  ///
  /// :param: indexPath The index path of the cell to be created in the table view.
  ///
  /// :returns: The created NotificationCell.
  func dequeueAndSetupNotificationCellForIndexPath(_ indexPath: IndexPath) -> NotificationCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardIdentifiers.notificationCell, for: indexPath) as! NotificationCell
    cell.makeCellFromNotification(displayedNotifications[(indexPath as NSIndexPath).row], withButtonTag: (indexPath as NSIndexPath).row)
    cell.assignDelegatesForCellTo(self)
    return cell
  }
  
  /// Makes a single label UITableViewCell that says "You have no notifications"
  ///
  /// :param: indexPath The index path of the cell to be created in the table view.
  ///
  /// :returns: The created NoNotificationsCell.
  func dequeueAndSetupNoNotificationsCellForIndexPath(_ indexPath: IndexPath) -> UITableViewCell {
     return tableView.dequeueReusableCell(withIdentifier: StoryboardIdentifiers.noNotificationsCell, for: indexPath) 
  }
  
  // MARK: Networking Helper Functions
  
  /// Used to retrieve post that a notification pertains to.
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: post The post that the notification pertains to.
  /// :param: * Nil if there was an error in the server call.
  func getPostForNotification(_ notification: Notification, completionHandler: (post: Post?) -> ()) {
    DataManager.sharedInstance.getPostByID(notification.postID) { result in
      self.handleSingleElementResponse(result, completionHandler: completionHandler)
    }
  }
  
  // MARK: IBActions
  
  /// Triggers segue to UserTableViewController.
  ///
  /// :param: sender The button that is touched to send this function is a photoButton in a NotificationCell.
  @IBAction func triggerUserSegueOnButton(_ sender: UIButton) {
    performSegue(withIdentifier: segueIdentifierThisToUser, sender: sender)
  }
}
