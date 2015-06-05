//
//  TabViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 12/20/14.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Starting UIViewController of Cillo application.
///
/// Has 3 tabs:
///
/// * Home - Root VC is HomeTableViewController
/// * Discover - Root VC is MyBoardsTableViewController
/// * Me - Root VC is MeViewController
///
/// **Note:** Each tab has a FormattedNavigationController as the start of the tab.
class TabViewController: UITabBarController {

  // MARK: UIViewController
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == SegueIdentifiers.tabToNewRepost {
      let destination = segue.destinationViewController as! NewRepostViewController
      if let sender = sender as? Repost {
          destination.postToRepost = sender.originalPost
      } else if let sender = sender as? Post {
          destination.postToRepost = sender
      }
    } else if segue.identifier == SegueIdentifiers.tabToSettings {
      let destination = segue.destinationViewController as! SettingsViewController
      if let sender = sender as? User {
        destination.user = sender
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    delegate = UIApplication.sharedApplication().delegate as? UITabBarControllerDelegate
  }
  
  override func viewDidAppear(animated: Bool){
    // Modally presents LoginViewController if NSUserDefaults doesn't have an Auth Token stored.
    super.viewDidAppear(animated)
    if !NSUserDefaults.hasAuthAndUser() {
      performSegueWithIdentifier(SegueIdentifiers.tabToLogin, sender: self)
    } else {
      println(NSUserDefaults.standardUserDefaults().valueForKey(NSUserDefaults.auth)! as! String)
      println(NSUserDefaults.standardUserDefaults().valueForKey(NSUserDefaults.user)! as! Int)
    }
  }
  
  // MARK: Navigation Helper Functions
  
  /// Makes the displayed view controllers displayed by this TabViewContoller retrieve their data from the Cillo servers.
  func forceDataRetrievalUponUnwinding() {
    for vc in viewControllers! {
      if let vc = vc as? FormattedNavigationViewController, visibleVC = vc.topViewController as? CustomTableViewController {
        visibleVC.retrieveData()
      } else if let vc = vc as? CustomTableViewController {
        vc.retrieveData()
      }
    }
  }
  
  // MARK: IBActions
  
  /// Allows any View Controller to unwind back to the main Tab bar.
  @IBAction func unwindToTab(sender: UIStoryboardSegue) {
  }
}
