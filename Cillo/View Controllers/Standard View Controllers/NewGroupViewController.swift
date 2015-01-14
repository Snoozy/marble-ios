//
//  NewGroupViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 1/7/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Handles creating new Groups.
class NewGroupViewController: UIViewController {

  // MARK: IBOutlets
  
  /// Allows logged in User to enter the Group name for his/her new Group.
  @IBOutlet weak var nameTextView: UITextView!
  
  /// Allows logged in User to enter a description for his/her new Group.
  @IBOutlet weak var descripTextView: UITextView!
  
  /// Set to DescripTextViewHeight after viewDidLayoutSubviews().
  @IBOutlet weak var descripTextViewHeightConstraint: NSLayoutConstraint!
  
  /// Button used to create the new Group.
  @IBOutlet weak var createGroupButton: UIButton!
  
  // MARK: Constants
  
  /// Height needed for all components of a NewGroupViewController excluding descripTextView in the Storyboard.
  ///
  /// **Note:** Height of descripTextView must be calculated based on the frame size of the device.
  class var VertSpaceExcludingDescripTextView: CGFloat {
    get {
      return 148
    }
  }
  
  /// Calculated height of descripTextView based on frame size of device.
  var DescripTextViewHeight: CGFloat {
    get {
      return view.frame.height - UITextView.KeyboardHeight - NewGroupViewController.VertSpaceExcludingDescripTextView
    }
  }
  
  /// Segue Identifier in Storyboard for this UIViewController to GroupTableViewController.
  var SegueIdentifierThisToGroup: String {
    get {
      return "NewGroupToGroup"
    }
  }
  
  // MARK: UIViewController
  
  /// Resizes postTextView so the keyboard won't overlap any UI elements and sets the group name in groupTextView if a group was passed to this UIViewController.
  override func viewDidLayoutSubviews() {
    descripTextViewHeightConstraint.constant = DescripTextViewHeight
  }
  
  /// Handles passing of data when navigation between UIViewControllers occur.
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // TODO: Figure out how to remove this from the navigationController's stack. Possibly make it modal?
    if segue.identifier == SegueIdentifierThisToGroup {
      var destination = segue.destinationViewController as GroupTableViewController
      if let sender = sender as? Group {
        destination.group = sender
      }
    }
  }
  
  // MARK: Helper Functions
  
  /// Used to create and retrieve a new Group made by the logged in User from Cillo servers.
  ///
  /// :param: completion The completion block for the group creation.
  /// :param: group The new Group that was created from calling the servers.
  ///
  /// :param: * Nil if server call passed an error back.
  func createGroup(completion: (group: Group?) -> Void) {
    var descrip: String?
    if descripTextView.text != "" {
      descrip = descripTextView.text
    }
    let activityIndicator = addActivityIndicatorToCenterWithText("Creating Group...")
    DataManager.sharedInstance.createGroup(name: nameTextView.text, description: descrip, completion: { (error, result) -> Void in
      activityIndicator.removeFromSuperview()
      if error != nil {
        println(error)
        error!.showAlert()
        completion(group: nil)
      } else {
        completion(group: result!)
      }
    })
  }
  
  // MARK: IBActions
  
  /// Triggers segue to GroupTableViewController when createGroupButton is pressed.
  @IBAction func triggerGroupSegueOnButton(sender: UIButton) {
    createGroup( { (group) -> Void in
      if let group = group {
        self.performSegueWithIdentifier(self.SegueIdentifierThisToGroup, sender: group)
      }
    })
  }

}
