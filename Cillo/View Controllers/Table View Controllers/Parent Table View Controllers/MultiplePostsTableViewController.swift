//
//  MultiplePostsTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 12/18/14.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Inherit this class for any UITableViewController that is only a table of PostCells.
///
/// **Note:** Subclasses must override segueIdentifierThisToPost, segueIdentifierThisToBoard, segueIdentifierThisToUser, and segueIdentifierThisToNewPost.
class MultiplePostsTableViewController: CustomTableViewController {
  
  // MARK: Properties
  
  /// Page marker used to retrieve 20 posts from the server at a time.
  var pageNumber = 1
  
  /// Posts that will be displayed in the tableView.
  var posts = [Post]()
  
  // MARK: Constants
  
  /// The standard dividerHeight between table view cells in tableView.
  let dividerHeight = DividerScheme.defaultScheme.multiplePostsDividerHeight()
  
  /// Segue Identifier in Storyboard for segue to BoardTableViewController.
  ///
  /// **Note:** Subclasses must override this Constant.
  var segueIdentifierThisToBoard: String {
    fatalError("Subclasses of MultiplePostsTableViewController must override segue identifiers")
  }
  
  /// Segue Identifier in Storyboard for segue to NewPostViewController.
  ///
  /// **Note:** Subclasses must override this Constant.
  var segueIdentifierThisToNewPost: String {
    fatalError("Subclasses of MultiplePostsTableViewController must override segue identifiers")
  }
  
  /// Segue Identifier in Storyboard for segue to PostTableViewController.
  ///
  /// **Note:** Subclasses must override this Constant.
  var segueIdentifierThisToPost: String {
    fatalError("Subclasses of MultiplePostsTableViewController must override segue identifiers")
  }

  /// Segue Identifier in Storyboard for segue to UserTableViewController.
  ///
  /// **Note:** Subclasses must override this Constant.
  var segueIdentifierThisToUser: String {
    fatalError("Subclasses of MultiplePostsTableViewController must override segue identifiers")
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
    } else if segue.identifier == segueIdentifierThisToBoard {
      var destination = segue.destinationViewController as! BoardTableViewController
      if let repost = post as? Repost where originalPost {
        post = repost.originalPost
      }
      destination.board = post.board
    } else if segue.identifier == segueIdentifierThisToUser {
      var destination = segue.destinationViewController as! UserTableViewController
      if let repost = post as? Repost where originalPost {
        post = repost.originalPost
      }
      destination.user = post.user
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.separatorStyle = .None
  }
  
  // MARK: UITableViewDataSource
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    return dequeueAndSetupPostCellForIndexPath(indexPath)
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return posts.count
  }

  // MARK: UITableViewDelegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
    performSegueWithIdentifier(segueIdentifierThisToPost, sender: indexPath)
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    let post = posts[indexPath.row]
    return PostCell.heightOfPostCellForPost(post, withElementWidth: tableViewWidthWithMargins, maxContractedHeight: maxContractedHeight, andDividerHeight: separatorHeightForIndexPath(indexPath))
  }
  
  // MARK: Setup Helper Functions
  
  /// Makes a PostCell for the corresponding post in `posts` based on the passed indexPath.
  ///
  /// If the post is a Repost, the returned PostCell will be a RepostCell.
  ///
  /// :param: indexPath The index path of the cell to be created in the table view.
  ///
  /// :returns: The created PostCell.
  func dequeueAndSetupPostCellForIndexPath(indexPath: NSIndexPath) -> PostCell {
    let post = posts[indexPath.row]
    var cell: PostCell
    if let post = post as? Repost {
      cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.repostCell, forIndexPath: indexPath) as! RepostCell
    } else {
      cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.postCell, forIndexPath: indexPath) as! PostCell
    }
    cell.makeCellFromPost(post, withButtonTag: indexPath.row, andSeparatorHeight: separatorHeightForIndexPath(indexPath))
    cell.assignDelegatesForCellTo(self)
    return cell
  }
  
  /// Calculates the correct separator height inbetween cells of `tableView`.
  ///
  /// :param: indexPath The index path of the cell in the `tableView`.
  ///
  /// :returns: The correct separator height, as specified by the `dividerHeight` constant.
  func separatorHeightForIndexPath(indexPath: NSIndexPath) -> CGFloat {
    return indexPath.row != posts.count - 1 ? dividerHeight : 0
  }
  
  // MARK: Networking Helper Functions
  
  /// Sends downvote request to Cillo Servers for the post at the specified index.
  ///
  /// :param: index The index of the post being upvoted in `posts`.
  /// :param: completion The completion block for the upvote.
  /// :param: success True if downvote request was successful. If error was received, false.
  func downvotePostAtIndex(index: Int, completion: (success: Bool) -> Void) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    DataManager.sharedInstance.postDownvote(posts[index].postID) { error, success in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      if let error = error {
        println(error)
        error.showAlert()
        completion(success: false)
      } else {
        completion(success: success)
      }
    }
  }
  
  /// Sends upvote request to Cillo Servers for the post at the specified index.
  ///
  /// :param: index The index of the post being upvoted in `posts`.
  /// :param: completion The completion block for the upvote.
  /// :param: success True if upvote request was successful. If error was received, false.
  func upvotePostAtIndex(index: Int, completion: (success: Bool) -> Void) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    DataManager.sharedInstance.postUpvote(posts[index].postID) { error, success in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      if let error = error {
        println(error)
        error.showAlert()
        completion(success: false)
      } else {
        completion(success: success)
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
    let post = self.posts[sender.tag]
    if post.voteValue != -1 {
      downvotePostAtIndex(sender.tag) { success in
        if success {
          post.downvote()
          let postIndexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
          self.tableView.reloadRowsAtIndexPaths([postIndexPath], withRowAnimation: .None)
        }
      }
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
  
  /// Triggers segue with identifier segueIdentifierThisToBoard.
  ///
  /// :param: sender The button that is touched to send this function is a boardButton in a PostCell or an originalBoardButton in a RepostCell.
  @IBAction func triggerBoardSegueOnButton(sender: UIButton) {
    performSegueWithIdentifier(segueIdentifierThisToBoard, sender: sender)
  }
  
  /// Triggers segue with identifier segueIdentifierThisToPost.
  ///
  /// :param: sender The button that is touched to send this function is a commentButton in a PostCell.
  @IBAction func triggerPostSegueOnButton(sender: UIButton) {
    performSegueWithIdentifier(segueIdentifierThisToPost, sender: sender)
  }
  
  /// Triggers segue with identifier segueIdentifierThisToUser.
  ///
  /// :param: sender The button that is touched to send this function is a nameButton or a pictureButton in a PostCell, or an originalNameButton or originalPictureButton in a RepostCell.
  @IBAction func triggerUserSegueOnButton(sender: UIButton) {
    performSegueWithIdentifier(segueIdentifierThisToUser, sender: sender)
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
          let postIndexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
          self.tableView.reloadRowsAtIndexPaths([postIndexPath], withRowAnimation: .None)
        }
      }
    }
  }
}

