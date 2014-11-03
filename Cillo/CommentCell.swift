//
//  CommentCell.swift
//  Cillo
//
//  Created by Andrew Daley on 11/3/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

///Cell that corresponds to reuse identifier "Comment". Used in PostTableViewController to format Comments in TableView.
class CommentCell: UITableViewCell {

    //MARK: - IBOutlets
    
    ///All IBOutlets correspond to properties of Comment. See Comment for definitions of properties
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var repAndTimeLabel: UILabel!
    
    ///Will be set to 0 when not selected and 32 when selected
    @IBOutlet weak var upvoteHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var downvoteHeightConstraint: NSLayoutConstraint!
    
    
    // MARK: - Constants
    
    ///Font of postTextView in Storyboard
    class var textViewFont:UIFont {return UIFont.systemFontOfSize(15.0)}
    
    ///Height needed for all components of PostCell except postTextView in Storyboard
    class var additionalVertSpaceNeeded:CGFloat {return 88}
    
    class var buttonHeight:CGFloat{return 32}

}
