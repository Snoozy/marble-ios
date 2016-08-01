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

  /// The height on screen of the cells containing only single labels
  var heightOfSingleLabelCells: CGFloat {
    return 40.0
  }
  
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
  
  override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == segueIdentifierThisToUser {
      let destination = segue.destination as! UserTableViewController
      if let sender = sender as? UIButton {
        destination.user = displayedConversations[sender.tag].otherUser
      }
    } else if segue.identifier == segueIdentifierThisToMessages {
      let destination = segue.destination as! MessagesViewController
      if let sender = sender as? IndexPath {
        destination.conversation = displayedConversations[(sender as NSIndexPath).row]
      } else if let sender = sender as? UIButton {
        destination.conversation = displayedConversations[sender.tag]
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
    if displayedConversations.count != 0 {
      return dequeueAndSetupConversationCellForIndexPath(indexPath)
    } else {
      return dequeueAndSetupNoMessagesCellForIndexPath(indexPath)
    }
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return displayedConversations.count != 0 ? displayedConversations.count : 1
  }
  
  // MARK: UITableViewDelegate
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    if displayedConversations.count != 0 {
      displayedConversations[(indexPath as NSIndexPath).row].read = true
      tableView.reloadRows(at: [indexPath], with: .none)
      performSegue(withIdentifier: segueIdentifierThisToMessages, sender: indexPath)
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if displayedConversations.count != 0 {
      return ConversationCell.heightOfConversationCellForConversation(displayedConversations[(indexPath as NSIndexPath).row], withElementWidth: tableViewWidthWithMargins, andDividerHeight: separatorHeightForIndexPath(indexPath))
    } else {
      return heightOfSingleLabelCells
    }
  }
  
  // MARK: Setup Helper Functions
  
  /// Makes a ConversationCell for the corresponding conversation in `conversations` based on the passed indexPath.
  ///
  /// :param: indexPath The index path of the cell to be created in the table view.
  ///
  /// :returns: The created ConversationCell.
  func dequeueAndSetupConversationCellForIndexPath(_ indexPath: IndexPath) -> ConversationCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardIdentifiers.conversationCell, for: indexPath) as! ConversationCell
    cell.makeCellFromConversation(displayedConversations[(indexPath as NSIndexPath).row], withButtonTag: (indexPath as NSIndexPath).row)
    cell.assignDelegatesForCellTo(self)
    return cell
  }
  
  /// Makes a single label UITableViewCell that says "You have no messages"
  ///
  /// :param: indexPath The index path of the cell to be created in the table view.
  ///
  /// :returns: The created NoMessagesCell.
  func dequeueAndSetupNoMessagesCellForIndexPath(_ indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: StoryboardIdentifiers.noMessagesCell, for: indexPath) 
  }
  
  /// Calculates the correct separator height inbetween cells of `tableView`.
  ///
  /// :param: indexPath The index path of the cell in the `tableView`.
  ///
  /// :returns: The correct separator height, as specified by the `dividerHeight` constant.
  func separatorHeightForIndexPath(_ indexPath: IndexPath) -> CGFloat {
    return (indexPath as NSIndexPath).row != displayedConversations.count - 1 ? dividerHeight : 0
  }

  // MARK: IBActions
  
  /// Triggers segue with identifier segueIdentifierThisToMessage.
  ///
  /// :param: sender The button that is touched to send this function is a nameButton or a photoButton in a ConversationCell.
  @IBAction func triggerMessagesSegueOnButton(_ sender: UIButton) {
    displayedConversations[sender.tag].read = true
    tableView.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .none)
    performSegue(withIdentifier: segueIdentifierThisToMessages, sender: sender)
  }
}
