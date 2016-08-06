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
    
    // MARK: - IBOutlets
    
    /// Displays `notification.notificationMessage`
    @IBOutlet weak var messageAttributedLabel: TTTAttributedLabel!
    
    /// Displays `notification.titleUser.photoURL` asynchronously
    @IBOutlet weak var photoButton: UIButton!
    
    /// Displays the time since this notification occured.
    @IBOutlet weak var timeLabel: UILabel!
    
    // MARK: - Constants
    
    /// Bold font of the text contained within messageAttributedLabel.
    private let boldMessageAttributedLabelFont = UIFont.boldSystemFont(ofSize: 15.0)
    
    /// Italic font of the text contained within messageAttributedLabel.
    private let italicMessageAttributedLabelFont = UIFont.italicSystemFont(ofSize: 15.0)
    
    /// Font of the text contained within messageAttributedLabel.
    private let messageAttributedLabelFont = UIFont.systemFont(ofSize: 15.0)
    
    // MARK: - Setup Helper Functions
    
    /// Assigns all delegates of cell to the given parameter.
    ///
    /// :param: delegate The delegate that will be assigned to elements of the cell pertaining to the required protocols specified in the function header.
    func assignDelegatesForCellTo<T: UIViewController where T: TTTAttributedLabelDelegate>(_ delegate: T) {
        messageAttributedLabel.delegate = delegate
    }
    
    /// Makes this NotificationCell's IBOutlets display the correct values of the corresponding Notification.
    ///
    /// :param: notification The corresponding Notification to be displayed by this NotificationCell.
    func makeFrom(notification: Notification) {
        let scheme = ColorScheme.defaultScheme
        
        photoButton.setBackgroundImageToImageWithURL(notification.titleUser.photoURL, forState: UIControlState())
        photoButton.clipsToBounds = true
        photoButton.layer.cornerRadius = 5.0
        
        messageAttributedLabel.setupFor(attributedText: messageFor(notification: notification))
        
        timeLabel.text = "\(notification.time) ago"
        timeLabel.textColor = scheme.touchableTextColor()
    }
    
    private func messageFor(notification: Notification) -> AttributedString {
        let otherString: String = {
            if notification.count == 0 {
                return ""
            } else if notification.count == 1 {
                return "and 1 other "
            } else {
                return "and \(self.count) others "
            }
        }()
        let actionTypeString: String = {
            switch notification.actionType {
            case .reply:
                return "replied to"
            case .vote:
                return "upvoted"
            }
        }()
        let entityTypeString: String = {
            switch notification.entityType {
            case .post:
                return "post"
            case .comment:
                return "comment"
            }
        }()
        var boldTitleUserString = NSMutableAttributedString(string: notification.titleUser.name,
                                                            attributes: [NSFontAttributeName: boldMessageAttributedLabelFont])
        let middleString = NSMutableAttributedString(string: " \(otherString)\(actionTypeString) your \(entityTypeString): ",
                                                     attributes: [NSFontAttributeName: messageAttributedLabelFont])
        let italicPreviewString = NSMutableAttributedString(string: preview,
                                                            attributes: [NSFontAttributeName: italicMessageAttributedLabelFont])
        boldTitleUserString.append(middleString)
        boldTitleUserString.append(italicPreviewString)
        return boldTitleUserString
    }
}
