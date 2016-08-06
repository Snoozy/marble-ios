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
    
    // MARK: - IBOutlets
    
    /// Displays board.name property of Post.
    @IBOutlet weak var boardButton: UIButton!
    
    /// Centers view on Comments Section of PostTableViewController.
    @IBOutlet weak var commentButton: UIButton!
    
    /// Displays commentCount property of Post.
    @IBOutlet weak var commentLabel: UILabel!
    
    /// Downvotes Post.
    @IBOutlet weak var downvoteButton: UIButton!
    
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
    @IBOutlet weak var expandButton: UIButton!
    
    /// Controls whether postAttributedLabel shows the full post or part of the post.
    ///
    /// If active, the post will be cut off, otherwise the full post is shown.
    @IBOutlet var expandConstraint: NSLayoutConstraint!
    
    /// Displays time property of Post.
    @IBOutlet weak var timeLabel: UILabel!
    
    /// Upvotes Post.
    @IBOutlet weak var upvoteButton: UIButton!
    
    // MARK: - UITableViewCell
    
    override func prepareForReuse() {
        nameButton.isEnabled = true
        photoButton.isEnabled = true
        photoButton.setImage(nil, for: UIControlState())
    }
    
    // MARK: - Setup Helper Functions
    
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
    /// :param: expanded If true, the cell will display its full text.
    func makeFrom(post: Post, expanded: Bool) {
        
        let color = ColorScheme.defaultScheme
        
        // handle recoloring of the end user's posts.
        if post.user.isSelf {
            nameButton.setTitleColor(color.meTextColor(), for: UIControlState())
        } else {
            nameButton.setTitleColor(UIColor.darkText, for: UIControlState())
        }
        nameButton.setTitleWithoutAnimation(post.user.name)
        
        boardButton.setTitleWithoutAnimation(post.board.name)
        
        timeLabel.text = post.time
        timeLabel.textColor = UIColor.lightGray
        
        photoButton.imageView?.contentMode = .scaleAspectFill
        photoButton.clipsToBounds = true
        photoButton.layer.cornerRadius = 5.0
        if let url = post.user.photoURL {
            ImageLoadingManager.sharedInstance.downloadImageFrom(url: url) { image in
                DispatchQueue.main.async {
                    self.photoButton.setImage(image, for: UIControlState())
                }
            }
        }
        
        postAttributedLabel.setupFor(post.text)
        
        commentLabel.text = post.commentCount.fiveCharacterDisplay
        commentLabel.textColor = UIColor.white
        
        repLabel.text = post.rep.fiveCharacterDisplay
        
        // handle anonymous boards
        if post.user.isAnon {
            nameButton.isEnabled = false
            photoButton.isEnabled = false
        }
        
        // handle upvoted and downvoted posts.
        if post.voteValue == 1 {
            upvoteButton.setBackgroundImage(UIImage(named: "Selected Up Arrow"),for: UIControlState())
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
        layoutMargins = .zero
        
        // handle whether the cell should show the expanded state
        expandButton.isHidden = !expanded
        expandConstraint.active = !expanded
    }
}
