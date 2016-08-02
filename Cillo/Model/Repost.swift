//
//  Repost.swift
//  Cillo
//
//  Created by Andrew Daley on 1/1/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Defines all properties of a Repost on Cillo.
class Repost: Post {
    
    // MARK: Properties
    
    /// The original Post that was reposted by this post.
    var originalPost = Post()
    
    // MARK: Initializers
    
    /// Creates Repost based on a swiftyJSON retrieved from a call to the Cillo servers.
    ///
    /// **Warning:** json must have "repost" key as true.
    ///
    /// Should contain key value pairs for:
    /// * "post_id" - Int
    /// * "repost" - Dictionary
    /// * "content" - String
    /// * "board" - Dictionary
    /// * "user" - Dictionary
    /// * "time" - Int64
    /// * "title" - String?
    /// * "rep" - Int
    /// * "comment_count" - Int
    /// * "vote_value" - Int
    ///
    /// :param: json The swiftyJSON retrieved from a call to the Cillo servers.
    override init(json: JSON) {
        originalPost = Post(json: json["repost"])
        super.init(json: json)
    }
    
    /// Create empty Repost.
    override init() {
        super.init()
    }
}
