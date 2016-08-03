//
//  Board.swift
//  Cillo
//
//  Created by Andrew Daley on 11/25/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

/// Defines all properties of a Board on Cillo.
class Board: IdentifiableObject {
    
    // MARK: - Properties
    
    /// ID of User that created this Board.
    var creatorId = 0
    
    /// Description of this Board's function.
    var descrip = ""
    
    /// Number of followers following this Board
    var followerCount = 0
    
    /// Indicates whether the end user is following this Board
    var following = false
    
    /// Name of this Board.
    var name = ""
    
    /// Picture of this Board.
    var photoURL: URL?
    
    // MARK: - Initializers
    
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
        id = json["board_id"].intValue
        creatorId = json["creator_id"].intValue
        if json["description"].string != nil {
            descrip = json["description"].stringValue
        }
        following = json["following"].boolValue
        if let url = URL(string: json["photo"].stringValue) {
            photoURL = url
        }
    }
    
    /// Creates empty Board.
    override init() {
        super.init()
    }
}

// MARK: - HeightCalculatable

extension Board: HeightCalculatable {
    
    var textToCalculate: String {
        return descrip
    }
}

// MARK: - ImageLoadable

extension Board: ImageLoadable {
    
    var imageURLsToLoad: [URL] {
        return photoURL != nil ? [photoURL!] : []
    }
}
