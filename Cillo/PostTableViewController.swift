//
//  PostTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 10/31/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

class PostTableViewController: UITableViewController {

    required init(coder aDecoder: NSCoder) {
        post = Post()
        super.init(coder: aDecoder)
    }

    var post : Post
    var tree : [Comment] = []
    var selectedPath : NSIndexPath?
    
    override func viewDidLoad() {
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
    
    var indentSize:CGFloat {
        return 50
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tree.count + 1
    }
    
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
            if post.rep >= 1000 {
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
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("Comment", forIndexPath: indexPath) as CommentCell
            
            let comment = tree[indexPath.row - 1]
            cell.userLabel.text = comment.user
            cell.profilePicView.image = comment.picture
            cell.commentTextView.text = comment.text
            cell.commentTextView.font = CommentCell.textViewFont
            cell.commentTextView.textContainer.lineFragmentPadding = 0
            cell.commentTextView.textContainerInset = UIEdgeInsetsZero
            var repText = ""
            if comment.rep >= 1000 {
                repText = convertToThousands(comment.rep)
            } else {
                repText = String(comment.rep)
            }
            if selectedPath == indexPath {
                cell.upvoteHeightConstraint.constant = CommentCell.buttonHeight
                cell.downvoteHeightConstraint.constant = CommentCell.buttonHeight
                cell.repAndTimeLabel.text = "\(repText) o \(comment.time)"
            } else {
                cell.upvoteHeightConstraint.constant = 0.0
                cell.downvoteHeightConstraint.constant = 0.0
                cell.repAndTimeLabel.text = repText
            }
            cell.indentationWidth = indentSize
            return cell
        }
        
    }
    
    
    //MARK - Table View Delegate
    
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
    
    override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        if indexPath.row == 0 {
            return 0
        } else {
            return tree[indexPath.row - 1].lengthToPost - 1
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if selectedPath !== indexPath {
            selectedPath = indexPath
        } else {
            selectedPath = nil
        }
        tableView.reloadData()
    }
    
    
    //MARK - Helper Functions

    func makeCommentTreeIntoArray(c: Comment) {
        tree.append(c)
        for child in c.comments {
            return makeCommentTreeIntoArray(child)
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
            let width = prototypeTextViewWidth - indentSize * indent
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
        thousands += Double(number % 1000 / 100) * 0.1
        return "\(thousands)k"
    }
}
