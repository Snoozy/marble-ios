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
  
  override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == segueIdentifierThisToBoard {
      let destination = segue.destination as! BoardTableViewController
      if let sender = sender as? IndexPath {
        destination.board = boards[(sender as NSIndexPath).row]
      } else if let sender = sender as? UIButton {
        destination.board = boards[sender.tag]
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.separatorStyle = .none
  }
  
  // MARK: UITableViewDataSource
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return dequeueAndSetupBoardCellForIndexPath(indexPath)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return boards.count
  }
  
  // MARK: UITableViewDelegate
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.performSegue(withIdentifier: segueIdentifierThisToBoard, sender: indexPath)
    tableView.deselectRow(at: indexPath, animated: false)
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return BoardCell.heightOfBoardCellForBoard(boards[(indexPath as NSIndexPath).row], withElementWidth: tableViewWidthWithMargins, andDividerHeight: separatorHeightForIndexPath(indexPath))
  }

  // MARK: Setup Helper Functions
  
  /// Makes a BoardCell for the corresponding board in `boards` based on the passed indexPath.
  ///
  /// :param: indexPath The index path of the cell to be created in the table view.
  ///
  /// :returns: The created BoardCell.
  func dequeueAndSetupBoardCellForIndexPath(_ indexPath: IndexPath) -> BoardCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardIdentifiers.boardCell, for: indexPath) as! BoardCell
    cell.makeCellFromBoard(boards[(indexPath as NSIndexPath).row], withButtonTag: (indexPath as NSIndexPath).row, andSeparatorHeight: separatorHeightForIndexPath(indexPath))
    cell.assignDelegatesForCellTo(self)
    return cell
  }
  
  /// Makes a single button UITableViewCell that has a button that responds to `triggerNewBoardSegueOnButton(_:)`.
  ///
  /// :param: indexPath The index path of the cell to be created in the table view.
  ///
  /// :returns: The created NewBoardCell.
  func dequeueAndSetupNewBoardCellForIndexPath(_ indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardIdentifiers.newBoardCell, for: indexPath) 
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
  func presentUnfollowConfirmationActionSheetForBoard(_ board: Board, atIndex index: Int, iPadReference: UIButton?) {
    if objc_getClass("UIAlertController") != nil {
      let actionSheet = UIAlertController(title: board.name, message: nil, preferredStyle: .actionSheet)
      let unfollowAction = UIAlertAction(title: "Leave", style: .default) { _ in
        self.unfollowBoardAtIndex(index) { success in
          if success {
            DispatchQueue.main.async {
              board.following = false
              let boardIndexPath = IndexPath(row: index, section: 0)
              self.tableView.reloadRows(at: [boardIndexPath], with: .none)
            }
          }
        }
      }
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
      }
      actionSheet.addAction(unfollowAction)
      actionSheet.addAction(cancelAction)
      if let iPadReference = iPadReference where UIDevice.current.userInterfaceIdiom == .pad {
        actionSheet.modalPresentationStyle = .popover
        let popPresenter = actionSheet.popoverPresentationController
        popPresenter?.sourceView = iPadReference
        popPresenter?.sourceRect = iPadReference.bounds
      }
      present(actionSheet, animated: true, completion: nil)
    } else {
      let actionSheet = UIActionSheet(title: board.name, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil, otherButtonTitles: "Leave", "Cancel")
      actionSheet.cancelButtonIndex = 1
      actionSheet.tag = index
      if let iPadReference = iPadReference where UIDevice.current.userInterfaceIdiom == .pad {
        actionSheet.show(from: iPadReference.bounds, in: iPadReference, animated: true)
      } else {
        if let tabBar = tabBarController?.tabBar {
          actionSheet.show(from: tabBar)
        }
      }
    }
    
  }
  
  /// Calculates the correct separator height inbetween cells of `tableView`.
  ///
  /// :param: indexPath The index path of the cell in the `tableView`.
  ///
  /// :returns: The correct separator height, as specified by the `dividerHeight` constant.
  func separatorHeightForIndexPath(_ indexPath: IndexPath) -> CGFloat {
    if (indexPath as NSIndexPath).row < boards.count - 1 {
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
  func followBoardAtIndex(_ index: Int, completionHandler: (success: Bool) -> ()) {
    DataManager.sharedInstance.followBoardWithID(boards[index].boardID) { result in
      self.handleSuccessResponse(result, completionHandler: completionHandler)
    }
  }
  
  /// Sends unfollow request to Cillo Servers for the board at index.
  ///
  /// :param: index The index of the board being unfollowed in the boards array.
  /// :param: completionHandler The completion block for the upvote.
  /// :param: success True if follow request was unsuccessful. If error was received, it is false.
  func unfollowBoardAtIndex(_ index: Int, completionHandler: (success: Bool) -> ()) {
    DataManager.sharedInstance.unfollowBoardWithID(boards[index].boardID) { result in
      self.handleSuccessResponse(result, completionHandler: completionHandler)
    }
  }
  
  // MARK: IBActions
  
  /// Expands the image displayed in the button to full screen.
  ///
  /// :param: sender The button that is touched to send this function is a `photoButton` in a BoardCell.
  @IBAction func boardPhotoPressed(_ sender: UIButton) {
    if let photo = sender.backgroundImage(for: UIControlState()) {
      JTSImageViewController.expandImage(photo, toFullScreenFromRoot: self, withSender: sender)
    }
  }
  
  /// Either follows the board at index sender.tag or presents an ActionSheet to unfollow the board.
  ///
  /// :param: sender The button that is touched to send this function is a followButton in a BoardCell.
  @IBAction func followOrUnfollowBoard(_ sender: UIButton) {
    let board = boards[sender.tag]
    if !board.following {
      followBoardAtIndex(sender.tag) { success in
        if success {
          DispatchQueue.main.async {
            board.following = true
            let boardIndexPath = IndexPath(row: sender.tag, section: 0)
            self.tableView.reloadRows(at: [boardIndexPath], with: .none)
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
  @IBAction func triggerBoardSegueOnButton(_ sender: UIButton) {
    performSegue(withIdentifier: segueIdentifierThisToBoard, sender: sender)
  }
  
  /// Triggers segue to NewBoardViewController.
  ///
  /// :param: sender The button that is touched to send this function is the button in the NewBoardCell.
  @IBAction func triggerNewBoardSegueOnButton(_ sender: UIButton) {
    if let tabBarController = tabBarController as? TabViewController {
      tabBarController.performSegue(withIdentifier: SegueIdentifiers.tabToNewBoard, sender: sender)
    }
  }
}

extension MultipleBoardsTableViewController: UIActionSheetDelegate {
  
  func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
    if buttonIndex == 0 {
      unfollowBoardAtIndex(actionSheet.tag) { success in
        if success {
          DispatchQueue.main.async {
            self.boards[actionSheet.tag].following = false
            let boardIndexPath = IndexPath(row: actionSheet.tag, section: 0)
            self.tableView.reloadRows(at: [boardIndexPath], with: .none)
          }
          
        }
      }
    }
  }
}
