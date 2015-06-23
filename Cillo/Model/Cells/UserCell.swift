//
//  UserCell.swift
//  Cillo
//
//  Created by Andrew Daley on 11/13/14.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit
import TTTAttributedLabel

/// Cell that corresponds to reuse identifier "User".
///
/// Used to format Users in UITableView.
class UserCell: UITableViewCell {
  
  // MARK: IBOutlets
  
  /// Displays bio property of User.
  ///
  /// Height of this UITextView is calulated by heightOfBioWithWidth(_:) in User.
  @IBOutlet weak var bioTTTAttributedLabel: TTTAttributedLabel!
  
  /// Displays numBoards propert of User.
  ///
  /// Text should display a bolded numBoards value followed by an unbolded " GROUPS".
  ///
  /// **Note:** Use NSMutableAttributedString.twoFontString(firstHalf:firstFont:secondHalf:secondFont:) to format text properly.
  @IBOutlet weak var boardsButton: UIButton!

  /// Displays name property of User.
  @IBOutlet weak var nameButton: UIButton!
  
  /// Displays profilePic property of User.
  @IBOutlet weak var photoButton: UIButton!
  
  /// Displays rep property of User.
  ///
  /// Text should display a bolded rep value followed by an unbolded " REP".
  ///
  /// **Note:** Use NSMutableAttributedString.twoFontString(firstHalf:firstFont:secondHalf:secondFont:) to format text properly.
  @IBOutlet weak var repLabel: UILabel!

  /// Displays username property of User.
  @IBOutlet weak var usernameButton: UIButton!

  // MARK: Constants
  
  /// Height needed for all components of a UserCell excluding bioTextView in the Storyboard.
  ///
  /// **Note:** Height of bioTextView must be calculated based on it's text property.
  class var additionalVertSpaceNeeded: CGFloat {
    return 126
  }
  
  /// Font of the text contained within bioTextView.
  class var bioTTTAttributedLabelFont: UIFont {
    return UIFont.systemFontOfSize(15.0)
  }
  
  /// Font used for the word " GROUPS" in boardsButton.
  class var boardsFont: UIFont {
    return UIFont.systemFontOfSize(15.0)
  }
  
  /// Font used for the numBoards value in boardsButton.
  class var boardsFontBold: UIFont {
    return UIFont.boldSystemFontOfSize(18.0)
  }
  
  /// Font used for the word " REP" in repLabel.
  class var repFont: UIFont {
    return UIFont.systemFontOfSize(15.0)
  }
  
  /// Font used for the rep value in repLabel.
  class var repFontBold: UIFont {
    return UIFont.boldSystemFontOfSize(18.0)
  }

  // MARK: Setup Helper Functions
  
  /// Makes this UserCell's IBOutlets display the correct values of the corresponding User.
  ///
  /// :param: user The corresponding User to be displayed by this UserCell.
  /// :param: buttonTag The tags of all buttons in this PostCell corresponding to their index in the array holding them.
  /// :param: * Pass the precise index of the post in its model array.
  func makeCellFromUser(user: User, withButtonTag buttonTag: Int) {
    let scheme = ColorScheme.defaultScheme
    
    DataManager.sharedInstance.activeRequests++
    photoButton.setBackgroundImageForState(.Normal, withURL: user.photoURL)
    nameButton.setTitle(user.name, forState: .Normal)
    usernameButton.setTitle(user.usernameDisplay, forState: .Normal)
    
    photoButton.clipsToBounds = true
    photoButton.layer.cornerRadius = 5.0
    
    bioTTTAttributedLabel.setupWithText(user.bio, andFont: UserCell.bioTTTAttributedLabelFont)
    
    photoButton.tag = buttonTag
    nameButton.tag = buttonTag
    usernameButton.tag = buttonTag
    
    if user.isSelf {
      nameButton.setTitleColor(scheme.meTextColor(), forState: .Normal)
    }
    
    // Make only the number in repLabel bold
    var repText = NSMutableAttributedString.twoFontString(firstHalf: user.rep.fiveCharacterDisplay, firstFont: UserCell.repFontBold, secondHalf: " REP", secondFont: UserCell.repFont)
    repLabel.attributedText = repText
    
    // Make only the number in boardsButton bold
    let boardString = user.boardCount == 1 ? " BOARD" : " BOARDS"
    var boardsText = NSMutableAttributedString.twoFontString(firstHalf: user.boardCount.fiveCharacterDisplay, firstFont: UserCell.boardsFontBold, secondHalf: boardString, secondFont: UserCell.boardsFont)
    boardsButton.setAttributedTitle(boardsText, forState: .Normal)
    boardsButton.tintColor = UIColor.darkTextColor()
  }
  
  /// Assigns all delegates of cell to the given parameter.
  ///
  /// :param: delegate The delegate that will be assigned to elements of the cell pertaining to the required protocols specified in the function header.
  func assignDelegatesForCellTo<T: UIViewController where T: TTTAttributedLabelDelegate>(delegate: T) {
    bioTTTAttributedLabel.delegate = delegate
  }
  
  /// Calculates the height of the cell given the properties of `user`.
  ///
  /// :param: user The user that this cell is based on.
  /// :param: width The width of the cell in the tableView.
  /// :returns: The height that the cell should be in the tableView.
  class func heightOfUserCellForUser(user: User, withElementWidth width: CGFloat) -> CGFloat {
    return user.heightOfBioWithWidth(width) + UserCell.additionalVertSpaceNeeded
  }
}
