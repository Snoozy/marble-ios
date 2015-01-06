//
//  MultipleGroupsTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 12/19/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

/// Inherit this class for any UITableViewController that is only a table of GroupCells
///
/// **Note:** Subclasses must override SegueIdentifierThisToGroup.
class MultipleGroupsTableViewController: UITableViewController {
  
  // MARK: Properties
  
  /// Groups for this UITableViewController.
  var groups: [Group] = []
  
  // MARK: Constants
  
  /// Segue Identifier in Storyboard for this UITableViewController to GroupTableViewController.
  ///
  /// **Note:** Subclasses must override this Constant.
  var SegueIdentifierThisToGroup: String {
    get {
      return ""
    }
  }
  
  // MARK: UIViewController
  
  // Handles passing of data when navigation between UIViewControllers occur.
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == SegueIdentifierThisToGroup {
      var destination = segue.destinationViewController as GroupTableViewController
      if let sender = sender as? NSIndexPath {
        destination.group = groups[sender.section]
      } else if let sender = sender as? UIButton {
        destination.group = groups[sender.tag]
      }
    }
  }
  
  // MARK: UITableViewDataSource
  
  // Assigns the number of sections based on the length of the groups array.
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return groups.count
  }
  
  // Assigns 1 row to each section in this UITableViewController.
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  // Creates GroupCell based on section number of indexPath.
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(GroupCell.ReuseIdentifier, forIndexPath: indexPath) as GroupCell
    let group = groups[indexPath.section]
    
    cell.makeCellFromGroup(group, withButtonTag: indexPath.section)
    
    return cell
  }
  
  
  // MARK: UITableViewDelegate
  
  // Sets height of divider inbetween cells.
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return section == 0 ? 0 : 10
  }
  
  // Makes divider inbetween cells blue.
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView()
    view.backgroundColor = UIColor.cilloBlue()
    return view
  }
  
  // Sets height of cell to appropriate value.
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    let group = groups[indexPath.section]
    return group.heightOfDescripWithWidth(PrototypeTextViewWidth) + GroupCell.AdditionalVertSpaceNeeded
  }
  
  // Sends view to GroupTableViewController if GroupCell is selected.
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    self.performSegueWithIdentifier(SegueIdentifierThisToGroup, sender: indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
  }
  
  // MARK: IBActions
  
  /// Triggers segue to GroupTableViewController when nameButton or pictureButton is pressed in GroupCell.
  @IBAction func triggerGroupSegueOnButton(sender: UIButton) {
    self.performSegueWithIdentifier(SegueIdentifierThisToGroup, sender: sender)
  }
  
}
