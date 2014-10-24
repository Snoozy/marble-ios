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
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var seeMoreButton: UIButton!
    class var textViewFont:UIFont {return UIFont.systemFontOfSize(13.0)}
    class var additionalVertSpaceNeeded:CGFloat {return 64}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
