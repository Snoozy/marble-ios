//
//  NewPostViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 1/6/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Handles creating new Posts.
class NewPostViewController: UIViewController {

  // MARK: Properties
  
  /// Group that this new Post will be posted to.
  ///
  /// Set this property to pass a group name to this UIViewController from another UIViewController.
  var group: Group?
  
  // MARK: IBOutlets
  
  /// Allows logged in User to enter the group name that he/she wants to post the new Post to.
  ///
  /// **Note:** Text is automatically set if group is not nil.
  @IBOutlet weak var groupTextView: UITextView!
  
  /// Allows logged in User to enter a title to his/her new Post.
  @IBOutlet weak var titleTextView: UITextView!
  
  /// Allows logged in User to enter text for his/her new Post.
  @IBOutlet weak var postTextView: UITextView!
  
  /// Set to PostTextViewHeight after viewDidLayoutSubviews().
  @IBOutlet weak var postTextViewHeightConstraint: NSLayoutConstraint!

  /// Button used to create the new Post.
  @IBOutlet weak var createPostButton: UIButton!
  
  // MARK: Constants
  
  /// Height needed for all components of a NewPostViewController excluding postTextView in the Storyboard.
  ///
  /// **Note:** Height of postTextView must be calculated based on the frame size of the device.
  class var VertSpaceExcludingPostTextView: CGFloat {
    get {
      return 186
    }
  }
  
  /// Calculated height of postTextView based on frame size of device.
  var PostTextViewHeight: CGFloat {
    get {
      return view.frame.height - UITextView.KeyboardHeight - NewPostViewController.VertSpaceExcludingPostTextView
    }
  }
  
  /// Segue Identifier in Storyboard for this UIViewController to PostTableViewController.
  var SegueIdentifierThisToPost: String {
    get {
      return "NewPostToPost"
    }
  }
  
  // MARK: UIViewController
  
  /// Resizes postTextView so the keyboard won't overlap any UI elements and sets the group name in groupTextView if a group was passed tot his UIViewController.
  override func viewDidLayoutSubviews() {
    postTextViewHeightConstraint.constant = PostTextViewHeight
    if let group = group {
      groupTextView.text = group.name
    }
  }
  
  /// Handles passing of data when navigation between UIViewControllers occur.
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // TODO: Figure out how to remove this from the navigationController's stack. Possibly make it modal?
    if segue.identifier == SegueIdentifierThisToPost {
      var destination = segue.destinationViewController as PostTableViewController
      if let sender = sender as? Post {
        destination.post = sender
      }
    }
  }
  
  // MARK: Helper Functions
  
  /// Used to create and retrieve a new Post made by the logged in User from Cillo servers.
  ///
  /// :param: completion The completion block for the post creation.
  /// :param: post The new Post that was created from calling the servers.
  ///
  /// :param: * Nil if server call passed an error back.
  func createPost(completion: (post: Post?) -> Void) {
    var title: String?
    if titleTextView.text != "" {
      title = titleTextView.text
    }
    let activityIndicator = addActivityIndicatorToCenterWithText("Creating Post...")
    DataManager.sharedInstance.createPostByGroupName(groupTextView.text, repostID: nil, text: postTextView.text, title: title, completion: { (error, result) -> Void in
      activityIndicator.removeFromSuperview()
      if error != nil {
        println(error)
        error!.showAlert()
        completion(post: nil)
      } else {
        completion(post: result!)
      }
    })
  }
  
  // MARK: IBActions
  
  /// Triggers segue to PostTableViewController when createPostButton is pressed.
  @IBAction func triggerPostSegueOnButton(sender: UIButton) {
    createPost( { (post) -> Void in
      if let post = post {
        self.performSegueWithIdentifier(self.SegueIdentifierThisToPost, sender: post)
      }
    })
  }
  
}
