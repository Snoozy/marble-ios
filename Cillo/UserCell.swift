//
//  UserCell.swift
//  Cillo
//
//  Created by Andrew Daley on 11/13/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    //MARK: - IBOutlets
    
    ///IBOulets Corresponding to fields in User
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var repLabel: UILabel!
    @IBOutlet weak var groupsButton: UIButton!
    @IBOutlet weak var postsSegControl: UISegmentedControl!
    
    
    //MARK - Constants
    
    ///Height needed for all components of UserCell except bioTextView in Storyboard
    class var ADDITIONAL_VERT_SPACE_NEEDED:CGFloat {return 215}
    
    ///Font for bioTextView
    class var BIO_TEXT_VIEW_FONT:UIFont {return UIFont.systemFontOfSize(15.0)}
    
    ///Font for word REP in repLabel
    class var REP_FONT:UIFont {return UIFont.systemFontOfSize(15.0)}
    
    ///Font for number in repLabel
    class var REP_FONT_BOLD:UIFont {return UIFont.boldSystemFontOfSize(18.0)}
    
    ///Font for word GROUPS in groupsButton
    class var GROUPS_FONT:UIFont {return UIFont.systemFontOfSize(15.0)}
    
    ///Font for number in groupsButton
    class var GROUPS_FONT_BOLD:UIFont {return UIFont.boldSystemFontOfSize(18.0)}
    
    ///Font for postsSegControl
    class var SEG_CONTROL_FONT:UIFont {return UIFont.boldSystemFontOfSize(12.0)}
    
    ///Makes the UserCell formatted in accordance with user
    func makeStandardUserCellFromUser(user: User) {
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
