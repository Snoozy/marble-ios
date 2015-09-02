//
//  Extensions.swift
//  Cillo
//
//  Created by Andrew Daley on 11/7/14.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

extension Int {
  
  // MARK: Properties
  
  /// Used to display large numbers in a compact 1-5 character String.
  ///
  /// String is formatted in one of following formats:
  ///
  /// * 100 - any number less than 1000.
  /// * 1.3k - any number in the order of thousands.
  /// * 2.6m - any number in the order of millions.
  /// * 6.8b - any number in the order of billions.
  var fiveCharacterDisplay: String {
      switch self {
      case -999...999:
        return "\(self)"
      case 1_000...9_999:
        var thousands = Double(self / 1_000)
        thousands += Double(self % 1_000 / 100) * 0.1
        return "\(thousands)k"
      case -9_999...(-1_000):
        var thousands = Double(self / 1_000)
        thousands -= Double(self % 1_000 / 100) * 0.1
        return "\(thousands)k"
      case 10_000...999_999, -999_999...(-10_000):
        return "\(self / 1_000)k"
      case 1_000_000...9_999_999:
        var millions = Double(self / 1_000_000)
        millions += Double(self % 1_000_000 / 100_000) * 0.1
        return "\(millions)m"
      case -9_999_999...(-1_000_000):
        var millions = Double(self / 1_000_000)
        millions -= Double(self % 1_000_000 / 100_000) * 0.1
        return "\(millions)m"
      case 10_000_000...999_999_999, -999_999_999...(-10_000_000):
        return "\(self / 1_000_000)m"
      case 1_000_000_000...Int.max:
        var billions = Double(self / 1_000_000_000)
        billions += Double(self % 1_000_000_000 / 100_000_000) * 0.1
        return "\(billions)b"
      case Int.min...(-1_000_000_000):
        var billions = Double(self / 1_000_000_000)
        billions -= Double(self % 1_000_000_000 / 100_000_000) * 0.1
        return "\(billions)b"
      default:
        return ""
      }
  }
}

extension Int64 {
  
  // MARK: Properties
  
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
  var compactTimeDisplay: String {
    let date = NSDate()
    let timeSince1970 = Int64(floor(date.timeIntervalSince1970 * 1000))
    let millisSincePost = timeSince1970 - self
    switch millisSincePost {
    case -1_000_000...59_999:
      return "1m"
    case 60_000...3_599_999:
      return "\(millisSincePost / 60_000)m"
    case 3_600_000...86_399_999:
      return "\(millisSincePost / 3_600_000)h"
    case 86_400_000...31_535_999_999:
      return "\(millisSincePost / 86_400_000)d"
    case 31_536_000_000..<Int64.max:
      return "\(millisSincePost / 31_536_000_000)y"
    default:
      return ""
    }
  }
}

// MARK: -

// MARK: Error User Info Dictionary Keys

/// Key to store request type of error in cillo servers
let RequestTypeKey = "request_type"

extension NSError {
  
  // MARK: Constants
  
  /// The domain name of errors returned by jsons retrieved from the cillo servers.
  class var cilloErrorDomain: String {
    return "CilloErrorDomain"
  }
  
  /// Description of the value contained in `userInfo` for the RequestTypeKey
  var requestTypeDescription: String {
    if let userInfo = userInfo as? [String: AnyObject], descrip = userInfo[RequestTypeKey] as? String {
      return descrip
    } else {
      return ""
    }
  }
  
  // MARK: Enums
  
  /// Contains all error codes for Cillo related errors
  enum CilloErrorCodes: Int {
    
    /// Error code for a password incorrect error on a login attempt.
    case PasswordIncorrect = 20
    
    /// Error code for a username taken error on a registration attempt.
    case UsernameTaken = 30
    
    /// Error code for a user unauthenticated error.
    case UserUnauthenticated = 10
    
    /// Cillo returned an unrecognized error code.
    case UndefinedError = 2147483647
    
    /// Error is not in `cilloErrorDomain`
    case NotCilloDomain = -2147483648
  }

  // MARK: Initializers
  
  /// Initializer used to create custom errors retrieved from the cillo servers.
  ///
  /// :param: cilloErrorString The message that was given by the key "error" in the retrieved json.
  /// :param: requestType The request type that the error corresponds to. See Router enum for a full list.
  convenience init(json: JSON, requestType: Router) {
    var error = ""
    var code = 0
    if json["error"] != nil {
      error = json["error"].stringValue
    }
    if json["code"] != nil {
      code = json["code"].intValue
    }
    self.init(domain: NSError.cilloErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey: error, RequestTypeKey: requestType.requestDescription])
  }
  
  // MARK: Setup Helper Functions

  /// Creates an error for an instance where no data is given from alamofire.
  ///
  /// :param: requestType The request that this error occurred in.
  class func noJSONFromDataError(#requestType: Router) -> NSError {
    return NSError(domain: "NoJSONErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "Problem making JSON from data retrieved by Alamofire", RequestTypeKey: requestType.requestDescription])
  }
  
  func cilloErrorCode() -> CilloErrorCodes {
    if domain == NSError.cilloErrorDomain {
      return CilloErrorCodes(rawValue: code) ?? .UndefinedError
    } else {
      return .NotCilloDomain
    }
  }
  
  /// Shows this error's properties in a UIAlertView that pops up on the screen.
  func showAlert() {
    let alert = UIAlertView(title: "\(domain) : \(code)", message: "\(localizedDescription)\n\(requestTypeDescription)", delegate: nil, cancelButtonTitle: "OK")
    alert.show()
  }
}

// MARK: -

extension NSMutableAttributedString {
  
  // MARK: Setup Helper Functions
  
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

extension JTSImageViewController {
  
  /// Presents a JTSImageViewController over the provided viewController that expands the provided image to full screen.
  ///
  /// :param: image The image to be expanded to full screen.
  /// :param: viewController The controller that will be blurred behind the image.
  /// :param: sender The view that was pressed containing the image to expand.
  class func expandImage<T: UIViewController where T: JTSImageViewControllerOptionsDelegate>(image: UIImage, toFullScreenFromRoot viewController: T, withSender sender: UIView) {
    let imageInfo = JTSImageInfo()
    imageInfo.image = image
    imageInfo.referenceRect = sender.frame
    imageInfo.referenceView = sender.superview
    imageInfo.referenceContentMode = sender.contentMode
    imageInfo.referenceCornerRadius = sender.layer.cornerRadius
    let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: .Image, backgroundStyle: .None)
    imageViewer.optionsDelegate = viewController
    imageViewer.showFromViewController(viewController, transition: ._FromOriginalPosition)
  }
}

// MARK: -

extension KeychainWrapper {
  
  // MARK: Constants
  
  /// Key to retrieve Auth_Token for the end user
  class var auth: String {
    return "Auth"
  }
  
  /// Key to retrieve userID for the end user
  class var user: String {
    return "User"
  }
  
  // MARK: Setup Helper Functions
  
  /// :returns: Auth token for end user. Nil if none stored in keychain or error.
  class func authToken() -> String? {
    return KeychainWrapper.stringForKey(KeychainWrapper.auth)
  }
  
  /// Remove the stored auth token from the keychain.
  ///
  /// :returns: True if the auth token was successfully cleared.
  class func clearAuthToken() -> Bool {
    return KeychainWrapper.removeObjectForKey(KeychainWrapper.auth)
  }
  
  /// Remove the stored user ID from the keychain.
  ///
  /// :returns: True if the user ID was successfully cleared.
  class func clearUserID() -> Bool {
    return KeychainWrapper.removeObjectForKey(KeychainWrapper.user)
  }
  
  /// Used to discover if keychain has values for keys .auth and .user
  ///
  /// :returns: True if there are values for both .auth and .user.
  class func hasAuthAndUser() -> Bool {
    if let auth = KeychainWrapper.authToken(), user = KeychainWrapper.userID() where auth != "" && user != 0 {
      return true
    } else {
      return false
    }
  }
  
  /// Stores an auth token in the keychain.
  ///
  /// :param: token The auth token to be stored.
  /// :returns: True if the storage was successful.
  class func setAuthToken(token: String) -> Bool {
    return KeychainWrapper.setString(token, forKey: KeychainWrapper.auth)
  }
  
  /// Stores a user ID in the keychain.
  ///
  /// :param: id The id of the end user to be stored.
  /// :returns: True if the storage was successful.
  class func setUserID(id: Int) -> Bool {
    return KeychainWrapper.setObject(id, forKey: KeychainWrapper.user)
  }
  
  /// :returns: User ID of end user. Nil if none stored in keychain or error.
  class func userID() -> Int? {
    return KeychainWrapper.objectForKey(KeychainWrapper.user) as? Int
  }
}

// MARK: -

extension String {
  
  // MARK: Setup Helper Functions

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

extension TTTAttributedLabel {
  
  // MARK: Setup Helper Functions
  
  /// Sets up links for the label and makes the label multiline, displaying the text.
  ///
  /// :param: text The attributed text to be displayed by this label.
  func setupWithAttributedText(text: NSAttributedString) {
    numberOfLines = 0
    enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
    linkAttributes = [kCTForegroundColorAttributeName : UIColor.cilloBlue()]
    attributedText = text
  }
  
  /// Sets up links for the label and makes the label multiline, displaying the text.
  ///
  /// :param: text The text to be displayed by this label.
  /// :param: font The font for this label to be displayed in.
  func setupWithText(text: String, andFont font: UIFont) {
    numberOfLines = 0
    self.font = font
    enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
    linkAttributes = [kCTForegroundColorAttributeName : UIColor.cilloBlue()]
    self.text = text
  }
}

// MARK: -

extension UIButton {
  
  // MARK: Constants
  
  /// Standard border width of bordered buttons.
  class var standardBorderWidth: Double {
    return 1.0
  }
  
  // MARK: Setup Helper Functions
  
  /// Sets up button to have a border with rounded corners.
  ///
  /// :param: width The width of the border.
  /// :param: color The color of the border.
  func setupWithRoundedBorderOfWidth(width: Double, andColor color: UIColor) {
    clipsToBounds = true
    layer.borderWidth = CGFloat(width)
    layer.cornerRadius = 5
    layer.borderColor = color.CGColor
  }
  
  /// Sets up button to have a border with width `standardBorderWidth` and color `ColorScheme.defaultScheme.solidButtonTextColor()`.
  func setupWithRoundedBorderOfStandardWidthAndColor() {
    setupWithRoundedBorderOfWidth(UIButton.standardBorderWidth, andColor: ColorScheme.defaultScheme.solidButtonTextColor())
  }
  
  /// Uses asynchronous image loading to set the background image to the image retrieved from the provided url.
  ///
  /// **Note:** This functions handles incrementing and decrementing `DataManager.sharedInstance.activeRequests`
  ///
  /// :param: url The url of the image to be retrieved
  /// :param: state The state to set the background image for
  func setBackgroundImageToImageWithURL(url: NSURL, forState state: UIControlState) {
    if url.absoluteString != nil { // without this check -> permanent activeRequests count increase
      DataManager.sharedInstance.activeRequests++
      setBackgroundImageForState(state, withURLRequest: NSURLRequest(URL: url), placeholderImage: nil,
        success: { _, _, image in
          self.setBackgroundImage(image, forState: state)
          DataManager.sharedInstance.activeRequests--
        },
        failure: { error in
          println(error)
          DataManager.sharedInstance.activeRequests--
        }
      )
    }
  }
}

// MARK: -

extension UIColor {
  
  // MARK: Custom Color Functions
  
  /// :returns: The gray color that is used for the buttons at the bottom of the cells.
  class func buttonGray() -> UIColor {
    return UIColor(red: 125/255.0, green: 138/255.0, blue: 150/255.0, alpha: 1.0)
  }
  
  /// :returns: The blue color that is the theme for the .Blue color scheme.
  class func cilloBlue() -> UIColor {
    return UIColor.cilloBlueWithAlpha(0.87)
  }
  
  /// Allows an alpha to be specified for the cillo blue color.
  ///
  /// :param: alpha The alpha of the returned color.
  /// :returns: The blue color that is the theme of Cillo with a specified alpha.
  class func cilloBlueWithAlpha(alpha: CGFloat) -> UIColor {
    return UIColor(red: 2/255.0, green: 81/255.0, blue: 138/255.0, alpha: alpha)
  }
  
  /// :returns: The gray color that is the theme for the .Gray color scheme.
  class func cilloGray() -> UIColor {
    return UIColor.cilloGrayWithAlpha(0.87)
  }
  
  /// Allows an alpha to be specified for the cillo gray color.
  ///
  /// :param: alpha The alpha of the returned color.
  /// :returns: The gray color that is the theme of Cillo with a specified alpha.
  class func cilloGrayWithAlpha(alpha: CGFloat) -> UIColor {
    return UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: alpha)
  }
  
  /// :returns: The light gray color that is used for dividers in UITableViews.
  class func defaultTableViewDividerColor() -> UIColor {
    return UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1.0)
  }
  
  /// :returns: The red color that is used for downvote coloring.
  class func downvoteRed() -> UIColor {
    return UIColor(red: 174/255.0, green: 0/255.0, blue: 37/255.0, alpha: 1.0)
  }
  
  /// :returns: A lighter black color that is used for the items on the nav bar in the .Gray screen.
  class func lighterBlack() -> UIColor {
    return UIColor(red: 78/255.0, green: 78/255.0, blue: 78/255.0, alpha: 1.0)
  }
  
  /// :returns: The light gray color that is used for placeholders in UITextFields.
  class func placeholderColor() -> UIColor {
    return UIColor(red: 199/255.0, green: 199/255.0, blue: 205/255.0, alpha: 1.0)
  }
  
  /// :returns: The green color that is used for upvote coloring.
  class func upvoteGreen() -> UIColor {
    return UIColor(red: 75/255.0, green: 129/255.0, blue: 44/255.0, alpha: 1.0)
  }
}

// MARK: -

extension UIImage {
  
  // MARK: Constants
  
  /// The factor to compress images by beforing uploading them to the Cillo servers
  class var JPEGCompression: CGFloat {
    return 0.5
  }
}

// MARK: -

extension UIImagePickerController {
  
  class func defaultActionSheetDelegateImplementationForSource<T: UIViewController where T: UIImagePickerControllerDelegate, T: UINavigationControllerDelegate, T: UIActionSheetDelegate>(source: T, withSelectedIndex index: Int) {
    switch index {
    case 0:
      let pickerController = UIImagePickerController()
      pickerController.delegate = source
      source.presentViewController(pickerController, animated: true, completion: nil)
    case 1:
      let pickerController = UIImagePickerController()
      pickerController.delegate = source
      if UIImagePickerController.isSourceTypeAvailable(.Camera) {
        pickerController.sourceType = .Camera
      }
      source.presentViewController(pickerController, animated: true, completion: nil)
    default:
      break
    }
  }
  
  /// Presents an action sheet that allows the user to choose a photo from library or take a photo with the camera.
  ///
  /// :param: source The view controller that will be the source of the modal presentation of the action sheet and the image picker onto it.
  class func presentActionSheetForPhotoSelectionFromSource<T: UIViewController where T: UIImagePickerControllerDelegate, T: UINavigationControllerDelegate, T: UIActionSheetDelegate>(source: T, withTitle title: String, iPadReference: UIButton?) {
    
    if objc_getClass("UIAlertController") != nil {
      let actionSheet = UIAlertController(title: title, message: nil, preferredStyle: .ActionSheet)
      let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { _ in
      }
      let pickerAction = UIAlertAction(title: "Choose Photo from Library", style: .Default) { _ in
        let pickerController = UIImagePickerController()
        pickerController.delegate = source
        source.presentViewController(pickerController, animated: true, completion: nil)
      }
      let cameraAction = UIAlertAction(title: "Take Photo", style: .Default) { _ in
        let pickerController = UIImagePickerController()
        pickerController.delegate = source
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
          pickerController.sourceType = .Camera
        }
        source.presentViewController(pickerController, animated: true, completion: nil)
      }
      actionSheet.addAction(cancelAction)
      actionSheet.addAction(pickerAction)
      actionSheet.addAction(cameraAction)
      if let iPadReference = iPadReference where UIDevice.currentDevice().userInterfaceIdiom == .Pad {
        actionSheet.modalPresentationStyle = .Popover
        let popPresenter = actionSheet.popoverPresentationController
        popPresenter?.sourceView = iPadReference
        popPresenter?.sourceRect = iPadReference.bounds
      }
      source.presentViewController(actionSheet, animated: true, completion: nil)
    } else {
      let actionSheet = UIActionSheet(title: title, delegate: source, cancelButtonTitle: nil, destructiveButtonTitle: nil, otherButtonTitles: "Choose Photo from Library", "Take Photo", "Cancel")
      actionSheet.cancelButtonIndex = 2
      if let iPadReference = iPadReference where UIDevice.currentDevice().userInterfaceIdiom == .Pad {
        actionSheet.showFromRect(iPadReference.bounds, inView: iPadReference, animated: true)
      } else {
        actionSheet.showInView(source.view)
      }
    }
  }
}

// MARK: -

extension UINavigationBar {
  
  // MARK: Setup Helper Functions
  
  /// Sets up this navigation bar with the proper colors according the specified scheme.
  ///
  /// :param: scheme The scheme to use when setting up this navigation bar.
  func setupAttributesForColorScheme(scheme: ColorScheme) {
    barTintColor = scheme.navigationBarColor()
    tintColor = scheme.barButtonItemColor()
    titleTextAttributes = [NSForegroundColorAttributeName: scheme.navigationBarTitleColor()]
  }
}

// MARK: -

extension UIStoryboard {
  
  // MARK: Constants
  
  /// The instance of the storyboard used.
  class var mainStoryboard: UIStoryboard {
    return UIStoryboard(name: "Main", bundle: nil)
  }
}

// MARK: -

extension UITextView {
  
  // MARK: Constants
  
  /// Height of keyboard when a UITextView is selected.
  class var keyboardHeight: CGFloat {
    return 256
  }
}

// MARK: -

extension UIViewController {
  
  // MARK: Setup Helper Functions
  
  /// Adds an animated UIActivityIndicatorView to the center of view in this UIViewController.
  ///
  /// :returns: The UIView at the center of view in this UIViewController.
  /// :returns: **Note:** Can remove the UIView from the center of this view by calling returnedView.removeFromSuperView(), where returnedView is the UIView returned by this function.
  func addActivityIndicatorToCenterWithText(text: String) -> UIView {
    let loadingView = UIView(frame: CGRect(x: 0, y: 0, width: 170, height: 170))
    loadingView.backgroundColor = ColorScheme.defaultScheme.activityIndicatorBackgroundColor()
    loadingView.clipsToBounds = true
    loadingView.layer.cornerRadius = 10.0
    loadingView.center = CGPoint(x: view.center.x, y: view.center.y)
    if let navigationController = navigationController as? FormattedNavigationViewController {
      loadingView.center.y -= navigationController.navigationBar.frame.height / 2
    }
    if let tabBarController = tabBarController as? TabViewController {
      loadingView.center.y -= tabBarController.tabBar.frame.height / 2
    }
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: ColorScheme.defaultScheme.activityIndicatoryStyle())
    activityIndicator.frame.origin.x = 65
    activityIndicator.frame.origin.y = 60
    loadingView.addSubview(activityIndicator)
    
    let loadingLabel = UILabel(frame: CGRect(x: 15, y: 115, width: 140, height: 30))
    loadingLabel.backgroundColor = UIColor.clearColor()
    loadingLabel.textColor = ColorScheme.defaultScheme.activityIndicatorTextColor()
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

