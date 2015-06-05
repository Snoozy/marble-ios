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
  
  /// Field for end user to enter the name of the Board that they want to post this post to.
  ///
  /// **Note:** Text is automatically set if board is not nil.
  @IBOutlet weak var boardTextField: CustomTextField!
  
  /// Button allowing end user to pick an image for their post.
  @IBOutlet weak var imageButton: UIButton!
  
  /// Field for end user to enter the text of their post.
  @IBOutlet weak var postTextView: PlaceholderTextView!
  
  /// Set to PostTextViewHeight after viewDidLayoutSubviews().
  @IBOutlet weak var postTextViewHeightConstraint: NSLayoutConstraint!
  
  /// Field for end user to enter the title of their post.
  @IBOutlet weak var titleTextField: CustomTextField!
  
  /// ImageView used to display the end user's profile picture.
  @IBOutlet weak var userImageView: UIImageView!
  
  /// Label used to display the end user's name.
  @IBOutlet weak var usernameLabel: UILabel!
  
  // MARK: Constants
  
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
      if let sender = sender as? Post {
        let postViewController = self.storyboard!.instantiateViewControllerWithIdentifier(StoryboardIdentifiers.post) as! PostTableViewController
        if let nav = destination.selectedViewController as? UINavigationController {
          postViewController.post = sender
          if image != nil {
            sender.showImages = true
          }
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
  
  /// Sets up the colors of the Outlets according to the default scheme of the app.
  private func setupColorScheme() {
    let scheme = ColorScheme.defaultScheme
    imageButton.setTitleColor(scheme.solidButtonTextColor(), forState: .Normal)
    imageButton.backgroundColor = scheme.solidButtonBackgroundColor()
    boardTextField.backgroundColor = scheme.textFieldBackgroundColor()
    titleTextField.backgroundColor = scheme.textFieldBackgroundColor()
    postTextView.backgroundColor = scheme.textFieldBackgroundColor()
  }
  
  /// Sets up the appearance of Outlets that were not set in the storyboard.
  private func setupOutletAppearances() {
    postTextViewHeightConstraint.constant = postTextViewHeight
    if let board = board {
      boardTextField.text = board.name
    }
    retrieveUser { user in
      if let user = user {
        self.userImageView.clipsToBounds = true
        self.userImageView.layer.cornerRadius = 5.0
        self.userImageView.setImageWithURL(user.profilePicURL)
        self.usernameLabel.text = user.name
      }
    }
  }
  
  /// Sets any delegates of Outlets that were not set in the storyboard.
  private func setupOutletDelegates() {
    boardTextField.delegate = self
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
  
  /// Used to create and retrieve a new Post made by the logged in User from Cillo servers.
  ///
  /// :param: completion The completion block for the post creation.
  /// :param: post The new Post that was created from calling the servers.
  ///
  /// :param: * Nil if server call passed an error back.
  func createPost(completion: (post: Post?) -> Void) {
    var title: String?
    if titleTextField.text != "" {
      title = titleTextField.text
    }
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    if let image = image {
      uploadImage(image) { mediaID in
        if let mediaID = mediaID {
          DataManager.sharedInstance.createPostByBoardName(self.boardTextField.text, repostID: nil, text: self.postTextView.text, title: title, mediaID: mediaID) { error, result in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if let error = error {
              println(error)
              error.showAlert()
              completion(post: nil)
            } else {
              completion(post: result!)
            }
          }
        } else {
          UIApplication.sharedApplication().networkActivityIndicatorVisible = false
          completion(post: nil)
        }
      }
    } else {
      DataManager.sharedInstance.createPostByBoardName(boardTextField.text, repostID: nil, text: postTextView.text, title: title, mediaID: nil) { error, result in
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        if let error = error {
          println(error)
          error.showAlert()
          completion(post: nil)
        } else {
          completion(post: result!)
        }
      }
    }
  }
  
  /// Retrieves the end user's info from the Cillo Servers.
  ///
  /// :param: completion The completion block for the request.
  /// :param: user The end user's info.
  /// :param: * Nil if an error occurred in the server call.
  func retrieveUser(completion: (user: User?) -> Void) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    DataManager.sharedInstance.getSelfInfo { error, result in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      if let error = error {
        println(error)
        error.showAlert()
        completion(user: nil)
      } else {
        completion(user: result!)
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
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    let activityIndicator = addActivityIndicatorToCenterWithText("Uploading Image...")
    DataManager.sharedInstance.imageUpload(imageData) { error, result in
      activityIndicator.removeFromSuperview()
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
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
  
  /// Presents an AlertController with ActionSheet style that allows the user to choose an image for their post.
  ///
  /// :param: sender The button that is touched to send this function is imageButton.
  @IBAction func imageButtonPressed(sender: UIButton) {
    UIImagePickerController.presentActionSheetForPhotoSelectionFromSource(self)
  }
  
  /// Creates a post. If the creation is successful, presents a PostTableViewController and removes self from navigationController's stack.
  ///
  /// :param: sender The bar button item that says Create.
  @IBAction func triggerTabSegueOnButton(sender: UIButton) {
    createPost { post in
      if let post = post {
        self.performSegueWithIdentifier(SegueIdentifiers.newPostToTab, sender: post)
      }
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
