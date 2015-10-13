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
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.
    UITabBar.appearance().tintColor = UIColor.cilloBlue()
    UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(17)], forState: .Normal)
    
    // notification registration
    if application.respondsToSelector("registerForRemoteNotifications") {
      let types: UIUserNotificationType = .Alert | .Badge | .Sound
      let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
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
  
  func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    if KeychainWrapper.hasAuthAndUser() {
      let bytes = UnsafePointer<CChar>(deviceToken.bytes)
      var tokenString = ""
      
      for var i = 0; i < deviceToken.length; i++ {
        tokenString += String(format: "%02.2hhx", arguments: [bytes[i]])
      }
      println(tokenString)
      DataManager.sharedInstance.sendDeviceToken(tokenString) { error, success in
        // do nothing with response.
        println(success)
      }
    }
  }
  
  func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    println(error)
  }
  
  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    if application.applicationState == .Active {
      // do nothing
    } else {
      if let tabBarController = window?.rootViewController as? TabViewController {
        tabBarController.selectedIndex = tabBarController.notificationTabIndex
      }
    }
    application.applicationIconBadgeNumber = 0
    completionHandler(.NoData)
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

