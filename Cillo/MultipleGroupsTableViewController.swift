//
//  MultipleGroupsTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 12/19/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

class MultipleGroupsTableViewController: UITableViewController {

    //MARK: - Properties
    
    ///Stores list of all groups retrieved from JSON
    var groups : [Group] = []
    
    
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
        let cell = tableView.dequeueReusableCellWithIdentifier(GroupCell.REUSE_IDENTIFIER, forIndexPath: indexPath) as GroupCell
        let group = groups[indexPath.section]
        
        cell.makeCellFromGroup(group)
        
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

}
