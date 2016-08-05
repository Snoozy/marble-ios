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
    
    // MARK: - IBOutlets
    
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
    
    /// Vertical line next to repost components that shows the post is the repost.
    @IBOutlet weak var verticalLineView: UIView!
    
    // MARK: - UITableViewCell
    
    override func prepareForReuse() {
        super.prepareForReuse()
        originalNameButton.isEnabled = true
        originalPhotoButton.isEnabled = true
    }
    
    // MARK: - Setup Helper Functions
    
    override func assignDelegatesForCellTo<T: UIViewController where T: TTTAttributedLabelDelegate>(_ delegate: T) {
        super.assignDelegatesForCellTo(delegate)
        originalPostAttributedLabel.delegate = delegate
    }
    
    override func makeFrom(post: Post, expanded: Bool) {
        super.makeFrom(post: post, expanded: expanded)
        
        let scheme = ColorScheme.defaultScheme
        
        if let post = post as? Repost {
            
            // handle recoloring of the end user's posts.
            if post.originalPost.user.isSelf {
                originalNameButton.setTitleColor(scheme.meTextColor(), for: UIControlState())
            } else {
                originalNameButton.setTitleColor(UIColor.darkText, for: UIControlState())
            }
            originalNameButton.setTitleWithoutAnimation(post.originalPost.user.name)
            
            originalBoardButton.setTitleWithoutAnimation(post.originalPost.board.name)
            
            originalPhotoButton.imageView?.contentMode = .scaleAspectFill
            originalPhotoButton.clipsToBounds = true
            originalPhotoButton.layer.cornerRadius = 5.0
            ImageLoadingManager.sharedInstance.downloadImageFrom(url: post.user.photoURL) { image in
                DispatchQueue.main.async {
                    originalPhotoButton.setImage(image, for: UIControlState())
                }
            }
            
            originalPostAttributedLabel.setupFor(post.originalPost.text)
            
            goToOriginalPostButton.setTitleColor(scheme.touchableTextColor(), for: UIControlState())
            
            if post.originalPost.user.isAnon {
                originalNameButton.isEnabled = false
                originalPhotoButton.isEnabled = false
            }
            
            verticalLineView.backgroundColor = scheme.thinLineBackgroundColor()
        }
    }
}
