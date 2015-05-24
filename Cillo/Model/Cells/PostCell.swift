//
//  PostCell.swift
//  Cillo
//
//  Created by Andrew Daley on 10/23/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit
import TTTAttributedLabel

/// Cell that corresponds to reuse identifier "Post".
///
/// Used to format Posts in UITableViews.
class PostCell: UITableViewCell {
  
  // MARK: IBOutlets
  
  /// Displays user.name property of Post.
  @IBOutlet weak var nameButton: UIButton!
  
  /// Displays user.profilePic property of Post.
  @IBOutlet weak var pictureButton: UIButton!
  
  /// Displays board.name property of Post.
  @IBOutlet weak var boardButton: UIButton!
  
  @IBOutlet weak var postTTTAttributedLabel: TTTAttributedLabel!
  
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
  
  /// Reposts Post in a different Board.
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
  
  @IBOutlet weak var imagesButton: UIButton!
  
  @IBOutlet weak var imagesButtonHeightConstraint: NSLayoutConstraint!

  // MARK: Constants
  
  /// Height needed for all components of a PostCell excluding postTTTAttributedLabel in the Storyboard.
  ///
  /// **Note:** Height of postTTTAttributedLabel must be calculated based on it's text property.
  class var additionalVertSpaceNeeded: CGFloat {
    return 140
  }
  
  /// Height of titleLabel in Storyboard.
  class var titleHeight: CGFloat {
    return 26
  }
  
  // TODO: Document
  class var imageMargins: CGFloat {
    return 3
  }
  
  /// Font of the text contained within postTTTAttributedLabel.
  class var postTTTAttributedLabelFont: UIFont {
    return UIFont.systemFontOfSize(15.0)
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
    let scheme = ColorScheme.defaultScheme
    
    let nameTitle = "\(post.user.name)"
    nameButton.setTitle(nameTitle, forState: .Normal)
    boardButton.setTitle(post.board.name, forState: .Normal)
    pictureButton.setBackgroundImageForState(.Normal, withURL: post.user.profilePicURL)
    nameButton.setTitle(nameTitle, forState: .Highlighted)
    boardButton.setTitle(post.board.name, forState: .Highlighted)
    pictureButton.setBackgroundImageForState(.Highlighted, withURL: post.user.profilePicURL)
    timeLabel.text = post.time
    
    postTTTAttributedLabel.numberOfLines = 0
    postTTTAttributedLabel.font = PostCell.postTTTAttributedLabelFont
    postTTTAttributedLabel.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
    postTTTAttributedLabel.linkAttributes = [kCTForegroundColorAttributeName : UIColor.cilloBlue()]
    postTTTAttributedLabel.text = post.text
    
    if post.user.isAnon {
      nameButton.setTitle(nameTitle, forState: .Disabled)
      pictureButton.setBackgroundImageForState(.Disabled, withURL: post.user.profilePicURL)
      nameButton.enabled = false
      pictureButton.enabled = false
    }
    
    nameButton.tag = buttonTag
    boardButton.tag = buttonTag
    pictureButton.tag = buttonTag
    commentButton.tag = buttonTag
    upvoteButton.tag = buttonTag
    downvoteButton.tag = buttonTag
    repostButton.tag = buttonTag
    imagesButton.tag = buttonTag
    
    if post.user.isSelf {
      nameButton.setTitleColor(scheme.meTextColor(), forState: .Normal)
      nameButton.setTitleColor(scheme.meTextColor(), forState: .Highlighted)
    } else {
      nameButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
      nameButton.setTitleColor(UIColor.blackColor(), forState: .Highlighted)
    }
    
    if post.voteValue == 1 {
      upvoteButton.setBackgroundImage(UIImage(named: "Selected Up Arrow"), forState: .Normal)
      upvoteButton.setBackgroundImage(UIImage(named: "Selected Up Arrow"), forState: .Highlighted)
      upvoteButton.setBackgroundImage(UIImage(named: "Selected Up Arrow"), forState: .Disabled)
      downvoteButton.setBackgroundImage(UIImage(named: "Down Arrow"), forState: .Normal)
      downvoteButton.setBackgroundImage(UIImage(named: "Down Arrow"), forState: .Highlighted)
      downvoteButton.setBackgroundImage(UIImage(named: "Down Arrow"), forState: .Disabled)
      repLabel.textColor = UIColor.upvoteGreen()
    } else if post.voteValue == -1 {
      upvoteButton.setBackgroundImage(UIImage(named: "Up Arrow"), forState: .Normal)
      upvoteButton.setBackgroundImage(UIImage(named: "Up Arrow"), forState: .Highlighted)
      upvoteButton.setBackgroundImage(UIImage(named: "Up Arrow"), forState: .Disabled)
      downvoteButton.setBackgroundImage(UIImage(named: "Selected Down Arrow"), forState: .Normal)
      downvoteButton.setBackgroundImage(UIImage(named: "Selected Down Arrow"), forState: .Highlighted)
      downvoteButton.setBackgroundImage(UIImage(named: "Selected Down Arrow"), forState: .Disabled)
      repLabel.textColor = UIColor.downvoteRed()
    } else {
      upvoteButton.setBackgroundImage(UIImage(named: "Up Arrow"), forState: .Normal)
      upvoteButton.setBackgroundImage(UIImage(named: "Up Arrow"), forState: .Highlighted)
      upvoteButton.setBackgroundImage(UIImage(named: "Up Arrow"), forState: .Disabled)
      downvoteButton.setBackgroundImage(UIImage(named: "Down Arrow"), forState: .Normal)
      downvoteButton.setBackgroundImage(UIImage(named: "Down Arrow"), forState: .Highlighted)
      downvoteButton.setBackgroundImage(UIImage(named: "Down Arrow"), forState: .Disabled)
      repLabel.textColor = UIColor.blackColor()
    }
    
    commentLabel.text = String.formatNumberAsString(number: post.commentCount)
    commentLabel.textColor = UIColor.whiteColor()
    contentView.bringSubviewToFront(commentLabel)
    repLabel.text = String.formatNumberAsString(number: post.rep)
    repLabel.font = UIFont.systemFontOfSize(24)
    
    if seeFullButton == nil {
      //gets rid of small gap in divider
      let dividerFix = UIView(frame: CGRect(x: 0, y: contentView.frame.size.height, width: 40, height: 1))
      dividerFix.backgroundColor = UIColor.defaultTableViewDividerColor()
      contentView.addSubview(dividerFix)
      layoutMargins = UIEdgeInsetsZero
    }
    
    separatorViewHeightConstraint?.constant = separatorHeight
    
    separatorView?.backgroundColor = scheme.dividerBackgroundColor()
    
    if !(post is Repost) {
      if let seeFullButton = seeFullButton {
        // tag acts as way for button to know it's position in data array
        seeFullButton.tag = buttonTag
        
        seeFullButton.setTitle("More", forState: .Normal)
        seeFullButton.setTitle("More", forState: .Highlighted)
        
        // short posts and already expanded posts don't need to be expanded
        if let seeFull = post.seeFull where !seeFull {
          seeFullButton.hidden = false
        } else {
          seeFullButton.hidden = true
        }
      }
      
      if let title = post.title {
        titleLabel.text = title
        titleHeightConstraint.constant = PostCell.titleHeight
      } else {
        titleLabel.text = ""
        titleHeightConstraint.constant = 0.0
      }
      
      imagesButtonHeightConstraint.constant = post.heightOfImagesInPostWithWidth(contentView.frame.size.width - 16, andButtonHeight: 20)
      if let imageURLs = post.imageURLs {
        imagesButton.setBackgroundImageForState(.Disabled, withURL: imageURLs[0], placeholderImage: UIImage(named: "Me"))
        imagesButton.setTitle("", forState: .Disabled)
        imagesButton.contentMode = .ScaleAspectFit
      }
      if imagesButtonHeightConstraint.constant == 20 {
        imagesButton.setTitle("Show Images", forState: .Normal)
        imagesButton.setTitle("Show Images", forState: .Highlighted)
        imagesButton.setTitleColor(scheme.touchableTextColor(), forState: .Normal)
        imagesButton.setTitleColor(scheme.touchableTextColor(), forState: .Highlighted)
        imagesButton.enabled = true
      } else if let imageURLs = post.imageURLs where post.showImages {
        imagesButton.enabled = false
      }
    }
  }
  
  func assignDelegatesForCellTo<T: UIViewController where T: TTTAttributedLabelDelegate>(delegate: T) {
    postTTTAttributedLabel.delegate = delegate
  }
  
  class func heightOfPostCellForPost(post: Post, withElementWidth width: CGFloat, maxContractedHeight maxHeight: CGFloat?, andDividerHeight dividerHeight: CGFloat) -> CGFloat {
    if let post = post as? Repost {
      return RepostCell.heightOfRepostCellForRepost(post, withElementWidth: width, maxContractedHeight: maxHeight, andDividerHeight: dividerHeight)
    }
    var height = post.heightOfPostWithWidth(width, andMaxContractedHeight: maxHeight, andFont: PostCell.postTTTAttributedLabelFont) + PostCell.additionalVertSpaceNeeded
    height += post.heightOfImagesInPostWithWidth(width, andButtonHeight: 20)
    height += dividerHeight
    return post.title != nil ? height : height - PostCell.titleHeight
  }
  
  override func prepareForReuse() {
    imagesButtonHeightConstraint.constant = 0
    separatorViewHeightConstraint?.constant = 0
    imagesButton.setTitle("", forState: .Normal)
    imagesButton.setTitle("", forState: .Highlighted)
    nameButton.enabled = true
    pictureButton.enabled = true
  }
  
}
