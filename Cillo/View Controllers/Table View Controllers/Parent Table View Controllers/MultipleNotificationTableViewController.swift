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
  
  /// The standard dividerHeight between PostCells in `tableView`.
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
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == segueIdentifierThisToPost {
      let destination = segue.destinationViewController as! PostTableViewController
      if let sender = sender as? Post {
        destination.post = sender
      }
    } else if segue.identifier == segueIdentifierThisToUser {
      let destination = segue.destinationViewController as! UserTableViewController
      if let sender = sender as? UIButton {
        destination.user = displayedNotifications[sender.tag].titleUser
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.separatorStyle = .None
  }
  
  // MARK: UITableViewDataSource
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    return dequeueAndSetupNotificationCellForIndexPath(indexPath)
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return displayedNotifications.count
  }
  
  // MARK: UITableViewDelegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    tableView.userInteractionEnabled = false
    getPostForNotification(displayedNotifications[indexPath.row]) { post in
      tableView.userInteractionEnabled = true
      if let post = post {
        self.performSegueWithIdentifier(self.segueIdentifierThisToPost, sender: post)
      }
    }
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return NotificationCell.heightOfNotificationCellForNotification(displayedNotifications[indexPath.row], withElementWidth: tableViewWidthWithMargins, andDividerHeight: notificationDividerHeight)
  }
  
  // MARK: Setup Helper Functions
  
  /// Makes a NotificationCell for the corresponding notification in `displayedNotifications` based on the passed indexPath..
  ///
  /// :param: indexPath The index path of the cell to be created in the table view.
  ///
  /// :returns: The created NotificationCell.
  func dequeueAndSetupNotificationCellForIndexPath(indexPath: NSIndexPath) -> NotificationCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.notificationCell, forIndexPath: indexPath) as! NotificationCell
    cell.makeCellFromNotification(displayedNotifications[indexPath.row], withButtonTag: indexPath.row)
    cell.assignDelegatesForCellTo(self)
    return cell
  }
  
  // MARK: Networking Helper Functions
  
  /// Used to retrieve post that a notification pertains to.
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: post The post that the notification pertains to.
  /// :param: * Nil if there was an error in the server call.
  func getPostForNotification(notification: Notification, completionHandler: (post: Post?) -> ()) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    DataManager.sharedInstance.getPostByID(notification.postID) { error, result in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      if let error = error {
        self.handleError(error)
        completionHandler(post: nil)
      } else {
        completionHandler(post: result)
      }
    }
  }
  
  // MARK: IBActions
  
  /// Triggers segue to UserTableViewController.
  ///
  /// :param: sender The button that is touched to send this function is a photoButton in a NotificationCell.
  @IBAction func triggerUserSegueOnButton(sender: UIButton) {
    performSegueWithIdentifier(segueIdentifierThisToUser, sender: sender)
  }
}