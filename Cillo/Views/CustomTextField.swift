//
//  CustomTextField.swift
//  Cillo
//
//  Created by Andrew Daley on 5/31/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

@IBDesignable
class CustomTextField: UITextField {

  @IBInspectable var inset: CGFloat = 8
  
  override func textRectForBounds(bounds: CGRect) -> CGRect {
    return CGRectInset(bounds, inset, inset)
  }
  
  override func editingRectForBounds(bounds: CGRect) -> CGRect {
    return textRectForBounds(bounds)
  }

}
