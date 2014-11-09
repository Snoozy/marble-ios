//
//  User.swift
//  Cillo
//
//  Created by Andrew Daley on 11/6/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

class User: NSObject {
   
    //MARK: - Properties
    
    var username: String = ""
    var posts: [Post] = []
    var comments: [Comment] = []
    var profilePic: UIImage = UIImage(named: "Me")!
    var bio: String = ""
    var numGroups: Int = 0
    var rep: Int = 0
    
    
    //MARK: - Initializers
    
    init(username: String, posts: [Post], comments: [Comment], profilePic: UIImage, bio: String, numGroups: Int, rep: Int) {
        self.username = username
        self.posts = posts
        self.comments = comments
        self.profilePic = profilePic
        self.bio = bio
        self.numGroups = numGroups
        self.rep = rep
    }
    
    override init() {
        super.init()
    }
    
    
    //MARK: - Helper Functions
    
    func heightOfBioWithWidth(width: CGFloat) -> CGFloat {
        var textView = UITextView(frame: CGRectMake(0, 0, width, CGFloat.max))
        textView.text = bio
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsetsZero
        textView.font = CommentCell.TEXT_VIEW_FONT
        textView.sizeToFit()
            
        return textView.frame.size.height
    }
    
    
}
