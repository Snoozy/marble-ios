//
//  GroupCell.swift
//  Cillo
//
//  Created by Andrew Daley on 11/25/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

class GroupCell: UITableViewCell {

    //MARK: - IBOutlets
    
    @IBOutlet weak var groupPicView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var systemNameLabel: UILabel!
    @IBOutlet weak var descripTextView: UITextView!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var postsButton: UIButton!

    
    //MARK: - Constants
    
    ///Height needed for all components of GroupCell except descripTextView in Storyboard
    class var ADDITIONAL_VERT_SPACE_NEEDED:CGFloat {return 188}
    
    ///Font for descripTextView
    class var DESCRIP_TEXT_VIEW_FONT:UIFont {return UIFont.systemFontOfSize(15.0)}
    
    ///Font for word FOLLOWERS in followersLabel
    class var FOLLOWER_FONT:UIFont {return UIFont.systemFontOfSize(15.0)}
    
    ///Font for number in followersLabel
    class var FOLLOWER_FONT_BOLD:UIFont {return UIFont.boldSystemFontOfSize(18.0)}
    
    ///Font for word POSTS in postsButton
    class var POSTS_FONT:UIFont {return UIFont.systemFontOfSize(15.0)}
    
    ///Font for number in postsButton
    class var POSTS_FONT_BOLD:UIFont {return UIFont.boldSystemFontOfSize(18.0)}
    
    ///Makes the UserCell formatted in accordance with user
    func makeStandardGroupCellFromGroup(group: Group) {
        groupPicView.image = group.picture
        nameLabel.text = group.name
        systemNameLabel.text = group.systemName
        
        descripTextView.text = group.descrip
        descripTextView.font = GroupCell.DESCRIP_TEXT_VIEW_FONT
        descripTextView.textContainer.lineFragmentPadding = 0
        descripTextView.textContainerInset = UIEdgeInsetsZero
        
        //Make only the number in followersLabel bold
        var followersText = NSMutableAttributedString.firstHalfBoldMutableAttributedString(String.formatNumberAsString(group.numFollowers),boldedFont: GroupCell.FOLLOWER_FONT_BOLD,normalString: " FOLLOWERS", normalFont: GroupCell.FOLLOWER_FONT)
        followersLabel.attributedText = followersText
        
        //Make only the number in groupsButton bold
        var postsText = NSMutableAttributedString.firstHalfBoldMutableAttributedString(String.formatNumberAsString(group.numPosts),boldedFont: GroupCell.POSTS_FONT_BOLD,normalString: " POSTS", normalFont: GroupCell.POSTS_FONT)
        postsButton.setAttributedTitle(postsText, forState: .Normal)
        postsButton.tintColor = UIColor.blackColor()
        
    }
    
    
}
