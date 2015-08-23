//
//  NewRepostViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 4/5/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Handles reposting of existing posts.
class NewRepostViewController: CustomViewController {

  // MARK: Properties
  
  /// The instance of the layout helper. This is needed because scrollView layout gets funky with autolayout.
  var contentView: RepostContentView?
  
  /// The original post that will be reposted.
  var postToRepost: Post = Post()
  
  /// The scrollView used to display all the contents of this ViewController.
  var scrollView: UIScrollView!
  
  // MARK: UIViewController
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if contentView == nil {
      contentView = RepostContentView(post: postToRepost, width: view.frame.width)
      setupUserInfoInContentView()
      setupScrollView()
      setupUIDelegates()
      setupButtonSelectors()
      contentView!.setupColorScheme()
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == SegueIdentifiers.newRepostToTab {
      var destination = segue.destinationViewController as! TabViewController
      if let sender = sender as? Post, navController = destination.selectedViewController as? UINavigationController {
        let postViewController = self.storyboard!.instantiateViewControllerWithIdentifier(StoryboardIdentifiers.post) as! PostTableViewController
        postViewController.post = sender
        navController.pushViewController(postViewController, animated: true)
      }
    }
  }
  
  // MARK: Setup Helper Functions
  
  /// Hides the keyboard of all textfields.
  private func resignTextFieldResponders() {
    if let contentView = contentView {
      contentView.boardTextField.resignFirstResponder()
      contentView.saySomethingTextView.resignFirstResponder()
    }
  }
  
  /// Sets the buttons to have image expanding events on touch
  private func setupButtonSelectors() {
    contentView?.pictureButton.addTarget(self, action: "photoButtonPressed:", forControlEvents: .TouchUpInside)
    contentView?.originalPictureButton.addTarget(self, action: "photoButtonPressed:", forControlEvents: .TouchUpInside)
    contentView?.originalPostImagesButton.addTarget(self, action: "photoButtonPressed:", forControlEvents: .TouchUpInside)
  }
  
  /// Sets the user related fields of the contentView.
  private func setupUserInfoInContentView() {
    retrieveEndUser { (user) in
      if let user = user {
        self.contentView?.pictureButton.setBackgroundImageToImageWithURL(user.photoURL, forState: .Normal)
        self.contentView?.usernameLabel.text = user.name
      }
    }
  }
  
  /// Sets up the scrollView to contain the contentView.
  private func setupScrollView() {
    if let contentView = contentView {
      let scrollViewHeight: CGFloat = {
        if contentView.frame.height > self.view.frame.height - self.imitationNavigationBar.frame.maxY {
          return self.view.frame.height - self.imitationNavigationBar.frame.maxY
        } else {
          return contentView.frame.height
        }
      }()
      scrollView = UIScrollView(frame: CGRect(x: 0, y: imitationNavigationBar.frame.maxY, width: view.frame.width, height: scrollViewHeight))
      scrollView.contentSize = contentView.frame.size
      view.addSubview(scrollView)
      scrollView.addSubview(contentView)
    }
  }
  
  /// Sets the delegates of the items in the contentView.
  private func setupUIDelegates() {
    contentView?.boardTextField.delegate = self
  }
  
  // MARK: Networking Helper Functions
  
  /// Reposts the post represented by the contentView to the Cillo Servers.
  ///
  /// :param: completionHandler The completion block for this server call.
  /// :param: post The repost after the server call.
  /// :param: * Nil if the server call was unsuccessful.
  func repostPost(completionHandler: (post: Post?) -> ()) {
    if let contentView = contentView {
      DataManager.sharedInstance.createPostByBoardName(contentView.boardTextField.text, text: contentView.saySomethingTextView.text, repostID: postToRepost.postID) { error, result in
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
  
  // MARK: Button Selectors
  
  /// Expands the image displayed in the button to full screen.
  ///
  /// :param: sender The button that is touched to send this function is a `photoButton`.
  func photoButtonPressed(sender: UIButton) {
    if let image = sender.backgroundImageForState(.Normal) {
      JTSImageViewController.expandImage(image, toFullScreenFromRoot: self, withSender: sender)
    }
  }
  
  
  // MARK: IBActions
  
  /// Reposts the post represented on the screen, and if successful, unwinds to the Tab Bar.
  ///
  /// :param: sender The bar button item that says Create.
  @IBAction func repostButtonPressed(sender: UIButton) {
    sender.enabled = false
    repostPost { post in
      if let post = post {
        self.performSegueWithIdentifier(SegueIdentifiers.newRepostToTab, sender: post)
      } else {
        sender.enabled = true
      }
    }
  }
}

// MARK: - Content View Layout Helper Class

/// This class is used to get around the weird autolayout behavior of UIScrollView. All content of NewRepostViewController is displayed on screen through this contentView.
class RepostContentView: UIView {
  
  // MARK: Properties
  
  /// Field for the end user to enter the board that they want to repost the post to.
  var boardTextField: CustomTextField!
  
  /// Label used to display the board of the original post.
  var originalBoardLabel: UILabel!
  
  /// Button used to display the profile picture of the user that posted the original post.
  var originalPictureButton: UIButton!
  
  /// Button used to display any images in the original post.
  var originalPostImagesButton: UIButton!
  
  /// View used to display the text of the original post.
  var originalPostTextView: UITextView!
  
  /// Label used to display the title of the original post.
  var originalTitleLabel: UILabel!
  
  /// Label used to display the name of the user that posted the original post.
  var originalUsernameLabel: UILabel!
  
  /// Button used to display the profile picture of the end user.
  var pictureButton: UIButton!
  
  /// Field for the end user to say something about the post that they are reposting.
  var saySomethingTextView: PlaceholderTextView!
  
  /// Button used to display the name of the end user.
  var usernameLabel: UILabel!
  
  // MARK: Initializers
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  /// Populates the contentView with all the User Interface elements depending on the original post provided.
  ///
  /// :param: post The original post that is supposed to be reposted.
  /// :param: width The width of the screen.
  init(var post: Post, width: CGFloat) {
    if let repost = (post as? Repost)?.originalPost {
      post = repost
    }
    let textEntryBackground = ColorScheme.defaultScheme.textFieldBackgroundColor()
    
    boardTextField = CustomTextField(frame: CGRect(x: 8, y: 8, width: width - 16, height: 40))
    boardTextField.placeholder = "Board"
    boardTextField.backgroundColor = textEntryBackground
    boardTextField.font = UIFont.systemFontOfSize(16)
    boardTextField.spellCheckingType = .No
    boardTextField.autocorrectionType = .No
    
    pictureButton = UIButton(frame: CGRect(x: 8, y: 56, width: 40, height: 40))
    pictureButton.clipsToBounds = true
    pictureButton.layer.cornerRadius = 5.0
    
    usernameLabel = UILabel(frame: CGRect(x: pictureButton.frame.maxX + 8, y: 65, width: width - pictureButton.frame.width - 24, height: 21))
    usernameLabel.font = UIFont.boldSystemFontOfSize(17)
    
    saySomethingTextView = PlaceholderTextView(frame: CGRect(x: 8, y: pictureButton.frame.maxY + 8, width: width - 16, height: 60))
    saySomethingTextView.placeholder = "Say something about this post..."
    saySomethingTextView.font = UIFont.systemFontOfSize(14)
    saySomethingTextView.backgroundColor = textEntryBackground
    saySomethingTextView.spellCheckingType = .No
    saySomethingTextView.autocorrectionType = .No
    
    let vertLeadingEdge = CGFloat(26)
    let vertWidth = CGFloat(3)
    let originalPostLeadingEdge = vertLeadingEdge + vertWidth + 27
    let originalPostTopEdge = saySomethingTextView.frame.maxY + 8
    
    originalPictureButton = UIButton(frame: CGRect(x: originalPostLeadingEdge, y: originalPostTopEdge, width: 35, height: 35))
    originalPictureButton.setBackgroundImageToImageWithURL(post.user.photoURL, forState: .Normal)
    originalPictureButton.clipsToBounds = true
    originalPictureButton.layer.cornerRadius = 5.0
    
    originalUsernameLabel = UILabel(frame: CGRect(x: originalPictureButton.frame.maxX + 8, y: originalPostTopEdge, width: 200, height: 18))
    originalUsernameLabel.font = UIFont.boldSystemFontOfSize(15)
    originalUsernameLabel.text = post.user.name
    
    let onLabel = UILabel(frame: CGRect(x: originalPictureButton.frame.maxX + 8, y: originalUsernameLabel.frame.maxY + 2, width: 16, height: 16))
    onLabel.font = UIFont.systemFontOfSize(13)
    onLabel.text = "on"
    
    originalBoardLabel = UILabel(frame: CGRect(x: onLabel.frame.maxX + 5, y: originalUsernameLabel.frame.maxY + 2, width: 200, height: 16))
    originalBoardLabel.font = UIFont.boldSystemFontOfSize(13)
    originalBoardLabel.text = post.board.name
    
    if let title = post.title {
      originalTitleLabel = UILabel(frame: CGRect(x: originalPostLeadingEdge, y: originalBoardLabel.frame.maxY + 8, width: width - originalPostLeadingEdge - 8, height: 23))
      originalTitleLabel.font = UIFont.boldSystemFontOfSize(20)
      originalTitleLabel.text = title
      originalTitleLabel.textAlignment = .Center
      
      originalPostTextView = UITextView(frame: CGRect(x: originalPostLeadingEdge, y: originalTitleLabel.frame.maxY + 8, width: width - originalPostLeadingEdge - 8, height: post.text.heightOfTextWithWidth(width - originalPostLeadingEdge - 8, andFont: UIFont.systemFontOfSize(15))))
    } else {
      originalTitleLabel = UILabel()
      
      originalPostTextView = UITextView(frame: CGRect(x: originalPostLeadingEdge, y: originalBoardLabel.frame.maxY + 8, width: width - originalPostLeadingEdge - 8, height: post.text.heightOfTextWithWidth(width - originalPostLeadingEdge - 8, andFont: UIFont.systemFontOfSize(15))))
    }
    
    originalPostTextView.textContainer.lineFragmentPadding = 0
    originalPostTextView.textContainerInset = UIEdgeInsetsZero
    originalPostTextView.editable = false
    originalPostTextView.userInteractionEnabled = false
    originalPostTextView.font = UIFont.systemFontOfSize(15)
    originalPostTextView.text = post.text
    
    var sideLine: UIView
    if let imageURLs = post.imageURLs {
      originalPostImagesButton = UIButton(frame: CGRect(x: originalPostLeadingEdge, y: originalPostTextView.frame.maxY, width: width - originalPostLeadingEdge - 8, height: post.heightOfImagesInPostWithWidth(width - originalPostLeadingEdge - 8, andMaxImageHeight: 300)))
      originalPostImagesButton.setBackgroundImageToImageWithURL(imageURLs[0], forState: .Normal)
      sideLine = UIView(frame: CGRect(x: vertLeadingEdge, y: originalPostTopEdge, width: vertWidth, height: originalPostImagesButton.frame.maxY - originalPostTopEdge))
    } else {
      originalPostImagesButton = UIButton()
      
      sideLine = UIView(frame: CGRect(x: vertLeadingEdge, y: originalPostTopEdge, width: vertWidth, height: originalPostTextView.frame.maxY - originalPostTopEdge))
    }
    
    sideLine.backgroundColor = ColorScheme.defaultScheme.thinLineBackgroundColor()

    super.init(frame: CGRect(x: 0, y: 0, width: width, height: sideLine.frame.maxY + 8))
    
    addSubview(pictureButton)
    addSubview(usernameLabel)
    addSubview(boardTextField)
    addSubview(saySomethingTextView)
    addSubview(originalUsernameLabel)
    addSubview(originalPictureButton)
    addSubview(onLabel)
    addSubview(originalBoardLabel)
    addSubview(originalTitleLabel)
    addSubview(originalPostTextView)
    addSubview(originalPostImagesButton)
    addSubview(sideLine)
  }
  
  // MARK: Setup Helper Functions
  
  /// Sets up the colors of the User Interface elements according to the default scheme of the app.
  func setupColorScheme() {
    let scheme = ColorScheme.defaultScheme
    saySomethingTextView.backgroundColor = scheme.textFieldBackgroundColor()
    boardTextField.backgroundColor = scheme.textFieldBackgroundColor()
  }
}

