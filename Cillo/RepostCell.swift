//
//  RepostCell.swift
//  Cillo
//
//  Created by Andrew Daley on 12/25/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

/// Cell that corresponds to reuse identifier "Repost". Used to format Posts with (repost = true) in UITableViews.
class RepostCell: PostCell {
  
  // MARK: - IBOutlets
  
  /// Displays group property of Post.
  @IBOutlet weak var repostGroupLabel: UILabel!
  
  // MARK: - Constants
  
  /// Height needed for all components of a RepostCell excluding postTextView in the Storyboard.
  ///
  /// Note: Height of postTextView must be calculated based on it's text property.
  override var AdditionalVertSpaceNeeded: CGFloat {
    get {
      return 149
    }
  }
  
  /// Reuse Identifier for this UITableViewCell.
  override var ReuseIdentifier: String {
    get {
      return "Repost"
    }
  }
  
  // MARK: - Helper Functions
  
  /// Makes this RepostCell's IBOutlets display the correct values of the corresponding Repost.
  ///
  /// Note: The implementation of this PostCell subclass will display repostUser as nameLabel.text and repostGroup as groupLabel.text.
  ///
  /// :param: post The corresponding Post to be displayed by this RepostCell.
  /// :param: buttonTag The tags of all buttons in this RepostCell.
  /// :param: * Pass either indexPath.section or indexPath.row for this parameter depending on the implementation of your UITableViewController.
  override func makeCellFromPost(post: Post, withButtonTag buttonTag: Int) {
    super.makeCellFromPost(post, withButtonTag: buttonTag)
    if post.repost {
      nameLabel.text = post.repostUser!
      groupLabel.text = post.repostGroup!
      repostGroupLabel.text = post.group
    }
  }
}
