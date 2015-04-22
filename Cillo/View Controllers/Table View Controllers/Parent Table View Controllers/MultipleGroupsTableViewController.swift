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
/// **Note:** Subclasses must override SegueIdentifierThisToGroup and SegueIdentifierThisToNewGroup.
class MultipleGroupsTableViewController: CustomTableViewController {
  
  var pageNumber: Int = 1
  
  // MARK: Properties
  
  /// Groups for this UITableViewController.
  var groups: [Group] = []
  
  // MARK: Constants
  
  /// Height of the custom divider UIViews at the bottom of the GroupCells managed by this MultipleGroupsTableViewController.
  class var DividerHeight: CGFloat {
    get {
      return 10.0
    }
  }
  
  /// Segue Identifier in Storyboard for this UITableViewController to GroupTableViewController.
  ///
  /// **Note:** Subclasses must override this Constant.
  var SegueIdentifierThisToGroup: String {
    get {
      return ""
    }
  }
  
  /// Segue Identifier in Storyboard for this UITableViewController to NewGroupViewController.
  ///
  /// **Note:** Subclasses must override this Constant.
  var SegueIdentifierThisToNewGroup: String {
    get {
      return ""
    }
  }
  
  // MARK: UIViewController
  
  /// Removes the default separator from tableView to allow for the custom implementation of cell separators.
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.separatorStyle = .None
  }
  
  /// Handles passing of data when navigation between UIViewControllers occur.
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == SegueIdentifierThisToGroup {
      var destination = segue.destinationViewController as! GroupTableViewController
      if let sender = sender as? NSIndexPath {
        destination.group = groups[sender.row]
      } else if let sender = sender as? UIButton {
        destination.group = groups[sender.tag]
      }
    } else if segue.identifier == SegueIdentifierThisToNewGroup {
      // no data to pass
    }
  }
  
  // MARK: UITableViewDataSource
  
  /// Assigns the number of sections in tableView to 1.
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  /// Assigns the number of rows in tableView based on the size of the groups array.
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return groups.count
  }
  
  /// Creates GroupCell based on section number of indexPath.
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(GroupCell.ReuseIdentifier, forIndexPath: indexPath) as! GroupCell
    let group = groups[indexPath.row]
    
    cell.makeCellFromGroup(group, withButtonTag: indexPath.row, andSeparatorHeight: (indexPath.row != groups.count - 1 ? MultipleGroupsTableViewController.DividerHeight : 0.0))
    
    return cell
  }
  
  
  // MARK: UITableViewDelegate
  
  /// Sets height of cell to appropriate value.
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    let dividerHeight = indexPath.row != groups.count - 1 ? MultipleGroupsTableViewController.DividerHeight : 0
    return GroupCell.heightOfGroupCellForGroup(groups[indexPath.row], withElementWidth: PrototypeTextViewWidth, andDividerHeight: dividerHeight)
  }
  
  /// Sends view to GroupTableViewController if GroupCell is selected.
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    self.performSegueWithIdentifier(SegueIdentifierThisToGroup, sender: indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
  }
  
  // MARK: Helper Functions
  
  /// Sends follow request to Cillo Servers for the group at index..
  ///
  /// :param: index The index of the group being followed in the groups array.
  /// :param: completion The completion block for the upvote.
  /// :param: success True if follow request was successful. If error was received, it is false.
  func followGroupAtIndex(index: Int, completion: (success: Bool) -> Void) {
    DataManager.sharedInstance.groupFollow(groups[index].groupID, completion: { (error, success) -> Void in
      if error != nil {
        println(error!)
        error!.showAlert()
        completion(success: false)
      } else {
        if success {
          completion(success: true)
          let groupIndexPath = NSIndexPath(forRow: index, inSection: 0)
          self.tableView.reloadRowsAtIndexPaths([groupIndexPath], withRowAnimation: .None)
        }
      }
    })
  }
  
  /// Sends unfollow request to Cillo Servers for the group at index..
  ///
  /// :param: index The index of the group being unfollowed in the groups array.
  /// :param: completion The completion block for the upvote.
  /// :param: success True if follow request was unsuccessful. If error was received, it is false.
  func unfollowGroupAtIndex(index: Int, completion: (success: Bool) -> Void) {
    DataManager.sharedInstance.groupUnfollow(groups[index].groupID, completion: { (error, success) -> Void in
      if error != nil {
        println(error!)
        error!.showAlert()
        completion(success: false)
      } else {
        if success {
          completion(success: true)
          let groupIndexPath = NSIndexPath(forRow: index, inSection: 0)
          self.tableView.reloadRowsAtIndexPaths([groupIndexPath], withRowAnimation: .None)
        }
      }
    })
  }
  
  // MARK: IBActions
  
  /// Triggers segue to GroupTableViewController.
  ///
  /// :param: sender The button that is touched to send this function is a nameButton or a pictureButton in a GroupCell.
  @IBAction func triggerGroupSegueOnButton(sender: UIButton) {
    self.performSegueWithIdentifier(SegueIdentifierThisToGroup, sender: sender)
  }
  
  /// Triggers segue to NewGroupViewController.
  ///
  /// :param: sender The button that is touched to send this function is the button in the navigationBar.
  @IBAction func triggerNewGroupSegueOnButton(sender: UIBarButtonItem) {
    self.performSegueWithIdentifier(SegueIdentifierThisToNewGroup, sender: sender)
  }
  
  /// Either follows the group at index sender.tag or presents an ActionSheet to unfollow the group.
  ///
  /// :param: sender The button that is touched to send this function is a followButton in a GroupCell.
  @IBAction func followOrUnfollowGroup(sender: UIButton) {
    let group = groups[sender.tag]
    if !group.following {
      followGroupAtIndex(sender.tag, completion: { (success) -> Void in
        if success {
          group.following = true
        }
      })
    } else {
      let actionSheet = UIAlertController(title: group.name, message: nil, preferredStyle: .ActionSheet)
      let unfollowAction = UIAlertAction(title: "Unfollow", style: .Default, handler: { (action) in
        self.unfollowGroupAtIndex(sender.tag, completion: { (success) -> Void in
          if success {
            group.following = false
          }
        })
      })
      let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
      })
      actionSheet.addAction(unfollowAction)
      actionSheet.addAction(cancelAction)
      presentViewController(actionSheet, animated: true, completion: nil)
    }
  }
  
}
