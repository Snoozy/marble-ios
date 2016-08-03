//
//  ImageLoadable.swift
//  Cillo
//
//  Created by Andrew Daley on 8/2/16.
//  Copyright © 2016 Cillo. All rights reserved.
//

import Foundation

/// Objects conforming to this protocol have images tied to them that need to be loaded asynchronously
protocol ImageLoadable {
    
    /// A list of urls that need to be loaded
    var imageURLsToLoad: [URL] { get }
}
