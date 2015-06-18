//
//  CustomTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 1/23/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import JTSImageViewController

/// Any UITableViewController in this app should subclass this class.
///
/// **Note:** Subclasses must override retrieveData(_:).
class CustomTableViewController: UITableViewController {
  
  // MARK: Properties
  
  /// Flag to tell if a large amount of data is being retrieved from the server at this time.
  var retrievingPage = false
  
  // MARK: Constants
  
  /// Max height of postTextView in a PostCell before it is expanded by seeFullButton.
  var maxContractedHeight: CGFloat {
    return tableView.frame.height * 0.625 - PostCell.additionalVertSpaceNeeded
  }
  
  /// The width of the screen with 8px margins.
  var tableViewWidthWithMargins: CGFloat {
    return tableView.frame.size.width - 16
  }
  
  // MARK: UIViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Establishes a UIRefreshControl that responds to the retrieveData() function.
    refreshControl = UIRefreshControl()
    refreshControl!.addTarget(self, action: "retrieveData", forControlEvents: .ValueChanged)
    tableView.addSubview(refreshControl!)
  }
  
  // MARK: Networking Helper Functions
  
  /// Handles an error received from a network call within the app.
  ///
  /// :param: error The error to be handled
  func handleError(error: NSError) {
    println(error)
    if error.domain == NSError.cilloErrorDomain {
      switch error.code {
      case NSError.CilloErrorCodes.userUnauthenticated:
        handleUserUnauthenticatedError(error)
      default:
        error.showAlert()
      }
    }
  }
  
  /// Used to retrieve all necessary data to display UITableViewCells in this CustomTableViewController.
  ///
  /// **Note:** This function does nothing unless overriden. Subclasses should override this function to retrieve data from the Cillo servers.
  ///
  /// **Note:** The overriden function should contain tableView.reloadData() and refreshControl?.endResfreshing()
  func retrieveData() {
    fatalError("Subclasses of CustomTableViewController must override retrieveData()")
  }

  // MARK: Error Handling Helper Functions
  
  /// Handles a cillo error with code `NSError.CilloErrorCodes.userUnauthenticated`.
  ///
  /// :param: error The error to be handled.
  func handleUserUnauthenticatedError(error: NSError) {
    if let tabBarController = tabBarController as? TabViewController {
      tabBarController.performSegueWithIdentifier(SegueIdentifiers.tabToLogin, sender: error)
    }
  }
  
  // MARK: IBActions
  
  /// Triggers segue to NewPostViewController when button is pressed on navigationBar.
  @IBAction func triggerNewPostSegueOnButton(sender: UIBarButtonItem) {
    if let tabBarController = tabBarController as? TabViewController {
      tabBarController.performSegueWithIdentifier(SegueIdentifiers.tabToNewPost, sender: sender)
    }
  }
}

// MARK: - TTTAttributedLabelDelegate

extension CustomTableViewController: TTTAttributedLabelDelegate {

  /// Opens all links in WebViewControllers.
  func attributedLabel(label: TTTAttributedLabel, didSelectLinkWithURL url: NSURL) {
    let webViewController = WebViewController()
    webViewController.urlToLoad = url
    navigationController?.pushViewController(webViewController, animated: true)
  }
}

extension CustomTableViewController: JTSImageViewControllerOptionsDelegate {
  
  func alphaForBackgroundDimmingOverlayInImageViewer(imageViewer: JTSImageViewController!) -> CGFloat {
    return 1.0
  }
}
