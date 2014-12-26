//
//  MeTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 11/13/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

///Handles first view of Me tab (Profile of logged in User). Formats TableView to look appealing and be functional.
class MeTableViewController: SingleUserTableViewController {
    
    //MARK: - Constants
    
    override var SEGUE_IDENTIFIER_THIS_TO_POST:String {return "MeToPost"}
    
    
    //MARK: - UIViewController
    
    //Initializes user
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //gets rid of Me Text on back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Bordered, target: nil, action: nil)
    }

}
