//
//  CommentCell.swift
//  Cillo
//
//  Created by Andrew Daley on 11/3/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit
import TTTAttributedLabel

// TODO: Handle Original Poster tag
// TODO: Implement a reply button.

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
  
  /// Upvotes Comment.
  @IBOutlet weak var upvoteButton: UIButton?
  
  /// Downvotes Comment.
  @IBOutlet weak var downvoteButton: UIButton?
  
  /// Replies to Comment.
  @IBOutlet weak var replyButton: UIButton?
  
  @IBOutlet weak var commentTTTAttributedLabel: TTTAttributedLabel!
  
  /// Displays rep and time of Comment
  @IBOutlet weak var repAndTimeLabel: UILabel!
  
  /// Set to 0 when cell is selected and ButtonHeight when selected.
  @IBOutlet weak var upvoteHeightConstraint: NSLayoutConstraint?
  
  /// Set to .getIndentationSize().
  @IBOutlet weak var imageIndentConstraint: NSLayoutConstraint!
  
  /// Custom border between cells.
  ///
  /// This IBOutlet may not be assigned in the storyboard, meaning the UITableViewController managing this cell wants totuse default UITableView separators.
  @IBOutlet weak var separatorView: UIView?
  
  /// Controls height of separatorView.
  ///
  /// Set constant to value of separatorHeight in the makeCellFromBoard(_:_:_:) function.
  @IBOutlet weak var separatorViewHeightConstraint: NSLayoutConstraint?
  
  // MARK: Constants
  
  /// Font of the text contained within commentTextView.
  class var commentTTTAttributedLabelFont: UIFont {
    return UIFont.systemFontOfSize(15.0)
  }
  
  /// Height needed for all components of a CommentCell excluding commentTextView in the Storyboard.
  ///
  /// **Note:** Height of commentTextView must be calculated based on it's text property.
  class var additionalVertSpaceNeeded: CGFloat {
    return 89
  }
  
  /// Height of buttons in expanded menu when CommentCell is selected.
  class var buttonHeight: CGFloat {
    return 32
  }
  
  /// Distance of commentTextView to right boundary of contentView.
  ///
  /// **Note:** Used to align commentTextView with nameLabel when cell is indented.
  class var commentTTTAttributedLabelDistanceToIndent: CGFloat {
    return 32
  }
  
  /// Width of indent per indentationLevel of indented Comments.
  class var indentSize: CGFloat {
    return 30
  }
  
  // MARK: Helper Methods
  
  /// Used to find how many pixels a CommentCell should be indented based on its indentationLevel.
  ///
  /// :returns: True indent size for cell with current indentationLevel.
  func getIndentationSize() -> CGFloat {
    return CGFloat(indentationLevel) * CommentCell.indentSize + 8
  }
  
  /// Makes this CommentCell's IBOutlets display the correct values of the corresponding Comment.
  ///
  /// :param: comment The corresponding Comment to be displayed by this CommentCell.
  /// :param: selected Descibes if CommentCell is selected.
  /// :param: buttonTag The tags of all buttons in this PostCell corresponding to their index in the array holding them.
  /// :param: * Pass the precise index of the comment in its model array.
  func makeCellFromComment(comment: Comment, withSelected selected: Bool, andButtonTag buttonTag: Int, andSeparatorHeight separatorHeight: CGFloat = 0.0) {
    let scheme = ColorScheme.defaultScheme
    
    var name = comment.user.name
    //add dots if CommentCell has reached max indent and cannot be indented more
    if let lengthToPost = comment.lengthToPost {
      if lengthToPost > Comment.longestLengthToPost {
        let difference = lengthToPost - Comment.longestLengthToPost
        for _ in 0..<difference {
          name = "· \(name)"
        }
      }
    }
    
    let nameTitle = "\(name)"
    nameButton.setTitle(nameTitle, forState: .Normal)
    pictureButton.setBackgroundImageForState(.Normal, withURL: comment.user.profilePicURL)
    
    if comment.user.isAnon {
      nameButton.setTitle(nameTitle, forState: .Disabled)
      pictureButton.setBackgroundImageForState(.Disabled, withURL: comment.user.profilePicURL)
      nameButton.enabled = false
      pictureButton.enabled = false
    }
    
    commentTTTAttributedLabel.numberOfLines = 0
    commentTTTAttributedLabel.font = CommentCell.commentTTTAttributedLabelFont
    commentTTTAttributedLabel.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
    commentTTTAttributedLabel.linkAttributes = [kCTForegroundColorAttributeName : UIColor.cilloBlue()]
    commentTTTAttributedLabel.text = comment.text
    
    var repText = String.formatNumberAsString(number: comment.rep)
    if comment.rep > 0 {
      repText = "+\(repText)"
    }
    if selected {
      //Show button bar when selected
      upvoteHeightConstraint?.constant = CommentCell.buttonHeight
      //Selected CommentCells show time next to rep
      repAndTimeLabel.text = "\(repText) · \(comment.time)"
      //Selected CommentCells need to clear vertical lines from the cell in order to expand cell
      for line in lines {
        line.removeFromSuperview()
      }
      lines.removeAll()
    } else {
      //hide button bar when not selected
      upvoteHeightConstraint?.constant = 0.0
      repAndTimeLabel.text = repText
    }
    
    nameButton.tag = buttonTag
    pictureButton.tag = buttonTag
    upvoteButton?.tag = buttonTag
    downvoteButton?.tag = buttonTag
    replyButton?.tag = buttonTag
    
    if comment.isOP {
      nameButton.setTitleColor(scheme.opTextColor(), forState: .Normal)
    } else if comment.user.isSelf {
      nameButton.setTitleColor(scheme.meTextColor(), forState: .Normal)
    } else {
      nameButton.setTitleColor(UIColor.darkTextColor(), forState: .Normal)
    }
    
    // TODO: Handle voteValues changing colors of images
    if comment.voteValue == 1 {
      upvoteButton?.setBackgroundImage(UIImage(named: "Selected Up Arrow"), forState: .Normal)
      downvoteButton?.setBackgroundImage(UIImage(named: "Down Arrow"), forState: .Normal)
      repAndTimeLabel.textColor = UIColor.upvoteGreen()
    } else if comment.voteValue == -1 {
      upvoteButton?.setBackgroundImage(UIImage(named: "Up Arrow"), forState: .Normal)
      downvoteButton?.setBackgroundImage(UIImage(named: "Selected Down Arrow"), forState: .Normal)
      repAndTimeLabel.textColor = UIColor.downvoteRed()
    } else {
      upvoteButton?.setBackgroundImage(UIImage(named: "Up Arrow"), forState: .Normal)
      downvoteButton?.setBackgroundImage(UIImage(named: "Down Arrow"), forState: .Normal)
    }
    
    //indents cell
    imageIndentConstraint.constant = getIndentationSize()
    
    //gets rid of small gap in divider
    layoutMargins = UIEdgeInsetsZero
    preservesSuperviewLayoutMargins = false
    
    //adds the vertical lines to the cells
    for i in 0...indentationLevel {
      var line = UIView(frame: CGRect(x: CGFloat(i)*CommentCell.indentSize, y: 0, width: 1, height: frame.size.height))
      line.backgroundColor = UIColor.defaultTableViewDividerColor()
      lines.append(line)
      contentView.addSubview(line)
    }
    
    if let separatorView = separatorView {
      separatorView.backgroundColor = scheme.dividerBackgroundColor()
      separatorViewHeightConstraint!.constant = separatorHeight
    }
    
    preservesSuperviewLayoutMargins = false
  }
  
  func assignDelegatesForCellTo<T: UIViewController where T: TTTAttributedLabelDelegate>(delegate: T) {
    commentTTTAttributedLabel.delegate = delegate
  }
  
  class func heightOfCommentCellForComment(comment: Comment, withElementWidth width: CGFloat, selectedState selected: Bool, andDividerHeight dividerHeight: CGFloat) -> CGFloat {
    let height = comment.heightOfCommentWithWidth(width, selected: selected) + CommentCell.additionalVertSpaceNeeded + dividerHeight
    return selected ? height : height - CommentCell.buttonHeight
  }
  
  override func prepareForReuse() {
    nameButton.enabled = true
    pictureButton.enabled = true
    upvoteHeightConstraint?.constant = 0.0
    imageIndentConstraint.constant = 0.0
    for line in lines {
      line.removeFromSuperview()
    }
  }
  
}

