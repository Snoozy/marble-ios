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
    
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var repLabel: UILabel!
    @IBOutlet weak var groupsButton: UIButton!
    @IBOutlet weak var postsSegControl: UISegmentedControl!
    
    
    //MARK - Constants
    
    ///Height needed for all components of CommentCell except commentTextView in Storyboard
    class var ADDITIONAL_VERT_SPACE_NEEDED:CGFloat {return 215}
    
    class var BIO_TEXT_VIEW_FONT:UIFont {return UIFont.systemFontOfSize(15.0)}
    
    class var REP_FONT:UIFont {return UIFont.systemFontOfSize(15.0)}
    
    class var REP_FONT_BOLD:UIFont {return UIFont.boldSystemFontOfSize(18.0)}
    
    class var GROUPS_FONT:UIFont {return UIFont.systemFontOfSize(15.0)}
    
    class var GROUPS_FONT_BOLD:UIFont {return UIFont.boldSystemFontOfSize(18.0)}
    
    class var SEG_CONTROL_FONT:UIFont {return UIFont.boldSystemFontOfSize(12.0)}
    
    func makeStandardUserCellFromUser(user: User) {
        profilePicView.image = user.profilePic
        userLabel.text = user.username
        accountLabel.text = user.accountname
        
        bioTextView.text = user.bio
        bioTextView.font = UserCell.BIO_TEXT_VIEW_FONT
        bioTextView.textContainer.lineFragmentPadding = 0
        bioTextView.textContainerInset = UIEdgeInsetsZero
        
        //Make only the number in repLabel bold
        var rep = NSMutableAttributedString(string: user.rep >= 1000 ? "\(Format.convertToThousands(user.rep))" : "\(user.rep)", attributes: [NSFontAttributeName:UserCell.REP_FONT_BOLD])
        var repWord = NSMutableAttributedString(string: " REP", attributes: [NSFontAttributeName:UserCell.REP_FONT])
        rep.appendAttributedString(repWord)
        repLabel.attributedText = rep
        
        //Make only the number in groupsButton bold
        var group = NSMutableAttributedString(string: user.numGroups >= 1000 ? "\(Format.convertToThousands(user.numGroups))" : "\(user.numGroups)", attributes: [NSFontAttributeName:UserCell.GROUPS_FONT_BOLD])
        var groupWord = NSMutableAttributedString(string: " GROUPS", attributes: [NSFontAttributeName:UserCell.GROUPS_FONT])
        group.appendAttributedString(groupWord)
        groupsButton.setAttributedTitle(group, forState: .Normal)
        groupsButton.tintColor = UIColor.blackColor()
        
        postsSegControl.setTitleTextAttributes([NSFontAttributeName:UserCell.SEG_CONTROL_FONT], forState: .Normal)
    }

}
