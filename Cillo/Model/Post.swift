//
//  Post.swift
//  Cillo
//
//  Created by Andrew Daley on 10/23/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

/// Defines all properties of a Post on Cillo.
class Post: IdentifiableObject, Votable {
    
    // MARK: - Votable
    
    var rep: Int = 0
    
    var voteValue: Int = 0
    
    // MARK: - Properties
    
    /// Board that this Post was posted in.
    var board = Board()
    
    /// Number of Comments relating to this Post.
    var commentCount: Int = 0
    
    /// All of the URLs for the images that this post is displaying.
    var imageURLs: [URL]?
    
    /// True if the post is an image post.
    var isImagePost: Bool {
        return imageURLs != nil
    }
    
    /// Content of this Post.
    var text: String = ""
    
    /// Time since this Post was posted.
    ///
    /// String is properly formatted via `compactTimeDisplay` property of UInt64.
    var time: String = ""
    
    /// User that posted this Post.
    var user = User()

    
    // MARK: - Initializers
    
    /// Creates Post based on a swiftyJSON retrieved from a call to the Cillo servers.
    ///
    /// Should contain key value pairs for:
    /// * "post_id" - Int
    /// * "content" - String
    /// * "board" - Dictionary
    /// * "user" - Dictionary
    /// * "time" - Int64
    /// * "title" - String?
    /// * "votes" - Int
    /// * "comment_count" - Int
    /// * "vote_value" - Int
    /// * "media_url" - String
    ///
    /// :param: json The swiftyJSON retrieved from a call to the Cillo servers.
    init(json: JSON) {
        id = json["post_id"].intValue
        text = json["content"].stringValue
        board = Board(json: json["board"])
        user = User(json: json["user"])
        let time = json["time"].int64Value
        self.time = time.compactTimeDisplay
        rep = json["votes"].intValue
        commentCount = json["comment_count"].intValue
        voteValue = json["vote_value"].intValue
        if json["media"] != nil {
            imageURLs = []
            for media in json["media"].arrayValue {
                if let url = URL(string: media.stringValue) {
                    imageURLs!.append(url)
                }
            }
        }
    }
    
    /// Creates empty Post.
    override init() {
        super.init()
    }
}

// MARK: - HeightCalculatable

extension Post: HeightCalculatable {
    
    var textToCalculate: String {
        return text
    }
}
