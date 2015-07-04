//
//  MessagesViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 7/3/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import SwiftKeychainWrapper

/// Handles chatting on Cillo.
class MessagesViewController: JSQMessagesViewController {

  // MARK: Properties
  
  /// Conversation that this view controller is displaying.
  ///
  /// **Note:** If the conversationID is -1 then there have been no messages sent in this conversation yet.
  var conversation = Conversation()
  
  /// The messages within this conversation that will be displayed in the speech bubbles.
  var messages = [Message]()
  
  /// The timer that checks for new messages every 15 seconds.
  var messageRefresher = NSTimer()
  
  // MARK: UIViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if conversation.conversationID != -1 && messages == [] { // no messages have been passed to this view controller and the conversation is a valid conversation.
      getMessages { messages in
        if let messages = messages {
          if messages.count >= 30 {
            self.showLoadEarlierMessagesHeader = self.conversation.conversationID != -1
          }
          self.messages = messages
          self.collectionView.reloadData()
          self.scrollToBottomAnimated(false)
        }
      }
    }
    senderDisplayName = ""
    senderId = "\(KeychainWrapper.userID() ?? -1)"
    collectionView.collectionViewLayout.incomingAvatarViewSize = .zeroSize
    collectionView.collectionViewLayout.outgoingAvatarViewSize = .zeroSize
    inputToolbar.contentView.leftBarButtonItem = nil
    automaticallyScrollsToMostRecentMessage = true
    navigationItem.title = conversation.otherUser.name
    messageRefresher = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(15), target: self, selector: "loadEarlierMessages:", userInfo: nil, repeats: true)
  }

  // MARK: JSQMessagesViewController

  override func collectionView(collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
    sender.enabled = false
    pageMessages { done, messages in
      sender.enabled = true
      if done {
        self.showLoadEarlierMessagesHeader = false
      } else if let messages = messages {
        self.messages = messages + self.messages
        self.collectionView.reloadData()
      }
    }
  }
  
  override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
    return messages[indexPath.item]
  }
  
  override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
    let message = messages[indexPath.item]
    if message.senderId() == senderId {
      return JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(ColorScheme.defaultScheme.outgoingMessageBubbleColor())
    } else {
      return JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(ColorScheme.defaultScheme.incomingMessageBubbleColor())
    }
  }
  
  override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
    return nil
  }
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return messages.count
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
    
    let message = messages[indexPath.item]
    
    if message.senderId() == senderId {
      cell.textView.textColor = UIColor.whiteColor()
    } else {
      cell.textView.textColor = UIColor.darkTextColor()
    }
    
    
    let attributes : [NSObject:AnyObject] = [NSForegroundColorAttributeName:cell.textView.textColor, NSUnderlineStyleAttributeName: 1]
    cell.textView.linkTextAttributes = attributes
    
    //        cell.textView.linkTextAttributes = [NSForegroundColorAttributeName: cell.textView.textColor,
    //            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle]
    return cell
  }
  
  
  // View  usernames above bubbles
  override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
//    let message = messages[indexPath.item];
//    
//    // Sent by me, skip
//    if message.senderId() == senderId {
//      return nil;
//    }
//    
//    // Same as previous sender, skip
//    if indexPath.item > 0 {
//      let previousMessage = messages[indexPath.item - 1];
//      if previousMessage.senderId() == message.senderId() {
//        return nil;
//      }
//    }
//    
//    return NSAttributedString(string:message.senderDisplayName())
    return nil
  }
  
  override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
//    let message = messages[indexPath.item]
//    
//    // Sent by me, skip
//    if message.senderId() == senderId {
//      return CGFloat(0.0);
//    }
//    
//    // Same as previous sender, skip
//    if indexPath.item > 0 {
//      let previousMessage = messages[indexPath.item - 1];
//      if previousMessage.senderId() == message.senderId() {
//        return CGFloat(0.0);
//      }
//    }
//    
//    return kJSQMessagesCollectionViewCellLabelHeightDefault
    return CGFloat(0.0)
  }
  
  override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
    
    sendMessage(text) { message in
      if let message = message {
        self.messages.append(message)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        if self.conversation.conversationID == -1 {
          self.conversation.conversationID = message.conversationID
        }
      }
    }
  }
  
  // MARK: Timer Selectors
  
  /// Polls the Cillo servers to see if there are any new messages.
  ///
  /// :param: sender The timer that calls this function is `messageRefresher`
  func loadEarlierMessages(sender: NSTimer) {
    if conversation.conversationID != -1 {
      pollMessages { empty, messages in
        if let messages = messages where !empty {
          for message in messages {
            self.messages.append(message)
            self.finishReceivingMessage()
          }
        }
      }
    }
  }
  
  
  // MARK: Networking Helper Functions
  
  /// Attempts to poll the Cillo servers to check for new messages.
  ///
  /// :param: completionHandler The completion block for this network request.
  /// :param: empty A boolean flag to tell if there are new messages. False if there are new messages.
  /// :param: messages The new messages retrieved by the network call.
  func pollMessages(completionHandler: (empty: Bool, messages: [Message]?) -> ()) {
    if messages.count > 0 {
      DataManager.sharedInstance.pollConversationByID(conversation.conversationID, withMostRecentMessageID: messages[messages.count - 1].messageID) { error, empty, messages in
        if let error = error {
          self.handleError(error)
          completionHandler(empty: false, messages: nil)
        } else {
          println(messages)
          completionHandler(empty: empty, messages: messages)
        }
      }
    } else {
      completionHandler(empty: true, messages: nil)
    }
  }
  
  /// Attempts to retrieve old messages from the Cillo servers.
  ///
  /// :param: completionHandler The completion block for this network request.
  /// :param: done A boolean flag to tell if there are no more old messages. True if there are no more messages.
  /// :param: messages The older messages retrieved by the network call.
  func pageMessages(completionHandler: (done: Bool, messages: [Message]?) -> ()) {
    DataManager.sharedInstance.pageConversationByID(conversation.conversationID, withOldestMessageID: messages[0].messageID) { error, done, messages in
      if let error = error {
        self.handleError(error)
        completionHandler(done: false, messages: nil)
      } else {
        completionHandler(done: done, messages: messages)
      }
    }
  }
  
  /// Attempts to send a new message to the Cillo servers.
  ///
  /// :param: completionHandler The completion block for this network request
  /// :param: message The new message created by the network call.
  func sendMessage(message: String, completionHandler: (message: Message?) -> ()) {
    DataManager.sharedInstance.sendMessage(message, toUserWithID: conversation.otherUser.userID) { error, message in
      if let error = error {
        self.handleError(error)
        completionHandler(message: nil)
      } else {
        completionHandler(message: message)
      }
    }
  }
  
  /// Attempts to retrieve the most recent 30 messages from the Cillo servers.
  ///
  /// :param: completionHandler The completion block for this network request
  /// :param: messages The messages retrieved by the network call.
  func getMessages(completionHandler: (messages: [Message]?) -> ()) {
    DataManager.sharedInstance.getMessagesByConversationID(conversation.conversationID) { error, messages in
      if let error = error {
        self.handleError(error)
        completionHandler(messages: nil)
      } else {
        completionHandler(messages: messages)
      }
    }
  }
  
  /// Handles an error received from a network call within the app.
  ///
  /// :param: error The error to be handled
  func handleError(error: NSError) {
    println(error)
    if error.domain == NSError.cilloErrorDomain {
      switch error.code {
      case NSError.CilloErrorCodes.userUnauthenticated:
        handleUserUnauthenticatedError(error)
      default:
        error.showAlert()
      }
    }
  }
  
  // MARK: Error Handling Helper Functions
  
  /// Handles a cillo error with code `NSError.CilloErrorCodes.userUnauthenticated`.
  ///
  /// **Note:** Default implementation presents a LoginVC.
  ///
  /// :param: error The error to be handled.
  func handleUserUnauthenticatedError(error: NSError) {
    if let tabBarController = tabBarController as? TabViewController {
      tabBarController.performSegueWithIdentifier(SegueIdentifiers.tabToLogin, sender: error)
    }
  }
  
  // MARK: IBActions
  
  /// Triggers segue to NewPostViewController when button is pressed on navigationBar.
  @IBAction func triggerNewPostSegueOnButton(sender: UIBarButtonItem) {
    if let tabBarController = tabBarController as? TabViewController {
      tabBarController.performSegueWithIdentifier(SegueIdentifiers.tabToNewPost, sender: sender)
    }
  }
}
