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
/// **Note:** Subclasses must override segueIdentifierThisToPost, segueIdentifierThisToBoard, and segueIdentifierThisToUser.
class MultiplePostsTableViewController: CustomTableViewController {
  
  // MARK: Properties
  
  /// Flag to tell if paged calls are completed (reached the end of the feed).
  var finishedPaging = false
  
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
      if let repost = post as? Repost, sender = sender as? UIButton, title = sender.titleForState(.Normal) where title == "Original Post" {
        post = repost.originalPost
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
    return PostCell.heightOfPostCellForPost(post, withElementWidth: tableViewWidthWithMargins, maxContractedHeight: maxContractedHeight, maxContractedImageHeight: maxContractedImageHeight, andDividerHeight: separatorHeightForIndexPath(indexPath))
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
    let cell: PostCell = {
      if let post = post as? Repost {
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
          post.loadedImage = image
          self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        }
      }
    }
    cell.makeCellFromPost(post, withButtonTag: indexPath.row, maxContractedImageHeight: maxContractedImageHeight, andSeparatorHeight: separatorHeightForIndexPath(indexPath))
    cell.assignDelegatesForCellTo(self)
    return cell
  }
 
  func updateUIAfterUserBlockedAtIndex(index: Int) {
    dispatch_async(dispatch_get_main_queue()) {
      let id = self.posts[index].user.userID
      var indexPaths = [NSIndexPath]()
      for (index,post) in enumerate(self.posts) {
        if post.user.userID == id {
          indexPaths.append(NSIndexPath(forRow: index, inSection: 0))
        }
      }
      self.posts = self.posts.filter { element in
        element.user.userID != id
      }
      self.tableView.beginUpdates()
      self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
      self.tableView.endUpdates()
    }
  }
  
  /// Presents an AlertController with style `.AlertView` that asks the user for confirmation of logging out.
  ///
  /// :param: index The index of the post that triggered this alert.
  func presentBlockConfirmationAlertViewForIndex(index: Int) {
    let name = posts[index].user.name
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
  
  /// Presents an AlertController with style `.ActionSheet` that prompts the user with various possible additional actions.
  ///
  /// :param: index The index of the post that triggered this action sheet.
  func presentMenuActionSheetForIndex(index: Int) {
    if objc_getClass("UIAlertController") != nil {
      let actionSheet = UIAlertController(title: "More", message: nil, preferredStyle: .ActionSheet)
      let flagAction = UIAlertAction(title: "Flag", style: .Default) { _ in
        self.flagPostAtIndex(index) { success in
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
      if let navigationController = navigationController where UIDevice.currentDevice().userInterfaceIdiom == .Pad {
        actionSheet.modalPresentationStyle = .Popover
        let popPresenter = actionSheet.popoverPresentationController
        popPresenter?.sourceView = navigationController.navigationBar
        popPresenter?.sourceRect = navigationController.navigationBar.frame
      }
      presentViewController(actionSheet, animated: true, completion: nil)
    } else {
      let actionSheet = UIActionSheet(title: "More", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Flag", "Block User")
      actionSheet.cancelButtonIndex = 2
      actionSheet.tag = index
      if let navigationController = navigationController where UIDevice.currentDevice().userInterfaceIdiom == .Pad {
        actionSheet.showFromRect(navigationController.navigationBar.frame, inView: view, animated: true)
      } else {
        actionSheet.showInView(view)
      }
    }
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
  
  /// Sends block user request to Cillo Servers for the post at the specified index.
  ///
  /// :param: index The index of the post being upvoted in `posts`.
  /// :param: completionHandler The completion block for the upvote.
  /// :param: success True if block request was successful. If error was received, false.
  func blockUserAtIndex(index: Int, completionHandler: (success: Bool) -> ()) {
    DataManager.sharedInstance.blockUser(posts[index].user) { error, success in
      if let error = error {
        self.handleError(error)
        completionHandler(success: false)
      } else {
        completionHandler(success: success)
      }
    }
  }
  
  /// Sends downvote request to Cillo Servers for the post at the specified index.
  ///
  /// :param: index The index of the post being upvoted in `posts`.
  /// :param: completionHandler The completion block for the upvote.
  /// :param: success True if downvote request was successful. If error was received, false.
  func downvotePostAtIndex(index: Int, completionHandler: (success: Bool) -> ()) {
    DataManager.sharedInstance.downvotePostWithID(posts[index].postID) { error, success in
      if let error = error {
        self.handleError(error)
        completionHandler(success: false)
      } else {
        completionHandler(success: success)
      }
    }
  }
  
  /// Sends flag post request to Cillo Servers for the post at the specified index.
  ///
  /// :param: index The index of the post being upvoted in `posts`.
  /// :param: completionHandler The completion block for the upvote.
  /// :param: success True if flag request was successful. If error was received, false.
  func flagPostAtIndex(index: Int, completionHandler: (success: Bool) -> ()) {
    DataManager.sharedInstance.flagPost(posts[index]) { error, success in
      if let error = error {
        self.handleError(error)
        completionHandler(success: false)
      } else {
        completionHandler(success: success)
      }
    }
  }
  
  /// Sends upvote request to Cillo Servers for the post at the specified index.
  ///
  /// :param: index The index of the post being upvoted in `posts`.
  /// :param: completionHandler The completion block for the upvote.
  /// :param: success True if upvote request was successful. If error was received, false.
  func upvotePostAtIndex(index: Int, completionHandler: (success: Bool) -> ()) {
    DataManager.sharedInstance.upvotePostWithID(posts[index].postID) { error, success in
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
    let post = self.posts[sender.tag]
    if post.voteValue != -1 {
      downvotePostAtIndex(sender.tag) { success in
        if success {
          dispatch_async(dispatch_get_main_queue()) {
            post.downvote()
            let postIndexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
            self.tableView.reloadRowsAtIndexPaths([postIndexPath], withRowAnimation: .None)
          }
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
  
  /// Expands the image displayed in the button to full screen.
  ///
  /// :param: sender The button that is touched to send this function is an imagesButton in a PostCell.
  @IBAction func imageButtonPressed(sender: UIButton) {
    let loadedImage: UIImage? = {
      let post = self.posts[sender.tag]
      if let post = post as? Repost {
        return post.originalPost.loadedImage
      } else {
        return post.loadedImage
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
    presentMenuActionSheetForIndex(sender.tag)
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
    tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: sender.tag, inSection: 0)], withRowAnimation: .None)
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
          dispatch_async(dispatch_get_main_queue()) {
            post.upvote()
            let postIndexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
            self.tableView.reloadRowsAtIndexPaths([postIndexPath], withRowAnimation: .None)
          }
        }
      }
    }
  }
}

// MARK: - UIActionSheetDelegate

extension MultiplePostsTableViewController: UIActionSheetDelegate {
  
  func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
    switch buttonIndex {
    case 0:
      self.flagPostAtIndex(actionSheet.tag) { success in
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

// MARK: - UIAlertViewDelegate

extension MultiplePostsTableViewController: UIAlertViewDelegate {
  
  func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
    if buttonIndex == 1 {
      blockUserAtIndex(alertView.tag) { success in
        if success {
          dispatch_async(dispatch_get_main_queue()) {
            UIAlertView(title: "\(self.posts[alertView.tag].user.name) Blocked", message: nil, delegate: nil, cancelButtonTitle: "Ok").show()
            self.updateUIAfterUserBlockedAtIndex(alertView.tag)
          }
        }
      }
    }
  }
}

