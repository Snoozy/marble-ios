//
//  BottomBorderedTextView.swift
//  Cillo
//
//  Created by Andrew Daley on 9/4/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Text view class that has only a border at the bottom of the view.
class BottomBorderedTextView: PlaceholderTextView {
  
  // MARK: Properties
  
  var bottomBorder: CALayer?
  
  // MARK: IBInspectable Properties
  
  /// Width of the line at the bottom of the text field.
  @IBInspectable var bottomBorderWidth: CGFloat = 1.0
  
  /// Color of the line at the bottom of the text field.
  @IBInspectable var bottomBorderColor: UIColor = ColorScheme.defaultScheme.thinLineBackgroundColor()
  
  // MARK: UIView
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    if bottomBorder == nil {
      bottomBorder = CALayer();
      bottomBorder!.frame = CGRect(x: 0.0, y: contentOffset.y + frame.size.height - bottomBorderWidth, width: frame.size.width, height: bottomBorderWidth);
      bottomBorder!.backgroundColor = bottomBorderColor.cgColor;
      layer.addSublayer(bottomBorder!)
      delegate = self
    }
  }
}

extension BottomBorderedTextView: UITextViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if let bottomBorder = bottomBorder {
      let newY = scrollView.contentOffset.y + frame.size.height - bottomBorderWidth
      bottomBorder.frame = CGRect(x: 0.0, y: newY, width: frame.size.width, height: bottomBorderWidth)
    }
  }
}
