//
//  HomeNavigationViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 10/31/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

///Handles all navigation segues in Home tab of application
class FormattedNavigationViewController: UINavigationController {
    
    //MARK: - UIViewController
    
    //Changes title of navigationBar to white color
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.tintColor = UIColor.whiteColor()
    }
    
    //Changes top battery bar to white color
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
}
