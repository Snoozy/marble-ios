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
  
  override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
    var index = 0
    var originalPost = false
    if let sender = sender as? UIButton {
      originalPost = sender.tag >= RepostCell.tagModifier
      index = originalPost ? sender.tag - RepostCell.tagModifier : sender.tag
    } else if let sender = sender as? IndexPath {
      index = (sender as NSIndexPath).row
    }
    var post = posts[index]
    if segue.identifier == segueIdentifierThisToPost {
      let destination = segue.destination as! PostTableViewController
      // "Original Post" button sends the end user to the originalPost, not the post
      if let repost = post as? Repost, sender = sender as? UIButton, title = sender.title(for: UIControlState()) where title == "Original Post" {
        post = repost.originalPost
      }
      destination.post = post
    } else if segue.identifier == segueIdentifierThisToBoard {
      let destination = segue.destination as! BoardTableViewController
      if let repost = post as? Repost where originalPost {
        post = repost.originalPost
      }
      destination.board = post.board
    } else if segue.identifier == segueIdentifierThisToUser {
      let destination = segue.destination as! UserTableViewController
      if let repost = post as? Repost where originalPost {
        post = repost.originalPost
      }
      destination.user = post.user
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.separatorStyle = .none
  }
  
  // MARK: UITableViewDataSource
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return dequeueAndSetupPostCellForIndexPath(indexPath)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return posts.count
  }

  // MARK: UITableViewDelegate
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    performSegue(withIdentifier: segueIdentifierThisToPost, sender: indexPath)
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let post = posts[(indexPath as NSIndexPath).row]
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
  func dequeueAndSetupPostCellForIndexPath(_ indexPath: IndexPath) -> PostCell {
    let post = posts[(indexPath as NSIndexPath).row]
    let cell: PostCell = {
      if let post = post as? Repost {
        return self.tableView.dequeueReusableCell(withIdentifier: StoryboardIdentifiers.repostCell, for: indexPath) as! RepostCell
      } else {
        return self.tableView.dequeueReusableCell(withIdentifier: StoryboardIdentifiers.postCell, for: indexPath) as! PostCell
      }
    }()
//    if let post = post as? Repost where post.originalPost.loadedImage == nil {
//      cell.loadImagesForPost(post) { image in
//        dispatch_async(dispatch_get_main_queue()) {
//          post.originalPost.loadedImage = image
//          self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
//        }
//      }
//    } else if !(post is Repost) && post.loadedImage == nil {
//      cell.loadImagesForPost(post) { image in
//        dispatch_async(dispatch_get_main_queue()) {
//          post.loadedImage = image
//          self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
//        }
//      }
//    }
    cell.makeCellFromPost(post, withButtonTag: (indexPath as NSIndexPath).row, maxContractedImageHeight: maxContractedImageHeight, andSeparatorHeight: separatorHeightForIndexPath(indexPath))
    cell.assignDelegatesForCellTo(self)
    return cell
  }
 
  func updateUIAfterUserBlockedAtIndex(_ index: Int) {
    DispatchQueue.main.async {
      let id = self.posts[index].user.userID
      var indexPaths = [IndexPath]()
      for (index,post) in enumerate(self.posts) {
        if post.user.userID == id {
          indexPaths.append(IndexPath(row: index, section: 0))
        }
      }
      self.posts = self.posts.filter { element in
        element.user.userID != id
      }
      self.tableView.beginUpdates()
      self.tableView.deleteRows(at: indexPaths, with: .fade)
      self.tableView.endUpdates()
    }
  }
  
  /// Presents an AlertController with style `.AlertView` that asks the user for confirmation of logging out.
  ///
  /// :param: index The index of the post that triggered this alert.
  func presentBlockConfirmationAlertViewForIndex(_ index: Int) {
    let name = posts[index].user.name
    if objc_getClass("UIAlertController") != nil {
      let alert = UIAlertController(title: "Block Confirmation", message: "Are you sure you want to block \(name)?", preferredStyle: .alert)
      let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
        self.blockUserAtIndex(index) { success in
          if success {
            DispatchQueue.main.async {
              UIAlertView(title: "\(name) Blocked", message: nil, delegate: nil, cancelButtonTitle: "Ok").show()
              self.updateUIAfterUserBlockedAtIndex(index)
            }
          }
        }
      }
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
      }
      alert.addAction(yesAction)
      alert.addAction(cancelAction)
      present(alert, animated: true, completion: nil)
    } else {
      let alert = UIAlertView(title: "Block Confirmation", message: "Are you sure you want to block \(name)?", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "Yes", "Cancel")
      alert.tag = index
      alert.show()
    }
  }
  
  /// Presents an AlertController with style `.ActionSheet` that prompts the user with various possible additional actions.
  ///
  /// :param: index The index of the post that triggered this action sheet.
  func presentMenuActionSheetForIndex(_ index: Int, iPadReference: UIButton?) {
    if objc_getClass("UIAlertController") != nil {
      let actionSheet = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
      let flagAction = UIAlertAction(title: "Flag", style: .default) { _ in
        self.flagPostAtIndex(index) { success in
          if success {
            UIAlertView(title: "Post flagged", message: "Thanks for helping make Cillo a better place!", delegate: nil, cancelButtonTitle: "Ok").show()
          }
        }
      }
      let blockAction = UIAlertAction(title: "Block User", style: .default) { _ in
        self.presentBlockConfirmationAlertViewForIndex(index)
      }
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
      }
      actionSheet.addAction(flagAction)
      actionSheet.addAction(blockAction)
      actionSheet.addAction(cancelAction)
      if let iPadReference = iPadReference where UIDevice.current.userInterfaceIdiom == .pad {
        actionSheet.modalPresentationStyle = .popover
        let popPresenter = actionSheet.popoverPresentationController
        popPresenter?.sourceView = iPadReference
        popPresenter?.sourceRect = iPadReference.bounds
      }
      present(actionSheet, animated: true, completion: nil)
    } else {
      let actionSheet = UIActionSheet(title: "More", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Flag", "Block User")
      actionSheet.cancelButtonIndex = 2
      actionSheet.tag = index
      if let iPadReference = iPadReference where UIDevice.current.userInterfaceIdiom == .pad {
        actionSheet.show(from: iPadReference.bounds, in: view, animated: true)
      } else {
        actionSheet.show(in: view)
      }
    }
  }
  
  /// Calculates the correct separator height inbetween cells of `tableView`.
  ///
  /// :param: indexPath The index path of the cell in the `tableView`.
  ///
  /// :returns: The correct separator height, as specified by the `dividerHeight` constant.
  func separatorHeightForIndexPath(_ indexPath: IndexPath) -> CGFloat {
    return (indexPath as NSIndexPath).row != posts.count - 1 ? dividerHeight : 0
  }
  
  // MARK: Networking Helper Functions
  
  /// Sends block user request to Cillo Servers for the post at the specified index.
  ///
  /// :param: index The index of the post being upvoted in `posts`.
  /// :param: completionHandler The completion block for the upvote.
  /// :param: success True if block request was successful. If error was received, false.
  func blockUserAtIndex(_ index: Int, completionHandler: (success: Bool) -> ()) {
    DataManager.sharedInstance.blockUser(posts[index].user) { result in
      self.handleSuccessResponse(result, completionHandler: completionHandler)
    }
  }
  
  /// Sends downvote request to Cillo Servers for the post at the specified index.
  ///
  /// :param: index The index of the post being upvoted in `posts`.
  /// :param: completionHandler The completion block for the upvote.
  /// :param: success True if downvote request was successful. If error was received, false.
  func downvotePostAtIndex(_ index: Int, completionHandler: (success: Bool) -> ()) {
    DataManager.sharedInstance.downvotePostWithID(posts[index].postID) { result in
      self.handleSuccessResponse(result, completionHandler: completionHandler)
    }
  }
  
  /// Sends flag post request to Cillo Servers for the post at the specified index.
  ///
  /// :param: index The index of the post being upvoted in `posts`.
  /// :param: completionHandler The completion block for the upvote.
  /// :param: success True if flag request was successful. If error was received, false.
  func flagPostAtIndex(_ index: Int, completionHandler: (success: Bool) -> ()) {
    DataManager.sharedInstance.flagPost(posts[index]) { result in
      self.handleSuccessResponse(result, completionHandler: completionHandler)
    }
  }
  
  /// Sends upvote request to Cillo Servers for the post at the specified index.
  ///
  /// :param: index The index of the post being upvoted in `posts`.
  /// :param: completionHandler The completion block for the upvote.
  /// :param: success True if upvote request was successful. If error was received, false.
  func upvotePostAtIndex(_ index: Int, completionHandler: (success: Bool) -> ()) {
    DataManager.sharedInstance.upvotePostWithID(posts[index].postID) { result in
      self.handleSuccessResponse(result, completionHandler: completionHandler)
    }
  }
  
  // MARK: IBActions
  
  /// Downvotes a post.
  ///
  /// **Note:** The position of the Post to be downvoted is known via the tag of the button.
  ///
  /// :param: sender The button that is touched to send this function is a downvoteButton in a PostCell.
  @IBAction func downvotePostPressed(_ sender: UIButton) {
    let post = self.posts[sender.tag]
    if post.voteValue != -1 {
      downvotePostAtIndex(sender.tag) { success in
        if success {
          DispatchQueue.main.async {
            post.downvote()
            let postIndexPath = IndexPath(row: sender.tag, section: 0)
            self.tableView.reloadRows(at: [postIndexPath], with: .none)
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
  @IBAction func goToOriginalPost(_ sender: UIButton) {
    if let post = posts[sender.tag - RepostCell.tagModifier] as? Repost {
      performSegue(withIdentifier: segueIdentifierThisToPost, sender: sender)
    }
  }
  
  /// Expands the image displayed in the button to full screen.
  ///
  /// :param: sender The button that is touched to send this function is an imagesButton in a PostCell.
  @IBAction func imageButtonPressed(_ sender: UIButton) {
//    let loadedImage: UIImage? = {
//      let post = self.posts[sender.tag]
//      if let post = post as? Repost {
//        return post.originalPost.loadedImage
//      } else {
//        return post.loadedImage
//      }
//      }()
//    if let loadedImage = loadedImage {
    //      JTSImageViewController.expandImage(loadedImage, toFullScreenFromRoot: self, withSender: sender)
    if let image = sender.imageView?.image {
      JTSImageViewController.expandImage(image, toFullScreenFromRoot: self, withSender: sender)
    }
  }
  
  /// Triggers an action sheet with a more actions menu.
  ///
  /// **Note:** The position of the Post to show menu for is known via the tag of the button.
  ///
  /// :param: sender The button that is touched to send this function is a moreButton in a PostCell.
  @IBAction func morePressed(_ sender: UIButton) {
    presentMenuActionSheetForIndex(sender.tag, iPadReference: sender)
  }
  
  /// Reposts a post.
  ///
  /// **Note:** The position of the Post to be reposted is known via the tag of the button.
  ///
  /// :param: sender The button that is touched to send this function is a repostButton in a PostCell.
  @IBAction func repostPressed(_ sender: UIButton) {
    if let tabBarController = tabBarController as? TabViewController {
      tabBarController.performSegue(withIdentifier: SegueIdentifiers.tabToNewRepost, sender: posts[sender.tag])
    }
  }
  
  /// Expands `postTextView` in a PostCell to a height greater than `maxContractedHeight`.
  ///
  /// :param: sender The button that is touched to send this function is a `seeFullButton` in a PostCell.
  @IBAction func seeFullPressed(_ sender: UIButton) {
    let post = posts[sender.tag]
    if let post = post as? Repost, seeFull = post.originalPost.seeFull {
      post.originalPost.seeFull! = !seeFull
    } else if let seeFull = post.seeFull {
      post.seeFull! = !seeFull
    }
    tableView.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .none)
  }

  /// Triggers segue with identifier segueIdentifierThisToBoard.
  ///
  /// :param: sender The button that is touched to send this function is a boardButton in a PostCell or an originalBoardButton in a RepostCell.
  @IBAction func triggerBoardSegueOnButton(_ sender: UIButton) {
    performSegue(withIdentifier: segueIdentifierThisToBoard, sender: sender)
  }
  
  /// Triggers segue with identifier segueIdentifierThisToPost.
  ///
  /// :param: sender The button that is touched to send this function is a commentButton in a PostCell.
  @IBAction func triggerPostSegueOnButton(_ sender: UIButton) {
    performSegue(withIdentifier: segueIdentifierThisToPost, sender: sender)
  }
  
  /// Triggers segue with identifier segueIdentifierThisToUser.
  ///
  /// :param: sender The button that is touched to send this function is a nameButton or a pictureButton in a PostCell, or an originalNameButton or originalPictureButton in a RepostCell.
  @IBAction func triggerUserSegueOnButton(_ sender: UIButton) {
    performSegue(withIdentifier: segueIdentifierThisToUser, sender: sender)
  }

  /// Upvotes a post.
  ///
  /// **Note:** The position of the Post to be upvoted is known via the tag of the button.
  ///
  /// :param: sender The button that is touched to send this function is an upvoteButton in a PostCell.
  @IBAction func upvotePostPressed(_ sender: UIButton) {
    let post = posts[sender.tag]
    if post.voteValue != 1 {
      upvotePostAtIndex(sender.tag) { success in
        if success {
          DispatchQueue.main.async {
            post.upvote()
            let postIndexPath = IndexPath(row: sender.tag, section: 0)
            self.tableView.reloadRows(at: [postIndexPath], with: .none)
          }
        }
      }
    }
  }
}

// MARK: - UIActionSheetDelegate

extension MultiplePostsTableViewController: UIActionSheetDelegate {
  
  func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
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
  
  func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
    if buttonIndex == 1 {
      blockUserAtIndex(alertView.tag) { success in
        if success {
          DispatchQueue.main.async {
            UIAlertView(title: "\(self.posts[alertView.tag].user.name) Blocked", message: nil, delegate: nil, cancelButtonTitle: "Ok").show()
            self.updateUIAfterUserBlockedAtIndex(alertView.tag)
          }
        }
      }
    }
  }
}

