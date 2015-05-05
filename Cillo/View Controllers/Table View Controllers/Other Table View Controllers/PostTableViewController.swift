//
//  PostTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 10/31/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

// TODO: Debug comment

/// Handles view of expanded Post with Comments beneath it.
///
/// Formats TableView to look appealing and be functional.
///
/// **Note:** Must assign post property of superclass a relevant value before displaying this SinglePostTableViewController.
class PostTableViewController: SinglePostTableViewController {
  
  // MARK: Properties
  
  // TODO: Document.
  var newCommentView: (UIView, UITextField)?

  // MARK: Constants
  
  /// Segue Identifier in Storyboard for this UITableViewController to GroupTableViewController.
  override var SegueIdentifierThisToGroup: String {
    get {
      return "PostToGroup"
    }
  }
  
  /// Segue Identifier in Storyboard for this UITableViewController to UserTableViewController.
  override var SegueIdentifierThisToUser: String {
    get {
      return "PostToUser"
    }
  }
  
  class var StoryboardIdentifier: String {
    return "Post"
  }
  
  // MARK: UIViewController
  
  /// Initializes commentTree array.
  // TODO: Redocument
  override func viewDidLoad() {
    super.viewDidLoad()
    if NSUserDefaults.hasAuthAndUser() {
      retrieveData()
    }
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
  }
  
  // MARK: Notification
  
  // TODO: Document
  func keyboardWillShow(notif: NSNotification) {
    if let newCommentView = newCommentView {
      let value = notif.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
      let keyboardHeight = value.CGRectValue().height
      let duration = (notif.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
      UIView.animateWithDuration(duration, animations: {
        newCommentView.0.frame.offset(dx: 0, dy: -keyboardHeight + self.tabBarController!.tabBar.frame.height)
      })
    }
  }
  
  // TODO: Document
  func keyboardWillHide(notif: NSNotification) {
    if let newCommentView = newCommentView {
      newCommentView.0.removeFromSuperview()
      self.newCommentView = nil
    }
  }
  
  // MARK: Helper Functions
  
  // TODO: Document
  func createComment(completion: (success: Bool) -> Void) {
    if let newCommentView = newCommentView {
      let textField = newCommentView.1
      let activityIndicator = addActivityIndicatorToCenterWithText("Making Comment...")
      DataManager.sharedInstance.createComment(parentID: nil, postID: post.postID, text: textField.text, lengthToPost: 1, completion: { (error, comment) -> Void in
        activityIndicator.removeFromSuperview()
        if error != nil {
          println(error!)
          error!.showAlert()
          completion(success: false)
        } else {
          if comment != nil {
            completion(success: true)
          }
        }
      })
    }
  }
  
  func replyToCommentAtIndex(index: Int, completion: (success: Bool) -> Void) {
    if let newCommentView = newCommentView {
      let textField = newCommentView.1
      let activityIndicator = addActivityIndicatorToCenterWithText("Replying to Comment...")
      let commentReplyingTo = commentTree[index]
      DataManager.sharedInstance.createComment(parentID: commentReplyingTo.commentID, postID: post.postID, text: textField.text, lengthToPost: commentReplyingTo.lengthToPost! + 1, completion: { (error, comment) -> Void in
        activityIndicator.removeFromSuperview()
        if error != nil {
          println(error!)
          error!.showAlert()
          completion(success: false)
        } else {
          if comment != nil {
            completion(success: true)
          }
        }
      })
    }
  }
  
  // TODO: Document
  func replyPressed(sender: UIButton) {
    if sender.tag < 0 {
      createComment( { (success) -> Void in
        if success {
          self.newCommentView?.1.resignFirstResponder()
          self.retrieveData()
        }
      })
    } else {
      replyToCommentAtIndex(sender.tag, completion: { (success) -> Void in
        if success {
          self.newCommentView?.1.resignFirstResponder()
          self.retrieveData()
        }
      })
    }
  }
  
  // TODO: Document.
  func makeNewCommentView(#tag: Int) {
    let textField = UITextField(frame: CGRect(x: 8.0, y: 8.0, width: self.view.frame.size.width - 72.0, height: 30.0))
    textField.backgroundColor = UIColor.whiteColor()
    textField.delegate = self
    let replyButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 58.0, y: 8.0, width: 50.0, height: 30.0))
    replyButton.tintColor = UIColor.whiteColor()
    replyButton.setTitle("Reply", forState: .Normal)
    replyButton.addTarget(self, action: "replyPressed:", forControlEvents: .TouchUpInside)
    replyButton.tag = tag
    let view = UIView(frame: CGRect(x: 0.0, y: self.view.frame.size.height - 46.0, width: self.view.frame.size.width, height: 46.0))
    view.backgroundColor = UIColor.cilloBlue()
    view.addSubview(textField)
    view.addSubview(replyButton)
    newCommentView = (view, textField)
  }
  
  // TODO: Document.
  @IBAction func newCommentPressed(sender: UIButton) {
    // tag of -1 signifies a direct reply to the post
    makeNewCommentView(tag: -1)
    view.addSubview(newCommentView!.0)
    newCommentView!.1.becomeFirstResponder()
  }
  
  // TODO: Document
  @IBAction func replyToCommentPressed(sender: UIButton) {
    makeNewCommentView(tag: sender.tag)
    view.addSubview(newCommentView!.0)
    newCommentView!.1.becomeFirstResponder()
  }
  
  /// Used to retrieve all necessary data to display UITableViewCells in this UIViewController.
  ///
  /// Assigns commentTree property of SinglePostTableViewController correct values from server calls.
  override func retrieveData() {
    retrieveCommentTree( { (commentTree) -> Void in
      if commentTree != nil {
        self.commentTree = commentTree!
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
      }
    })
  }
  
  /// Used to retrieve the comment tree for post from Cillo servers.
  ///
  /// :param: completion The completion block for the server call.
  /// :param: comments The comment tree for this post.
  /// :param: * Nil if there was an error in the server call.
  func retrieveCommentTree(completion: (commentTree: [Comment]?) -> Void) {
    let activityIndicator = addActivityIndicatorToCenterWithText("Retrieving Comments")
    DataManager.sharedInstance.getPostCommentsByID(post, completion: { (error, result) -> Void in
      activityIndicator.removeFromSuperview()
      if error != nil {
        println(error!)
        error!.showAlert()
        completion(commentTree: nil)
      } else {
        completion(commentTree: result!)
      }
    })
  }
  
}

extension PostTableViewController: UITextFieldDelegate {
  
  // MARK: UITextFieldDelegate
  
  // TODO: Document
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.endEditing(true)
    return true
  }
  
}
