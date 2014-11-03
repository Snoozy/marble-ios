//
//  Comment.swift
//  Cillo
//
//  Created by Andrew Daley on 11/3/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

class Comment: NSObject {
   
    //MARK: - Properties
    
    ///Username that posted Post
    let user: String
    
    ///Profile picture of user
    let picture: UIImage
    
    ///Content of Comment
    let text: String
    
    ///Time since Post was posted. Formatted as #h for # hours
    let time : String
    
    ///Number of Comments that replied to this Comment
    var numComments: Int
    
    ///(Upvotes - Downvotes) for Comment
    var rep: Int
    
    ///Distance to parent Post through tree
    var lengthToPost: Int
    
    ///Comments replying to this Comment
    let comments: [Comment]
    
    
    //MARK: - Initializers
    
    init(user: String, picture: UIImage, text: String, time: String, numComments: Int, rep: Int, lengthToPost: Int, comments: [Comment]) {
        self.user = user
        self.picture = picture
        self.text = text
        self.time = time
        self.numComments = numComments
        self.rep = rep
        self.lengthToPost = lengthToPost
        self.comments = comments
    }
    
}
