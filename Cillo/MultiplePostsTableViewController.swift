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
/// Note: Subclasses must override SegueIdentifierThisToPost.
class MultiplePostsTableViewController: UITableViewController {
  
  // MARK: Properties
  
  /// Posts for this UITableViewController.
  var posts: [Post] = []
  
  // MARK: Constants
  
  /// Segue Identifier in Storyboard for this UITableViewController to PostTableViewController.
  ///
  /// Note: Subclasses must override this Constant.
  var SegueIdentifierThisToPost: String {
    get {
      return ""
    }
  }
  
  // MARK: UIViewController
  
  // Transfer selected Post to PostTableViewController.
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == SegueIdentifierThisToPost {
      var destination = segue.destinationViewController as PostTableViewController
      if let sender = sender as? UIButton {
        destination.post = posts[sender.tag]
      } else if let sender = sender as? NSIndexPath {
        destination.post = posts[sender.section]
      }
    }
  }
  
  // MARK: UITableViewDataSource
  
  // Assigns the number of sections based on length of the posts array.
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return posts.count
  }
  
  // Assigns 1 row to each section in this UITAbleViewController.
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  // Creates PostCell based on section number of indexPath.
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let post = posts[indexPath.section]
    var cell: PostCell
    if let post = post as? Repost {
      cell = tableView.dequeueReusableCellWithIdentifier(RepostCell.ReuseIdentifier, forIndexPath: indexPath) as RepostCell
    } else {
      cell = tableView.dequeueReusableCellWithIdentifier(PostCell.ReuseIdentifier, forIndexPath: indexPath) as PostCell
    }
    
    cell.makeCellFromPost(post, withButtonTag: indexPath.section)
    
    return cell
  }
  
  // MARK: UITableViewDelegate
  
  // Sets height of divider inbetween cells.
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return section == 0 ? 0 : 10
  }
  
  // Makes divider inbetween cells blue.
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView()
    view.backgroundColor = UIColor.cilloBlue()
    return view
  }
  
  // Sets height of cell to appropriate value depending on length of post and whether post is expanded.
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    let post = posts[indexPath.section]
    let height = post.heightOfPostWithWidth(PrototypeTextViewWidth, andMaxContractedHeight: MaxContractedHeight) + (post is Repost ? RepostCell.AdditionalVertSpaceNeeded : PostCell.AdditionalVertSpaceNeeded)
    return post.title != nil ? height : height - PostCell.TitleHeight
  }
  
  // Sends view to PostTableViewController if PostCell is selected.
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    self.performSegueWithIdentifier(SegueIdentifierThisToPost, sender: indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
  }
  
  //MARK: IBActions
  
  /// Expands post in PostCell of sender when seeFullButton is pressed.
  @IBAction func seeFullPressed(sender: UIButton) {
    let post = posts[sender.tag]
    if post.seeFull != nil {
      post.seeFull! = !post.seeFull!
    }
    tableView.reloadData()
  }
  
}
