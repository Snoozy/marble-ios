//
//  PostCell.swift
//  Cillo
//
//  Created by Andrew Daley on 10/23/14.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit
import TTTAttributedLabel

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
  
  ///Controls height of imagesButton.
  ///
  /// Set constant to 20 if showImages is false, otherwise set it to the height of the image.
  @IBOutlet weak var imagesButtonHeightConstraint: NSLayoutConstraint!
  
  /// Displays user.name property of Post.
  @IBOutlet weak var nameButton: UIButton!
  
  /// Displays user.photo property of Post.
  @IBOutlet weak var photoButton: UIButton!
  
  /// Displays text property of Post.
  @IBOutlet weak var postTTTAttributedLabel: TTTAttributedLabel!
  
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
  
  /// Controls height of titleLabel.
  ///
  /// If title of Post is nil, set constant to 0.
  @IBOutlet weak var titleHeightConstraint: NSLayoutConstraint!
  
  /// Displays title property of Post.
  @IBOutlet weak var titleLabel: UILabel!
  
  /// Upvotes Post.
  @IBOutlet weak var upvoteButton: UIButton!

  // MARK: Constants
  
  /// Height needed for all components of a PostCell excluding postTTTAttributedLabel in the Storyboard.
  ///
  /// **Note:** Height of postTTTAttributedLabel must be calculated based on it's text property.
  class var additionalVertSpaceNeeded: CGFloat {
    return 140
  }
  /// Font of the text contained within postTTTAttributedLabel.
  class var postTTTAttributedLabelFont: UIFont {
    return UIFont.systemFontOfSize(15.0)
  }
  
  /// Height of titleLabel in Storyboard.
  class var titleHeight: CGFloat {
    return 26
  }
  
  // MARK: UITableViewCell
  
  override func prepareForReuse() {
    imagesButtonHeightConstraint.constant = 0
    imagesButton.setBackgroundImage(nil, forState: .Normal)
    imagesButton.setBackgroundImage(nil, forState: .Highlighted)
    separatorViewHeightConstraint?.constant = 0
    imagesButton.setTitle("", forState: .Normal)
    nameButton.enabled = true
    photoButton.enabled = true
  }
  
  // MARK: Setup Helper Functions
  
  /// Assigns all delegates of cell to the given parameter.
  ///
  /// :param: delegate The delegate that will be assigned to elements of the cell pertaining to the required protocols specified in the function header.
  func assignDelegatesForCellTo<T: UIViewController where T: TTTAttributedLabelDelegate>(delegate: T) {
    postTTTAttributedLabel.delegate = delegate
  }
  
  /// Calculates the height of the cell given the properties of `post`.
  ///
  /// :param: post The post that this cell is based on.
  /// :param: width The width of the cell in the tableView.
  /// :param: maxHeight The maximum height of the cell when seeFull is false.
  /// :param: dividerHeight The height of the `separatorView` in the tableView.
  /// :returns: The height that the cell should be in the tableView.
  class func heightOfPostCellForPost(post: Post, withElementWidth width: CGFloat, maxContractedHeight maxHeight: CGFloat?, andDividerHeight dividerHeight: CGFloat) -> CGFloat {
    if let post = post as? Repost {
      return RepostCell.heightOfRepostCellForRepost(post, withElementWidth: width, maxContractedHeight: maxHeight, andDividerHeight: dividerHeight)
    }
    var height = post.heightOfPostWithWidth(width, andMaxContractedHeight: maxHeight, andFont: PostCell.postTTTAttributedLabelFont) + PostCell.additionalVertSpaceNeeded
    height += post.heightOfImagesInPostWithWidth(width)
    height += dividerHeight
    return post.title != nil ? height : height - PostCell.titleHeight
  }
  
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
    photoButton.setBackgroundImageForState(.Normal, withURL: post.user.photoURL)
    timeLabel.text = post.time
    
    photoButton.clipsToBounds = true
    photoButton.layer.cornerRadius = 5.0
    
    postTTTAttributedLabel.setupWithText(post.text, andFont: PostCell.postTTTAttributedLabelFont)
    
    if post.user.isAnon {
      nameButton.setTitle(nameTitle, forState: .Disabled)
      photoButton.setBackgroundImageForState(.Disabled, withURL: post.user.photoURL)
      nameButton.enabled = false
      photoButton.enabled = false
    }
    
    nameButton.tag = buttonTag
    boardButton.tag = buttonTag
    photoButton.tag = buttonTag
    commentButton.tag = buttonTag
    upvoteButton.tag = buttonTag
    downvoteButton.tag = buttonTag
    repostButton.tag = buttonTag
    imagesButton.tag = buttonTag
    
    if post.user.isSelf {
      nameButton.setTitleColor(scheme.meTextColor(), forState: .Normal)
    } else {
      nameButton.setTitleColor(UIColor.darkTextColor(), forState: .Normal)
    }
    
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
    
    commentLabel.text = post.commentCount.fiveCharacterDisplay
    commentLabel.textColor = UIColor.whiteColor()
    repLabel.text = post.rep.fiveCharacterDisplay
    repLabel.font = UIFont.systemFontOfSize(24)
    
    // gets rid of small gap in divider
    if seeFullButton == nil && respondsToSelector("setLayoutMargins:") {
        layoutMargins = UIEdgeInsetsZero
    }
    
    separatorViewHeightConstraint?.constant = separatorHeight
    
    separatorView?.backgroundColor = scheme.dividerBackgroundColor()

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
      
      if let title = post.title {
        titleLabel.text = title
        titleHeightConstraint.constant = PostCell.titleHeight
      } else {
        titleLabel.text = ""
        titleHeightConstraint.constant = 0.0
      }
      
      imagesButtonHeightConstraint.constant = post.heightOfImagesInPostWithWidth(contentView.frame.size.width - 16)
      if let loadedImage = post.loadedImage {
        imagesButton.setBackgroundImage(loadedImage, forState: .Normal)
        imagesButton.setTitle("", forState: .Normal)
        imagesButton.contentMode = .ScaleAspectFit
      } else if post.isImagePost {
        imagesButton.setTitle("Loading...", forState: .Normal)
      }
    }
  }
  
  // MARK: Networking Helper Functions
  
  // TODO:
  func loadImagesForPost(post: Post, completionHandler: (image: UIImage) -> ()) {
    if let imageURLs = post.imageURLs {
      imagesButton.setBackgroundImageForState(.Highlighted, withURLRequest: NSURLRequest(URL: imageURLs[0]), placeholderImage: nil, success: { request, response, image in
        completionHandler(image: image)
      }, failure: nil)
    }
  }
}
