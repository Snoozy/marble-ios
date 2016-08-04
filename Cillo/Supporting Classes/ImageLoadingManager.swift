//
//  ImageLoadingManager.swift
//  Cillo
//
//  Created by Andrew Daley on 8/3/16.
//  Copyright © 2016 Cillo. All rights reserved.
//

import UIKit

class ImageLoadingManager: NSObject {
    
    // MARK: - Singleton Instance
    
    static let sharedInstance = ImageLoadingManager()

    // MARK: - Properties
    
    let imageDownloader = ImageDownloader()
    
    // MARK: Downloading Functions
    
    func downloadImageFrom(url: URL) {
        imageDownloader.downloadImage(URLRequest: URLRequest(URL: url)) { response in
            ()
        }
    }
    
    func downloadImageFrom(url: URL, completionBlock: (UIImage) -> ()) {
        imageDownloader.downloadImage(URLRequest: URLRequest(URL: url)) { response in
            if let image = response.result.value {
                completionBlock(image)
            }
        }
    }
}
