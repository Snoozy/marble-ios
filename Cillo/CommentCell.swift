//
//  CommentCell.swift
//  Cillo
//
//  Created by Andrew Daley on 11/3/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

///Cell that corresponds to reuse identifier "Comment". Used to format Comments in UITableView.
class CommentCell: UITableViewCell {

    //MARK: - Properties
    
    ///An array that stores vertical lines for formating indents in a Comment tree. This array should be empty is there is no indent for CommentCell
    var lines: [UIView] = []
    
    
    //MARK: - IBOutlets
    
    ///Corresponds to user of Comment
    @IBOutlet weak var userLabel: UILabel!
    
    ///Corresponds to picture of Comment
    @IBOutlet weak var profilePicView: UIImageView!
    
    ///Corresponds to text of Comment
    @IBOutlet weak var commentTextView: UITextView!
    
    ///Corresponds to rep and time of Comment
    @IBOutlet weak var repAndTimeLabel: UILabel!
    
    ///Set to 0 when not selected and BUTTON_HEIGHT when selected
    @IBOutlet weak var upvoteHeightConstraint: NSLayoutConstraint!
    
    ///Set to 0 when not selected and BUTTON_HEIGHT when selected
    @IBOutlet weak var downvoteHeightConstraint: NSLayoutConstraint!
    
    ///Set to this cell's indent size
    @IBOutlet weak var imageIndentConstraint: NSLayoutConstraint!
    
    ///Set to this cell's indent size
    @IBOutlet weak var textIndentConstraint: NSLayoutConstraint!
    
    
    //MARK: - Constants
    
    ///Font of commentTextView
    class var COMMENT_TEXT_VIEW_FONT : UIFont {return UIFont.systemFontOfSize(15.0)}
    
    ///Height needed for all components of CommentCell except commentTextView in Storyboard
    class var ADDITIONAL_VERT_SPACE_NEEDED : CGFloat {return 89}
    
    ///Height of buttons in expanded menu when CommentCell is selected
    class var BUTTON_HEIGHT : CGFloat {return 32}
    
    ///Distance of commentTextView to right boundary of contentView. Used to align textView with userLabel when cell is indented
    class var TEXT_VIEW_DISTANCE_TO_INDENT : CGFloat {return 32}
    
    ///Width of indent of indented Comments
    class var INDENT_SIZE : CGFloat {return 30}
    
    ///Reuse Identifier for this UITableViewCell
    class var REUSE_IDENTIFIER : String {return "Comment"}
    
    
    //MARK: - Helper Methods
    
    ///Returns true indent size for cell with current indentationLevel
    func getIndentationSize() -> CGFloat {
        return CGFloat(indentationLevel) * CommentCell.INDENT_SIZE
    }
    
    ///Makes this CommentCell formatted in accordance with comment and selected
    func makeCellFromComment(comment: Comment, withSelected selected: Bool) {
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
        commentTextView.font = CommentCell.COMMENT_TEXT_VIEW_FONT
        commentTextView.textContainer.lineFragmentPadding = 0
        commentTextView.textContainerInset = UIEdgeInsetsZero
        var repText = String.formatNumberAsString(comment.rep)
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
            line.backgroundColor = UIColor.defaultTableViewDividerColor()
            lines.append(line)
            contentView.addSubview(line)
        }
    }

}
