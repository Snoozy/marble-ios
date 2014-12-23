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
    
    //MARK: - Properties
    
    ///ID of post
    let postID : String = ""
    
    ///ID of group
    let groupID : String = ""
    
    ///Is a repost
    let repost : Bool = false
    
    ///Username that reposted Post
    let repostUser : String?
    
    ///Group that Post was reposted into
    let repostGroup : String?
    
    ///Username that posted Post
    let user : String = ""
    
    ///User username that posted Post (ie "@ndusgal")
    let username : String = ""
    
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
    
    ///Expansion status of Post. nil -> unexpandable, false -> shortened, true -> full size
    var seeFull : Bool?
    
    
    //MARK: - Initializers
    
    ///Creates Post based on swiftyJSON
    init(json: JSON) {
        self.postID = String(json["post_id"].intValue)
        self.repost = json["repost"].boolValue
        if self.repost {
            self.repostUser = json["repost_user"].stringValue
            self.repostGroup = json["repost_group"].stringValue
        }
        self.text = json["content"].stringValue
        self.groupID = String(json["group_id"].intValue)
        self.group = json["group_name"].stringValue
        self.user = json["user_name"].stringValue
        self.username = json["user_username"].stringValue
        if let imageData = NSData(contentsOfURL: NSURL(fileURLWithPath: json["user_photo"].stringValue)!) {
            if let image = UIImage(data: imageData) {
                picture = image
            } else {
                picture = UIImage(named: "Me")!
            }
        }
        let time = json["time"].int64Value
        self.time = NSDate.convertToTimeString(time)
        self.rep = json["votes"].intValue
        self.numComments = json["comment_count"].intValue
    }
    
    //Creates empty Post
    override init() {
        super.init()
    }
    
    //MARK: - Helper Functions
    
    ///Returns the predicted height of postTextView in a PostCell. 
    ///@width - width of UITextView in container
    ///@maxHeight - maximum height of UITextView if it is expandable
    func heightOfPostWithWidth(width: CGFloat, andMaxContractedHeight maxHeight: CGFloat?) -> CGFloat {
        let height = text.heightOfTextWithWidth(width, andFont: PostCell.POST_TEXT_VIEW_FONT)
        if let h = maxHeight {
            //seeFull should not be nil if post needs expansion option
            if seeFull == nil && height > h {
                seeFull = false
            }
            
            if seeFull == nil || seeFull! {
                return height
            } else {
                return h
            }
        } else {
            return height
        }
    }
    
}
