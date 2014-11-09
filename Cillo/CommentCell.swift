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
    class var TEXT_VIEW_FONT:UIFont {return UIFont.systemFontOfSize(15.0)}
    
    ///Height needed for all components of PostCell except postTextView in Storyboard
    class var ADDITIONAL_VERT_SPACE_NEEDED:CGFloat {return 88}
    
    ///Height of buttons in expanded menu when CommentCell is selected
    class var BUTTON_HEIGHT:CGFloat{return 32}
    
    ///Distance of commentTextView to right boundary of contentView. Used to align textView with userLabel when cell is indented
    class var TEXT_VIEW_DISTANCE_TO_INDENT: CGFloat{return 32}
    
    ///Width of indent of indented Comments
    class var INDENT_SIZE:CGFloat {return 30}
    
    
    //MARK: - Helper Methods
    
    ///Returns true indent size for cell with current indentationLevel
    func getIndentationSize() -> CGFloat {
        return CGFloat(indentationLevel) * CommentCell.INDENT_SIZE
    }
    
    func makeStandardCommentCellFromComment(comment: Comment, forIndexPath indexPath: NSIndexPath, withSelected selected: Bool) {
        userLabel.text = comment.user
        //add dots if CommentCell has reached max indent and cannot be indented more
        if comment.lengthToPost > Comment.LONGEST_LENGTH_TO_POST {
            let difference = comment.lengthToPost - Comment.LONGEST_LENGTH_TO_POST
            for var i=0; i<difference; i++ {
               userLabel.text = "· \(userLabel.text!)"
            }
        }
        
        profilePicView.image = comment.picture
        commentTextView.text = comment.text
        commentTextView.font = CommentCell.TEXT_VIEW_FONT
        commentTextView.textContainer.lineFragmentPadding = 0
        commentTextView.textContainerInset = UIEdgeInsetsZero
        var repText = ""
        if comment.rep >= 1000 || comment.rep <= -1000 {
            repText = Format.convertToThousands(comment.rep)
        } else {
            repText = String(comment.rep)
        }
        if comment.rep > 0 {
            repText = "+\(repText)"
        }
        if selected {
            //Show button bar when selected
            upvoteHeightConstraint.constant = CommentCell.BUTTON_HEIGHT
            downvoteHeightConstraint.constant = CommentCell.BUTTON_HEIGHT
            //Selected CommentCells show time next to rep
            repAndTimeLabel.text = "\(repText) · \(comment.time)"
            //Selected CommentCells need to clear vertical lines from the cell in order to expand cell
            for line in lines {
                line.removeFromSuperview()
            }
            lines.removeAll()
        } else {
            //hide button bar when not selected
            upvoteHeightConstraint.constant = 0.0
            downvoteHeightConstraint.constant = 0.0
            repAndTimeLabel.text = repText
        }
        
        //indents cell
        imageIndentConstraint.constant = getIndentationSize()
        textIndentConstraint.constant = getIndentationSize() + CommentCell.TEXT_VIEW_DISTANCE_TO_INDENT
        
        //gets rid of small gap in divider
        layoutMargins = UIEdgeInsetsZero
        preservesSuperviewLayoutMargins = false
        
        //adds the vertical lines to the cells
        for var i=1; i<=indentationLevel; i++ {
            var line = UIView(frame: CGRectMake(CGFloat(i)*CommentCell.INDENT_SIZE, 0, 1, frame.size.height))
            line.backgroundColor = Format.defaultTableViewDividerColor()
            lines.append(line)
            contentView.addSubview(line)
        }
    }

}