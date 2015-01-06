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
  
  /// Creates Repost based on a swiftyJSON retrieved from a call to the Cillo servers.
  ///
  /// **Warning:** json must have "repost" key as true.
  ///
  /// Should contain key value pairs for:
  /// * "post_id" - Int
  /// * "repost" - Bool
  /// * "repost_user" - Dictionary
  /// * "repost_group" - Dictionary
  /// * "content" - String
  /// * "group" - Dictionary
  /// * "user" - Dictionary
  /// * "time" - Int64
  /// * "rep" - Int
  /// * "comment_count" - Int
  ///
  /// :param: json The swiftyJSON retrieved from a call to the Cillo servers.
  override init(json: JSON) {
    super.init(json: json)
    originalUser = User(json: json["user"])
    user = User(json: json["repost_user"])
    originalGroup = Group(json: json["group"])
    group = Group(json: json["repost_group"])
  }
  
  // Create empty Repost.
  override init() {
    super.init()
  }
  
}
