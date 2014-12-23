//
//  UserCell.swift
//  Cillo
//
//  Created by Andrew Daley on 11/13/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    ///enum of segmentIndexes in postsSegControl
    enum segIndex {
        //segmentIndex 0
        case POSTS
        //segmentIndex 1
        case COMMENTS
    }
    
    //MARK: - IBOutlets
    
    ///Corresponds to proficlePic of User
    @IBOutlet weak var profilePicView: UIImageView!
    
    ///Corresponds to username of User
    @IBOutlet weak var userLabel: UILabel!
    
    ///Corresponds to accountname of User
    @IBOutlet weak var accountLabel: UILabel!
    
    ///Corresponds to bio of User
    @IBOutlet weak var bioTextView: UITextView!
    
    ///Corresponds to rep of User
    @IBOutlet weak var repLabel: UILabel!
    
    ///Corresponds to numGroups of User
    @IBOutlet weak var groupsButton: UIButton!
    
    ///Used to select what type of cells are shown under UserCell
    @IBOutlet weak var postsSegControl: UISegmentedControl!
    
    
    //MARK: - Constants
    
    ///Height needed for all components of UserCell except bioTextView in Storyboard
    class var ADDITIONAL_VERT_SPACE_NEEDED : CGFloat {return 215}
    
    ///Font for bioTextView
    class var BIO_TEXT_VIEW_FONT : UIFont {return UIFont.systemFontOfSize(15.0)}
    
    ///Font for word REP in repLabel
    class var REP_FONT : UIFont {return UIFont.systemFontOfSize(15.0)}
    
    ///Font for number in repLabel
    class var REP_FONT_BOLD : UIFont {return UIFont.boldSystemFontOfSize(18.0)}
    
    ///Font for word GROUPS in groupsButton
    class var GROUPS_FONT : UIFont {return UIFont.systemFontOfSize(15.0)}
    
    ///Font for number in groupsButton
    class var GROUPS_FONT_BOLD : UIFont {return UIFont.boldSystemFontOfSize(18.0)}
    
    ///Font for postsSegControl
    class var SEG_CONTROL_FONT : UIFont {return UIFont.boldSystemFontOfSize(12.0)}
    
    ///Reuse Identifier for this UITableViewCell
    class var REUSE_IDENTIFIER : String {return "User"}
    
    
    //MARK: - Helper Methods
    
    ///Makes the UserCell formatted in accordance with User
    func makeCellFromUser(user: User) {
        profilePicView.image = user.profilePic
        userLabel.text = user.username
        accountLabel.text = user.accountname
        
        bioTextView.text = user.bio
        bioTextView.font = UserCell.BIO_TEXT_VIEW_FONT
        bioTextView.textContainer.lineFragmentPadding = 0
        bioTextView.textContainerInset = UIEdgeInsetsZero
        
        //Make only the number in repLabel bold
        var repText = NSMutableAttributedString.firstHalfBoldMutableAttributedString(String.formatNumberAsString(user.rep),boldedFont: UserCell.REP_FONT_BOLD,normalString: " REP", normalFont: UserCell.REP_FONT)
        repLabel.attributedText = repText
        
        //Make only the number in groupsButton bold
        var groupsText = NSMutableAttributedString.firstHalfBoldMutableAttributedString(String.formatNumberAsString(user.numGroups),boldedFont: UserCell.GROUPS_FONT_BOLD,normalString: " GROUPS", normalFont: UserCell.GROUPS_FONT)
        groupsButton.setAttributedTitle(groupsText, forState: .Normal)
        groupsButton.tintColor = UIColor.blackColor()
        
        postsSegControl.setTitleTextAttributes([NSFontAttributeName:UserCell.SEG_CONTROL_FONT], forState: .Normal)
    }

}
