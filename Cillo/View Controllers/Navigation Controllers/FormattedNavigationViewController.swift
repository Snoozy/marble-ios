//
//  FormattedNavigationViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 10/31/14.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Formats UINavigationController to fit the style of the Cillo application.
///
/// **Note:** This class is the root UINavigationController of every Tab in the application.
class FormattedNavigationViewController: UINavigationController {

  // MARK: UIViewController
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return ColorScheme.defaultScheme.statusBarStyle()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationBar.setupAttributesForColorScheme(ColorScheme.defaultScheme)
    navigationBar.translucent = false
  }
}
