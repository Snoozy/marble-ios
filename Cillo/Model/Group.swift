//
//  Group.swift
//  Cillo
//
//  Created by Andrew Daley on 11/25/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

/// Defines all properties of a Group on Cillo.
class Group: NSObject {
  
  // MARK: Properties
  
  /// ID of this Group.
  let groupID: Int = 0
  
  /// ID of User that created this Group.
  let creatorID: Int = 0
  
  /// Picture of this Group.
  var picture: UIImage = UIImage(named: "Groups")!
  
  /// Name of this Group.
  ///
  /// Example: #Group
  var name: String = "#"
  
  /// Description of this Group's function.
  var descrip: String = ""
  
  /// Number of followers following this Group
  var numFollowers: Int = 0
  
  /// Indicates whether the logged in User is following this Group
  ///
  /// * True - Logged in User is following this Group.
  /// * False - Logged in User is not following this Group.
  var following: Bool = false
  
  /// Used to print properties in println statements.
  override var description: String {
    var followingString: String
    if following {
      followingString = "Followed"
    } else {
      followingString = "Not Followed"
    }
    return "Group {\n   Group ID: \(groupID)\n   Creator ID: \(creatorID)\n   Name: \(name)\n   Description: \(descrip)\n   Number of Followers: \(numFollowers)\n   Following Status: \(followingString)\n }\n"
  }
  
  // MARK: Initializers
  
  /// Creates Group based on a swiftyJSON retrieved from a call to the Cillo servers.
  ///
  /// Should contain key value pairs for:
  /// * "name" - String
  /// * "followers" - Int
  /// * "group_id" - Int
  /// * "creator_id" - Int
  /// * "description" - String?
  /// * "following" - Bool
  /// * "photo" - String
  ///
  /// :param: json The swiftyJSON retrieved from a call to the Cillo servers.
  init(json: JSON) {
    name = json["name"].stringValue
    numFollowers = json["followers"].intValue
    groupID = json["group_id"].intValue
    creatorID = json["creator_id"].intValue
    if json["description"].string != nil {
      descrip = json["description"].stringValue
    }
    following = json["following"].boolValue
    if let url = NSURL(string: json["photo"].stringValue) {
      // FIXME: Get rid of this check when default images are added to database
      if url != NSURL(string: "https://static.cillo.co/image/34f4ca41-0d9b-436d-816a-5f30d787fbf2") {
        if let imageData = NSData(contentsOfURL: url) {
          if let image = UIImage(data: imageData) {
            picture = image
          }
        }
      }
    }
  }
  
  /// Creates empty Group.
  override init() {
    super.init()
  }
  
  // MARK: Helper Functions
  
  /// Used to find the height of descripTextView in a GroupCell displaying this Group.
  ///
  /// :param: width The current width of descripTextView.
  /// :returns: Predicted height of descripTextView in a GroupCell.
  func heightOfDescripWithWidth(width: CGFloat) -> CGFloat {
    return descrip.heightOfTextWithWidth(width, andFont: GroupCell.DescripTextViewFont)
  }
  
}