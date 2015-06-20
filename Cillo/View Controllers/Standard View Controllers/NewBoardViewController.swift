//
//  NewBoardViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 1/7/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit
import JTSImageViewController

/// Handles creating new Boards.
class NewBoardViewController: CustomViewController {
  
  // MARK: Properties
  
  /// Stores the chosen photo to be uploaded as the Board's photo.
  var image: UIImage?

  // MARK: IBOutlets
  
  /// Button allowing end user to change their board photo.
  @IBOutlet weak var choosePhotoButton: UIButton!
  
  /// Field for end user to enter the description of the new Board.
  @IBOutlet weak var descripTextView: PlaceholderTextView!
  
  /// Set to DescripTextViewHeight after viewDidLayoutSubviews().
  @IBOutlet weak var descripTextViewHeightConstraint: NSLayoutConstraint!
  
  /// Field for end user to enter the name of the new Board.
  @IBOutlet weak var nameTextField: CustomTextField!
  
  /// Button used to display the end user's selected board photo.
  @IBOutlet weak var photoButton: UIButton!
  
  // MARK: Constants
  
  // FIXME: Implement this with notification center to get keyboard height correctly
  
  /// Calculated height of descripTextView based on frame size of device.
  var descripTextViewHeight: CGFloat {
    return view.frame.height - UITextView.keyboardHeight - vertSpaceExcludingDescripTextView
  }
  
  /// Height needed for all components of a NewBoardViewController excluding descripTextView in the Storyboard.
  ///
  /// **Note:** Height of descripTextView must be calculated based on the frame size of the device.
  var vertSpaceExcludingDescripTextView: CGFloat {
    return 188
  }
  
  // MARK: UIViewController
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == SegueIdentifiers.newBoardToTab {
      var destination = segue.destinationViewController as! TabViewController
      resignTextFieldResponders()
      if let sender = sender as? Board, navController = destination.selectedViewController as? UINavigationController {
        let boardViewController = self.storyboard!.instantiateViewControllerWithIdentifier(StoryboardIdentifiers.board) as! BoardTableViewController
        boardViewController.board = sender
        navController.pushViewController(boardViewController, animated: true)
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupColorScheme()
    setupOutletAppearances()
  }
  
  // MARK: Setup Helper Functions
  
  /// Hides the keyboard of all textfields.
  private func resignTextFieldResponders() {
    descripTextView.resignFirstResponder()
    nameTextField.resignFirstResponder()
  }
  
  /// Sets up the colors of the Outlets according to the default scheme of the app.
  private func setupColorScheme() {
    let scheme = ColorScheme.defaultScheme
    choosePhotoButton.tintColor = scheme.touchableTextColor()
    nameTextField.backgroundColor = scheme.textFieldBackgroundColor()
    descripTextView.backgroundColor = scheme.textFieldBackgroundColor()
  }
  
  /// Sets up the appearance of Outlets that were not set in the storyboard.
  private func setupOutletAppearances() {
    descripTextViewHeightConstraint.constant = descripTextViewHeight
    photoButton.clipsToBounds = true
    photoButton.layer.cornerRadius = 5.0
  }
  
  // MARK: Networking Helper Functions
  
  /// Used to create and retrieve a new Board made by the end user from Cillo servers.
  ///
  /// :param: mediaID The media id for the uploaded photo that resembles this board.
  /// :param: completionHandler The completion block for the board creation.
  /// :param: board The new Board that was created from calling the servers.
  ///
  /// :param: * Nil if server call passed an error back.
  func createBoard(completionHandler: (board: Board?) -> ()) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    if let image = image {
      uploadImage(image) { mediaID in
        if let mediaID = mediaID {
          DataManager.sharedInstance.createBoardWithName(self.nameTextField.text, description: self.descripTextView.text, mediaID: mediaID) { error, result in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if let error = error {
              self.handleError(error)
              completionHandler(board: nil)
            } else {
              completionHandler(board: result)
            }
          }
        } else {
          UIApplication.sharedApplication().networkActivityIndicatorVisible = false
          completionHandler(board: nil)
        }
      }
    } else {
      DataManager.sharedInstance.createBoardWithName(nameTextField.text, description: descripTextView.text) { error, result in
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        if let error = error {
          self.handleError(error)
          completionHandler(board: nil)
        } else {
          completionHandler(board: result)
        }
      }
    }
  }
  
  /// Used to upload image to Cillo servers.
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: mediaID The id of the image uploaded to the Cillo servers.
  /// :param: * Nil if there was an error in the server call.
  func uploadImage(image: UIImage, completionHandler: (mediaID: Int?) -> ()) {
    let imageData = UIImageJPEGRepresentation(image, UIImage.JPEGCompression)
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    let activityIndicator = addActivityIndicatorToCenterWithText("Uploading Image...")
    DataManager.sharedInstance.uploadImageData(imageData) { error, result in
      activityIndicator.removeFromSuperview()
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      if let error = error {
        self.handleError(error)
        completionHandler(mediaID: nil)
      } else {
        completionHandler(mediaID: result)
      }
    }
  }
  
  // MARK: IBActions
  
  /// Expands the image displayed in the button to full screen.
  ///
  /// :param: sender The button that is touched to send this function is a `photoButton`.
  @IBAction func boardPhotoButtonPressed(sender: UIButton) {
    if let image = sender.backgroundImageForState(.Normal) {
      JTSImageViewController.expandImage(image, toFullScreenFromRoot: self, withSender: sender)
    }
  }
  
  /// Presents an AlertController with ActionSheet style that allows the user to choose a new profile picture.
  ///
  /// :param: sender The button that is touched to send this function is choosePictureButton
  @IBAction func imageButtonPressed(sender: UIButton) {
    UIImagePickerController.presentActionSheetForPhotoSelectionFromSource(self)
  }
  
  /// Creates a board. If the creation is successful, presents a BoardTableViewController and removes self from navigationController's stack.
  ///
  /// :param: sender The button that is touched to send this function is createBoardButton.
  @IBAction func triggerTabSegueOnButton(sender: UIButton) {
    sender.enabled = false
    createBoard { board in
      if let board = board {
        self.performSegueWithIdentifier(SegueIdentifiers.newBoardToTab, sender: board)
      } else {
        sender.enabled = true
      }
    }
  }
}

// MARK: - UIImagePickerControllerDelegate

extension NewBoardViewController: UIImagePickerControllerDelegate {
  
  /// Handles the instance in which an image was picked by a UIImagePickerController presented by this NewBoardViewController.
  ///
  /// :param: picker The UIImagePickerController presented by this NewBoardViewController.
  /// :param: info The dictionary containing the selected image's data.
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
      self.image = image
      photoButton.setBackgroundImage(image, forState: .Normal)
    }
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  /// Handles the instance in which the user cancels the selection of an image by a UIImagePickerController presented by this NewBoardViewController.
  ///
  /// :param: picker The UIImagePickerController presented by this NewBoardViewController.
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    dismissViewControllerAnimated(true, completion: nil)
  }
}

// MARK: - UINavigationControllerDelegate

// Required to implement UINavigationControllerDelegate in order to present UIImagePickerControllers.
extension NewBoardViewController: UINavigationControllerDelegate {
}
