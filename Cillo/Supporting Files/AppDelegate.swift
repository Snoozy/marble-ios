//
//  AppDelegate.swift
//  Cillo
//
//  Created by Andrew Daley on 10/23/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  // MARK: Properties
  
  var window: UIWindow?
  
  /// The previous navigation controller selected by the tab bar. 
  ///
  /// Represents the most recent tab touched.
  ///
  /// Used to implement tap tab to top functionality
  var previousViewController: FormattedNavigationViewController?
  
  // MARK: UIApplicationDelegate
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.
    UITabBar.appearance().tintColor = UIColor.cilloBlue()
    return true
  }
}

// MARK: - UITabBarControllerDelegate

extension AppDelegate: UITabBarControllerDelegate {
  
  func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
    
    // Tap tab bar to go to top of table view functionality
    var shouldSelectVC = true
    if let navigationController = viewController as? FormattedNavigationViewController, presentedController = navigationController.topViewController as? CustomTableViewController {
      if let previousViewController = previousViewController where previousViewController == navigationController {
        if presentedController.tableView.contentOffset.y > 10 {
          presentedController.tableView.setContentOffset(CGPoint.zeroPoint, animated: true)
          shouldSelectVC = false // stops popping to navigation root vc
        }
      }
      previousViewController = navigationController
    }
    return shouldSelectVC
  }
}

