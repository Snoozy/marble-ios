//
//  TextHeightCalculator.swift
//  Cillo
//
//  Created by Andrew Daley on 8/2/16.
//  Copyright © 2016 Cillo. All rights reserved.
//

import UIKit

class TextHeightCalculator: NSObject {

    var cachedHeights = [Int : CGFloat]()
    
    let maxHeight: CGFloat = -1.0
    
    let font: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    
    let screenWidth: CGFloat = 0.0
    
    init(maxHeight: CGFloat = -1.0, font: UIFont, screenWidth: CGFloat) {
        super.init()
        self.maxHeight = maxHeight
        self.font = font
        self.screenWidth = screenWidth
    }
    
    func calculateHeightOf<T where T: HeightCalculatable, T: Identifiable>(object: T) -> CGFloat {
        var height = cachedHeights[object.id] ?? heightOf(string: object.textToCalculate)
        if maxHeight != -1.0 && height > maxHeight {
            height = maxHeight
        }
        return height
    }
    
    private func heightOf(string: String) -> CGFloat {
        if self == "" {
            return CGFloat(0.0)
        }
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: CGFloat.greatestFiniteMagnitude))
        textView.text = string
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        textView.font = font
        textView.sizeToFit()
        
        return textView.frame.size.height
    }
}
