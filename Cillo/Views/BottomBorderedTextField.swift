//
//  BottomBorderedTextField.swift
//  Cillo
//
//  Created by Andrew Daley on 6/3/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

@IBDesignable class BottomBorderedTextField: CustomTextField {

  @IBInspectable var bottomBorderWidth: CGFloat = 1.0
  
  @IBInspectable var bottomBorderColor: UIColor = ColorScheme.defaultScheme.thinLineBackgroundColor()

  override func drawRect(rect: CGRect) {
    super.drawRect(rect)
    var bottomBorder = CALayer();
    bottomBorder.frame = CGRect(x: 0.0, y: self.frame.size.height - bottomBorderWidth, width: self.frame.size.width, height: bottomBorderWidth);
    bottomBorder.backgroundColor = bottomBorderColor.CGColor;
    layer.addSublayer(bottomBorder)
  }
}
