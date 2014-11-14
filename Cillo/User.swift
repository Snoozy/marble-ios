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
    
    ///Display name for User
    var username: String = ""
    
    ///Account name for user (@BlahBlah)
    var accountname: String = ""
    
    ///Array of Posts made by User
    var posts: [Post] = []
    
    ///Array of Comments made by User
    var comments: [Comment] = []
    
    ///Profile Picture of User
    var profilePic: UIImage = UIImage(named: "Me")!
    
    ///User biography
    var bio: String = ""
    
    ///Number of Groups that User is following
    var numGroups: Int = 0
    
    ///Total accumulated rep of User
    var rep: Int = 0
    
    
    //MARK: - Initializers
    
    ///creates User based on input parameters
    init(username: String, accountname: String, posts: [Post], comments: [Comment], profilePic: UIImage, bio: String, numGroups: Int, rep: Int) {
        self.username = username
        self.accountname = accountname
        self.posts = posts
        self.comments = comments
        self.profilePic = profilePic
        self.bio = bio
        self.numGroups = numGroups
        self.rep = rep
    }
    
    //creates a default User
    override init() {
        super.init()
    }
    
    
    //MARK: - Helper Functions
    
    //returns the predicted height of a bioTextView in a UserCell
    func heightOfBioWithWidth(width: CGFloat) -> CGFloat {
        var textView = UITextView(frame: CGRectMake(0, 0, width, CGFloat.max))
        textView.text = bio
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsetsZero
        textView.font = UserCell.BIO_TEXT_VIEW_FONT
        textView.sizeToFit()
            
        return textView.frame.size.height
    }
    
    
}
