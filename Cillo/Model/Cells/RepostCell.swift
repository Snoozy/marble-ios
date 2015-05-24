//
//  RepostCell.swift
//  Cillo
//
//  Created by Andrew Daley on 12/25/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit
import TTTAttributedLabel

// TODO: Rephrase the "Reposted from Board" to better show that it takes the User to the original Post.

/// Cell that corresponds to reuse identifier "Repost".
///
/// Used to format Posts with (repost = true) in UITableViews.
class RepostCell: PostCell {
  
  // MARK: IBOutlets
  
  @IBOutlet weak var originalPictureButton: UIButton!
  
  @IBOutlet weak var originalNameButton: UIButton!
  
  @IBOutlet weak var originalBoardButton: UIButton!
  
  @IBOutlet weak var goToOriginalPostButton: UIButton!
  
  @IBOutlet weak var verticalLineView: UIView!
  
  @IBOutlet weak var postTTTAttributedLabelHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var originalPostTTTAttributedLabel: TTTAttributedLabel!
  
  
  
  // MARK: Constants
  
  // Height needed for all components of a RepostCell excluding postTextView in the Storyboard.
  //
  // **Note:** Height of postTextView must be calculated based on it's text property.
  override class var additionalVertSpaceNeeded: CGFloat {
    return 205
  }
  
  class var originalPostMargins: CGFloat {
    return 37
  }
  
  class var originalPostTitleHeight: CGFloat {
    return 23
  }
  
  class var originalPostTTTAttributedLabelFont: UIFont {
    return UIFont.systemFontOfSize(13.0)
  }
  
  class var tagModifier: Int {
    return 1000000
  }
  
  // MARK: Helper Functions
  
  /// Makes this RepostCell's IBOutlets display the correct values of the corresponding Repost.
  ///
  /// **Note:** The implementation of this PostCell subclass will display repostUser as nameLabel.text and repostBoard as boardLabel.text.
  ///
  /// :param: post The corresponding Post to be displayed by this RepostCell.
  /// :param: buttonTag The tags of all buttons in this RepostCell.
  /// :param: * Pass the precise index of the post in its model array.
  /// :param: separatorHeight The height of the custom separators at the bottom of this Post Cell.
  /// :param: * The default value is 0.0, meaning the separators will not show by default.
  override func makeCellFromPost(post: Post, withButtonTag buttonTag: Int, andSeparatorHeight separatorHeight: CGFloat = 0.0) {
    super.makeCellFromPost(post, withButtonTag: buttonTag, andSeparatorHeight: separatorHeight)
    
    let scheme = ColorScheme.defaultScheme
    
    if let post = post as? Repost {
      postTTTAttributedLabelHeightConstraint.constant = post.heightOfPostWithWidth(contentView.frame.size.width - 16, andMaxContractedHeight: nil, andFont: PostCell.postTTTAttributedLabelFont)
      
      let nameTitle = "\(post.originalPost.user.name)"
      originalNameButton.setTitle(nameTitle, forState: .Normal)
      originalBoardButton.setTitle(post.originalPost.board.name, forState: .Normal)
      originalPictureButton.setBackgroundImageForState(.Normal, withURL: post.originalPost.user.profilePicURL)
      originalNameButton.setTitle(nameTitle, forState: .Highlighted)
      originalBoardButton.setTitle(post.originalPost.board.name, forState: .Highlighted)
      originalPictureButton.setBackgroundImageForState(.Highlighted, withURL: post.originalPost.user.profilePicURL)
      
      originalPostTTTAttributedLabel.numberOfLines = 0
      originalPostTTTAttributedLabel.font = RepostCell.originalPostTTTAttributedLabelFont
      originalPostTTTAttributedLabel.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
      originalPostTTTAttributedLabel.linkAttributes = [kCTForegroundColorAttributeName : UIColor.cilloBlue()]
      originalPostTTTAttributedLabel.text = post.originalPost.text
      
      goToOriginalPostButton.tintColor = scheme.touchableTextColor()
      
      if post.originalPost.user.isAnon {
        originalNameButton.setTitle(nameTitle, forState: .Disabled)
        originalPictureButton.setBackgroundImageForState(.Disabled, withURL: post.user.profilePicURL)
        originalNameButton.enabled = false
        originalPictureButton.enabled = false
      }
      
      if seeFullButton != nil {
        seeFullButton!.tag = buttonTag
        if post.originalPost.seeFull == nil || post.originalPost.seeFull! {
          seeFullButton!.hidden = true
        } else {
          seeFullButton!.hidden = false
        }
      }
      
      originalNameButton.tag = buttonTag + RepostCell.tagModifier
      originalBoardButton.tag = buttonTag + RepostCell.tagModifier
      originalPictureButton.tag = buttonTag + RepostCell.tagModifier
      goToOriginalPostButton.tag = buttonTag + RepostCell.tagModifier
      
      if post.originalPost.user.isSelf {
        originalNameButton.setTitleColor(scheme.meTextColor(), forState: .Normal)
        originalNameButton.setTitleColor(scheme.meTextColor(), forState: .Highlighted)
      } else {
        originalNameButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        originalNameButton.setTitleColor(UIColor.blackColor(), forState: .Highlighted)
      }
      
      if let title = post.originalPost.title {
        titleLabel.text = title
        titleHeightConstraint.constant = RepostCell.titleHeight
      } else {
        titleLabel.text = ""
        titleHeightConstraint.constant = 0.0
      }
      
      imagesButtonHeightConstraint.constant = post.originalPost.heightOfImagesInPostWithWidth(contentView.frame.size.width - 16 - RepostCell.originalPostMargins, andButtonHeight: 20)
      if post.originalPost.imageURLs != nil {
        imagesButton.setBackgroundImageForState(.Disabled, withURL: post.originalPost.imageURLs![0], placeholderImage: UIImage(named: "Me"))
        imagesButton.setTitle("", forState: .Disabled)
        imagesButton.contentMode = .ScaleAspectFit
      }
      if imagesButtonHeightConstraint.constant == 20 {
        imagesButton.setTitle("Show Images", forState: .Normal)
        imagesButton.setTitle("Show Images", forState: .Highlighted)
        imagesButton.setTitleColor(scheme.touchableTextColor(), forState: .Normal)
        imagesButton.setTitleColor(scheme.touchableTextColor(), forState: .Highlighted)
        imagesButton.enabled = true
      } else if post.originalPost.imageURLs != nil && post.originalPost.showImages {
        imagesButton.enabled = false
      }
      
      verticalLineView.backgroundColor = scheme.thinLineBackgroundColor()
    }
  }
  
  override func assignDelegatesForCellTo<T: UIViewController where T: TTTAttributedLabelDelegate>(delegate: T) {
    super.assignDelegatesForCellTo(delegate)
    originalPostTTTAttributedLabel.delegate = delegate
  }
  
  class func heightOfRepostCellForRepost(post: Repost, withElementWidth width: CGFloat, maxContractedHeight maxHeight: CGFloat?, andDividerHeight dividerHeight: CGFloat) -> CGFloat {
    var height = post.heightOfPostWithWidth(width, andMaxContractedHeight: nil, andFont: PostCell.postTTTAttributedLabelFont) + RepostCell.additionalVertSpaceNeeded + post.originalPost.heightOfPostWithWidth(width - RepostCell.originalPostMargins, andMaxContractedHeight: maxHeight, andFont: RepostCell.originalPostTTTAttributedLabelFont)
    height += post.originalPost.heightOfImagesInPostWithWidth(width - RepostCell.originalPostMargins, andButtonHeight: 20)
    height += dividerHeight
    return post.originalPost.title != nil ? height : height - RepostCell.titleHeight
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    postTTTAttributedLabelHeightConstraint.constant = 20
    originalNameButton.enabled = true
    originalPictureButton.enabled = true
  }
}
