//
//  ConversationCell.swift
//  Cillo
//
//  Created by Andrew Daley on 6/24/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Cell that corresponds to reuse identifier "Conversation".
///
/// Used to format Conversations in UITableViews.
class ConversationCell: UITableViewCell {
  
  // MARK: IBOutlets
  
  /// Displays a dot if the conversation is unread.
  @IBOutlet weak var dotLabel: UILabel!
  
  /// Displays `conversation.preview`
  @IBOutlet weak var previewAttributedLabel: TTTAttributedLabel!
  
  /// Displays `conversation.otherUser.name`
  @IBOutlet weak var nameButton: UIButton!
  
  /// Displays `conversation.otherUser.photoURL` asynchronously
  @IBOutlet weak var photoButton: UIButton!
  
  /// Displays `conversation.updateTime`.
  @IBOutlet weak var timeLabel: UILabel!
  
  /// Custom border between cells.
  ///
  /// This IBOutlet may not be assigned in the storyboard, meaning the UITableViewController managing this cell wants to use default UITableView separators.
  @IBOutlet weak var separatorView: UIView?
  
  // MARK: Constants
  
  /// Struct containing all relevent fonts for the elements of a ConversationCell.
  struct ConversationFonts {
    
    /// Italic font of the text contained within nameButton.
    static let nameButtonFont = UIFont.boldSystemFontOfSize(15.0)
    
    /// Font of the text contained within previewAttributedLabel.
    static let previewAttributedLabelFont = UIFont.systemFontOfSize(15.0)
    
    /// Font of the text contained within timeLabel.
    static let timeLabelFont = UIFont.systemFontOfSize(12.0)
  }

  /// Vertical space needed besides `separatorView`.
  class var vertSpaceNeeded: CGFloat {
    return 70.0
  }
  
  // MARK: Setup Helper Functions
  
  /// Assigns all delegates of cell to the given parameter.
  ///
  /// :param: delegate The delegate that will be assigned to elements of the cell pertaining to the required protocols specified in the function header.
  func assignDelegatesForCellTo<T: UIViewController where T: TTTAttributedLabelDelegate>(delegate: T) {
    previewAttributedLabel.delegate = delegate
  }
  
  /// Calculates the height of the cell given the properties of `notification`.
  ///
  /// :param: post The post that this cell is based on.
  /// :param: width The width of the cell in the tableView.
  /// :param: dividerHeight The height of the `separatorView` in the tableView.
  /// :returns: The height that the cell should be in the tableView.
  class func heightOfConversationCellForConversation(conversation: Conversation, withElementWidth width: CGFloat, andDividerHeight dividerHeight: CGFloat) -> CGFloat {
    // TODO: may need to calculate the height of the preview depending on the implementation of the ui
    return ConversationCell.vertSpaceNeeded + dividerHeight
  }
  
  /// Makes this ConversationCell's IBOutlets display the correct values of the corresponding Conversation.
  ///
  /// :param: conversation The corresponding Conversation to be displayed by this ConversationCell.
  /// :param: buttonTag The tags of all buttons in this ConversationCell corresponding to their index in the array holding them.
  /// :param: * Pass the precise index of the conversation in its model array.
  func makeCellFromConversation(conversation: Conversation, withButtonTag buttonTag: Int) {
    let scheme = ColorScheme.defaultScheme
    
    setupConversationOutletFonts()
    
    photoButton.setBackgroundImageToImageWithURL(conversation.otherUser.photoURL, forState: .Normal)
    photoButton.clipsToBounds = true
    photoButton.layer.cornerRadius = 5.0
    
    previewAttributedLabel.setupWithText(conversation.preview, andFont: ConversationCell.ConversationFonts.previewAttributedLabelFont)
    
    timeLabel.text = "\(conversation.updateTime) ago"
    timeLabel.textColor = scheme.touchableTextColor()
    
    photoButton.tag = buttonTag
    
    if conversation.read {
      dotLabel.text = ""
    }
    nameButton.setTitle(conversation.otherUser.name, forState: .Normal)
    
    separatorView?.backgroundColor = scheme.dividerBackgroundColor()
  }
  
  /// Sets fonts of all IBOutlets to the fonts specified in the `ConversationCell.ConversationFonts` struct.
  private func setupConversationOutletFonts() {
    nameButton.titleLabel?.font = ConversationCell.ConversationFonts.nameButtonFont
    timeLabel.font = ConversationCell.ConversationFonts.timeLabelFont
  }
}
