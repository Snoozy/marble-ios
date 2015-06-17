//
//  RepostCell.swift
//  Cillo
//
//  Created by Andrew Daley on 12/25/14.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit
import TTTAttributedLabel

/// Cell that corresponds to reuse identifier "Repost".
///
/// Used to format Posts with (`repost` == true) in UITableViews.
class RepostCell: PostCell {
  
  // MARK: IBOutlets
  
  /// Sends the user to the original post.
  @IBOutlet weak var goToOriginalPostButton: UIButton!
  
  /// Displays board.name for originalPost.
  @IBOutlet weak var originalBoardButton: UIButton!
  
  /// Displays user.name for orginalPost.
  @IBOutlet weak var originalNameButton: UIButton!
  
  /// Displays user.profilePic for originalPost.
  @IBOutlet weak var originalPhotoButton: UIButton!
  
  /// Displays text of originalPost.
  @IBOutlet weak var originalPostTTTAttributedLabel: TTTAttributedLabel!
  
  /// Controls height of postTTTAttributedlabel.
  ///
  /// Allows both postTTTAtttibutedLabel and originalPostTTTAttributedLabel to have dynamic heights based on their text size.
  @IBOutlet weak var postTTTAttributedLabelHeightConstraint: NSLayoutConstraint!
  
  /// Vertical line next to repost components that shows the post is the repost.
  @IBOutlet weak var verticalLineView: UIView!
  
  // MARK: Constants
  
  override class var additionalVertSpaceNeeded: CGFloat {
    return 205
  }
  
  /// Distance to originalPost related elements in the RepostCell.
  class var originalPostMargins: CGFloat {
    return 37
  }
  
  /// Height of the titleLabel in a RepostCell.
  class var originalPostTitleHeight: CGFloat {
    return 23
  }
  
  /// Font of originalPostTTTAttributedLabel.
  class var originalPostTTTAttributedLabelFont: UIFont {
    return UIFont.systemFontOfSize(13.0)
  }
  
  /// Tag modifier that is added to the tag of all buttons relating to the orginalPost in a RepostCell.
  ///
  /// Allows the ViewControllers to know what buttons are triggering segues in the applicaiton.
  class var tagModifier: Int {
    return 1000000
  }
  
  // MARK: UITableViewCell
  
  override func prepareForReuse() {
    super.prepareForReuse()
    postTTTAttributedLabelHeightConstraint.constant = 20
    originalNameButton.enabled = true
    originalPhotoButton.enabled = true
  }
  
  // MARK: PostCell
  
  override func assignDelegatesForCellTo<T: UIViewController where T: TTTAttributedLabelDelegate>(delegate: T) {
    super.assignDelegatesForCellTo(delegate)
    originalPostTTTAttributedLabel.delegate = delegate
  }
  
  // MARK: Setup Helper Functions

  /// Calculates the height of the cell given the properties of `post`.
  ///
  /// :param: post The post that this cell is based on.
  /// :param: width The width of the cell in the tableView.
  /// :param: maxHeight The maximum height of the cell when seeFull is false.
  /// :param: dividerHeight The height of the `separatorView` in the tableView.
  /// :returns: The height that the cell should be in the tableView.
  class func heightOfRepostCellForRepost(post: Repost, withElementWidth width: CGFloat, maxContractedHeight maxHeight: CGFloat?, andDividerHeight dividerHeight: CGFloat) -> CGFloat {
    var height = post.heightOfPostWithWidth(width, andMaxContractedHeight: nil, andFont: PostCell.postTTTAttributedLabelFont) + RepostCell.additionalVertSpaceNeeded + post.originalPost.heightOfPostWithWidth(width - RepostCell.originalPostMargins, andMaxContractedHeight: maxHeight, andFont: RepostCell.originalPostTTTAttributedLabelFont)
    height += post.originalPost.heightOfImagesInPostWithWidth(width - RepostCell.originalPostMargins)
    height += dividerHeight
    return post.originalPost.title != nil ? height : height - RepostCell.titleHeight
  }
  
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
      originalPhotoButton.setBackgroundImageForState(.Normal, withURL: post.originalPost.user.photoURL)
      
      originalPhotoButton.clipsToBounds = true
      originalPhotoButton.layer.cornerRadius = 5.0
      
      originalPostTTTAttributedLabel.setupWithText(post.originalPost.text, andFont: RepostCell.originalPostTTTAttributedLabelFont)
      
      goToOriginalPostButton.setTitleColor(scheme.touchableTextColor(), forState: .Normal)
      
      if post.originalPost.user.isAnon {
        originalNameButton.setTitle(nameTitle, forState: .Disabled)
        originalPhotoButton.setBackgroundImageForState(.Disabled, withURL: post.user.photoURL)
        originalNameButton.enabled = false
        originalPhotoButton.enabled = false
      }
      
      if let seeFullButton = seeFullButton {
        seeFullButton.tag = buttonTag
        if let seeFull = post.originalPost.seeFull where !seeFull {
          seeFullButton.hidden = false
        } else {
          seeFullButton.hidden = true
        }
      }
      
      originalNameButton.tag = buttonTag + RepostCell.tagModifier
      originalBoardButton.tag = buttonTag + RepostCell.tagModifier
      originalPhotoButton.tag = buttonTag + RepostCell.tagModifier
      goToOriginalPostButton.tag = buttonTag + RepostCell.tagModifier
      
      if post.originalPost.user.isSelf {
        originalNameButton.setTitleColor(scheme.meTextColor(), forState: .Normal)
      } else {
        originalNameButton.setTitleColor(UIColor.darkTextColor(), forState: .Normal)
      }
      
      if let title = post.originalPost.title {
        titleLabel.text = title
        titleHeightConstraint.constant = RepostCell.titleHeight
      } else {
        titleLabel.text = ""
        titleHeightConstraint.constant = 0.0
      }
      
      imagesButtonHeightConstraint.constant = post.originalPost.heightOfImagesInPostWithWidth(contentView.frame.size.width - 16 - RepostCell.originalPostMargins)
      if let loadedImage = post.originalPost.loadedImage {
        imagesButton.setBackgroundImage(loadedImage, forState: .Normal)
        imagesButton.setTitle("", forState: .Normal)
        imagesButton.contentMode = .ScaleAspectFit
      } else if post.originalPost.isImagePost {
        imagesButton.setTitle("Loading...", forState: .Normal)
      }
      
      verticalLineView.backgroundColor = scheme.thinLineBackgroundColor()
    }
  }
  
  // MARK: Networking Helper Functions
  
  // TODO:
  override func loadImagesForPost(post: Post, completionHandler: (image: UIImage) -> ()) {
    if let post = post as? Repost, imageURLs = post.originalPost.imageURLs {
      imagesButton.setBackgroundImageForState(.Highlighted, withURLRequest: NSURLRequest(URL: imageURLs[0]), placeholderImage: nil, success: { request, response, image in
          completionHandler(image: image)
        }, failure: nil)
    }
  }
}
