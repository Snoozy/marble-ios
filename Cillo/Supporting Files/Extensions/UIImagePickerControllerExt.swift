//
//  UIImagePickerControllerExt.swift
//  Cillo
//
//  Created by Andrew Daley on 8/6/16.
//  Copyright © 2016 Cillo. All rights reserved.
//

import UIKit

extension UIImagePickerController {
    
    // MARK: - Setup Helper Functions
    
    // FIXME: This function is probably useless without iOS 7 support
    class func defaultActionSheetDelegateImplementationWith<T: UIViewController where
                                                            T: UIImagePickerControllerDelegate,
                                                            T: UINavigationControllerDelegate,
                                                            T: UIActionSheetDelegate>(source: T,
                                                                                      withSelectedIndex index: Int) {
        switch index {
        case 0:
            let pickerController = UIImagePickerController()
            pickerController.delegate = source
            source.present(pickerController, animated: true, completion: nil)
        case 1:
            let pickerController = UIImagePickerController()
            pickerController.delegate = source
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                pickerController.sourceType = .camera
            }
            source.present(pickerController, animated: true, completion: nil)
        default:
            break
        }
    }
    
    /// Presents an action sheet that allows the user to choose a photo from library or take a photo with the camera.
    ///
    /// :param: source The view controller that will be the source of the modal presentation of the action sheet and the image picker onto it.
    class func presentActionSheetForPhotoSelectionFrom<T: UIViewController where
        T: UIImagePickerControllerDelegate,
        T: UINavigationControllerDelegate>(source: T,
                                           withTitle title: String,
                                           iPadReference: UIButton?) {
        
        let actionSheet = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
        }
        let pickerAction = UIAlertAction(title: "Choose Photo from Library", style: .default) { _ in
            let pickerController = UIImagePickerController()
            pickerController.delegate = source
            source.present(pickerController, animated: true, completion: nil)
        }
        let cameraAction = UIAlertAction(title: "Take Photo", style: .default) { _ in
            let pickerController = UIImagePickerController()
            pickerController.delegate = source
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                pickerController.sourceType = .camera
            }
            source.present(pickerController, animated: true, completion: nil)
        }
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(pickerAction)
        actionSheet.addAction(cameraAction)
        if let iPadReference = iPadReference && UIDevice.current.userInterfaceIdiom == .pad {
            actionSheet.modalPresentationStyle = .popover
            let popPresenter = actionSheet.popoverPresentationController
            popPresenter?.sourceView = iPadReference
            popPresenter?.sourceRect = iPadReference.bounds
        }
        source.present(actionSheet, animated: true, completion: nil)
    }
}
