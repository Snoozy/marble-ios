//
//  Post.swift
//  Cillo
//
//  Created by Andrew Daley on 10/23/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

class Post: NSObject {
    let postText : String
    var comNum : Int
    let user : String
    var rep : Int
    let date : String
    let group : String
    var seeMore : Bool = false
    
    init(postText: String, comNum: Int, user: String, rep: Int, date: String, group: String) {
        self.postText = postText
        self.comNum = comNum
        self.user = user
        self.rep = rep
        self.date = date
        self.group = group
    }
    
}
