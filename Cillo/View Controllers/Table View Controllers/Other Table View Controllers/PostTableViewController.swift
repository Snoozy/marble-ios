//
//  PostTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 10/31/14.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Handles view of expanded Post with Comments beneath it.
///
/// Formats TableView to look appealing and be functional.
///
/// **Note:** Must assign post property of superclass a relevant value before displaying this SinglePostTableViewController.
class PostTableViewController: SinglePostTableViewController {
  
  // MARK: Properties
  
  /// The height of the keyboard, as updated by the keyboard notification selectors.
  ///
  /// Nil if the keyboard is not showing.
  var keyboardHeight: CGFloat?
  
  /// The bar that is shown above the keyboard when the end user is creating a new comment.
  ///
  /// Index 0 of the tuple is the view representing the bar above the keyboard.
  ///
  /// Index 1 of the tuple is the textfield that contains the text of the new comment.
  var newCommentView: (UIView, UITextField)?
  
  // MARK: Constants
  
  /// Segue Identifier in Storyboard for segue to BoardTableViewController.
  override var segueIdentifierThisToBoard: String {
    return SegueIdentifiers.postToBoard
  }
  
  /// Segue Identifier in Storyboard for segue to UserTableViewController.
  override var segueIdentifierThisToUser: String {
    return SegueIdentifiers.postToUser
  }
  
  // MARK: UIViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if NSUserDefaults.hasAuthAndUser() {
      retrieveData()
    }
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
  }
  
  // MARK: UIScrollViewDelegate
  
  override func scrollViewDidScroll(scrollView: UIScrollView) {
    // keeps newCommentView correctly positioned in scrollView
    if let newCommentView = newCommentView, keyboardHeight = keyboardHeight {
      let newY = tableView.contentOffset.y + tableView.frame.size.height - 46.0 - keyboardHeight + tabBarController!.tabBar.frame.height
      newCommentView.0.frame = CGRect(x: 0.0, y: newY, width: tableView.frame.size.width, height: 46.0)
    }
  }
  
  // MARK: Networking Helper Functions
  
  /// Replies to `post` directly.
  ///
  /// :param: completion The completion block for the server call.
  /// :param: success True if the server call was successful. Otherwise, false.
  func createComment(completion: (success: Bool) -> Void) {
    if let newCommentView = newCommentView {
      let textField = newCommentView.1
      UIApplication.sharedApplication().networkActivityIndicatorVisible = true
      DataManager.sharedInstance.createComment(parentID: nil, postID: post.postID, text: textField.text, lengthToPost: 1) { error, comment in
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        if let error = error {
          println(error)
          error.showAlert()
          completion(success: false)
        } else {
          completion(success: comment != nil)
        }
      }
    }
  }
  
  /// Replies to a comment in `commentTree` at the specified index.
  ///
  /// :param: index The index of the comment to be replied to in the commentTree
  /// :param: completion The completion block for the server call.
  /// :param: success True if the server call was successful. Otherwise, false.
  func replyToCommentAtIndex(index: Int, completion: (success: Bool) -> Void) {
    if let newCommentView = newCommentView {
      let textField = newCommentView.1
      UIApplication.sharedApplication().networkActivityIndicatorVisible = true
      let commentReplyingTo = commentTree[index]
      DataManager.sharedInstance.createComment(parentID: commentReplyingTo.commentID, postID: post.postID, text: textField.text, lengthToPost: commentReplyingTo.lengthToPost! + 1) { error, comment in
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        if let error = error {
          println(error)
          error.showAlert()
          completion(success: false)
        } else {
          completion(success: comment != nil)
        }
      }
    }
  }
  
  /// Used to retrieve the comment tree for post from Cillo servers.
  ///
  /// :param: completion The completion block for the server call.
  /// :param: comments The comment tree for this post.
  /// :param: * Nil if there was an error in the server call.
  func retrieveCommentTree(completion: (commentTree: [Comment]?) -> Void) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    DataManager.sharedInstance.getPostCommentsByID(post) { error, result in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      if let error = error {
        println(error)
        error.showAlert()
        completion(commentTree: nil)
      } else {
        completion(commentTree: result!)
      }
    }
  }
  
  /// Used to retrieve all necessary data to display UITableViewCells in this UIViewController.
  ///
  /// Assigns commentTree property of SinglePostTableViewController correct values from server calls.
  override func retrieveData() {
    retrieveCommentTree { commentTree in
      self.commentsRetrieved = true
      if let commentTree = commentTree {
        self.commentTree = commentTree
        self.tableView.reloadData()
      }
      self.refreshControl?.endRefreshing()
    }
  }

  // MARK: Keyboard Notification Selectors
  
  /// The selector that will be called when the keyboard is hidden.
  ///
  /// :param: notif The notification that called this selector.
  func keyboardWillHide(notif: NSNotification) {
    if let newCommentView = newCommentView {
      newCommentView.0.removeFromSuperview()
      self.newCommentView = nil
      keyboardHeight = nil
    }
  }
  
  /// The selector that will be called when the keyboard is shown.
  ///
  /// This function is used to update `keyboardHeight`.
  ///
  /// :param: notif The notification that called this selector.
  func keyboardWillShow(notif: NSNotification) {
    if let newCommentView = newCommentView {
      let value = notif.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
      keyboardHeight = value.CGRectValue().height
      let duration = (notif.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
      UIView.animateWithDuration(duration) {
        newCommentView.0.frame = CGRect(x: 0.0, y: self.tableView.contentOffset.y + self.tableView.frame.size.height - 46.0 - self.keyboardHeight! + self.tabBarController!.tabBar.frame.height, width: self.tableView.frame.size.width, height: 46.0)
      }
    }
  }
  
  // MARK: Button Selectors
  
  /// The selector that is assigned to the reply button in `newCommentView`'s touch event.
  ///
  /// :param: sender The sender of this event is the reply button in `newCommentView`.
  func replyPressed(sender: UIButton) {
    if sender.tag < 0 { // direct reply to post
      createComment { success in
        if success {
          self.newCommentView?.1.resignFirstResponder()
          self.retrieveData()
        }
      }
    } else {
      replyToCommentAtIndex(sender.tag) { success in
        if success {
          self.newCommentView?.1.resignFirstResponder()
          self.retrieveData()
        }
      }
    }
  }
  
  // MARK: Setup Helper Functions
  
  /// Formats `newCommentView` UI correctly.
  ///
  /// :param: tag The tag that is assigned to the elements of `newCommentView` that will be used to tell the position of the comment being replied to in `commentTree`.
  func makeNewCommentViewWithTag(tag: Int) {
    let textField = UITextField(frame: CGRect(x: 8.0, y: 8.0, width: tableView.frame.size.width - 72.0, height: 30.0))
    textField.backgroundColor = UIColor.whiteColor()
    textField.delegate = self
    textField.returnKeyType = .Done
    textField.autocorrectionType = .No
    textField.spellCheckingType = .No
    textField.tag = tag
    let replyButton = UIButton(frame: CGRect(x: tableView.frame.size.width - 58.0, y: 8.0, width: 50.0, height: 30.0))
    replyButton.tintColor = ColorScheme.defaultScheme.barAboveKeyboardTouchableTextColor()
    replyButton.setTitle("Reply", forState: .Normal)
    replyButton.addTarget(self, action: "replyPressed:", forControlEvents: .TouchUpInside)
    replyButton.tag = tag
    let view = UIView(frame: CGRect(x: 0.0, y: tableView.contentOffset.y + tableView.frame.size.height - 46.0, width: tableView.frame.size.width, height: 46.0))
    view.backgroundColor = ColorScheme.defaultScheme.barAboveKeyboardColor()
    view.addSubview(textField)
    view.addSubview(replyButton)
    newCommentView = (view, textField)
  }
  
  // MARK: IBActions
  
  /// Presents a `newCommentView` above the keyboard that allows the end user to reply to `post`.
  ///
  /// :param: sender The button that is touched to send this function is the new comment bar button item.
  @IBAction func newCommentPressed(sender: UIButton) {
    // tag of -1 signifies a direct reply to the post
    makeNewCommentViewWithTag(-1)
    view.addSubview(newCommentView!.0)
    newCommentView!.1.becomeFirstResponder()
  }
  
  /// Presents a `newCommentView` above the keyboard that allows the end user to reply to a comment.
  ///
  /// :param: sender The button that is touched to send this function is a replyButton is a CommentCell.
  @IBAction func replyToCommentPressed(sender: UIButton) {
    makeNewCommentViewWithTag(sender.tag)
    view.addSubview(newCommentView!.0)
    newCommentView!.1.becomeFirstResponder()
  }
}

// MARK: - UITextFieldDelegate

extension PostTableViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField.tag < 0 {
      createComment { success in
        if success {
          self.newCommentView?.1.resignFirstResponder()
          self.retrieveData()
        }
      }
    } else {
      replyToCommentAtIndex(textField.tag) { success in
        if success {
          self.newCommentView?.1.resignFirstResponder()
          self.retrieveData()
        }
      }
    }
    return true
  }
}
