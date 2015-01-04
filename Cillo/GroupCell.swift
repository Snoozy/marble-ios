//
//  GroupCell.swift
//  Cillo
//
//  Created by Andrew Daley on 11/25/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

/// Cell that corresponds to reuse identifier "Group".
///
/// Used to format Groups in UITableView.
class GroupCell: UITableViewCell {
  
  // MARK: IBOutlets
  
  /// Displays picture property of Group.
  @IBOutlet weak var groupPicView: UIImageView!
  
  /// Displays name property of Group.
  @IBOutlet weak var nameLabel: UILabel!
  
  /// Displays descrip property of Group.
  ///
  /// Height of this UITextView is calulated by heightOfDescripWithWidth(_:) in Group.
  @IBOutlet weak var descripTextView: UITextView!
  
  /// Displays numFollowers property of Group.
  ///
  /// Text should display a bolded numFollowers value followed by an unbolded " FOLLOWERS".
  ///
  /// Note: Use NSMutableAttributedString.twoFontString(firstHalf:firstFont:secondHalf:secondFont:) to format text properly.
  @IBOutlet weak var followersLabel: UILabel!
  
  // MARK: Constants
  
  /// Height needed for all components of a GroupCell excluding descripTextView in the Storyboard.
  ///
  /// Note: Height of descripTextView must be calculated based on it's text property.
  class var AdditionalVertSpaceNeeded: CGFloat {
    get {
      return 154
    }
  }
  
  /// Font of the text contained within descripTextView.
  class var DescripTextViewFont: UIFont {
    get {
      return UIFont.systemFontOfSize(15.0)
    }
  }
  
  /// Font used for the word " FOLLOWERS" in followersLabel.
  class var FollowerFont: UIFont {
    get {
      return UIFont.systemFontOfSize(15.0)
    }
  }
  
  /// Font used for the numFollowers value in followersLabel.
  class var FollowerFontBold: UIFont {
    get {
      return UIFont.boldSystemFontOfSize(18.0)
    }
  }
  
  /// Reuse Identifier for this UITableViewCell.
  class var ReuseIdentifier: String {
    get {
      return "Group"
    }
  }
  
  // MARK: Helper Methods
  
  /// Makes this GroupCell's IBOutlets display the correct values of the corresponding Group.
  ///
  /// :param: group The corresponding Group to be displayed by this GroupCell.
  func makeCellFromGroup(group: Group) {
    groupPicView.image = group.picture
    nameLabel.text = group.name
    
    descripTextView.text = group.descrip
    descripTextView.font = GroupCell.DescripTextViewFont
    descripTextView.textContainer.lineFragmentPadding = 0
    descripTextView.textContainerInset = UIEdgeInsetsZero
    
    // Make only the number in followersLabel bold
    var followersText = NSMutableAttributedString.twoFontString(firstHalf: String.formatNumberAsString(number: group.numFollowers), firstFont: GroupCell.FollowerFontBold, secondHalf: " FOLLOWERS", secondFont: GroupCell.FollowerFont)
    followersLabel.attributedText = followersText
  }
  
}
