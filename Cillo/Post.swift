//
//  Post.swift
//  Cillo
//
//  Created by Andrew Daley on 10/23/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

class Post: NSObject {
    let post : String
    var comNum : Int
    let user : String
    var karma : Int
    let date : String
    let group : String
    var seeMore : Bool = false
    
    init(post: String, comNum: Int, user: String, karma: Int, date: String, group: String) {
        self.post = post
        self.comNum = comNum
        self.user = user
        self.karma = karma
        self.date = date
        self.group = group
    }
    
}
