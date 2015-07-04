//
//  ConversationCell.swift
//  Cillo
//
//  Created by Andrew Daley on 6/24/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit
import TTTAttributedLabel

/// Cell that corresponds to reuse identifier "Conversation".
///
/// Used to format Conversations in UITableViews.
class ConversationCell: UITableViewCell {
  
  // MARK: IBOutlets
  
  /// Displays `conversation.preview`
  @IBOutlet weak var previewTTTAttributedLabel: TTTAttributedLabel!
  
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

  /// Font of previewTTTAttributedLabel.
  class var previewTTTAttributedLabelFont: UIFont {
    return UIFont.systemFontOfSize(15.0)
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
    previewTTTAttributedLabel.delegate = delegate
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
    
    photoButton.setBackgroundImageToImageWithURL(conversation.otherUser.photoURL, forState: .Normal)
    
    photoButton.clipsToBounds = true
    photoButton.layer.cornerRadius = 5.0
    
    previewTTTAttributedLabel.setupWithText(conversation.preview, andFont: ConversationCell.previewTTTAttributedLabelFont)
    
    timeLabel.text = "\(conversation.updateTime) ago"
    timeLabel.textColor = scheme.touchableTextColor()
    
    photoButton.tag = buttonTag
    
    var name = NSMutableAttributedString(string: conversation.otherUser.name, attributes: [NSForegroundColorAttributeName: UIColor.darkTextColor()])
    var unreadDot = NSMutableAttributedString(string: "·", attributes: [NSForegroundColorAttributeName: UIColor.blueColor()])
    if !conversation.read {
      unreadDot.appendAttributedString(name)
      name = unreadDot
    }
    nameButton.setAttributedTitle(name, forState: .Normal)
    
    separatorView?.backgroundColor = scheme.dividerBackgroundColor()
  }
  
}
