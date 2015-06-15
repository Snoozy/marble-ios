//
//  SingleUserTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 12/19/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

/// Inherit this class for any UITableViewController that is a UserCell followed by PostCells and CommentCells.
///
/// **Note:** Subclasses must override segueIdentifierThisToPost, segueIdentifierThisToBoard and segueIdentifierThisToBoards.
class SingleUserTableViewController: CustomTableViewController {
  
  // MARK: Enums
  
  /// Titles of segments of segmented control in the headerview of section 1 in `tableView`.
  ///
  /// * Posts: Title of segment with index 0.
  /// * Comments: Title of segment with index 1.
  enum SegIndex {
    case Posts, Comments
  }
  
  // MARK: Structs
  
  /// Configuration constants related to segmented control in the headerview of section 1 in `tableView`
  struct SegControlConstants {
    
    /// Font of the segmented control
    static let font = UIFont.boldSystemFontOfSize(14.0)
    
    /// Height of the segmented control
    static let height: CGFloat = 28.0
    
    /// Distance from each side of the screen to the segmented control
    static let margins: CGFloat = 6.0
  }
  
  // MARK: Properties
  
  /// Corresponds to the selected segmentIndex of the segmented control in the headerview of section 1 of `tableView`.
  var cellsShown = SegIndex.Posts
  
  /// Comments made by `user`.
  var comments = [Comment]()
  
  /// Page marker used to retrieve 20 comments from the server at a time.
  var commentsPageNumber = 1
  
  /// Flag that is only false when comments and posts have not attempted to be retrieved yet.
  var dataRetrieved = false
  
  /// Posts made by `user`.
  var posts = [Post]()
  
  /// Page marker used to retrieve 20 posts from the server at a time.
  var postsPageNumber = 1
  
  /// User that this view controller is representing.
  var user = User()
  
  // MARK: Constants
  
  /// The standard dividerHeight between CommentCells in `tableView`.
  let commentDividerHeight = DividerScheme.defaultScheme.singleUserCommentDividerHeight()
  
  /// The height on screen of the cells containing only single labels
  var heightOfSingleLabelCells: CGFloat {
    return 40.0
  }
  
  /// The standard dividerHeight between PostCells in `tableView`.
  let postDividerHeight = DividerScheme.defaultScheme.singleUserPostDividerHeight()
  
  /// Segue Identifier in Storyboard for segue to PostTableViewController.
  ///
  /// **Note:** Subclasses must override this Constant.
  var segueIdentifierThisToPost: String {
    fatalError("Subclasses of SingleUserTableViewController must override segue identifiers")
  }
  
  /// Segue Identifier in Storyboard for segue to BoardTableViewController.
  ///
  /// **Note:** Subclasses must override this Constant.
  var segueIdentifierThisToBoard: String {
    fatalError("Subclasses of SingleUserTableViewController must override segue identifiers")

  }
  
  /// Segue Identifier in Storyboard for segue to BoardsTableViewController.
  ///
  /// **Note:** Subclasses must override this Constant.
  var segueIdentifierThisToBoards: String {
    fatalError("Subclasses of SingleUserTableViewController must override segue identifiers")

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
    if segue.identifier == segueIdentifierThisToPost {
      var destination = segue.destinationViewController as! PostTableViewController
      switch cellsShown {
      case .Posts:
        var post = posts[index]
        if let repost = post as? Repost {
          destination.mainShowImages = repost.originalPost.showImages
          if let sender = sender as? UIButton, title = sender.titleForState(.Normal) where title == "Original Post" {
            post = repost.originalPost
          }
        } else {
          destination.mainShowImages = post.showImages
        }
        destination.post = post
      case .Comments:
        destination.post = comments[index].post
      }
    } else if segue.identifier == segueIdentifierThisToBoard {
      var destination = segue.destinationViewController as! BoardTableViewController
      switch cellsShown {
      case .Posts:
        var post = posts[index]
        if let repost = post as? Repost where originalPost {
          post = repost.originalPost
        }
        destination.board = post.board
      case .Comments:
        break
      }
    } else if segue.identifier == segueIdentifierThisToBoards {
      var destination = segue.destinationViewController as! BoardsTableViewController
      destination.userID = user.userID
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.separatorStyle = .None
  }
  
  // MARK: UITableViewDataSource
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // UserCell is in separate section from Post/CommentCells to get sticky segmentedControl effect
    return 2
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      return dequeueAndSetupUserCellForIndexPath(indexPath)
    } else if !dataRetrieved {
      return dequeueAndSetupRetrievingDataCellForIndexPath(indexPath)
    } else {
      switch cellsShown {
      case .Posts:
        if posts.count == 0 {
          return dequeueAndSetupNoPostsCellForIndexPath(indexPath)
        } else {
          return dequeueAndSetupPostCellForIndexPath(indexPath)
        }
      case .Comments:
        if comments.count == 0 {
          return dequeueAndSetupNoCommentsCellForIndexPath(indexPath)
        } else {
          return dequeueAndSetupCommentCellForIndexPath(indexPath)
        }
      }
    }
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // UserCell section only has 1 cell
    if section == 0  || !dataRetrieved {
      return 1
    } else {
      switch cellsShown {
      case .Posts:
        if posts.count == 0 {
          return 1
        } else {
          return posts.count
        }
      case .Comments:
        if comments.count == 0 {
          return 1
        } else {
          return comments.count
        }
      }
    }
  }

  // MARK: UITableViewDelegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
    if indexPath.section != 0 && dataRetrieved {
      switch cellsShown {
      case .Posts where posts.count != 0:
        performSegueWithIdentifier(segueIdentifierThisToPost, sender: indexPath)
      case .Comments where comments.count != 0:
        performSegueWithIdentifier(segueIdentifierThisToPost, sender: indexPath)
      default:
        break
      }
    }
  }
  
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return section == 0 || !dataRetrieved ? 0 : SegControlConstants.height + SegControlConstants.margins * 2
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.section == 0 {
      return UserCell.heightOfUserCellForUser(user, withElementWidth: tableViewWidthWithMargins)
    } else if !dataRetrieved {
      return heightOfSingleLabelCells
    } else {
      switch cellsShown {
      case .Posts:
        if posts.count == 0 {
          return heightOfSingleLabelCells
        } else {
          return PostCell.heightOfPostCellForPost(posts[indexPath.row], withElementWidth: tableViewWidthWithMargins, maxContractedHeight: maxContractedHeight, andDividerHeight: separatorHeightForIndexPath(indexPath))
        }
      case .Comments:
        if comments.count == 0 {
          return heightOfSingleLabelCells
        } else {
          return CommentCell.heightOfCommentCellForComment(comments[indexPath.row], withElementWidth: tableViewWidthWithMargins, selectedState: false, andDividerHeight: separatorHeightForIndexPath(indexPath))
        }
      }
    }
  }
  
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    // Segmented Control gets placed in header view to get a sticky segmented control effect.
    if section == 1 && dataRetrieved {
      let view = UIView()
      view.backgroundColor = UIColor.whiteColor()
      
      view.addSubview(segmentedControlForHeaderView())
      
      let bottomBorder = UIView(frame: CGRect(x: 0, y: SegControlConstants.height + SegControlConstants.margins * 2 - 1, width: tableView.frame.size.width, height: 1))
      bottomBorder.backgroundColor = ColorScheme.defaultScheme.thinLineBackgroundColor()
      view.addSubview(bottomBorder)
      
      return view
    }
    return nil
  }
  
  // MARK: Setup Helper Functions
  
  /// Makes a CommentCell for the corresponding comment in `comments` based on the passed indexPath.
  ///
  /// :param: indexPath The index path of the cell to be created in the table view.
  ///
  /// :returns: The created CommentCell.
  func dequeueAndSetupCommentCellForIndexPath(indexPath: NSIndexPath) -> CommentCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.commentCell, forIndexPath: indexPath) as! CommentCell
    cell.makeCellFromComment(comments[indexPath.row], withSelected: false, andButtonTag: indexPath.row, andSeparatorHeight: separatorHeightForIndexPath(indexPath))
    cell.assignDelegatesForCellTo(self)
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
  
  /// Makes a single label UITableViewCell that says "Retrieving Posts and Comments..."
  ///
  /// :param: indexPath The index path of the cell to be created in the table view.
  ///
  /// :returns: The created RetrieivingDataCell.
  func dequeueAndSetupRetrievingDataCellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.retrievingDataCell, forIndexPath: indexPath) as! UITableViewCell
    return cell
  }

  /// Makes a UserCell for `user` based on the passed indexPath.
  ///
  /// :param: indexPath The index path of the cell to be created in the table view.
  ///
  /// :returns: The created UserCell.
  func dequeueAndSetupUserCellForIndexPath(indexPath: NSIndexPath) -> UserCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.userCell, forIndexPath: indexPath) as! UserCell
    cell.makeCellFromUser(user, withButtonTag: 0)
    cell.assignDelegatesForCellTo(self)
    return cell
  }
  
  /// Creates the segmented control to be displayed in the header view of section 1 of `tableView`.
  ///
  /// :returns: The created UISegmentedControl.
  func segmentedControlForHeaderView() -> UISegmentedControl {
    let segControl = UISegmentedControl(items: ["Posts", "Comments"])
    segControl.addTarget(self, action: "segmentedControlValueChanged:", forControlEvents: .ValueChanged)
    segControl.setTitleTextAttributes([NSFontAttributeName:SegControlConstants.font], forState: .Normal)
    switch cellsShown {
    case .Posts:
      segControl.selectedSegmentIndex = 0
    case .Comments:
      segControl.selectedSegmentIndex = 1
    }
    segControl.tintColor = ColorScheme.defaultScheme.segmentedControlSelectedColor()
    segControl.backgroundColor = ColorScheme.defaultScheme.segmentedControlUnselectedColor()
    segControl.layer.cornerRadius = 0
    segControl.frame = CGRect(x: SegControlConstants.margins, y: SegControlConstants.margins, width: tableView.frame.size.width - SegControlConstants.margins * 2, height: SegControlConstants.height)
    return segControl
  }
  
  /// Calculates the correct separator height inbetween cells of `tableView`.
  ///
  /// :param: indexPath The index path of the cell in the `tableView`.
  ///
  /// :returns: The correct separator height, as specified by the `postDividerHeight` and `commentDividerHeight` constants.
  func separatorHeightForIndexPath(indexPath: NSIndexPath) -> CGFloat {
    if indexPath.section == 0 {
      return 0.0
    }
    switch cellsShown {
    case .Posts:
      return indexPath.row != posts.count - 1 ? postDividerHeight : 0.0
    case .Comments:
      return indexPath.row != comments.count - 1 ? commentDividerHeight : 0.0
    }
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
  
  // MARK: Segmented Control Selectors
  
  /// Updates cellsShown based on the selectedSegmentIndex of sender.
  ///
  /// :param: sender The UISegmentedControl in section 1 header.
  func segmentedControlValueChanged(sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0:
      cellsShown = .Posts
    case 1:
      cellsShown = .Comments
    default:
      break
    }
    tableView.reloadData()
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
  
  /// Triggers segue to BoardTableViewController.
  ///
  /// :param: sender The button that is touched to send this function is a boardButton in a PostCell or an originalBoardButton in a RepostCell.
  @IBAction func triggerBoardSegueOnButton(sender: UIButton) {
    performSegueWithIdentifier(segueIdentifierThisToBoard, sender: sender)
  }
  
  /// Triggers segue to BoardsTableViewController.
  ///
  /// :param: sender The button that is touched to send this function is a boardsButton in a UserCell.
  @IBAction func triggerBoardsSegueOnButton(sender: UIButton) {
    performSegueWithIdentifier(segueIdentifierThisToBoards, sender: sender)
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
