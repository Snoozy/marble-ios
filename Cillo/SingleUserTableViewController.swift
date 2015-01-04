//
//  SingleUserTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 12/19/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

// TODO: Find way to make UISegmentedControl stick to navigation bar when scrolled off screen.

/// Inherit this class for any UITableViewController that is a UserCell followed by PostCells and CommentCells.
///
/// Note: Subclasses must override SegueIdentifierThisToPost.
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
  /// Note: Subclasses must override this Constant.
  var SegueIdentifierThisToPost: String {
    get {
      return ""
    }
  }
  
  
  // MARK: UIViewController
  
  // Transfer selected Post to PostTableViewController
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == SegueIdentifierThisToPost {
      var destination = segue.destinationViewController as PostTableViewController
      switch cellsShown {
      case .Posts:
        if sender is UIButton {
          destination.post = posts[(sender as UIButton).tag - 1]
        } else if sender is NSIndexPath {
          destination.post = posts[(sender as NSIndexPath).section - 1]
        }
      case .Comments:
        if sender is NSIndexPath {
          destination.post = comments[(sender as NSIndexPath).section - 1].post
        }
      default:
        break
      }
    }
  }
  
  
  // MARK: UITableViewDataSource
  
  // Assigns number of sections based on the length of the User array corresponding to cellsShown.
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
  
  // Creates UserCell, PostCell, or CommentCell based on section number of indexPath and value of cellsShown.
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      let cell = tableView.dequeueReusableCellWithIdentifier(UserCell.ReuseIdentifier, forIndexPath: indexPath) as UserCell
      cell.makeCellFromUser(user)
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
        cell.makeCellFromPost(post, withButtonTag: indexPath.section)
        return cell
      case .Comments:
        let cell = tableView.dequeueReusableCellWithIdentifier(CommentCell.ReuseIdentifier, forIndexPath: indexPath) as CommentCell
        cell.makeCellFromComment(comments[indexPath.section - 1], withSelected: false)
        return cell
      default:
        return UITableViewCell()
      }
    }
  }
  
  // MARK: UITableViewDelegate
  
  // Sets height of divider inbetween cells.
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
  
  // Makes divider inbetween cells blue.
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView()
    view.backgroundColor = UIColor.cilloBlue()
    return view
  }
  
  // Sets height of cell to appropriate value based on value of cellsShown.
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
  
  // Sends view to PostTableViewController if CommentCell or PostCell is selected.
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
    if indexPath.section != 0 {
      self.performSegueWithIdentifier(SegueIdentifierThisToPost, sender: indexPath)
    }
  }
  
  
  // MARK: IBActions
  
  /// Updates cellsShown when the postsSegControl in UserCell changes its selectedIndex.
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
  
  /// Expands post in PostCell of sender when seeFullButton is pressed.
  @IBAction func seeFullPressed(sender: UIButton) {
    var post = posts[sender.tag]
    if post.seeFull != nil {
      post.seeFull! = !post.seeFull!
    }
    tableView.reloadData()
  }
  
}
