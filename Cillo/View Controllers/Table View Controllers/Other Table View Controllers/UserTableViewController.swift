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
  
  override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
    super.prepare(for: segue, sender: sender)
    if segue.identifier == segueIdentifierThisToMessages {
      let destination = segue.destination as! MessagesViewController
      if let sender = sender as? [String: AnyObject] {
        if let messages = sender["0"] as? [Message], conversation = sender["1"] as? Conversation {
          destination.messages = messages
          destination.conversation = conversation
        }
      }
    }
  }
  
  // MARK: UITableViewDelegate
  
  override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    switch cellsShown {
    case .posts:
      if !postsFinishedPaging && !retrievingPage && (indexPath as NSIndexPath).row > posts.count - 25 {
        retrievingPage = true
        retrievePosts { posts in
          if let posts = posts {
            if posts.isEmpty {
              self.postsFinishedPaging = true
            } else {
              var row = self.posts.count
              var newPaths = [IndexPath]()
              for post in posts {
                self.posts.append(post)
                newPaths.append(IndexPath(row: row, section: 1))
                row += 1
              }
              DispatchQueue.main.async {
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: newPaths, with: .middle)
                self.tableView.endUpdates()
                self.postsPageNumber += 1
              }
            }
          }
          self.retrievingPage = false
        }
      }
    case .comments:
      if !commentsFinishedPaging && !retrievingPage && (indexPath as NSIndexPath).row > comments.count - 25 {
        retrievingPage = true
        retrieveComments { comments in
          if let comments = comments {
            if comments.isEmpty {
              self.commentsFinishedPaging = true
            } else {
              var row = self.comments.count
              var newPaths = [IndexPath]()
              for comment in comments {
                self.comments.append(comment)
                newPaths.append(IndexPath(row: row, section: 1))
                row += 1
              }
              DispatchQueue.main.async {
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: newPaths, with: .middle)
                self.tableView.endUpdates()
                self.commentsPageNumber += 1
              }
            }
          }
          self.retrievingPage = false
        }
      }
    }
  }
  
  // MARK: Setup Helper Functions
  
  /// Presents an AlertController with style `.AlertView` that asks the user for confirmation of logging out.
  func presentBlockConfirmationAlertView() {
    if objc_getClass("UIAlertController") != nil {
      let alert = UIAlertController(title: "Block Confirmation", message: "Are you sure you want to block \(user.name)?", preferredStyle: .alert)
      let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
        self.blockUser { success in
          if success {
            DispatchQueue.main.async {
              UIAlertView(title: "\(self.user.name) Blocked", message: nil, delegate: nil, cancelButtonTitle: "Ok").show()
              self.navigationController?.popToRootViewController(animated: true)
              if let topVC = self.navigationController?.topViewController as? CustomTableViewController {
                topVC.retrieveData()
              }
            }
          }
        }
      }
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
      }
      alert.addAction(yesAction)
      alert.addAction(cancelAction)
      present(alert, animated: true, completion: nil)
    } else {
      let alert = UIAlertView(title: "Block Confirmation", message: "Are you sure you want to block \(user.name)?", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "Yes", "Cancel")
      alert.show()
    }
  }
  
  /// Presents an AlertController with style `.ActionSheet` that prompts the user with various possible additional actions.
  func presentMenuActionSheet() {
    if objc_getClass("UIAlertController") != nil {
      let actionSheet = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
      let messageAction = UIAlertAction(title: "Message", style: .default) { _ in
        self.retrieveConversation { messages, conversation in
          if let messages = messages, conversation = conversation {
            let dictionaryToPass: [String: AnyObject] = ["0": messages, "1": conversation]
            DispatchQueue.main.async {
              self.performSegue(withIdentifier: self.segueIdentifierThisToMessages, sender: dictionaryToPass)
            }
          }
        }
      }
      let blockAction = UIAlertAction(title: "Block", style: .default) { _ in
        self.presentBlockConfirmationAlertView()
      }
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
      }
      actionSheet.addAction(messageAction)
      actionSheet.addAction(blockAction)
      actionSheet.addAction(cancelAction)
      if let navigationController = navigationController where UIDevice.current.userInterfaceIdiom == .pad {
        actionSheet.modalPresentationStyle = .popover
        let popPresenter = actionSheet.popoverPresentationController
        popPresenter?.sourceView = navigationController.navigationBar
        popPresenter?.sourceRect = navigationController.navigationBar.frame
      }
      present(actionSheet, animated: true, completion: nil)
    } else {
      let actionSheet = UIActionSheet(title: "More", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Message", "Block")
      actionSheet.cancelButtonIndex = 2
      actionSheet.tag = menuActionSheetTag
      if let navigationController = navigationController where UIDevice.current.userInterfaceIdiom == .pad {
        actionSheet.show(from: navigationController.navigationBar.frame, in: view, animated: true)
      } else {
        actionSheet.show(in: view)
      }
    }
  }
  
  /// Presents an AlertController with style `.ActionSheet` that prompts the user with various possible additional actions.
  ///
  /// :param: index The index of the post that triggered this action sheet.
  func presentMenuActionSheetForIndex(_ index: Int, iPadReference: UIButton?) {
    if objc_getClass("UIAlertController") != nil {
      let actionSheet = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
      let flagAction = UIAlertAction(title: "Flag", style: .default) { _ in
        self.flagPostAtIndex(index) { success in
          if success {
            UIAlertView(title: "Post flagged", message: "Thanks for helping make Cillo a better place!", delegate: nil, cancelButtonTitle: "Ok").show()
          }
        }
      }
      let blockAction = UIAlertAction(title: "Block User", style: .default) { _ in
        self.presentBlockConfirmationAlertView()
      }
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
      }
      actionSheet.addAction(flagAction)
      actionSheet.addAction(blockAction)
      actionSheet.addAction(cancelAction)
      if let iPadReference = iPadReference where UIDevice.current.userInterfaceIdiom == .pad {
        actionSheet.modalPresentationStyle = .popover
        let popPresenter = actionSheet.popoverPresentationController
        popPresenter?.sourceView = iPadReference
        popPresenter?.sourceRect = iPadReference.bounds
      }
      present(actionSheet, animated: true, completion: nil)
    } else {
      let actionSheet = UIActionSheet(title: "More", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Flag", "Block User")
      actionSheet.cancelButtonIndex = 2
      actionSheet.tag = index
      if let iPadReference = iPadReference where UIDevice.current.userInterfaceIdiom == .pad {
        actionSheet.show(from: iPadReference.bounds, in: view, animated: true)
      } else {
        actionSheet.show(in: view)
      }
    }
  }
  
  // MARK: Networking Helper Functions
  
  /// Used to block the user.
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: success True if the call was successful.
  func blockUser(_ completionHandler: (success: Bool) -> ()) {
    DataManager.sharedInstance.blockUser(user) { result in
      self.handleSuccessResponse(result, completionHandler: completionHandler)
    }
  }
  
  /// Sends flag post request to Cillo Servers for the post at the specified index.
  ///
  /// :param: index The index of the post being upvoted in `posts`.
  /// :param: completionHandler The completion block for the upvote.
  /// :param: success True if flag request was successful. If error was received, false.
  func flagPostAtIndex(_ index: Int, completionHandler: (success: Bool) -> ()) {
    DataManager.sharedInstance.flagPost(posts[index]) { result in
      self.handleSuccessResponse(result, completionHandler: completionHandler)
    }
  }
  
  /// Used to retrieve the comments made by user from Cillo servers.
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: comments The comments made by user.
  /// :param: * Nil if there was an error in the server call.
  func retrieveComments(_ completionHandler: (comments: [Comment]?) -> ()) {
    DataManager.sharedInstance.getUserCommentsByID(user.userID, lastCommentID: comments.last?.commentID) { result in
      self.handleSingleElementResponse(result, completionHandler: completionHandler)
    }
  }
  
  func retrieveConversation(_ completionHandler: (messages: [Message]?, conversation: Conversation?) -> ()) {
    DataManager.sharedInstance.getEndUserMessagesWithUser(user) { result in
      switch result {
      case .error(let error):
        self.handleError(error)
        completionHandler(messages: nil, conversation: nil)
      case .value(let element):
        let messages = element.unbox
        let conversation = Conversation()
        conversation.otherUser = self.user
        if !messages.isEmpty {
          conversation.conversationID = messages[0].conversationID
        }
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
        DispatchQueue.main.async {
          if posts.isEmpty {
            self.postsFinishedPaging = true
          }
          self.posts = posts
          self.postsPageNumber += 1
          self.commentsFinishedPaging = false
          self.comments = []
          self.commentsPageNumber = 1
        }
        self.retrieveComments { comments in
          DispatchQueue.main.async {
            self.dataRetrieved = true
            if let comments = comments {
              if comments.isEmpty {
                self.commentsFinishedPaging = true
              }
              self.comments = comments
              self.commentsPageNumber += 1
            }
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            self.retrievingPage = false
          }
        }
      } else {
        DispatchQueue.main.async {
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
  func retrievePosts(_ completionHandler: (posts: [Post]?) -> ()) {
    DataManager.sharedInstance.getUserPostsByID(user.userID, lastPostID: posts.last?.postID) { result in
      self.handleSingleElementResponse(result, completionHandler: completionHandler)
    }
  }
  
  // MARK: IBActions
  
  /// Presents action sheet to block message user.
  ///
  /// :param: sender The button that is touched to send this function is the right bar button.
  @IBAction func menuPressed(_ sender: UIBarButtonItem) {
    presentMenuActionSheet()
  }
  
  /// Triggers an action sheet with a more actions menu.
  ///
  /// **Note:** The position of the Post to show menu for is known via the tag of the button.
  ///
  /// :param: sender The button that is touched to send this function is a moreButton in a PostCell.
  @IBAction func morePressed(_ sender: UIButton) {
    presentMenuActionSheetForIndex(sender.tag, iPadReference: sender)
  }
}

// MARK: - UIActionSheetDelegate

extension UserTableViewController: UIActionSheetDelegate {
  
  func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
    if actionSheet.tag ==  menuActionSheetTag {
      switch buttonIndex {
      case 0:
        retrieveConversation { messages, conversation in
          if let messages = messages, conversation = conversation {
            let dictionaryToPass: [String: AnyObject] = ["0": messages, "1": conversation]
            DispatchQueue.main.async {
              self.performSegue(withIdentifier: self.segueIdentifierThisToMessages, sender: dictionaryToPass)
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
  
  func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
    if buttonIndex == 1 {
      blockUser { success in
        if success {
          DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: true)
            if let topVC = self.navigationController?.topViewController as? CustomTableViewController {
              topVC.retrieveData()
            }
          }
        }
      }
    }
  }
}
