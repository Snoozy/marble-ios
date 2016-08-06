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
  
  // MARK: - IBOutlets
  
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
  
  // MARK: - Setup Helper Functions
  
  /// Assigns all delegates of cell to the given parameter.
  ///
  /// :param: delegate The delegate that will be assigned to elements of the cell pertaining to the required protocols specified in the function header.
  func assignDelegatesForCellTo<T: UIViewController where T: TTTAttributedLabelDelegate>(_ delegate: T) {
    previewAttributedLabel.delegate = delegate
  }
  
  /// Makes this ConversationCell's IBOutlets display the correct values of the corresponding Conversation.
  ///
  /// :param: conversation The corresponding Conversation to be displayed by this ConversationCell.
  func makeFrom(conversation: Conversation) {
    let scheme = ColorScheme.defaultScheme
    
    photoButton.clipsToBounds = true
    photoButton.layer.cornerRadius = 5.0
    if let url = conversation.otherUser.photoURL {
        ImageLoadingManager.sharedInstance.downloadImageFrom(url: url) { image in
            DispatchQueue.main.async {
                self.photoButton.setImage(image, for: UIControlState())
            }
        }
    }
    
    previewAttributedLabel.setupFor(conversation.preview)
    
    timeLabel.text = "\(conversation.updateTime) ago"
    timeLabel.textColor = scheme.touchableTextColor()
    
    if conversation.read {
      dotLabel.text = ""
    }
    nameButton.setTitleWithoutAnimation(conversation.otherUser.name)
  }
    
}
