//
//  CustomTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 1/23/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit
import TTTAttributedLabel

// TODO: Document.
class CustomTableViewController: UITableViewController {
  
  // MARK: Constants
  
  /// Width of textView in UITableViewCell.
  var PrototypeTextViewWidth: CGFloat {
    get {
      return tableView.frame.size.width - 16
    }
  }
  
  /// Max height of postTextView in a PostCell before it is expanded by seeFullButton.
  var MaxContractedHeight: CGFloat {
    get {
      return tableView.frame.height * 0.625 - PostCell.AdditionalVertSpaceNeeded
    }
  }
  
  // MARK: UIViewController
  
  /// Establishes a UIRefreshControl that is attached to the retrieveData() function.
  override func viewDidLoad() {
    super.viewDidLoad()
    refreshControl = UIRefreshControl()
    refreshControl!.addTarget(self, action: "retrieveData", forControlEvents: .ValueChanged)
    tableView.addSubview(refreshControl!)
  }
  
  // MARK: Helper Functions
  
  /// Used to retrieve all necessary data to display UITableViewCells in this UITableViewController.
  ///
  /// **Note:** This function does nothing unless overriden. Subclasses should override this function to retrieve data from the Cillo servers.
  ///
  /// **Note:** The overriden function should contain tableView.reloadData() and refreshControl?.endResfreshing()
  func retrieveData() {
  }
  
  /// Triggers segue to NewPostViewController when button is pressed on navigationBar.
  @IBAction func triggerNewPostSegueOnButton(sender: UIBarButtonItem) {
    if let tabBarController = tabBarController as? TabViewController {
      tabBarController.performSegueWithIdentifier(TabViewController.SegueIdentifierThisToNewPost, sender: sender)
    }
  }

}

extension CustomTableViewController: UITabBarControllerDelegate {
  
//  // MARK: UITabBarControllerDelegate
//  
//  /// Scrolls tableView back to top if a tab that is already selected is pressed again.
//  func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
//    if navigationController == viewController {
//      tableView.setContentOffset(CGPointZero, animated: true)
//    }
//  }
  
}

extension CustomTableViewController: TTTAttributedLabelDelegate {

  func attributedLabel(label: TTTAttributedLabel, didSelectLinkWithURL url: NSURL) {
    let webViewController = WebViewController()
    webViewController.urlToLoad = url
    navigationController?.pushViewController(webViewController, animated: true)
  }
}
