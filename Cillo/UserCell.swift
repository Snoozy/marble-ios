//
//  UserCell.swift
//  Cillo
//
//  Created by Andrew Daley on 11/13/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

/// Cell that corresponds to reuse identifier "User". Used to format Users in UITableView.
class UserCell: UITableViewCell {
  
  // MARK: - IBOutlets
  
  /// Displays profilePic property of User.
  @IBOutlet weak var profilePicView: UIImageView!
  
  /// Displays name property of User.
  @IBOutlet weak var nameLabel: UILabel!
  
  /// Displays username property of User.
  @IBOutlet weak var usernameLabel: UILabel!
  
  /// Displays bio property of User.
  ///
  /// Height of this UITextView is calulated by heightOfBioWithWidth(_:) in User.
  @IBOutlet weak var bioTextView: UITextView!
  
  /// Displays rep property of User.
  ///
  /// Text should display a bolded rep value followed by an unbolded " REP".
  ///
  /// Note: Use NSMutableAttributedString.twoFontString(firstHalf:firstFont:secondHalf:secondFont:) to format text properly.
  @IBOutlet weak var repLabel: UILabel!
  
  /// Displays numGroups propert of User.
  ///
  /// Text should display a bolded numGroups value followed by an unbolded " GROUPS".
  ///
  /// Note: Use NSMutableAttributedString.twoFontString(firstHalf:firstFont:secondHalf:secondFont:) to format text properly.
  @IBOutlet weak var groupsButton: UIButton!
  
  /// Used to select the type of UITableViewCell is displayed under this UserCell in a SingleUserTableViewController.
  @IBOutlet weak var postsSegControl: UISegmentedControl!
  
  // MARK: - Enums
  
  /// Titles of postsSegControl's segments.
  ///
  /// * Posts: Title of segment with index 0.
  /// * Comments: Title of segment with index 1.
  enum SegIndex {
    case Posts, Comments
  }

  // MARK: - Constants
  
  /// Height needed for all components of a UserCell excluding bioTextView in the Storyboard.
  ///
  /// Note: Height of bioTextView must be calculated based on it's text property.
  class var AdditionalVertSpaceNeeded: CGFloat {
    get {
      return 215
    }
  }
  
  /// Font of the text contained within bioTextView.
  class var BioTextViewFont: UIFont {
    get {
      return UIFont.systemFontOfSize(15.0)
    }
  }
  
  /// Font used for the word " REP" in repLabel.
  class var RepFont: UIFont {
    get {
      return UIFont.systemFontOfSize(15.0)
    }
  }
  
  /// Font used for the rep value in repLabel.
  class var RepFontBold: UIFont {
    get {
      return UIFont.boldSystemFontOfSize(18.0)
    }
  }
  
  /// Font used for the word " GROUPS" in groupsButton.
  class var GroupsFont: UIFont {
    get {
      return UIFont.systemFontOfSize(15.0)
    }
  }
  
  /// Font used for the numGroups value in groupsButton.
  class var GroupsFontBold: UIFont {
    get {
      return UIFont.boldSystemFontOfSize(18.0)
    }
  }
  
  /// Font used for the segment titles in postsSegControl.
  class var SegControlFont: UIFont {
    get {
      return UIFont.boldSystemFontOfSize(12.0)
    }
  }
  
  /// Reuse Identifier for this UITableViewCell.
  class var ReuseIdentifier: String {
    get {
      return "User"
    }
  }
  
  
  // MARK: - Helper Methods
  
  /// Makes this UserCell's IBOutlets display the correct values of the corresponding User.
  ///
  /// :param: user The corresponding User to be displayed by this UserCell.
  func makeCellFromUser(user: User) {
    profilePicView.image = user.profilePic
    nameLabel.text = user.name
    usernameLabel.text = user.username
    
    bioTextView.text = user.bio
    bioTextView.font = UserCell.BioTextViewFont
    bioTextView.textContainer.lineFragmentPadding = 0
    bioTextView.textContainerInset = UIEdgeInsetsZero
    
    // Make only the number in repLabel bold
    var repText = NSMutableAttributedString.twoFontString(firstHalf: String.formatNumberAsString(number: user.rep), firstFont: UserCell.RepFontBold, secondHalf: " REP", secondFont: UserCell.RepFont)
    repLabel.attributedText = repText
    
    // Make only the number in groupsButton bold
    var groupsText = NSMutableAttributedString.twoFontString(firstHalf: String.formatNumberAsString(number: user.numGroups), firstFont: UserCell.GroupsFontBold, secondHalf: " GROUPS", secondFont: UserCell.GroupsFont)
    groupsButton.setAttributedTitle(groupsText, forState: .Normal)
    groupsButton.tintColor = UIColor.blackColor()
    
    postsSegControl.setTitleTextAttributes([NSFontAttributeName:UserCell.SegControlFont], forState: .Normal)
  }
  
}
