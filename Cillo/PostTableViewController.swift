//
//  PostTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 10/31/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

///Handles view of expanded Post with Comments beneath it. Formats TableView to look appealing and be functional.
class PostTableViewController: UITableViewController {

    //MARK: - Properties
    
    ///Post that is expanded in ViewController
    var post : Post = Post()
    
    ///Array that represents Comment tree in pre-order listing
    var tree : [Comment] = []
    
    ///NSIndexPath of selected Comment in tableView
    var selectedPath : NSIndexPath?
    
    
    //MARK: - Constants
    
    ///Width of postTextView in PostCell
    var PROTOTYPE_TEXT_VIEW_WIDTH:CGFloat {
        //margins are 16
        return tableView.frame.width - 16
    }
    
    
    //MARK: - UIViewController
    
    //Stores comments of post in tree
    override func viewWillAppear(animated: Bool) {
        for comment in post.comments {
            makeCommentTreeIntoArray(comment)
        }
    }
    

    //MARK: - UITableViewDataSource

    //1 section in tableView
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    //Assigns (# comments + post) rows to tableView
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tree.count + 1
    }
    
    //Creates PostCell with appropriate properties for Post at first row and CommentCell for each Comment in tree
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 { //Make a Post Cell for only first row
            let cell = tableView.dequeueReusableCellWithIdentifier("Post", forIndexPath: indexPath) as PostCell
            
            cell.makeExpandedPostCellFromPost(post, forIndexPath: indexPath)
            
            return cell
        } else { //Make a CommentCell for all rows past the first row
            let cell = tableView.dequeueReusableCellWithIdentifier("Comment", forIndexPath: indexPath) as CommentCell
            
            let comment = tree[indexPath.row - 1] //indexPath.row - 1 b/c Post is not included in tree
            
            cell.makeStandardCommentCellFromComment(comment, forIndexPath: indexPath, withSelected: selectedPath == indexPath)
            
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
            
            return cell
        }
        
    }
    
    
    //MARK: - UITableViewDelegate
    
    //Make height of cell appropriate size for settings
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 { //PostCell
            let heightWithTitle = post.heightOfPostWithWidth(PROTOTYPE_TEXT_VIEW_WIDTH, andMaxContractedHeight: nil) + PostCell.ADDITIONAL_VERT_SPACE_NEEDED
            return post.title != nil ? heightWithTitle : heightWithTitle - PostCell.TITLE_HEIGHT
        }
        //is a CommentCell
        let height = tree[indexPath.row - 1].heightOfCommentWithWidth(PROTOTYPE_TEXT_VIEW_WIDTH, withSelected: selectedPath == indexPath) + CommentCell.ADDITIONAL_VERT_SPACE_NEEDED
        return selectedPath == indexPath ? height : height - CommentCell.BUTTON_HEIGHT
    }
    
    //Returns the indentationLevel for the indexPath. Cannot exceed 5 to keep cells from getting too small
    override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        if indexPath.row == 0 || indexPath == selectedPath {
            return 0
        } else {
            return tree[indexPath.row - 1].predictedIndentLevel()
        }
    }
    
    //Updates selectedPath
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
    
}
