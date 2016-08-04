//
//  AppDelegate.swift
//  Cillo
//
//  Created by Andrew Daley on 10/23/14.
//  Copyright (c) 2015 Cillo. All rights reserved.
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
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    NetworkActivityIndicatorManager.sharedManager.isEnabled = true
    
    // Override point for customization after application launch.
    UITabBar.appearance().tintColor = UIColor.cilloBlue()
    UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 17)], for: UIControlState())
    
    // notification registration
    if application.responds(to: #selector(UIApplication.registerForRemoteNotifications as (UIApplication) -> () -> Void)) {
      let types: UIUserNotificationType = .Alert | .Badge | .Sound
      let settings = UIUserNotificationSettings(types: types, categories: nil)
      application.registerUserNotificationSettings(settings)
      application.registerForRemoteNotifications()
    } else {
      application.registerForRemoteNotificationTypes(.Alert | .Badge | .Sound)
    }
    
    // handle launch from notif
    if let notif = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
      if let tabBarController = window?.rootViewController as? TabViewController {
        tabBarController.selectedIndex = tabBarController.notificationTabIndex
      }
      application.applicationIconBadgeNumber = 0
    }
    
    return true
  }
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    if KeychainWrapper.hasAuthAndUser() {
      let bytes = UnsafePointer<CChar>((deviceToken as NSData).bytes)
      var tokenString = ""
      
      for i in 0 ..< deviceToken.count {
        tokenString += String(format: "%02.2hhx", arguments: [bytes[i]])
      }
      println(tokenString)
      DataManager.sharedInstance.sendDeviceToken(tokenString) { result in
        // do nothing with response.
      }
    }
  }
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    println(error)
  }
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    if application.applicationState == .active {
      // do nothing
    } else {
      if let tabBarController = window?.rootViewController as? TabViewController {
        tabBarController.selectedIndex = tabBarController.notificationTabIndex
      }
    }
    application.applicationIconBadgeNumber = 0
    completionHandler(.noData)
  }
}

// MARK: - UITabBarControllerDelegate

extension AppDelegate: UITabBarControllerDelegate {
  
  func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
    
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

