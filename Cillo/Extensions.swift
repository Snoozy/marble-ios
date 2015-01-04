//
//  Extensions.swift
//  Cillo
//
//  Created by Andrew Daley on 11/7/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

// MARK: - Extensions -

extension String {
  
  /// Used to display large numbers in a compact 1-5 character String.
  ///
  /// String is formatted in one of following formats:
  ///
  /// * 100 - any number less than 1000.
  /// * 1.3k - any number in the order of thousands.
  /// * 2.6m - any number in the order of millions.
  /// * 6.8b - any number in the order of billions.
  /// 
  /// Note: Does not display numbers in order of trillions or larger.
  ///
  /// :param: number The number that is formatted as a String.
  /// :returns: The formatted String for the specified number.
  static func formatNumberAsString(#number: Int) -> String {
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
  
  /// Used to calculate the precise height of a UITextView so it fits this String.
  ///
  /// :param: width The width of the UITextView on the current screen.
  /// :param: font The font currently displayed in the UITextView.
  /// :returns: The height of a UITextView with the specified parameters containing this String.
  func heightOfTextWithWidth(width: CGFloat, andFont font: UIFont) -> CGFloat {
    let textView = UITextView(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.max))
    textView.text = self
    textView.textContainer.lineFragmentPadding = 0
    textView.textContainerInset = UIEdgeInsetsZero
    textView.font = font
    textView.sizeToFit()
    
    return textView.frame.size.height
  }
  
}

// MARK: -

extension NSMutableAttributedString {
  
  /// Used to create text that is displayed in two different fonts. 
  /// Useful for making half bolded or half italicized text.
  ///
  /// :param: firstHalf The text that is displayed in the first font.
  /// :param: firstFont The font that the first part of the AttributedString is displayed in.
  /// :param: secondHalf The text that is displayed in the second font.
  /// :param: secondFont The font that the second part of the AttributedString is displayed in.
  /// :returns: An AttributedString that has two parts displayed in two different fonts.
  class func twoFontString(#firstHalf: String, firstFont: UIFont, secondHalf: String, secondFont: UIFont) -> NSMutableAttributedString {
    let first = NSMutableAttributedString(string: firstHalf, attributes: [NSFontAttributeName:firstFont])
    let second = NSMutableAttributedString(string: secondHalf, attributes: [NSFontAttributeName:secondFont])
    first.appendAttributedString(second)
    return first
  }
  
}

// MARK: -

extension UIColor {
  
  /// :returns: The dark blue color that is the theme for Cillo.
  class func cilloBlue() -> UIColor {
    return UIColor(red: 0.0627, green: 0.396, blue: 0.768, alpha: 0.87)
  }
  
  /// :returns: The light gray color that is used for dividers in UITableViews
  class func defaultTableViewDividerColor() -> UIColor {
    return UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1.0)
  }
  
}

// MARK: -

extension UITableViewController {
  
  /// Width of textView in UITableViewCell
  var PrototypeTextViewWidth: CGFloat {
    get {
      return view.frame.size.width - 16
    }
  }
  
  /// Max height of postTextView in a PostCell before it is expanded by seeFullButton
  var MaxContractedHeight: CGFloat {
    get {
      return tableView.frame.height * 0.625 - PostCell.AdditionalVertSpaceNeeded
    }
  }
  
}

// MARK: -

extension NSDate {
  
  /// Used to convert a large integer that represents milliseconds since epoch to a compact String.
  ///
  /// String is formatted in one of the following ways:
  ///
  /// * 1m - all times that are less than 2 minutes default to a 1m display time since creation
  /// * 15m - any time that is in the order of minutes
  /// * 3h - any time that is in the order of hours
  /// * 2y - any time that is in the order of years
  ///
  /// :param: time The time of an instance's creation in milliseconds since epoch.
  /// :returns: A readable String representing the time since the instance's creation.
  class func convertToTimeString(#time: Int64) -> String {
    let date = NSDate()
    let gmtOffset = NSTimeZone.localTimeZone().secondsFromGMT * 1000
    let timeSince1970 = Int64(floor(date.timeIntervalSince1970 * 1000))
    let timeStamp = gmtOffset + timeSince1970
    let millisSincePost = timeStamp - time
    switch millisSincePost {
    case 0...59999:
      return "1m"
    case 60000...3599999:
      return "\(millisSincePost / 60000)m"
    case 3600000...1313999999:
      return "\(millisSincePost / 3600000)d"
    case 1314000000...Int64.max:
      return "\(millisSincePost / 1314000000)y"
    default:
      return "WTF"
    }
  }
  
}

// MARK: -

extension NSError {
  
  /// Shows this error's properties in a UIAlertView that pops up on the screen.
  func showAlert() {
    let alert = UIAlertView(title: "Error \(self.domain) : \(self.code)", message: self.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
    alert.show()
  }
  
}

// MARK: -

extension NSUserDefaults {
  
  /// Key to retrieve Auth_Token for the logged in User
  class var Auth: String {
    get {
      return "auth"
    }
  }
  
  /// Key to retrieve User object for the logged in User
  class var User: String {
    get {
     return "user"
    }
  }
  
}

// MARK: -

extension UIActivityIndicatorView {
  
  /// Shows and animates this UIActivityIndicatorView
  func start() {
    self.startAnimating()
    hidden = false
  }
  
  /// Hides and stops animating this UIActivityIndicatorView
  func stop() {
    self.stopAnimating()
    hidden = true
  }
  
}