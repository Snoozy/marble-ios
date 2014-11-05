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

    //MARK: - Properties
    
    ///An array that stores vertical lines for formating indents. This array should be empty is there is no indent for CommentCell
    var lines: [UIView] = []
    
    //MARK: - IBOutlets
    
    ///All IBOutlets correspond to properties of Comment. See Comment for definitions of properties
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var repAndTimeLabel: UILabel!
    
    ///Will be set to 0 when not selected and 32 when selected
    @IBOutlet weak var upvoteHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var downvoteHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageIndentConstraint: NSLayoutConstraint!
    @IBOutlet weak var textIndentConstraint: NSLayoutConstraint!
    
    
    //MARK: - Constants
    
    ///Font of postTextView in Storyboard
    class var textViewFont:UIFont {return UIFont.systemFontOfSize(15.0)}
    
    ///Height needed for all components of PostCell except postTextView in Storyboard
    class var additionalVertSpaceNeeded:CGFloat {return 88}
    
    ///Height of buttons in expanded menu when CommentCell is selected
    class var buttonHeight:CGFloat{return 32}
    
    ///Distance of commentTextView to right boundary of contentView. Used to align textView with userLabel when cell is indented
    class var textViewDistanceToIndent: CGFloat{return 32}
    
    ///Width of indent of indented Comments
    class var indentSize:CGFloat {
        return 30
    }
    
    
    //MARK: - Helper Methods
    
    ///Returns true indent size for cell with current indentationLevel
    func getIndentationSize() -> CGFloat {
        return CGFloat(indentationLevel) * CommentCell.indentSize
    }

}
