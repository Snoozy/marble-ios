//
//  Group.swift
//  Cillo
//
//  Created by Andrew Daley on 11/25/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

class Group: NSObject {
   
    var picture: UIImage = UIImage(named: "Groups")!
    var name: String = ""
    var systemName : String = "#"
    var descrip : String = ""
    var numFollowers : Int = 0
    var numPosts : Int = 0
    
    init(name: String, systemName: String, description: String, numFollowers: Int, numPosts: Int, picture: UIImage) {
        self.name = name
        self.systemName = systemName
        self.descrip = description
        self.numFollowers = numFollowers
        self.numPosts = numPosts
        self.picture = picture
    }
    
    override init() {
        super.init()
    }
    
    //MARK: - Helper Functions
    
    ///returns the predicted height of a bioTextView in a UserCell
    func heightOfDescripWithWidth(width: CGFloat) -> CGFloat {
        return descrip.heightOfTextWithWidth(width, andFont: GroupCell.DESCRIP_TEXT_VIEW_FONT)
    }
    
}
