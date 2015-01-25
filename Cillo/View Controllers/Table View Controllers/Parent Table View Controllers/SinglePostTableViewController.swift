//
//  SinglePostTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 1/3/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Inherit this class for any UITableViewController that is a UserCell followed by PostCells and CommentCells.
///
/// **Note:** Subclasses must override SegueIdentifierThisToGroup and SegueIdentifierThisToUser.
class SinglePostTableViewController: CustomTableViewController {
  
  // MARK: Properties
  
  /// Post that is shown in this UITableViewController.
  var post: Post = Post()
  
  /// Comment tree corresponding to post.
  var commentTree: [Comment] = []
  
  /// Index path of a selected Comment in tableView.
  /// 
  /// **Note:** Selected CommentCells are expanded to display additional user interaction options.
  ///
  /// Nil if no CommentCell is selected.
  var selectedPath : NSIndexPath?
  
  // MARK: Constants
  
  /// Segue Identifier in Storyboard for this UITableViewController to GroupTableViewController.
  ///
  /// **Note:** Subclasses must override this Constant.
  var SegueIdentifierThisToGroup: String {
    get {
      return ""
    }
  }
  
  /// Segue Identifier in Storyboard for this UITableViewController to UserTableViewController.
  ///
  /// **Note:** Subclasses must override this Constant.
  var SegueIdentifierThisToUser: String {
    get {
      return ""
    }
  }
  
  // MARK: UIViewController
  
  /// Handles passing of data when navigation between UIViewControllers occur.
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == SegueIdentifierThisToGroup {
      var destination = segue.destinationViewController as GroupTableViewController
      destination.group = post.group
    } else if segue.identifier == SegueIdentifierThisToUser {
      var destination = segue.destinationViewController as UserTableViewController
      if let sender = sender as? UIButton {
        destination.user = commentTree[sender.tag].user
      }
    }
  }
  
  // MARK: UITableViewDataSource
  
  /// Assigns 2 sections in this UITableViewController.
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
  
  /// Assigns the number of rows in tableView based on the size of the commentTree.
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return section == 0 ? 1 : commentTree.count
  }
  
  /// Creates PostCell if row number is zero and CommentCell based on row number of indexPath.
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.section == 0 { // Make a Post Cell for only first section
      let cell = tableView.dequeueReusableCellWithIdentifier(PostCell.ReuseIdentifier, forIndexPath: indexPath) as PostCell
      
      cell.makeCellFromPost(post, withButtonTag: indexPath.row)
      
      return cell
    } else { // Make a CommentCell for all rows past the first section
      let cell = tableView.dequeueReusableCellWithIdentifier(CommentCell.ReuseIdentifier, forIndexPath: indexPath) as CommentCell
      
      let comment = commentTree[indexPath.row] // indexPath.row - 1 b/c Post is not included in tree
      
      cell.makeCellFromComment(comment, withSelected: selectedPath == indexPath, andButtonTag: indexPath.row)
      
      // Makes separator indented
      // UIEdgeInsetsMake(top, left, bottom, right)
      if indexPath.row != commentTree.count - 1 {
        if indexPath.row + 1 == selectedPath?.row {
          cell.separatorInset = UIEdgeInsetsZero
        } else if cell.indentationLevel < commentTree[indexPath.row].predictedIndentLevel(selected: false) {
          cell.separatorInset = UIEdgeInsetsMake(0, cell.getIndentationSize(), 0, 0)
        } else {
          cell.separatorInset = UIEdgeInsetsMake(0, commentTree[indexPath.row + 1].predictedIndentSize(selected: false), 0, 0)
        }
      }
      
      return cell
    }
    
  }
  
  // MARK: UITableViewDelegate
  
  /// Sets height of cell to appropriate value.
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.section == 0 { // PostCell
      let heightWithTitle = post.heightOfPostWithWidth(PrototypeTextViewWidth, andMaxContractedHeight: nil) + PostCell.AdditionalVertSpaceNeeded
      return post.title != nil ? heightWithTitle : heightWithTitle - PostCell.TitleHeight
    }
    // is a CommentCell
    let height = commentTree[indexPath.row].heightOfCommentWithWidth(PrototypeTextViewWidth, selected: selectedPath == indexPath) + CommentCell.AdditionalVertSpaceNeeded
    return selectedPath == indexPath ? height : height - CommentCell.ButtonHeight
  }
  
  /// Returns the indentationLevel for the indexPath.
  ///
  /// **Note:** Cannot exceed 5 to keep cells from getting too small
  override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
    return indexPath.section == 0 ? 0 : commentTree[indexPath.row].predictedIndentLevel(selected: indexPath == selectedPath)
  }
  
  /// Updates selectedPath when a new cell is selected.
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if selectedPath !== indexPath {
      selectedPath = indexPath
    } else {
      selectedPath = nil
    }
    tableView.reloadData()
  }
  
  // MARK: Helper Functions
  
  /// Sends create post request to Cillo Servers for post.
  ///
  /// **Note:** Create post is used to repost posts when given a repostID parameter.
  ///
  /// :param: groupName The name of the group that the specified post is being reposted to.
  /// :param: completion The completion block for the repost.
  /// :param: success True if repost request was successful. If error was received, it is false.
  func repostPostToGroup(groupName: String, completion: (success: Bool) -> Void) {
    var id = 0
    if let post = post as? Repost {
      id = post.originalPostID
    } else {
      id = post.postID
    }
    DataManager.sharedInstance.createPostByGroupName(groupName, repostID: id, text: post.text, title: post.title, completion: { (error, repost) -> Void in
      if error != nil {
        println(error!)
        error!.showAlert()
        completion(success: false)
      } else {
        completion(success: repost != nil)
      }
    })
  }
  
  /// Sends upvote request to Cillo Servers for the post that this UIViewController is representing.
  ///
  /// :param: completion The completion block for the upvote.
  /// :param: success True if upvote request was successful. If error was received, it is false.
  func upvotePost(completion: (success: Bool) -> Void) {
    DataManager.sharedInstance.postUpvote(post.postID, completion: { (error, success) -> Void in
      if error != nil {
        println(error!)
        error!.showAlert()
        completion(success: false)
      } else {
        if success {
          completion(success: true)
        }
      }
    })
  }
  
  /// Sends downvote request to Cillo Servers for the post that this UIViewController is representing.
  ///
  /// :param: completion The completion block for the upvote.
  /// :param: success True if downvote request was successful. If error was received, it is false.
  func downvotePost(completion: (success: Bool) -> Void) {
    DataManager.sharedInstance.postDownvote(post.postID, completion: { (error, success) -> Void in
      if error != nil {
        println(error!)
        error!.showAlert()
        completion(success: false)
      } else {
        if success {
          completion(success: true)
        }
      }
    })
  }
  
  /// Sends upvote request to Cillo Servers for the comment at the specified index in commentTree.
  ///
  /// :param: index The index of the comment being upvoted in the commentTree array.
  /// :param: completion The completion block for the upvote.
  /// :param: success True if upvote request was successful. If error was received, it is false.
  func upvoteCommentAtIndex(index: Int, completion: (success: Bool) -> Void) {
    DataManager.sharedInstance.commentUpvote(commentTree[index].commentID, completion: { (error, success) -> Void in
      if error != nil {
        println(error!)
        error!.showAlert()
        completion(success: false)
      } else {
        if success {
          completion(success: true)
        }
      }
    })
  }
  
  /// Sends downvote request to Cillo Servers for the comment at the specified index in commentTree.
  ///
  /// :param: index The index of the comment being downvoted in the commentTree array.
  /// :param: completion The completion block for the downvote.
  /// :param: success True if downvote request was successful. If error was received, it is false.
  func downvoteCommentAtIndex(index: Int, completion: (success: Bool) -> Void) {
    DataManager.sharedInstance.commentDownvote(commentTree[index].commentID, completion: { (error, success) -> Void in
      if error != nil {
        println(error!)
        error!.showAlert()
        completion(success: false)
      } else {
        if success {
          completion(success: true)
        }
      }
    })
  }

  // MARK: IBActions
  
  /// Triggers segue to UserTableViewController.
  ///
  /// :param: sender The button that is touched to send this function is a nameButton or a pictureButton in a PostCell or a CommentCell.
  @IBAction func triggerUserSegueOnButton(sender: UIButton) {
    self.performSegueWithIdentifier(SegueIdentifierThisToUser, sender: sender)
  }
  
  /// Triggers segue to GroupTableViewController.
  ///
  /// :param: sender The button that is touched to send this function is a groupButton in a PostCell or an originalGroupButton in a RepostCell.
  @IBAction func triggerGroupSegueOnButton(sender: UIButton) {
    self.performSegueWithIdentifier(SegueIdentifierThisToGroup, sender: sender)
  }
  
  /// Reposts a post.
  ///
  /// :param: sender The button that is touched to send this function is a repostButton in a PostCell.
  @IBAction func repostPressed(sender: UIButton) {
    let alert = UIAlertController(title: "Repost", message: "Which group are you reposting this post to?", preferredStyle: .Alert)
    let repostAction = UIAlertAction(title: "Repost", style: .Default, handler: { (action) in
      let groupName = alert.textFields![0].text
      self.repostPostToGroup(groupName, completion: { (success) in
        if (success) {
          let repostSuccessfulAlert = UIAlertController(title: "Repost Successful", message: "Reposted to \(groupName)", preferredStyle: .Alert)
          let okAction = UIAlertAction(title: "Ok", style: .Cancel, handler: { (action) in
          })
          repostSuccessfulAlert.addAction(okAction)
          self.presentViewController(repostSuccessfulAlert, animated: true, completion: nil)
        }
      })
    })
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
    })
    alert.addTextFieldWithConfigurationHandler( { (textField) in
      textField.placeholder = "Group Name"
    })
    alert.addAction(cancelAction)
    alert.addAction(repostAction)
    presentViewController(alert, animated: true, completion: nil)
  }
  
  /// Upvotes a post.
  ///
  /// :param: sender The button that is touched to send this function is a upvoteButton in a PostCell.
  @IBAction func upvotePostPressed(sender: UIButton) {
    if post.voteValue != 1 {
      upvotePost( { (success) -> Void in
        if success {
          if self.post.voteValue == 0 {
            self.post.rep++
          } else if self.post.voteValue == -1 {
            self.post.rep += 2
          }
          self.post.voteValue = 1
          let postIndexPath = NSIndexPath(forRow: 0, inSection: 0)
          self.tableView.reloadRowsAtIndexPaths([postIndexPath], withRowAnimation: .None)
        }
      })
    }
  }
  
  /// Downvotes a post.
  ///
  /// :param: sender The button that is touched to send this function is a downvoteButton in a PostCell.
  @IBAction func downvotePostPressed(sender: UIButton) {
    if post.voteValue != -1 {
      downvotePost( { (success) -> Void in
        if success {
          if self.post.voteValue == 0 {
            self.post.rep--
          } else if self.post.voteValue == 1 {
            self.post.rep -= 2
          }
          self.post.voteValue = -1
          let postIndexPath = NSIndexPath(forRow: 0, inSection: 0)
          self.tableView.reloadRowsAtIndexPaths([postIndexPath], withRowAnimation: .None)
        }
      })
    }
  }
  
  /// Upvotes a comment.
  ///
  /// :param: sender The button that is touched to send this function is a upvtoeButton in a CommentCell.
  @IBAction func upvoteCommentPressed(sender: UIButton) {
    let comment = commentTree[sender.tag]
    if comment.voteValue != 1 {
      upvoteCommentAtIndex(sender.tag, completion: { (success) -> Void in
        if success {
          if comment.voteValue == 0 {
            comment.rep++
          } else if comment.voteValue == -1 {
            comment.rep += 2
          }
          comment.voteValue = 1
          let commentIndexPath = NSIndexPath(forRow: sender.tag, inSection: 1)
          self.tableView.reloadRowsAtIndexPaths([commentIndexPath], withRowAnimation: .None)
        }
      })
    }
  }
  
  /// Downvotes a comment.
  ///
  /// :param: sender The button that is touched to send this function is a downvoteButton in a CommentCell.
  @IBAction func downvoteCommentPressed(sender: UIButton) {
    let comment = commentTree[sender.tag]
    if comment.voteValue != -1 {
      downvoteCommentAtIndex(sender.tag, completion: { (success) -> Void in
        if success {
          if comment.voteValue == 0 {
            comment.rep--
          } else if comment.voteValue == 1 {
            comment.rep -= 2
          }
          comment.voteValue = -1
          let commentIndexPath = NSIndexPath(forRow: sender.tag, inSection: 1)
          self.tableView.reloadRowsAtIndexPaths([commentIndexPath], withRowAnimation: .None)
        }
      })
    }
  }
  
}
