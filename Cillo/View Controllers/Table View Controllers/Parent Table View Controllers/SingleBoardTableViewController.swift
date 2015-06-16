//
//  SingleBoardTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 1/5/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Inherit this class for any UITableViewController that is a BoardCell followed by PostCells.
///
/// **Note:** Subclasses must override segueIdentifierThisToPost, segueIdentifierThisToUser, and segueIdentifierThisToNewPost.
class SingleBoardTableViewController: CustomTableViewController {
  
  // MARK: Properties
  
  /// Board that is shown in this UITableViewController.
  var board = Board()
  
  /// Page marker used to retrieve 20 boards from the server at a time.
  var pageNumber = 1
  
  /// Posts for this UITableViewController.
  var posts = [Post]()
  
  /// Flag that is only false when posts have not attempted to be retrieved yet.
  var postsRetrieved = false
  
  // MARK: Constants 
  
  /// The standard dividerHeight between table view cells in tableView.
  let dividerHeight = DividerScheme.defaultScheme.singleBoardDividerHeight()
  
  /// The height on screen of the cells containing only single labels
  var heightOfSingleLabelCells: CGFloat {
    return 40.0
  }
  
  /// Segue Identifier in Storyboard for segue to PostTableViewController.
  ///
  /// **Note:** Subclasses must override this Constant.
  var segueIdentifierThisToPost: String {
    fatalError("Subclasses of SingleBoardTableViewController must override segue identifiers")
  }
  
  /// Segue Identifier in Storyboard for segue to UserTableViewController.
  ///
  /// **Note:** Subclasses must override this Constant.
  var segueIdentifierThisToUser: String {
    fatalError("Subclasses of SingleBoardTableViewController must override segue identifiers")
  }
  
  /// Segue Identifier in Storyboard for segue to NewPostViewController.
  ///
  /// **Note:** Subclasses must override this Constant.
  var segueIdentifierThisToNewPost: String {
    fatalError("Subclasses of SingleBoardTableViewController must override segue identifiers")
  }
  
  // MARK: UIViewController
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    var index = 0
    var originalPost = false
    if let sender = sender as? UIButton {
      originalPost = sender.tag >= RepostCell.tagModifier
      index = originalPost ? sender.tag - RepostCell.tagModifier : sender.tag
    } else if let sender = sender as? NSIndexPath {
      index = sender.row
    }
    var post = posts[index]
    if segue.identifier == segueIdentifierThisToPost {
      var destination = segue.destinationViewController as! PostTableViewController
      // "Original Post" button sends the end user to the originalPost, not the post
      if let repost = post as? Repost {
        destination.mainShowImages = repost.originalPost.showImages
        if let sender = sender as? UIButton, title = sender.titleForState(.Normal) where title == "Original Post" {
          post = repost.originalPost
        }
      } else {
        destination.mainShowImages = post.showImages
      }
      destination.post = post
    } else if segue.identifier == segueIdentifierThisToUser {
      var destination = segue.destinationViewController as! UserTableViewController
      if let repost = post as? Repost where originalPost {
        post = repost.originalPost
      }
      destination.user = post.user
    } else if segue.identifier == segueIdentifierThisToNewPost {
      var destination = segue.destinationViewController as! NewPostViewController
      destination.board = board
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.separatorStyle = .None
  }
  
  // MARK: UITableViewDataSource
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // Placing the BoardCell in the first section and the PostCells in the second section.
    return 2
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      return dequeueAndSetupBoardCellForIndexPath(indexPath)
    } else if !postsRetrieved {
      return dequeueAndSetupRetrievingPostsCellForIndexPath(indexPath)
    } else if posts.count == 0 {
      return dequeueAndSetupNoPostsCellForIndexPath(indexPath)
    } else {
      return dequeueAndSetupPostCellForIndexPath(indexPath)
    }
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 || !postsRetrieved || posts.count == 0 {
      return 1
    } else {
      return posts.count
    }
  }
  
  // MARK: UITableViewDelegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
    if indexPath.section != 0 && postsRetrieved && posts.count != 0 {
      performSegueWithIdentifier(segueIdentifierThisToPost, sender: indexPath)
    }
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.section == 0 {
      return BoardCell.heightOfBoardCellForBoard(board, withElementWidth: tableViewWidthWithMargins, andDividerHeight: separatorHeightForIndexPath(indexPath))
    } else if !postsRetrieved || posts.count == 0 {
      return heightOfSingleLabelCells
    } else {
      return PostCell.heightOfPostCellForPost(posts[indexPath.row], withElementWidth: tableViewWidthWithMargins, maxContractedHeight: maxContractedHeight, andDividerHeight: separatorHeightForIndexPath(indexPath))
    }
  }
  
  // MARK: Setup Helper Functions
  
  /// Makes a BoardCell for `board`.
  ///
  /// :param: indexPath The index path of the cell to be created in the table view.
  ///
  /// :returns: The created BoardCell.
  func dequeueAndSetupBoardCellForIndexPath(indexPath: NSIndexPath) -> BoardCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.boardCell, forIndexPath: indexPath) as! BoardCell
    cell.makeCellFromBoard(board, withButtonTag: 0, andSeparatorHeight: separatorHeightForIndexPath(indexPath))
    cell.assignDelegatesForCellTo(self)
    return cell
  }
  
  /// Makes a single label UITableViewCell that says "No posts..."
  ///
  /// :param: indexPath The index path of the cell to be created in the table view.
  ///
  /// :returns: The created NoPostsCell.
  func dequeueAndSetupNoPostsCellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.noPostsCell, forIndexPath: indexPath) as! UITableViewCell
    return cell
  }
  
  /// Makes a PostCell for the corresponding post in `posts` based on the passed indexPath.
  ///
  /// If the post is a Repost, the returned PostCell will be a RepostCell.
  ///
  /// :param: indexPath The index path of the cell to be created in the table view.
  ///
  /// :returns: The created PostCell.
  func dequeueAndSetupPostCellForIndexPath(indexPath: NSIndexPath) -> PostCell {
    let post = posts[indexPath.row]
    let cell: PostCell = {
      if let post = post as? Repost {
        return self.tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.repostCell, forIndexPath: indexPath) as! RepostCell
      } else {
        return self.tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.postCell, forIndexPath: indexPath) as! PostCell
      }
    }()
    cell.makeCellFromPost(post, withButtonTag: indexPath.row, andSeparatorHeight: separatorHeightForIndexPath(indexPath))
    cell.assignDelegatesForCellTo(self)
    return cell
  }
  
  /// Makes a single label UITableViewCell that says "Retrieving Posts..."
  ///
  /// :param: indexPath The index path of the cell to be created in the table view.
  ///
  /// :returns: The created RetrieivingCommentsCell.
  func dequeueAndSetupRetrievingPostsCellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.retrievingPostsCell, forIndexPath: indexPath) as! UITableViewCell
    return cell
  }
  
  /// Presents an AlertController with style `.ActionSheet` that asks the user for confirmation of unfollowing a board.
  func presentUnfollowConfirmationActionSheet() {
    let actionSheet = UIAlertController(title: board.name, message: nil, preferredStyle: .ActionSheet)
    let unfollowAction = UIAlertAction(title: "Unfollow", style: .Default) { _ in
      self.unfollowBoard { success in
        if success {
          self.board.following = false
          let boardIndexPath = NSIndexPath(forRow: 0, inSection: 0)
          self.tableView.reloadRowsAtIndexPaths([boardIndexPath], withRowAnimation: .None)
        }
      }
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { _ in
    }
    actionSheet.addAction(unfollowAction)
    actionSheet.addAction(cancelAction)
    presentViewController(actionSheet, animated: true, completion: nil)
  }
  
  /// Calculates the correct separator height inbetween cells of `tableView`.
  ///
  /// :param: indexPath The index path of the cell in the `tableView`.
  ///
  /// :returns: The correct separator height, as specified by the `dividerHeight` constant.
  func separatorHeightForIndexPath(indexPath: NSIndexPath) -> CGFloat {
    if indexPath.section == 0 {
      return dividerHeight
    }
    return indexPath.row != posts.count - 1 ? dividerHeight : 0
  }
  
  // MARK: Networking Helper Functions
  
  /// Sends downvote request to Cillo Servers for the post that this UIViewController is representing.
  ///
  /// :param: index The index of the post being upvoted in the posts array.
  /// :param: completionHandler The completion block for the upvote.
  /// :param: success True if downvote request was successful. If error was received, it is false.
  func downvotePostAtIndex(index: Int, completionHandler: (success: Bool) -> ()) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    DataManager.sharedInstance.downvotePostWithID(posts[index].postID) { error, success in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      if let error = error {
        self.handleError(error)
        completionHandler(success: false)
      } else {
        completionHandler(success: success)
      }
    }
  }
  
  /// Sends follow request to Cillo Servers for board represented by this UIViewController.
  ///
  /// :param: completionHandler The completion block for the upvote.
  /// :param: success True if follow request was successful. If error was received, it is false.
  func followBoard(completionHandler: (success: Bool) -> ()) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    DataManager.sharedInstance.followBoardWithID(board.boardID) { error, success in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      if let error = error {
        self.handleError(error)
        completionHandler(success: false)
      } else {
        completionHandler(success: success)
      }
    }
  }
  
  /// Sends upvote request to Cillo Servers for the post that this UIViewController is representing.
  ///
  /// :param: index The index of the post being upvoted in the posts array.
  /// :param: completionHandler The completion block for the upvote.
  /// :param: success True if upvote request was successful. If error was received, it is false.
  func upvotePostAtIndex(index: Int, completionHandler: (success: Bool) -> ()) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    DataManager.sharedInstance.upvotePostWithID(posts[index].postID) { error, success in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      if let error = error {
        self.handleError(error)
        completionHandler(success: false)
      } else {
        completionHandler(success: success)
      }
    }
  }
  
  /// Sends unfollow request to Cillo Servers for board represented by this UIViewController.
  ///
  /// :param: completionHandler The completion block for the upvote.
  /// :param: success True if follow request was unsuccessful. If error was received, it is false.
  func unfollowBoard(completionHandler: (success: Bool) -> ()) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    DataManager.sharedInstance.unfollowBoardWithID(board.boardID) { error, success in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      if let error = error {
        self.handleError(error)
        completionHandler(success: false)
      } else {
        completionHandler(success: success)
      }
    }
  }
  
  // MARK: IBActions
  
  /// Downvotes a post.
  ///
  /// **Note:** The position of the Post to be downvoted is known via the tag of the button.
  ///
  /// :param: sender The button that is touched to send this function is a downvoteButton in a PostCell.
  @IBAction func downvotePostPressed(sender: UIButton) {
    let post = posts[sender.tag]
    if post.voteValue != -1 {
      downvotePostAtIndex(sender.tag) { success in
        if success {
          post.downvote()
          let postIndexPath = NSIndexPath(forRow: sender.tag, inSection: 1)
          self.tableView.reloadRowsAtIndexPaths([postIndexPath], withRowAnimation: .None)
        }
      }
    }
  }
  
  /// Either follows board or presents an ActionSheet to unfollow board.
  ///
  /// :param: sender The button that is touched to send this function is a followButton in a BoardCell.
  @IBAction func followOrUnfollowBoard(sender: UIButton) {
    if !board.following {
      followBoard { success in
        if success {
          self.board.following = true
          let boardIndexPath = NSIndexPath(forRow: 0, inSection: 0)
          self.tableView.reloadRowsAtIndexPaths([boardIndexPath], withRowAnimation: .None)
        }
      }
    } else {
      presentUnfollowConfirmationActionSheet()
    }
  }
  
  /// Triggers segue with identifier segueIdentifierThisToPost.
  ///
  /// **Note:** The position of the Post is known via the tag of the button with the RepostCell.tagModifier taken into account.
  ///
  /// :param: sender The button that is touched to send this function is an originalPostButton in a RepostCell.
  @IBAction func goToOriginalPost(sender: UIButton) {
    if let post = posts[sender.tag - RepostCell.tagModifier] as? Repost {
      performSegueWithIdentifier(segueIdentifierThisToPost, sender: sender)
    }
  }
  
  /// Reposts a post.
  ///
  /// **Note:** The position of the Post to be reposted is known via the tag of the button.
  ///
  /// :param: sender The button that is touched to send this function is a repostButton in a PostCell.
  @IBAction func repostPressed(sender: UIButton) {
    if let tabBarController = tabBarController as? TabViewController {
      tabBarController.performSegueWithIdentifier(SegueIdentifiers.tabToNewRepost, sender: posts[sender.tag])
    }
  }
  
  /// Expands `postTextView` in a PostCell to a height greater than `maxContractedHeight`.
  ///
  /// :param: sender The button that is touched to send this function is a `seeFullButton` in a PostCell.
  @IBAction func seeFullPressed(sender: UIButton) {
    let post = posts[sender.tag]
    if let post = post as? Repost, seeFull = post.originalPost.seeFull {
      post.originalPost.seeFull! = !seeFull
    } else if let seeFull = post.seeFull {
      post.seeFull! = !seeFull
    }
    tableView.reloadData()
  }
  
  /// Expands `imagesButton` in a PostCell to its full image size.
  ///
  /// :param: sender The button that is touched to send this function is a `imagesButton` in a PostCell.
  @IBAction func showImagesPressed(sender: UIButton) {
    let post = posts[sender.tag]
    if let post = post as? Repost where !post.originalPost.showImages {
      post.originalPost.showImages = !post.originalPost.showImages
    } else if !post.showImages {
      post.showImages = !post.showImages
    }
    tableView.reloadData()
  }
  
  /// Triggers segue to PostTableViewController.
  ///
  /// :param: sender The button that is touched to send this function is a commentButton in a PostCell.
  @IBAction func triggerPostSegueOnButton(sender: UIButton) {
    performSegueWithIdentifier(segueIdentifierThisToPost, sender: sender)
  }
  
  /// Triggers segue to UserTableViewController.
  ///
  /// :param: sender The button that is touched to send this function is a nameButton or a pictureButton in a PostCell.
  @IBAction func triggerUserSegueOnButton(sender: UIButton) {
    performSegueWithIdentifier(segueIdentifierThisToUser, sender: sender)
  }
  
  /// Presents another instance of this ViewController representing the board of an `oringialPost` if a `post` is a Repost.
  ///
  /// :param: sender The button that is touched to send this function is an originalGroupButton in a RepostCell.
  @IBAction func triggerOriginalBoardTransitionOnButton(sender: UIButton) {
    if let post = posts[sender.tag] as? Repost {
      let boardViewController = UIStoryboard.mainStoryboard.instantiateViewControllerWithIdentifier(StoryboardIdentifiers.board) as! BoardTableViewController
      boardViewController.board = post.originalPost.board
      navigationController?.pushViewController(boardViewController, animated: true)
    }
  }
  
  /// Upvotes a post.
  ///
  /// **Note:** The position of the Post to be upvoted is known via the tag of the button.
  ///
  /// :param: sender The button that is touched to send this function is an upvoteButton in a PostCell.
  @IBAction func upvotePostPressed(sender: UIButton) {
    let post = posts[sender.tag]
    if post.voteValue != 1 {
      upvotePostAtIndex(sender.tag) { success in
        if success {
          post.upvote()
          let postIndexPath = NSIndexPath(forRow: sender.tag, inSection: 1)
          self.tableView.reloadRowsAtIndexPaths([postIndexPath], withRowAnimation: .None)
        }
      }
    }
  }
}
