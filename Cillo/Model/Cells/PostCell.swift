//
//  PostCell.swift
//  Cillo
//
//  Created by Andrew Daley on 10/23/14.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Cell that corresponds to reuse identifier "Post".
///
/// Used to format Posts in UITableViews.
class PostCell: UITableViewCell {
  
  // MARK: IBOutlets
  
  /// Displays board.name property of Post.
  @IBOutlet weak var boardButton: UIButton!
  
  /// Centers view on Comments Section of PostTableViewController.
  @IBOutlet weak var commentButton: UIButton!
  
  /// Displays commentCount property of Post.
  @IBOutlet weak var commentLabel: UILabel!
  
  /// Downvotes Post.
  @IBOutlet weak var downvoteButton: UIButton!
  
  /// Loads images corresponding to imageURLs property of Post asynchronously.
  @IBOutlet weak var imagesButton: UIButton!
  
  /// Controls height of imagesButton.
  ///
  /// Set constant to 20 if showImages is false, otherwise set it to the height of the image.
  @IBOutlet weak var imagesButtonHeightConstraint: NSLayoutConstraint!
  
  
  /// Displays a menu with more actions on the Post.
  @IBOutlet weak var moreButton: UIButton?
  
  /// Displays user.name property of Post.
  @IBOutlet weak var nameButton: UIButton!
  
  /// Displays user.photo property of Post.
  @IBOutlet weak var photoButton: UIButton!
  
  /// Displays text property of Post.
  @IBOutlet weak var postAttributedLabel: TTTAttributedLabel!
  
  /// Displays rep property of Post.
  @IBOutlet weak var repLabel: UILabel!
  
  /// Reposts Post in a different Board.
  @IBOutlet weak var repostButton: UIButton!
  
  /// Changes seeFull value of Post.
  ///
  /// Posts with seeFull == nil do not have this UIButton.
  @IBOutlet weak var seeFullButton: UIButton?
  
  /// Custom border between cells.
  ///
  /// This IBOutlet may not be assigned in the storyboard, meaning the UITableViewController managing this cell wants to use default UITableView separators.
  @IBOutlet weak var separatorView: UIView?
  
  /// Controls height of separatorView.
  ///
  /// Set constant to value of separatorHeight in the makeCellFromPost(_:withButtonTag:andSeparatorHeight:) function.
  @IBOutlet weak var separatorViewHeightConstraint: NSLayoutConstraint?
  
  /// Displays time property of Post.
  @IBOutlet weak var timeLabel: UILabel!
  
  /// Upvotes Post.
  @IBOutlet weak var upvoteButton: UIButton!

  // MARK: Constants
  
  /// Height needed for all components of a PostCell excluding postAttributedLabel in the Storyboard.
  ///
  /// **Note:** Height of postAttributedLabel must be calculated based on it's text property.
  class var additionalVertSpaceNeeded: CGFloat {
    return 116
  }
  
  /// Struct containing all relevent fonts for the elements of a PostCell.
  struct PostFonts {
    
    /// Font of the text contained within postAttributedLabel.
    static let postAttributedLabelFont = UIFont.systemFontOfSize(15.0)
    
    /// Font of the text contained within repLabel.
    static let repLabelFont = UIFont.boldSystemFontOfSize(18.0)
    
    /// Font of the text contained within nameButton.
    static let nameButtonFont = UIFont.boldSystemFontOfSize(17.0)
    
    /// Font of the text contained within boardButton.
    static let boardButtonFont = UIFont.boldSystemFontOfSize(17.0)
    
    /// Font of the text contained within timeLabel.
    static let timeLabelFont = UIFont.systemFontOfSize(13.0)
    
    /// Font of the text contained within commentLabel.
    static let commentLabelFont = UIFont.systemFontOfSize(9.0)
  }
  
  // MARK: UITableViewCell
  
  override func prepareForReuse() {
//    imagesButtonHeightConstraint.constant = 0
//    imagesButton.setImage(nil, forState: .Normal)
//    separatorViewHeightConstraint?.constant = 0
//    imagesButton.setTitle("", forState: .Normal)
    nameButton.enabled = true
    photoButton.enabled = true
//    nameButton.setTitleWithoutAnimation("")
//    boardButton.setTitleWithoutAnimation("")
  }
  
  // MARK: Setup Helper Functions
  
  /// Assigns all delegates of cell to the given parameter.
  ///
  /// :param: delegate The delegate that will be assigned to elements of the cell pertaining to the required protocols specified in the function header.
  func assignDelegatesForCellTo<T: UIViewController where T: TTTAttributedLabelDelegate>(delegate: T) {
    postAttributedLabel.delegate = delegate
  }
  
  /// Calculates the height of the cell given the properties of `post`.
  ///
  /// :param: post The post that this cell is based on.
  /// :param: width The width of the cell in the tableView.
  /// :param: maxHeight The maximum height of the cell when seeFull is false.
  /// :param: maxImageHeight The maximum height of the image in the cell.
  /// :param: dividerHeight The height of the `separatorView` in the tableView.
  /// :returns: The height that the cell should be in the tableView.
  class func heightOfPostCellForPost(post: Post, withElementWidth width: CGFloat, maxContractedHeight maxHeight: CGFloat?, maxContractedImageHeight maxImageHeight: CGFloat?, andDividerHeight dividerHeight: CGFloat) -> CGFloat {
    if let post = post as? Repost {
      return RepostCell.heightOfRepostCellForRepost(post, withElementWidth: width, maxContractedHeight: maxHeight, maxContractedImageHeight: maxImageHeight, andDividerHeight: dividerHeight)
    }
    var height = post.heightOfPostWithWidth(width, andMaxContractedHeight: maxHeight, andFont: PostCell.PostFonts.postAttributedLabelFont) + PostCell.additionalVertSpaceNeeded
    height += post.heightOfImagesInPostWithWidth(width, andMaxImageHeight: maxImageHeight ?? .max)
    height += dividerHeight
    return height
  }
  
  /// Makes this PostCell's IBOutlets display the correct values of the corresponding Post.
  ///
  /// :param: post The corresponding Post to be displayed by this PostCell.
  /// :param: buttonTag The tags of all buttons in this PostCell corresponding to their index in the array holding them.
  /// :param: * Pass the precise index of the post in its model array.
  /// :param: maxImageHeight The maximum height of the image in the cell.
  /// :param: separatorHeight The height of the custom separators at the bottom of this PostCell.
  /// :param: * The default value is 0.0, meaning the separators will not show by default.
  func makeCellFromPost(post: Post, withButtonTag buttonTag: Int, maxContractedImageHeight maxImageHeight: CGFloat?, andSeparatorHeight separatorHeight: CGFloat = 0.0) {
    
    setupPostOutletFonts()
    setOutletTagsTo(buttonTag)
    
    nameButton.setTitleWithoutAnimation(post.user.name)
    boardButton.setTitleWithoutAnimation(post.board.name)
    
    timeLabel.text = post.time
    timeLabel.textColor = UIColor.lightGrayColor()
    
    photoButton.setBackgroundImageToImageWithURL(post.user.photoURL, forState: .Normal)
    photoButton.clipsToBounds = true
    photoButton.layer.cornerRadius = 5.0
    
    postAttributedLabel.setupWithText(post.text, andFont: PostCell.PostFonts.postAttributedLabelFont)
    
    commentLabel.text = post.commentCount.fiveCharacterDisplay
    commentLabel.textColor = UIColor.whiteColor()
    
    repLabel.text = post.rep.fiveCharacterDisplay
    
    // handle anonymous boards
    if post.user.isAnon {
      nameButton.enabled = false
      photoButton.enabled = false
    }
    
    let scheme = ColorScheme.defaultScheme
    
    // handle recoloring of the end user's posts.
    if post.user.isSelf {
      nameButton.setTitleColor(scheme.meTextColor(), forState: .Normal)
    } else {
      nameButton.setTitleColor(UIColor.darkTextColor(), forState: .Normal)
    }
    
    // handle upvoted and downvoted posts.
    if post.voteValue == 1 {
      upvoteButton.setBackgroundImage(UIImage(named: "Selected Up Arrow"), forState: .Normal)
      downvoteButton.setBackgroundImage(UIImage(named: "Down Arrow"), forState: .Normal)
      repLabel.textColor = UIColor.upvoteGreen()
    } else if post.voteValue == -1 {
      upvoteButton.setBackgroundImage(UIImage(named: "Up Arrow"), forState: .Normal)
      downvoteButton.setBackgroundImage(UIImage(named: "Selected Down Arrow"), forState: .Normal)
      repLabel.textColor = UIColor.downvoteRed()
    } else {
      upvoteButton.setBackgroundImage(UIImage(named: "Up Arrow"), forState: .Normal)
      downvoteButton.setBackgroundImage(UIImage(named: "Down Arrow"), forState: .Normal)
      repLabel.textColor = UIColor.darkTextColor()
    }
    
    // gets rid of small gap in divider
    if seeFullButton == nil && respondsToSelector("setLayoutMargins:") {
      layoutMargins = UIEdgeInsetsZero
    }
    
    separatorViewHeightConstraint?.constant = separatorHeight
    separatorView?.backgroundColor = scheme.dividerBackgroundColor()

    // perform additional setup when post is not a Repost.
    // this setup would be redundant if post is a Repost.
    if !(post is Repost) {
      if let seeFullButton = seeFullButton {
        // tag acts as way for button to know it's position in data array
        seeFullButton.tag = buttonTag
        
        seeFullButton.setTitle("More", forState: .Normal)
        
        // short posts and already expanded posts don't need to be expanded
        if let seeFull = post.seeFull where !seeFull {
          seeFullButton.hidden = false
        } else {
          seeFullButton.hidden = true
        }
      }
      
      imagesButtonHeightConstraint.constant = post.heightOfImagesInPostWithWidth(contentView.frame.size.width - 16, andMaxImageHeight: maxImageHeight ?? .max)
//      if let loadedImage = post.loadedImage {
//        imagesButton.imageView?.contentMode = .ScaleAspectFill
//        imagesButton.clipsToBounds = true
//        imagesButton.contentHorizontalAlignment = .Fill
//        imagesButton.contentVerticalAlignment = .Fill
//        imagesButton.setImage(loadedImage, forState: .Normal)
//        imagesButton.setTitle("", forState: .Normal)
//      } else if post.isImagePost {
//        imagesButton.contentVerticalAlignment = .Center
//        imagesButton.contentHorizontalAlignment = .Center
//        imagesButton.setTitle("Loading Image...", forState: .Normal)
//        imagesButton.setTitleColor(scheme.touchableTextColor(), forState: .Normal)
//      }
      if post.isImagePost {
        imagesButton.setImage(nil, forState: .Normal)
        imagesButton.imageView?.contentMode = .ScaleAspectFill
        imagesButton.clipsToBounds = true
        imagesButton.contentHorizontalAlignment = .Fill
        imagesButton.contentVerticalAlignment = .Fill
        imagesButton.enabled = true
        imagesButton.setImageToImageWithURL(post.imageURLs![0], forState: .Normal)
      }
    }
  }
  
  /// Sets the tag of all relevent outlets to the specified tag. This tag represents the row of this cell in the `tableView`.
  ///
  /// :param: tag The tag that the outlet's `tag` property is set to.
  private func setOutletTagsTo(tag: Int) {
    nameButton.tag = tag
    boardButton.tag = tag
    photoButton.tag = tag
    commentButton.tag = tag
    upvoteButton.tag = tag
    downvoteButton.tag = tag
    repostButton.tag = tag
    imagesButton.tag = tag
    moreButton?.tag = tag
  }
  
  /// Sets fonts of all IBOutlets to the fonts specified in the `PostCell.PostFonts` struct.
  private func setupPostOutletFonts() {
    nameButton.titleLabel?.font = PostCell.PostFonts.nameButtonFont
    boardButton.titleLabel?.font = PostCell.PostFonts.boardButtonFont
    timeLabel.font = PostCell.PostFonts.timeLabelFont
    commentLabel.font = PostCell.PostFonts.commentLabelFont
    repLabel.font = PostCell.PostFonts.repLabelFont
  }
  
  // MARK: Networking Helper Functions
  
  /// Loads the image for `post.imageURLs[0]` into `imagesButton`.
  ///
  /// :param: post The post that contains the correct image url.
  /// :param: completionHandler The completion block for the network request.
  /// :param: image The image that was loaded into the button.
  func loadImagesForPost(post: Post, completionHandler: (image: UIImage) -> ()) {
    if let imageURLs = post.imageURLs {
      DataManager.sharedInstance.activeRequests++
      imagesButton.setBackgroundImageForState(.Highlighted, withURLRequest: NSURLRequest(URL: imageURLs[0]), placeholderImage: nil,
        success: { _, _, image in
          DataManager.sharedInstance.activeRequests--
          completionHandler(image: image)
        },
        failure: { error in
          DataManager.sharedInstance.activeRequests--
        }
      )
    }
  }
}
