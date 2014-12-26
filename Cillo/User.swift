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
    var username : String = ""
    
    ///Account name for user "@username"
    var accountname : String = ""
    
    ///Profile picture of User
    var profilePic : UIImage = UIImage(named: "Me")!
    
    ///User biography
    var bio : String = ""
    
    ///ID of User
    var userID: Int = 0
    
    ///Total accumulated rep of User
    var rep : Int = 0
    
    
    //MARK: - Initializers
    
    ///Creates User based on swiftyJSON
    init(json: JSON) {
        self.username = json["name"].stringValue
        self.accountname = json["username"].stringValue
        self.userID = json["user_id"].intValue
        self.rep = json["reputation"].intValue
        if let imageData = NSData(contentsOfURL: NSURL(fileURLWithPath: json["photo"].stringValue)!) {
            if let image = UIImage(data: imageData) {
                profilePic = image
            } else {
                profilePic = UIImage(named: "Me")!
            }
        }
        self.bio = json["bio"].stringValue
    }
    
    //Creates a default User
    override init() {
        super.init()
    }
    
    
    //MARK: - Helper Functions
    
    ///Returns the predicted height of bioTextView in a UserCell.
    ///@width - width of UITextView in container
    func heightOfBioWithWidth(width: CGFloat) -> CGFloat {
        return bio.heightOfTextWithWidth(width, andFont: UserCell.BIO_TEXT_VIEW_FONT)
    }
    
    
}
