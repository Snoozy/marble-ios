//
//  JTSImageViewControllerExt.swift
//  Cillo
//
//  Created by Andrew Daley on 8/6/16.
//  Copyright © 2016 Cillo. All rights reserved.
//

import Foundation

extension JTSImageViewController {
    
    /// Presents a JTSImageViewController over the provided viewController that expands the provided image to full screen.
    ///
    /// :param: image The image to be expanded to full screen.
    /// :param: viewController The controller that will be blurred behind the image.
    /// :param: sender The view that was pressed containing the image to expand.
    class func expand<T: UIViewController where
                      T: JTSImageViewControllerOptionsDelegate>(image: UIImage,
                                                                toFullScreenFromRoot viewController: T,
                                                                withSender sender: UIView) {
        let imageInfo = JTSImageInfo()
        imageInfo.image = image
        imageInfo.referenceRect = sender.frame
        imageInfo.referenceView = sender.superview
        imageInfo.referenceContentMode = sender.contentMode
        imageInfo.referenceCornerRadius = sender.layer.cornerRadius
        let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: .image, backgroundStyle: JTSImageViewControllerBackgroundOptions())
        imageViewer?.optionsDelegate = viewController
        imageViewer?.showFromViewController(viewController, transition: ._FromOriginalPosition)
    }
}
