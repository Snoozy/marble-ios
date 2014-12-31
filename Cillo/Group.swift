//
//  Group.swift
//  Cillo
//
//  Created by Andrew Daley on 11/25/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

///Defines all properties of a Group on Cillo
class Group: NSObject {
  
  // MARK: - Properties
  
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
  
  // MARK: - Initializers
  
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
  init(json: JSON) {
    name = json["name"].stringValue
    numFollowers = json["followers"].intValue
    groupID = json["group_id"].intValue
    creatorID = json["creator_id"].intValue
    if let s = json["description"].string {
      descrip = s
    }
    following = json["following"].boolValue
    if let imageData = NSData(contentsOfURL: NSURL(fileURLWithPath: json["photo"].stringValue)!) {
      if let image = UIImage(data: imageData) {
        picture = image
      } else {
        picture = UIImage(named: "Groups")!
      }
    }
  }
  
  //Creates empty Group
  override init() {
    super.init()
  }
  
  // MARK: - Helper Functions
  
  /// Used to find the height of descripTextView in a GroupCell displaying this Group.
  ///
  /// :param: width The current width of descripTextView.
  /// :returns: Predicted height of descripTextView in a GroupCell.
  func heightOfDescripWithWidth(width: CGFloat) -> CGFloat {
    return descrip.heightOfTextWithWidth(width, andFont: GroupCell.DescripTextViewFont)
  }
  
}
