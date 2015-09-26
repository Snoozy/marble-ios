//
//  UserTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 1/5/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Handles view of User with Posts or Comments beneath it for any User that is not the end user.
///
/// Formats TableView to look appealing and be functional.
///
/// **Note:** Must assign user property of superclass a relevant value before displaying this SingleUserTableViewController.
class UserTableViewController: SingleUserTableViewController {

  // MARK: Constants
  
  /// Tag for the menu UIActionSheet to differentiate with the post UIActionSheet
  let menuActionSheetTag = Int.max
  
  /// Segue Identifier in Storyboard for segue to PostTableViewController.
  override var segueIdentifierThisToPost: String {
    return SegueIdentifiers.userToPost
  }
  
  /// Segue Identifier in Storyboard for segue to BoardTableViewController.
  override var segueIdentifierThisToBoard: String {
    return SegueIdentifiers.userToBoard
  }
  
  /// Segue Identifier in Storyboard for segue to BoardsTableViewController.
  override var segueIdentifierThisToBoards: String {
    return SegueIdentifiers.userToBoards
  }
  
  var segueIdentifierThisToMessages: String {
    return SegueIdentifiers.userToMessages
  }
  
  // MARK: UIViewController 
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if KeychainWrapper.hasAuthAndUser() && user != User(){
      retrieveData()
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    super.prepareForSegue(segue, sender: sender)
    if segue.identifier == segueIdentifierThisToMessages {
      let destination = segue.destinationViewController as! MessagesViewController
      if let sender = sender as? [String: AnyObject] {
        if let messages = sender["0"] as? [Message], conversation = sender["1"] as? Conversation {
          destination.messages = messages
          destination.conversation = conversation
        }
      }
    }
  }
  
  // MARK: UITableViewDelegate
  
  override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    switch cellsShown {
    case .Posts:
      if !postsFinishedPaging && !retrievingPage && indexPath.row > posts.count - 10 {
        retrievingPage = true
        retrievePosts { posts in
          dispatch_async(dispatch_get_main_queue()) {
            if let posts = posts {
              if posts.isEmpty {
                self.postsFinishedPaging = true
              } else {
                for post in posts {
                  self.posts.append(post)
                }
                self.postsPageNumber++
                self.tableView.reloadData()
              }
            }
            self.retrievingPage = false
          }
        }
      }
    case .Comments:
      if !commentsFinishedPaging && !retrievingPage && indexPath.row > comments.count - 10 {
        retrievingPage = true
        retrieveComments { comments in
          dispatch_async(dispatch_get_main_queue()) {
            if let comments = comments {
              if comments.isEmpty {
                self.commentsFinishedPaging = true
              } else {
                for comment in comments {
                  self.comments.append(comment)
                }
                self.commentsPageNumber++
                self.tableView.reloadData()
              }
            }
            self.retrievingPage = false
          }
        }
      }
    }
  }
  
  // MARK: Setup Helper Functions
  
  /// Presents an AlertController with style `.AlertView` that asks the user for confirmation of logging out.
  func presentBlockConfirmationAlertView() {
    if objc_getClass("UIAlertController") != nil {
      let alert = UIAlertController(title: "Block Confirmation", message: "Are you sure you want to block \(user.name)?", preferredStyle: .Alert)
      let yesAction = UIAlertAction(title: "Yes", style: .Default) { _ in
        self.blockUser { success in
          if success {
            dispatch_async(dispatch_get_main_queue()) {
              UIAlertView(title: "\(self.user.name) Blocked", message: nil, delegate: nil, cancelButtonTitle: "Ok").show()
              self.navigationController?.popToRootViewControllerAnimated(true)
              if let topVC = self.navigationController?.topViewController as? CustomTableViewController {
                topVC.retrieveData()
              }
            }
          }
        }
      }
      let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { _ in
      }
      alert.addAction(yesAction)
      alert.addAction(cancelAction)
      presentViewController(alert, animated: true, completion: nil)
    } else {
      let alert = UIAlertView(title: "Block Confirmation", message: "Are you sure you want to block \(user.name)?", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "Yes", "Cancel")
      alert.show()
    }
  }
  
  /// Presents an AlertController with style `.ActionSheet` that prompts the user with various possible additional actions.
  func presentMenuActionSheet() {
    if objc_getClass("UIAlertController") != nil {
      let actionSheet = UIAlertController(title: "More", message: nil, preferredStyle: .ActionSheet)
      let messageAction = UIAlertAction(title: "Message", style: .Default) { _ in
        self.retrieveConversation { messages, conversation in
          if let messages = messages, conversation = conversation {
            let dictionaryToPass: [String: AnyObject] = ["0": messages, "1": conversation]
            dispatch_async(dispatch_get_main_queue()) {
              self.performSegueWithIdentifier(self.segueIdentifierThisToMessages, sender: dictionaryToPass)
            }
          }
        }
      }
      let blockAction = UIAlertAction(title: "Block", style: .Default) { _ in
        self.presentBlockConfirmationAlertView()
      }
      let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { _ in
      }
      actionSheet.addAction(messageAction)
      actionSheet.addAction(blockAction)
      actionSheet.addAction(cancelAction)
      if let navigationController = navigationController where UIDevice.currentDevice().userInterfaceIdiom == .Pad {
        actionSheet.modalPresentationStyle = .Popover
        let popPresenter = actionSheet.popoverPresentationController
        popPresenter?.sourceView = navigationController.navigationBar
        popPresenter?.sourceRect = navigationController.navigationBar.frame
      }
      presentViewController(actionSheet, animated: true, completion: nil)
    } else {
      let actionSheet = UIActionSheet(title: "More", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Message", "Block")
      actionSheet.cancelButtonIndex = 2
      actionSheet.tag = menuActionSheetTag
      if let navigationController = navigationController where UIDevice.currentDevice().userInterfaceIdiom == .Pad {
        actionSheet.showFromRect(navigationController.navigationBar.frame, inView: view, animated: true)
      } else {
        actionSheet.showInView(view)
      }
    }
  }
  
  /// Presents an AlertController with style `.ActionSheet` that prompts the user with various possible additional actions.
  ///
  /// :param: index The index of the post that triggered this action sheet.
  func presentMenuActionSheetForIndex(index: Int, iPadReference: UIButton?) {
    if objc_getClass("UIAlertController") != nil {
      let actionSheet = UIAlertController(title: "More", message: nil, preferredStyle: .ActionSheet)
      let flagAction = UIAlertAction(title: "Flag", style: .Default) { _ in
        self.flagPostAtIndex(index) { success in
          if success {
            UIAlertView(title: "Post flagged", message: "Thanks for helping make Cillo a better place!", delegate: nil, cancelButtonTitle: "Ok").show()
          }
        }
      }
      let blockAction = UIAlertAction(title: "Block User", style: .Default) { _ in
        self.presentBlockConfirmationAlertView()
      }
      let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { _ in
      }
      actionSheet.addAction(flagAction)
      actionSheet.addAction(blockAction)
      actionSheet.addAction(cancelAction)
      if let iPadReference = iPadReference where UIDevice.currentDevice().userInterfaceIdiom == .Pad {
        actionSheet.modalPresentationStyle = .Popover
        let popPresenter = actionSheet.popoverPresentationController
        popPresenter?.sourceView = iPadReference
        popPresenter?.sourceRect = iPadReference.bounds
      }
      presentViewController(actionSheet, animated: true, completion: nil)
    } else {
      let actionSheet = UIActionSheet(title: "More", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Flag", "Block User")
      actionSheet.cancelButtonIndex = 2
      actionSheet.tag = index
      if let iPadReference = iPadReference where UIDevice.currentDevice().userInterfaceIdiom == .Pad {
        actionSheet.showFromRect(iPadReference.bounds, inView: view, animated: true)
      } else {
        actionSheet.showInView(view)
      }
    }
  }
  
  // MARK: Networking Helper Functions
  
  /// Used to block the user.
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: success True if the call was successful.
  func blockUser(completionHandler: (success: Bool) -> ()) {
    DataManager.sharedInstance.blockUser(user) { error, success in
      if let error = error {
        self.handleError(error)
        completionHandler(success: false)
      } else {
        completionHandler(success: success)
      }
    }
  }
  
  /// Sends flag post request to Cillo Servers for the post at the specified index.
  ///
  /// :param: index The index of the post being upvoted in `posts`.
  /// :param: completionHandler The completion block for the upvote.
  /// :param: success True if flag request was successful. If error was received, false.
  func flagPostAtIndex(index: Int, completionHandler: (success: Bool) -> ()) {
    DataManager.sharedInstance.flagPost(posts[index]) { error, success in
      if let error = error {
        self.handleError(error)
        completionHandler(success: false)
      } else {
        completionHandler(success: success)
      }
    }
  }
  
  /// Used to retrieve the comments made by user from Cillo servers.
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: comments The comments made by user.
  /// :param: * Nil if there was an error in the server call.
  func retrieveComments(completionHandler: (comments: [Comment]?) -> ()) {
    DataManager.sharedInstance.getUserCommentsByID(user.userID, lastCommentID: comments.last?.commentID) { error, result in
      if let error = error {
        self.handleError(error)
        completionHandler(comments: nil)
      } else {
        completionHandler(comments: result)
      }
    }
  }
  
  func retrieveConversation(completionHandler: (messages: [Message]?, conversation: Conversation?) -> ()) {
    DataManager.sharedInstance.getEndUserMessagesWithUser(user) { error, hasConversation, messages in
      if let error = error {
        self.handleError(error)
        completionHandler(messages: nil, conversation: nil)
      } else if !hasConversation {
        let conversation = Conversation()
        conversation.otherUser = self.user
        completionHandler(messages: [], conversation: conversation)
      } else if let messages = messages {
        let conversation = Conversation()
        conversation.conversationID = messages[0].conversationID
        conversation.otherUser = self.user
        completionHandler(messages: messages, conversation: conversation)
      }
    }
  }
  
  /// Used to retrieve all necessary data to display UITableViewCells in this UIViewController.
  ///
  /// Assigns posts and comments properties of SingleUserTableViewController correct values from server calls.
  override func retrieveData() {
    retrievingPage = true
    postsFinishedPaging = false
    posts = []
    postsPageNumber = 1
    retrievePosts { posts in
      if let posts = posts {
        dispatch_async(dispatch_get_main_queue()) {
          if posts.isEmpty {
            self.postsFinishedPaging = true
          }
          self.posts = posts
          self.postsPageNumber++
          self.commentsFinishedPaging = false
          self.comments = []
          self.commentsPageNumber = 1
        }
        self.retrieveComments { comments in
          dispatch_async(dispatch_get_main_queue()) {
            self.dataRetrieved = true
            if let comments = comments {
              if comments.isEmpty {
                self.commentsFinishedPaging = true
              }
              self.comments = comments
              self.commentsPageNumber++
            }
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            self.retrievingPage = false
          }
        }
      } else {
        dispatch_async(dispatch_get_main_queue()) {
          self.dataRetrieved = true
          self.refreshControl?.endRefreshing()
          self.retrievingPage = false
        }
      }
    }
  }
  
  /// Used to retrieve the posts made by user from Cillo servers.
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: posts The posts made by user.
  /// :param: * Nil if there was an error in the server call.
  func retrievePosts(completionHandler: (posts: [Post]?) -> ()) {
    DataManager.sharedInstance.getUserPostsByID(user.userID, lastPostID: posts.last?.postID) { error, result in
      if let error = error {
        self.handleError(error)
        completionHandler(posts: nil)
      } else {
        completionHandler(posts: result)
      }
    }
  }
  
  // MARK: IBActions
  
  /// Presents action sheet to block message user.
  ///
  /// :param: sender The button that is touched to send this function is the right bar button.
  @IBAction func menuPressed(sender: UIBarButtonItem) {
    presentMenuActionSheet()
  }
  
  /// Triggers an action sheet with a more actions menu.
  ///
  /// **Note:** The position of the Post to show menu for is known via the tag of the button.
  ///
  /// :param: sender The button that is touched to send this function is a moreButton in a PostCell.
  @IBAction func morePressed(sender: UIButton) {
    presentMenuActionSheetForIndex(sender.tag, iPadReference: sender)
  }
}

// MARK: - UIActionSheetDelegate

extension UserTableViewController: UIActionSheetDelegate {
  
  func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
    if actionSheet.tag ==  menuActionSheetTag {
      switch buttonIndex {
      case 0:
        retrieveConversation { messages, conversation in
          if let messages = messages, conversation = conversation {
            let dictionaryToPass: [String: AnyObject] = ["0": messages, "1": conversation]
            dispatch_async(dispatch_get_main_queue()) {
              self.performSegueWithIdentifier(self.segueIdentifierThisToMessages, sender: dictionaryToPass)
            }
          }
        }
      case 1:
        presentBlockConfirmationAlertView()
      default:
        break
      }
    } else {
      switch buttonIndex {
      case 0:
        self.flagPostAtIndex(actionSheet.tag) { success in
          if success {
            UIAlertView(title: "Post flagged", message: "Thanks for helping make Cillo a better place!", delegate: nil, cancelButtonTitle: "Ok").show()
          }
        }
      case 1:
        presentBlockConfirmationAlertView()
      default:
        break
      }
    }
  }
}

// MARK: - UIAlertViewDelegate

extension UserTableViewController: UIAlertViewDelegate {
  
  func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
    if buttonIndex == 1 {
      blockUser { success in
        if success {
          dispatch_async(dispatch_get_main_queue()) {
            self.navigationController?.popToRootViewControllerAnimated(true)
            if let topVC = self.navigationController?.topViewController as? CustomTableViewController {
              topVC.retrieveData()
            }
          }
        }
      }
    }
  }
}
