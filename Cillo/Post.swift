//
//  Post.swift
//  Cillo
//
//  Created by Andrew Daley on 10/23/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

/// Defines all properties of a Post on Cillo.
class Post: NSObject {
  
  // MARK: Properties
  
  /// ID of this Post
  let postID: Int = 0
  
  /// User that posted this Post.
  var user: User = User()
  
  /// Group that this Post was posted in.
  var group: Group = Group()
  
  /// Content of this Post.
  let text: String = ""
  
  /// Title of this Post.
  ///
  /// Nil if this Post has no title.
  let title: String?
  
  /// Time since this Post was posted.
  ///
  /// String is properly formatted via NSDate.convertToTimeString(time:).
  let time: String = ""
  
  /// Number of Comments relating to this Post.
  var numComments: Int = 0
  
  /// Reputation of this Post.
  ///
  /// Formula: Upvotes - Downvotes
  var rep: Int = 0
  
  /// Expansion status of Post.
  /// 
  /// * True - Post is fully expanded. All text is shown.
  /// * False - Post is contracted. Only text that fits in MaxContractedHeight of UITableViewController is shown.
  /// * Nil - Post is unexpandable.
  var seeFull : Bool?
  
  // MARK: Initializers
  
  /// Creates Post based on a swiftyJSON retrieved from a call to the Cillo servers.
  ///
  /// Should contain key value pairs for:
  /// * "post_id" - Int
  /// * "repost" - Bool
  /// * "content" - String
  /// * "group" - Dictionary
  /// * "user" - Dictionary
  /// * "time" - Int64
  /// * "votes" - Int
  /// * "comment_count" - Int
  ///
  /// :param: json The swiftyJSON retrieved from a call to the Cillo servers.
  init(json: JSON) {
    postID = json["post_id"].intValue
    text = json["content"].stringValue
    group = Group(json: json["group"])
    user = User(json: json["user"])
    let time = json["time"].int64Value
    self.time = NSDate.convertToTimeString(time: time)
    rep = json["votes"].intValue
    numComments = json["comment_count"].intValue
  }
  
  // Creates empty Post.
  override init() {
    super.init()
  }
  
  // MARK: Helper Functions
  
  /// Used to find the height of postTextView in a PostCell displaying this Post.
  ///
  /// :param: width The current width of postTextView.
  /// :param: maxHeight The maximum height of the postTextView before it is expanded.
  /// :param: * Nil if post is unexpandable (seeFull is nil).
  ///  * Usually set to MaxContracted height constant of UITableViewController.
  /// :returns: Predicted height of postTextView in a PostCell.
  func heightOfPostWithWidth(width: CGFloat, andMaxContractedHeight maxHeight: CGFloat?) -> CGFloat {
    let height = text.heightOfTextWithWidth(width, andFont: PostCell.PostTextViewFont)
    if let maxHeight = maxHeight {
      // seeFull should not be nil if post needs expansion option
      if seeFull == nil && height > maxHeight {
        seeFull = false
      }
      
      if seeFull == nil || seeFull! {
        return height
      } else {
        return maxHeight
      }
    } else {
      return height
    }
  }
  
}
