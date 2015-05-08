//
//  GroupCell.swift
//  Cillo
//
//  Created by Andrew Daley on 11/25/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit
import TTTAttributedLabel

// TODO: Handle following property of Group

/// Cell that corresponds to reuse identifier "Group".
///
/// Used to format Groups in UITableView.
class GroupCell: UITableViewCell {
  
  // MARK: IBOutlets
  
  /// Displays picture property of Group.
  @IBOutlet weak var pictureButton: UIButton!
  
  /// Displays name property of Group.
  @IBOutlet weak var nameButton: UIButton!
  
  /// Displays descrip property of Group.
  ///
  /// Height of this UITextView is calulated by heightOfDescripWithWidth(_:) in Group.
  @IBOutlet weak var descripTTTAttributedLabel: TTTAttributedLabel!
  
  /// Displays numFollowers property of Group.
  ///
  /// Text should display a bolded numFollowers value followed by an unbolded " FOLLOWERS".
  ///
  /// **Note:** Use NSMutableAttributedString.twoFontString(firstHalf:firstFont:secondHalf:secondFont:) to format text properly.
  @IBOutlet weak var followersLabel: UILabel!
  
  /// Follows or unfollows Group.
  @IBOutlet weak var followButton: UIButton!
  
  /// Custom border between cells.
  ///
  /// This IBOutlet may not be assigned in the storyboard, meaning the UITableViewController managing this cell wants totuse default UITableView separators.
  @IBOutlet weak var separatorView: UIView?
  
  /// Controls height of separatorView.
  ///
  /// Set constant to value of separatorHeight in the makeCellFromGroup(_:_:_:) function.
  @IBOutlet weak var separatorViewHeightConstraint: NSLayoutConstraint?
  
  // MARK: Constants
  
  /// Height needed for all components of a GroupCell excluding descripTextView in the Storyboard.
  ///
  /// **Note:** Height of descripTextView must be calculated based on it's text property.
  class var AdditionalVertSpaceNeeded: CGFloat {
    get {
      return 154
    }
  }
  
  /// Font of the text contained within descripTextView.
  class var DescripTTTAttributedLabelFont: UIFont {
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
  /// :param: buttonTag The tags of all buttons in this GroupCell corresponding to their index in the array holding them.
  /// :param: * Pass the precise index of the group in its model array.
  /// :param: separatorHeight The height of the custom separators at the bottom of this GroupCell.
  /// :param: * The default value is 0.0, meaning the separators will not show by default.
  func makeCellFromGroup(group: Group, withButtonTag buttonTag: Int, andSeparatorHeight separatorHeight: CGFloat = 0.0) {
    pictureButton.setBackgroundImageForState(.Normal, withURL: group.pictureURL)
    pictureButton.setBackgroundImageForState(.Highlighted, withURL: group.pictureURL)
    nameButton.setTitle(group.name, forState: .Normal)
    nameButton.setTitle(group.name, forState: .Highlighted)
    
    descripTTTAttributedLabel.numberOfLines = 0
    descripTTTAttributedLabel.font = GroupCell.DescripTTTAttributedLabelFont
    descripTTTAttributedLabel.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
    descripTTTAttributedLabel.linkAttributes = [kCTForegroundColorAttributeName : UIColor.cilloBlue()]
    descripTTTAttributedLabel.text = group.descrip
    
    pictureButton.tag = buttonTag
    nameButton.tag = buttonTag
    followButton.tag = buttonTag
    
    if !group.following {
      followButton.setTitle("Follow", forState: .Normal)
      followButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
    } else {
      followButton.setTitle("Following", forState: .Normal)
      followButton.setTitleColor(UIColor.upvoteGreen(), forState: .Normal)
    }
    
    // Make only the number in followersLabel bold
    var followersText = NSMutableAttributedString.twoFontString(firstHalf: String.formatNumberAsString(number: group.numFollowers), firstFont: GroupCell.FollowerFontBold, secondHalf: " FOLLOWERS", secondFont: GroupCell.FollowerFont)
    followersLabel.attributedText = followersText
    
    if let separatorView = separatorView {
      separatorView.backgroundColor = UIColor.cilloBlue()
      separatorViewHeightConstraint!.constant = separatorHeight
    }
  }
  
  class func heightOfGroupCellForGroup(group: Group, withElementWidth width: CGFloat, andDividerHeight dividerHeight: CGFloat) -> CGFloat {
    return group.heightOfDescripWithWidth(width) + GroupCell.AdditionalVertSpaceNeeded + dividerHeight
  }
  
  override func prepareForReuse() {
    separatorViewHeightConstraint?.constant = 0
  }
}
