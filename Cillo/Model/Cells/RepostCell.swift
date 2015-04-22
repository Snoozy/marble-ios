//
//  RepostCell.swift
//  Cillo
//
//  Created by Andrew Daley on 12/25/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

// TODO: Rephrase the "Reposted from Group" to better show that it takes the User to the original Post.

/// Cell that corresponds to reuse identifier "Repost".
///
/// Used to format Posts with (repost = true) in UITableViews.
class RepostCell: PostCell {
  
  // MARK: IBOutlets
  
  @IBOutlet weak var originalPictureButton: UIButton!
  
  @IBOutlet weak var originalNameButton: UIButton!
  
  @IBOutlet weak var originalGroupButton: UIButton!
  
  @IBOutlet weak var originalPostTextView: UITextView!
  
  @IBOutlet weak var goToOriginalPostButton: UIButton!
  
  @IBOutlet weak var postTextViewHeightConstraint: NSLayoutConstraint!
  
  
  
  // MARK: Constants
  
  // Height needed for all components of a RepostCell excluding postTextView in the Storyboard.
  //
  // **Note:** Height of postTextView must be calculated based on it's text property.
  override class var AdditionalVertSpaceNeeded: CGFloat {
    get {
      return 200
    }
  }
  
  // Reuse Identifier for this UITableViewCell.
  override class var ReuseIdentifier: String {
    get {
      return "Repost"
    }
  }
  
  class var OriginalPostMargins: CGFloat {
    return 37
  }
  
  class var OriginalPostTitleHeight: CGFloat {
    return 23
  }
  
  class var OriginalPostTextViewFont: UIFont {
    return UIFont.systemFontOfSize(13.0)
  }
  
  // MARK: Helper Functions
  
  /// Makes this RepostCell's IBOutlets display the correct values of the corresponding Repost.
  ///
  /// **Note:** The implementation of this PostCell subclass will display repostUser as nameLabel.text and repostGroup as groupLabel.text.
  ///
  /// :param: post The corresponding Post to be displayed by this RepostCell.
  /// :param: buttonTag The tags of all buttons in this RepostCell.
  /// :param: * Pass the precise index of the post in its model array.
  /// :param: separatorHeight The height of the custom separators at the bottom of this Post Cell.
  /// :param: * The default value is 0.0, meaning the separators will not show by default.
  override func makeCellFromPost(post: Post, withButtonTag buttonTag: Int, andSeparatorHeight separatorHeight: CGFloat = 0.0) {
    super.makeCellFromPost(post, withButtonTag: buttonTag, andSeparatorHeight: separatorHeight)
    if let post = post as? Repost {
      
      postTextViewHeightConstraint.constant = post.heightOfPostWithWidth(contentView.frame.size.width - 16, andMaxContractedHeight: nil)
      
      let me = post.originalPost.user.isSelf ? " (me)" : ""
      let nameTitle = "\(post.originalPost.user.name)\(me)"
      originalNameButton.setTitle(nameTitle, forState: .Normal)
      originalGroupButton.setTitle(post.originalPost.group.name, forState: .Normal)
      originalPictureButton.setBackgroundImageForState(.Normal, withURL: post.originalPost.user.profilePicURL)
      originalNameButton.setTitle(nameTitle, forState: .Highlighted)
      originalGroupButton.setTitle(post.originalPost.group.name, forState: .Highlighted)
      originalPictureButton.setBackgroundImageForState(.Highlighted, withURL: post.originalPost.user.profilePicURL)
      
      originalPostTextView.text = post.originalPost.text
      originalPostTextView.font = RepostCell.OriginalPostTextViewFont
      originalPostTextView.textContainer.lineFragmentPadding = 0
      originalPostTextView.textContainerInset = UIEdgeInsetsZero
      originalPostTextView.editable = false
      
      goToOriginalPostButton.tintColor = UIColor.cilloBlue()
      
      if post.originalPost.user.isAnon {
        originalNameButton.setTitle(nameTitle, forState: .Disabled)
        originalPictureButton.setBackgroundImageForState(.Disabled, withURL: post.user.profilePicURL)
        originalNameButton.enabled = false
        originalPictureButton.enabled = false
      }
      
      if seeFullButton != nil {
        if post.originalPost.seeFull == nil || post.originalPost.seeFull! {
          seeFullButton!.hidden = true
        } else {
          seeFullButton!.hidden = false
        }
      }
      
      originalNameButton.tag = buttonTag * 1000000
      originalGroupButton.tag = buttonTag * 1000000
      originalPictureButton.tag = buttonTag * 1000000
      goToOriginalPostButton.tag = buttonTag
      
      if post.originalPost.user.isSelf {
        originalNameButton.setTitleColor(UIColor.cilloBlue(), forState: .Normal)
        originalNameButton.setTitleColor(UIColor.cilloBlue(), forState: .Highlighted)
      } else {
        originalNameButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        originalNameButton.setTitleColor(UIColor.blackColor(), forState: .Highlighted)
      }
      
      if let title = post.originalPost.title {
        titleLabel.text = title
        titleHeightConstraint.constant = RepostCell.TitleHeight
      } else {
        titleLabel.text = ""
        titleHeightConstraint.constant = 0.0
      }
      
      imagesButtonHeightConstraint.constant = post.originalPost.heightOfImagesInPostWithWidth(contentView.frame.size.width - 16 - RepostCell.OriginalPostMargins, andButtonHeight: 20)
      if post.originalPost.imageURLs != nil {
        imagesButton.setBackgroundImageForState(.Disabled, withURL: post.originalPost.imageURLs![0], placeholderImage: UIImage(named: "Me"))
        imagesButton.setTitle("", forState: .Disabled)
        imagesButton.contentMode = .ScaleAspectFit
      }
      if imagesButtonHeightConstraint.constant == 20 {
        imagesButton.setTitle("Show Images", forState: .Normal)
        imagesButton.setTitle("Show Images", forState: .Highlighted)
        imagesButton.setTitleColor(UIColor.cilloBlue(), forState: .Normal)
        imagesButton.setTitleColor(UIColor.cilloBlue(), forState: .Highlighted)
        imagesButton.enabled = true
      } else if post.originalPost.imageURLs != nil && post.originalPost.showImages {
        imagesButton.enabled = false
      }
      
    }
  }
  
  class func heightOfRepostCellForRepost(post: Repost, withElementWidth width: CGFloat, maxContractedHeight maxHeight: CGFloat?, andDividerHeight dividerHeight: CGFloat) -> CGFloat {
    var height = post.heightOfPostWithWidth(width, andMaxContractedHeight: nil) + RepostCell.AdditionalVertSpaceNeeded + post.originalPost.heightOfPostWithWidth(width - RepostCell.OriginalPostMargins, andMaxContractedHeight: maxHeight)
    height += post.originalPost.heightOfImagesInPostWithWidth(width - RepostCell.OriginalPostMargins, andButtonHeight: 20)
    height += dividerHeight
    return post.originalPost.title != nil ? height : height - RepostCell.TitleHeight
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    postTextViewHeightConstraint.constant = 20
    originalNameButton.enabled = true
    originalPictureButton.enabled = true
  }
}
