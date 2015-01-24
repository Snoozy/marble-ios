//
//  CustomTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 1/23/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

// TODO: Document.
class CustomTableViewController: UITableViewController {
  
  var prevViewController: UIViewController?
  
  // MARK: Constants
  
  /// Width of textView in UITableViewCell.
  var PrototypeTextViewWidth: CGFloat {
    get {
      return view.frame.size.width - 16
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
  
  // TODO: Document
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    tabBarController?.delegate = self
  }
  
  // MARK: Helper Functions
  
  /// Used to retrieve all necessary data to display UITableViewCells in this UITableViewController.
  ///
  /// **Note:** This function does nothing unless overriden. Subclasses should override this function to retrieve data from the Cillo servers.
  ///
  /// **Note:** The overriden function should contain tableView.reloadData() and refreshControl?.endResfreshing()
  func retrieveData() {
  }

}

extension CustomTableViewController: UITabBarControllerDelegate {
  
  // MARK: UITabBarControllerDelegate
  
  func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
    prevViewController = viewController
    return true
  }
  
  /// Scrolls tableView back to top if a tab that is already selected is pressed again.
  func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
    if prevViewController == viewController {
      tableView.setContentOffset(CGPointZero, animated: true)
    }
  }
  
}

extension CustomTableViewController: UITextViewDelegate {
  
  // MARK: UITextViewDelegate
  
  // TODO: Document.
  func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
    let webViewController = WebViewController()
    webViewController.urlToLoad = URL
    navigationController?.pushViewController(webViewController, animated: true)
    return false
  }
  
}
