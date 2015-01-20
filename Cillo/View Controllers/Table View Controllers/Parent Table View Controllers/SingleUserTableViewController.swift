//
//  SingleUserTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 12/19/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

// TODO: Decide whether upvoting/downvoting from this screen is allowed.
// TODO: Revamp divider implementation
// TODO: Find way to make UISegmentedControl stick to navigation bar when scrolled off screen.

/// Inherit this class for any UITableViewController that is a UserCell followed by PostCells and CommentCells.
///
/// **Note:** Subclasses must override SegueIdentifierThisToPost, SegueIdentifierThisToGroup and SegueIdentifierThisToGroups.
class SingleUserTableViewController: UITableViewController {
  
  // MARK: Properties
  
  /// User for this UIViewController.
  var user: User = User()
  
  /// Posts made by user.
  var posts: [Post] = []
  
  /// Comments made by user.
  var comments: [Comment] = []
  
  /// Corresponds to segmentIndex of postsSegControl in UserCell.
  var cellsShown = UserCell.SegIndex.Posts
  
  
  // MARK: Constants
  
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
  
  // MARK: UIViewController
  
  /// Handles passing of data when navigation between UIViewControllers occur.
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == SegueIdentifierThisToPost {
      var destination = segue.destinationViewController as PostTableViewController
      switch cellsShown {
      case .Posts:
        if let sender = sender as? UIButton {
          destination.post = posts[sender.tag]
        } else if let sender = sender as? NSIndexPath {
          destination.post = posts[sender.section - 1]
        }
      case .Comments:
        if let sender = sender as? UIButton {
          destination.post = comments[sender.tag].post
        } else if let sender = sender as? NSIndexPath {
          destination.post = comments[sender.section - 1].post
        }
      default:
        break
      }
    } else if segue.identifier == SegueIdentifierThisToGroup {
      var destination = segue.destinationViewController as GroupTableViewController
      switch cellsShown {
      case .Posts:
        if let sender = sender as? UIButton {
          let post = posts[sender.tag]
          if sender.titleLabel?.text == post.group.name {
            destination.group = post.group
          } else if let post = post as? Repost {
            if sender.titleLabel?.text == post.originalGroup.name {
              destination.group = post.originalGroup
            }
          }
        }
      default:
        break
      }
    } else if segue.identifier == SegueIdentifierThisToGroups {
      var destination = segue.destinationViewController as GroupsTableViewController
      destination.userID = user.userID
    }
  }
  
  
  // MARK: UITableViewDataSource
  
  /// Assigns number of sections based on the length of the User array corresponding to cellsShown.
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    switch cellsShown {
    case .Posts:
      return 1 + posts.count
    case .Comments:
      return 1 + comments.count
    default:
      return 1
    }
  }
  
  // Assigns 1 row to each section in this UITableViewController.
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  /// Creates UserCell, PostCell, or CommentCell based on section number of indexPath and value of cellsShown.
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      let cell = tableView.dequeueReusableCellWithIdentifier(UserCell.ReuseIdentifier, forIndexPath: indexPath) as UserCell
      cell.makeCellFromUser(user, withButtonTag: 0)
      return cell
    } else {
      var cell: PostCell
      switch cellsShown {
      case .Posts:
        let post = posts[indexPath.section - 1]
        if let post = post as? Repost {
          cell = tableView.dequeueReusableCellWithIdentifier(RepostCell.ReuseIdentifier, forIndexPath: indexPath) as RepostCell
        } else {
          cell = tableView.dequeueReusableCellWithIdentifier(PostCell.ReuseIdentifier, forIndexPath: indexPath) as PostCell
        }
        cell.makeCellFromPost(post, withButtonTag: indexPath.section - 1)
        return cell
      case .Comments:
        let cell = tableView.dequeueReusableCellWithIdentifier(CommentCell.ReuseIdentifier, forIndexPath: indexPath) as CommentCell
        cell.makeCellFromComment(comments[indexPath.section - 1], withSelected: false, andButtonTag: indexPath.section - 1)
        return cell
      default:
        return UITableViewCell()
      }
    }
  }
  
  // MARK: UITableViewDelegate
  
  /// Sets height of divider inbetween cells.
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == 0 {
      return 0
    }
    switch cellsShown {
    case .Posts:
      return 10
    case .Comments:
      return 5
    default:
      return 0
    }
  }
  
  /// Makes divider inbetween cells blue.
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView()
    view.backgroundColor = UIColor.cilloBlue()
    return view
  }
  
  /// Sets height of cell to appropriate value based on value of cellsShown.
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.section == 0 {
      return user.heightOfBioWithWidth(PrototypeTextViewWidth) + UserCell.AdditionalVertSpaceNeeded
    }
    switch cellsShown {
    case .Posts:
      let post = posts[indexPath.section - 1]
      var height: CGFloat
      if let post = post as? Repost {
        height = post.heightOfPostWithWidth(PrototypeTextViewWidth, andMaxContractedHeight: MaxContractedHeight) + RepostCell.AdditionalVertSpaceNeeded
      } else {
        height = post.heightOfPostWithWidth(PrototypeTextViewWidth, andMaxContractedHeight: MaxContractedHeight) + PostCell.AdditionalVertSpaceNeeded
      }
      return post.title != nil ? height : height - PostCell.TitleHeight
    case .Comments:
      return comments[indexPath.section - 1].heightOfCommentWithWidth(PrototypeTextViewWidth, selected: false) + CommentCell.AdditionalVertSpaceNeeded - CommentCell.ButtonHeight
    default:
      return 0
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
  
  /// Sends create post request to Cillo Servers for the Post at the specified index in posts.
  ///
  /// **Note:** Create post is used to repost posts when given a repostID parameter.
  ///
  /// :param: index The index of the post being reposted in the posts array.
  /// :param: groupName The name of the group that the specified post is being reposted to.
  /// :param: completion The completion block for the repost.
  /// :param: success True if repost request was successful. If error was received, it is false.
  func repostPostAtIndex(index: Int, toGroupWithName groupName: String, completion: (success: Bool) -> Void) {
    let post = posts[index]
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
  
  // MARK: IBActions
  
  /// Updates cellsShown based on the selectedIndex of sender.
  ///
  /// :param: sender The postsSegControl in a UserCell.
  @IBAction func valueChanged(sender: UISegmentedControl) {
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
  
  /// Expands postTextView.
  ///
  /// :param: sender The button that is touched to send this function is a seeFullButton in a PostCell.
  @IBAction func seeFullPressed(sender: UIButton) {
    var post = posts[sender.tag]
    if post.seeFull != nil {
      post.seeFull! = !post.seeFull!
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
    let alert = UIAlertController(title: "Repost", message: "Which group are you reposting this post to?", preferredStyle: .Alert)
    let repostAction = UIAlertAction(title: "Repost", style: .Default, handler: { (action) in
      let groupName = alert.textFields![0].text
      self.repostPostAtIndex(sender.tag, toGroupWithName: groupName, completion: { (success) in
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
          let postIndexPath = NSIndexPath(forRow: 0, inSection: sender.tag)
          self.tableView.reloadRowsAtIndexPaths([postIndexPath], withRowAnimation: .None)
        }
      })
    }
  }
  
  /// Downvotes a psot.
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
          let postIndexPath = NSIndexPath(forRow: 0, inSection: sender.tag)
          self.tableView.reloadRowsAtIndexPaths([postIndexPath], withRowAnimation: .None)
        }
      })
    }
  }
  
}
