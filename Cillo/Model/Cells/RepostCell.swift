//
//  RepostCell.swift
//  Cillo
//
//  Created by Andrew Daley on 12/25/14.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

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
  @IBOutlet weak var originalPostAttributedLabel: TTTAttributedLabel!
  
  /// Controls height of postAttributedLabel.
  ///
  /// Allows both postTTTAtttibutedLabel and originalPostAttributedLabel to have dynamic heights based on their text size.
  @IBOutlet weak var postAttributedLabelHeightConstraint: NSLayoutConstraint!
  
  /// Vertical line next to repost components that shows the post is the repost.
  @IBOutlet weak var verticalLineView: UIView!
  
  // MARK: Constants
  
  override class var additionalVertSpaceNeeded: CGFloat {
    return 184
  }
  
  /// Distance to originalPost related elements in the RepostCell.
  class var originalPostMargins: CGFloat {
    return 37
  }
  
  /// Struct containing all relevent fonts for the elements of a RepostCell.
  struct RepostFonts {
    
    /// Font of the text contained within originalPostAttributedLabel.
    static let originalPostAttributedLabelFont = UIFont.systemFont(ofSize: 15.0)
    
    /// Font of the text contained within originalNameButton.
    static let originalNameButtonFont = UIFont.boldSystemFont(ofSize: 15.0)
    
    /// Font of the text contained within originalBoardButton.
    static let originalBoardButtonFont = UIFont.boldSystemFont(ofSize: 15.0)
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
    postAttributedLabelHeightConstraint.constant = 20
    originalNameButton.isEnabled = true
    originalPhotoButton.isEnabled = true
    originalNameButton.setTitleWithoutAnimation("")
    originalBoardButton.setTitleWithoutAnimation("")
  }

  // MARK: Setup Helper Functions
  
  override func assignDelegatesForCellTo<T: UIViewController where T: TTTAttributedLabelDelegate>(_ delegate: T) {
    super.assignDelegatesForCellTo(delegate)
    originalPostAttributedLabel.delegate = delegate
  }
  
  /// Calculates the height of the cell given the properties of `post`.
  ///
  /// :param: post The post that this cell is based on.
  /// :param: width The width of the cell in the tableView.
  /// :param: maxHeight The maximum height of the cell when seeFull is false.
  /// :param: maxImageHeight The maximum height of the image in the cell.
  /// :param: dividerHeight The height of the `separatorView` in the tableView.
  /// :returns: The height that the cell should be in the tableView.
  class func heightOfRepostCellForRepost(_ post: Repost, withElementWidth width: CGFloat, maxContractedHeight maxHeight: CGFloat?, maxContractedImageHeight maxImageHeight: CGFloat?,andDividerHeight dividerHeight: CGFloat) -> CGFloat {
    var height = post.heightOfPostWithWidth(width, andMaxContractedHeight: nil, andFont: PostCell.PostFonts.postAttributedLabelFont) + RepostCell.additionalVertSpaceNeeded + post.originalPost.heightOfPostWithWidth(width - RepostCell.originalPostMargins, andMaxContractedHeight: maxHeight, andFont: RepostCell.RepostFonts.originalPostAttributedLabelFont)
    height += post.originalPost.heightOfImagesInPostWithWidth(width - RepostCell.originalPostMargins, andMaxImageHeight: maxImageHeight ?? .max)
    height += dividerHeight
    return height
  }
  
  /// Makes this RepostCell's IBOutlets display the correct values of the corresponding Repost.
  ///
  /// **Note:** The implementation of this PostCell subclass will display repostUser as nameLabel.text and repostBoard as boardLabel.text.
  ///
  /// :param: post The corresponding Post to be displayed by this RepostCell.
  /// :param: buttonTag The tags of all buttons in this RepostCell.
  /// :param: * Pass the precise index of the post in its model array.
  /// :param: maxImageHeight The maximum height of the image in the cell.
  /// :param: separatorHeight The height of the custom separators at the bottom of this Post Cell.
  /// :param: * The default value is 0.0, meaning the separators will not show by default.
  override func makeCellFromPost(_ post: Post, withButtonTag buttonTag: Int, maxContractedImageHeight maxImageHeight: CGFloat?, andSeparatorHeight separatorHeight: CGFloat = 0.0) {
    super.makeCellFromPost(post, withButtonTag: buttonTag, maxContractedImageHeight: maxImageHeight, andSeparatorHeight: separatorHeight)
    
    let scheme = ColorScheme.defaultScheme
    
    if let post = post as? Repost {
      
      setupRepostOutletFonts()
      setRepostOutletTagsTo(buttonTag + RepostCell.tagModifier)
    
      postAttributedLabelHeightConstraint.constant = post.heightOfPostWithWidth(contentView.frame.size.width - 16, andMaxContractedHeight: nil, andFont: PostCell.PostFonts.postAttributedLabelFont)
      
      originalNameButton.setTitleWithoutAnimation(post.originalPost.user.name)
      
      originalBoardButton.setTitleWithoutAnimation(post.originalPost.board.name)
      
      originalPhotoButton.setBackgroundImageToImageWithURL(post.originalPost.user.photoURL, forState: UIControlState())
      originalPhotoButton.clipsToBounds = true
      originalPhotoButton.layer.cornerRadius = 5.0
      
      originalPostAttributedLabel.setupWithText(post.originalPost.text, andFont: RepostCell.RepostFonts.originalPostAttributedLabelFont)
      
      goToOriginalPostButton.setTitleColor(scheme.touchableTextColor(), for: UIControlState())
      
      if post.originalPost.user.isAnon {
        originalNameButton.isEnabled = false
        originalPhotoButton.isEnabled = false
      }
      
      if let seeFullButton = seeFullButton {
        seeFullButton.tag = buttonTag
        if let seeFull = post.originalPost.seeFull where !seeFull {
          seeFullButton.isHidden = false
        } else {
          seeFullButton.isHidden = true
        }
      }
      
      if post.originalPost.user.isSelf {
        originalNameButton.setTitleColor(scheme.meTextColor(), for: UIControlState())
      } else {
        originalNameButton.setTitleColor(UIColor.darkText, for: UIControlState())
      }
      
      imagesButtonHeightConstraint.constant = post.originalPost.heightOfImagesInPostWithWidth(contentView.frame.size.width - 16 - RepostCell.originalPostMargins, andMaxImageHeight: maxImageHeight ?? .max)
//      if let loadedImage = post.originalPost.loadedImage {
//        imagesButton.imageView?.contentMode = .ScaleAspectFill
//        imagesButton.clipsToBounds = true
//        imagesButton.contentHorizontalAlignment = .Fill
//        imagesButton.contentVerticalAlignment = .Fill
//        imagesButton.setImage(loadedImage, forState: .Normal)
//        imagesButton.setTitle("", forState: .Normal)
//      } else if post.originalPost.isImagePost {
//        imagesButton.contentVerticalAlignment = .Center
//        imagesButton.contentHorizontalAlignment = .Center
//        imagesButton.setTitle("Loading Image...", forState: .Normal)
//        imagesButton.setTitleColor(scheme.touchableTextColor(), forState: .Normal)
//      }
      if post.isImagePost {
        imagesButton.imageView?.contentMode = .scaleAspectFill
        imagesButton.clipsToBounds = true
        imagesButton.contentHorizontalAlignment = .fill
        imagesButton.contentVerticalAlignment = .fill
        imagesButton.setImageToImageWithURL(post.originalPost.imageURLs![0], forState: UIControlState(), withWidth: contentView.frame.size.width - 16 - RepostCell.originalPostMargins)
      }
      verticalLineView.backgroundColor = scheme.thinLineBackgroundColor()
    }
  }
  
  /// Sets the tag of all relevent outlets to the specified tag. This tag represents the row of this cell in the `tableView`. The tag also notifies transition segues of the sender of transitions.
  ///
  /// :param: tag The tag that the outlet's `tag` property is set to.
  private func setRepostOutletTagsTo(_ tag: Int) {
    originalNameButton.tag = tag
    originalBoardButton.tag = tag
    originalPhotoButton.tag = tag
    goToOriginalPostButton.tag = tag
  }
  
  private func setupRepostOutletFonts() {
    originalNameButton.titleLabel?.font = RepostCell.RepostFonts.originalNameButtonFont
    originalBoardButton.titleLabel?.font = RepostCell.RepostFonts.originalBoardButtonFont
  }
  
  // MARK: Networking Helper Functions
  
  override func loadImagesForPost(_ post: Post, completionHandler: (image: UIImage) -> ()) {
    if let post = post as? Repost, imageURLs = post.originalPost.imageURLs {
      DataManager.sharedInstance.activeRequests += 1
      imagesButton.setBackgroundImageFor(.highlighted, with: Foundation.URLRequest(url: imageURLs[0] as URL), placeholderImage: nil,
        success: { _, _, image in
          DataManager.sharedInstance.activeRequests -= 1
          completionHandler(image: image!)
        },
        failure: { _ in
          DataManager.sharedInstance.activeRequests--
        }
      )
      
    }
  }
}
