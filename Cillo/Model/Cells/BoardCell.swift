//
//  BoardCell.swift
//  Cillo
//
//  Created by Andrew Daley on 11/25/14.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit
import TTTAttributedLabel

/// Cell that corresponds to reuse identifier "Board".
///
/// Used to format Boards in UITableView.
class BoardCell: UITableViewCell {
  
  // MARK: IBOutlets
  
  /// Displays descrip property of Board.
  ///
  /// Height of this UITextView is calulated by heightOfDescripWithWidth(_:) in Board.
  @IBOutlet weak var descripTTTAttributedLabel: TTTAttributedLabel!
  
  /// Follows or unfollows Board.
  @IBOutlet weak var followButton: UIButton!
  
  /// Displays numFollowers property of Board.
  ///
  /// Text should display a bolded numFollowers value followed by an unbolded " FOLLOWERS".
  ///
  /// **Note:** Use NSMutableAttributedString.twoFontString(firstHalf:firstFont:secondHalf:secondFont:) to format text properly.
  @IBOutlet weak var followersLabel: UILabel!
  
  /// Displays name property of Board.
  @IBOutlet weak var nameButton: UIButton!
  
  /// Displays picture property of Board.
  @IBOutlet weak var photoButton: UIButton!

  /// Custom border between cells.
  ///
  /// This IBOutlet may not be assigned in the storyboard, meaning the UITableViewController managing this cell wants totuse default UITableView separators.
  @IBOutlet weak var separatorView: UIView?
  
  /// Controls height of separatorView.
  ///
  /// Set constant to value of separatorHeight in the makeCellFromBoard(_:_:_:) function.
  @IBOutlet weak var separatorViewHeightConstraint: NSLayoutConstraint?
  
  // MARK: Constants
  
  /// Height needed for all components of a BoardCell excluding descripTextView in the Storyboard.
  ///
  /// **Note:** Height of descripTextView must be calculated based on it's text property.
  class var additionalVertSpaceNeeded: CGFloat {
    return 90
  }
  
  /// Font of the text contained within descripTextView.
  class var descripTTTAttributedLabelFont: UIFont {
    return UIFont.systemFontOfSize(15.0)
  }
  
  /// Color of the border of `followButton`. Also is the color of the background when the button is filled (signifying that the user is following already).
  class var followButtonColor: UIColor {
    return UIColor.grayColor()
  }
  
  /// Font used for the word " FOLLOWERS" in followersLabel.
  class var followerFont: UIFont {
    return UIFont.systemFontOfSize(12.0)
  }
  
  /// Font used for the numFollowers value in followersLabel.
  class var followerFontBold: UIFont {
    return UIFont.boldSystemFontOfSize(14.0)
  }
  
  // MARK: UITableViewCell
  
  override func prepareForReuse() {
    separatorViewHeightConstraint?.constant = 0
  }
  
  // MARK: Setup Helper Functions
  
  /// Assigns all delegates of cell to the given parameter.
  ///
  /// :param: delegate The delegate that will be assigned to elements of the cell pertaining to the required protocols specified in the function header.
  func assignDelegatesForCellTo<T: UIViewController where T: TTTAttributedLabelDelegate>(delegate: T) {
    descripTTTAttributedLabel.delegate = delegate
  }
  
  /// Calculates the height of the cell given the properties of `board`.
  ///
  /// :param: board The board that this cell is based on.
  /// :param: width The width of the cell in the tableView.
  /// :param: dividerHeight The height of the `separatorView` in the tableView.
  /// :returns: The height that the cell should be in the tableView.
  class func heightOfBoardCellForBoard(board: Board, withElementWidth width: CGFloat, andDividerHeight dividerHeight: CGFloat) -> CGFloat {
    return board.heightOfDescripWithWidth(width) + BoardCell.additionalVertSpaceNeeded + dividerHeight
  }
  
  /// Makes this BoardCell's IBOutlets display the correct values of the corresponding Board.
  ///
  /// :param: board The corresponding Board to be displayed by this BoardCell.
  /// :param: buttonTag The tags of all buttons in this BoardCell corresponding to their index in the array holding them.
  /// :param: * Pass the precise index of the board in its model array.
  /// :param: separatorHeight The height of the custom separators at the bottom of this BoardCell.
  /// :param: * The default value is 0.0, meaning the separators will not show by default.
  func makeCellFromBoard(board: Board, withButtonTag buttonTag: Int, andSeparatorHeight separatorHeight: CGFloat = 0.0) {
    let scheme = ColorScheme.defaultScheme
    
    photoButton.setBackgroundImageToImageWithURL(board.photoURL, forState: .Normal)
    nameButton.setTitle(board.name, forState: .Normal)
    
    photoButton.clipsToBounds = true
    photoButton.layer.cornerRadius = 5.0
    
    descripTTTAttributedLabel.setupWithText(board.descrip, andFont: BoardCell.descripTTTAttributedLabelFont)
    
    photoButton.tag = buttonTag
    nameButton.tag = buttonTag
    followButton.tag = buttonTag
    
    followButton.setupWithRoundedBorderOfWidth(UIButton.standardBorderWidth, andColor: BoardCell.followButtonColor)
    if !board.following {
      followButton.setTitle("Follow", forState: .Normal)
      followButton.setTitleColor(UIColor.lighterBlack(), forState: .Normal)
      followButton.backgroundColor = UIColor.whiteColor()
    } else {
      followButton.setTitle("Following", forState: .Normal)
      followButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
      followButton.backgroundColor = BoardCell.followButtonColor
    }
    
    // Make only the number in followersLabel bold
    let followersString = board.followerCount == 1 ? " FOLLOWER" : " FOLLOWERS"
    var followersText = NSMutableAttributedString.twoFontString(firstHalf: board.followerCount.fiveCharacterDisplay, firstFont: BoardCell.followerFontBold, secondHalf: followersString, secondFont: BoardCell.followerFont)
    followersLabel.attributedText = followersText
    
    if let separatorView = separatorView {
      separatorView.backgroundColor = scheme.dividerBackgroundColor()
      separatorViewHeightConstraint!.constant = separatorHeight
    }
  }
}
