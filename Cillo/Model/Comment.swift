//
//  Comment.swift
//  Cillo
//
//  Created by Andrew Daley on 11/3/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

/// Defines all properties of a Comment on Cillo.
class Comment: NSObject {
  
  // MARK: Properties
  
  /// Comments that replied to this Comment.
  ///
  /// Nil if this Comment does not have any children or the children are unknown.
  var children: [Comment]?
  
  /// ID of this Comment.
  var commentID = 0
  
  /// Level of this Comment in Comment tree.
  ///
  /// Note: A direct reply to a Post has a lengthToPost of 1.
  var lengthToPost: Int?
  
  /// True if this Comment's user is the same as the user of the main Post.
  var isOP: Bool {
    return post.user.userID == user.userID
  }
  
  /// Post that this Comment replied to.
  var post = Post()
  
  /// Reputation of this Comment.
  ///
  /// Formula: Upvotes - Downvotes
  var rep = 0
  
  /// Content of this Comment.
  var text = ""
  
  /// Time since this Comment was posted.
  ///
  /// String is properly formatted via NSDate.convertToTimeString(time:).
  var time = ""
  
  /// User that posted this Comment.
  var user = User()
  
  /// The voting status of the end user on this Comment.
  ///
  /// * -1: This Comment has been downvoted by the User.
  /// * 0: This Comment has not been upvoted or downvoted by the User.
  /// * 1: This Comment has been upvoted by the User.
  var voteValue = 0

  // MARK: Constants
  
  /// Longest possible lengthToPost before indent is constant in CommentCell.
  class var longestLengthToPost: Int {
    return 5
  }
  
  // MARK: Initializers
  
  /// Creates Comment based on a swiftyJSON retrieved from a call to the Cillo servers.
  ///
  /// Should contain key value pairs for:
  /// * "comment_id" - Int
  /// * "post" - Dictionary
  /// * "user" - Dictionary
  /// * "content" - String
  /// * "time" - Int64
  /// * "votes" - Int
  /// * "children" - Array?
  /// * "vote_value" - Int
  ///
  /// :param: json The swiftyJSON retrieved from a call to the Cillo servers.
  /// :param: lengthToPost The level of this Comment in a Comment tree.
  /// 
  /// Nil if not building a Comment tree with this Comment.
  init(json: JSON, lengthToPost: Int?) {
    commentID = json["comment_id"].intValue
    post = Post(json: json["post"])
    user = User(json: json["user"])
    text = json["content"].stringValue
    let time = json["time"].int64Value
    self.time = time.compactTimeDisplay
    rep = json["votes"].intValue
    voteValue = json["vote_value"].intValue
    self.lengthToPost = lengthToPost
    if lengthToPost != nil && json["children"] != nil {
      let children = json["children"].arrayValue
      self.children = []
      for child in children {
        let item = Comment(json: child, lengthToPost: self.lengthToPost! + 1)
        self.children!.append(item)
      }
    }
  }
  
  /// Creates empty Comment.
  override init() {
    super.init()
  }
  
  // MARK: Setup Helper Functions
  
  /// Used to find the height of commentTextView in a CommentCell displaying this Comment.
  ///
  /// :param: width The current width of commentTextView.
  /// :param: selected Describes if CommentCell is selected.
  /// :returns: Predicted height of commentTextView in a CommentCell.
  func heightOfCommentWithWidth(width: CGFloat, selected: Bool) -> CGFloat {
    let trueWidth = width - CommentCell.commentTTTAttributedLabelDistanceToIndent - predictedIndentSize(selected: selected)
    return text.heightOfTextWithWidth(trueWidth, andFont: CommentCell.commentTTTAttributedLabelFont)
  }
  
  /// Used to retrieve a Comment tree containing this Comment and all of its children.
  ///
  /// :returns: An array of Comments representing a Comment tree in preorder format.
  func makeCommentTree() -> [Comment] {
    var tree: [Comment] = [self]
    if let children = self.children {
      for child in children {
        tree += child.makeCommentTree()
      }
    }
    return tree
  }
  
  /// Used to find the indentLevel property for a CommentCell displaying this Comment.
  ///
  /// **Warning:** Don't call this method if lengthToPost is nil
  ///
  /// :param: selected Describes if CommentCell is selected.
  /// :returns: A valid indentLevel for a CommentCell displaying this Comment.
  func predictedIndentLevel(#selected: Bool) -> Int {
    if let lengthToPost = self.lengthToPost {
      if selected {
        return 0
      } else {
        return lengthToPost > Comment.longestLengthToPost ? Comment.longestLengthToPost - 1 : lengthToPost - 1
      }
    }
    return 0
  }
  
  /// Used to find the indent size for a CommentCell displaying this Comment.
  ///
  /// :param: selected Describes if CommentCell is selected.
  /// :returns: A valid indentSize in pixels for a CommentCell displaying this Comment.
  func predictedIndentSize(#selected: Bool) -> CGFloat {
    return CGFloat(predictedIndentLevel(selected: selected)) * CommentCell.indentSize
  }
  
  // MARK: Mutating Helper Functions
  
  /// Updates the comment model to be downvoted.
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
  
  /// Updates the comment model to be upvoted.
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
