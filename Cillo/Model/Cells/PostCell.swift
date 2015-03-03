//
//  PostCell.swift
//  Cillo
//
//  Created by Andrew Daley on 10/23/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

/// Cell that corresponds to reuse identifier "Post".
///
/// Used to format Posts in UITableViews.
class PostCell: UITableViewCell {
  
  // MARK: Properties
  
  // TODO: Document
  var imageViews: [UIImageView] = []
  
  // MARK: IBOutlets
  
  /// Displays user.name property of Post.
  @IBOutlet weak var nameButton: UIButton!
  
  /// Displays user.profilePic property of Post.
  @IBOutlet weak var pictureButton: UIButton!
  
  /// Displays group.name property of Post.
  @IBOutlet weak var groupButton: UIButton!
  
  /// Displays text property of Post.
  @IBOutlet weak var postTextView: UITextView!
  
  /// Displays title property of Post.
  @IBOutlet weak var titleLabel: UILabel!
  
  /// Displays time property of Post.
  @IBOutlet weak var timeLabel: UILabel!
  
  /// Displays numComments property of Post.
  @IBOutlet weak var commentLabel: UILabel!
  
  /// Displays rep property of Post.
  @IBOutlet weak var repLabel: UILabel!
  
  /// Changes seeFull value of Post.
  /// 
  /// Posts with seeFull == nil do not have this UIButton.
  @IBOutlet weak var seeFullButton: UIButton?
  
  /// Upvotes Post.
  @IBOutlet weak var upvoteButton: UIButton!
  
  /// Downvotes Post.
  @IBOutlet weak var downvoteButton: UIButton!
  
  /// Centers view on Comments Section of PostTableViewController.
  @IBOutlet weak var commentButton: UIButton!
  
  /// Reposts Post in a different Group.
  @IBOutlet weak var repostButton: UIButton!
  
  /// Custom border between cells.
  ///
  /// This IBOutlet may not be assigned in the storyboard, meaning the UITableViewController managing this cell wants totuse default UITableView separators.
  @IBOutlet weak var separatorView: UIView?
  
  /// Controls height of titleLabel.
  ///
  /// If title of Post is nil, set constant to 0.
  @IBOutlet weak var titleHeightConstraint: NSLayoutConstraint!
  
  /// Controls height of separatorView.
  ///
  /// Set constant to value of separatorHeight in the makeCellFromPost(_:_:_:) function.
  @IBOutlet weak var separatorViewHeightConstraint: NSLayoutConstraint?
  
  // TODO: Document
  @IBOutlet weak var titleToTextViewSpacingConstraint: NSLayoutConstraint!

  // MARK: Constants
  
  /// Height needed for all components of a PostCell excluding postTextView in the Storyboard.
  ///
  /// **Note:** Height of postTextView must be calculated based on it's text property.
  class var AdditionalVertSpaceNeeded: CGFloat {
    get {
      return 139
    }
  }
  
  /// Height of titleLabel in Storyboard.
  class var TitleHeight: CGFloat {
    get {
      return 26.5
    }
  }
  
  // TODO: Document
  class var ImageMargins: CGFloat {
    get {
      return 3
    }
  }
  
  /// Font of the text contained within postTextView.
  class var PostTextViewFont: UIFont {
    get {
      return UIFont.systemFontOfSize(15.0)
    }
  }
  
  /// Reuse Identifier for this UITableViewCell.
  class var ReuseIdentifier: String {
    get {
      return "Post"
    }
  }
  
  // MARK: Helper Functions
  
  /// Makes this PostCell's IBOutlets display the correct values of the corresponding Post.
  ///
  /// :param: post The corresponding Post to be displayed by this PostCell.
  /// :param: buttonTag The tags of all buttons in this PostCell corresponding to their index in the array holding them.
  /// :param: * Pass the precise index of the post in its model array.
  /// :param: separatorHeight The height of the custom separators at the bottom of this PostCell.
  /// :param: * The default value is 0.0, meaning the separators will not show by default.
  func makeCellFromPost(post: Post, withButtonTag buttonTag: Int, andSeparatorHeight separatorHeight: CGFloat = 0.0) {
    nameButton.setTitle(post.user.name, forState: .Normal)
    groupButton.setTitle(post.group.name, forState: .Normal)
    pictureButton.setBackgroundImage(post.user.profilePic, forState: .Normal)
    nameButton.setTitle(post.user.name, forState: .Highlighted)
    groupButton.setTitle(post.group.name, forState: .Highlighted)
    pictureButton.setBackgroundImage(post.user.profilePic, forState: .Highlighted)
    timeLabel.text = post.time
    
    postTextView.text = post.text
    postTextView.font = PostCell.PostTextViewFont
    postTextView.textContainer.lineFragmentPadding = 0
    postTextView.textContainerInset = UIEdgeInsetsZero
    postTextView.editable = false
    
    if seeFullButton != nil {
      // tag acts as way for button to know it's position in data array
      seeFullButton!.tag = buttonTag
      
      seeFullButton!.setTitle("More", forState: .Normal)
      seeFullButton!.setTitle("More", forState: .Highlighted)
      
      // short posts and already expanded posts don't need to be expanded
      if post.seeFull == nil || post.seeFull! {
        seeFullButton!.hidden = true
      } else {
        seeFullButton!.hidden = false
      }
    }
    
    nameButton.tag = buttonTag
    groupButton.tag = buttonTag
    pictureButton.tag = buttonTag
    commentButton.tag = buttonTag
    upvoteButton.tag = buttonTag
    downvoteButton.tag = buttonTag
    repostButton.tag = buttonTag
    
    // TODO: Handle voteValues changing colors of images
    if post.voteValue == 1 {
  
    } else if post.voteValue == -1 {
      
    }
    
    commentLabel.text = String.formatNumberAsString(number: post.numComments)
    repLabel.text = String.formatNumberAsString(number: post.rep)
    
    if let title = post.title {
      titleLabel.text = title
      titleHeightConstraint.constant = PostCell.TitleHeight
    } else {
      titleLabel.text = ""
      titleHeightConstraint.constant = 0.0
    }
    
    if seeFullButton == nil {
      //gets rid of small gap in divider
      let dividerFix = UIView(frame: CGRect(x: 0, y: contentView.frame.size.height, width: 40, height: 1))
      dividerFix.backgroundColor = UIColor.defaultTableViewDividerColor()
      contentView.addSubview(dividerFix)
      preservesSuperviewLayoutMargins = false
      layoutMargins = UIEdgeInsetsZero
    }
    
    if let separatorView = separatorView {
      separatorView.backgroundColor = UIColor.cilloBlue()
      separatorViewHeightConstraint!.constant = separatorHeight
    }
  }
  
  // TODO: Document
  func addImage(image: UIImage) {
    let height = image.size.height
    let width = image.size.width
    let ratio = height/width
    let imageView: UIImageView = UIImageView(frame: CGRect(x: titleLabel.frame.minX, y: titleLabel.frame.maxY + PostCell.ImageMargins, width: titleLabel.frame.width, height: titleLabel.frame.width * ratio))
    imageView.contentMode = .ScaleAspectFit
    imageView.image = image
    titleToTextViewSpacingConstraint.constant += imageView.frame.height + PostCell.ImageMargins * 2
    contentView.addSubview(imageView)
    
  }
  
}
