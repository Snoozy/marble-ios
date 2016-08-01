//
//  MessagesViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 7/3/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

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
  var messageRefresher = Timer()
  
  // MARK: UIViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if conversation.conversationID != -1 && messages.isEmpty { // no messages have been passed to this view controller and the conversation is a valid conversation.
      getMessages { messages in
        if let messages = messages {
          if messages.count >= 30 {
            self.showLoadEarlierMessagesHeader = self.conversation.conversationID != -1
          }
          self.messages = messages
          self.collectionView.reloadData()
          self.scrollToBottom(animated: false)
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
    messageRefresher = Timer.scheduledTimer(timeInterval: TimeInterval(15), target: self, selector: #selector(MessagesViewController.loadEarlierMessages(_:)), userInfo: nil, repeats: true)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    messageRefresher.invalidate()
  }

  // MARK: JSQMessagesViewController

  override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
    sender.isEnabled = false
    pageMessages { done, messages in
      sender.isEnabled = true
      if done {
        self.showLoadEarlierMessagesHeader = false
      } else if let messages = messages {
        self.messages = messages + self.messages
        self.collectionView.reloadData()
      }
    }
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
    return messages[indexPath.item]
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
    let message = messages[indexPath.item]
    if message.senderId() == senderId {
      return JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: Color Scheme.defaultScheme.outgoingMessageBubbleColor())
    } else {
      return JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: Color Scheme.defaultScheme.incomingMessageBubbleColor())
    }
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
    return nil
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return messages.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
    
    let message = messages[(indexPath as NSIndexPath).item]
    
    if message.senderId() == senderId {
      cell.textView.textColor = UIColor.white
    } else {
      cell.textView.textColor = UIColor.darkText
    }
    
    
    let attributes : [NSObject:AnyObject] = [NSForegroundColorAttributeName:cell.textView.textColor!, NSUnderlineStyleAttributeName: 1]
    cell.textView.linkTextAttributes = attributes
    
    //        cell.textView.linkTextAttributes = [NSForegroundColorAttributeName: cell.textView.textColor,
    //            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle]
    return cell
  }
  
  
  // View  usernames above bubbles
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> AttributedString! {
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
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
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
  
  override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
    
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
  func loadEarlierMessages(_ sender: Timer) {
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
  func pollMessages(_ completionHandler: (empty: Bool, messages: [Message]?) -> ()) {
    if messages.count > 0 {
      DataManager.sharedInstance.pollConversationByID(conversation.conversationID, withMostRecentMessageID: messages[messages.count - 1].messageID) { result in
        switch result {
        case .error(let error):
          self.handleError(error)
          completionHandler(empty: false, messages: nil)
        case .value(let element):
          let (empty,newMessages) = element.unbox
          completionHandler(empty: empty, messages: newMessages)
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
  func pageMessages(_ completionHandler: (done: Bool, messages: [Message]?) -> ()) {
    DataManager.sharedInstance.pageConversationByID(conversation.conversationID, withOldestMessageID: messages[0].messageID) { result in
      switch result {
      case .error(let error):
        self.handleError(error)
        completionHandler(done: false, messages: nil)
      case .value(let element):
        let (done,olderMessages) = element.unbox
        completionHandler(done: done, messages: olderMessages)
      }
    }
  }
  
  /// Attempts to send a new message to the Cillo servers.
  ///
  /// :param: completionHandler The completion block for this network request
  /// :param: message The new message created by the network call.
  func sendMessage(_ message: String, completionHandler: (message: Message?) -> ()) {
    DataManager.sharedInstance.sendMessage(message, toUserWithID: conversation.otherUser.userID) { result in
      switch result {
      case .error(let error):
        self.handleError(error)
        completionHandler(message: nil)
      case .value(let message):
        completionHandler(message: message.unbox)
      }
    }
  }
  
  /// Attempts to retrieve the most recent 30 messages from the Cillo servers.
  ///
  /// :param: completionHandler The completion block for this network request
  /// :param: messages The messages retrieved by the network call.
  func getMessages(_ completionHandler: (messages: [Message]?) -> ()) {
    DataManager.sharedInstance.getMessagesByConversationID(conversation.conversationID) { result in
      switch result {
      case .error(let error):
        self.handleError(error)
        completionHandler(messages: nil)
      case .value(let messages):
        completionHandler(messages: messages.unbox)
      }
    }
  }
  
  /// Handles an error received from a network call within the app.
  ///
  /// :param: error The error to be handled
  func handleError(_ error: NSError) {
    println(error)
    switch error.cilloErrorCode() {
    case .userUnauthenticated:
      handleUserUnauthenticatedError(error)
    case .notCilloDomain:
      break
    default:
      error.showAlert()
    }
  }
  
  // MARK: Error Handling Helper Functions
  
  /// Handles a cillo error with code `NSError.CilloErrorCodes.userUnauthenticated`.
  ///
  /// **Note:** Default implementation presents a LoginVC.
  ///
  /// :param: error The error to be handled.
  func handleUserUnauthenticatedError(_ error: NSError) {
    if let tabBarController = tabBarController as? TabViewController {
      tabBarController.performSegue(withIdentifier: SegueIdentifiers.tabToLogin, sender: error)
    }
  }
  
  // MARK: IBActions
  
  /// Triggers segue to NewPostViewController when button is pressed on navigationBar.
  @IBAction func triggerNewPostSegueOnButton(_ sender: UIBarButtonItem) {
    if let tabBarController = tabBarController as? TabViewController {
      tabBarController.performSegue(withIdentifier: SegueIdentifiers.tabToNewPost, sender: sender)
    }
  }
}
