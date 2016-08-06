//
//  NSMutableAttributedStringExt.swift
//  Cillo
//
//  Created by Andrew Daley on 8/6/16.
//  Copyright © 2016 Cillo. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {
    
    // MARK: - Setup Helper Functions
    
    /// Used to create text that is displayed in two different fonts.
    /// Useful for making half bolded or half italicized text.
    ///
    /// :param: firstHalf The text that is displayed in the first font.
    /// :param: firstFont The font that the first part of the AttributedString is displayed in.
    /// :param: secondHalf The text that is displayed in the second font.
    /// :param: secondFont The font that the second part of the AttributedString is displayed in.
    /// :returns: An AttributedString that has two parts displayed in two different fonts.
    class func twoFontString(firstHalf: String,
                             firstFont: UIFont,
                             secondHalf: String,
                             secondFont: UIFont) -> NSMutableAttributedString {
        var first = NSMutableAttributedString(string: firstHalf,
                                              attributes: [NSFontAttributeName:firstFont])
        let second = NSMutableAttributedString(string: secondHalf,
                                               attributes: [NSFontAttributeName:secondFont])
        first.appendAttributedString(second)
        return first
    }
}
