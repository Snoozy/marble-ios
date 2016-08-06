//
//  TTTAttributedLabelExt.swift
//  Cillo
//
//  Created by Andrew Daley on 8/6/16.
//  Copyright © 2016 Cillo. All rights reserved.
//

import Foundation

extension TTTAttributedLabel {
    
    // MARK: Setup Helper Functions
    
    /// Sets up links for the label and makes the label multiline, displaying the text.
    ///
    /// :param: text The attributed text to be displayed by this label.
    func setupFor(attributedText: AttributedString) {
        numberOfLines = 0
        enabledTextCheckingTypes = TextCheckingResult.CheckingType.link.rawValue
        linkAttributes = [kCTForegroundColorAttributeName : UIColor.cilloBlue()]
        attributedText = text
    }
    
    /// Sets up links for the label and makes the label multiline, displaying the text.
    ///
    /// :param: text The text to be displayed by this label.
    func setupFor(text: String) {
        numberOfLines = 0
        self.font = font
        enabledTextCheckingTypes = TextCheckingResult.CheckingType.link.rawValue
        linkAttributes = [kCTForegroundColorAttributeName : UIColor.cilloBlue()]
        self.text = text
    }
}
