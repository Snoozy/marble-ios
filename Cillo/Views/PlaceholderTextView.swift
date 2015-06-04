//
//  PlaceholderTextView.swift
//  Cillo
//
//  Created by Andrew Daley on 6/3/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Altered UITextView to allow for placeholder functionality.
@IBDesignable class PlaceholderTextView: UITextView {
  
  // MARK: Properties
  
  /// Label that displays `placeholder` in the actual text view.
  private var placeholderLabel: UILabel?
  
  // IBInspectable Properties
  
  /// Color of the placeholder.
  @IBInspectable var placeholderColor: UIColor = UIColor.placeholderColor()
  
  /// Text to be shown as the placeholder.
  @IBInspectable var placeholder: String = ""
  
  // MARK: Initializers
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "myTextDidChange", name: UITextViewTextDidChangeNotification, object: self)
  }
  
  override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "myTextDidChange", name: UITextViewTextDidChangeNotification, object: self)
  }
  
  // MARK: UIView
  
  override func layoutSubviews() {
    super.layoutSubviews()
    if placeholderLabel == nil {
      placeholderLabel = UILabel(frame: CGRect(x: 8, y: 8, width: frame.width - 16, height: 20))
      addSubview(placeholderLabel!)
    }
    if let placeholderLabel = placeholderLabel {
      placeholderLabel.textColor = placeholderColor
      placeholderLabel.font = font
      placeholderLabel.text = placeholder
      bringSubviewToFront(placeholderLabel)
    }
  }
  
  // MARK: Notificaiton Selectors
  
  /// Function that is called each time the text is changed.
  ///
  /// Responsible for hiding the placeholder.
  func myTextDidChange() {
    if let placeholderLabel = placeholderLabel {
      placeholderLabel.hidden = text != ""
    }
  }
}
