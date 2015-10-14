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
  
  /// Post that is represented by this view controller.
  var post = Post()
  
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
  
  /// Tag of actionsheet for moreButton for `post`
  let postMoreActionSheetTag = Int.max
  
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
    if !commentTree[indexPath.row].blocked {
      if selectedPath != indexPath {
        selectedPath = indexPath
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
      } else {
        selectedPath = nil
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
      }
    }
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.section == 0 {
      return PostCell.heightOfPostCellForPost(post, withElementWidth: tableViewWidthWithMargins, maxContractedHeight: nil, maxContractedImageHeight: maxContractedImageHeight, andDividerHeight: 0)
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
    let cell: PostCell = {
      if let post = self.post as? Repost {
        return self.tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.repostCell, forIndexPath: indexPath) as! RepostCell
      } else {
        return self.tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.postCell, forIndexPath: indexPath) as! PostCell
      }
    }()
    if let post = post as? Repost where post.originalPost.loadedImage == nil {
      cell.loadImagesForPost(post) { image in
        dispatch_async(dispatch_get_main_queue()) {
          post.originalPost.loadedImage = image
          self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        }
      }
    } else if !(post is Repost) && post.loadedImage == nil {
      cell.loadImagesForPost(post) { image in
        dispatch_async(dispatch_get_main_queue()) {
          self.post.loadedImage = image
          self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        }
      }
    }
    cell.makeCellFromPost(post, withButtonTag: postCellTag, maxContractedImageHeight: maxContractedImageHeight)
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
  
  func updateUIAfterUserBlockedAtIndex(index: Int) {
    dispatch_async(dispatch_get_main_queue()) {
      let id = self.commentTree[index].user.userID
      var indexPaths = [NSIndexPath]()
      for (index, comment) in enumerate(self.commentTree) {
        if comment.user.userID == id {
          indexPaths.append(NSIndexPath(forRow: index, inSection: 1))
        }
      }
      self.selectedPath = nil
      self.tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
    }
  }
  
  /// Presents an AlertController with style `.ActionSheet` that prompts the user with various possible additional actions.
  ///
  /// :param: index The index of the post that triggered this action sheet.
  func presentMenuActionSheetForIndex(index: Int, iPadReference: UIButton?) {
    if objc_getClass("UIAlertController") != nil {
      let actionSheet = UIAlertController(title: "More", message: nil, preferredStyle: .ActionSheet)
      let flagAction = UIAlertAction(title: "Flag", style: .Default) { _ in
        self.flagCommentAtIndex(index) { success in
          if success {
            UIAlertView(title: "Post flagged", message: "Thanks for helping make Cillo a better place!", delegate: nil, cancelButtonTitle: "Ok").show()
          }
        }
      }
      let blockAction = UIAlertAction(title: "Block User", style: .Default) { _ in
        self.presentBlockConfirmationAlertViewForIndex(index)
      }
      let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { _ in
      }
      actionSheet.addAction(flagAction)
      actionSheet.addAction(blockAction)
      actionSheet.addAction(cancelAction)
      if let iPadReference = iPadReference where UIDevice.currentDevice().userInterfaceIdiom == .Pad {
        actionSheet.modalPresentationStyle = .Popover
        let popPresenter = actionSheet.popoverPresentationController
        popPresenter?.sourceView = iPadReference
        popPresenter?.sourceRect = iPadReference.bounds
      }
      presentViewController(actionSheet, animated: true, completion: nil)
    } else {
      let actionSheet = UIActionSheet(title: "More", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Flag", "Block User")
      actionSheet.cancelButtonIndex = 2
      actionSheet.tag = index
      if let iPadReference = iPadReference where UIDevice.currentDevice().userInterfaceIdiom == .Pad {
        actionSheet.showFromRect(iPadReference.bounds, inView: view, animated: true)
      } else {
        actionSheet.showInView(view)
      }
    }
  }
  
  /// Presents an AlertController with style `.ActionSheet` that prompts the user with various possible additional actions.
  func presentPostMenuActionSheet(#iPadReference: UIButton?) {
    if objc_getClass("UIAlertController") != nil {
      let actionSheet = UIAlertController(title: "More", message: nil, preferredStyle: .ActionSheet)
      let flagAction = UIAlertAction(title: "Flag", style: .Default) { _ in
        self.flagPost { success in
          if success {
            UIAlertView(title: "Post flagged", message: "Thanks for helping make Cillo a better place!", delegate: nil, cancelButtonTitle: "Ok").show()
          }
        }
      }
      let blockAction = UIAlertAction(title: "Block User", style: .Default) { _ in
        self.presentPostBlockConfirmationAlertView()
      }
      let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { _ in
      }
      actionSheet.addAction(flagAction)
      actionSheet.addAction(blockAction)
      actionSheet.addAction(cancelAction)
      if let iPadReference = iPadReference where UIDevice.currentDevice().userInterfaceIdiom == .Pad {
        actionSheet.modalPresentationStyle = .Popover
        let popPresenter = actionSheet.popoverPresentationController
        popPresenter?.sourceView = iPadReference
        popPresenter?.sourceRect = iPadReference.bounds
      }
      presentViewController(actionSheet, animated: true, completion: nil)
    } else {
      let actionSheet = UIActionSheet(title: "More", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Flag", "Block User")
      actionSheet.cancelButtonIndex = 2
      actionSheet.tag = postMoreActionSheetTag
      if let iPadReference = iPadReference where UIDevice.currentDevice().userInterfaceIdiom == .Pad {
        actionSheet.showFromRect(iPadReference.bounds, inView: view, animated: true)
      } else {
        actionSheet.showInView(view)
      }
    }
  }
  
  /// Presents an AlertController with style `.AlertView` that asks the user for confirmation of blocking `post.user`.
  func presentPostBlockConfirmationAlertView() {
    let name = post.user.name
    if objc_getClass("UIAlertController") != nil {
      let alert = UIAlertController(title: "Block Confirmation", message: "Are you sure you want to block \(name)?", preferredStyle: .Alert)
      let yesAction = UIAlertAction(title: "Yes", style: .Default) { _ in
        self.blockUser { success in
          if success {
            dispatch_async(dispatch_get_main_queue()) {
              UIAlertView(title: "\(name) Blocked", message: nil, delegate: nil, cancelButtonTitle: "Ok").show()
              self.navigationController?.popToRootViewControllerAnimated(true)
              if let topVC = self.navigationController?.topViewController as? CustomTableViewController {
                topVC.retrieveData()
              }
            }
          }
        }
      }
      let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { _ in
      }
      alert.addAction(yesAction)
      alert.addAction(cancelAction)
      presentViewController(alert, animated: true, completion: nil)
    } else {
      let alert = UIAlertView(title: "Block Confirmation", message: "Are you sure you want to block \(name)?", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "Yes", "Cancel")
      alert.tag = postMoreActionSheetTag
      alert.show()
    }
  }
  
  /// Presents an AlertController with style `.AlertView` that asks the user for confirmation of logging out.
  ///
  /// :param: index The index of the comment that triggered this alert.
  func presentBlockConfirmationAlertViewForIndex(index: Int) {
    let name = commentTree[index].user.name
    if objc_getClass("UIAlertController") != nil {
      let alert = UIAlertController(title: "Block Confirmation", message: "Are you sure you want to block \(name)?", preferredStyle: .Alert)
      let yesAction = UIAlertAction(title: "Yes", style: .Default) { _ in
        self.blockUserAtIndex(index) { success in
          if success {
            dispatch_async(dispatch_get_main_queue()) {
              UIAlertView(title: "\(name) Blocked", message: nil, delegate: nil, cancelButtonTitle: "Ok").show()
              self.updateUIAfterUserBlockedAtIndex(index)
            }
          }
        }
      }
      let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { _ in
      }
      alert.addAction(yesAction)
      alert.addAction(cancelAction)
      presentViewController(alert, animated: true, completion: nil)
    } else {
      let alert = UIAlertView(title: "Block Confirmation", message: "Are you sure you want to block \(name)?", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "Yes", "Cancel")
      alert.tag = index
      alert.show()
    }
  }
  
  // MARK: Networking Helper Functions
  
  /// Sends block user request to Cillo Servers for `post`.
  ///
  /// :param: completionHandler The completion block for the upvote.
  /// :param: success True if block request was successful. If error was received, false.
  func blockUser(completionHandler: (success: Bool) -> ()) {
    DataManager.sharedInstance.blockUser(post.user) { result in
      self.handleSuccessResponse(result, completionHandler: completionHandler)
    }
  }
  
  /// Sends block user request to Cillo Servers for the post at the specified index.
  ///
  /// :param: index The index of the post being upvoted in `posts`.
  /// :param: completionHandler The completion block for the upvote.
  /// :param: success True if block request was successful. If error was received, false.
  func blockUserAtIndex(index: Int, completionHandler: (success: Bool) -> ()) {
    DataManager.sharedInstance.blockUser(commentTree[index].user) { result in
      self.handleSuccessResponse(result, completionHandler: completionHandler)
    }
  }
  
  /// Sends downvote request to Cillo Servers for the comment at the specified index in commentTree.
  ///
  /// :param: index The index of the comment being downvoted in the commentTree array.
  /// :param: completionHandler The completion block for the downvote.
  /// :param: success True if downvote request was successful. If error was received, it is false.
  func downvoteCommentAtIndex(index: Int, completionHandler: (success: Bool) -> ()) {
    DataManager.sharedInstance.downvoteCommentWithID(commentTree[index].commentID) { result in
      self.handleSuccessResponse(result, completionHandler: completionHandler)
    }
  }
  
  /// Sends downvote request to Cillo Servers for the post that this UIViewController is representing.
  ///
  /// :param: completionHandler The completion block for the upvote.
  /// :param: success True if downvote request was successful. If error was received, it is false.
  func downvotePost(completionHandler: (success: Bool) -> ()) {
    DataManager.sharedInstance.downvotePostWithID(post.postID) { result in
      self.handleSuccessResponse(result, completionHandler: completionHandler)
    }
  }
  
  /// Sends flag post request to Cillo Servers for the comment at the specified index.
  ///
  /// :param: index The index of the comment being flagged in `commentTree`.
  /// :param: completionHandler The completion block for the upvote.
  /// :param: success True if flag request was successful. If error was received, false.
  func flagCommentAtIndex(index: Int, completionHandler: (success: Bool) -> ()) {
    DataManager.sharedInstance.flagComment(commentTree[index]) { result in
      self.handleSuccessResponse(result, completionHandler: completionHandler)
    }
  }
  
  /// Sends flag post request to Cillo Servers for `post`.
  ///
  /// :param: completionHandler The completion block for the upvote.
  /// :param: success True if flag request was successful. If error was received, false.
  func flagPost(completionHandler: (success: Bool) -> ()) {
    DataManager.sharedInstance.flagPost(post) { result in
      self.handleSuccessResponse(result, completionHandler: completionHandler)
    }
  }
  
  /// Sends upvote request to Cillo Servers for the comment at the specified index in commentTree.
  ///
  /// :param: index The index of the comment being upvoted in the commentTree array.
  /// :param: completionHandler The completion block for the upvote.
  /// :param: success True if upvote request was successful. If error was received, it is false.
  func upvoteCommentAtIndex(index: Int, completionHandler: (success: Bool) -> ()) {
    DataManager.sharedInstance.upvoteCommentWithID(commentTree[index].commentID) { result in
      self.handleSuccessResponse(result, completionHandler: completionHandler)
    }
  }
  
  /// Sends upvote request to Cillo Servers for the post that this UIViewController is representing.
  ///
  /// :param: completionHandler The completion block for the upvote.
  /// :param: success True if upvote request was successful. If error was received, it is false.
  func upvotePost(completionHandler: (success: Bool) -> ()) {
    DataManager.sharedInstance.upvotePostWithID(post.postID) { result in
      self.handleSuccessResponse(result, completionHandler: completionHandler)
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
          dispatch_async(dispatch_get_main_queue()) {
            comment.downvote()
            let commentIndexPath = NSIndexPath(forRow: sender.tag, inSection: 1)
            self.tableView.reloadRowsAtIndexPaths([commentIndexPath], withRowAnimation: .None)
          }
          
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
          dispatch_async(dispatch_get_main_queue()) {
            self.post.downvote()
            let postIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            self.tableView.reloadRowsAtIndexPaths([postIndexPath], withRowAnimation: .None)
          }
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
  
  /// Expands the image displayed in the button to full screen.
  ///
  /// :param: sender The button that is touched to send this function is an imagesButton in a PostCell.
  @IBAction func imageButtonPressed(sender: UIButton) {
    let loadedImage: UIImage? = {
      if let post = self.post as? Repost {
        return post.originalPost.loadedImage
      } else {
        return self.post.loadedImage
      }
      }()
    if let loadedImage = loadedImage {
      JTSImageViewController.expandImage(loadedImage, toFullScreenFromRoot: self, withSender: sender)
    }
  }
  
  /// Triggers an action sheet with a more actions menu.
  ///
  /// **Note:** The position of the Post to show menu for is known via the tag of the button.
  ///
  /// :param: sender The button that is touched to send this function is a moreButton in a PostCell.
  @IBAction func morePressed(sender: UIButton) {
    presentPostMenuActionSheet(iPadReference: sender)
  }
  
  /// Triggers an action sheet with a more actions menu.
  ///
  /// **Note:** The position of the Comment to show menu for is known via the tag of the button.
  ///
  /// :param: sender The button that is touched to send this function is a moreButton in a CommentCell.
  @IBAction func morePressedOnComment(sender: UIButton) {
    presentMenuActionSheetForIndex(sender.tag, iPadReference: sender)
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
          dispatch_async(dispatch_get_main_queue()) {
            comment.upvote()
            let commentIndexPath = NSIndexPath(forRow: sender.tag, inSection: 1)
            self.tableView.reloadRowsAtIndexPaths([commentIndexPath], withRowAnimation: .None)
          }
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
          dispatch_async(dispatch_get_main_queue()) {
            self.post.upvote()
            let postIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            self.tableView.reloadRowsAtIndexPaths([postIndexPath], withRowAnimation: .None)
          }
        }
      }
    }
  }
}

// MARK: - UIActionSheetDelegate

extension SinglePostTableViewController: UIActionSheetDelegate {
  
  func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
    if actionSheet.tag == postMoreActionSheetTag {
      switch buttonIndex {
      case 0:
        self.flagPost { success in
          if success {
            UIAlertView(title: "Post flagged", message: "Thanks for helping make Cillo a better place!", delegate: nil, cancelButtonTitle: "Ok").show()
          }
        }
      case 1:
        presentPostBlockConfirmationAlertView()
      default:
        break
      }
    } else {
      switch buttonIndex {
      case 0:
        self.flagCommentAtIndex(actionSheet.tag) { success in
          if success {
            UIAlertView(title: "Post flagged", message: "Thanks for helping make Cillo a better place!", delegate: nil, cancelButtonTitle: "Ok").show()
          }
        }
      case 1:
        presentBlockConfirmationAlertViewForIndex(actionSheet.tag)
      default:
        break
      }
    }
  }
}

// MARK: - UIAlertViewDelegate

extension SinglePostTableViewController: UIAlertViewDelegate {
  
  func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
    if alertView.tag == postMoreActionSheetTag {
      if buttonIndex == 1 {
        blockUser { success in
          if success {
            dispatch_async(dispatch_get_main_queue()) {
              UIAlertView(title: "\(self.post.user.name) Blocked", message: nil, delegate: nil, cancelButtonTitle: "Ok").show()
              self.navigationController?.popToRootViewControllerAnimated(true)
              if let topVC = self.navigationController?.topViewController as? CustomTableViewController {
                topVC.retrieveData()
              }
            }
          }
        }
      }
    } else {
      if buttonIndex == 1 {
        self.blockUserAtIndex(alertView.tag) { success in
          if success {
            dispatch_async(dispatch_get_main_queue()) {
              UIAlertView(title: "\(self.commentTree[alertView.tag].user.name) Blocked", message: nil, delegate: nil, cancelButtonTitle: "Ok").show()
              self.updateUIAfterUserBlockedAtIndex(alertView.tag)
            }
          }
        }
      }
    }
  }
}
