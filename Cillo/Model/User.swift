//
//  User.swift
//  Cillo
//
//  Created by Andrew Daley on 11/6/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

/// Defines all properties of a User on Cillo.
class User: NSObject {
  
  // MARK: Properties
  
  /// ID of this User.
  var userID: Int = 0
  
  /// Username for this User.
  ///
  /// Unique to this User.
  /// 
  /// Example: @AccountName
  var username: String = ""
  
  /// Display name for this User.
  var name: String = ""
  
  /// Profile picture of this User.
  var profilePicURL: NSURL = NSURL()
  
  /// User biography.
  var bio: String = ""
  
  /// Total accumulated reputation of this User.
  var rep: Int = 0
  
  /// Number of groups that this User follows
  var numGroups: Int = 0
  
  // TODO: Document
  var isSelf: Bool = false
  
  var isAnon: Bool {
    return username == ""
  }
  
  /// Used to print properties in println statements.
  override var description: String {
    return "User {\n   User ID: \(userID)\n   Username: \(username)\n   Display Name: \(name)\n   Bio: \(bio)\n   Reputation: \(rep)\n   Number of Groups: \(numGroups)\n }\n"
  }
  
  // MARK: Initializers
  
  /// Creates User based on a swiftyJSON retrieved from a call to the Cillo servers. 
  ///
  /// Should contain key value pairs for:
  /// * "name" - String
  /// * "username" - String
  /// * "user_id" - Int
  /// * "reputation" - Int
  /// * "photo" - String
  /// * "bio" - String
  /// * "board_count" - Int
  ///
  /// :param: json The swiftyJSON retrieved from a call to the Cillo servers.
  init(json: JSON) {
    println(json)
    name = json["name"].stringValue
    username = json["username"].stringValue
    userID = json["user_id"].intValue
    rep = json["reputation"].intValue
    if let url = NSURL(string: json["photo"].stringValue) {
      profilePicURL = url
    }
    bio = json["bio"].stringValue
    numGroups = json["board_count"].intValue
    isSelf = json["self"].boolValue
  }
  
  /// Creates a default User.
  override init() {
    super.init()
  }
  
  // MARK: Helper Functions
  
  /// Used to find the height of bioTextView in a UserCell displaying this User.
  ///
  /// :param: width The current width of bioTextView.
  /// :returns: Predicted height of bioTextView in a UserCell.
  func heightOfBioWithWidth(width: CGFloat) -> CGFloat {
    return bio.heightOfTextWithWidth(width, andFont: UserCell.BioTextViewFont)
  }
  
  
}
