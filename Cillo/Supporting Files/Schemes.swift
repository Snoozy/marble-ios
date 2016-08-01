//
//  ColorScheme.swift
//  Cillo
//
//  Created by Andrew Daley on 5/14/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

// MARK: - ColorScheme

/// Represents a particular color scheme for the app.
struct ColorScheme {
  
  // MARK: Properties
  
  /// Describes the color scheme that this instance represents.
  var scheme: ColorSchemeOptions
  
  // MARK: Static Variables
  
  /// Current scheme used in the live version of the app.
  static var defaultScheme: ColorScheme {
    return ColorScheme(scheme: .gray)
  }
  
  // MARK: Initializers
  
  /// Initializer that takes in a scheme option
  ///
  /// :param: scheme The chosen option to represent the created ColorScheme instance
  init(scheme: ColorSchemeOptions) {
    self.scheme = scheme
  }
  
  // MARK: Setup Helper Functions
  
  /// :returns: The background color of activity indicator views.
  func activityIndicatorBackgroundColor() -> UIColor {
    switch scheme {
    case .blue:
      return UIColor.cilloBlue()
    case .gray:
      return UIColor.cilloGray()
    }
  }
  
  /// :returns: The style of the activity indicator in activity indiciator views.
  func activityIndicatoryStyle() -> UIActivityIndicatorViewStyle {
    switch scheme {
    case .blue:
      return .whiteLarge
    case .gray:
      return .whiteLarge
    }
  }
  
  /// :returns: The text color of activity indicator views.
  func activityIndicatorTextColor() -> UIColor {
    switch scheme {
    case .blue:
      return UIColor.white
    case .gray:
      return UIColor.darkText
    }
  }

  /// :returns: The background color of any bar that appears above the keyboard.
  /// :returns: For example, the new comment bar.
  func barAboveKeyboardColor() -> UIColor {
    switch scheme {
    case .blue:
      return UIColor.cilloBlueWithAlpha(1.0)
    case .gray:
      return UIColor.cilloGrayWithAlpha(1.0)
    }
  }
  
  /// :returns: The color of the text of the button on any bar that appears above the keyboard.
  /// :returns: For example, the reply button on the new comment bar.
  func barAboveKeyboardTouchableTextColor() -> UIColor {
    switch scheme {
    case .blue:
      return UIColor.white
    case .gray:
      return UIColor.darkText
    }
  }
  
  /// :returns: The color to be displayed as the color of all bar button items.
  /// :returns: **Note:** The bar button color is the `tintColor` property.
  func barButtonItemColor() -> UIColor {
    switch scheme {
    case .blue:
      return UIColor.white
    case .gray:
      return UIColor.lighterBlack()
    }
  }
  
  /// :returns: The color to be displayed as the background color of the bottom bordered text fields.
  func bottomBorderedTextFieldBackgroundColor() -> UIColor {
    switch scheme {
    case .blue:
      return UIColor.white
    case .gray:
      return UIColor.white
    }
  }
  
  /// :returns: The color of the custom dividers implemented in most CustomTableViewController classes.
  func dividerBackgroundColor() -> UIColor {
    switch scheme {
    case .blue:
      return UIColor.cilloBlue()
    case .gray:
      return UIColor.cilloGray()
    }
  }
  
  /// :returns: The color to be displayed as the background color of the incoming message bubbles in chat.
  func incomingMessageBubbleColor() -> UIColor {
    switch scheme {
    case .blue:
      return UIColor.jsq_messageBubbleLightGray()
    case .gray:
      return UIColor.jsq_messageBubbleLightGray()
    }
  }
  
  /// :returns: The color of the name in any cell that represents a user that is the end user.
  func meTextColor() -> UIColor {
    switch scheme {
    case .blue:
      return UIColor.cilloBlue()
    case .gray:
      return UIColor.darkText
    }
  }
  
  /// :returns: The color to be displayed as the navigation bar background.
  /// :returns: **Note:** The background is the `barTint` property.
  func navigationBarColor() -> UIColor {
    switch scheme {
    case .blue:
      return UIColor.cilloBlue()
    case .gray:
      return UIColor.cilloGray()
    }
  }

  /// :returns: The color to be displayed as the color of the title of the navigation bar.
  /// :returns: **Note:** The title color is set through the `titleTextAttributes` `NSForegroundColorAttributeName` key.
  func navigationBarTitleColor() -> UIColor {
    switch scheme {
    case .blue:
      return UIColor.white
    case .gray:
      return UIColor.lighterBlack()
    }
  }
  
  /// :returns: The color of the name in a comment cell that represents a comment posted by the original poster of the post.
  func opTextColor() -> UIColor {
    switch scheme {
    case .blue:
      return UIColor.orange
    case .gray:
      return UIColor.cilloBlue()
    }
  }
  
  /// :returns: The color to be displayed as the background color of the outgoing message bubbles in chat.
  func outgoingMessageBubbleColor() -> UIColor {
    switch scheme {
    case .blue:
      return UIColor.jsq_messageBubbleBlue()
    case .gray:
      return UIColor.jsq_messageBubbleBlue()
    }
  }
  
  /// :returns: The color of the selected segement of all segmented controls.
  func segmentedControlSelectedColor() -> UIColor {
    switch scheme {
    case .blue:
      return UIColor.gray
    case .gray:
      return UIColor.gray
    }
  }
  
  /// :returns: The color of the unselected segement of all segmented controls.
  func segmentedControlUnselectedColor() -> UIColor {
    switch scheme {
    case .blue:
      return UIColor.white
    case .gray:
      return UIColor.white
    }
  }
  
  /// :returns: The color to be displayed as the background color of all buttons with a background.
  func solidButtonBackgroundColor() -> UIColor {
    switch scheme {
    case .blue:
      return UIColor.cilloBlue()
    case .gray:
      return UIColor.white
    }
  }
  
  /// :returns: The color to be displayed as the text color of all buttons with a background.
  func solidButtonTextColor() -> UIColor {
    switch scheme {
    case .blue:
      return UIColor.white
    case .gray:
      return UIColor.lighterBlack()
    }
  }
  
  /// :returns: The status bar style for the application.
  func statusBarStyle() -> UIStatusBarStyle {
    switch scheme {
    case .blue:
      return .lightContent
    case .gray:
      return .default
    }
  }
  
  /// :returns: The color to be displayed as the background color of text fields and text views.
  func textFieldBackgroundColor() -> UIColor {
    switch scheme {
    case .blue:
      return UIColor.cilloBlueWithAlpha(0.1)
    case .gray:
      return UIColor.cilloGrayWithAlpha(0.4)
    }
  }
  
  /// :returns: The color of all thin lines that are used as divider accents in the application.
  func thinLineBackgroundColor() -> UIColor {
    switch scheme {
    case .blue:
      return UIColor.defaultTableViewDividerColor()
    case .gray:
      return UIColor.defaultTableViewDividerColor()
    }
  }
  
  /// :returns: The color to be displayed as the text color of all button with white backgrounds.
  func touchableTextColor() -> UIColor {
    switch scheme {
    case .blue:
      return UIColor.cilloBlue()
    case .gray:
      return UIColor.gray
    }
  }
}

// MARK: ColorScheme Enums

/// Enum of the scheme options.
/// * Blue: A scheme based around cilloBlue color.
/// * Gray: A scheme based around cilloGray color.
enum ColorSchemeOptions {
  case blue
  case gray
}

// MARK: - DividerScheme

/// Represents a particular divider scheme for the app.
struct DividerScheme {
  
  // MARK: Properties
  
  /// Describes the divider scheme that this instance represents
  var scheme: DividerSchemeOptions
  
  // MARK: Static Variables

  /// Current scheme used in the live version of the app
  static var defaultScheme: DividerScheme {
    return DividerScheme(scheme: .thin)
  }
  
  // MARK: Initializers
  
  /// Initializer that takes in a scheme option
  ///
  /// :param: scheme The chosen option to represent the created DividerScheme instance
  init(scheme: DividerSchemeOptions) {
    self.scheme = scheme
  }
  
  // MARK: Setup Helper Functions

  /// :returns: The divider height for any MultipleBoardsTableViewController.
  func multipleBoardsDividerHeight() -> CGFloat {
    switch scheme {
    case .thick:
      return 10.0
    case .thin:
      return 1.0
    }
  }
  
  /// :returns: The divider height between ConversationCells for any MultipleConversationTableViewController.
  func multipleConversationDividerHeight() -> CGFloat {
    switch scheme {
    case .thick:
      return 10.0
    case .thin:
      return 1.0
    }
  }
  
  /// :returns: The divider height for any MultipleNotificationsTableViewController.
  func multipleNotificationsDividerHeight() -> CGFloat {
    switch scheme {
    case .thick:
      return 5.0
    case .thin:
      return 1.0
    }
  }
  
  /// :returns: The divider height for any MultiplePostsTableViewController.
  func multiplePostsDividerHeight() -> CGFloat {
    switch scheme {
    case .thick:
      return 10.0
    case .thin:
      return 1.0
    }
  }
  
  /// :returns: The divider height for any SingleBoardTableViewController.
  func singleBoardDividerHeight() -> CGFloat {
    switch scheme {
    case .thick:
      return 10.0
    case .thin:
      return 1.0
    }
  }
  
  /// :returns: The divider height between CommentCells for any SingleUserTableViewController.
  func singleUserCommentDividerHeight() -> CGFloat {
    switch scheme {
    case .thick:
      return 5.0
    case .thin:
      return 1.0
    }
  }
  
  /// :returns: The divider height between PostCells for any SingleUserTableViewController.
  func singleUserPostDividerHeight() -> CGFloat {
    switch scheme {
    case .thick:
      return 10.0
    case .thin:
      return 1.0
    }
  }
}

// MARK: DividerScheme  Enums

/// Enum of the scheme options.
/// * Thick: A scheme with mostly 5px dividers.
/// * Thin: A scheme with 1px dividers.
enum DividerSchemeOptions {
  case thin
  case thick
}
