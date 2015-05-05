//
//  MultiplePostsTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 12/18/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

// TODO: Test Image Posts

/// Inherit this class for any UITableViewController that is only a table of PostCells.
///
/// **Note:** Subclasses must override SegueIdentifierThisToPost, SegueIdentifierThisToGroup, SegueIdentifierThisToUser, and SegueIdentifierThisToNewPost.
class MultiplePostsTableViewController: CustomTableViewController {
  
  var pageNumber: Int = 1
  
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
      var destination = segue.destinationViewController as! PostTableViewController
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
    } else if segue.identifier == SegueIdentifierThisToGroup {
      var destination = segue.destinationViewController as! GroupTableViewController
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
    } else if segue.identifier == SegueIdentifierThisToUser {
      var destination = segue.destinationViewController as! UserTableViewController
      if let sender = sender as? UIButton {
        let tag = sender.tag >= 1000000 ? sender.tag / 1000000 : sender.tag
        let post = posts[tag]
        if let post = post as? Repost {
          if sender.tag < 1000000 {
            destination.user = post.user
          } else {
            destination.user = post.originalPost.user
          }
        } else {
          destination.user = post.user
        }
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
      cell = tableView.dequeueReusableCellWithIdentifier(RepostCell.ReuseIdentifier, forIndexPath: indexPath) as! RepostCell
    } else {
      cell = tableView.dequeueReusableCellWithIdentifier(PostCell.ReuseIdentifier, forIndexPath: indexPath) as! PostCell
    }
    
    cell.makeCellFromPost(post, withButtonTag: indexPath.row, andSeparatorHeight: (indexPath.row != posts.count - 1 ? MultiplePostsTableViewController.DividerHeight : 0.0))
    
    cell.postTextView.delegate = self
    (cell as? RepostCell)?.originalPostTextView.delegate = self
    
    return cell
  }
  
  // MARK: UITableViewDelegate
  
  /// Sets height of cell to appropriate value depending on length of post and whether post is expanded.
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    let post = posts[indexPath.row]
    let dividerHeight = indexPath.row != posts.count - 1 ? MultiplePostsTableViewController.DividerHeight : 0
    return PostCell.heightOfPostCellForPost(post, withElementWidth: PrototypeTextViewWidth, maxContractedHeight: MaxContractedHeight, andDividerHeight: dividerHeight)
  }
  
  /// Sends view to PostTableViewController if PostCell is selected.
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
    self.performSegueWithIdentifier(SegueIdentifierThisToPost, sender: indexPath)
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
  
  // MARK: IBActions
  
  /// Expands postTextView in a PostCell.
  ///
  /// :param: sender The button that is touched to send this function is a seeFullButton in a PostCell.
  @IBAction func seeFullPressed(sender: UIButton) {
    let post = posts[sender.tag]
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
  
  @IBAction func goToOriginalPost(sender: UIButton) {
    if let post = posts[sender.tag] as? Repost {
      performSegueWithIdentifier(SegueIdentifierThisToPost, sender: sender)
    }
  }
  
}

