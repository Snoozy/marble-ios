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
  
  /// True if all followed boards should be shown. If false, only `numberBoardsShownBeforeSeeAll` boards will be shown, in addition to a cell for a SeeAll button and a New Board button.
  var seeAll = false
  
  // MARK: Constants
  
  /// The standard dividerHeight between table view cells in tableView.
  let dividerHeight = DividerScheme.defaultScheme.multipleBoardsDividerHeight()
  
  /// The height on screen of the cells containing only single buttons.
  ///
  /// These cells are the newBoardCell and seeAllCell.
  var heightOfSingleButtonCells: CGFloat {
    return 40.0
  }
  
  /// The quantity of boards that will be shown before `seeAll` is set to be true.
  var numberBoardsShownBeforeSeeAll: Int {
    return 10
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
    if !seeAll {
      if indexPath.row == numberOfBoardsDisplayedBeforeSeeAll() && seeAllNecessary() {
        return dequeueAndSetupSeeAllCellForIndexPath(indexPath)
      } else if indexPath.row >= numberOfBoardsDisplayedBeforeSeeAll() {
        return dequeueAndSetupNewBoardCellForIndexPath(indexPath)
      }
    } else if indexPath.row >= boards.count {
      return dequeueAndSetupNewBoardCellForIndexPath(indexPath)
    }
    return dequeueAndSetupBoardCellForIndexPath(indexPath)
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // Should show all boards when seeAll is true.
    // Otherwise we must add the number of single button cells to the number of boards to be displayed before the single button cells.
    return seeAll ? boards.count : numberOfBoardsDisplayedBeforeSeeAll() + numberOfExtraCellsBeforeSeeAll()
  }
  
  // MARK: UITableViewDelegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if seeAll || numberOfBoardsDisplayedBeforeSeeAll() > indexPath.row {
      self.performSegueWithIdentifier(segueIdentifierThisToBoard, sender: indexPath)
    }
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.row >= boards.count {
      return heightOfSingleButtonCells
    }
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
  
  /// Makes a single button UITableViewCell that has a button that responds to `seeAllBoardsPress(_:)`.
  ///
  /// :param: indexPath The index path of the cell to be created in the table view.
  ///
  /// :returns: The created SeeAllCell.
  func dequeueAndSetupSeeAllCellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.seeAllCell, forIndexPath: indexPath) as! UITableViewCell
    for view in cell.contentView.subviews {
      if let button = view as? UIButton {
        button.tintColor = ColorScheme.defaultScheme.touchableTextColor()
      } else if let view = view as? UIView {
        view.backgroundColor = ColorScheme.defaultScheme.dividerBackgroundColor()
      }
    }
    return cell
  }
  
  /// Calculates the number of rows that should be displayed before the single button cells.
  ///
  /// :returns: The number of rows before the single button cells, in the range of 0 to `numberBoardsShownBeforeSeeAll`.
  func numberOfBoardsDisplayedBeforeSeeAll() -> Int {
    return boards.count < numberBoardsShownBeforeSeeAll ? boards.count : numberBoardsShownBeforeSeeAll
  }
  
  /// Calculates the number of single button cells displayed before `seeAll` is true.
  ///
  /// **Note:** NewBaordCell is always necessary, but SeeAllCell is only necessary when `seeAllNecessary()` returns true.
  ///
  /// :returns: The number of single button cells, in the range of 1 to 2.
  func numberOfExtraCellsBeforeSeeAll() -> Int {
    return seeAllNecessary() ? 2 : 1
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
            board.following = false
            let boardIndexPath = NSIndexPath(forRow: index, inSection: 0)
            self.tableView.reloadRowsAtIndexPaths([boardIndexPath], withRowAnimation: .None)
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
  
  /// Calculates whether the see all single button cell is necessary. If there are no additional boards to be shown, than see all is clearly not necessary.
  ///
  /// :returns: True only if there are more boards than `numberBoardsShownBeforeSeeAll`.
  func seeAllNecessary() -> Bool {
    return boards.count > numberBoardsShownBeforeSeeAll
  }
  
  /// Calculates the correct separator height inbetween cells of `tableView`.
  ///
  /// :param: indexPath The index path of the cell in the `tableView`.
  ///
  /// :returns: The correct separator height, as specified by the `dividerHeight` constant.
  func separatorHeightForIndexPath(indexPath: NSIndexPath) -> CGFloat {
    if !seeAll && indexPath.row == numberOfBoardsDisplayedBeforeSeeAll() - 1 {
      return 1.0
    } else if seeAll && indexPath.row == boards.count - 1 {
      return 1.0
    } else {
      return dividerHeight
    }
  }
  
  // MARK: Networking Helper Functions
  
  /// Sends follow request to Cillo Servers for the board at index.
  ///
  /// :param: index The index of the board being followed in the boards array.
  /// :param: completionHandler The completion block for the upvote.
  /// :param: success True if follow request was successful. If error was received, it is false.
  func followBoardAtIndex(index: Int, completionHandler: (success: Bool) -> ()) {
    DataManager.sharedInstance.followBoardWithID(boards[index].boardID) { error, success in
      if let error = error {
        self.handleError(error)
        completionHandler(success: false)
      } else {
        completionHandler(success: success)
      }
    }
  }
  
  /// Sends unfollow request to Cillo Servers for the board at index.
  ///
  /// :param: index The index of the board being unfollowed in the boards array.
  /// :param: completionHandler The completion block for the upvote.
  /// :param: success True if follow request was unsuccessful. If error was received, it is false.
  func unfollowBoardAtIndex(index: Int, completionHandler: (success: Bool) -> ()) {
    DataManager.sharedInstance.unfollowBoardWithID(boards[index].boardID) { error, success in
      if let error = error {
        self.handleError(error)
        completionHandler(success: false)
      } else {
        completionHandler(success: success)
      }
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
          board.following = true
          let boardIndexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
          self.tableView.reloadRowsAtIndexPaths([boardIndexPath], withRowAnimation: .None)
        }
      }
    } else {
      presentUnfollowConfirmationActionSheetForBoard(board, atIndex: sender.tag, iPadReference: sender)
    }
  }
  
  /// Shows all boards in the `boards` array in `tableView`.
  ///
  /// :param: sender The button tha tis touched to send this function is the button in the SeeAllCell.
  @IBAction func seeAllBoardsPressed(sender: UIButton) {
    seeAll = true
    tableView.reloadData()
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
          self.boards[actionSheet.tag].following = false
          let boardIndexPath = NSIndexPath(forRow: actionSheet.tag, inSection: 0)
          self.tableView.reloadRowsAtIndexPaths([boardIndexPath], withRowAnimation: .None)
        }
      }
    }
  }
}
