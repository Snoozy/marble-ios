//
//  MyGroupsViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 11/25/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

///Handles first view of Groups tab (Groups of logged in User). Formats TableView to look appealing and be functional.
class MyGroupsTableViewController: MultipleGroupsTableViewController {

    //MARK: - UIViewController
    
    //Initializes groups array
    override func viewDidLoad() {
        groups.append(Group(name: "Soccer", systemName: "#soccer", description: "Soccer sucks", numFollowers: 2873, numPosts: 82739, picture: UIImage(named: "Groups")!))
        groups.append(Group(name: "Basketball", systemName: "#bball", description: "Basketball is good", numFollowers: 128738, numPosts: 1000000, picture: UIImage(named: "Groups")!))
        groups.append(Group(name: "Cillo", systemName: "#cillo", description: "Cillo is a social networking site that will be worth 4.5 billion dollars within a year. If it fails to reach this mark I will cry and possibly cry more. Sad face.", numFollowers: 1, numPosts: 2, picture: UIImage(named: "Groups")!))
        tableView.reloadData()
    }
    
}
