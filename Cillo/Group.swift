//
//  Group.swift
//  Cillo
//
//  Created by Andrew Daley on 11/25/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

///Defines all properties of a Group on Cillo
class Group: NSObject {
   
    //MARK: - Properties
    
    ///ID of Group
    var groupID : Int = 0
    
    ///ID of User that created Group
    var creatorID : Int = 0
    
    ///Picture of Group
    var picture : UIImage = UIImage(named: "Groups")!
    
    ///Name of Group
    var name : String = "#"
    
    ///Description of Group's function
    var descrip : String = ""
    
    ///Number of Followers of Group
    var numFollowers : Int = 0
    
    ///(Logged in User is following this group)
    var following : Bool = false
    
    
    //MARK: - Initializers
    
    ///Creates Group based on swiftyJSON
    init(json: JSON) {
        self.name = json["name"].stringValue
        self.numFollowers = json["followers"].intValue
        self.groupID = json["group_id"].intValue
        self.creatorID = json["creator_id"].intValue
        if let s = json["description"].string {
            self.descrip = s
        }
        self.following = json["following"].boolValue
        if let imageData = NSData(contentsOfURL: NSURL(fileURLWithPath: json["photo"].stringValue)!) {
            if let image = UIImage(data: imageData) {
                picture = image
            } else {
                picture = UIImage(named: "Groups")!
            }
        }
    }
    
    //Creates empty Group
    override init() {
        super.init()
    }
    
    //MARK: - Helper Functions
    
    ///Returns the predicted height of descripTextView in a GroupCell.
    ///@width - width of UITextView in container
    func heightOfDescripWithWidth(width: CGFloat) -> CGFloat {
        return descrip.heightOfTextWithWidth(width, andFont: GroupCell.DESCRIP_TEXT_VIEW_FONT)
    }
    
}
