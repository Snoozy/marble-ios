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
  
  /// ID of this Post.
  var postID: Int = 0
  
  /// User that posted this Post.
  var user: User = User()
  
  /// Group that this Post was posted in.
  var group: Group = Group()
  
  /// Content of this Post.
  var text: String = ""
  
  /// Title of this Post.
  ///
  /// Nil if this Post has no title.
  var title: String?
  
  /// Time since this Post was posted.
  ///
  /// String is properly formatted via NSDate.convertToTimeString(time:).
  var time: String = ""
  
  /// Number of Comments relating to this Post.
  var numComments: Int = 0
  
  /// Reputation of this Post.
  ///
  /// Formula: Upvotes - Downvotes
  var rep: Int = 0
  
  /// The voting status of the logged in User on this Post.
  ///
  /// * -1: This Post has been downvoted by the User.
  /// * 0: This Post has not been upvoted or downvoted by the User.
  /// * 1: This Post has been upvoted by the User.
  var voteValue: Int = 0
  
  /// Expansion status of Post.
  /// 
  /// * True - Post is fully expanded. All text is shown.
  /// * False - Post is contracted. Only text that fits in MaxContractedHeight of UITableViewController is shown.
  /// * Nil - Post is expanded by default.
  var seeFull: Bool?
  
  // TODO: Document
  var imageURLs: [NSURL]?
  
  var showImages: Bool = false
  
  /// Used to print properties in println statements.
  override var description: String {
    let none = "N/A"
    let imgstr = "HASANIMAGE"
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
    return "Post {\n  Post ID: \(postID)\n  Title: \(title != nil ? title! : none)\n  Text: \(text)\n  User: \(user)\n  Group: \(group)\n  Time: \(time)\n  Number of Comments: \(numComments)\n  Reputation: \(rep)\n  Vote Value: \(vote)\n  Expansion Status: \(expanded)\n  Image: \(imageURLs != nil ? imgstr : none)\n}\n"
  }
  
  // MARK: Initializers
  
  /// Creates Post based on a swiftyJSON retrieved from a call to the Cillo servers.
  ///
  /// Should contain key value pairs for:
  /// * "post_id" - Int
  /// * "content" - String
  /// * "board" - Dictionary
  /// * "user" - Dictionary
  /// * "time" - Int64
  /// * "title" - String?
  /// * "votes" - Int
  /// * "comment_count" - Int
  /// * "vote_value" - Int
  /// * "media_url" - String
  ///
  /// :param: json The swiftyJSON retrieved from a call to the Cillo servers.
  init(json: JSON) {
    postID = json["post_id"].intValue
    text = json["content"].stringValue
    group = Group(json: json["board"])
    user = User(json: json["user"])
    let time = json["time"].int64Value
    self.time = NSDate.convertToTimeString(time: time)
    if json["title"] != nil {
      self.title = json["title"].stringValue
    }
    rep = json["votes"].intValue
    numComments = json["comment_count"].intValue
    voteValue = json["vote_value"].intValue
    if json["media"] != nil {
      imageURLs = []
      for media in json["media"].arrayValue {
        if let url = NSURL(string: media.stringValue) {
          imageURLs!.append(url)
        }
      }
    }
  }
  
  /// Creates empty Post.
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
  
  func heightOfImagesInPostWithWidth(width: CGFloat, andButtonHeight height: CGFloat) -> CGFloat {
    if imageURLs != nil {
      if showImages {
        var h: CGFloat = 0.0
        for imageURL in imageURLs! {
          let button = UIButton()
          button.setBackgroundImageForState(.Normal, withURL: imageURL, placeholderImage: UIImage(named: "Me"))
          let image = button.backgroundImageForState(.Normal)
          if image != nil && image != UIImage(named: "Me") {
            h += width * image!.size.height / image!.size.width
          } else {
            h += height
          }
          break // TODO: Find way to make multiple images
        }
        return h
      } else {
        return height
      }
    } else {
      return 0
    }
  }
  
  // TODO: Document
  func isImagePost() -> Bool {
    return imageURLs != nil
  }
  
}
