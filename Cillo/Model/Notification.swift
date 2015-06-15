//
//  Notification.swift
//  Cillo
//
//  Created by Andrew Daley on 6/15/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Defines all properties of a Notification on Cillo.
class Notification: NSObject {
  
  // MARK: Enums
  
  /// Describes the potential actions that a Notificaiton can describe.
  ///
  /// * *Reply:* Notification is notifying about a reply.
  /// * *Vote:* Notification is notifying about a vote.
  enum ActionType {
    case Reply, Vote
    
    static func actionTypeForString(string: String) -> ActionType {
      switch string {
      case "reply":
        return .Reply
      case "vote":
        return .Vote
      default:
        return .Reply
      }
    }
  }
  
  /// Describes the potential entities that can send Notifications.
  ///
  /// * *Post:* Notification is sent by a Post.
  /// * *Comment:* Notification is sent by a Comment.
  enum EntityType {
    case Post, Comment
  }
  
  // MARK: Properties
  
  /// Action type that this Notification is sending.
  var actionType = ActionType.Reply
  
  /// Number of notifications in addition to the notification pertaining to `titleUser`.
  var count = 0
  
  /// ID of the `EntityType` that this Notification pertains to.
  var entityID = 0
  
  /// Entity type that this Notification is notifying about.
  var entityType = EntityType.Post
  
  /// ID of this notification.
  var notificationID = 0
  
  /// Boolean flag to tell if the end user has read this notification yet.
  var read = false
  
  /// Time that this Notification occured.
  ///
  /// String is properly formatted via `compactTimeDisplay` property of UInt64.
  var time: String = ""
  
  /// The displayed user for this Notification.
  var titleUser: User = User()
  
  // MARK: Initializers
  
  /// Creates Notification based on a swiftyJSON retrieved from a call to the Cillo servers.
  ///
  /// Should contain key value pairs for:
  /// * "notification_id" - Int
  /// * "count" - Int
  /// * "title_user" - Dictionary
  /// * "time" - Int64
  /// * "post_id" - Int?
  /// * "comment_id" - Int?
  /// * "read" - Bool
  /// * "action_type" - String
  ///
  /// :param: json The swiftyJSON retrieved from a call to the Cillo servers.
  init(json: JSON) {
    notificationID = json["notification_id"].intValue
    count = json["count"].intValue
    titleUser = User(json: json["title_user"])
    let time = json["time"].int64Value
    self.time = time.compactTimeDisplay
    if json["post_id"] != nil {
      entityType = .Post
      entityID = json["post_id"].intValue
    } else if json["comment_id"] != nil {
      entityType = .Comment
      entityID = json["comment_id"].intValue
    }
    read = json["read"].boolValue
    let actionType = json["action_type"].stringValue
    self.actionType = ActionType.actionTypeForString(actionType)
  }
  
  /// Creates empty Post.
  override init() {
    super.init()
  }
  
}
