//
//  UIColorExt.swift
//  Cillo
//
//  Created by Andrew Daley on 8/6/16.
//  Copyright © 2016 Cillo. All rights reserved.
//

import UIKit

extension UIColor {
    
    // MARK: - Custom Colors
    
    /// :returns: The gray color that is used for the buttons at the bottom of the cells.
    class var buttonGray: UIColor {
        return UIColor(red: 125/255.0, green: 138/255.0, blue: 150/255.0, alpha: 1.0)
    }
    
    /// :returns: The blue color that is the theme for the .Blue color scheme.
    class var cilloBlue: UIColor {
        return UIColor.cilloBlueWithAlpha(0.87)
    }
    
    /// Allows an alpha to be specified for the cillo blue color.
    ///
    /// :param: alpha The alpha of the returned color.
    /// :returns: The blue color that is the theme of Cillo with a specified alpha.
    class func cilloBlueWith(alpha: CGFloat) -> UIColor {
        return UIColor(red: 13/255.0, green: 88/255.0, blue: 245/255.0, alpha: alpha)
    }
    
    /// :returns: The gray color that is the theme for the .Gray color scheme.
    class var cilloGray: UIColor {
        return UIColor.cilloGrayWithAlpha(0.87)
    }
    
    /// Allows an alpha to be specified for the cillo gray color.
    ///
    /// :param: alpha The alpha of the returned color.
    /// :returns: The gray color that is the theme of Cillo with a specified alpha.
    class func cilloGrayWith(alpha: CGFloat) -> UIColor {
        return UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: alpha)
    }
    
    /// :returns: The light gray color that is used for dividers in UITableViews.
    class func defaultTableViewDividerColor() -> UIColor {
        return UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1.0)
    }
    
    /// :returns: The red color that is used for downvote coloring.
    class var downvoteRed: UIColor {
        return UIColor(red: 174/255.0, green: 0/255.0, blue: 37/255.0, alpha: 1.0)
    }
    
    /// :returns: A lighter black color that is used for the items on the nav bar in the .Gray screen.
    class var lighterBlack: UIColor {
        return UIColor(red: 78/255.0, green: 78/255.0, blue: 78/255.0, alpha: 1.0)
    }
    
    /// :returns: The light gray color that is used for placeholders in UITextFields.
    class var placeholderColor: UIColor {
        return UIColor(red: 199/255.0, green: 199/255.0, blue: 205/255.0, alpha: 1.0)
    }
    
    /// :returns: The green color that is used for upvote coloring.
    class var upvoteGreen: UIColor {
        return UIColor(red: 75/255.0, green: 129/255.0, blue: 44/255.0, alpha: 1.0)
    }
}
