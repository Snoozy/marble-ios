//
//  NewPostViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 1/6/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Handles creating new Posts.
class NewPostViewController: UIViewController {

  // MARK: Properties
  
  /// Group that this new Post will be posted to.
  ///
  /// Set this property to pass a group name to this UIViewController from another UIViewController.
  var group: Group?
  
  var image: UIImage?
  
  var scrollView: UIScrollView?
  
  // MARK: IBOutlets
  
  /// Allows logged in User to enter the group name that he/she wants to post the new Post to.
  ///
  /// **Note:** Text is automatically set if group is not nil.
  @IBOutlet weak var groupTextField: UITextField!
  
  /// Allows logged in User to enter a title to his/her new Post.
  @IBOutlet weak var titleTextField: UITextField!
  
  /// Allows logged in User to enter text for his/her new Post.
  @IBOutlet weak var postTextView: UITextView!
  
  /// Set to PostTextViewHeight after viewDidLayoutSubviews().
  @IBOutlet weak var postTextViewHeightConstraint: NSLayoutConstraint!

  /// Button used to create the new Post.
  @IBOutlet weak var createPostButton: UIBarButtonItem!
  
  @IBOutlet weak var fakeNavigationBar: UINavigationBar!
  
  @IBOutlet weak var imageButton: UIButton!
  
  @IBOutlet weak var imageButtonHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var userImageView: UIImageView!
  
  @IBOutlet weak var usernameLabel: UILabel!
  
  // MARK: Constants
  
  /// Height needed for all components of a NewPostViewController excluding postTextView in the Storyboard.
  ///
  /// **Note:** Height of postTextView must be calculated based on the frame size of the device.
  class var VertSpaceExcludingPostTextView: CGFloat {
    get {
      return 230
    }
  }
  
  /// Calculated height of postTextView based on frame size of device.
  var PostTextViewHeight: CGFloat {
    get {
      return view.frame.height - UITextView.KeyboardHeight - NewPostViewController.VertSpaceExcludingPostTextView
    }
  }
  
  /// Segue Identifier in Storyboard for this UIViewController to PostTableViewController.
  var SegueIdentifierThisToTab: String {
    get {
      return "NewPostToTab"
    }
  }
  
  // MARK: UIViewController
  
  /// Resizes postTextView so the keyboard won't overlap any UI elements and sets the group name in groupTextView if a group was passed tot his UIViewController.
  override func viewDidLoad() {
    postTextViewHeightConstraint.constant = PostTextViewHeight
    if let group = group {
      groupTextField.text = group.name
    }
    imageButton.tintColor = UIColor.whiteColor()
    imageButton.backgroundColor = UIColor.cilloBlue()
    fakeNavigationBar.barTintColor = UIColor.cilloBlue()
    retrieveUser( { (user) in
      if user != nil {
        self.userImageView.setImageWithURL(user!.profilePicURL)
        self.usernameLabel.text = user!.name
      }
    })
  }
  
  override func viewDidAppear(animated: Bool) {
    if let image = image {
      scrollView?.removeFromSuperview()
      var height = imageButton.frame.width * image.size.height / image.size.width
      scrollView = UIScrollView(frame: CGRect(x: imageButton.frame.minX, y: imageButton.frame.minY, width: imageButton.frame.width, height: UITextView.KeyboardHeight))
      view.addSubview(scrollView!)
      scrollView!.contentSize = CGSize(width: imageButton.frame.size.width, height: height)
      let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: scrollView!.contentSize.width, height: scrollView!.contentSize.height))
      scrollView!.addSubview(imageView)
      imageView.image = image
      imageView.contentMode = .ScaleAspectFit
      view.bringSubviewToFront(imageButton)
      imageButton.setTitle("Choose New Image", forState: .Normal)
      imageButton.setTitle("Choose New Image", forState: .Highlighted)
      imageButton.alpha = 0.5
    }
  }
  
  /// Handles passing of data when navigation between UIViewControllers occur.
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == SegueIdentifierThisToTab {
      var destination = segue.destinationViewController as! TabViewController
      if let sender = sender as? Post {
        let postViewController = self.storyboard!.instantiateViewControllerWithIdentifier("Post") as! PostTableViewController
        if let nav = destination.selectedViewController as? UINavigationController {
          postViewController.post = sender
          nav.pushViewController(postViewController, animated: true)
        }
      }
    }
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
  // MARK: Helper Functions
  
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
    let activityIndicator = addActivityIndicatorToCenterWithText("Creating Post...")
    if let image = image {
      DataManager.sharedInstance.imageUpload(UIImageJPEGRepresentation(image, 0.5), completion: { (error, mediaID) in
        if error != nil {
          activityIndicator.removeFromSuperview()
          println(error!)
          error!.showAlert()
          completion(post: nil)
        } else {
          DataManager.sharedInstance.createPostByGroupName(self.groupTextField.text, repostID: nil, text: self.postTextView.text, title: title, mediaID: mediaID, completion: { (error, result) in
            activityIndicator.removeFromSuperview()
            if error != nil {
              println(error!)
              error!.showAlert()
              completion(post: nil)
            } else {
              completion(post: result!)
            }
          })
        }
      })
    } else {
      DataManager.sharedInstance.createPostByGroupName(groupTextField.text, repostID: nil, text: postTextView.text, title: title, mediaID: nil, completion: { (error, result) -> Void in
        activityIndicator.removeFromSuperview()
        if error != nil {
          println(error!)
          error!.showAlert()
          completion(post: nil)
        } else {
          completion(post: result!)
        }
      })
    }
  }
  
  func retrieveUser(completion: (user: User?) -> Void) {
    let activityIndicator = addActivityIndicatorToCenterWithText("Retrieving User...")
    DataManager.sharedInstance.getSelfInfo( { (error, result) -> Void in
      activityIndicator.removeFromSuperview()
      if error != nil {
        println(error!)
        error!.showAlert()
        completion(user: nil)
      } else {
        completion(user: result!)
      }
    })
  }
  
  // MARK: IBActions
  
  /// Creates a post. If the creation is successful, presents a PostTableViewController and removes self from navigationController's stack.
  ///
  /// :param: sender The button that is touched to send this function is createPostButton.
  @IBAction func triggerTabSegueOnButton(sender: UIButton) {
    createPost( { (post) -> Void in
      if let post = post {
        self.performSegueWithIdentifier(self.SegueIdentifierThisToTab, sender: post)
      }
    })
  }
  
  @IBAction func imageButtonPressed(sender: UIButton) {
    let actionSheet = UIAlertController(title: "Change Profile Picture", message: nil, preferredStyle: .ActionSheet)
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
    })
    let pickerAction = UIAlertAction(title: "Choose Photo from Library", style: .Default, handler:  { (action) in
      let pickerController = UIImagePickerController()
      pickerController.delegate = self
      self.presentViewController(pickerController, animated: true, completion: nil)
    })
    let cameraAction = UIAlertAction(title: "Take Photo", style: .Default, handler: { (action) in
      // TODO: Camera picker
    })
    actionSheet.addAction(cancelAction)
    actionSheet.addAction(pickerAction)
    actionSheet.addAction(cameraAction)
    presentViewController(actionSheet, animated: true, completion: nil)
  }
  
}

extension NewPostViewController: UIImagePickerControllerDelegate {
  // MARK: UIImagePickerControllerDelegate
  
  /// Handles the instance in which an image was picked by a UIImagePickerController presented by this MeTableViewController.
  ///
  /// :param: picker The UIImagePickerController presented by this MeTableViewController.
  /// :param: info The dictionary containing the selected image's data.
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
      self.image = image
    }
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  /// Handles the instance in which the user cancels the selection of an image by a UIImagePickerController presented by this MeTableViewController.
  ///
  /// :param: picker The UIImagePickerController presented by this MeTableViewController.
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
}

// Required to implement UINavigationControllerDelegate in order to present UIImagePickerControllers.
extension NewPostViewController: UINavigationControllerDelegate {
  
  // MARK: UINavigationControllerDelegate
  
}

extension NewPostViewController: UIBarPositioningDelegate {
  func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
    return .TopAttached
  }
}
