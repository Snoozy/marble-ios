//
//  MultiplePostsTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 12/18/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

/// Inherit this class for any UITableViewController that is only a table of PostCells.
///
/// **Note:** Subclasses must override SegueIdentifierThisToPost, SegueIdentifierThisToGroup, SegueIdentifierThisToUser, and SegueIdentifierThisToNewPost.
class MultiplePostsTableViewController: UITableViewController {
  
  // MARK: Properties
  
  /// Posts for this UITableViewController.
  var posts: [Post] = []
  
  // MARK: Constants
  
  /// Height of the custom divider UIViews at the bottom of the PostCells managed by this MultiplePostsTableViewController.
  class var DividerHeight: CGFloat {
    get {
      return 10.0
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
        destination.post = posts[sender.row]
      }
    } else if segue.identifier == SegueIdentifierThisToGroup {
      var destination = segue.destinationViewController as GroupTableViewController
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
    } else if segue.identifier == SegueIdentifierThisToUser {
      var destination = segue.destinationViewController as UserTableViewController
      if let sender = sender as? UIButton {
        destination.user = posts[sender.tag].user
      }
    } else if segue.identifier == SegueIdentifierThisToNewPost {
      // do not transmit any data
    }
  }
  
  /// Removes the default separator from tableView to allow for the custom implementation of cell separators.
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.separatorStyle = .None
  }
  
  // MARK: UITableViewDataSource
  
  /// Assigns the number of sections in tableView to 1.
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  /// Assigns the number of rows in tableView based on the size of the posts array.
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return posts.count
  }
  
  /// Creates PostCell based on row number of indexPath.
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let post = posts[indexPath.row]
    var cell: PostCell
    if let post = post as? Repost {
      cell = tableView.dequeueReusableCellWithIdentifier(RepostCell.ReuseIdentifier, forIndexPath: indexPath) as RepostCell
    } else {
      cell = tableView.dequeueReusableCellWithIdentifier(PostCell.ReuseIdentifier, forIndexPath: indexPath) as PostCell
    }
    
    cell.makeCellFromPost(post, withButtonTag: indexPath.row, andSeparatorHeight: (indexPath.row != posts.count - 1 ? MultiplePostsTableViewController.DividerHeight : 0.0))
    
    return cell
  }
  
  // MARK: UITableViewDelegate
  
  /// Sets height of cell to appropriate value depending on length of post and whether post is expanded.
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    let post = posts[indexPath.row]
    var height = post.heightOfPostWithWidth(PrototypeTextViewWidth, andMaxContractedHeight: MaxContractedHeight) + (post is Repost ? RepostCell.AdditionalVertSpaceNeeded : PostCell.AdditionalVertSpaceNeeded)
    if indexPath.row != posts.count - 1 {
      height += MultiplePostsTableViewController.DividerHeight
    }
    return post.title != nil ? height : height - PostCell.TitleHeight
  }
  
  /// Sends view to PostTableViewController if PostCell is selected.
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    self.performSegueWithIdentifier(SegueIdentifierThisToPost, sender: indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
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
  
  /// Expands postTextView in a PostCell.
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
  
  /// Triggers segue to GroupTableViewController when groupButton is pressed in PostCell or originalGroupButton is pressed in RepostCell.
  ///
  /// :param: sender The button that is touched to send this function is a groupButton in a PostCell or an originalGroupButton in a RepostCell.
  @IBAction func triggerGroupSegueOnButton(sender: UIButton) {
    self.performSegueWithIdentifier(SegueIdentifierThisToGroup, sender: sender)
  }
  
  /// Triggers segue to NewPostViewController when button is pressed on navigationBar.
  @IBAction func triggerNewPostSegueOnButton(sender: UIButton) {
    self.performSegueWithIdentifier(SegueIdentifierThisToNewPost, sender: sender)
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
          let postIndexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
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
          let postIndexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
          self.tableView.reloadRowsAtIndexPaths([postIndexPath], withRowAnimation: .None)
        }
      })
    }
  }
  
}
