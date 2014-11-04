//
//  PostTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 10/31/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

class PostTableViewController: UITableViewController {

    // MARK: - Properties
    
    ///Post that is expanded in ViewController
    var post : Post
    
    ///Array that represents Comment tree in order
    var tree : [Comment] = []
    
    ///IndexPath of selected Comment
    var selectedPath : NSIndexPath?
    
    
    // MARK: - Initializers
    
    ///Mandatory initializer
    required init(coder aDecoder: NSCoder) {
        post = Post()
        super.init(coder: aDecoder)
    }
    
    
    // MARK: - UIViewController
    
    ///When View appears make the Post Comments into an array
    override func viewWillAppear(animated: Bool) {
        for comment in post.comments {
            makeCommentTreeIntoArray(comment)
        }
    }
    
    
    // MARK: - Constants
    
    ///Width of postTextView in PostCell
    var prototypeTextViewWidth:CGFloat {
        //margins are 16
        return tableView.frame.width - 16
    }
    

    // MARK: - UITableViewDataSource

    ///Only needs 1 section in tableView
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    ///Returns number of rows in tableView. This number is number of comments + 1 (the post)
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tree.count + 1
    }
    
    ///Creates PostCell with appropriate properties for Post at first row and CommentCell for each Comment in tree
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("Post", forIndexPath: indexPath) as PostCell
            
            cell.userLabel.text = post.user
            cell.profilePicView.image = post.picture
            cell.groupLabel.text = post.group
            cell.timeLabel.text = post.time
            
            cell.postTextView.text = post.text
            cell.postTextView.font = PostCell.textViewFont
            cell.postTextView.textContainer.lineFragmentPadding = 0
            cell.postTextView.textContainerInset = UIEdgeInsetsZero
            
            //tag acts as way for button to know it's position in data array
            cell.contentView.tag = indexPath.row //for gesture recognizer
            
            //Formats numbers on screen to say #.#k if necessary
            if post.numComments >= 1000 {
                cell.commentLabel.text = convertToThousands(post.numComments)
            } else {
                cell.commentLabel.text = String(post.numComments)
            }
            if post.rep >= 1000 || post.rep <= -1000 {
                cell.repLabel.text = convertToThousands(post.rep)
            } else {
                cell.repLabel.text = String(post.rep)
            }
            
            if let t = post.title {
                cell.titleLabel.text = t
            } else {
                cell.titleLabel.text = ""
                cell.titleHeightConstraint.constant = 0.0
            }
            
            //gets rid of small gap in divider
            cell.layoutMargins = UIEdgeInsetsZero
            cell.preservesSuperviewLayoutMargins = false
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("Comment", forIndexPath: indexPath) as CommentCell
            
            let comment = tree[indexPath.row - 1]
            cell.userLabel.text = comment.user
            if comment.lengthToPost > Comment.longestLengthToPost {
                let difference = comment.lengthToPost - Comment.longestLengthToPost
                for var i=0; i<difference; i++ {
                    cell.userLabel.text = "· \(cell.userLabel.text!)"
                }
            }
            cell.profilePicView.image = comment.picture
            cell.commentTextView.text = comment.text
            cell.commentTextView.font = CommentCell.textViewFont
            cell.commentTextView.textContainer.lineFragmentPadding = 0
            cell.commentTextView.textContainerInset = UIEdgeInsetsZero
            var repText = ""
            if comment.rep >= 1000 || comment.rep <= -1000 {
                repText = convertToThousands(comment.rep)
            } else {
                repText = String(comment.rep)
            }
            if comment.rep > 0 {
                repText = "+\(repText)"
            }
            if selectedPath == indexPath {
                cell.upvoteHeightConstraint.constant = CommentCell.buttonHeight
                cell.downvoteHeightConstraint.constant = CommentCell.buttonHeight
                cell.repAndTimeLabel.text = "\(repText) · \(comment.time)"
                for line in cell.lines {
                    line.removeFromSuperview()
                }
                cell.lines.removeAll()
            } else {
                cell.upvoteHeightConstraint.constant = 0.0
                cell.downvoteHeightConstraint.constant = 0.0
                cell.repAndTimeLabel.text = repText
            }
            
            //indents cell
            cell.imageIndentConstraint.constant = cell.getIndentationSize()
            cell.textIndentConstraint.constant = cell.getIndentationSize() + CommentCell.textViewDistanceToIndent
            
            //makes separator indented
            //UIEdgeInsetsMake(top, left, bottom, right)
            if indexPath.row != tree.count {
                if indexPath.row + 1 == selectedPath?.row {
                    cell.separatorInset = UIEdgeInsetsZero
                } else if cell.indentationLevel < tree[indexPath.row].predictedIndentLevel() {
                    cell.separatorInset = UIEdgeInsetsMake(0, cell.getIndentationSize(), 0, 0)
                } else {
                    cell.separatorInset = UIEdgeInsetsMake(0, tree[indexPath.row].predictedIndentSize(), 0, 0)
                }
            }
            
            //gets rid of small gap in divider
            cell.layoutMargins = UIEdgeInsetsZero
            cell.preservesSuperviewLayoutMargins = false
            
            //adds the vertical lines to the cells
            for var i=1; i<=cell.indentationLevel; i++ {
                var line = UIView(frame: CGRectMake(CGFloat(i)*CommentCell.indentSize, 0, 1, cell.frame.size.height))
                line.backgroundColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1.0)
                cell.lines.append(line)
                cell.contentView.addSubview(line)
            }
            
            return cell
        }
        
    }
    
    
    //MARK: - UITableViewDelegate
    
    ///Make height of cell appropriate size for settings
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return heightForTextOfRow(indexPath.row) + PostCell.additionalVertSpaceNeeded
        }
        if selectedPath == indexPath {
            return heightForTextOfRow(indexPath.row) + CommentCell.additionalVertSpaceNeeded
        } else {
            return heightForTextOfRow(indexPath.row) + CommentCell.additionalVertSpaceNeeded - CommentCell.buttonHeight
        }
    }
    
    ///Returns the indentationLevel for the indexPath. Cannot exceed 5 to keep cells from getting too small
    override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        if indexPath.row == 0 || indexPath == selectedPath {
            return 0
        } else {
            return tree[indexPath.row - 1].predictedIndentLevel()
        }
    }
    
    ///If a cell is selcted, update the selectedPath to update TableView properties (expand CommentCell to show menu)
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if selectedPath !== indexPath {
            selectedPath = indexPath
        } else {
            selectedPath = nil
        }
        tableView.reloadData()
    }
    
    
    //MARK: - Helper Functions

    ///Makes Comment tree into an array in pre-order
    func makeCommentTreeIntoArray(c: Comment) {
        tree.append(c)
        for child in c.comments {
            makeCommentTreeIntoArray(child)
        }
    }
    
    ///Calculates height of textView according to length of Post or Comment's text.
    func heightForTextOfRow(row: Int) -> CGFloat {
        if row == 0 {
            //creates a mock textView to calculate height with sizeToFit() function
            var textView = UITextView(frame: CGRectMake(0, 0, prototypeTextViewWidth, CGFloat.max))
            textView.text = post.text
            textView.textContainer.lineFragmentPadding = 0
            textView.textContainerInset = UIEdgeInsetsZero
            textView.font = PostCell.textViewFont
            textView.sizeToFit()
            
            return textView.frame.size.height
        } else {
            let comment = tree[row - 1]
            let indent = CGFloat(comment.lengthToPost - 1)
            let width = prototypeTextViewWidth - comment.predictedIndentSize() - CommentCell.textViewDistanceToIndent
            var textView = UITextView(frame: CGRectMake(0, 0, width, CGFloat.max))
            textView.text = comment.text
            textView.textContainer.lineFragmentPadding = 0
            textView.textContainerInset = UIEdgeInsetsZero
            textView.font = CommentCell.textViewFont
            textView.sizeToFit()
            
            return textView.frame.size.height
        }
    }
    
    ///Converts Int to formatted #.#k String
    func convertToThousands(number: Int) -> String {
        var thousands : Double = Double(number / 1000)
        if thousands < 0 {
            thousands -= Double(number % 1000 / 100) * 0.1
        } else {
            thousands += Double(number % 1000 / 100) * 0.1
        }
        return "\(thousands)k"
    }
}
