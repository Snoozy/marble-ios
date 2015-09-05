//
//  NewPostViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 1/6/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Handles creating new Posts.
class NewPostViewController: CustomViewController {

  // MARK: Properties
  
  /// Board that this new Post will be posted to.
  ///
  /// Set this property to pass a board name to this UIViewController from another UIViewController.
  var board: Board?
  
  /// Stores the chosen image for this post, if the post is an image post.
  var image: UIImage?
 
  /// Displays a scrollable image to fit `image` on the screen.
  ///
  /// Setup in viewDidAppear(_:) to reload each time a new picture is selected via an ImagePickerController.
  var scrollView: UIScrollView?
  
  // MARK: IBOutlets
  
  /// Button that presents a popup for the end user to select a board to post their new post on.
  @IBOutlet weak var selectBoardButton: UIButton!
  
  /// Button that displays the board photo after the user has selected a board to post on.
  @IBOutlet weak var boardPhotoButton: UIButton!
  
  /// Set to boardPhotoWidth after the user has selected a board
  @IBOutlet weak var boardPhotoButtonWidthConstraint: NSLayoutConstraint!
  
  /// 1px view that divides the select board section with the add image section.
  @IBOutlet weak var boardToImageDividerView: UIView!
  
  /// Button allowing end user to pick an image for their post.
  @IBOutlet weak var imageButton: UIButton!
  
  /// Field for end user to enter the text of their post.
  @IBOutlet weak var postTextView: BottomBorderedTextView!
  
  /// Set to postTextViewHeight after viewDidLayoutSubviews().
  @IBOutlet weak var postTextViewHeightConstraint: NSLayoutConstraint!
  
  /// Field for end user to enter the title of their post.
  @IBOutlet weak var titleTextField: BottomBorderedTextField!
  
  /// Button used to display the end user's profile picture.
  @IBOutlet weak var userPhotoButton: UIButton!
  
  /// Label used to display the end user's name.
  @IBOutlet weak var usernameLabel: UILabel!
  
  // MARK: Constants
  
  /// Width of a board photo after a board has been selected.
  let boardPhotoWidth = CGFloat(40.0)
  
  // FIXME: Implement this with notification center to get keyboard height correctly
  
  /// Calculated height of postTextView based on frame size of device.
  var postTextViewHeight: CGFloat {
    return view.frame.height - UITextView.keyboardHeight - NewPostViewController.vertSpaceExcludingPostTextView
  }
  
  /// Height needed for all components of a NewPostViewController excluding postTextView in the Storyboard.
  ///
  /// **Note:** Height of postTextView must be calculated based on the frame size of the device.
  class var vertSpaceExcludingPostTextView: CGFloat {
   return 246
  }
  
  // MARK: UIViewController
  
  /// Handles passing of data when navigation between UIViewControllers occur.
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == SegueIdentifiers.newPostToTab {
      var destination = segue.destinationViewController as! TabViewController
      resignTextFieldResponders()
      if let sender = sender as? Post {
        let postViewController = self.storyboard!.instantiateViewControllerWithIdentifier(StoryboardIdentifiers.post) as! PostTableViewController
        if let nav = destination.selectedViewController as? UINavigationController {
          postViewController.post = sender
          nav.pushViewController(postViewController, animated: true)
        }
      }
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    setupScrollView()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupColorScheme()
    setupOutletAppearances()
    setupOutletDelegates()
  }
  
  // MARK: Setup Helper Functions
  
  /// Presents a popup overlay allowing the end user to select a board from the list of boards that they are following.
  func presentOverlay() {
    resignTextFieldResponders()
    let overlayView = SelectBoardOverlayView(frame: view.frame)
    overlayView.delegate = self
    overlayView.animateInto(view)
  }
  
  /// Hides the keyboard of all textfields.
  private func resignTextFieldResponders() {
    postTextView.resignFirstResponder()
    titleTextField.resignFirstResponder()
  }
  
  /// Sets up the colors of the Outlets according to the default scheme of the app.
  private func setupColorScheme() {
    let scheme = ColorScheme.defaultScheme
    imageButton.setTitleColor(scheme.touchableTextColor(), forState: .Normal)
    imageButton.backgroundColor = scheme.solidButtonBackgroundColor()
    selectBoardButton.setTitleColor(scheme.touchableTextColor(), forState: .Normal)
    titleTextField.backgroundColor = scheme.bottomBorderedTextFieldBackgroundColor()
    postTextView.backgroundColor = scheme.bottomBorderedTextFieldBackgroundColor()
    boardToImageDividerView.backgroundColor = scheme.thinLineBackgroundColor()
  }
  
  /// Sets up the appearance of Outlets that were not set in the storyboard.
  private func setupOutletAppearances() {
    postTextViewHeightConstraint.constant = postTextViewHeight
    if let board = board where board.following {
      selectBoardButton.setTitle(board.name, forState: .Normal)
      boardPhotoButton.setBackgroundImageToImageWithURL(board.photoURL, forState: .Normal)
      boardPhotoButtonWidthConstraint.constant = boardPhotoWidth
    }
    boardPhotoButton.clipsToBounds = true
    boardPhotoButton.layer.cornerRadius = 5.0
    retrieveEndUser { user in
      if let user = user {
        self.userPhotoButton.clipsToBounds = true
        self.userPhotoButton.layer.cornerRadius = 5.0
        self.userPhotoButton.setBackgroundImageToImageWithURL(user.photoURL, forState: .Normal)
        self.usernameLabel.text = user.name
      }
    }
  }
  
  /// Sets any delegates of Outlets that were not set in the storyboard.
  private func setupOutletDelegates() {
    titleTextField.delegate = self
  }
  
  /// Sets up the scrollView to display a scrollable representaiton of image.
  private func setupScrollView() {
    if let image = image {
      scrollView?.removeFromSuperview()
      var height = imageButton.frame.width * image.size.height / image.size.width
      scrollView = UIScrollView(frame: CGRect(x: imageButton.frame.minX, y: imageButton.frame.minY, width: imageButton.frame.width, height: UITextView.keyboardHeight))
      view.addSubview(scrollView!)
      scrollView!.contentSize = CGSize(width: imageButton.frame.size.width, height: height)
      let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: scrollView!.contentSize.width, height: scrollView!.contentSize.height))
      scrollView!.addSubview(imageView)
      imageView.image = image
      imageView.contentMode = .ScaleAspectFill
      view.bringSubviewToFront(imageButton)
      imageButton.setTitle("Choose New Image", forState: .Normal)
      imageButton.alpha = 0.5
    }
  }
  
  // MARK: Networking Helper Functions
  
  /// Used to create and retrieve a new Post made by the end user from Cillo servers.
  ///
  /// :param: completionHandler The completion block for the post creation.
  /// :param: post The new Post that was created from calling the servers.
  ///
  /// :param: * Nil if server call passed an error back.
  func createPost(completionHandler: (post: Post?) -> ()) {
    if let board = selectBoardButton.titleForState(.Normal) where board != "Select Board" {
      if let image = image {
        uploadImage(image) { mediaID in
          if let mediaID = mediaID {
            DataManager.sharedInstance.createPostByBoardName(board, text: self.postTextView.text, title: self.titleTextField.text, mediaID: mediaID) { error, result in
              if let error = error {
                self.handleError(error)
                completionHandler(post: nil)
              } else {
                completionHandler(post: result)
              }
            }
          } else {
            completionHandler(post: nil)
          }
        }
      } else {
        DataManager.sharedInstance.createPostByBoardName(board, text: postTextView.text, title: self.titleTextField.text) { error, result in
          if let error = error {
            self.handleError(error)
            completionHandler(post: nil)
          } else {
            completionHandler(post: result)
          }
        }
      }
    } else {
      UIAlertView(title: "Error", message: "Please select a board.", delegate: nil, cancelButtonTitle: "Ok").show()
    }
  }
  
  /// Retrieves the end user's info from the Cillo Servers.
  ///
  /// :param: completionHandler The completion block for the request.
  /// :param: user The end user's info.
  /// :param: * Nil if an error occurred in the server call.
  func retrieveEndUser(completionHandler: (user: User?) -> ()) {
    DataManager.sharedInstance.getEndUserInfo { error, result in
      if let error = error {
        self.handleError(error)
        completionHandler(user: nil)
      } else {
        completionHandler(user: result)
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
    let activityIndicator = addActivityIndicatorToCenterWithText("Uploading Image...")
    DataManager.sharedInstance.uploadImageData(imageData) { error, result in
      activityIndicator.removeFromSuperview()
      if let error = error {
        self.handleError(error)
        completionHandler(mediaID: nil)
      } else {
        completionHandler(mediaID: result)
      }
    }
  }
  
  // MARK: IBActions
  
  /// Presents an AlertController with ActionSheet style that allows the user to choose an image for their post.
  ///
  /// :param: sender The button that is touched to send this function is imageButton.
  @IBAction func imageButtonPressed(sender: UIButton) {
    UIImagePickerController.presentActionSheetForPhotoSelectionFromSource(self, withTitle: "Select Image", iPadReference: sender)
  }
  
  /// Presents a popup overlay table to select a board to post on when a button is pressed.
  ///
  /// :param: sender The button that is touched to send this function is selecctBoardButton.
  @IBAction func selectBoardPressed(sender: UIButton) {
    presentOverlay()
  }
  
  /// Creates a post. If the creation is successful, presents a PostTableViewController and removes self from navigationController's stack.
  ///
  /// :param: sender The bar button item that says Create.
  @IBAction func triggerTabSegueOnButton(sender: UIButton) {
    sender.enabled = false
    createPost { post in
      if let post = post {
        self.performSegueWithIdentifier(SegueIdentifiers.newPostToTab, sender: post)
      } else {
        sender.enabled = true
      }
    }
  }
  
  /// Expands the image displayed in the button to full screen.
  ///
  /// :param: sender The button that is touched to send this function is a `photoButton`.
  @IBAction func userPhotoButtonPressed(sender: UIButton) {
    if let image = sender.backgroundImageForState(.Normal) {
      JTSImageViewController.expandImage(image, toFullScreenFromRoot: self, withSender: sender)
    }
  }
  
}

// MARK: - UIImagePickerControllerDelegate

extension NewPostViewController: UIImagePickerControllerDelegate {
  
  /// Handles the instance in which an image was picked by a UIImagePickerController presented by this NewPostViewController.
  ///
  /// :param: picker The UIImagePickerController presented by this NewPostViewController.
  /// :param: info The dictionary containing the selected image's data.
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
      self.image = image
    }
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  /// Handles the instance in which the user cancels the selection of an image by a UIImagePickerController presented by this NewPostViewController.
  ///
  /// :param: picker The UIImagePickerController presented by this NewPostViewController.
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    dismissViewControllerAnimated(true, completion: nil)
  }
}

// MARK: - UINavigationControllerDelegate

// Required to implement UINavigationControllerDelegate in order to present UIImagePickerControllers.
extension NewPostViewController: UINavigationControllerDelegate {
}

// MARK: - UIActionSheetDelegate

extension NewPostViewController: UIActionSheetDelegate {
  
  func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
    UIImagePickerController.defaultActionSheetDelegateImplementationForSource(self, withSelectedIndex: buttonIndex)
  }
}

// MARK: - SelectBoardOverlayViewDelegate

extension NewPostViewController: SelectBoardOverlayViewDelegate {
  
  /// Called when a board is selected on a popup overlay.
  ///
  /// :param: overlay The overlay that the board was selected from.
  /// :param: board THe board that was selected.
  func overlay(overlay: SelectBoardOverlayView, selectedBoard board: Board) {
    overlay.animateOut()
    selectBoardButton.setTitle(board.name, forState: .Normal)
    boardPhotoButton.setBackgroundImageToImageWithURL(board.photoURL, forState: .Normal)
    boardPhotoButtonWidthConstraint.constant = boardPhotoWidth
  }
  
  
  /// Called when a popup overlay is dismissed
  ///
  /// :param: overlay The overlay that was dismissed.
  func overlayDismissed(overlay: SelectBoardOverlayView) {
    overlay.animateOut()
  }
}
