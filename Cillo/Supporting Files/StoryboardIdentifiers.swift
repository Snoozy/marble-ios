//
//  StoryboardIdentifiers.swift
//  Cillo
//
//  Created by Andrew Daley on 5/14/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import Foundation

/// Has constants for all segue identifiers in the storyboard.
struct SegueIdentifiers {
  
  // MARK: LogInViewController
  
  /// Segue from LogInViewController to RegisterViewController.
  static let loginToRegister = "LoginToRegister"
  
  /// Segue from LogInViewController to TabViewController.
  static let loginToTab = "LoginToTab"
  
  // MARK: SettingsViewController
  
  /// Segue from SettingsViewController to TabViewController.
  static let settingsToTab = "SettingsToTab"
  
  // MARK: RegisterViewController
  
  /// Segue from RegisterViewController to LogInViewController.
  static let registerToLogin = "RegisterToLogin"
  
  // MARK: NewBoardViewController
  
  /// Segue from NewBoardViewController to TabViewController.
  static let newBoardToTab = "NewBoardToTab"
  
  // MARK: NewPostViewController
  
  /// Segue from NewPostViewController to TabViewController.
  static let newPostToTab = "NewPostToTab"
  
  // MARK: NewRepostViewController
  
  /// Segue from NewRepostViewController to TabViewController.
  static let newRepostToTab = "NewRepostToTab"
  
  // MARK: TabViewController
  
  /// Segue from TabViewController to LogInViewController.
  static let tabToLogin = "TabToLogin"
  
  /// Segue from TabViewController to NewBoardViewController.
  static let tabToNewBoard = "TabToNewBoard"
  
  /// Segue from TabViewController to NewPosttViewController.
  static let tabToNewPost = "TabToNewPost"
  
  /// Segue from TabViewController to NewRepostViewController.
  static let tabToNewRepost = "TabToNewRepost"
  
  /// Segue from TabViewController to SettingsViewController.
  static let tabToSettings = "TabToSettings"
  
  // MARK: HomeTableViewController
  
  /// Segue from HomeTableViewController to BoardTableViewController.
  static let homeToBoard = "HomeToBoard"
  
  /// Segue from HomeTableViewController to PostTableViewController.
  static let homeToPost = "HomeToPost"
  
  /// Segue from HomeTableViewController to UserTableViewController.
  static let homeToUser = "HomeToUser"
  
  // MARK: MyBoardsTableViewController
  
  /// Segue from MyBoardsTableViewController to BoardTableViewController.
  static let myBoardsToBoard = "MyBoardsToBoard"
  
  // MARK: MeTableViewController
  
  /// Segue from MeTableViewController to BoardTableViewController.
  static let meToBoard = "MeToBoard"
  
  /// Segue from MeTableViewController to BoardsTableViewController.
  static let meToBoards = "MeToBoards"
  
  /// Segue from MeTableViewController to PostTableViewController.
  static let meToPost = "MeToPost"
  
  // MARK: MyNotificationsViewController
  
  /// Segue from MyNotificationsViewController to PostTableViewController.
  static let myNotificationsToPost = "MyNotifsToPost"
  
  /// Segue from MyNotificationsViewController to UserTableViewController.
  static let myNotificationsToUser = "MyNotifsToUser"
  
  // MARK: PostTableViewController
  
  /// Segue from PostTableViewController to BoardTableViewController.
  static let postToBoard = "PostToBoard"
  
  /// Segue from PostTableViewController to UserTableViewController.
  static let postToUser = "PostToUser"
  
  // MARK: BoardTableViewController
  
  /// Segue from BoardTableViewController to NewPostTableViewController.
  static let boardToNewPost = "BoardToNewPost"
  
  /// Segue from BoardTableViewController to PostTableViewController.
  static let boardToPost = "BoardToPost"
  
  /// Segue from BoardTableViewController to UserTableViewController.
  static let boardToUser = "BoardToUser"
  
  // MARK: UserTableViewController
  
  /// Segue from UserTableViewController to BoardTableViewController.
  static let userToBoard = "UserToBoard"
  
  /// Segue from UserTableViewController to BoardsTableViewController.
  static let userToBoards = "UserToBoards"
  
  /// Segue from UserTableViewController to PostTableViewController.
  static let userToPost = "UserToPost"
  
  // MARK: BoardsTableViewController
  
  /// Segue from BoardsTableViewController to BoardTableViewController.
  static let boardsToBoard = "BoardsToBoard"
}

/// Has constants for all cell identifiers and view controller identifiers in the storyboard.
struct StoryboardIdentifiers {
  
  // MARK: LogInViewController
  
  /// Storyboard identifier for LogInViewController
  static let login = "Login"
  
  // MARK: BoardTableViewController
  
  /// Storyboard identifier for BoardTableViewController.
  static let board = "Board"
  
  // MARK: PostTableViewController
  
  /// Storyboard identifier for PostTableViewController.
  static let post = "Post"
  
  // MARK: PostCell
  
  /// Reuse identifier for PostCell.
  static let postCell = "Post"
  
  // MARK: RepostCell
  
  /// Reuse identifier for RepostCell.
  static let repostCell = "Repost"
  
  // MARK: BoardCell
  
  /// Reuse identifier for BoardCell.
  static let boardCell = "Board"
  
  // MARK: CommentCell
  
  /// Reuse identifier for CommentCell.
  static let commentCell = "Comment"
  
  // MARK: UserCell
  
  /// Reuse identifier for UserCell.
  static let userCell = "User"
  
  // MARK: NotificationCell
  
  /// Reuse identifier for NotificationCell.
  static let notificationCell = "Notification"
  
  // MARK: Single Button Cells
  
  /// Reuse identifier for "See All" UITableViewCell in MultipleBoardsTableViewController tableView.
  static let seeAllCell = "SeeAll"
  
  /// Reuse identifier for "New Board" UITableViewCell in MultipleBoardsTableViewController tableView.
  static let newBoardCell = "NewBoard"
  
  // MARK: Single Label Cells
  
  /// Reuse identifier for "No Comments" UITableViewCell in SinglePostTableViewController tableView and SingleUserTableViewController tableView.
  static let noCommentsCell = "NoComments"
  
  /// Reuse identifier for "Retrieving Comments" UITableViewCell in SinglePostTableViewController tableView.
  static let retrievingCommentsCell = "RetrievingComments"
  
  /// Reuse identifier for "Retrieving Posts" UITableViewCell in SingleUserTableViewController tableView.
  static let retrievingDataCell = "RetrievingData"
  
  /// Reuse identifier for "No Posts" UITableViewCell in SingleBoardTableViewController tableView and SingleUserTableViewController tableView.
  static let noPostsCell = "NoPosts"
  
  /// Reuse identifier for "Retrieving Posts" UITableViewCell in SingleBoardTableViewController tableView.
  static let retrievingPostsCell = "RetrievingPosts"
}