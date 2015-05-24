//
//  UserCell.swift
//  Cillo
//
//  Created by Andrew Daley on 11/13/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit
import TTTAttributedLabel

/// Cell that corresponds to reuse identifier "User".
///
/// Used to format Users in UITableView.
class UserCell: UITableViewCell {
  
  // MARK: IBOutlets
  
  /// Displays profilePic property of User.
  @IBOutlet weak var pictureButton: UIButton!
  
  /// Displays name property of User.
  @IBOutlet weak var nameButton: UIButton!
  
  /// Displays username property of User.
  @IBOutlet weak var usernameButton: UIButton!
  
  /// Displays bio property of User.
  ///
  /// Height of this UITextView is calulated by heightOfBioWithWidth(_:) in User.
  @IBOutlet weak var bioTTTAttributedLabel: TTTAttributedLabel!
  
  /// Displays rep property of User.
  ///
  /// Text should display a bolded rep value followed by an unbolded " REP".
  ///
  /// **Note:** Use NSMutableAttributedString.twoFontString(firstHalf:firstFont:secondHalf:secondFont:) to format text properly.
  @IBOutlet weak var repLabel: UILabel!
  
  /// Displays numBoards propert of User.
  ///
  /// Text should display a bolded numBoards value followed by an unbolded " GROUPS".
  ///
  /// **Note:** Use NSMutableAttributedString.twoFontString(firstHalf:firstFont:secondHalf:secondFont:) to format text properly.
  @IBOutlet weak var boardsButton: UIButton!

  // MARK: Constants
  
  /// Height needed for all components of a UserCell excluding bioTextView in the Storyboard.
  ///
  /// **Note:** Height of bioTextView must be calculated based on it's text property.
  class var additionalVertSpaceNeeded: CGFloat {
    return 174
  }
  
  /// Font of the text contained within bioTextView.
  class var bioTTTAttributedLabelFont: UIFont {
    return UIFont.systemFontOfSize(15.0)
  }
  
  /// Font used for the word " REP" in repLabel.
  class var repFont: UIFont {
    return UIFont.systemFontOfSize(15.0)
  }
  
  /// Font used for the rep value in repLabel.
  class var repFontBold: UIFont {
    return UIFont.boldSystemFontOfSize(18.0)
  }
  
  /// Font used for the word " GROUPS" in boardsButton.
  class var boardsFont: UIFont {
    return UIFont.systemFontOfSize(15.0)
  }
  
  /// Font used for the numBoards value in boardsButton.
  class var boardsFontBold: UIFont {
    return UIFont.boldSystemFontOfSize(18.0)
  }
  
  // MARK: Helper Methods
  
  /// Makes this UserCell's IBOutlets display the correct values of the corresponding User.
  ///
  /// :param: user The corresponding User to be displayed by this UserCell.
  /// :param: buttonTag The tags of all buttons in this PostCell corresponding to their index in the array holding them.
  /// :param: * Pass the precise index of the post in its model array.
  func makeCellFromUser(user: User, withButtonTag buttonTag: Int) {
    let scheme = ColorScheme.defaultScheme
    
    pictureButton.setBackgroundImageForState(.Normal, withURL: user.profilePicURL)
    pictureButton.setBackgroundImageForState(.Highlighted, withURL: user.profilePicURL)
    nameButton.setTitle(user.name, forState: .Normal)
    nameButton.setTitle(user.name, forState: .Highlighted)
    usernameButton.setTitle("@\(user.username)", forState: .Normal)
    usernameButton.setTitle("@\(user.username)", forState: .Highlighted)
    
    bioTTTAttributedLabel.numberOfLines = 0
    bioTTTAttributedLabel.font = UserCell.bioTTTAttributedLabelFont
    bioTTTAttributedLabel.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
    bioTTTAttributedLabel.linkAttributes = [kCTForegroundColorAttributeName : UIColor.cilloBlue()]
    bioTTTAttributedLabel.text = user.bio
    
    pictureButton.tag = buttonTag
    nameButton.tag = buttonTag
    usernameButton.tag = buttonTag
    
    if user.isSelf {
      nameButton.setTitleColor(scheme.meTextColor(), forState: .Normal)
      nameButton.setTitleColor(scheme.meTextColor(), forState: .Highlighted)
    }
    
    // Make only the number in repLabel bold
    var repText = NSMutableAttributedString.twoFontString(firstHalf: String.formatNumberAsString(number: user.rep), firstFont: UserCell.repFontBold, secondHalf: " REP", secondFont: UserCell.repFont)
    repLabel.attributedText = repText
    
    // Make only the number in boardsButton bold
    var boardsText = NSMutableAttributedString.twoFontString(firstHalf: String.formatNumberAsString(number: user.boardCount), firstFont: UserCell.boardsFontBold, secondHalf: " BOARDS", secondFont: UserCell.boardsFont)
    boardsButton.setAttributedTitle(boardsText, forState: .Normal)
    boardsButton.tintColor = UIColor.blackColor()
  }
  
  func assignDelegatesForCellTo<T: UIViewController where T: TTTAttributedLabelDelegate>(delegate: T) {
    bioTTTAttributedLabel.delegate = delegate
  }
  
  class func heightOfUserCellForUser(user: User, withElementWidth width: CGFloat) -> CGFloat {
    return user.heightOfBioWithWidth(width) + UserCell.additionalVertSpaceNeeded
  }
}
