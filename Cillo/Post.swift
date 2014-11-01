//
//  Post.swift
//  Cillo
//
//  Created by Andrew Daley on 10/23/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

class Post: NSObject {
    let text : String
    var numComments : Int
    let user : String
    var rep : Int
    let time : String
    let group : String
    let title : String?
    let picture : UIImage
    var seeFull : Bool?
    
    init(text: String, numComments: Int, user: String, rep: Int, time: String, group: String, title: String?, picture : UIImage) {
        self.text = text
        self.numComments = numComments
        self.user = user
        self.rep = rep
        self.time = time
        self.group = group
        self.title = title
        self.picture = picture
    }
    
}
