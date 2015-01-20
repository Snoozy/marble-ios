//
//  RepostCell.swift
//  Cillo
//
//  Created by Andrew Daley on 12/25/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

// TODO: Rephrase the "Reposted from Group" to better show that it takes the User to the original Post.

/// Cell that corresponds to reuse identifier "Repost".
///
/// Used to format Posts with (repost = true) in UITableViews.
class RepostCell: PostCell {
  
  // MARK: IBOutlets
  
  /// Displays originalGroup.name property of Repost.
  @IBOutlet weak var originalGroupButton: UIButton!
  
  // MARK: Constants
  
  // Height needed for all components of a RepostCell excluding postTextView in the Storyboard.
  //
  // **Note:** Height of postTextView must be calculated based on it's text property.
  override class var AdditionalVertSpaceNeeded: CGFloat {
    get {
      return 149
    }
  }
  
  // Reuse Identifier for this UITableViewCell.
  override class var ReuseIdentifier: String {
    get {
      return "Repost"
    }
  }
  
  // MARK: Helper Functions
  
  /// Makes this RepostCell's IBOutlets display the correct values of the corresponding Repost.
  ///
  /// **Note:** The implementation of this PostCell subclass will display repostUser as nameLabel.text and repostGroup as groupLabel.text.
  ///
  /// :param: post The corresponding Post to be displayed by this RepostCell.
  /// :param: buttonTag The tags of all buttons in this RepostCell.
  /// :param: * Pass the precise index of the post in its model array.
  /// :param: separatorHeight The height of the custom separators at the bottom of this Post Cell.
  /// :param: * The default value is 0.0, meaning the separators will not show by default.
  override func makeCellFromPost(post: Post, withButtonTag buttonTag: Int, andSeparatorHeight separatorHeight: CGFloat = 0.0) {
    super.makeCellFromPost(post, withButtonTag: buttonTag)
    if let post = post as? Repost {
      originalGroupButton.setTitle(post.originalGroup.name, forState: .Normal)
      originalGroupButton.setTitle(post.originalGroup.name, forState: .Highlighted)
      originalGroupButton.tag = buttonTag
    }
  }
}
