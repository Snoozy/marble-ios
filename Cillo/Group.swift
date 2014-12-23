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
    
    ///Picture of Group
    var picture : UIImage = UIImage(named: "Groups")!
    
    ///Name of Group
    var name : String = ""
    
    ///Group ID "#name"
    var systemName : String = "#"
    
    ///Description of Group's function
    var descrip : String = ""
    
    ///Number of Followers of Group
    var numFollowers : Int = 0
    
    ///Number of Posts in Group
    var numPosts : Int = 0
    
    
    //MARK: - Initializers
    
    ///Creates Group based on input parameters
    init(name: String, systemName: String, description: String, numFollowers: Int, numPosts: Int, picture: UIImage) {
        self.name = name
        self.systemName = systemName
        self.descrip = description
        self.numFollowers = numFollowers
        self.numPosts = numPosts
        self.picture = picture
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
