//
//  PostCell.swift
//  Cillo
//
//  Created by Andrew Daley on 10/23/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

///Cell that corresponds to reuse identifier "Post". Used to format Posts in UITableViews.
class PostCell: UITableViewCell {

    // MARK: - IBOutlets
    
    ///Corresponds to user of Post
    @IBOutlet weak var userLabel: UILabel!
    
    ///Corresponds to picture of Post
    @IBOutlet weak var profilePicView: UIImageView!
    
    ///Corresponds to group of Post
    @IBOutlet weak var groupLabel: UILabel!
    
    ///Corresponds to text of Post
    @IBOutlet weak var postTextView: UITextView!
    
    ///Corresponds to title of Post
    @IBOutlet weak var titleLabel: UILabel!
    
    ///Corresponds to time of Post
    @IBOutlet weak var timeLabel: UILabel!
    
    ///Corresponds to numComments of Post
    @IBOutlet weak var commentLabel: UILabel!
    
    ///Corresponds to rep of Post
    @IBOutlet weak var repLabel: UILabel!
    
    ///Changes seeFull of Post. Unexpandable Posts do not have this UIButton
    @IBOutlet weak var seeFullButton: UIButton?
    
    ///Sends view to Comments Section of PostTableViewController
    @IBOutlet weak var commentButton: UIButton!
    
    ///Set to 0 if there is no title for Post
    @IBOutlet weak var titleHeightConstraint: NSLayoutConstraint!
    
    
    // MARK: - Constants
    
    ///Font of postTextView
    class var POST_TEXT_VIEW_FONT:UIFont {return UIFont.systemFontOfSize(15.0)}
    
    ///Height needed for all components of PostCell except postTextView in Storyboard
    class var ADDITIONAL_VERT_SPACE_NEEDED:CGFloat {return 139}
    
    ///Height of titleLabel in StoryBoard
    class var TITLE_HEIGHT:CGFloat {return 26.5}
    
    
    //MARK: - Helper Functions
    
    ///Makes this PostCell formatted to have the possibility of being expanded and contracted if this PostCell has a seeFullButton
    func makeCellFromPost(post: Post, withButtonTag buttonTag: Int) {
        
        userLabel.text = post.user
        groupLabel.text = post.group
        profilePicView.image = post.picture
        timeLabel.text = post.time
        
        postTextView.text = post.text
        postTextView.font = PostCell.POST_TEXT_VIEW_FONT
        postTextView.textContainer.lineFragmentPadding = 0
        postTextView.textContainerInset = UIEdgeInsetsZero
        
        if seeFullButton != nil {
            //tag acts as way for button to know it's position in data array
            seeFullButton!.tag = buttonTag
            commentButton.tag = buttonTag
            
            //short posts and already expanded posts don't need to be expanded
            if post.seeFull == nil || post.seeFull! {
                seeFullButton!.hidden = true
            } else {
                seeFullButton!.hidden = false
            }
        }
        
        //Formats numbers on screen to say #.#k if necessary
        commentLabel.text = String.formatNumberAsString(post.numComments)
        repLabel.text = String.formatNumberAsString(post.rep)
        
        if let t = post.title {
            titleLabel.text = t
        } else {
            titleLabel.text = ""
            titleHeightConstraint.constant = 0.0
        }
        
        if seeFullButton == nil {
            //gets rid of small gap in divider
            layoutMargins = UIEdgeInsetsZero
            preservesSuperviewLayoutMargins = false
        }
    }

}
