//
//  RepostCell.swift
//  Cillo
//
//  Created by Andrew Daley on 12/25/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

///Cell that corresponds to reuse identifier "Repost". Used to format Posts with (repost = true) in UITableViews.
class RepostCell: PostCell {

    //MARK: - IBOutlets
    
    ///Corresponds to repostGroup of Post
    @IBOutlet weak var repostGroupLabel: UILabel!
    
    ///Corresponds to repostUser of Post
    @IBOutlet weak var repostUserLabel: UILabel!
    
    
    //MARK: - Constants

    ///Height needed for all components of RepostCell except postTextView in Storyboard
    override var ADDITIONAL_VERT_SPACE_NEEDED : CGFloat {return 149}
    
    ///Reuse Identifier for this UITableViewCell
    override var REUSE_IDENTIFIER : String {return "Repost"}
    
    
    //MARK: - Helper Functions
    
    ///Makes this RepostCell formatted to have the possibility of being expanded and contracted if this PostCell has a seeFullButton
    override func makeCellFromPost(post: Post, withButtonTag buttonTag: Int) {
        super.makeCellFromPost(post, withButtonTag: buttonTag)
        if post.repost {
            repostGroupLabel.text = post.repostGroup!
            repostUserLabel.text = post.repostUser!
        }
    }
}
