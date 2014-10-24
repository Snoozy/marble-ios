//
//  PostCell.swift
//  Cillo
//
//  Created by Andrew Daley on 10/23/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {

    required init(coder aDecoder: NSCoder) {
        post = Post(post: "", comNum: 0, user: "", karma: 0, date: "", group: "")
        super.init(coder: aDecoder)
    }

    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var repLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var seeMoreButton: UIButton!
    class var textViewFont:UIFont {return UIFont.systemFontOfSize(13.0)}
    class var additionalVertSpaceNeeded:CGFloat {return 64}
    var post : Post
    
    @IBAction func seeMorePressed(sender: UIButton) {
        post.seeMore = !post.seeMore
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
