//
//  SingleUserTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 12/19/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

// TODO: Image Posts

/// Inherit this class for any UITableViewController that is a UserCell followed by PostCells and CommentCells.
///
/// **Note:** Subclasses must override SegueIdentifierThisToPost, SegueIdentifierThisToGroup and SegueIdentifierThisToGroups.
class SingleUserTableViewController: CustomTableViewController {
  
  var postsPageNumber: Int = 1
  
  var commentsPageNumber: Int = 1
  
  // MARK: Properties
  
  /// User for this UIViewController.
  var user: User = User()
  
  /// Posts made by user.
  var posts: [Post] = []
  
  /// Comments made by user.
  var comments: [Comment] = []
  
  /// Corresponds to segmentIndex of postsSegControl in UserCell.
  var cellsShown = SegIndex.Posts
  
  // MARK: Constants
  
  /// Font used for the segment titles in the UISegmentedControl that is placed in the section 1 header.
  class var SegControlFont: UIFont {
    get {
      return UIFont.boldSystemFontOfSize(14.0)
    }
  }
  
  /// Height of the UISegmentedControl that is added to the section 1 header.
  class var SegmentedControlHeight: CGFloat {
    get {
      return 28.0
    }
  }
  
  class var SegmentedControlMargins: CGFloat {
    get {
      return 6
    }
  }
  
  /// Height of the custom divider UIViews at the bottom of the PostCells managed by this SingleUserTableViewController.
  class var PostDividerHeight: CGFloat {
    get {
      return 10.0
    }
  }
  
  /// Height of the custom divider UIViews at the bottom of the CommentCells managed by this SingleUserTableViewController.
  class var CommentDividerHeight: CGFloat {
    get {
      return 5.0
    }
  }
  
  /// Segue Identifier in Storyboard for this UITableViewController to PostTableViewController.
  ///
  /// **Note:** Subclasses must override this Constant.
  var SegueIdentifierThisToPost: String {
    get {
      return ""
    }
  }
  
  /// Segue Identifier in Storyboard for this UITableViewController to GroupTableViewController.
  ///
  /// **Note:** Subclasses must override this Constant.
  var SegueIdentifierThisToGroup: String {
    get {
      return ""
    }
  }
  
  /// Segue Identifier in Storyboard for this UITableViewController to GroupsTableViewController.
  ///
  /// **Note:** Subclasses must override this Constant.
  var SegueIdentifierThisToGroups: String {
    get {
      return ""
    }
  }
  
  // MARK: Enums
  
  /// Titles of postsSegControl's segments.
  ///
  /// * Posts: Title of segment with index 0.
  /// * Comments: Title of segment with index 1.
  enum SegIndex {
    case Posts, Comments
  }
  
  // MARK: UIViewController
  
  /// Removes the default separator from tableView to allow for the custom implementation of cell separators.
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.separatorStyle = .None
  }
  
  /// Handles passing of data when navigation between UIViewControllers occur.
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == SegueIdentifierThisToPost {
      var destination = segue.destinationViewController as! PostTableViewController
      switch cellsShown {
      case .Posts:
        if let sender = sender as? UIButton {
          let tag = sender.tag >= 1000000 ? sender.tag / 1000000 : sender.tag
          var post: Post
          if sender.titleForState(.Normal) != nil && sender.titleForState(.Normal)! == "Original Post" {
            if let repost = posts[tag] as? Repost {
              post = repost.originalPost
            } else {
              post = posts[tag]
            }
          } else {
            post = posts[tag]
          }
          destination.post = post
          if let post = post as? Repost {
            destination.mainShowImages = post.originalPost.showImages
          } else {
            destination.mainShowImages = post.showImages
          }
        } else if let sender = sender as? NSIndexPath {
          destination.post = posts[sender.row]
          if let post = posts[sender.row] as? Repost {
            destination.mainShowImages = post.originalPost.showImages
          } else {
            destination.mainShowImages = posts[sender.row].showImages
          }
        }
      case .Comments:
        if let sender = sender as? UIButton {
          let tag = sender.tag >= 1000000 ? sender.tag / 1000000 : sender.tag
          destination.post = comments[tag].post
        } else if let sender = sender as? NSIndexPath {
          destination.post = comments[sender.row].post
        }
      default:
        break
      }
    } else if segue.identifier == SegueIdentifierThisToGroup {
      var destination = segue.destinationViewController as! GroupTableViewController
      switch cellsShown {
      case .Posts:
        if let sender = sender as? UIButton {
          let tag = sender.tag >= 1000000 ? sender.tag / 1000000 : sender.tag
          let post = posts[tag]
          if let post = post as? Repost {
            if sender.tag < 1000000 {
              destination.group = post.group
            } else {
              destination.group = post.originalPost.group
            }
          } else {
            destination.group = post.group
          }
        }
      default:
        break
      }
    } else if segue.identifier == SegueIdentifierThisToGroups {
      var destination = segue.destinationViewController as! GroupsTableViewController
      destination.userID = user.userID
    }
  }
  
  
  // MARK: UITableViewDataSource
  
  /// Assigns number of sections based on the length of the User array corresponding to cellsShown.
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
  
  // Assigns 1 row to each section in this UITableViewController.
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch cellsShown {
    case .Posts:
      return section == 0 ? 1 : posts.count
    case .Comments:
      return section == 0 ? 1 : comments.count
    }
  }
  
  /// Creates UserCell, PostCell, or CommentCell based on section number of indexPath and value of cellsShown.
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      let cell = tableView.dequeueReusableCellWithIdentifier(UserCell.ReuseIdentifier, forIndexPath: indexPath) as! UserCell
      cell.makeCellFromUser(user, withButtonTag: 0)
      return cell
    } else {
      switch cellsShown {
      case .Posts:
        var cell: PostCell
        let post = posts[indexPath.row]
        if let post = post as? Repost {
          cell = tableView.dequeueReusableCellWithIdentifier(RepostCell.ReuseIdentifier, forIndexPath: indexPath) as! RepostCell
        } else {
          cell = tableView.dequeueReusableCellWithIdentifier(PostCell.ReuseIdentifier, forIndexPath: indexPath) as! PostCell
        }
        cell.makeCellFromPost(post, withButtonTag: indexPath.row, andSeparatorHeight: indexPath.row != posts.count - 1 ? SingleUserTableViewController.PostDividerHeight : 0.0)
        cell.postTextView.delegate = self
        (cell as? RepostCell)?.originalPostTextView.delegate = self
        return cell
      case .Comments:
        let cell = tableView.dequeueReusableCellWithIdentifier(CommentCell.ReuseIdentifier, forIndexPath: indexPath) as! CommentCell
        cell.makeCellFromComment(comments[indexPath.row], withSelected: false, andButtonTag: indexPath.row, andSeparatorHeight: indexPath.row != comments.count - 1 ? SingleUserTableViewController.CommentDividerHeight : 0.0)
        return cell
      }
    }
  }
  
  // MARK: UITableViewDelegate
  
  // TODO: Document
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return section == 0 ? 0 : SingleUserTableViewController.SegmentedControlHeight + SingleUserTableViewController.SegmentedControlMargins * 2
  }
  
  // TODO: Document
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if section == 1 {
      let view = UIView()
      view.backgroundColor = UIColor.whiteColor()
      
      let segControl = UISegmentedControl(items: ["Posts", "Comments"])
      segControl.addTarget(self, action: "segmentedControlValueChanged:", forControlEvents: .ValueChanged)
      segControl.setTitleTextAttributes([NSFontAttributeName:SingleUserTableViewController.SegControlFont], forState: .Normal)
      switch cellsShown {
      case .Posts:
        segControl.selectedSegmentIndex = 0
      case .Comments:
        segControl.selectedSegmentIndex = 1
      }
      segControl.tintColor = UIColor.grayColor()
      segControl.backgroundColor = UIColor.whiteColor()
      segControl.layer.cornerRadius = 0
      segControl.frame = CGRect(x: SingleUserTableViewController.SegmentedControlMargins, y: SingleUserTableViewController.SegmentedControlMargins, width: tableView.frame.size.width - SingleUserTableViewController.SegmentedControlMargins * 2, height: SingleUserTableViewController.SegmentedControlHeight)
      view.addSubview(segControl)
      
      let bottomBorder = UIView(frame: CGRect(x: 0, y: SingleUserTableViewController.SegmentedControlHeight + SingleUserTableViewController.SegmentedControlMargins * 2 - 1, width: tableView.frame.size.width, height: 1))
      bottomBorder.backgroundColor = UIColor.grayColor()
      view.addSubview(bottomBorder)
      
      return view
    }
    return nil
  }
  
  /// Sets height of cell to appropriate value based on value of cellsShown.
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.section == 0 {
      return UserCell.heightOfUserCellForUser(user, withElementWidth: PrototypeTextViewWidth)
    }
    switch cellsShown {
    case .Posts:
      let post = posts[indexPath.row]
      let dividerHeight = indexPath.row != posts.count - 1 ? SingleUserTableViewController.PostDividerHeight : 0
      return PostCell.heightOfPostCellForPost(post, withElementWidth: PrototypeTextViewWidth, maxContractedHeight: MaxContractedHeight, andDividerHeight: dividerHeight)
    case .Comments:
      let dividerHeight = indexPath.row != comments.count - 1 ? SingleUserTableViewController.CommentDividerHeight : 0
      return CommentCell.heightOfCommentCellForComment(comments[indexPath.row], withElementWidth: PrototypeTextViewWidth, selectedState: false, andDividerHeight: dividerHeight)
    }
  }
  
  /// Sends view to PostTableViewController if CommentCell or PostCell is selected.
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
    if indexPath.section != 0 {
      self.performSegueWithIdentifier(SegueIdentifierThisToPost, sender: indexPath)
    }
  }
  
  // MARK: Helper Functions
  
  /// Sends upvote request to Cillo Servers for the post that this UIViewController is representing.
  ///
  /// :param: index The index of the post being upvoted in the posts array.
  /// :param: completion The completion block for the upvote.
  /// :param: success True if upvote request was successful. If error was received, it is false.
  func upvotePostAtIndex(index: Int, completion: (success: Bool) -> Void) {
    DataManager.sharedInstance.postUpvote(posts[index].postID, completion: { (error, success) -> Void in
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
  /// :param: index The index of the post being upvoted in the posts array.
  /// :param: completion The completion block for the upvote.
  /// :param: success True if downvote request was successful. If error was received, it is false.
  func downvotePostAtIndex(index: Int, completion: (success: Bool) -> Void) {
    DataManager.sharedInstance.postDownvote(posts[index].postID, completion: { (error, success) -> Void in
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
  
  /// Expands postTextView.
  ///
  /// :param: sender The button that is touched to send this function is a seeFullButton in a PostCell.
  @IBAction func seeFullPressed(sender: UIButton) {
    var post = posts[sender.tag]
    if let post = post as? Repost {
      if post.originalPost.seeFull != nil {
        post.seeFull! = !post.seeFull!
      }
    } else {
      if post.seeFull != nil {
        post.seeFull! = !post.seeFull!
      }
    }
    tableView.reloadData()
  }
  
  @IBAction func showImagesPressed(sender: UIButton) {
    let post = posts[sender.tag]
    if let post = post as? Repost {
      if !post.originalPost.showImages {
        post.originalPost.showImages = !post.originalPost.showImages
      }
    } else {
      if !post.showImages {
        post.showImages = !post.showImages
      }
    }
    tableView.reloadData()
  }
  
  /// Triggers segue to PostTableViewController.
  ///
  /// :param: sender The button that is touched to send this function is a commentButton in a PostCell.
  @IBAction func triggerPostSegueOnButton(sender: UIButton) {
    self.performSegueWithIdentifier(SegueIdentifierThisToPost, sender: sender)
  }
  
  /// Triggers segue to GroupsTableViewController.
  ///
  /// :param: sender The button that is touched to send this function is a groupsButton in a UserCell.
  @IBAction func triggerGroupsSegueOnButton(sender: UIButton) {
    self.performSegueWithIdentifier(SegueIdentifierThisToGroups, sender: sender)
  }
  
  /// Triggers segue to GroupTableViewController.
  ///
  /// :param: sender The button that is touched to send this function is a groupButton in a PostCell or an originalGroupButton in a RepostCell.
  @IBAction func triggerGroupSegueOnButton(sender: UIButton) {
    self.performSegueWithIdentifier(SegueIdentifierThisToGroup, sender: sender)
  }
  
  /// Reposts a post.
  ///
  /// **Note:** The position of the Post to be reposted is known via the tag of the button.
  ///
  /// :param: sender The button that is touched to send this function is a repostButton in a PostCell.
  @IBAction func repostPressed(sender: UIButton) {
    if let tabBarController = tabBarController as? TabViewController {
      tabBarController.performSegueWithIdentifier(TabViewController.SegueIdentifierThisToNewRepost, sender: posts[sender.tag])
    }
  }
  
  /// Upvotes a post.
  ///
  /// **Note:** The position of the Post to be upvoted is known via the tag of the button.
  ///
  /// :param: sender The button that is touched to send this function is an upvoteButton in a PostCell.
  @IBAction func upvotePostPressed(sender: UIButton) {
    let post = self.posts[sender.tag]
    if post.voteValue != 1 {
      upvotePostAtIndex(sender.tag, completion: { (success) -> Void in
        if success {
          if post.voteValue == 0 {
            post.rep++
          } else if post.voteValue == -1 {
            post.rep += 2
          }
          post.voteValue = 1
          let postIndexPath = NSIndexPath(forRow: sender.tag, inSection: 1)
          self.tableView.reloadRowsAtIndexPaths([postIndexPath], withRowAnimation: .None)
        }
      })
    }
  }
  
  /// Downvotes a post.
  ///
  /// **Note:** The position of the Post to be downvoted is known via the tag of the button.
  ///
  /// :param: sender The button that is touched to send this function is a downvoteButton in a PostCell.
  @IBAction func downvotePostPressed(sender: UIButton) {
    let post = self.posts[sender.tag]
    if post.voteValue != -1 {
      downvotePostAtIndex(sender.tag, completion: { (success) -> Void in
        if success {
          if post.voteValue == 0 {
            post.rep--
          } else if post.voteValue == 1 {
            post.rep -= 2
          }
          post.voteValue = -1
          let postIndexPath = NSIndexPath(forRow: sender.tag, inSection: 1)
          self.tableView.reloadRowsAtIndexPaths([postIndexPath], withRowAnimation: .None)
        }
      })
    }
  }
  
  @IBAction func goToOriginalPost(sender: UIButton) {
    if let post = posts[sender.tag] as? Repost {
      performSegueWithIdentifier(SegueIdentifierThisToPost, sender: sender)
    }
  }
  
}
