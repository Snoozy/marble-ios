//
//  BottomBorderedTextField.swift
//  Cillo
//
//  Created by Andrew Daley on 6/3/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Text field class that has only a border at the bottom of the field.
@IBDesignable class BottomBorderedTextField: CustomTextField {

  // MARK: IBInspectable Properties
  
  /// Width of the line at the bottom of the text field.
  @IBInspectable var bottomBorderWidth: CGFloat = 1.0
  
  /// Color of the line at the bottom of the text field.
  @IBInspectable var bottomBorderColor: UIColor = ColorScheme.defaultScheme.thinLineBackgroundColor()

  // MARK: UIView
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    let bottomBorder = CALayer();
    bottomBorder.frame = CGRect(x: 0.0, y: self.frame.size.height - bottomBorderWidth, width: self.frame.size.width, height: bottomBorderWidth);
    bottomBorder.backgroundColor = bottomBorderColor.cgColor;
    layer.addSublayer(bottomBorder)
  }
}
