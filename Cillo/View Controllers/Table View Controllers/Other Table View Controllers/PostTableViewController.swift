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
  
  // MARK: IBOutlets
  
  /// The button that the end user can press to make a new comment.
  ///
  /// This button will change to a Cancel button when newCommentView is not nil.
  @IBOutlet weak var newCommentBarButton: UIBarButtonItem!
  
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
  
  override func viewWillAppear(animated: Bool) {
    makeNewCommentViewWithTag(-1)
    view.addSubview(newCommentView!.0)
    view.bringSubviewToFront(newCommentView!.0)
    tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 46, right: 0)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if KeychainWrapper.hasAuthAndUser() {
      retrieveData()
    }
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
  }
  
  // MARK: UIScrollViewDelegate
  
  override func scrollViewDidScroll(scrollView: UIScrollView) {
    // keeps newCommentView correctly positioned in scrollView
    if let newCommentView = newCommentView {
      if let keyboardHeight = keyboardHeight {
        let newY = tableView.contentOffset.y + tableView.frame.size.height - 46.0 - keyboardHeight + tabBarController!.tabBar.frame.height
        newCommentView.0.frame = CGRect(x: 0.0, y: newY, width: tableView.frame.size.width, height: 46.0)
      } else {
        let newY = tableView.contentOffset.y + tableView.frame.size.height - 46.0
        newCommentView.0.frame = CGRect(x: 0.0, y: newY, width: tableView.frame.size.width, height: 46.0)
      }
    }
  }
  
  // MARK: Networking Helper Functions
  
  /// Replies to `post` directly.
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: success True if the server call was successful. Otherwise, false.
  func createComment(completionHandler: (success: Bool) -> ()) {
    if let newCommentView = newCommentView {
      let textField = newCommentView.1
      DataManager.sharedInstance.createCommentWithText(textField.text, postID: post.postID, lengthToPost: 1) { result in
        self.handleSuccessResponse(result, completionHandler: completionHandler)
      }
    }
  }
  
  /// Replies to a comment in `commentTree` at the specified index.
  ///
  /// :param: index The index of the comment to be replied to in the commentTree
  /// :param: completionHandler The completion block for the server call.
  /// :param: success True if the server call was successful. Otherwise, false.
  func replyToCommentAtIndex(index: Int, completionHandler: (success: Bool) -> ()) {
    if let newCommentView = newCommentView {
      let textField = newCommentView.1
      let commentReplyingTo = commentTree[index]
      DataManager.sharedInstance.createCommentWithText(textField.text, postID: post.postID, lengthToPost: commentReplyingTo.lengthToPost! + 1, parentID: commentReplyingTo.commentID) { result in
        self.handleSuccessResponse(result, completionHandler: completionHandler)
      }
    }
  }
  
  /// Used to retrieve the comment tree for post from Cillo servers.
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: comments The comment tree for this post.
  /// :param: * Nil if there was an error in the server call.
  func retrieveCommentTree(completionHandler: (commentTree: [Comment]?) -> ()) {
    DataManager.sharedInstance.getCommentsForPost(post) { result in
      self.handleSingleElementResponse(result, completionHandler: completionHandler)
    }
  }
  
  /// Used to retrieve all necessary data to display UITableViewCells in this UIViewController.
  ///
  /// Assigns commentTree property of SinglePostTableViewController correct values from server calls.
  override func retrieveData() {
    retrieveCommentTree { commentTree in
      dispatch_async(dispatch_get_main_queue()) {
        self.commentsRetrieved = true
        if let commentTree = commentTree {
          self.commentTree = commentTree
          self.tableView.reloadData()
        }
        self.refreshControl?.endRefreshing()
      }
    }
  }

  // MARK: Keyboard Notification Selectors
  
  /// The selector that will be called when the keyboard is hidden.
  ///
  /// :param: notif The notification that called this selector.
  func keyboardWillHide(notif: NSNotification) {
    if let newCommentView = newCommentView {
      setBarButtonToNewComment()
      let duration = (notif.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
      UIView.animateWithDuration(duration) {
        newCommentView.0.frame = CGRect(x: 0.0, y: self.tableView.contentOffset.y + self.tableView.frame.size.height - 46.0, width: self.tableView.frame.size.width, height: 46.0)
      }
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
      setBarButtonToCancel()
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
    if let (container,textField) = newCommentView {
      sender.enabled = false
      if container.tag < 0 { // direct reply to post
        createComment { success in
          sender.enabled = true
          if success {
            dispatch_async(dispatch_get_main_queue()) {
              container.tag = -1
              textField.tag = -1
              textField.resignFirstResponder()
              textField.text = ""
              self.retrieveData()
            }
          }
        }
      } else {
        replyToCommentAtIndex(container.tag) { success in
          sender.enabled = true
          if success {
            dispatch_async(dispatch_get_main_queue()) {
              container.tag = -1
              textField.tag = -1
              textField.resignFirstResponder()
              textField.text = ""
              self.retrieveData()
            }
          }
        }
      }
    }
  }
  
  // MARK: Setup Helper Functions

  /// Formats `newCommentView` UI correctly.
  ///
  /// :param: tag The tag that is assigned to the elements of `newCommentView` that will be used to tell the position of the comment being replied to in `commentTree`.
  func makeNewCommentViewWithTag(tag: Int) {
    let textField = CustomTextField(frame: CGRect(x: 8.0, y: 8.0, width: tableView.frame.size.width - 72.0, height: 30.0))
    textField.backgroundColor = UIColor.whiteColor()
    textField.delegate = self
    textField.returnKeyType = .Done
    textField.autocorrectionType = .No
    textField.spellCheckingType = .No
    textField.placeholder = "Write a comment..."
    textField.tag = tag
    let replyButton = UIButton(frame: CGRect(x: tableView.frame.size.width - 58.0, y: 8.0, width: 50.0, height: 30.0))
    replyButton.setTitleColor(ColorScheme.defaultScheme.barAboveKeyboardTouchableTextColor(), forState: .Normal)
    replyButton.setTitle("Reply", forState: .Normal)
    replyButton.addTarget(self, action: "replyPressed:", forControlEvents: .TouchUpInside)
    replyButton.tag = tag
    let view = UIView(frame: CGRect(x: 0.0, y: tableView.contentOffset.y + tableView.frame.size.height - 46.0, width: tableView.frame.size.width, height: 46.0))
    view.backgroundColor = ColorScheme.defaultScheme.barAboveKeyboardColor()
    view.alpha = 1.0
    view.addSubview(textField)
    view.addSubview(replyButton)
    view.tag = tag
    newCommentView = (view, textField)
  }
  
  /// Sets `newCommentBarButton` to say "Cancel".
  func setBarButtonToCancel() {
    newCommentBarButton.image = nil
    newCommentBarButton.title = "Cancel"
  }
  
  /// Sets `newCommentBarButton` to show the new comment icon.
  func setBarButtonToNewComment() {
    newCommentBarButton.image = UIImage(named: "New Comment")
    newCommentBarButton.title = nil
  }

  // MARK: IBActions
  
  /// Presents a `newCommentView` above the keyboard that allows the end user to reply to `post`.
  ///
  /// :param: sender The button that is touched to send this function is the new comment bar button item.
  @IBAction func newCommentPressed(sender: UIButton) {
    if let newCommentView = newCommentView {
      if let keyboardHeight = keyboardHeight {
        newCommentView.0.tag = -1
        newCommentView.1.tag = -1
        newCommentView.1.resignFirstResponder()
      } else {
        newCommentView.0.tag = -1
        newCommentView.1.tag = -1
        newCommentView.1.becomeFirstResponder()
      }
    } else {
      // tag of -1 signifies a direct reply to the post
      makeNewCommentViewWithTag(-1)
      view.addSubview(newCommentView!.0)
      newCommentView!.1.becomeFirstResponder()
    }
  }
  
  /// Presents a `newCommentView` above the keyboard that allows the end user to reply to a comment.
  ///
  /// :param: sender The button that is touched to send this function is a replyButton is a CommentCell.
  @IBAction func replyToCommentPressed(sender: UIButton) {
    if let newCommentView = newCommentView {
      newCommentView.0.tag = sender.tag
      newCommentView.1.tag = sender.tag
      newCommentView.1.becomeFirstResponder()
    } else {
      makeNewCommentViewWithTag(sender.tag)
      view.addSubview(newCommentView!.0)
      newCommentView!.1.becomeFirstResponder()
    }
  }
}

// MARK: - UITextFieldDelegate

extension PostTableViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField.text != "" {
      if textField.tag < 0 {
        createComment { success in
          if success {
            dispatch_async(dispatch_get_main_queue()) {
              self.newCommentView?.1.resignFirstResponder()
              self.retrieveData()
            }
          }
        }
      } else {
        replyToCommentAtIndex(textField.tag) { success in
          if success {
            dispatch_async(dispatch_get_main_queue()) {
              self.newCommentView?.1.resignFirstResponder()
              self.retrieveData()
            }
          }
        }
      }
    } else {
      newCommentView?.1.resignFirstResponder()
    }
    return true
  }
}
