//
//  Conversation.swift
//  Cillo
//
//  Created by Andrew Daley on 6/23/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Defines all properties of a Conversation on Cillo
class Conversation: IdentifiableObject {
    
    // MARK: - Properties
    
    /// Time that this conversation was created.
    ///
    /// String is properly formatted via `compactTimeDisplay` property of UInt64.
    var creationTime = ""
    
    /// ID of last user to say something in this conversation
    var lastUser = 0
    
    /// The other User in this Conversation.
    var otherUser = User()
    
    /// Text preview of the conversation's message content.
    var preview = ""
    
    /// Boolean flag to tell if the end user has read this conversation yet.
    var read = false
    
    /// Time that this conversation was last updated.
    ///
    /// String is properly formatted via `compactTimeDisplay` property of UInt64.
    var updateTime = ""
    
    // MARK: Initializers
    
    /// Creates Conversation based on a swiftyJSON retrieved from a call to the Cillo servers.
    ///
    /// Should contain key value pairs for:
    /// * "conversation_id" - Int
    /// * "user" - Dictionary
    /// * "create_time" - UInt64
    /// * "update_time" - UInt64
    /// * "read" - Bool
    /// * "last_user" - Int
    /// * "preview" - String
    ///
    /// :param: json The swiftyJSON retrieved from a call to the Cillo servers.
    init(json: JSON) {
        id = json["conversation_id"].intValue
        otherUser = User(json: json["user"])
        let creationTime = json["create_time"].int64Value
        self.creationTime = creationTime.compactTimeDisplay
        let updateTime = json["update_time"].int64Value
        self.updateTime = updateTime.compactTimeDisplay
        read = json["read"].boolValue
        lastUser = json["last_user"].intValue
        preview = json["preview"].stringValue
    }
    
    /// Creates empty Conversation.
    override init() {
        super.init()
    }
}
