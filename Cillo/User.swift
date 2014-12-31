//
//  User.swift
//  Cillo
//
//  Created by Andrew Daley on 11/6/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

/// Defines all properties of a User on Cillo
class User: NSObject {
  
  // MARK: - Properties
  
  /// ID of this User.
  let userID: Int = 0
  
  /// Username for this User.
  /// Unique to this User.
  /// 
  /// Example: @AccountName
  let username: String = ""
  
  /// Display name for this User.
  var name: String = ""
  
  /// Profile picture of this User.
  var profilePic: UIImage = UIImage(named: "Me")!
  
  /// User biography.
  var bio: String = ""
  
  /// Total accumulated reputation of this User.
  var rep: Int = 0
  
  // MARK: - Initializers
  
  /// Creates User based on a swiftyJSON retrieved from a call to the Cillo servers. 
  ///
  /// Should contain key value pairs for:
  /// * "name" - String
  /// * "username" - String
  /// * "user_id" - Int
  /// * "reputation" - Int
  /// * "photo" - String
  /// * "bio" - String
  init(json: JSON) {
    name = json["name"].stringValue
    username = json["username"].stringValue
    userID = json["user_id"].intValue
    rep = json["reputation"].intValue
    if let imageData = NSData(contentsOfURL: NSURL(fileURLWithPath: json["photo"].stringValue)!) {
      if let image = UIImage(data: imageData) {
        profilePic = image
      } else {
        profilePic = UIImage(named: "Me")!
      }
    }
    bio = json["bio"].stringValue
  }
  
  // Creates a default User
  override init() {
    super.init()
  }
  
  // MARK: - Helper Functions
  
  /// Used to find the height of bioTextView in a UserCell displaying this User.
  ///
  /// :param: width The current width of bioTextView.
  /// :returns: Predicted height of bioTextView in a UserCell.
  func heightOfBioWithWidth(width: CGFloat) -> CGFloat {
    return bio.heightOfTextWithWidth(width, andFont: UserCell.BioTextViewFont)
  }
  
  
}
