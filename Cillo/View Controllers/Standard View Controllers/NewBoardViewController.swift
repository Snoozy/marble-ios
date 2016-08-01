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
  @IBOutlet weak var choosePhotoButton: UIButton!
  
  /// Field for end user to enter the description of the new Board.
  @IBOutlet weak var descripTextView: BottomBorderedTextView!
  
  /// Set to DescripTextViewHeight after viewDidLayoutSubviews().
  @IBOutlet weak var descripTextViewHeightConstraint: NSLayoutConstraint!
  
  /// Field for end user to enter the name of the new Board.
  @IBOutlet weak var nameTextField: BottomBorderedTextField!
  
  /// 1px view that divides the choose photo section with the name section.
  @IBOutlet weak var photoToNameDividerView: UIView!
  
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
  
  override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == SegueIdentifiers.newBoardToTab {
      let destination = segue.destination as! TabViewController
      resignTextFieldResponders()
      if let sender = sender as? Board, navController = destination.selectedViewController as? UINavigationController {
        let boardViewController = self.storyboard!.instantiateViewController(withIdentifier: StoryboardIdentifiers.board) as! BoardTableViewController
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
  
  // MARK: UIResponder 
  
  override func touchesBegan(_ touches: Set<NSObject>, with event: UIEvent) {
    if descripTextView.isFirstResponder {
      descripTextView.resignFirstResponder()
    } else if nameTextField.isFirstResponder {
      nameTextField.resignFirstResponder()
    }
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
    nameTextField.backgroundColor = scheme.bottomBorderedTextFieldBackgroundColor()
    descripTextView.backgroundColor = scheme.bottomBorderedTextFieldBackgroundColor()
    photoToNameDividerView.backgroundColor = scheme.thinLineBackgroundColor()
  }
  
  /// Sets up the appearance of Outlets that were not set in the storyboard.
  private func setupOutletAppearances() {
    descripTextViewHeightConstraint.constant = descripTextViewHeight < 100 ? 100 : descripTextViewHeight
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
  func createBoard(_ completionHandler: (board: Board?) -> ()) {
    if let image = image {
      uploadImage(image) { mediaID in
        if let mediaID = mediaID {
          DataManager.sharedInstance.createBoardWithName(self.nameTextField.text, description: self.descripTextView.text, mediaID: mediaID) { result in
            self.handleSingleElementResponse(result, completionHandler: completionHandler)
          }
        } else {
          completionHandler(board: nil)
        }
      }
    } else {
      DataManager.sharedInstance.createBoardWithName(nameTextField.text, description: descripTextView.text) { result in
        self.handleSingleElementResponse(result, completionHandler: completionHandler)
      }
    }
  }
  
  /// Used to upload image to Cillo servers.
  ///
  /// :param: completionHandler The completion block for the server call.
  /// :param: mediaID The id of the image uploaded to the Cillo servers.
  /// :param: * Nil if there was an error in the server call.
  func uploadImage(_ image: UIImage, completionHandler: (mediaID: Int?) -> ()) {
    let imageData = UIImageJPEGRepresentation(image, UIImage.JPEGCompression)
    let activityIndicator = addActivityIndicatorToCenterWithText("Uploading Image...")
    DataManager.sharedInstance.uploadImageData(imageData) { result in
      activityIndicator.removeFromSuperview()
      self.handleSingleElementResponse(result, completionHandler: completionHandler)
    }
  }
  
  // MARK: Error Handling Helper Functions
  
  override func handleBoardNameInvalidError(_ error: NSError) {
    if objc_getClass("UIAlertController") != nil {
      let alert = UIAlertController(title: "Error", message: "Board Name Unavailable.\n Note: Board Names cannot contain spaces.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Ok", style: .cancel) { _ in
        })
      present(alert, animated: true, completion: nil)
    } else {
      let alert = UIAlertView(title: "Error", message: "Board Name Unavailable.\n Note: Board Names cannot contain spaces.", delegate: nil, cancelButtonTitle: "Ok")
      alert.show()
    }
    
  }
  
  // MARK: IBActions
  
  /// Expands the image displayed in the button to full screen.
  ///
  /// :param: sender The button that is touched to send this function is a `photoButton`.
  @IBAction func boardPhotoButtonPressed(_ sender: UIButton) {
    if let image = sender.backgroundImage(for: UIControlState()) {
      JTSImageViewController.expandImage(image, toFullScreenFromRoot: self, withSender: sender)
    }
  }
  
  /// Presents an AlertController with ActionSheet style that allows the user to choose a new profile picture.
  ///
  /// :param: sender The button that is touched to send this function is choosePictureButton
  @IBAction func imageButtonPressed(_ sender: UIButton) {
    UIImagePickerController.presentActionSheetForPhotoSelectionFromSource(self, withTitle: "Select Board Photo", iPadReference: sender)
  }
  
  /// Creates a board. If the creation is successful, presents a BoardTableViewController and removes self from navigationController's stack.
  ///
  /// :param: sender The button that is touched to send this function is createBoardButton.
  @IBAction func triggerTabSegueOnButton(_ sender: UIButton) {
    sender.isEnabled = false
    createBoard { board in
      if let board = board {
        self.performSegue(withIdentifier: SegueIdentifiers.newBoardToTab, sender: board)
      } else {
        sender.isEnabled = true
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
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
      self.image = image
      photoButton.setBackgroundImage(image, for: UIControlState())
    }
    dismiss(animated: true, completion: nil)
  }
  
  /// Handles the instance in which the user cancels the selection of an image by a UIImagePickerController presented by this NewBoardViewController.
  ///
  /// :param: picker The UIImagePickerController presented by this NewBoardViewController.
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
}

// MARK: - UINavigationControllerDelegate

// Required to implement UINavigationControllerDelegate in order to present UIImagePickerControllers.
extension NewBoardViewController: UINavigationControllerDelegate {
}

// MARK: - UIActionSheetDelegate

extension NewBoardViewController: UIActionSheetDelegate {
  
  func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
    UIImagePickerController.defaultActionSheetDelegateImplementationForSource(self, withSelectedIndex: buttonIndex)
  }
}
