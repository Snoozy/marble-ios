//
//  MeTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 11/13/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

/// Handles first view of Me tab (Profile of logged in User). 
///
/// Formats TableView to look appealing and be functional.
class MeTableViewController: SingleUserTableViewController {
  
  //MARK: - IBOutlets
  
  /// Activity indicator used for network interactions.
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  // MARK: - Constants
  
  /// Segue Identifier in Storyboard for this UITableViewController to PostTableViewController.
  override var SegueIdentifierThisToPost: String {
    get {
      return "MeToPost"
    }
  }
  
  // MARK: - UIViewController
  
  // Initializes user
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if NSUserDefaults.standardUserDefaults().valueForKey(NSUserDefaults.Auth) != nil {
      retrieveData()
    }
    
    // Gets rid of Me Text on back button
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Bordered, target: nil, action: nil)
  }
  
  /// Used to retrieve all necessary data to display UITableViewCells in this UIViewController.
  ///
  /// Assigns user, posts, and comments properties of SingleUserTableViewController correct values from server calls.
  func retrieveData() {
    retrieveUser()
    retrievePosts()
    retrieveComments()
  }
  
  /// Retrieves logged in User from NSUserDefaults and sets user property of superclass to the retrieved User.
  func retrieveUser() {
    if let me = NSUserDefaults.standardUserDefaults().valueForKey(NSUserDefaults.User) as? User {
      user = me
    }
  }
  
  /// Retrieves posts made by logged in User from Cillo servers and sets posts property of superclass to the retrieved Post array.
  func retrievePosts() {
    activityIndicator.start()
    DataManager.sharedInstance.getUserPosts(userID: user.userID { (error, result) -> Void in
      self.activityIndicator.stop()
      if error != nil {
        println(error)
        error!.showAlert()
      } else {
        self.posts = result!
      }
    })
  }
  
  /// Retrieves comments made by logged in User from Cillo servers and sets comments property of superclass to the retrieved Comment array.
  func retrieveComments() {
    //TODO: Write code once Comment networking code is done.
  }
}
