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
  
  /// Board that this Post was posted in.
  var board = Board()
  
  /// Number of Comments relating to this Post.
  var commentCount: Int = 0
  
  /// All of the URLs for the images that this post is displaying.
  var imageURLs: [NSURL]?
 
  /// True if the post is an image post.
  var isImagePost: Bool {
    return imageURLs != nil
  }
  
  /// Stores image after it is loaded asynchronously
  var loadedImage: UIImage?
  
  /// ID of this Post.
  var postID = 0
  
  /// Reputation of this Post.
  ///
  /// Formula: Upvotes - Downvotes
  var rep: Int = 0
  
  /// Expansion status of Post.
  ///
  /// * True - Post is fully expanded. All text is shown.
  /// * False - Post is contracted. Only text that fits in MaxContractedHeight of UITableViewController is shown.
  /// * Nil - Post is expanded by default.
  var seeFull: Bool?
  
  /// Content of this Post.
  var text: String = ""
  
  /// Time since this Post was posted.
  ///
  /// String is properly formatted via `compactTimeDisplay` property of UInt64.
  var time: String = ""
  
  /// Title of this Post.
  ///
  /// Nil if this Post has no title.
  var title: String?
  
  /// User that posted this Post.
  var user = User()
  
  /// The voting status of the end user on this Post.
  ///
  /// * -1: This Post has been downvoted by the User.
  /// * 0: This Post has not been upvoted or downvoted by the User.
  /// * 1: This Post has been upvoted by the User.
  var voteValue: Int = 0
  
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
    println(json["time"].int64Value)
    println(NSDate().timeIntervalSince1970)
    postID = json["post_id"].intValue
    text = json["content"].stringValue
    board = Board(json: json["board"])
    user = User(json: json["user"])
    let time = json["time"].int64Value
    self.time = time.compactTimeDisplay
    if json["title"] != nil {
      self.title = json["title"].stringValue
    }
    rep = json["votes"].intValue
    commentCount = json["comment_count"].intValue
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
  
  // MARK: Setup Helper Functions
  
  /// Calculates the height of the images corresponding to the imagesURL array.
  ///
  /// :param: width The width of the screen
  /// :returns: The height of the button that will be displaying the images for this post.
  func heightOfImagesInPostWithWidth(width: CGFloat) -> CGFloat {
    if let loadedImage = loadedImage {
      var h: CGFloat = width * loadedImage.size.height / loadedImage.size.width
      return h
    } else if isImagePost {
      return 20
    } else {
      return 0
    }
  }
  
  /// Used to find the height of postTextView in a PostCell displaying this Post.
  ///
  /// :param: width The current width of postTextView.
  /// :param: maxHeight The maximum height of the postTextView before it is expanded.
  /// :param: * Nil if post is unexpandable (seeFull is nil).
  ///  * Usually set to MaxContracted height constant of UITableViewController.
  /// :returns: Predicted height of postTextView in a PostCell.
  func heightOfPostWithWidth(width: CGFloat, andMaxContractedHeight maxHeight: CGFloat?, andFont font: UIFont) -> CGFloat {
    let height = text.heightOfTextWithWidth(width, andFont: font)
    if let maxHeight = maxHeight {
      // seeFull should not be nil if post needs expansion option
      if seeFull == nil && height > maxHeight {
        seeFull = false
      }
      
      if let seeFull = seeFull where !seeFull {
        return maxHeight
      } else {
        return height
      }
    } else {
      return height
    }
  }

  // MARK: Mutating Helper Functions
  
  /// Updates the post model to be downvoted.
  func downvote() {
    switch voteValue {
    case 0:
      rep--
    case 1:
      rep -= 2
    default:
      break
    }
    voteValue = -1
  }
  
  /// Updates the post model to be upvoted
  func upvote() {
    switch voteValue {
    case 0:
      rep++
    case -1:
      rep += 2
    default:
      break
    }
    voteValue = 1
  }
}
