//
//  HomeTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 10/23/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

///Handles first view of Home tab (Front Page of Cillo). Formats TableView to look appealing and be functional.
class HomeTableViewController: MultiplePostsTableViewController {
    
    //MARK: - Constants
    
    override var SEGUE_IDENTIFIER_THIS_TO_POST : String {return "HomeToPost"}
    
    
    //MARK: - IBOutlets
    
    ///Activity indicator used for network interactions
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    //MARK: - UIViewController
    
    //Initializes posts array
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if NSUserDefaults.standardUserDefaults().valueForKey(NSUserDefaults.AUTH) != nil {
            retrievePosts()
        }
        
        //gets rid of Front Page Text on back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
    }
    
    
    //MARK: - Helper Functions
    
    ///Retrieves posts from server
    func retrievePosts() {
        activityIndicator.start()
        DataManager.sharedInstance.getHomePage( { (error, result) -> Void in
            self.activityIndicator.stop()
            if error != nil {
                println(error)
                error!.showAlert()
            } else {
                self.posts = result!
            }
        })
    }
    
}
