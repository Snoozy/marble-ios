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
    
    // MARK: Properties
    
    var indexPath = NSIndexPath()
    
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
    
    /// Changes expanded value of Post.
    ///
    /// Posts with expanded == nil hide this button.
    @IBOutlet weak var expandedButton: UIButton!
    
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
        static let postAttributedLabelFont = UIFont.systemFont(ofSize: 15.0)
        
        /// Font of the text contained within repLabel.
        static let repLabelFont = UIFont.boldSystemFont(ofSize: 18.0)
        
        /// Font of the text contained within nameButton.
        static let nameButtonFont = UIFont.boldSystemFont(ofSize: 16.0)
        
        /// Font of the text contained within boardButton.
        static let boardButtonFont = UIFont.boldSystemFont(ofSize: 16.0)
        
        /// Font of the text contained within timeLabel.
        static let timeLabelFont = UIFont.systemFont(ofSize: 13.0)
        
        /// Font of the text contained within commentLabel.
        static let commentLabelFont = UIFont.systemFont(ofSize: 9.0)
    }
    
    // MARK: UITableViewCell
    
    override func prepareForReuse() {
        nameButton.isEnabled = true
        photoButton.isEnabled = true
    }
    
    // MARK: Setup Helper Functions
    
    /// Assigns all delegates of cell to the given parameter.
    ///
    /// :param: delegate The delegate that will be assigned to elements of the cell pertaining to the required protocols specified in the function header.
    func assignDelegatesForCellTo<T: UIViewController where
                                  T: TTTAttributedLabelDelegate>(_ delegate: T) {
        postAttributedLabel.delegate = delegate
    }
    
    /// Makes this PostCell's IBOutlets display the correct values of the corresponding Post.
    ///
    /// :param: post The corresponding Post to be displayed by this PostCell.
    /// :param: buttonTag The tags of all buttons in this PostCell corresponding to their index in the array holding them.
    /// :param: * Pass the precise index of the post in its model array.
    /// :param: maxImageHeight The maximum height of the image in the cell.
    /// :param: separatorHeight The height of the custom separators at the bottom of this PostCell.
    /// :param: * The default value is 0.0, meaning the separators will not show by default.
    func makeFrom(post: Post,
                  atIndexPath indexPath: NSIndexPath,
                  withImageHeight imageHeight: CGFloat,
                  andSeparatorHeight separatorHeight: CGFloat = 0.0) {
        
        self.indexPath = indexPath
        
        setupPostOutletFonts()
        
        nameButton.setTitleWithoutAnimation(post.user.name)
        boardButton.setTitleWithoutAnimation(post.board.name)
        
        timeLabel.text = post.time
        timeLabel.textColor = UIColor.lightGray
        
        ImageLoadingManager.sharedInstance.downloadImageFrom(url: post.user.photoURL) { image in
            DispatchQueue.main.async {
                photoButton.setImage(image, for: UIControlState())
            }
        }
        photoButton.imageView?.contentMode = .scaleAspectFill
        photoButton.clipsToBounds = true
        photoButton.layer.cornerRadius = 5.0
        
        postAttributedLabel.setupWithText(post.text,
                                          andFont: PostCell.PostFonts.postAttributedLabelFont)
        
        commentLabel.text = post.commentCount.fiveCharacterDisplay
        commentLabel.textColor = UIColor.white
        
        repLabel.text = post.rep.fiveCharacterDisplay
        
        // handle anonymous boards
        if post.user.isAnon {
            nameButton.isEnabled = false
            photoButton.isEnabled = false
        }
        
        let scheme = ColorScheme.defaultScheme
        
        // handle recoloring of the end user's posts.
        if post.user.isSelf {
            nameButton.setTitleColor(scheme.meTextColor(), for: UIControlState())
        } else {
            nameButton.setTitleColor(UIColor.darkText, for: UIControlState())
        }
        
        // handle upvoted and downvoted posts.
        if post.voteValue == 1 {
            upvoteButton.setBackgroundImage(UIImage(named: "Selected Up Arrow"), for: UIControlState())
            downvoteButton.setBackgroundImage(UIImage(named: "Down Arrow"), for: UIControlState())
            repLabel.textColor = UIColor.upvoteGreen()
        } else if post.voteValue == -1 {
            upvoteButton.setBackgroundImage(UIImage(named: "Up Arrow"), for: UIControlState())
            downvoteButton.setBackgroundImage(UIImage(named: "Selected Down Arrow"), for: UIControlState())
            repLabel.textColor = UIColor.downvoteRed()
        } else {
            upvoteButton.setBackgroundImage(UIImage(named: "Up Arrow"), for: UIControlState())
            downvoteButton.setBackgroundImage(UIImage(named: "Down Arrow"), for: UIControlState())
            repLabel.textColor = UIColor.darkText
        }
        
        // gets rid of small gap in divider
        if expandedButton == nil {
            layoutMargins = UIEdgeInsetsZero
        }
        
        separatorViewHeightConstraint?.constant = separatorHeight
        separatorView?.backgroundColor = scheme.dividerBackgroundColor()
        
        // perform additional setup when post is not a Repost.
        // this setup would be redundant if post is a Repost.
        if !(post is Repost) {
            if let expandedButton = expandedButton {
                
                expandedButton.setTitle("More", for: UIControlState())
                
                // short posts and already expanded posts don't need to be expanded
                if let expanded = post.expanded && !expanded {
                    expandedButton.isHidden = false
                } else {
                    expandedButton.isHidden = true
                }
            }
            
            
            if post.isImagePost {
                imagesButtonHeightConstraint.constant = imageHeight
                imagesButton.setImage(nil, for: UIControlState())
                imagesButton.imageView?.contentMode = .scaleAspectFill
                imagesButton.clipsToBounds = true
                imagesButton.contentHorizontalAlignment = .fill
                imagesButton.contentVerticalAlignment = .fill
                imagesButton.isEnabled = true
                ImageLoadingManager.sharedInstance.downloadImageFrom(url: post.imageURLs![0]) { image in
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.3) {
                            imagesButton.setImage(image, for: UIControlState())
                        }
                    }
                }
            } else {
                imagesButtonHeightConstraint.constant = 0.0
            }
        }
    }
    
    /// Sets fonts of all IBOutlets to the fonts specified in the `PostCell.PostFonts` struct.
    private func setupPostOutletFonts() {
        nameButton.titleLabel?.font = PostCell.PostFonts.nameButtonFont
        boardButton.titleLabel?.font = PostCell.PostFonts.boardButtonFont
        timeLabel.font = PostCell.PostFonts.timeLabelFont
        commentLabel.font = PostCell.PostFonts.commentLabelFont
        repLabel.font = PostCell.PostFonts.repLabelFont
    }
}
