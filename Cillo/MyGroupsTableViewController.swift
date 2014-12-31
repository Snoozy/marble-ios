//
//  MyGroupsViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 11/25/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

/// Handles first view of Groups tab (Groups of logged in User).
///
/// Formats TableView to look appealing and be functional.
class MyGroupsTableViewController: MultipleGroupsTableViewController {
  
  // MARK: - IBOutlets
  
  /// Activity indicator used for network interactions.
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  // MARK: - UIViewController
  
  // Initializes groups array
  override func viewDidLoad() {
    super.viewDidLoad
    
    if NSUserDefaults.standardUserDefaults().valueForKey(NSUserDefaults.Auth) != nil {
      retrieveGroups()
    }
    
    // Gets rid of Groups Text on back button
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
  }
  
  // MARK: - Helper Functions
  
  /// Used to retrieve groups followed by logged in User from Cillo servers.
  ///
  /// Assigns groups property of MultipleGroupsTableViewController correct values from server calls.
  func retrieveGroups() {
    activityIndicator.start()
    if let id = (NSUserDefaults.standardUserDefaults().valueForKey(NSUserDefaults.USER) as? User)?.userID {
      DataManager.sharedInstance.getUserGroupsByID(userID: id { (error, result) -> Void in
        self.activityIndicator.stop()
        if error != nil {
          println(error)
          error!.showAlert()
        } else {
          self.groups = result!
        }
      })
    }
    
  }
  
}
