//
//  Extensions.swift
//  Cillo
//
//  Created by Andrew Daley on 11/7/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

//MARK: - New String Methods

extension String {
   
    ///Converts Int to formatted 1-4 character String
    static func formatNumberAsString(number: Int) -> String {
        switch number {
        case -999...999:
            return "\(number)"
        case 1000...9999:
            var thousands = Double(number / 1000)
            thousands += Double(number % 1000 / 100) * 0.1
            return "\(thousands)k"
        case -9999...(-1000):
            var thousands = Double(number / 1000)
            thousands -= Double(number % 1000 / 100) * 0.1
            return "\(thousands)k"
        case 10000...999999, -999999...(-10000):
            return "\(number / 1000)k"
        case 1000000...9999999:
            var millions = Double(number / 1000000)
            millions += Double(number % 1000000 / 100000) * 0.1
            return "\(millions)m"
        case -9999999...(-1000000):
            var millions = Double(number / 1000000)
            millions -= Double(number % 1000000 / 100000) * 0.1
            return "\(millions)m"
        case 10000000...999999999, -999999999...(-10000000):
            return "\(number / 1000000)m"
        case 1000000000...9999999999:
            var billions = Double(number / 1000000000)
            billions += Double(number % 1000000000 / 100000000) * 0.1
            return "\(billions)b"
        case -9999999999...(-1000000000):
            var billions = Double(number / 1000000000)
            billions -= Double(number % 1000000000 / 100000000) * 0.1
            return "\(billions)b"
        case 10000000000...999999999999, -999999999999...(-10000000000):
            return "\(number / 1000000000)b"
        default:
            return "WTF"
        }
    }
    
    ///Returns the height of a UITextView with a specified width and font containing this String
    func heightOfTextWithWidth(width: CGFloat, andFont font: UIFont) -> CGFloat {
        var textView = UITextView(frame: CGRectMake(0, 0, width, CGFloat.max))
        textView.text = self
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsetsZero
        textView.font = font
        textView.sizeToFit()
        
        return textView.frame.size.height
    }

}

//MARK: - New NSMutableAttributedString Method

extension NSMutableAttributedString {
    
    ///Returns an AttributedString that has the first half bolded
    class func firstHalfBoldMutableAttributedString(boldedString: String, boldedFont: UIFont, normalString: String, normalFont: UIFont) -> NSMutableAttributedString{
        var firstHalf = NSMutableAttributedString(string:boldedString, attributes: [NSFontAttributeName:boldedFont])
        var secondHalf = NSMutableAttributedString(string: normalString, attributes: [NSFontAttributeName:normalFont])
        firstHalf.appendAttributedString(secondHalf)
        return firstHalf
    }
}

//MARK: - New UIColor Methods

extension UIColor {
    
    ///Returns the Cillo Blue Color
    class func cilloBlue() -> UIColor {
        return UIColor(red: 0.0627, green: 0.396, blue: 0.768, alpha: 0.87)
    }
    
    ///Returns standard UITableView divider color
    class func defaultTableViewDividerColor() -> UIColor {
        return UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1.0)
    }
}

//MARK: - New UITableViewController Constants

extension UITableViewController {
    
    ///Width of textView in UITableViewCell
    var PROTOTYPE_TEXT_VIEW_WIDTH:CGFloat {return view.frame.size.width - 16}
    
    ///Max height of postTextView in PostCell before it is expanded by seeFullButton
    var MAX_CONTRACTED_HEIGHT:CGFloat {return tableView.frame.height * 0.625 - PostCell.ADDITIONAL_VERT_SPACE_NEEDED}
    
}