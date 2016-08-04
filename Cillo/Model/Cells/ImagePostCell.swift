//
//  ImagePostCell.swift
//  Cillo
//
//  Created by Andrew Daley on 8/4/16.
//  Copyright © 2016 Cillo. All rights reserved.
//

import UIKit

class ImagePostCell: PostCell, ImagePostDisplayable {
    
    // MARK: - ImagePostDisplayable
    
    @IBOutlet weak var imagesButton: UIButton!
    
    // MARK: - Setup Helper Functions

    override func makeFrom(post: Post, expanded: Bool) {
        super.makeFrom(post: post, expanded: expanded)
        setImagesButtonToDisplay(post: post)
    }
}
