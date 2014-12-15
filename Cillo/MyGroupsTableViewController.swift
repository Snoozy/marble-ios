//
//  MyGroupsViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 11/25/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

///Handles first view of Groups tab (Groups of logged in User). Formats TableView to look appealing and be functional.
class MyGroupsTableViewController: UITableViewController {

    //MARK: - Properties
    
    ///Stores list of all groups retrieved from JSON
    var groups : [Group] = []
    
    // MARK: - Constants
    
    ///Width of descripTextView in GroupCell
    var PROTOTYPE_TEXT_VIEW_WIDTH:CGFloat {
        //margins are 16
        return tableView.frame.width - 16
    }
    
    //MARK: - UIViewController
    
    //Initializes groups array
    override func viewDidLoad() {
        groups.append(Group(name: "Soccer", systemName: "#soccer", description: "Soccer sucks", numFollowers: 2873, numPosts: 82739, picture: UIImage(named: "Groups")!))
        groups.append(Group(name: "Basketball", systemName: "#bball", description: "Basketball is good", numFollowers: 128738, numPosts: 1000000, picture: UIImage(named: "Groups")!))
        groups.append(Group(name: "Cillo", systemName: "#cillo", description: "Cillo is a social networking site that will be worth 4.5 billion dollars within a year. If it fails to reach this mark I will cry and possibly cry more. Sad face.", numFollowers: 1, numPosts: 2, picture: UIImage(named: "Groups")!))
        tableView.reloadData()
    }
    
    
    // MARK: - UITableViewDataSource
    
    //Assigns the number of sections to length of groups array
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return groups.count
    }
    
    //Assigns 1 row to each section
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //Creates GroupCell with appropriate properties for Group at given section in groups
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Group", forIndexPath: indexPath) as GroupCell
        let group = groups[indexPath.section]
        
        cell.makeStandardGroupCellFromGroup(group)
        
        return cell
    }
    
    
    // MARK: - UITableViewDelegate
    
    //Sets height of divider inbetween cells
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 10
    }
    
    //Makes divider inbetween cells blue
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view = UIView()
        view.backgroundColor = UIColor.cilloBlue()
        return view
    }
    
    //Sets height of cell to appropriate value
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let group = groups[indexPath.section]
        return group.heightOfDescripWithWidth(PROTOTYPE_TEXT_VIEW_WIDTH) + GroupCell.ADDITIONAL_VERT_SPACE_NEEDED
    }
    
//    //If cell is selected then go to post
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        self.performSegueWithIdentifier("HomeToPost", sender: indexPath)
//        tableView.deselectRowAtIndexPath(indexPath, animated: false)
//    }
}
