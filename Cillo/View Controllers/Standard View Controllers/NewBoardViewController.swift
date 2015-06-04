//
//  NewBoardViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 1/7/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Handles creating new Boards.
class NewBoardViewController: CustomViewController {
  
  // MARK: Properties
  
  /// Stores the chosen photo to be uploaded as the Board's photo.
  var image: UIImage?

  // MARK: IBOutlets
  
  /// Button allowing end user to change their board photo.
  @IBOutlet weak var choosePictureButton: UIButton!
  
  /// Field for end user to enter the description of the new Board.
  @IBOutlet weak var descripTextView: PlaceholderTextView!
  
  /// Set to DescripTextViewHeight after viewDidLayoutSubviews().
  @IBOutlet weak var descripTextViewHeightConstraint: NSLayoutConstraint!
  
  /// Field for end user to enter the name of the new Board.
  @IBOutlet weak var nameTextField: CustomTextField!
  
  /// Button used to display the end user's selected board photo.
  @IBOutlet weak var pictureButton: UIButton!
  
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
  
  /// Sets up the colors of the Outlets according to the default scheme of the app.
  private func setupColorScheme() {
    let scheme = ColorScheme.defaultScheme
    choosePictureButton.tintColor = scheme.touchableTextColor()
    nameTextField.backgroundColor = scheme.textFieldBackgroundColor()
    descripTextView.backgroundColor = scheme.textFieldBackgroundColor()
  }
  
  /// Sets up the appearance of Outlets that were not set in the storyboard.
  private func setupOutletAppearances() {
    descripTextViewHeightConstraint.constant = descripTextViewHeight
    pictureButton.clipsToBounds = true
    pictureButton.layer.cornerRadius = 5.0
  }
  
  // MARK: Networking Helper Functions
  
  /// Used to create and retrieve a new Board made by the logged in User from Cillo servers.
  ///
  /// :param: mediaID The media id for the uploaded photo that resembles this board.
  /// :param: completion The completion block for the board creation.
  /// :param: board The new Board that was created from calling the servers.
  ///
  /// :param: * Nil if server call passed an error back.
  func createBoard(completion: (board: Board?) -> Void) {
    var descrip: String?
    if descripTextView.text != "" {
      descrip = descripTextView.text
    }
    let activityIndicator = addActivityIndicatorToCenterWithText("Creating Board...")
    if let image = image {
      uploadImage(image) { mediaID in
        if let mediaID = mediaID {
          DataManager.sharedInstance.createBoard(name: self.nameTextField.text, description: descrip, mediaID: mediaID) { error, result in
            activityIndicator.removeFromSuperview()
            if let error = error {
              println(error)
              error.showAlert()
              completion(board: nil)
            } else {
              completion(board: result!)
            }
          }
        } else {
          activityIndicator.removeFromSuperview()
          completion(board: nil)
        }
      }
    } else {
      DataManager.sharedInstance.createBoard(name: nameTextField.text, description: descrip, mediaID: nil) { error, result in
        activityIndicator.removeFromSuperview()
        if let error = error {
          println(error)
          error.showAlert()
          completion(board: nil)
        } else {
          completion(board: result!)
        }
      }
    }
  }
  
  /// Used to upload image to Cillo servers.
  ///
  /// :param: completion The completion block for the server call.
  /// :param: mediaID The id of the image uploaded to the Cillo servers.
  /// :param: * Nil if there was an error in the server call.
  func uploadImage(image: UIImage, completion: (mediaID: Int?) -> Void) {
    let imageData = UIImageJPEGRepresentation(image, UIImage.JPEGCompression)
    let activityIndicator = addActivityIndicatorToCenterWithText("Uploading Image...")
    DataManager.sharedInstance.imageUpload(imageData) { error, result in
      activityIndicator.removeFromSuperview()
      if let error = error {
        println(error)
        error.showAlert()
        completion(mediaID: nil)
      } else {
        completion(mediaID: result!)
      }
    }
  }
  
  // MARK: IBActions
  
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
    createBoard { board in
      if let board = board {
        self.performSegueWithIdentifier(SegueIdentifiers.newBoardToTab, sender: board)
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
      pictureButton.setBackgroundImage(image, forState: .Normal)
      pictureButton.setBackgroundImage(image, forState: .Highlighted)
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
