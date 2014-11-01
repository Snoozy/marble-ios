//
//  PostCell.swift
//  Cillo
//
//  Created by Andrew Daley on 10/23/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

///Cell that corresponds to reuse identifier "Post". Used in HomeTableViewController to format Posts in TableView.
class PostCell: UITableViewCell {

    //********** Outlets **********
    
    ///All IBOutlets correspond to properties of Post. See Post for definitions of properties
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var repLabel: UILabel!
    @IBOutlet weak var seeFullButton: UIButton!
    
    ///Constraint will be set to 0 if there is no title for Post
    @IBOutlet weak var titleHeightConstraint: NSLayoutConstraint!
    
    
    //********** Constants **********
    
    ///Font of postTextView in Storyboard
    class var textViewFont:UIFont {return UIFont.systemFontOfSize(15.0)}
    
    ///Height needed for all components of PostCell except postTextView in Storyboard
    class var additionalVertSpaceNeeded:CGFloat {return 139}
    
    ///Height of titleLabel in StoryBoard
    class var titleHeight:CGFloat {return 26.5}

}
