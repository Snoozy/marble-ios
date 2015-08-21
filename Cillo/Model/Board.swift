//
//  Board.swift
//  Cillo
//
//  Created by Andrew Daley on 11/25/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

/// Defines all properties of a Board on Cillo.
class Board: NSObject {
  
  // MARK: Properties
  
  /// ID of this Board.
  var boardID = 0
  
  /// ID of User that created this Board.
  var creatorID = 0
  
  /// Description of this Board's function.
  var descrip = ""
  
  /// Number of followers following this Board
  var followerCount = 0
  
  /// Indicates whether the end user is following this Board
  var following = false
  
  /// Name of this Board.
  var name = ""
  
  /// Picture of this Board.
  var photoURL = NSURL()
  
  // MARK: Initializers
  
  /// Creates Board based on a swiftyJSON retrieved from a call to the Cillo servers.
  ///
  /// Should contain key value pairs for:
  /// * "name" - String
  /// * "followers" - Int
  /// * "board_id" - Int
  /// * "creator_id" - Int
  /// * "description" - String?
  /// * "following" - Bool
  /// * "photo" - String
  ///
  /// :param: json The swiftyJSON retrieved from a call to the Cillo servers.
  init(json: JSON) {
    name = json["name"].stringValue
    followerCount = json["followers"].intValue
    boardID = json["board_id"].intValue
    creatorID = json["creator_id"].intValue
    if json["description"].string != nil {
      descrip = json["description"].stringValue
    }
    following = json["following"].boolValue
    if let url = NSURL(string: json["photo"].stringValue) {
      photoURL = url
    }
  }
  
  /// Creates empty Board.
  override init() {
    super.init()
  }
  
  // MARK: Setup Helper Functions
  
  /// Used to find the height of descripTextView in a Board displaying this Board.
  ///
  /// :param: width The current width of descripTextView.
  /// :returns: Predicted height of descripTextView in a BoardCell.
  func heightOfDescripWithWidth(width: CGFloat) -> CGFloat {
    return descrip.heightOfTextWithWidth(width, andFont: BoardCell.descripAttributedLabelFont)
  }
}
