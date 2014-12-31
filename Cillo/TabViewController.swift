//
//  TabViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 12/20/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

// TODO: Make view scroll to top if tab button is pressed.

/// Starting UIViewController of Cillo application.
///
/// Has 3 tabs:
///
/// * Home - Root VC is HomeTableViewController
/// * Groups - Root VC is MyGroupsTableViewController
/// * Me - Root VC is MeViewController
///
/// Note: Each tab has a FormattedNavigationController as the start of the tab.
class TabViewController: UITabBarController {
  
  // MARK: - Constants
  
  /// Segue Identifier in Storyboard for this UITabBarController to LoginViewController.
  class var SegueIdentifierThisToLogin: String {
    get {
      return "TabToLogin"
    }
  }

  // MARK: - UIViewController
  
  // Modally presents LoginViewController if NSUserDefaults doesn'y have an Auth Token stored.
  override func viewDidAppear(animated: Bool){
    if NSUserDefaults.standardUserDefaults().stringForKey(NSUserDefaults.Auth) == nil {
      performSegueWithIdentifier(TabViewController.SegueIdentifierThisToLogin, sender: self)
    }
  }
  
  // MARK: - IBActions
  
  /// Allows LoginViewController to unwind its modal segue.
  @IBAction func unwindToTab(sender: UIStoryboardSegue) {
    
  }
  
}
