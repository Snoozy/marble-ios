//
//  Post.swift
//  Cillo
//
//  Created by Andrew Daley on 10/23/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

///Defines all properties of a Post on Cillo
class Post: NSObject {
  
  // MARK: - Properties
  
  /// ID of this Post
  let postID: Int = 0
  
  /// ID of the Group that this Post was posted in.
  let groupID: Int = 0
  
  /// Indicates whether this Post is a repost from another Group.
  ///
  /// * True - This Post is a repost.
  /// * False - This Post is not a repost
  let repost: Bool = false
  
  /// Accountname of User that reposted this Post.
  /// Nil if repost is false.
  let repostUser: String?
  
  /// Group that this Post was reposted to.
  /// Nil if repost is false.
  let repostGroup: String?
  
  /// Display name of User that posted this Post.
  let name: String = ""
  
  /// Username of user that posted this Post.
  let username: String = ""
  
  /// Profile picture of User that posted this Post.
  let picture: UIImage = UIImage(named: "Me")!
  
  /// Group that this Post was posted in.
  let group: String = ""
  
  /// Content of this Post.
  let text: String = ""
  
  /// Title of this Post.
  /// Nil if this Post has no title.
  let title: String?
  
  /// Time since this Post was posted.
  /// String is properly formatted via NSDate.convertToTimeString(time:).
  let time: String = ""
  
  /// Number of Comments relating to this Post.
  var numComments: Int = 0
  
  /// Reputation of this Post.
  /// Formula: Upvotes - Downvotes
  var rep: Int = 0
  
  /// Expansion status of Post.
  /// 
  /// * True - Post is fully expanded. All text is shown.
  /// * False - Post is contracted. Only text that fits in MaxContractedHeight of UITableViewController is shown.
  /// * Nil - Post is unexpandable.
  var seeFull : Bool?
  
  // MARK: - Initializers
  
  /// Creates Post based on a swiftyJSON retrieved from a call to the Cillo servers.
  ///
  /// Should contain key value pairs for:
  /// * "post_id" - Int
  /// * "repost" - Bool
  /// * "repost_user" - String (Only present if "repost" is true)
  /// * "repost_group" - String (Only present if "repost" is true)
  /// * "content" - String
  /// * "group_id" - Int
  /// * "group_name" - String
  /// * "user_name" - String
  /// * "user_username" - String
  /// * "user_photo" - String
  /// * "time" - Int64
  /// * "rep" - Int
  /// * "comment_count" - Int
  init(json: JSON) {
    self.postID = json["post_id"].intValue
    self.repost = json["repost"].boolValue
    if self.repost {
      self.repostUser = json["repost_user"].stringValue
      self.repostGroup = json["repost_group"].stringValue
    }
    self.text = json["content"].stringValue
    self.groupID = json["group_id"].intValue
    self.group = json["group_name"].stringValue
    self.name = json["user_name"].stringValue
    self.username = json["user_username"].stringValue
    if let imageData = NSData(contentsOfURL: NSURL(fileURLWithPath: json["user_photo"].stringValue)!) {
      if let image = UIImage(data: imageData) {
        picture = image
      } else {
        picture = UIImage(named: "Me")!
      }
    }
    let time = json["time"].int64Value
    self.time = NSDate.convertToTimeString(time: time)
    self.rep = json["votes"].intValue
    self.numComments = json["comment_count"].intValue
  }
  
  //Creates empty Post
  override init() {
    super.init()
  }
  
  // MARK: - Helper Functions
  
  /// Used to find the height of postTextView in a PostCell displaying this Post.
  ///
  /// :param: width The current width of postTextView.
  /// :param: maxHeight The maximum height of the postTextView before it is expanded.
  /// :param: * Nil if post is unexpandable (seeFull is nil).
  ///  * Usually set to MaxContracted height constant of UITableViewController.
  /// :returns: Predicted height of descripTextView in a GroupCell.
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
        return h
      }
    } else {
      return height
    }
  }
  
}
