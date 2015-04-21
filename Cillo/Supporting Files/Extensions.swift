//
//  Extensions.swift
//  Cillo
//
//  Created by Andrew Daley on 11/7/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

extension String {
  
  // MARK: Helper Functions
  
  /// Used to display large numbers in a compact 1-5 character String.
  ///
  /// String is formatted in one of following formats:
  ///
  /// * 100 - any number less than 1000.
  /// * 1.3k - any number in the order of thousands.
  /// * 2.6m - any number in the order of millions.
  /// * 6.8b - any number in the order of billions.
  /// 
  /// **Note:** Does not display numbers in order of trillions or larger.
  ///
  /// :param: number The number that is formatted as a String.
  /// :returns: The formatted String for the specified number.
  static func formatNumberAsString(#number: Int) -> String {
    switch number {
    case -999...999:
      return "\(number)"
    case 1_000...9_999:
      var thousands = Double(number / 1_000)
      thousands += Double(number % 1_000 / 100) * 0.1
      return "\(thousands)k"
    case -9_999...(-1_000):
      var thousands = Double(number / 1_000)
      thousands -= Double(number % 1_000 / 100) * 0.1
      return "\(thousands)k"
    case 10_000...999_999, -999_999...(-10_000):
      return "\(number / 1_000)k"
    case 1_000_000...9_999_999:
      var millions = Double(number / 1_000_000)
      millions += Double(number % 1_000_000 / 100_000) * 0.1
      return "\(millions)m"
    case -9_999_999...(-1_000_000):
      var millions = Double(number / 1_000_000)
      millions -= Double(number % 1_000_000 / 100_000) * 0.1
      return "\(millions)m"
    case 10_000_000...999_999_999, -999_999_999...(-10_000_000):
      return "\(number / 1_000_000)m"
    case 1_000_000_000...Int.max:
      var billions = Double(number / 1_000_000_000)
      billions += Double(number % 1_000_000_000 / 100_000_000) * 0.1
      return "\(billions)b"
    case Int.min...(-1_000_000_000):
      var billions = Double(number / 1_000_000_000)
      billions -= Double(number % 1_000_000_000 / 100_000_000) * 0.1
      return "\(billions)b"
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
    if self == "" {
      return CGFloat(0.0)
    }
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
  
  // MARK: Helper Functions
  
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
  
  // MARK: Helper Functions
  
  /// :returns: The blue color that is the theme for Cillo.
  class func cilloBlue() -> UIColor {
//    return UIColor(red: 0.0627, green: 0.396, blue: 0.768, alpha: 0.87)
    return UIColor(red: 2/255.0, green: 81/255.0, blue: 138/255.0, alpha: 0.87)
  }
  
  /// Allows an alpha to be specified for the cillo blue color.
  ///
  /// **Note:** The default alpha for UIColor.cilloBlue() is 0.87.
  /// :param: alpha The alpha of the returned color.
  /// :returns: The blue color that is the theme of Cillo with a specified alpha.
  class func cilloBlueWithAlpha(alpha: CGFloat) -> UIColor {
    return UIColor(red: 0.0627, green: 0.396, blue: 0.768, alpha: alpha)
  }
  
  /// :returns: The light gray color that is used for dividers in UITableViews.
  class func defaultTableViewDividerColor() -> UIColor {
    return UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1.0)
  }
  
}

// MARK: -

extension NSDate {
  
  // MARK: Helper Functions
  
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
    // THE BELOW COMMENTED CODE IS OFFSETTING FOR TIMEZONES. THIS IS NOT NEED FOR THIS METHOD BUT WILL BE SAVED IN CASE NEEDED FOR FUTURE USE.
//    println("Time: \(time)")
    let date = NSDate()
//    let gmtOffset = NSTimeZone.localTimeZone().secondsFromGMT * 1000
//    println("GMT Offset: \(gmtOffset)")
    let timeSince1970 = Int64(floor(date.timeIntervalSince1970 * 1000))
//    println("Time Since 1970: \(timeSince1970)")
//    let timeStamp = gmtOffset + timeSince1970
//    println("Time Since 1970 Adjusted with Offset: \(timeStamp)")
//    let millisSincePost = timeStamp - time
//    println("Millis Since: \(millisSincePost)")
    let millisSincePost = timeSince1970 - time
    switch millisSincePost {
    case -1_000_000...59_999:
      return "1m"
    case 60_000...3_599_999:
      return "\(millisSincePost / 60_000)m"
    case 3_600_000...86_399_999:
      return "\(millisSincePost / 3_600_000)h"
    case 86_400_000...31_535_999_999:
      return "\(millisSincePost / 86_400_000)d"
    case 31_536_000_000...Int64.max:
      return "\(millisSincePost / 31_536_000_000)y"
    default:
      return "WTF"
    }
  }
  
}

// MARK: -

extension NSError {
  
  // MARK: Constants
  
  /// The domain name of errors returned by jsons retrieved from the cillo servers.
  class var CilloErrorDomain: String {
    get {
      return "CilloErrorDomain"
    }
  }
  
  // MARK: Initializers
  
  /// Initializer used to create custom errors retrieved from the cillo servers.
  ///
  /// :param: cilloErrorString The message that was given by the key "error" in the retrieved json.
  /// :param: requestType The request type that the error corresponds to. See Router enum for a full list.
  convenience init(cilloErrorString: String, requestType: Router) {
    self.init(domain: NSError.CilloErrorDomain, code: NSError.getErrorCodeForRouter(requestType), userInfo: [NSLocalizedDescriptionKey: cilloErrorString])
  }
  
  // MARK: Helper Functions
  
  /// Shows this error's properties in a UIAlertView that pops up on the screen.
  func showAlert() {
    let alert = UIAlertView(title: "Error \(self.domain) : \(self.code)", message: self.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
    alert.show()
  }
  
  /// Used to retrieve the error code for identification of various cillo errors.
  ///
  /// The error cod is used to recognize the Router that the error occurred in.
  ///
  /// **Breakdown of error codes:**
  ///
  /// *First Digit: Requst type*
  ///
  /// * GET Request: 1
  /// * POST Request: 2
  ///
  /// *Second Digit: Data that requester has already"
  ///
  /// * Post: 1
  /// * Comment: 2
  /// * Group: 3
  /// * User: 4
  /// * Me: 5 (Me is the auth_token for the logged in User)
  /// * Nothing/Misc: 6
  /// * Search: 7
  /// * Autocomplete: 8
  ///
  /// *Third Digit: Data that is needed from the server"
  ///
  /// * Post: 1
  /// * Comment: 2
  /// * Group: 3
  /// * User: 4
  /// * Me: 5 (Me is the auth_token for the logged in User)
  /// * Success Message: 6
  ///
  /// *Fourth Digit: Goal of the POST request (POST requests only)*
  ///
  /// * Create: 1
  /// * Upvote or Follow: 2
  /// * Downvote or Unfollow: 3
  /// * Account Related: 4
  /// * Upload: 5
  ///
  /// :param: requestType The request that retrieved an error. See Router enum for full list.
  /// :returns: The 3 (GET requests) or 4 (POST requests) digit code for an error with a speccific Router type.
  class func getErrorCodeForRouter(requestType: Router) -> Int {
    var code = 0
    switch requestType {
    case .Root:
      code = 151
    case .GroupFeed(let groupID):
      code = 131
    case .GroupInfo(let groupID):
      code = 163
    case .PostInfo(let postID):
      code = 161
    case .PostComments(let postID):
      code = 112
    case .SelfInfo:
      code = 154
    case .UserInfo:
      code = 164
    case .UserGroups(let userID):
      code = 143
    case .UserPosts(let userID):
      code = 141
    case .UserComments(let userID):
      code = 142
    case .GroupSearch:
      code = 173
    case .GroupAutocomplete:
      code = 183
    case .Register:
      code = 2664
    case .GroupCreate:
      code = 2631
    case .Login:
      code = 2654
    case .Logout:
      code = 2564
    case .PostCreate:
      code = 2611
    case .CommentCreate:
      code = 2621
    case .MediaUpload:
      code = 2665
    case .CommentUp(let commentID):
      code = 2262
    case .CommentDown(let commentID):
      code = 2263
    case .PostUp(let postID):
      code = 2162
    case .PostDown(let postID):
      code = 2163
    case .GroupFollow(let groupID):
      code = 2362
    case .GroupUnfollow(let groupID):
      code = 2363
    case .SelfSettings:
      code = 2544
    }
    return code
  }
  
  class func noJSONFromDataError(#requestType: Router) -> NSError {
    return NSError(domain: "NoJSONErrorDomain", code: NSError.getErrorCodeForRouter(requestType), userInfo: [NSLocalizedDescriptionKey: "Problem making JSON from data retrieved by Alamofire"])
  }
  
}

// MARK: -

extension NSUserDefaults {
  
  // MARK: Constants
  
  /// Key to retrieve Auth_Token for the logged in User
  class var Auth: String {
    get {
      return "auth"
    }
  }
  
  /// Key to retrieve userID for the logged in User
  class var User: String {
    get {
     return "user"
    }
  }
  
  // MARK: Helper Functions

  /// Used to discover if NSUserDefaults has values for keys .Auth and .User 
  ///
  /// :returns: True if there are values for both .Auth and .User.
  class func hasAuthAndUser() -> Bool {
    let auth: String? = NSUserDefaults.standardUserDefaults().valueForKey(NSUserDefaults.Auth) as? String
    let user: Int? = NSUserDefaults.standardUserDefaults().valueForKey(NSUserDefaults.User) as? Int
    if let auth = auth {
      if auth == "" {
        return false
      } else if let user = user {
        if user != 0 {
          return true
        } else {
          return false
        }
      } else {
        return false
      }
    } else {
      return false
    }
  }
  
}

// MARK: -

extension UIViewController {
  
  // MARK: Helper Functions
  
  /// Adds an blue, animated UIActivityIndicatorView to the center of view in this UIViewController.
  ///
  /// :returns: The UIView at the center of view in this UIViewController.
  /// :returns: **Note:** Can remove the UIView from the center of this view by calling returnedView.removeFromSuperView(), where returnedView is the UIView returned by this function.
  func addActivityIndicatorToCenterWithText(text: String) -> UIView {
    let loadingView = UIView(frame: CGRect(x: 0, y: 0, width: 170, height: 170))
    loadingView.backgroundColor = UIColor.cilloBlue()
    loadingView.clipsToBounds = true
    loadingView.layer.cornerRadius = 10.0
    loadingView.center = CGPoint(x: view.center.x, y: view.center.y)
    if let navigationController = navigationController as? FormattedNavigationViewController {
      loadingView.center.y -= navigationController.NavigationBarHeight / 2
    }
    if let tabBarController = tabBarController as? TabViewController {
      loadingView.center.y -= tabBarController.TabBarHeight / 2
    }
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    activityIndicator.frame.origin.x = 65
    activityIndicator.frame.origin.y = 60
    loadingView.addSubview(activityIndicator)
    
    let loadingLabel = UILabel(frame: CGRect(x: 15, y: 115, width: 140, height: 30))
    loadingLabel.backgroundColor = UIColor.clearColor()
    loadingLabel.textColor = UIColor.whiteColor()
    loadingLabel.adjustsFontSizeToFitWidth = true
    loadingLabel.textAlignment = .Center
    loadingLabel.text = text
    loadingView.addSubview(loadingLabel)
    
    activityIndicator.startAnimating()
    view.addSubview(loadingView)
    view.bringSubviewToFront(loadingView)
    return loadingView
  }
  
}

// MARK: -

extension UITextView {
  
  // MARK: Constants
  
  /// Height of keyboard when a UITextView is selected.
  class var KeyboardHeight: CGFloat {
    get {
      return 256
    }
  }
  
}

