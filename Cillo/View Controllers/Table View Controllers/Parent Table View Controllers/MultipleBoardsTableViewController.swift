//
//  MultipleBoardsTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 12/19/14.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Inherit this class for any UITableViewController that is only a table of BoardCells.
///
/// **Note:** Subclasses must override segueIdentifierThisToBoard and segueIdentifierThisToNewBoard.
class MultipleBoardsTableViewController: CustomTableViewController {
  
  // MARK: Properties
  
  /// Boards for this UITableViewController.
  var boards = [Board]()
  
  // MARK: Constants
  
  /// The standard dividerHeight between table view cells in tableView.
  let dividerHeight = DividerScheme.defaultScheme.multipleBoardsDividerHeight()
  
  /// The height on screen of the cells containing only single buttons.
  ///
  /// These cells are the newBoardCell and seeAllCell.
  var heightOfSingleButtonCells: CGFloat {
    return 40.0
  }
  
  /// Segue Identifier in Storyboard for segue to BoardTableViewController.
  ///
  /// **Note:** Subclasses must override this Constant.
  var segueIdentifierThisToBoard: String {
    fatalError("Subclasses of MultipleBoardsTableViewController must override segue identifiers")
  }
  
  // MARK: UIViewController
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == segueIdentifierThisToBoard {
      var destination = segue.destinationViewController as! BoardTableViewController
      if let sender = sender as? NSIndexPath {
        destination.board = boards[sender.row]
      } else if let sender = sender as? UIButton {
        destination.board = boards[sender.tag]
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.separatorStyle = .None
  }
  
  // MARK: UITableViewDataSource
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    return dequeueAndSetupBoardCellForIndexPath(indexPath)
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return boards.count
  }
  
  // MARK: UITableViewDelegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    self.performSegueWithIdentifier(segueIdentifierThisToBoard, sender: indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return BoardCell.heightOfBoardCellForBoard(boards[indexPath.row], withElementWidth: tableViewWidthWithMargins, andDividerHeight: separatorHeightForIndexPath(indexPath))
  }

  // MARK: Setup Helper Functions
  
  /// Makes a BoardCell for the corresponding board in `boards` based on the passed indexPath.
  ///
  /// :param: indexPath The index path of the cell to be created in the table view.
  ///
  /// :returns: The created BoardCell.
  func dequeueAndSetupBoardCellForIndexPath(indexPath: NSIndexPath) -> BoardCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.boardCell, forIndexPath: indexPath) as! BoardCell
    cell.makeCellFromBoard(boards[indexPath.row], withButtonTag: indexPath.row, andSeparatorHeight: separatorHeightForIndexPath(indexPath))
    cell.assignDelegatesForCellTo(self)
    return cell
  }
  
  /// Makes a single button UITableViewCell that has a button that responds to `triggerNewBoardSegueOnButton(_:)`.
  ///
  /// :param: indexPath The index path of the cell to be created in the table view.
  ///
  /// :returns: The created NewBoardCell.
  func dequeueAndSetupNewBoardCellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.newBoardCell, forIndexPath: indexPath) as! UITableViewCell
    for view in cell.contentView.subviews {
      if let button = view as? UIButton {
        button.tintColor = ColorScheme.defaultScheme.touchableTextColor()
      }
    }
    return cell
  }
  
  /// Presents an AlertController with style `.ActionSheet` that asks the user for confirmation of unfollowing a board.
  ///
  /// :param: board The board that is being unfollowed.
  /// :param: index The index of the board being unfollowed in the `boards` array.
  func presentUnfollowConfirmationActionSheetForBoard(board: Board, atIndex index: Int, iPadReference: UIButton?) {
    if objc_getClass("UIAlertController") != nil {
      let actionSheet = UIAlertController(title: board.name, message: nil, preferredStyle: .ActionSheet)
      let unfollowAction = UIAlertAction(title: "Leave", style: .Default) { _ in
        self.unfollowBoardAtIndex(index) { success in
          if success {
            dispatch_async(dispatch_get_main_queue()) {
              board.following = false
              let boardIndexPath = NSIndexPath(forRow: index, inSection: 0)
              self.tableView.reloadRowsAtIndexPaths([boardIndexPath], withRowAnimation: .None)
            }
          }
        }
      }
      let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { _ in
      }
      actionSheet.addAction(unfollowAction)
      actionSheet.addAction(cancelAction)
      if let iPadReference = iPadReference where UIDevice.currentDevice().userInterfaceIdiom == .Pad {
        actionSheet.modalPresentationStyle = .Popover
        let popPresenter = actionSheet.popoverPresentationController
        popPresenter?.sourceView = iPadReference
        popPresenter?.sourceRect = iPadReference.bounds
      }
      presentViewController(actionSheet, animated: true, completion: nil)
    } else {
      let actionSheet = UIActionSheet(title: board.name, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil, otherButtonTitles: "Leave", "Cancel")
      actionSheet.cancelButtonIndex = 1
      actionSheet.tag = index
      if let iPadReference = iPadReference where UIDevice.currentDevice().userInterfaceIdiom == .Pad {
        actionSheet.showFromRect(iPadReference.bounds, inView: iPadReference, animated: true)
      } else {
        if let tabBar = tabBarController?.tabBar {
          actionSheet.showFromTabBar(tabBar)
        }
      }
    }
    
  }
  
  /// Calculates the correct separator height inbetween cells of `tableView`.
  ///
  /// :param: indexPath The index path of the cell in the `tableView`.
  ///
  /// :returns: The correct separator height, as specified by the `dividerHeight` constant.
  func separatorHeightForIndexPath(indexPath: NSIndexPath) -> CGFloat {
    if indexPath.row < boards.count - 1 {
      return dividerHeight
    } else {
      return 0
    }
  }
  
  // MARK: Networking Helper Functions
  
  /// Sends follow request to Cillo Servers for the board at index.
  ///
  /// :param: index The index of the board being followed in the boards array.
  /// :param: completionHandler The completion block for the upvote.
  /// :param: success True if follow request was successful. If error was received, it is false.
  func followBoardAtIndex(index: Int, completionHandler: (success: Bool) -> ()) {
    DataManager.sharedInstance.followBoardWithID(boards[index].boardID) { result in
      self.handleSuccessResponse(result, completionHandler: completionHandler)
    }
  }
  
  /// Sends unfollow request to Cillo Servers for the board at index.
  ///
  /// :param: index The index of the board being unfollowed in the boards array.
  /// :param: completionHandler The completion block for the upvote.
  /// :param: success True if follow request was unsuccessful. If error was received, it is false.
  func unfollowBoardAtIndex(index: Int, completionHandler: (success: Bool) -> ()) {
    DataManager.sharedInstance.unfollowBoardWithID(boards[index].boardID) { result in
      self.handleSuccessResponse(result, completionHandler: completionHandler)
    }
  }
  
  // MARK: IBActions
  
  /// Expands the image displayed in the button to full screen.
  ///
  /// :param: sender The button that is touched to send this function is a `photoButton` in a BoardCell.
  @IBAction func boardPhotoPressed(sender: UIButton) {
    if let photo = sender.backgroundImageForState(.Normal) {
      JTSImageViewController.expandImage(photo, toFullScreenFromRoot: self, withSender: sender)
    }
  }
  
  /// Either follows the board at index sender.tag or presents an ActionSheet to unfollow the board.
  ///
  /// :param: sender The button that is touched to send this function is a followButton in a BoardCell.
  @IBAction func followOrUnfollowBoard(sender: UIButton) {
    let board = boards[sender.tag]
    if !board.following {
      followBoardAtIndex(sender.tag) { success in
        if success {
          dispatch_async(dispatch_get_main_queue()) {
            board.following = true
            let boardIndexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
            self.tableView.reloadRowsAtIndexPaths([boardIndexPath], withRowAnimation: .None)
          }
          
        }
      }
    } else {
      presentUnfollowConfirmationActionSheetForBoard(board, atIndex: sender.tag, iPadReference: sender)
    }
  }
  
  /// Triggers segue to BoardTableViewController.
  ///
  /// :param: sender The button that is touched to send this function is a nameButton or a pictureButton in a BoardCell.
  @IBAction func triggerBoardSegueOnButton(sender: UIButton) {
    performSegueWithIdentifier(segueIdentifierThisToBoard, sender: sender)
  }
  
  /// Triggers segue to NewBoardViewController.
  ///
  /// :param: sender The button that is touched to send this function is the button in the NewBoardCell.
  @IBAction func triggerNewBoardSegueOnButton(sender: UIButton) {
    if let tabBarController = tabBarController as? TabViewController {
      tabBarController.performSegueWithIdentifier(SegueIdentifiers.tabToNewBoard, sender: sender)
    }
  }
}

extension MultipleBoardsTableViewController: UIActionSheetDelegate {
  
  func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
    if buttonIndex == 0 {
      unfollowBoardAtIndex(actionSheet.tag) { success in
        if success {
          dispatch_async(dispatch_get_main_queue()) {
            self.boards[actionSheet.tag].following = false
            let boardIndexPath = NSIndexPath(forRow: actionSheet.tag, inSection: 0)
            self.tableView.reloadRowsAtIndexPaths([boardIndexPath], withRowAnimation: .None)
          }
          
        }
      }
    }
  }
}
