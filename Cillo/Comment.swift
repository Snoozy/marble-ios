//
//  Comment.swift
//  Cillo
//
//  Created by Andrew Daley on 11/3/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

// TODO: Make this class fit the Cillo server's model.
// TODO: Document this code.

///Defines all properties of a Comment on Cillo
class Comment: NSObject {
  
  //MARK: - Properties
  
  ///Username that posted Comment
  let user : String = ""
  
  ///Profile picture of user
  let picture : UIImage = UIImage(named: "Me")!
  
  ///Content of Comment
  let text : String = ""
  
  ///Time since Comment was posted. Formatted as #h for # hours
  let time : String = ""
  
  ///Number of Comments that replied to this Comment
  var numComments : Int = 0
  
  ///(Upvotes - Downvotes) for Comment
  var rep : Int = 0
  
  ///Distance to parent Post through tree
  var lengthToPost : Int = 1
  
  ///Comments replying to this Comment
  var comments : [Comment] = []
  
  ///Post that Comment is replying to
  var post : Post = Post()
  
  
  //MARK: - Constants
  
  ///Longest possible lengthToPost before indent is constant in CommentCell
  class var LongestLengthToPost: Int {
    get {
      return 5
    }
  }
  
  
  //MARK: - Initializers
  
  ///Creates Comment based on input parameters
  init(user: String, picture: UIImage, text: String, time: String, numComments: Int, rep: Int, lengthToPost: Int, comments: [Comment]) {
    self.user = user
    self.picture = picture
    self.text = text
    self.time = time
    self.numComments = numComments
    self.rep = rep
    self.lengthToPost = lengthToPost
    self.comments = comments
  }
  
  ///Creates empty Comment
  override init() {
    super.init()
  }
  
  
  //MARK: - Helper Methods
  
  ///Predicted indentLevel property for CommentCell. Does not account for if CommentCell is selected
  func predictedIndentLevel() -> Int {
    if lengthToPost > Comment.LongestLengthToPost {
      return 4
    } else {
      return lengthToPost - 1
    }
  }
  
  ///Predicted indent size for an arbitrary CommentCell containing this Comment. Does not account for if CommentCell is selected.
  func predictedIndentSize() -> CGFloat {
    return CGFloat(predictedIndentLevel()) * CommentCell.IndentSize
  }
  
  ///Returns the predicted height of commentTextView in a CommentCell.
  ///@width - width of UITextView in container
  ///@selected - true if CommentCell is selected
  func heightOfCommentWithWidth(width: CGFloat, withSelected selected: Bool) -> CGFloat {
    let indent = CGFloat(lengthToPost - 1)
    var w = width - CommentCell.TextViewDistanceToIndent
    if !selected { w -= predictedIndentSize() }
    
    return text.heightOfTextWithWidth(w, andFont: CommentCell.CommentTextViewFont)
  }
  
}
