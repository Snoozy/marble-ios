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
  
  /// End User representation to be shown at the top of the screen.
  ///
  /// Set this property to pass an end user name to this UIViewController from another UIViewController.
  var endUser: User?
  
  /// The original post that will be reposted.
  var postToRepost: Post = Post()
  
  /// The scrollView used to display all the contents of this ViewController.
  var scrollView: UIScrollView!
  
  // MARK: UIViewController
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if contentView == nil {
      contentView = RepostContentView(post: postToRepost, width: view.frame.width)
      setupUserInfoInContentView()
      setupScrollView()
      setupButtonSelectors()
      contentView!.setupColorScheme()
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == SegueIdentifiers.newRepostToTab {
      let destination = segue.destination as! TabViewController
      if let sender = sender as? Post, navController = destination.selectedViewController as? UINavigationController {
        let postViewController = self.storyboard!.instantiateViewController(withIdentifier: StoryboardIdentifiers.post) as! PostTableViewController
        postViewController.post = sender
        navController.pushViewController(postViewController, animated: true)
      }
    }
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
    if let contentView = contentView {
      contentView.saySomethingTextView.resignFirstResponder()
    }
  }
  
  /// Sets the buttons to have image expanding events on touch
  private func setupButtonSelectors() {
    contentView?.pictureButton.addTarget(self, action: #selector(NewRepostViewController.photoButtonPressed(_:)), for: .touchUpInside)
    contentView?.originalPictureButton.addTarget(self, action: #selector(NewRepostViewController.photoButtonPressed(_:)), for: .touchUpInside)
    contentView?.originalPostImagesButton.addTarget(self, action: #selector(NewRepostViewController.photoButtonPressed(_:)), for: .touchUpInside)
    contentView?.boardPhotoButton.addTarget(self, action: #selector(NewRepostViewController.photoButtonPressed(_:)), for: .touchUpInside)
    contentView?.selectBoardButton.addTarget(self, action: #selector(NewRepostViewController.presentOverlay), for: .touchUpInside)
  }
  
  /// Sets the user related fields of the contentView.
  private func setupUserInfoInContentView() {
    if let endUser = endUser {
      contentView?.pictureButton.setBackgroundImageToImageWithURL(endUser.photoURL, forState: UIControlState())
      contentView?.usernameLabel.text = endUser.name
    } else {
      retrieveEndUser { (user) in
        if let user = user {
          self.contentView?.pictureButton.setBackgroundImageToImageWithURL(user.photoURL, forState: UIControlState())
          self.contentView?.usernameLabel.text = user.name
        }
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
  
  // MARK: Networking Helper Functions
  
  /// Reposts the post represented by the contentView to the Cillo Servers.
  ///
  /// :param: completionHandler The completion block for this server call.
  /// :param: post The repost after the server call.
  /// :param: * Nil if the server call was unsuccessful.
  func repostPost(_ completionHandler: (post: Post?) -> ()) {
    if let contentView = contentView {
      DataManager.sharedInstance.createPostByBoardName(contentView.selectBoardButton.title(for: UIControlState()) ?? "", text: contentView.saySomethingTextView.text, repostID: postToRepost.postID) { result in
        self.handleSingleElementResponse(result, completionHandler: completionHandler)
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
  func retrieveEndUser(_ completionHandler: (user: User?) -> ()) {
    DataManager.sharedInstance.getEndUserInfo { result in
      self.handleSingleElementResponse(result, completionHandler: completionHandler)
    }
  }
  
  // MARK: Button Selectors
  
  /// Expands the image displayed in the button to full screen.
  ///
  /// :param: sender The button that is touched to send this function is a `photoButton`.
  func photoButtonPressed(_ sender: UIButton) {
    if let image = sender.backgroundImage(for: UIControlState()) {
      JTSImageViewController.expandImage(image, toFullScreenFromRoot: self, withSender: sender)
    } else if let image = sender.image(for: UIControlState()) {
      JTSImageViewController.expandImage(image, toFullScreenFromRoot: self, withSender: sender)
    }
  }
  
  
  // MARK: IBActions
  
  /// Reposts the post represented on the screen, and if successful, unwinds to the Tab Bar.
  ///
  /// :param: sender The bar button item that says Create.
  @IBAction func repostButtonPressed(_ sender: UIButton) {
    if let board = contentView?.selectBoardButton.title(for: UIControlState()) where board != "Select Board" {
      sender.isEnabled = false
      repostPost { post in
        sender.isEnabled = true
        if let post = post {
          self.performSegue(withIdentifier: SegueIdentifiers.newRepostToTab, sender: post)
        }
      }
    } else {
      UIAlertView(title: "Error", message: "Please select a board.", delegate: nil, cancelButtonTitle: "Ok").show()
    }
  }
}

// MARK: - SelectBoardOverlayViewDelegate

extension NewRepostViewController: SelectBoardOverlayViewDelegate {
  
  /// Called when a board is selected on a popup overlay.
  ///
  /// :param: overlay The overlay that the board was selected from.
  /// :param: board THe board that was selected.
  func overlay(_ overlay: SelectBoardOverlayView, selectedBoard board: Board) {
    overlay.animateOut()
    if let boardPhotoButton = contentView?.boardPhotoButton, selectBoardButton = contentView?.selectBoardButton {
      if boardPhotoButton.frame.width < 1 {
        boardPhotoButton.frame = CGRect(x: boardPhotoButton.frame.minX, y: boardPhotoButton.frame.minY, width: boardPhotoButton.frame.height, height: boardPhotoButton.frame.height)
        selectBoardButton.frame = CGRect(x: selectBoardButton.frame.minX + boardPhotoButton.frame.height, y: selectBoardButton.frame.minY, width: selectBoardButton.frame.width - boardPhotoButton.frame.height, height: selectBoardButton.frame.height)
      }
      selectBoardButton.setTitle(board.name, for: UIControlState())
      boardPhotoButton.setBackgroundImageToImageWithURL(board.photoURL, forState: UIControlState())
    }
  }
  
  
  /// Called when a popup overlay is dismissed
  ///
  /// :param: overlay The overlay that was dismissed.
  func overlayDismissed(_ overlay: SelectBoardOverlayView) {
    overlay.animateOut()
  }
}

// MARK: - Content View Layout Helper Class

/// This class is used to get around the weird autolayout behavior of UIScrollView. All content of NewRepostViewController is displayed on screen through this contentView.
class RepostContentView: UIView {
  
  // MARK: Properties
  
  /// Button that presents a popup for the end user to select a board to repost on.
  var selectBoardButton: UIButton!
  
  /// Button that displays the board photo after the user has selected a board to repost on.
  var boardPhotoButton: UIButton!
  
  /// Label used to display the board of the original post.
  var originalBoardLabel: UILabel!
  
  /// Button used to display the profile picture of the user that posted the original post.
  var originalPictureButton: UIButton!
  
  /// Button used to display any images in the original post.
  var originalPostImagesButton: UIButton!
  
  /// View used to display the text of the original post.
  var originalPostTextView: UITextView!
  
  /// Label used to display the name of the user that posted the original post.
  var originalUsernameLabel: UILabel!
  
  /// Button used to display the profile picture of the end user.
  var pictureButton: UIButton!
  
  /// Field for the end user to say something about the post that they are reposting.
  var saySomethingTextView: BottomBorderedTextView!
  
  /// Button used to display the name of the end user.
  var usernameLabel: UILabel!
  
  // MARK: Initializers
  
  /// **Warning:** Do not use this initializer.
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  /// Populates the contentView with all the User Interface elements depending on the original post provided.
  ///
  /// :param: post The original post that is supposed to be reposted.
  /// :param: width The width of the screen.
  init(post: Post, width: CGFloat) {
    var post = post
    if let repost = (post as? Repost)?.originalPost {
      post = repost
    }
    let textEntryBackground = ColorScheme.defaultScheme.textFieldBackgroundColor()
    
    pictureButton = UIButton(frame: CGRect(x: 8, y: 8, width: 40, height: 40))
    pictureButton.clipsToBounds = true
    pictureButton.layer.cornerRadius = 5.0
    
    usernameLabel = UILabel(frame: CGRect(x: pictureButton.frame.maxX + 8, y: 17, width: width - pictureButton.frame.width - 24, height: 21))
    usernameLabel.font = UIFont.boldSystemFont(ofSize: 17)
    
    saySomethingTextView = BottomBorderedTextView(frame: CGRect(x: 8, y: pictureButton.frame.maxY + 8, width: width - 16, height: 60))
    saySomethingTextView.placeholder = "Say something about this post..."
    saySomethingTextView.font = UIFont.systemFont(ofSize: 14)
    saySomethingTextView.backgroundColor = textEntryBackground
    saySomethingTextView.spellCheckingType = .no
    saySomethingTextView.autocorrectionType = .no
    
    boardPhotoButton = UIButton(frame: CGRect(x: 8, y: saySomethingTextView.frame.maxY + 4, width: 0, height: 40))
    boardPhotoButton.clipsToBounds = true
    boardPhotoButton.layer.cornerRadius = 5.0
    
    selectBoardButton = UIButton(frame: CGRect(x: boardPhotoButton.frame.maxX + 8, y: saySomethingTextView.frame.maxY + 9, width: width - 16 - boardPhotoButton.frame.width, height: 30))
    selectBoardButton.contentHorizontalAlignment = .left
    selectBoardButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
    selectBoardButton.setTitle("Select Board", for: UIControlState())
    
    let horizontalBoardDivider = UIView(frame: CGRect(x: 8, y: boardPhotoButton.frame.maxY + 4, width: width - 16, height: 1))
    horizontalBoardDivider.backgroundColor = ColorScheme.defaultScheme.thinLineBackgroundColor()
    
    let vertLeadingEdge = CGFloat(26)
    let vertWidth = CGFloat(3)
    let originalPostLeadingEdge = vertLeadingEdge + vertWidth + 27
    let originalPostTopEdge = boardPhotoButton.frame.maxY + 9
    
    originalPictureButton = UIButton(frame: CGRect(x: originalPostLeadingEdge, y: originalPostTopEdge, width: 35, height: 35))
    originalPictureButton.setBackgroundImageToImageWithURL(post.user.photoURL, forState: UIControlState())
    originalPictureButton.clipsToBounds = true
    originalPictureButton.layer.cornerRadius = 5.0
    
    originalUsernameLabel = UILabel(frame: CGRect(x: originalPictureButton.frame.maxX + 8, y: originalPostTopEdge, width: 200, height: 18))
    originalUsernameLabel.font = UIFont.boldSystemFont(ofSize: 15)
    originalUsernameLabel.text = post.user.name
    
    let onLabel = UILabel(frame: CGRect(x: originalPictureButton.frame.maxX + 8, y: originalUsernameLabel.frame.maxY + 2, width: 16, height: 16))
    onLabel.font = UIFont.systemFont(ofSize: 13)
    onLabel.text = "on"
    
    originalBoardLabel = UILabel(frame: CGRect(x: onLabel.frame.maxX + 5, y: originalUsernameLabel.frame.maxY + 2, width: 200, height: 16))
    originalBoardLabel.font = UIFont.boldSystemFont(ofSize: 13)
    originalBoardLabel.text = post.board.name
      
    originalPostTextView = UITextView(frame: CGRect(x: originalPostLeadingEdge, y: originalBoardLabel.frame.maxY + 8, width: width - originalPostLeadingEdge - 8, height: post.text.heightOfTextWithWidth(width - originalPostLeadingEdge - 8, andFont: UIFont.systemFont(ofSize: 15))))
    
    originalPostTextView.textContainer.lineFragmentPadding = 0
    originalPostTextView.textContainerInset = UIEdgeInsetsZero
    originalPostTextView.isEditable = false
    originalPostTextView.isUserInteractionEnabled = false
    originalPostTextView.font = UIFont.systemFont(ofSize: 15)
    originalPostTextView.text = post.text
    
    var sideLine: UIView
    if let imageURLs = post.imageURLs {
      originalPostImagesButton = UIButton(frame: CGRect(x: originalPostLeadingEdge, y: originalPostTextView.frame.maxY, width: width - originalPostLeadingEdge - 8, height: post.heightOfImagesInPostWithWidth(width - originalPostLeadingEdge - 8, andMaxImageHeight: 300)))
      originalPostImagesButton.imageView?.contentMode = .scaleAspectFill
      originalPostImagesButton.clipsToBounds = true
      originalPostImagesButton.contentHorizontalAlignment = .fill
      originalPostImagesButton.contentVerticalAlignment = .fill
      originalPostImagesButton.setImageToImageWithURL(imageURLs[0], forState: UIControlState(), withWidth: width - originalPostLeadingEdge - 8)
      sideLine = UIView(frame: CGRect(x: vertLeadingEdge, y: originalPostTopEdge, width: vertWidth, height: originalPostImagesButton.frame.maxY - originalPostTopEdge))
    } else {
      originalPostImagesButton = UIButton()
      
      sideLine = UIView(frame: CGRect(x: vertLeadingEdge, y: originalPostTopEdge, width: vertWidth, height: originalPostTextView.frame.maxY - originalPostTopEdge))
    }
    
    sideLine.backgroundColor = ColorScheme.defaultScheme.thinLineBackgroundColor()

    super.init(frame: CGRect(x: 0, y: 0, width: width, height: sideLine.frame.maxY + 8))
    
    addSubview(pictureButton)
    addSubview(usernameLabel)
    addSubview(boardPhotoButton)
    addSubview(selectBoardButton)
    addSubview(horizontalBoardDivider)
    addSubview(saySomethingTextView)
    addSubview(originalUsernameLabel)
    addSubview(originalPictureButton)
    addSubview(onLabel)
    addSubview(originalBoardLabel)
    addSubview(originalPostTextView)
    addSubview(originalPostImagesButton)
    addSubview(sideLine)
  }
  
  // MARK: UIResponder
  
  override func touchesBegan(_ touches: Set<NSObject>, with event: UIEvent) {
    if saySomethingTextView.isFirstResponder {
      saySomethingTextView.resignFirstResponder()
    }
  }
  
  // MARK: Setup Helper Functions
  
  /// Sets up the colors of the User Interface elements according to the default scheme of the app.
  func setupColorScheme() {
    let scheme = ColorScheme.defaultScheme
    saySomethingTextView.backgroundColor = scheme.bottomBorderedTextFieldBackgroundColor()
    selectBoardButton.setTitleColor(scheme.touchableTextColor(), for: UIControlState())
  }
}

