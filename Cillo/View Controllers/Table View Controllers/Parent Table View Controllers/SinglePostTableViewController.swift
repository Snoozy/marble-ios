//
//  SinglePostTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 1/3/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Inherit this class for any UITableViewController that is a PostCell followed by a comment tree of CommentCells.
///
/// **Note:** Subclasses must override segueIdentifierThisToBoard and segueIdentifierThisToUser.
class SinglePostTableViewController: CustomTableViewController {
  
  // MARK: Properties
  
  /// Comment tree corresponding to `post`.
  var commentTree = [Comment]()
  
  /// Flag that is only false when comments have not attempted to be retrieved yet.
  var commentsRetrieved = false
  
  /// The `showImages` value of the post in the view controller under this view controller in the navigation stack.
  var mainShowImages = false
  
  /// Post that is represented by this view controller.
  var post = Post() {
    didSet {
      post.showImages = true
      if let post = post as? Repost {
        post.originalPost.showImages = true
      }
    }
  }
  
  /// Index path of a selected Comment in tableView.
  /// 
  /// **Note:** Selected CommentCells are expanded to display additional user interaction options.
  ///
  /// Nil if no CommentCell is selected.
  var selectedPath: NSIndexPath?
  
  // MARK: Constants
  
  /// The height on screen of the cells containing only single labels
  var heightOfSingleLabelCells: CGFloat {
    return 40.0
  }
  
  /// Tag of all buttons in the PostCell representing `post`
  let postCellTag = 1000000
  
  /// Segue Identifier in Storyboard for segue to BoardTableViewController.
  ///
  /// **Note:** Subclasses must override this Constant.
  var segueIdentifierThisToBoard: String {
    fatalError("Subclasses of SinglePostTableViewController must override segue identifiers")
  }
  
  /// Segue Identifier in Storyboard for segue to UserTableViewController.
  ///
  /// **Note:** Subclasses must override this Constant.
  var segueIdentifierThisToUser: String {
    fatalError("Subclasses of SinglePostTableViewController must override segue identifiers")
  }
  
  // MARK: UIViewController
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == segueIdentifierThisToBoard {
      var destination = segue.destinationViewController as! BoardTableViewController
      if let post = post as? Repost, sender = sender as? UIButton where sender.tag == postCellTag + RepostCell.tagModifier {
            destination.board = post.originalPost.board
      } else {
        destination.board = post.board
      }
    } else if segue.identifier == segueIdentifierThisToUser {
      var destination = segue.destinationViewController as! UserTableViewController
      if let sender = sender as? UIButton {
        if sender.tag >= postCellTag {
          if let post = post as? Repost where sender.tag == postCellTag + RepostCell.tagModifier {
              destination.user = post.originalPost.user
          } else {
            destination.user = post.user
          }
        } else {
          destination.user = commentTree[sender.tag].user
        }
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // removes extraneous dividers
    tableView.tableFooterView = UIView(frame: CGRect.zeroRect)
    // gets rid of small gap in divider
    if tableView.respondsToSelector("setSeparatorInset:") {
      tableView.separatorInset = UIEdgeInsetsZero
    }
    if tableView.respondsToSelector("setLayoutMargins:") {
      tableView.layoutMargins = UIEdgeInsetsZero
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    post.showImages = mainShowImages
    if let post = post as? Repost {
      post.originalPost.showImages = mainShowImages
    }
  }
  
  // MARK: UITableViewDataSource
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // Placing the PostCell in the first section and the comment tree in the second section.
    return 2
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      return dequeueAndSetupPostCellForIndexPath(indexPath)
    } else if !commentsRetrieved {
      return dequeueAndSetupRetrievingCommentsCellForIndexPath(indexPath)
    } else if commentTree.count == 0 {
      return dequeueAndSetupNoCommentsCellForIndexPath(indexPath)
    } else {
      return dequeueAndSetupCommentCellForIndexPath(indexPath)
    }
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 || !commentsRetrieved || commentTree.count == 0 {
      return 1
    } else {
      return commentTree.count
    }
  }
  
  // MARK: UITableViewDelegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
    if selectedPath != indexPath {
      selectedPath = indexPath
      tableView.reloadData()
    } else {
      selectedPath = nil
      tableView.reloadData()
    }
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.section == 0 {
      return PostCell.heightOfPostCellForPost(post, withElementWidth: tableViewWidthWithMargins, maxContractedHeight: nil, andDividerHeight: 0)
    } else if !commentsRetrieved || commentTree.count == 0 {
      return heightOfSingleLabelCells
    } else {
      return CommentCell.heightOfCommentCellForComment(commentTree[indexPath.row], withElementWidth: tableViewWidthWithMargins, selectedState: selectedPath == indexPath, andDividerHeight: 0)
    }
  }
  
  override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
    if indexPath.section == 0 || !commentsRetrieved || commentTree.count == 0 {
      return 0
    } else {
      return commentTree[indexPath.row].predictedIndentLevel(selected: indexPath == selectedPath)
    }
  }
  
  // MARK: Setup Helper Functions
  
  /// Makes a CommentCell for the corresponding comment in `commentTree` based on the passed indexPath.
  ///
  /// :param: indexPath The index path of the cell to be created in the table view.
  ///
  /// :returns: The created CommentCell.
  func dequeueAndSetupCommentCellForIndexPath(indexPath: NSIndexPath) -> CommentCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.commentCell, forIndexPath: indexPath) as! CommentCell
    let comment = commentTree[indexPath.row]
    comment.post = post
    cell.makeCellFromComment(comment, withSelected: selectedPath == indexPath, andButtonTag: indexPath.row)
    cell.assignDelegatesForCellTo(self)
    
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
  
  /// Makes a single label UITableViewCell that says "No comments..."
  ///
  /// :param: indexPath The index path of the cell to be created in the table view.
  ///
  /// :returns: The created NoCommentsCell.
  func dequeueAndSetupNoCommentsCellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.noCommentsCell, forIndexPath: indexPath) as! UITableViewCell
    cell.separatorInset = UIEdgeInsets(top: 0, left: cell.frame.size.width, bottom: 0, right: 0)
    return cell
  }
  
  /// Makes a PostCell for `post`.
  ///
  /// If the post is a Repost, the returned PostCell will be a RepostCell.
  ///
  /// :param: indexPath The index path of the cell to be created in the table view.
  ///
  /// :returns: The created PostCell.
  func dequeueAndSetupPostCellForIndexPath(indexPath: NSIndexPath) -> PostCell {
    var cell: PostCell
    if let post = post as? Repost {
      cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.repostCell, forIndexPath: indexPath) as! RepostCell
    } else {
      cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.postCell, forIndexPath: indexPath) as! PostCell
    }
    cell.makeCellFromPost(post, withButtonTag: indexPath.row)
    cell.assignDelegatesForCellTo(self)
    return cell
  }
  
  /// Makes a single label UITableViewCell that says "Retrieving Comments..."
  ///
  /// :param: indexPath The index path of the cell to be created in the table view.
  ///
  /// :returns: The created RetrieivingCommentsCell.
  func dequeueAndSetupRetrievingCommentsCellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.retrievingCommentsCell, forIndexPath: indexPath) as! UITableViewCell
    cell.separatorInset = UIEdgeInsets(top: 0, left: cell.frame.size.width, bottom: 0, right: 0)
    return cell
  }
  
  // MARK: Networking Helper Functions
  
  /// Sends downvote request to Cillo Servers for the comment at the specified index in commentTree.
  ///
  /// :param: index The index of the comment being downvoted in the commentTree array.
  /// :param: completionHandler The completion block for the downvote.
  /// :param: success True if downvote request was successful. If error was received, it is false.
  func downvoteCommentAtIndex(index: Int, completionHandler: (success: Bool) -> ()) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    DataManager.sharedInstance.downvoteCommentWithID(commentTree[index].commentID) { error, success in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      if let error = error {
        handleError(error)
        completionHandler(success: false)
      } else {
        completionHandler(success: success)
      }
    }
  }
  
  /// Sends downvote request to Cillo Servers for the post that this UIViewController is representing.
  ///
  /// :param: completionHandler The completion block for the upvote.
  /// :param: success True if downvote request was successful. If error was received, it is false.
  func downvotePost(completionHandler: (success: Bool) -> ()) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    DataManager.sharedInstance.downvotePostWithID(post.postID) { error, success in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      if let error = error {
        handleError(error)
        completionHandler(success: false)
      } else {
        completionHandler(success: success)
      }
    }
  }
  
  /// Sends upvote request to Cillo Servers for the comment at the specified index in commentTree.
  ///
  /// :param: index The index of the comment being upvoted in the commentTree array.
  /// :param: completionHandler The completion block for the upvote.
  /// :param: success True if upvote request was successful. If error was received, it is false.
  func upvoteCommentAtIndex(index: Int, completionHandler: (success: Bool) -> ()) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    DataManager.sharedInstance.upvoteCommentWithID(commentTree[index].commentID) { error, success in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      if let error = error {
        handleError(error)
        completionHandler(success: false)
      } else {
        completionHandler(success: success)
      }
    }
  }
  
  /// Sends upvote request to Cillo Servers for the post that this UIViewController is representing.
  ///
  /// :param: completionHandler The completion block for the upvote.
  /// :param: success True if upvote request was successful. If error was received, it is false.
  func upvotePost(completionHandler: (success: Bool) -> ()) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    DataManager.sharedInstance.upvotePostWithID(post.postID) { error, success in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      if let error = error {
        handleError(error)
        completionHandler(success: false)
      } else {
        completionHandler(success: success)
      }
    }
  }

  // MARK: IBActions
  
  /// Downvotes a comment.
  ///
  /// :param: sender The button that is touched to send this function is a downvoteButton in a CommentCell.
  @IBAction func downvoteCommentPressed(sender: UIButton) {
    let comment = commentTree[sender.tag]
    if comment.voteValue != -1 {
      downvoteCommentAtIndex(sender.tag) { success in
        if success {
          comment.downvote()
          let commentIndexPath = NSIndexPath(forRow: sender.tag, inSection: 1)
          self.tableView.reloadRowsAtIndexPaths([commentIndexPath], withRowAnimation: .None)
        }
      }
    }
  }
  
  /// Downvotes a post.
  ///
  /// :param: sender The button that is touched to send this function is a downvoteButton in a PostCell.
  @IBAction func downvotePostPressed(sender: UIButton) {
    if post.voteValue != -1 {
      downvotePost { success in
        if success {
          self.post.downvote()
          let postIndexPath = NSIndexPath(forRow: 0, inSection: 0)
          self.tableView.reloadRowsAtIndexPaths([postIndexPath], withRowAnimation: .None)
        }
      }
    }
  }
  
  /// Presents another instance of this ViewController representing the originalPost of `post` if `post` is a Repost.
  ///
  /// **Note:** The position of the Post is known via the tag of the button with the RepostCell.tagModifier taken into account.
  ///
  /// :param: sender The button that is touched to send this function is an originalPostButton in a RepostCell.
  @IBAction func goToOriginalPost(sender: UIButton) {
    if let post = post as? Repost {
      let postViewController = UIStoryboard.mainStoryboard.instantiateViewControllerWithIdentifier(StoryboardIdentifiers.post) as! PostTableViewController
      postViewController.post = post.originalPost
      navigationController?.pushViewController(postViewController, animated: true)
    }
  }
  
  /// Reposts a post.
  ///
  /// :param: sender The button that is touched to send this function is a repostButton in a PostCell.
  @IBAction func repostPressed(sender: UIButton) {
    if let tabBarController = tabBarController as? TabViewController {
      tabBarController.performSegueWithIdentifier(SegueIdentifiers.tabToNewRepost, sender: post)
    }
  }
  
  /// Triggers segue to BoardTableViewController.
  ///
  /// :param: sender The button that is touched to send this function is a boardButton in a PostCell or an originalBoardButton in a RepostCell.
  @IBAction func triggerBoardSegueOnButton(sender: UIButton) {
    performSegueWithIdentifier(segueIdentifierThisToBoard, sender: sender)
  }
  
  /// Triggers segue to UserTableViewController.
  ///
  /// :param: sender The button that is touched to send this function is a nameButton or a pictureButton in a PostCell or a CommentCell.
  @IBAction func triggerUserSegueOnButton(sender: UIButton) {
    performSegueWithIdentifier(segueIdentifierThisToUser, sender: sender)
  }
  
  /// Upvotes a comment.
  ///
  /// :param: sender The button that is touched to send this function is a upvtoeButton in a CommentCell.
  @IBAction func upvoteCommentPressed(sender: UIButton) {
    let comment = commentTree[sender.tag]
    if comment.voteValue != 1 {
      upvoteCommentAtIndex(sender.tag) { success in
        if success {
          comment.upvote()
          let commentIndexPath = NSIndexPath(forRow: sender.tag, inSection: 1)
          self.tableView.reloadRowsAtIndexPaths([commentIndexPath], withRowAnimation: .None)
        }
      }
    }
  }
  
  /// Upvotes a post.
  ///
  /// :param: sender The button that is touched to send this function is a upvoteButton in a PostCell.
  @IBAction func upvotePostPressed(sender: UIButton) {
    if post.voteValue != 1 {
      upvotePost { success in
        if success {
          self.post.upvote()
          let postIndexPath = NSIndexPath(forRow: 0, inSection: 0)
          self.tableView.reloadRowsAtIndexPaths([postIndexPath], withRowAnimation: .None)
        }
      }
    }
  }
}
