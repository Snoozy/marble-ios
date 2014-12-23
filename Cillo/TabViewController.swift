//
//  TabViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 12/20/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {
    
    //MARK: - Constants

    class var SEGUE_IDENTIFIER_THIS_TO_LOGIN : String {return "TabToLogin"}
    
    
    //MARK: - UIViewController
    
    override func viewDidAppear(animated: Bool){

        if NSUserDefaults.standardUserDefaults().stringForKey(NSUserDefaults.AUTH) == nil {
            performSegueWithIdentifier(TabViewController.SEGUE_IDENTIFIER_THIS_TO_LOGIN, sender: self)
        }
    }
    
    
    //MARK: - IBActions
    
    @IBAction func unwindToTab(sender: UIStoryboardSegue) {
        
    }

}
