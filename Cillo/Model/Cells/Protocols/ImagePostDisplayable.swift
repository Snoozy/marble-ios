//
//  ImagePostDisplayable.swift
//  Cillo
//
//  Created by Andrew Daley on 8/4/16.
//  Copyright © 2016 Cillo. All rights reserved.
//

import Foundation

protocol ImagePostDisplayable {
    var imagesButton: UIButton! { get }
}

extension ImagePostDisplayable {
    
    /// Asynchronously loads the first image of `post.imageURLs` into `imagesButton`
    ///
    /// - Parameter post: The post to load into `imagesButton`
    func setImagesButtonToDisplay(post: Post) {
        imagesButton.setImage(nil, for: UIControlState())
        imagesButton.imageView?.contentMode = .scaleAspectFill
        imagesButton.clipsToBounds = true
        imagesButton.contentHorizontalAlignment = .fill
        imagesButton.contentVerticalAlignment = .fill
        if let urls = post.imageURLs {
            for url in urls {
                ImageLoadingManager.sharedInstance.downloadImageFrom(url: url) { image in
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.3) {
                            imagesButton.setImage(image, for: UIControlState())
                        }
                    }
                }
                // only handling one image right now
                break
            }
        }
    }
}
