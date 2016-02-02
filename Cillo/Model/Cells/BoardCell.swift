//
//  BoardCell.swift
//  Cillo
//
//  Created by Andrew Daley on 11/25/14.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Cell that corresponds to reuse identifier "Board".
///
/// Used to format Boards in UITableView.
class BoardCell: UITableViewCell {
  
  // MARK: IBOutlets
  
  /// Displays descrip property of Board.
  ///
  /// Height of this UITextView is calulated by heightOfDescripWithWidth(_:) in Board.
  @IBOutlet weak var descripAttributedLabel: TTTAttributedLabel!
  
  /// Follows or unfollows Board.
  @IBOutlet weak var followButton: UIButton!
  
  /// Displays numFollowers property of Board.
  ///
  /// Text should display a bolded numFollowers value followed by an unbolded " MEMBERS".
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
  
  /// Struct containing all relevent fonts for the elements of a BoardCell.
  struct BoardFonts {
    
    /// Font of the text contained within descripAttributedLabelFont.
    static let descripAttributedLabelFont = UIFont.systemFontOfSize(15.0)
    
    static let followButtonFont: UIFont = {
      if let font = UIFont(name: "HelveticaNeue-Medium", size: 14) {
        return font
      } else {
        return UIFont.boldSystemFontOfSize(14.0)
      }
    }()
    
    /// Font used for the word " MEMBERS" in followersLabel.
    static let followerLabelFont = UIFont.systemFontOfSize(12.0)
    
    /// Font used for the followerCount value in followersLabel.
    static let followerCountFont = UIFont.boldSystemFontOfSize(14.0)
    
    /// Font of the text contained within nameButton.
    static let nameButtonFont = UIFont.boldSystemFontOfSize(20.0)
  }
  
  /// Color of the border of `followButton`. Also is the color of the background when the button is filled (signifying that the user is following already).
  class var followButtonColor: UIColor {
    return UIColor.grayColor()
  }

  // MARK: UITableViewCell
  
  override func prepareForReuse() {
    separatorViewHeightConstraint?.constant = 0
    nameButton.setTitleWithoutAnimation("")
  }
  
  // MARK: Setup Helper Functions
  
  /// Assigns all delegates of cell to the given parameter.
  ///
  /// :param: delegate The delegate that will be assigned to elements of the cell pertaining to the required protocols specified in the function header.
  func assignDelegatesForCellTo<T: UIViewController where T: TTTAttributedLabelDelegate>(delegate: T) {
    descripAttributedLabel.delegate = delegate
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
    
    setupBoardOutletFonts()
    setOutletTagsTo(buttonTag)
    
    nameButton.setTitleWithoutAnimation(board.name)
    
    photoButton.setBackgroundImageToImageWithURL(board.photoURL, forState: .Normal)
    photoButton.clipsToBounds = true
    photoButton.layer.cornerRadius = 5.0
    
    descripAttributedLabel.setupWithText(board.descrip, andFont: BoardCell.BoardFonts.descripAttributedLabelFont)

    followButton.setupWithRoundedBorderOfWidth(UIButton.standardBorderWidth, andColor: BoardCell.followButtonColor)
    if !board.following {
      followButton.setTitle("Join", forState: .Normal)
      followButton.setTitleColor(UIColor.lighterBlack(), forState: .Normal)
      followButton.backgroundColor = UIColor.whiteColor()
    } else {
      followButton.setTitle("Joined", forState: .Normal)
      followButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
      followButton.backgroundColor = BoardCell.followButtonColor
    }
    
    // Make only the number in followersLabel bold
    let followersString = board.followerCount == 1 ? " MEMBER" : " MEMBERS"
    var followersText = NSMutableAttributedString.twoFontString(firstHalf: board.followerCount.fiveCharacterDisplay, firstFont: BoardCell.BoardFonts.followerCountFont, secondHalf: followersString, secondFont: BoardCell.BoardFonts.followerLabelFont)
    followersLabel.attributedText = followersText
    
    if let separatorView = separatorView {
      separatorView.backgroundColor = scheme.dividerBackgroundColor()
      separatorViewHeightConstraint!.constant = separatorHeight
    }
  }
  
  /// Sets the tag of all relevent outlets to the specified tag. This tag represents the row of this cell in the `tableView`.
  ///
  /// :param: tag The tag that the outlet's `tag` property is set to.
  private func setOutletTagsTo(tag: Int) {
    photoButton.tag = tag
    nameButton.tag = tag
    followButton.tag = tag
  }
  
  /// Sets fonts of all IBOutlets to the fonts specified in the `BoardCell.BoardFonts` struct.
  private func setupBoardOutletFonts() {
    nameButton.titleLabel?.font = BoardCell.BoardFonts.nameButtonFont
    followButton.titleLabel?.font = BoardCell.BoardFonts.followButtonFont
  }
}
