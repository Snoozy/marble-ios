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
  
  /// User biography.
  var bio = ""
  
  /// Number of boards that this User follows
  var boardCount = 0
  
  /// True if this user represents an anonymous user.
  var isAnon: Bool {
    return username == ""
  }
  
  /// True if this User is the end user.
  var isSelf = false
  
  /// Display name for this User.
  var name = ""
  
  /// Profile picture of this User.
  var profilePicURL = NSURL()
  
  /// Total accumulated reputation of this User.
  var rep = 0
  
  /// ID of this User.
  var userID = 0
  
  /// Username for this User.
  ///
  /// Unique to this User.
  var username = ""
  
  /// A displayable username for the cell.
  var usernameDisplay: String {
    return username == "" ? "" : "@\(username)"
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
    name = json["name"].stringValue
    username = json["username"].stringValue
    userID = json["user_id"].intValue
    rep = json["reputation"].intValue
    if let url = NSURL(string: json["photo"].stringValue) {
      profilePicURL = url
    }
    bio = json["bio"].stringValue
    boardCount = json["board_count"].intValue
    isSelf = json["self"].boolValue
  }
  
  /// Creates a default User.
  override init() {
    super.init()
  }
  
  // MARK: Setup Helper Functions
  
  /// Used to find the height of bioTextView in a UserCell displaying this User.
  ///
  /// :param: width The current width of bioTextView.
  /// :returns: Predicted height of bioTextView in a UserCell.
  func heightOfBioWithWidth(width: CGFloat) -> CGFloat {
    return bio.heightOfTextWithWidth(width, andFont: UserCell.bioTTTAttributedLabelFont)
  }
}
