//
//  UserTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 1/5/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

/// Handles view of User with Posts or Comments beneath it for any User that is not the end user.
///
/// Formats TableView to look appealing and be functional.
///
/// **Note:** Must assign user property of superclass a relevant value before displaying this SingleUserTableViewController.
class UserTableViewController: SingleUserTableViewController {

  // MARK: Constants
  
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
      if !retrievingPage && indexPath.row > (postsPageNumber - 2) * 20 + 10 {
        retrievingPage = true
        retrievePosts { posts in
          if let posts = posts {
            for post in posts {
              self.posts.append(post)
            }
            self.postsPageNumber++
            self.tableView.reloadData()
          }
          self.retrievingPage = false
        }
      }
    case .Comments:
      if !retrievingPage && indexPath.row > (commentsPageNumber - 2) * 20 + 10 {
        retrievingPage = true
        retrieveComments { comments in
          if let comments = comments {
            for comment in comments {
              self.comments.append(comment)
            }
            self.commentsPageNumber++
            self.tableView.reloadData()
          }
          self.retrievingPage = false
        }
      }
    }
  }
  
  // MARK: Networking Helper Functions
  
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
    posts = []
    postsPageNumber = 1
    retrievePosts { posts in
      if let posts = posts {
        self.posts = posts
        self.postsPageNumber++
        self.comments = []
        self.commentsPageNumber = 1
        self.retrieveComments { comments in
          self.dataRetrieved = true
          if let comments = comments {
            self.comments = comments
            self.commentsPageNumber++
          }
          self.tableView.reloadData()
          self.refreshControl?.endRefreshing()
          self.retrievingPage = false
        }
      } else {
        self.dataRetrieved = true
        self.refreshControl?.endRefreshing()
        self.retrievingPage = false
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
  
  /// Triggers segue to MessagesViewController.
  ///
  /// :param: sender The button that is touched to send this function is a messageButton in a UserCell.
  @IBAction func messagePressed(sender: UIButton) {
    retrieveConversation { messages, conversation in
      if let messages = messages, conversation = conversation {
        let dictionaryToPass: [String: AnyObject] = ["0": messages, "1": conversation]
        self.performSegueWithIdentifier(self.segueIdentifierThisToMessages, sender: dictionaryToPass)
      }
    }
  }
}
