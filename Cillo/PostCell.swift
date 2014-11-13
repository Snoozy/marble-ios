//
//  PostCell.swift
//  Cillo
//
//  Created by Andrew Daley on 10/23/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

///Cell that corresponds to reuse identifier "Post". Used in HomeTableViewController and PostTableViewController to format Posts in TableView.
class PostCell: UITableViewCell {

    // MARK: - IBOutlets
    
    ///All IBOutlets correspond to properties of Post. See Post for definitions of properties
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var repLabel: UILabel!
    @IBOutlet weak var seeFullButton: UIButton?
    @IBOutlet weak var commentButton: UIButton!
    
    ///Constraint will be set to 0 if there is no title for Post
    @IBOutlet weak var titleHeightConstraint: NSLayoutConstraint!
    
    
    // MARK: - Constants
    
    ///Font of postTextView in Storyboard
    class var POST_TEXT_VIEW_FONT:UIFont {return UIFont.systemFontOfSize(15.0)}
    
    ///Height needed for all components of PostCell except postTextView in Storyboard
    class var ADDITIONAL_VERT_SPACE_NEEDED:CGFloat {return 139}
    
    ///Height of titleLabel in StoryBoard
    class var TITLE_HEIGHT:CGFloat {return 26.5}
    
    
    //MARK: - Initializers
    
    ///Makes this PostCell formatted to have the possibility of being expanded and contracted. StandardPostCells have a seeFullButton
    func makeStandardPostCellFromPost(post: Post, forIndexPath indexPath: NSIndexPath) {
        userLabel.text = post.user
        groupLabel.text = post.group
        profilePicView.image = post.picture
        timeLabel.text = post.time
        
        postTextView.text = post.text
        postTextView.font = PostCell.POST_TEXT_VIEW_FONT
        postTextView.textContainer.lineFragmentPadding = 0
        postTextView.textContainerInset = UIEdgeInsetsZero
        
        //tag acts as way for button to know it's position in data array
        seeFullButton!.tag = indexPath.section //for button
        commentButton.tag = indexPath.section //for button
        
        //short posts and already expanded posts don't need to be expanded
        if post.seeFull == nil || post.seeFull! {
            seeFullButton!.hidden = true
        } else {
            seeFullButton!.hidden = false
        }
        
        //Formats numbers on screen to say #.#k if necessary
        commentLabel.text = Format.formatNumberAsString(post.numComments)
        repLabel.text = Format.formatNumberAsString(post.rep)
        
        if let t = post.title {
            titleLabel.text = t
        } else {
            titleLabel.text = ""
            titleHeightConstraint.constant = 0.0
        }
    }
    
    ///Makes this PostCell fully expanded by default. ExpandedPostCells don't have a seeFullButton
    func makeExpandedPostCellFromPost(post: Post, forIndexPath indexPath: NSIndexPath) {
        userLabel.text = post.user
        profilePicView.image = post.picture
        groupLabel.text = post.group
        timeLabel.text = post.time
        
        postTextView.text = post.text
        postTextView.font = PostCell.POST_TEXT_VIEW_FONT
        postTextView.textContainer.lineFragmentPadding = 0
        postTextView.textContainerInset = UIEdgeInsetsZero
        
        //Formats numbers on screen to say #.#k if necessary
        commentLabel.text = Format.formatNumberAsString(post.numComments)
        repLabel.text = Format.formatNumberAsString(post.rep)
        
        if let t = post.title {
            titleLabel.text = t
        } else { //post has no title
            titleLabel.text = ""
            titleHeightConstraint.constant = 0.0
        }
        
        //gets rid of small gap in divider
        layoutMargins = UIEdgeInsetsZero
        preservesSuperviewLayoutMargins = false
    }

}
