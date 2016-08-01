//
//  CustomTextField.swift
//  Cillo
//
//  Created by Andrew Daley on 5/31/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Text field class that allows the text to be inset on a text field with no border.
@IBDesignable class CustomTextField: UITextField {

  // MARK: IBInspectable Properties
  
  /// Inset of text in the text field frame.
  @IBInspectable var inset: CGFloat = 8
  
  // MARK: UITextField
  
  override func editingRect(forBounds bounds: CGRect) -> CGRect {
    return textRect(forBounds: bounds)
  }
  
  override func textRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.insetBy(dx: inset, dy: inset)
  }
}
