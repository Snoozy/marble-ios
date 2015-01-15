//
//  SingleGroupTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 1/5/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Inherit this class for any UITableViewController that is a GroupCell followed by PostCells.
///
/// **Note:** Subclasses must override SegueIdentifierThisToPost.
class SingleGroupTableViewController: UITableViewController {

  // MARK: Properties
  
  /// Group that is shown in this UITableViewController.
  var group: Group = Group()
  
  /// Posts for this UITableViewController.
  var posts: [Post] = []
  
  // MARK: Constants 
  
  /// Segue Identifier in Storyboard for this UITableViewController to PostTableViewController.
  ///
  /// **Note:** Subclasses must override this Constant.
  var SegueIdentifierThisToPost: String {
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
  
  /// Segue Identifier in Storyboard for this UITableViewController to NewPostViewController.
  ///
  /// **Note:** Subclasses must override this Constant.
  var SegueIdentifierThisToNewPost: String {
    get {
      return ""
    }
  }
  
  // MARK: UIViewController
  
  /// Handles passing of data when navigation between UIViewControllers occur.
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == SegueIdentifierThisToPost {
      var destination = segue.destinationViewController as PostTableViewController
      if let sender = sender as? UIButton {
        destination.post = posts[sender.tag]
      } else if let sender = sender as? NSIndexPath {
        destination.post = posts[sender.section - 1]
      }
    } else if segue.identifier == SegueIdentifierThisToUser {
      var destination = segue.destinationViewController as UserTableViewController
      if let sender = sender as? UIButton {
        destination.user = posts[sender.tag].user
      }
    } else if segue.identifier == SegueIdentifierThisToNewPost {
      var destination = segue.destinationViewController as NewPostViewController
      destination.group = group
    }
  }
  
  // MARK: UITableViewDataSource
  
  /// Assigns the number of sections based on length of the posts array.
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return posts.count + 1
  }
  
  /// Assigns 1 row to each section in this UITAbleViewController.
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  /// Creates GroupCell or PostCell based on section number of indexPath.
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.row == 0 { // Make a GroupCell for only first row
      let cell = tableView.dequeueReusableCellWithIdentifier(GroupCell.ReuseIdentifier, forIndexPath: indexPath) as GroupCell
      
      cell.makeCellFromGroup(group, withButtonTag: 0)
      
      return cell
    } else {
      let post = posts[indexPath.section - 1]
      var cell: PostCell
      if let post = post as? Repost {
        cell = tableView.dequeueReusableCellWithIdentifier(RepostCell.ReuseIdentifier, forIndexPath: indexPath) as RepostCell
      } else {
        cell = tableView.dequeueReusableCellWithIdentifier(PostCell.ReuseIdentifier, forIndexPath: indexPath) as PostCell
      }
      
      cell.makeCellFromPost(post, withButtonTag: indexPath.section - 1)
      
      return cell
    }
  }
  
  // MARK: UITableViewDelegate
  
  /// Sets height of divider inbetween cells.
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return section == 0 ? 0 : section == 1 ? 5 : 10
  }
  
  /// Makes divider inbetween cells blue.
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView()
    view.backgroundColor = UIColor.cilloBlue()
    return view
  }
  
  /// Sets height of cell to appropriate value depending on length of post and whether post is expanded.
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.section == 0 {
      return group.heightOfDescripWithWidth(PrototypeTextViewWidth) + GroupCell.AdditionalVertSpaceNeeded
    }
    let post = posts[indexPath.section - 1]
    let height = post.heightOfPostWithWidth(PrototypeTextViewWidth, andMaxContractedHeight: MaxContractedHeight) + (post is Repost ? RepostCell.AdditionalVertSpaceNeeded : PostCell.AdditionalVertSpaceNeeded)
    return post.title != nil ? height : height - PostCell.TitleHeight
  }
  
  /// Sends view to PostTableViewController if PostCell is selected.
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.section != 0 {
      self.performSegueWithIdentifier(SegueIdentifierThisToPost, sender: indexPath)
    }
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
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
  
  /// Sends follow request to Cillo Servers for group represented by this UIViewController.
  ///
  /// :param: completion The completion block for the upvote.
  /// :param: success True if follow request was successful. If error was received, it is false.
  func followGroup(completion: (success: Bool) -> Void) {
    DataManager.sharedInstance.groupFollow(group.groupID, completion: { (error, success) -> Void in
      if error != nil {
        println(error!)
        error!.showAlert()
        completion(success: false)
      } else {
        if success {
          completion(success: true)
          let groupIndexPath = NSIndexPath(forRow: 0, inSection: 0)
          self.tableView.reloadRowsAtIndexPaths([groupIndexPath], withRowAnimation: .None)
        }
      }
    })
  }
  
  /// Sends unfollow request to Cillo Servers for group represented by this UIViewController.
  ///
  /// :param: completion The completion block for the upvote.
  /// :param: success True if follow request was unsuccessful. If error was received, it is false.
  func unfollowGroup(completion: (success: Bool) -> Void) {
    DataManager.sharedInstance.groupUnfollow(group.groupID, completion: { (error, success) -> Void in
      if error != nil {
        println(error!)
        error!.showAlert()
        completion(success: false)
      } else {
        if success {
          completion(success: true)
          let groupIndexPath = NSIndexPath(forRow: 0, inSection: 0)
          self.tableView.reloadRowsAtIndexPaths([groupIndexPath], withRowAnimation: .None)
        }
      }
    })
  }
  
  // MARK: IBActions
  
  /// Expands postTextView.
  ///
  /// :param: sender The button that is touched to send this function is a seeFullButton in a PostCell.
  @IBAction func seeFullPressed(sender: UIButton) {
    let post = posts[sender.tag]
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
  
  /// Triggers segue to UserTableViewController.
  ///
  /// :param: sender The button that is touched to send this function is a nameButton or a pictureButton in a PostCell.
  @IBAction func triggerUserSegueOnButton(sender: UIButton) {
    self.performSegueWithIdentifier(SegueIdentifierThisToUser, sender: sender)
  }

  /// Triggers segue to NewPostViewController.
  ///
  /// :param: sender The button that is touched to send this function is the button in the navigationBar.
  @IBAction func triggerNewPostSegueOnButton(sender: UIButton) {
    self.performSegueWithIdentifier(SegueIdentifierThisToNewPost, sender: sender)
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
          let postIndexPath = NSIndexPath(forRow: 0, inSection: sender.tag)
          self.tableView.reloadRowsAtIndexPaths([postIndexPath], withRowAnimation: .None)
        }
      })
    }
  }
  
  /// Either follows group or presents an ActionSheet to unfollow group.
  ///
  /// :param: sender The button that is touched to send this function is a followButton in a GroupCell.
  @IBAction func followOrUnfollowGroup(sender: UIButton) {
    if !group.following {
      followGroup( { (success) -> Void in
        if success {
          self.group.following = true
        }
      })
    } else {
      let actionSheet = UIAlertController(title: group.name, message: nil, preferredStyle: .ActionSheet)
      let unfollowAction = UIAlertAction(title: "Unfollow", style: .Default, handler: { (action) in
        self.unfollowGroup( { (success) -> Void in
          if success {
            self.group.following = false
          }
        })
      })
      let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
      })
      actionSheet.addAction(unfollowAction)
      actionSheet.addAction(cancelAction)
      presentViewController(actionSheet, animated: true, completion: nil)
    }
  }
  
}
