//
//  UIButtonExt.swift
//  Cillo
//
//  Created by Andrew Daley on 8/6/16.
//  Copyright © 2016 Cillo. All rights reserved.
//

import UIKit

extension UIButton {
    
    // MARK: - Constants
    
    /// Standard border width of bordered buttons.
    class var standardBorderWidth: Double {
        return 1.0
    }
    
    // MARK: - Setup Helper Functions
    
    /// Sets up button to have a border with rounded corners.
    ///
    /// :param: width The width of the border.
    /// :param: color The color of the border.
    func setupWithRoundedBorderOfWidth(_ width: Double, andColor color: UIColor) {
        clipsToBounds = true
        layer.borderWidth = CGFloat(width)
        layer.cornerRadius = 5
        layer.borderColor = color.cgColor
    }
    
    /// Sets up button to have a border with width `standardBorderWidth` and color `ColorScheme.defaultScheme.solidButtonTextColor()`.
    func setupWithRoundedBorderOfStandardWidthAndColor() {
        setupWithRoundedBorderOfWidth(UIButton.standardBorderWidth, andColor: ColorScheme.defaultScheme.solidButtonTextColor())
    }
    
    func setTitleWithoutAnimation(_ title: String) {
        titleLabel?.text = title
        setTitle(title, for: UIControlState())
    }
}
