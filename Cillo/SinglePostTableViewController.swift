//
//  SinglePostTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 1/3/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Inherit this class for any UITableViewController that is a UserCell followed by PostCells and CommentCells.
class SinglePostTableViewController: UITableViewController {
  
  // MARK: Properties
  
  /// Post that is shown in this UITableViewController.
  var post: Post = Post()
  
  /// Comment tree corresponding to post.
  var commentTree: [Comment] = []
  
  /// Index path of a selected Comment in tableView.
  /// 
  /// Note: Selected CommentCells are expanded to display additional user interaction options.
  ///
  /// Nil if no CommentCell is selected.
  var selectedPath : NSIndexPath?
  
  // MARK: UITableViewDataSource
  
  // Assigns 1 section in this UITableViewController.
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  // Assigns (# comments + post) rows to each section in this UITableViewController.
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return commentTree.count + 1
  }
  
  // Creates PostCell if row number is zero and CommentCell based on row number of indexPath.
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.row == 0 { // Make a Post Cell for only first row
      let cell = tableView.dequeueReusableCellWithIdentifier(PostCell.ReuseIdentifier, forIndexPath: indexPath) as PostCell
      
      cell.makeCellFromPost(post, withButtonTag: indexPath.row)
      
      return cell
    } else { // Make a CommentCell for all rows past the first row
      let cell = tableView.dequeueReusableCellWithIdentifier(CommentCell.ReuseIdentifier, forIndexPath: indexPath) as CommentCell
      
      let comment = commentTree[indexPath.row - 1] // indexPath.row - 1 b/c Post is not included in tree
      
      cell.makeCellFromComment(comment, withSelected: selectedPath == indexPath)
      
      // Makes separator indented
      // UIEdgeInsetsMake(top, left, bottom, right)
      if indexPath.row != commentTree.count {
        if indexPath.row + 1 == selectedPath?.row {
          cell.separatorInset = UIEdgeInsetsZero
        } else if cell.indentationLevel < commentTree[indexPath.row].predictedIndentLevel(selected: false) {
          cell.separatorInset = UIEdgeInsetsMake(0, cell.getIndentationSize(), 0, 0)
        } else {
          cell.separatorInset = UIEdgeInsetsMake(0, commentTree[indexPath.row].predictedIndentSize(selected: false), 0, 0)
        }
      }
      
      return cell
    }
    
  }
  
  // MARK: UITableViewDelegate
  
  // Sets height of cell to appropriate value.
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.row == 0 { // PostCell
      let heightWithTitle = post.heightOfPostWithWidth(PrototypeTextViewWidth, andMaxContractedHeight: nil) + PostCell.AdditionalVertSpaceNeeded
      return post.title != nil ? heightWithTitle : heightWithTitle - PostCell.TitleHeight
    }
    // is a CommentCell
    let height = commentTree[indexPath.row - 1].heightOfCommentWithWidth(PrototypeTextViewWidth, selected: selectedPath == indexPath) + CommentCell.AdditionalVertSpaceNeeded
    return selectedPath == indexPath ? height : height - CommentCell.ButtonHeight
  }
  
  // Returns the indentationLevel for the indexPath.
  //
  // Note: Cannot exceed 5 to keep cells from getting too small
  override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
    return indexPath.row == 0 ? 0 : commentTree[indexPath.row - 1].predictedIndentLevel(selected: indexPath == selectedPath)
  }
  
  // Updates selectedPath when a new cell is selected.
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if selectedPath !== indexPath {
      selectedPath = indexPath
    } else {
      selectedPath = nil
    }
    tableView.reloadData()
  }

}
