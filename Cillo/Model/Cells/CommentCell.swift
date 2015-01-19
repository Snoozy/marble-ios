//
//  CommentCell.swift
//  Cillo
//
//  Created by Andrew Daley on 11/3/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

// TODO: Handle Original Poster tag

/// Cell that corresponds to reuse identifier "Comment".
///
/// Used to format Comments in UITableView.
class CommentCell: UITableViewCell {
  
  // MARK: Properties
  
  /// An array that stores vertical lines for formating indents in a Comment tree.
  ///
  /// **Note:** This array should be empty if there is no indent for this CommentCell.
  var lines: [UIView] = []
  
  // MARK: IBOutlets
  
  /// Displays user.name property of Comment.
  @IBOutlet weak var nameButton: UIButton!
  
  /// Displays user.profilePic property of Comment.
  @IBOutlet weak var pictureButton: UIButton!
  
  /// Upvotes Post.
  @IBOutlet weak var upvoteButton: UIButton!
  
  /// Downvotes Post.
  @IBOutlet weak var downvoteButton: UIButton!
  
  /// Displays text property of Comment.
  @IBOutlet weak var commentTextView: UITextView!
  
  /// Displays rep and time of Comment
  @IBOutlet weak var repAndTimeLabel: UILabel!
  
  /// Set to 0 when cell is selected and ButtonHeight when selected.
  @IBOutlet weak var upvoteHeightConstraint: NSLayoutConstraint!
  
  /// Set to 0 when cell is selected and ButtonHeight when selected.
  @IBOutlet weak var downvoteHeightConstraint: NSLayoutConstraint!
  
  /// Set to .getIndentationSize().
  @IBOutlet weak var imageIndentConstraint: NSLayoutConstraint!
  
  /// Set to .getIndentationSize() + .TextViewDistanceToIndent.
  @IBOutlet weak var textIndentConstraint: NSLayoutConstraint!
  
  // MARK: Constants
  
  /// Font of the text contained within commentTextView.
  class var CommentTextViewFont: UIFont {
    get {
      return UIFont.systemFontOfSize(15.0)
    }
  }
  
  /// Height needed for all components of a CommentCell excluding commentTextView in the Storyboard.
  ///
  /// **Note:** Height of commentTextView must be calculated based on it's text property.
  class var AdditionalVertSpaceNeeded: CGFloat {
    get {
      return 89
    }
  }
  
  /// Height of buttons in expanded menu when CommentCell is selected.
  class var ButtonHeight: CGFloat {
    get {
      return 32
    }
  }
  
  /// Distance of commentTextView to right boundary of contentView.
  ///
  /// **Note:** Used to align commentTextView with nameLabel when cell is indented.
  class var TextViewDistanceToIndent: CGFloat {
    get {
      return 32
    }
  }
  
  /// Width of indent per indentationLevel of indented Comments.
  class var IndentSize: CGFloat {
    get {
      return 30
    }
  }
  
  /// Reuse Identifier for this UITableViewCell.
  class var ReuseIdentifier: String {
    get {
      return "Comment"
    }
  }
  
  // MARK: Helper Methods
  
  /// Used to find how many pixels a CommentCell should be indented based on its indentationLevel.
  ///
  /// :returns: True indent size for cell with current indentationLevel.
  func getIndentationSize() -> CGFloat {
    return CGFloat(indentationLevel) * CommentCell.IndentSize
  }
  
  /// Makes this CommentCell's IBOutlets display the correct values of the corresponding Comment.
  ///
  /// :param: comment The corresponding Comment to be displayed by this CommentCell.
  /// :param: selected Descibes if CommentCell is selected.
  /// :param: buttonTag The tags of all buttons in this PostCell corresponding to their index in the array holding them.
  /// :param: * Pass either indexPath.section or indexPath.row for this parameter depending on the implementation of your UITableViewController.
  func makeCellFromComment(comment: Comment, withSelected selected: Bool, andButtonTag buttonTag: Int) {
    
    var name = comment.user.name
    //add dots if CommentCell has reached max indent and cannot be indented more
    if let lengthToPost = comment.lengthToPost {
      if lengthToPost > Comment.LongestLengthToPost {
        let difference = lengthToPost - Comment.LongestLengthToPost
        for _ in 0..<difference {
          name = "· \(name)"
        }
      }
    }
    
    nameButton.setTitle(name, forState: .Normal)
    pictureButton.setBackgroundImage(comment.user.profilePic, forState: .Normal)
    nameButton.setTitle(name, forState: .Highlighted)
    pictureButton.setBackgroundImage(comment.user.profilePic, forState: .Highlighted)
    commentTextView.text = comment.text
    commentTextView.font = CommentCell.CommentTextViewFont
    commentTextView.textContainer.lineFragmentPadding = 0
    commentTextView.textContainerInset = UIEdgeInsetsZero
    var repText = String.formatNumberAsString(number: comment.rep)
    if comment.rep > 0 {
      repText = "+\(repText)"
    }
    if selected {
      //Show button bar when selected
      upvoteHeightConstraint.constant = CommentCell.ButtonHeight
      downvoteHeightConstraint.constant = CommentCell.ButtonHeight
      //Selected CommentCells show time next to rep
      repAndTimeLabel.text = "\(repText) · \(comment.time)"
      //Selected CommentCells need to clear vertical lines from the cell in order to expand cell
      for line in lines {
        line.removeFromSuperview()
      }
      lines.removeAll()
    } else {
      //hide button bar when not selected
      upvoteHeightConstraint.constant = 0.0
      downvoteHeightConstraint.constant = 0.0
      repAndTimeLabel.text = repText
    }
    
    nameButton.tag = buttonTag
    pictureButton.tag = buttonTag
    
    // TODO: Handle voteValues changing colors of images
    if comment.voteValue == 1 {
      
    } else if comment.voteValue == -1 {
      
    }
    
    //indents cell
    imageIndentConstraint.constant = getIndentationSize()
    textIndentConstraint.constant = getIndentationSize() + CommentCell.TextViewDistanceToIndent
    
    //gets rid of small gap in divider
    layoutMargins = UIEdgeInsetsZero
    preservesSuperviewLayoutMargins = false
    
    //adds the vertical lines to the cells
    for i in 1...indentationLevel {
      var line = UIView(frame: CGRect(x: CGFloat(i)*CommentCell.IndentSize, y: 0, width: 1, height: frame.size.height))
      line.backgroundColor = UIColor.defaultTableViewDividerColor()
      lines.append(line)
      contentView.addSubview(line)
    }
  }
  
}
