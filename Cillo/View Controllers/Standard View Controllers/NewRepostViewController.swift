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
  
  @IBOutlet weak var saySomethingTextView: UITextView!
  
  @IBOutlet weak var groupTextField: UITextField!
  
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
  
  func repostPost(completion: (post: Post?) -> Void) {
    let activityIndicator = addActivityIndicatorToCenterWithText("Reposting...")
    DataManager.sharedInstance.createPostByGroupName(groupTextField.text, repostID: postToRepost.postID, text: saySomethingTextView.text, title: nil, mediaID: nil, completion: { (error, result) -> Void in
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
  
  @IBAction func repostButtonPressed(sender: UIButton) {
    repostPost( { (post) in
      if let post = post {
        self.performSegueWithIdentifier(self.SegueIdentifierThisToTab, sender: post)
      }
    })
  }

}
