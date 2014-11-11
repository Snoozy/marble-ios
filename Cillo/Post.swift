//
//  Post.swift
//  Cillo
//
//  Created by Andrew Daley on 10/23/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

///Defines all properties of a Post on Cillo
class Post: NSObject {
    
    // MARK: - Properties
    
    ///Username that posted Post
    let user : String = ""
    
    ///Profile picture of user
    let picture : UIImage = UIImage(named: "Me")!
    
    ///Group that Post was posted in
    let group : String = ""
    
    ///Content of Post
    let text : String = ""
    
    ///Title of Post. Posts can have no title
    let title : String?
    
    ///Time since Post was posted. Formatted as #h for # hours
    let time : String = ""
    
    ///Number of comments attached to Post
    var numComments : Int = 0
    
    ///(Upvotes - Downvotes) for Post
    var rep : Int = 0
    
    ///Comments replying to this Post
    var comments : [Comment] = []
    
    ///Expansion status of Post. nil -> unexpandable, false -> shortened, true -> full size
    var seeFull : Bool?
    
    
    // MARK: - Initializers
    
    ///Creates post based on input parameters
    init(text: String, numComments: Int, user: String, rep: Int, time: String, group: String, title: String?, picture : UIImage, comments: [Comment]) {
        self.text = text
        self.numComments = numComments
        self.user = user
        self.rep = rep
        self.time = time
        self.group = group
        self.title = title
        self.picture = picture
        self.comments = comments
        super.init()
    }
    
    //Creates an empty Post
    override init() {
        super.init()
    }
    
    // MARK: - Helper Functions
    
    func heightOfPostWithWidth(textViewWidth: CGFloat, andMaxContractedHeight maxHeight: CGFloat?) -> CGFloat {
        var textView = UITextView(frame: CGRectMake(0, 0, textViewWidth, CGFloat.max))
        textView.text = text
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsetsZero
        textView.font = PostCell.TEXT_VIEW_FONT
        textView.sizeToFit()
        
        if let h = maxHeight {
            //seeFull should not be nil if post needs expansion option
            if seeFull == nil && textView.frame.size.height > h {
                seeFull = false
            }
            
            if seeFull == nil || seeFull! {
                return textView.frame.size.height
            } else {
                return h
            }
        } else {
            return textView.frame.size.height
        }
    }
    
}
