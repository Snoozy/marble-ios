//
//  UIStoryboardExt.swift
//  Cillo
//
//  Created by Andrew Daley on 8/6/16.
//  Copyright © 2016 Cillo. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    // MARK: - Constants
    
    /// The instance of the storyboard used.
    class var mainStoryboard: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
}
