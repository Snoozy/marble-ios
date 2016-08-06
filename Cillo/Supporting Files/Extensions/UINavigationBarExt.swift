//
//  UINavigationBarExt.swift
//  Cillo
//
//  Created by Andrew Daley on 8/6/16.
//  Copyright © 2016 Cillo. All rights reserved.
//

import UIKit

extension UINavigationBar {
    
    // MARK: Setup Helper Functions
    
    /// Sets up this navigation bar with the proper colors according the specified scheme.
    ///
    /// :param: scheme The scheme to use when setting up this navigation bar.
    func setupAttributesFor(colorScheme: ColorScheme) {
        barTintColor = colorScheme.navigationBarColor()
        tintColor = colorScheme.barButtonItemColor()
        titleTextAttributes = [NSForegroundColorAttributeName: colorScheme.navigationBarTitleColor()]
    }
}
