//
//  PostCell.swift
//  Cillo
//
//  Created by Andrew Daley on 10/23/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {


    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var repLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var seeFullButton: UIButton!
    @IBOutlet weak var titleHeightConstraint: NSLayoutConstraint!
    
    
    class var textViewFont:UIFont {return UIFont.systemFontOfSize(15.0)}
    class var additionalVertSpaceNeeded:CGFloat {return 139}
    class var titleHeight:CGFloat {return 26.5}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
