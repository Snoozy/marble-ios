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
  
  // MARK: UIViewController
  
  // Handles passing of data when navigation between UIViewControllers occur.
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
    }
  }
  
  // MARK: UITableViewDataSource
  
  // Assigns the number of sections based on length of the posts array.
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return posts.count + 1
  }
  
  // Assigns 1 row to each section in this UITAbleViewController.
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  // Creates GroupCell or PostCell based on section number of indexPath.
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
  
  // Sets height of divider inbetween cells.
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return section == 0 ? 0 : section == 1 ? 5 : 10
  }
  
  // Makes divider inbetween cells blue.
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView()
    view.backgroundColor = UIColor.cilloBlue()
    return view
  }
  
  // Sets height of cell to appropriate value depending on length of post and whether post is expanded.
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.section == 0 {
      return group.heightOfDescripWithWidth(PrototypeTextViewWidth) + GroupCell.AdditionalVertSpaceNeeded
    }
    let post = posts[indexPath.section - 1]
    let height = post.heightOfPostWithWidth(PrototypeTextViewWidth, andMaxContractedHeight: MaxContractedHeight) + (post is Repost ? RepostCell.AdditionalVertSpaceNeeded : PostCell.AdditionalVertSpaceNeeded)
    return post.title != nil ? height : height - PostCell.TitleHeight
  }
  
  // Sends view to PostTableViewController if PostCell is selected.
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.section != 0 {
      self.performSegueWithIdentifier(SegueIdentifierThisToPost, sender: indexPath)
    }
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
  }
  
  // Sends view to PostTableViewController if CommentCell or PostCell is selected.
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
    if indexPath.section != 0 {
      self.performSegueWithIdentifier(SegueIdentifierThisToPost, sender: indexPath)
    }
  }
  
  // MARK: IBActions
  
  /// Expands post in PostCell of sender when seeFullButton is pressed.
  @IBAction func seeFullPressed(sender: UIButton) {
    let post = posts[sender.tag]
    if post.seeFull != nil {
      post.seeFull! = !post.seeFull!
    }
    tableView.reloadData()
  }
  
  /// Triggers segue to PostTableViewController when commentButton is pressed in PostCell.
  @IBAction func triggerPostSegueOnButton(sender: UIButton) {
    self.performSegueWithIdentifier(SegueIdentifierThisToPost, sender: sender)
  }
  
  /// Triggers segue to UserTableViewController when nameButton or pictureButton is pressed in PostCell or CommentCell.
  @IBAction func triggerUserSegueOnButton(sender: UIButton) {
    self.performSegueWithIdentifier(SegueIdentifierThisToUser, sender: sender)
  }

}
