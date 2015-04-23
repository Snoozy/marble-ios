//
//  TabViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 12/20/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

// TODO: Make view scroll to top if tab button is pressed.

// TODO: Maybe implement a way to get back to root vcs quickly

/// Starting UIViewController of Cillo application.
///
/// Has 3 tabs:
///
/// * Home - Root VC is HomeTableViewController
/// * Groups - Root VC is MyGroupsTableViewController
/// * Me - Root VC is MeViewController
///
/// **Note:** Each tab has a FormattedNavigationController as the start of the tab.
class TabViewController: UITabBarController {
  
  // MARK: Constants
  
  /// The height of the tabBar of this UITabBarController
  var TabBarHeight: CGFloat {
    get {
      return tabBar.frame.size.height
    }
  }
  
  class var SegueIdentifierThisToNewRepost: String {
    get {
      return "TabToNewRepost"
    }
  }
  
  /// Segue Identifier in Storyboard for this UITabBarController to LoginViewController.
  class var SegueIdentifierThisToLogin: String {
    get {
      return "TabToLogin"
    }
  }
  
  // TODO: Document
  class var SegueIdentifierThisToNewPost: String {
    get {
      return "TabToNewPost"
    }
  }
  
  class var SegueIdentifierThisToSettings: String {
    return "TabToSettings"
  }

  // MARK: UIViewController
  
  // NOTE: Tab Bar is white right now. This code will make it blue if needed.
//  override func viewDidLoad() {
//    tabBar.barTintColor = UIColor.cilloBlue()
//    tabBar.translucent = false
//  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == TabViewController.SegueIdentifierThisToNewRepost {
      if let sender = sender as? Post {
        let destination = segue.destinationViewController as! NewRepostViewController
        if let repost = sender as? Repost {
          destination.postToRepost = repost.originalPost
        } else {
          destination.postToRepost = sender
        }
      }
    } else if segue.identifier == TabViewController.SegueIdentifierThisToSettings {
      if let sender = sender as? User {
        let destination = segue.destinationViewController as! SettingsViewController
        destination.user = sender
      }
    }
  }
  
  /// Modally presents LoginViewController if NSUserDefaults doesn't have an Auth Token stored.
  override func viewDidAppear(animated: Bool){
    if !NSUserDefaults.hasAuthAndUser() {
      performSegueWithIdentifier(TabViewController.SegueIdentifierThisToLogin, sender: self)
    } else {
      println(NSUserDefaults.standardUserDefaults().valueForKey(NSUserDefaults.Auth)! as! String)
      println(NSUserDefaults.standardUserDefaults().valueForKey(NSUserDefaults.User)! as! Int)
    }
  }
  
  // MARK: IBActions
  
  /// Allows LoginViewController to unwind its modal segue.
  @IBAction func unwindToTab(sender: UIStoryboardSegue) {
    
  }
  
}
