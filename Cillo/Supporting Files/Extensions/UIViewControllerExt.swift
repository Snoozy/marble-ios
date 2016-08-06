//
//  UIViewControllerExt.swift
//  Cillo
//
//  Created by Andrew Daley on 8/6/16.
//  Copyright © 2016 Cillo. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // MARK: Setup Helper Functions
    
    /// Adds an animated UIActivityIndicatorView to the center of view in this UIViewController.
    ///
    /// :returns: The UIView at the center of view in this UIViewController.
    /// :returns: **Note:** Can remove the UIView from the center of this view by calling returnedView.removeFromSuperView(), where returnedView is the UIView returned by this function.
    func addActivityIndicatorToCenterWith(text: String) -> UIView {
        let loadingView = UIView(frame: CGRect(x: 0, y: 0, width: 170, height: 170))
        loadingView.backgroundColor = ColorScheme.defaultScheme.activityIndicatorBackgroundColor()
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10.0
        loadingView.center = CGPoint(x: view.center.x, y: view.center.y)
        if let navigationController = navigationController as? FormattedNavigationViewController {
            loadingView.center.y -= navigationController.navigationBar.frame.height / 2
        }
        if let tabBarController = tabBarController as? TabViewController {
            loadingView.center.y -= tabBarController.tabBar.frame.height / 2
        }
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: ColorScheme.defaultScheme.activityIndicatoryStyle())
        activityIndicator.frame.origin.x = 65
        activityIndicator.frame.origin.y = 60
        loadingView.addSubview(activityIndicator)
        
        let loadingLabel = UILabel(frame: CGRect(x: 15, y: 115, width: 140, height: 30))
        loadingLabel.backgroundColor = UIColor.clear
        loadingLabel.textColor = ColorScheme.defaultScheme.activityIndicatorTextColor()
        loadingLabel.adjustsFontSizeToFitWidth = true
        loadingLabel.textAlignment = .center
        loadingLabel.text = text
        loadingView.addSubview(loadingLabel)
        
        activityIndicator.startAnimating()
        view.addSubview(loadingView)
        view.bringSubview(toFront: loadingView)
        return loadingView
    }
}
