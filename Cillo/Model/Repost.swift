//
//  Repost.swift
//  Cillo
//
//  Created by Andrew Daley on 1/1/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Defines all properties of a Repost on Cillo.
class Repost: Post {
  
  /// User that originally posted this Post.
  let originalUser: User = User()
  
  /// Group name of Group that this Post was originally posted to.
  let originalGroup: Group = Group()
  
  /// ID of the original post that this post if a repost of.
  let originalPostID: Int = 0
  
  /// Used to print properties in println statements.
  override var description: String {
    let none = "N/A"
    var vote = "Has not voted"
    if voteValue == 1 {
      vote = "Upvoted"
    } else if voteValue == -1 {
      vote = "Downvoted"
    }
    var expanded = "Expanded by Default"
    if seeFull != nil && seeFull! {
      expanded = "Expanded"
    } else if seeFull != nil && !seeFull! {
      expanded = "Not Expanded Yet"
    }
    return "Repost {\n  Post ID: \(postID)\n  Title: \(title != nil ? title : none)\n  Text: \(text)\n  User: \(user)\n  Group: \(group)\n  Original User: \(originalUser)\n  Original Group: \(originalGroup)\n  Time: \(time)\n  Number of Comments: \(numComments)\n  Reputation: \(rep)\n  Vote Value: \(vote)\n  Expansion Status: \(expanded)\n}\n"
  }
  
  /// Creates Repost based on a swiftyJSON retrieved from a call to the Cillo servers.
  ///
  /// **Warning:** json must have "repost" key as true.
  ///
  /// Should contain key value pairs for:
  /// * "post_id" - Int
  /// * "repost" - Bool
  /// * "repost_user" - Dictionary
  /// * "repost_group" - Dictionary
  /// * "repost_id" - Int
  /// * "content" - String
  /// * "group" - Dictionary
  /// * "user" - Dictionary
  /// * "time" - Int64
  /// * "title" - String?
  /// * "rep" - Int
  /// * "comment_count" - Int
  /// * "vote_value" - Int
  ///
  /// :param: json The swiftyJSON retrieved from a call to the Cillo servers.
  override init(json: JSON) {
    super.init(json: json)
    originalUser = User(json: json["user"])
    user = User(json: json["repost_user"])
    originalGroup = Group(json: json["group"])
    group = Group(json: json["repost_group"])
    originalPostID = json["repost_id"].intValue
  }
  
  /// Create empty Repost.
  override init() {
    super.init()
  }
  
}
