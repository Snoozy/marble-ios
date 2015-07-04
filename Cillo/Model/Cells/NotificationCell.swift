//
//  NotificationCell.swift
//  Cillo
//
//  Created by Andrew Daley on 6/15/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Cell that corresponds to reuse identifier "Notification".
///
/// Used to format Notifications in UITableViews.
class NotificationCell: UITableViewCell {
  
  // MARK: IBOutlets
  
  /// Displays `notification.notificationMessage`
  @IBOutlet weak var messageTTTAttributedLabel: TTTAttributedLabel!
  
  /// Displays `notification.titleUser.photoURL` asynchronously
  @IBOutlet weak var photoButton: UIButton!
  
  /// Displays the time since this notification occured.
  @IBOutlet weak var timeLabel: UILabel!
  
  /// Custom border between cells.
  ///
  /// This IBOutlet may not be assigned in the storyboard, meaning the UITableViewController managing this cell wants to use default UITableView separators.
  @IBOutlet weak var separatorView: UIView?
  
  // MARK: Constants
  
  /// Bold font of messageTTTAttributedLabel.
  class var boldMessageTTTAttributedLabelFont: UIFont {
    return UIFont.boldSystemFontOfSize(15.0)
  }
  
  /// Italic font of messageTTTAttributedLabel.
  class var italicMessageTTTAttributedLabelFont: UIFont {
    return UIFont.italicSystemFontOfSize(15.0)
  }
  
  /// Font of messageTTTAttributedLabel.
  class var messageTTTAttributedLabelFont: UIFont {
    return UIFont.systemFontOfSize(15.0)
  }
  
  /// Vertical space needed besides `separatorView`
  class var vertSpaceNeeded: CGFloat {
    return 70.0
  }
  
  // MARK: Setup Helper Functions
  
  /// Assigns all delegates of cell to the given parameter.
  ///
  /// :param: delegate The delegate that will be assigned to elements of the cell pertaining to the required protocols specified in the function header.
  func assignDelegatesForCellTo<T: UIViewController where T: TTTAttributedLabelDelegate>(delegate: T) {
    messageTTTAttributedLabel.delegate = delegate
  }
  
  /// Calculates the height of the cell given the properties of `notification`.
  ///
  /// :param: post The post that this cell is based on.
  /// :param: width The width of the cell in the tableView.
  /// :param: dividerHeight The height of the `separatorView` in the tableView.
  /// :returns: The height that the cell should be in the tableView.
  class func heightOfNotificationCellForNotification(notification: Notification, withElementWidth width: CGFloat, andDividerHeight dividerHeight: CGFloat) -> CGFloat {
    return NotificationCell.vertSpaceNeeded + dividerHeight
  }
  
  /// Makes this NotificationCell's IBOutlets display the correct values of the corresponding Notification.
  ///
  /// :param: notification The corresponding Notification to be displayed by this NotificationCell.
  /// :param: buttonTag The tags of all buttons in this NotificationCell corresponding to their index in the array holding them.
  /// :param: * Pass the precise index of the notification in its model array.
  func makeCellFromNotification(notification: Notification, withButtonTag buttonTag: Int) {
    let scheme = ColorScheme.defaultScheme
    
    photoButton.setBackgroundImageToImageWithURL(notification.titleUser.photoURL, forState: .Normal)
    
    photoButton.clipsToBounds = true
    photoButton.layer.cornerRadius = 5.0
    
    messageTTTAttributedLabel.setupWithAttributedText(notification.notificationMessage)

    timeLabel.text = "\(notification.time) ago"
    timeLabel.textColor = scheme.touchableTextColor()
    
    photoButton.tag = buttonTag

    separatorView?.backgroundColor = scheme.dividerBackgroundColor()
  }
}
