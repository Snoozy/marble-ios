//
//  Message.swift
//  Cillo
//
//  Created by Andrew Daley on 6/23/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Defines all properties of a Message on Cillo
class Message: NSObject {
  
  // MARK: Properties
  
  /// ID of this Message.
  var messageID = 0
  
  /// ID of Conversation that this message belongs to.
  var conversationID = 0
  
  /// ID of the User that sent this message.
  var senderID = 0
  
  /// Text of this message.
  var content = ""
  
  /// Time that this message was sent.
  ///
  /// String is properly formatted via `compactTimeDisplay` property of UInt64.
  var time = NSDate()
  
  // MARK: Initializers
  
  /// Creates Message based on a swiftyJSON retrieved from a call to the Cillo servers.
  ///
  /// Should contain key value pairs for:
  /// * "message_id" - Int
  /// * "conversation_id" - Int
  /// * "user_id" - Int
  /// * "content" - String
  /// * "time" - UInt64
  ///
  /// :param: json The swiftyJSON retrieved from a call to the Cillo servers.
  init(json: JSON) {
    messageID = json["message_id"].intValue
    conversationID = json["conversation_id"].intValue
    senderID = json["user_id"].intValue
    content = json["content"].stringValue
    let time = json["time"].int64Value
    self.time = NSDate(timeIntervalSince1970: NSTimeInterval(time))
  }
  
  /// Creates empty Message.
  override init() {
    super.init()
  }
}

extension Message: JSQMessageData {
  
  func senderId() -> String! {
    return "\(senderID)"
  }
  
  func senderDisplayName() -> String! {
    return ""
  }
  
  func date() -> NSDate! {
    return time
  }
  
  func isMediaMessage() -> Bool {
    return false
  }
  
  func messageHash() -> UInt {
    return UInt(messageID)
  }
  
  func text() -> String! {
    return content
  }
}
