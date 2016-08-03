//
//  Notification.swift
//  Cillo
//
//  Created by Andrew Daley on 6/15/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Defines all properties of a Notification on Cillo.
class Notification: IdentifiableObject {
    
    // MARK: - Enums
    
    /// Describes the potential actions that a Notificaiton can describe.
    ///
    /// * *Reply:* Notification is notifying about a reply.
    /// * *Vote:* Notification is notifying about a vote.
    enum ActionType {
        case reply, vote
        
        static func actionTypeForString(_ string: String) -> ActionType {
            switch string {
            case "reply":
                return .reply
            case "vote":
                return .vote
            default:
                return .reply
            }
        }
    }
    
    /// Describes the potential entities that can send Notifications.
    ///
    /// * *Post:* Notification is sent by a Post.
    /// * *Comment:* Notification is sent by a Comment.
    enum EntityType {
        case post, comment
    }
    
    // MARK: - Properties
    
    /// Action type that this Notification is sending.
    var actionType = ActionType.reply
    
    /// ID for comment that this notification pertains to
    ///
    /// Only present when `entityType` is `.Comment`.
    var commentId: Int?
    
    /// Number of notifications in addition to the notification pertaining to `titleUser`.
    var count = 0
    
    /// Entity type that this Notification is notifying about.
    var entityType = EntityType.post
    
    /// Message encapsulating the properties of this Notification that will be displayed to the end user.
    var notificationMessage: NSAttributedString {
        let otherString: String = {
            if self.count == 0 {
                return ""
            } else if self.count == 1 {
                return "and 1 other "
            } else {
                return "and \(self.count) others "
            }
        }()
        let actionTypeString: String = {
            switch self.actionType {
            case .reply:
                return "replied to"
            case .vote:
                return "upvoted"
            }
        }()
        let entityTypeString: String = {
            switch self.entityType {
            case .post:
                return "post"
            case .comment:
                return "comment"
            }
        }()
        let boldTitleUserString = NSMutableAttributedString(string: titleUser.name, attributes: [NSFontAttributeName: NotificationCell.NotificationFonts.boldMessageAttributedLabelFont])
        let middleString = NSMutableAttributedString(string: " \(otherString)\(actionTypeString) your \(entityTypeString): ", attributes: [NSFontAttributeName: NotificationCell.NotificationFonts.messageAttributedLabelFont])
        let italicPreviewString = NSMutableAttributedString(string: preview, attributes: [NSFontAttributeName: NotificationCell.NotificationFonts.italicMessageAttributedLabelFont])
        boldTitleUserString.append(middleString)
        boldTitleUserString.append(italicPreviewString)
        return boldTitleUserString
    }
    
    /// Boolean flag to tell if the end user has read this notification yet.
    var read = false
    
    /// ID of the post that this Notification pertains to.
    var postId = 0
    
    /// Text preview of the entity that this Notification corresponds to.
    var preview = ""
    
    /// Time that this Notification occured.
    ///
    /// String is properly formatted via `compactTimeDisplay` property of UInt64.
    var time = ""
    
    /// The displayed user for this Notification.
    var titleUser = User()
    
    // MARK: - Initializers
    
    /// Creates Notification based on a swiftyJSON retrieved from a call to the Cillo servers.
    ///
    /// Should contain key value pairs for:
    /// * "notification_id" - Int
    /// * "count" - Int
    /// * "title_user" - Dictionary
    /// * "time" - Int64
    /// * "post_id" - Int
    /// * "comment_id" - Int?
    /// * "read" - Bool
    /// * "action_type" - String
    ///
    /// :param: json The swiftyJSON retrieved from a call to the Cillo servers.
    init(json: JSON) {
        id = json["notification_id"].intValue
        count = json["count"].intValue
        titleUser = User(json: json["title_user"])
        let time = json["time"].int64Value
        self.time = time.compactTimeDisplay
        if json["comment_id"] != nil {
            entityType = .comment
            commentId = json["comment_id"].intValue
        } else {
            entityType = .post
        }
        postId = json["post_id"].intValue
        read = json["read"].boolValue
        preview = json["preview"].stringValue
        let actionType = json["action_type"].stringValue
        self.actionType = ActionType.actionTypeForString(actionType)
    }
    
    /// Creates empty Post.
    override init() {
        super.init()
    }
}
