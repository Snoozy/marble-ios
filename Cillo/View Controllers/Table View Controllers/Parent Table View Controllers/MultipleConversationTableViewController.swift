//
//  MultipleConversationTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 7/3/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Inherit this class for any UITableViewController that is only a table of ConversationCells.
///
/// **Note:** Subclasses must override segueIdentifierThisToUser, and segueIdentifierThisToMessages.
class MultipleConversationTableViewController: CustomTableViewController {
  
  // MARK: Properties

  /// Conversations that will be displayed in the tableView.
  var displayedConversations = [Conversation]()
  
  // MARK: Constants
  
  /// The standard dividerHeight between table view cells in tableView.
  let dividerHeight = DividerScheme.defaultScheme.multipleConversationDividerHeight()

  /// Segue Identifier in Storyboard for segue to UserTableViewController.
  ///
  /// **Note:** Subclasses must override this Constant.
  var segueIdentifierThisToUser: String {
    fatalError("Subclasses of MultipleConversationTableViewController must override segue identifiers")
  }
  
  /// Segue Identifier in Storyboard for segue to MessagesViewController.
  ///
  /// **Note:** Subclasses must override this Constant.
  var segueIdentifierThisToMessages: String {
    fatalError("Subclasses of MultipleConversationTableViewController must override segue identifiers")
  }
  
  // MARK: UIViewController
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == segueIdentifierThisToUser {
      let destination = segue.destinationViewController as! UserTableViewController
      if let sender = sender as? UIButton {
        destination.user = displayedConversations[sender.tag].otherUser
      }
    } else if segue.identifier == segueIdentifierThisToMessages {
      let destination = segue.destinationViewController as! MessagesViewController
      if let sender = sender as? NSIndexPath {
        destination.conversation = displayedConversations[sender.row]
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
    return dequeueAndSetupConversationCellForIndexPath(indexPath)
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return displayedConversations.count
  }
  
  // MARK: UITableViewDelegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
    performSegueWithIdentifier(segueIdentifierThisToMessages, sender: indexPath)
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return ConversationCell.heightOfConversationCellForConversation(displayedConversations[indexPath.row], withElementWidth: tableViewWidthWithMargins, andDividerHeight: separatorHeightForIndexPath(indexPath))
  }
  
  // MARK: Setup Helper Functions
  
  /// Makes a ConversationCell for the corresponding conversation in `conversations` based on the passed indexPath.
  ///
  /// :param: indexPath The index path of the cell to be created in the table view.
  ///
  /// :returns: The created ConversationCell.
  func dequeueAndSetupConversationCellForIndexPath(indexPath: NSIndexPath) -> ConversationCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.conversationCell, forIndexPath: indexPath) as! ConversationCell
    cell.makeCellFromConversation(displayedConversations[indexPath.row], withButtonTag: indexPath.row)
    cell.assignDelegatesForCellTo(self)
    return cell
  }
  
  /// Calculates the correct separator height inbetween cells of `tableView`.
  ///
  /// :param: indexPath The index path of the cell in the `tableView`.
  ///
  /// :returns: The correct separator height, as specified by the `dividerHeight` constant.
  func separatorHeightForIndexPath(indexPath: NSIndexPath) -> CGFloat {
    return indexPath.row != displayedConversations.count - 1 ? dividerHeight : 0
  }

  // MARK: IBActions

  /// Triggers segue with identifier segueIdentifierThisToUser.
  ///
  /// :param: sender The button that is touched to send this function is a nameButton or a photoButton in a ConversationCell.
  @IBAction func triggerUserSegueOnButton(sender: UIButton) {
    performSegueWithIdentifier(segueIdentifierThisToUser, sender: sender)
  }
}
