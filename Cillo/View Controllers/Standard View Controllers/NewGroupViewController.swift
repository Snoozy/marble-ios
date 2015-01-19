//
//  NewGroupViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 1/7/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

// TODO: Put photo upload in UI and handle uploading photos in code

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
    // NOTE: currently ignoring segue, found another implementation
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
  /// :param: mediaID The media id for the uploaded photo that resembles this group.
  /// :param: completion The completion block for the group creation.
  /// :param: group The new Group that was created from calling the servers.
  ///
  /// :param: * Nil if server call passed an error back.
  func createGroupWithPhoto(mediaID: Int?, completion: (group: Group?) -> Void) {
    var descrip: String?
    if descripTextView.text != "" {
      descrip = descripTextView.text
    }
    let activityIndicator = addActivityIndicatorToCenterWithText("Creating Group...")
    DataManager.sharedInstance.createGroup(name: nameTextView.text, description: descrip, mediaID: mediaID, completion: { (error, result) -> Void in
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
  // TODO: Redocument
  @IBAction func triggerGroupSegueOnButton(sender: UIButton) {
    // TODO: handle media id and photo uploads
    createGroupWithPhoto(nil, completion: { (group) -> Void in
      if let group = group {
        // NOTE: currently ignoring segue, found another implementation
//        self.performSegueWithIdentifier(self.SegueIdentifierThisToGroup, sender: group)
        let groupViewController = self.storyboard!.instantiateViewControllerWithIdentifier("Group") as GroupTableViewController
        groupViewController.group = group
        var viewControllers = self.navigationController!.viewControllers
        viewControllers.removeLast()
        viewControllers.append(groupViewController)
        self.navigationController?.setViewControllers(viewControllers, animated: true)
      }
    })
  }

}
