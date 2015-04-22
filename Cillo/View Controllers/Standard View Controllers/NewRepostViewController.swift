//
//  NewRepostViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 4/5/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

class NewRepostViewController: UIViewController {

  var postToRepost: Post = Post()
  
  var SegueIdentifierThisToTab: String {
    get {
      return "NewRepostToTab"
    }
  }
  
  @IBOutlet weak var fakeNavigationBar: UINavigationBar!
  
  var scrollView: UIScrollView!
  
  var contentView: RepostContentView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    fakeNavigationBar.barTintColor = UIColor.cilloBlue()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewDidAppear(animated)
    contentView = RepostContentView(post: postToRepost, width: view.frame.width)
    retrieveUser({ (user) in
      if user != nil {
        self.contentView.pictureButton.setBackgroundImageForState(.Disabled, withURL: user!.profilePicURL)
        self.contentView.usernameLabel.text = user!.name
      }
    })
    var scrollViewHeight: CGFloat
    if contentView.frame.height > view.frame.height - fakeNavigationBar.frame.maxY {
      scrollViewHeight = view.frame.height - fakeNavigationBar.frame.maxY
    } else {
      scrollViewHeight = contentView.frame.height
    }
    scrollView = UIScrollView(frame: CGRect(x: 0, y: fakeNavigationBar.frame.maxY, width: view.frame.width, height: scrollViewHeight))
    scrollView.contentSize = contentView.frame.size
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)
    println(contentView.commentLabel.font.pointSize)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == SegueIdentifierThisToTab {
      if let sender = sender as? Post {
        var destination = segue.destinationViewController as! TabViewController
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
  
  func repostPost(completion: (post: Post?) -> Void) {
    let activityIndicator = addActivityIndicatorToCenterWithText("Reposting...")
    DataManager.sharedInstance.createPostByGroupName(contentView.groupTextField.text, repostID: postToRepost.postID, text: contentView.saySomethingTextView.text, title: nil, mediaID: nil, completion: { (error, result) -> Void in
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
  
  @IBAction func repostButtonPressed(sender: UIButton) {
    repostPost( { (post) in
      if let post = post {
        self.performSegueWithIdentifier(self.SegueIdentifierThisToTab, sender: post)
      }
    })
  }

}

extension NewRepostViewController: UIBarPositioningDelegate {
  func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
    return .TopAttached
  }
}

class RepostContentView: UIView {
  
  var saySomethingTextView: UITextView!
  
  var groupTextField: UITextField!
  
  var pictureButton: UIButton!
  
  var usernameLabel: UILabel!
  
  var commentLabel: UILabel!
  
  var originalPictureButton: UIButton!
  
  var originalUsernameLabel: UILabel!
  
  var originalGroupLabel: UILabel!
  
  var originalTitleLabel: UILabel!
  
  var originalPostTextView: UITextView!
  
  var originalPostImagesButton: UIButton!
  
  init(var post: Post, width: CGFloat) {
    if let repost = (post as? Repost)?.originalPost {
      post = repost
    }
    let textEntryBackground = UIColor(red: 16/255.0, green: 101/255.0, blue: 196/255.0, alpha: 0.08)
    
    pictureButton = UIButton(frame: CGRect(x: 8, y: 8, width: 40, height: 40))
    pictureButton.enabled = false
    
    usernameLabel = UILabel(frame: CGRect(x: pictureButton.frame.maxX + 8, y: 17, width: 200, height: 21))
    usernameLabel.font = UIFont.boldSystemFontOfSize(17)
    
    commentLabel = UILabel(frame: CGRect(x: 8, y: pictureButton.frame.maxY + 3, width: 144, height: 15))
    commentLabel.font = UIFont.systemFontOfSize(12)
    commentLabel.text = "Comment about the Post:"
    
    let groupTextFieldLeadingEdge = commentLabel.frame.maxX + 40
    
    let repostLabel = UILabel(frame: CGRect(x: groupTextFieldLeadingEdge, y: 10, width: 97, height: 15))
    repostLabel.font = UIFont.systemFontOfSize(12)
    repostLabel.text = "Repost to Group:"
    
    groupTextField = UITextField(frame: CGRect(x: groupTextFieldLeadingEdge, y: repostLabel.frame.maxY + 5, width: width - groupTextFieldLeadingEdge - 8, height: 31))
    groupTextField.placeholder = "Group"
    groupTextField.backgroundColor = textEntryBackground
    groupTextField.font = UIFont.systemFontOfSize(16)
    
    saySomethingTextView = UITextView(frame: CGRect(x: 8, y: groupTextField.frame.maxY + 8, width: width - 16, height: 60))
    saySomethingTextView.font = UIFont.systemFontOfSize(14)
    saySomethingTextView.backgroundColor = textEntryBackground
    
    let originalPostLabel = UILabel(frame: CGRect(x: 8, y: saySomethingTextView.frame.maxY + 8, width: 93, height: 18))
    originalPostLabel.font = UIFont.systemFontOfSize(15)
    originalPostLabel.text = "Original Post:"
    
    let vertLeadingEdge = CGFloat(26)
    let vertWidth = CGFloat(3)
    let originalPostLeadingEdge = vertLeadingEdge + vertWidth + 27
    let originalPostTopEdge = originalPostLabel.frame.maxY + 8
    
    originalPictureButton = UIButton(frame: CGRect(x: originalPostLeadingEdge, y: originalPostTopEdge, width: 35, height: 35))
    originalPictureButton.setBackgroundImageForState(.Disabled, withURL: post.user.profilePicURL)
    originalPictureButton.enabled = false
    
    originalUsernameLabel = UILabel(frame: CGRect(x: originalPictureButton.frame.maxX + 8, y: originalPostTopEdge, width: 200, height: 18))
    originalUsernameLabel.font = UIFont.boldSystemFontOfSize(15)
    originalUsernameLabel.text = post.user.name
    
    let onLabel = UILabel(frame: CGRect(x: originalPictureButton.frame.maxX + 8, y: originalUsernameLabel.frame.maxY + 2, width: 16, height: 16))
    onLabel.font = UIFont.systemFontOfSize(13)
    onLabel.text = "on"
    
    originalGroupLabel = UILabel(frame: CGRect(x: onLabel.frame.maxX + 5, y: originalUsernameLabel.frame.maxY + 2, width: 200, height: 16))
    originalGroupLabel.font = UIFont.boldSystemFontOfSize(13)
    originalGroupLabel.text = post.group.name
    
    if let title = post.title {
      
      originalTitleLabel = UILabel(frame: CGRect(x: originalPostLeadingEdge, y: originalGroupLabel.frame.maxY + 8, width: width - originalPostLeadingEdge - 8, height: 23))
      originalTitleLabel.font = UIFont.boldSystemFontOfSize(20)
      originalTitleLabel.text = title
      originalTitleLabel.textAlignment = .Center
      
      originalPostTextView = UITextView(frame: CGRect(x: originalPostLeadingEdge, y: originalTitleLabel.frame.maxY + 8, width: width - originalPostLeadingEdge - 8, height: post.text.heightOfTextWithWidth(width - originalPostLeadingEdge - 8, andFont: UIFont.systemFontOfSize(15))))
      
    } else {
      
      originalTitleLabel = UILabel()
      
      originalPostTextView = UITextView(frame: CGRect(x: originalPostLeadingEdge, y: originalGroupLabel.frame.maxY + 8, width: width - originalPostLeadingEdge - 8, height: post.text.heightOfTextWithWidth(width - originalPostLeadingEdge - 8, andFont: UIFont.systemFontOfSize(15))))
      
    }
    
    originalPostTextView.textContainer.lineFragmentPadding = 0
    originalPostTextView.textContainerInset = UIEdgeInsetsZero
    originalPostTextView.editable = false
    originalPostTextView.userInteractionEnabled = false
    originalPostTextView.font = UIFont.systemFontOfSize(15)
    originalPostTextView.text = post.text
    
    var sideLine: UIView
    if let imageURLs = post.imageURLs {
      originalPostImagesButton = UIButton(frame: CGRect(x: originalPostLeadingEdge, y: originalPostTextView.frame.maxY, width: width - originalPostLeadingEdge - 8, height: post.heightOfImagesInPostWithWidth(width - originalPostLeadingEdge - 8, andButtonHeight: 0)))
      originalPostImagesButton.setBackgroundImageForState(.Disabled, withURL: imageURLs[0])
      originalPostImagesButton.enabled = false
      
      sideLine = UIView(frame: CGRect(x: vertLeadingEdge, y: originalPostTopEdge, width: vertWidth, height: originalPostImagesButton.frame.maxY - originalPostTopEdge))
    } else {
      originalPostImagesButton = UIButton()
      
      sideLine = UIView(frame: CGRect(x: vertLeadingEdge, y: originalPostTopEdge, width: vertWidth, height: originalPostTextView.frame.maxY - originalPostTopEdge))
    }
    
    sideLine.backgroundColor = UIColor.lightGrayColor()

    super.init(frame: CGRect(x: 0, y: 0, width: width, height: sideLine.frame.maxY + 8))
    
    addSubview(pictureButton)
    addSubview(usernameLabel)
    addSubview(repostLabel)
    addSubview(groupTextField)
    addSubview(commentLabel)
    addSubview(saySomethingTextView)
    addSubview(originalPostLabel)
    addSubview(originalUsernameLabel)
    addSubview(originalPictureButton)
    addSubview(onLabel)
    addSubview(originalGroupLabel)
    addSubview(originalTitleLabel)
    addSubview(originalPostTextView)
    addSubview(originalPostImagesButton)
    addSubview(sideLine)
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
}

