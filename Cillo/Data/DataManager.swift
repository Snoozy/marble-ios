//
//  DataManager.swift
//  Cillo
//
//  Created by Andrew Daley on 12/20/14.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import Foundation
import Alamofire
import SwiftKeychainWrapper

// TODO: Implement page number functionality for comments
// TODO: When private boards are implemented, get rid of createPostByBoardName

// MARK: - Enums

/// List of possible requests to Cillo servers.
///
/// **Note:** KeychainWrapper must have an Auth Token stored in order for requests to work.
///
/// **Note:** Login and Register do not need an Auth Token.
///
/// GET Requests:
///
/// * Root: Request to retrieve feed of posts for end user. Parameter is the page number on the home page.
/// * BoardFeed(Int): Request to retrieve feed of posts for a specific board. Parameter is a board id and the page number on the feed.
/// * BoardInfo(Int): Request to retrieve info about a specific board. Parameter is a board id.
/// * PostInfo(Int): Request to retrieve info about a specific post. Parameter is a post id.
/// * PostComments(Int): Request to retrieve all comments for a specific post. Parameter is a post id.
/// * SelfInfo: Request to retrieve info about the end user.
/// * UserInfo: Request to retrieve info about a specific user. No Parameter is present because either a user id or username may be passed when the request is performed.
/// * UserBoards(Int): Request to retrieve the boards that a specific user follows. Parameter is a user id and the page number on the list of boards.
/// * UserPosts(Int): Request to retrieve the posts that a specific user has made. Parameter is a user id and the page number in the list of posts.
/// * UserComments(Int): Request to retrieve the comments that a specific user has made. parameter is a user id and the page number in the list of comments.
/// * BoardSearch: Request to retrieve the boards that match a specific search string.
/// * BoardAutocomplete: Request to retrieve board names that autocomplete a specific search string.
///
/// POST Requests:
///
/// * Register: Request to register user with server. Does not need an Auth Token.
/// * BoardCreate: Request to create a board.
/// * Login: Request to login to server. Does not need an Auth Token.
/// * Logout: Request to logout of server.
/// * PostCreate: Request to create a post.
/// * CommentCreate: Request to create a comment.
/// * MediaUpload: Request to upload a form of media, such as a photo.
/// * CommentUp(Int): Request to upvote a comment. Parameter is a comment id.
/// * CommentDown(Int): Request to downvote a comment. Parameter is a comment id.
/// * PostUp(Int): Request to upvote a post. Parameter is a post id.
/// * PostDown(Int): Request to downvote a post. Parameter is a post id.
/// * BoardFollow(Int): Request to follow a board. Parameter is a board id.
/// * BoardUnfollow(Int): Request to unfollow a board. Parameter is a board id.
/// * SelfSettings: Request to update the settings of the end user.
/// * PasswordUpdate: Reuqest to update the password of the end user.
enum Router: URLStringConvertible {
  /// Basic URL of website without any request extensions.
  static let baseURLString = "http://api.cillo.co"
  
  //GET
  case Root(Int?)
  case BoardFeed(Int, Int?)
  case BoardInfo(Int)
  case PostInfo(Int)
  case PostComments(Int)
  case SelfInfo
  case UserInfo
  case UserBoards(Int, Int?)
  case UserPosts(Int, Int?)
  case UserComments(Int, Int?)
  case BoardSearch
  case BoardAutocomplete
  
  //POST
  case Register
  case BoardCreate
  case Login
  case Logout
  case PostCreate
  case CommentCreate
  case MediaUpload
  case CommentUp(Int)
  case CommentDown(Int)
  case PostUp(Int)
  case PostDown(Int)
  case BoardFollow(Int)
  case BoardUnfollow(Int)
  case SelfSettings
  case PasswordUpdate
  
  /// URL of the server call.
  var URLString: String {
    let auth = KeychainWrapper.authToken()
    var authString: String = ""
    if let auth = auth {
      authString = "?auth_token=\(auth)"
    }
    let vNum = "v1"
    var pageString = "&after="
    let path: String = {
      switch self {
        // GET
      case .Root(let pgNum):
        let page = pgNum != nil ? "\(pageString)\(pgNum!)" : ""
        return "/\(vNum)/me/feed\(authString)\(page)"
      case .BoardFeed(let boardID, let pgNum):
        let page = pgNum != nil ? "\(pageString)\(pgNum!)" : ""
        return "/\(vNum)/boards/\(boardID)/feed\(authString)\(page)"
      case .BoardInfo(let boardID):
        return "/\(vNum)/boards/\(boardID)/describe\(authString)"
      case .PostInfo(let postID):
        return "/\(vNum)/posts/\(postID)/describe\(authString)"
      case .PostComments(let postID):
        return "/\(vNum)/posts/\(postID)/comments\(authString)"
      case .SelfInfo:
        return "/\(vNum)/me/describe\(authString)"
      case .UserInfo:
        return "/\(vNum)/users/describe\(authString)"
      case .UserBoards(let userID, let pgNum):
        let page = pgNum != nil ? "\(pageString)\(pgNum!)" : ""
        return "/\(vNum)/users/\(userID)/boards\(authString)\(page)"
      case .UserPosts(let userID, let pgNum):
        let page = pgNum != nil ? "\(pageString)\(pgNum!)" : ""
        return "/\(vNum)/users/\(userID)/posts\(authString)\(page)"
      case .UserComments(let userID, let pgNum):
        let page = pgNum != nil ? "\(pageString)\(pgNum!)" : ""
        return "/\(vNum)/users/\(userID)/comments\(authString)\(page)"
      case .BoardSearch:
        return "/\(vNum)/boards/search\(authString)"
      case .BoardAutocomplete:
        return "/\(vNum)/boards/autocomplete\(authString)"
        
        // POST
      case .Register:
        return "/\(vNum)/users/register"
      case .BoardCreate:
        return "/\(vNum)/boards/create\(authString)"
      case .Login:
        return "/\(vNum)/auth/login"
      case .Logout:
        return "/\(vNum)/auth/logout\(authString)"
      case .PostCreate:
        return "/\(vNum)/posts/create\(authString)"
      case .CommentCreate:
        return "/\(vNum)/comments/create\(authString)"
      case .MediaUpload:
        return "/\(vNum)/media/upload\(authString)"
      case .CommentUp(let commentID):
        return "/\(vNum)/comments/\(commentID)/upvote\(authString)"
      case .CommentDown(let commentID):
        return "/\(vNum)/comments/\(commentID)/downvote\(authString)"
      case .PostUp(let postID):
        return "/\(vNum)/posts/\(postID)/upvote\(authString)"
      case .PostDown(let postID):
        return "/\(vNum)/posts/\(postID)/downvote\(authString)"
      case .BoardFollow(let boardID):
        return "/\(vNum)/boards/\(boardID)/follow\(authString)"
      case .BoardUnfollow(let boardID):
        return "/\(vNum)/boards/\(boardID)/unfollow\(authString)"
      case .SelfSettings:
        return "/\(vNum)/me/settings\(authString)"
      case .PasswordUpdate:
        return "/\(vNum)/me/settings/password\(authString)"
      }
    }()
    
    return Router.baseURLString + path
  }
  
}

// MARK: - Classes

/// Used for all the network calls to the Cillo servers.
///
/// **Warning:** Always call this class's methods through the sharedInstance.
class DataManager: NSObject {
  
  // MARK: Constants
  
  /// Singleton network manager.
  ///
  /// **Note:** each network call should start with DataManager.sharedInstance.method(_:).
  class var sharedInstance: DataManager {
    struct Static {
      static var instance: DataManager = DataManager()
    }
    return Static.instance
  }
  
  // MARK: Networking Functions
  
  /// Attempts to follow a board.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: boardID The id of the board that is being followed.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: success If the request was successful, this will be true.
  func boardFollow(boardID: Int, completion:(error: NSError?, success: Bool) -> ()) {
    Alamofire.request(.POST, Router.BoardFollow(boardID), parameters: nil, encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(error: error, success: false)
        } else if let swiftyJSON = JSON(rawValue: data!) {
          if swiftyJSON["error"] != nil {
            let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .BoardFollow(boardID))
            completion(error: cilloError, success: false)
          } else {
            completion(error: nil, success: true)
          }
        } else {
          completion(error: NSError.noJSONFromDataError(requestType: .BoardFollow(boardID)), success: false)
        }
    }
  }
  
  /// Attempts to unfollow a board.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: boardID The id of the board that is being followed.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: success If the request was successful, this will be true.
  func boardUnfollow(boardID: Int, completion:(error: NSError?, success: Bool) -> ()) {
    Alamofire.request(.POST, Router.BoardUnfollow(boardID), parameters: nil, encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(error: error, success: false)
        } else if let swiftyJSON = JSON(rawValue: data!) {
          if swiftyJSON["error"] != nil {
            let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .BoardUnfollow(boardID))
            completion(error: cilloError, success: false)
          } else {
            completion(error: nil, success: true)
          }
        } else {
          completion(error: NSError.noJSONFromDataError(requestType: .BoardUnfollow(boardID)), success: false)
        }
    }
  }
  
  /// Attempts to retrieve a list of board names based on a search term.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: name The name of the board that is being searched.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will be the array of board names.
  func boardsAutocompleteByName(name: String, completion:(error: NSError?, result: [String]?) -> ()) {
    Alamofire.request(.GET, Router.BoardAutocomplete, parameters: ["q": name], encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(error: error, result: nil)
        } else if let swiftyJSON = JSON(rawValue: data!) {
          if swiftyJSON["error"] != nil {
            let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .BoardAutocomplete)
            completion(error: cilloError, result: nil)
          } else {
            let boards = swiftyJSON["results"].arrayValue
            var returnArray = [String]()
            for board in boards {
              let name = board["name"].stringValue
              returnArray.append(name)
            }
            completion(error: nil, result: returnArray)
          }
        } else {
          completion(error: NSError.noJSONFromDataError(requestType: .BoardAutocomplete), result: nil)
        }
    }
  }
  
  /// Attempts to a list of boards based on a search term.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: name The name of the board that is being searched.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will be the array of Boards that were found.
  func boardsSearchByName(name: String, completion:(error: NSError?, result: [Board]?) -> ()) {
    Alamofire.request(.GET, Router.BoardSearch, parameters: ["q": name], encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(error: error, result: nil)
        } else if let swiftyJSON = JSON(rawValue: data!) {
          if swiftyJSON["error"] != nil {
            let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .BoardSearch)
            completion(error: cilloError, result: nil)
          } else {
            let boards = swiftyJSON["results"].arrayValue
            var returnArray = [Board]()
            for board in boards {
              let item = Board(json: board)
              returnArray.append(item)
            }
            completion(error: nil, result: returnArray)
          }
        } else {
          completion(error: NSError.noJSONFromDataError(requestType: .BoardSearch), result: nil)
        }
    }
  }
  
  /// Attempts to downvote a comment.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: commentID The id of the comment that is being downvoted.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: success If the request was successful, this will be true.
  func commentDownvote(commentID: Int, completion:(error: NSError?, success: Bool) -> ()) {
    Alamofire.request(.POST, Router.CommentDown(commentID), parameters: nil, encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(error: error, success: false)
        } else if let swiftyJSON = JSON(rawValue: data!) {
          if swiftyJSON["error"] != nil {
            let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .CommentDown(commentID))
            completion(error: cilloError, success: false)
          } else {
            completion(error: nil, success: true)
          }
        } else {
          completion(error: NSError.noJSONFromDataError(requestType: .CommentDown(commentID)), success: false)
        }
    }
  }
  
  /// Attempts to upvote a comment.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: commentID The id of the comment that is being upvoted.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: success If the request was successful, this will be true.
  func commentUpvote(commentID: Int, completion:(error: NSError?, success: Bool) -> ()) {
    Alamofire.request(.POST, Router.CommentUp(commentID), parameters: nil, encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(error: error, success: false)
        } else if let swiftyJSON = JSON(rawValue: data!) {
          if swiftyJSON["error"] != nil {
            let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .CommentUp(commentID))
            completion(error: cilloError, success: false)
          } else {
            completion(error: nil, success: true)
          }
        } else {
          completion(error: NSError.noJSONFromDataError(requestType: .CommentUp(commentID)), success: false)
        }
    }
  }
  
  /// Attempts to create a new board made by the end user.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: name The name of the new board.
  /// :param: description The description of the board.
  ///
  ///  Nil if the board has no description.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will be the created Board.
  func createBoard(#name: String, description: String?, mediaID: Int?, completion:(error: NSError?, result: Board?) -> ()) {
    var parameters: [String: AnyObject] = ["name": name]
    if let description = description {
      parameters["description"] = description
    }
    if let mediaID = mediaID {
      parameters["photo"] = mediaID
    }
    Alamofire.request(.POST, Router.BoardCreate, parameters: parameters, encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(error: error, result: nil)
        } else if let swiftyJSON = JSON(rawValue: data!) {
          if swiftyJSON["error"] != nil {
            let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .BoardCreate)
            completion(error: cilloError, result: nil)
          } else {
            let board = Board(json: swiftyJSON)
            completion(error: nil, result: board)
          }
        } else {
          completion(error: NSError.noJSONFromDataError(requestType: .BoardCreate), result: nil)
        }
        
    }
  }
  
  /// Attempts to create a new board made by the end user.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: parentID The id of the comment that this comment is reply to.
  /// :param: * Nil if the comment is replying to the post directly.
  /// :param: postID The id of the post that this comment is associated with.
  /// :param: text The content of the comment.
  /// :param: lengthToPost The level of this comment in the comment tree.
  /// :param: * **Note:** Should be equal to parentComment.lengthToPost + 1.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will be the created Comment.
  func createComment(#parentID: Int?, postID: Int, text: String, lengthToPost: Int, completion:(error: NSError?, result: Comment?) -> ()) {
    var parameters: [String: AnyObject] = ["post_id": postID, "data": text]
    if let parentID = parentID {
      parameters["parent_id"] = parentID
    }
    Alamofire.request(.POST, Router.CommentCreate, parameters: parameters, encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(error: error, result: nil)
        } else if let swiftyJSON = JSON(rawValue: data!) {
          if swiftyJSON["error"] != nil {
            let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .CommentCreate)
            completion(error: cilloError, result: nil)
          } else {
            let comment = Comment(json: swiftyJSON, lengthToPost: lengthToPost)
            completion(error: nil, result: comment)
          }
        } else {
          completion(error: NSError.noJSONFromDataError(requestType: .CommentCreate), result: nil)
        }
    }
  }
  
  /// Attempts to create a new post made by the end user.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: repostID The id of the original post that is being reposted.
  ///
  ///  Nil if the post being created is not a repost.
  /// :param: boardID The id of the board that the new post is being posted in.
  /// :param: text The content of the post.
  /// :param: title The title of the post.
  ///
  ///  Nil if the post has no title.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will be the created Post.
  func createPostByBoardID(repostID: Int?, boardID: Int, text: String, title: String?, mediaID: Int?, completion:(error: NSError?, result: Post?) -> ()) {
    var parameters: [String: AnyObject] = ["board_id": boardID, "data": text]
    if let repostID = repostID {
      parameters["repost_id"] = repostID
    }
    if let title = title {
      parameters["title"] = title
    }
    if let mediaID = mediaID {
      parameters["media"] = mediaID
    }
    Alamofire.request(.POST, Router.PostCreate, parameters: parameters, encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(error: error, result: nil)
        } else if let swiftyJSON = JSON(rawValue: data!) {
          if swiftyJSON["error"] != nil {
            let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .PostCreate)
            completion(error: cilloError, result: nil)
          } else {
            var post: Post
            if swiftyJSON["repost"] != nil {
              post = Repost(json: swiftyJSON)
            } else {
              post = Post(json: swiftyJSON)
            }
            completion(error: nil, result: post)
          }
        } else {
          completion(error: NSError.noJSONFromDataError(requestType: .PostCreate), result: nil)
        }
    }
  }
  
  /// Attempts to create a new post made by the end user.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: repostID The id of the original post that is being reposted.
  ///
  ///  Nil if the post being created is not a repost.
  /// :param: boardName The name of the board that the new post is being posted in.
  /// :param: text The content of the post.
  /// :param: title The title of the post.
  ///
  ///  Nil if the post has no title.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will be the created Post.
  func createPostByBoardName(boardName: String, repostID: Int?, text: String, title: String?, mediaID: Int?, completion:(error: NSError?, result: Post?) -> ()) {
    var parameters: [String: AnyObject] = ["board_name": boardName, "data": text]
    if let repostID = repostID {
      parameters["repost_id"] = repostID
    }
    if let title = title {
      parameters["title"] = title
    }
    if let mediaID = mediaID {
      parameters["media"] = mediaID
    }
    Alamofire.request(.POST, Router.PostCreate, parameters: parameters, encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(error: error, result: nil)
        } else if let swiftyJSON = JSON(rawValue: data!) {
          if swiftyJSON["error"] != nil {
            let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .PostCreate)
            completion(error: cilloError, result: nil)
          } else {
            var post: Post
            if swiftyJSON["repost"] != nil {
              post = Repost(json: swiftyJSON)
            } else {
              post = Post(json: swiftyJSON)
            }
            completion(error: nil, result: post)
          }
        } else {
          completion(error: NSError.noJSONFromDataError(requestType: .PostCreate), result: nil)
        }
    }
  }
  
  /// Attempts to update the settings of the end user.
  ///
  /// **Note:** All parameters are optional because settings can be updated independent of each other.
  ///
  /// * At least one parameter should not be nil.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: newName The new name of the end user.
  /// :param: newMediaID The media ID of the new profile picture of the end user.
  /// :param: newBio The new bio of the end user.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will contain the user object of the end user with the updated settings.
  func editSelfSettings(#newName: String?, newUsername: String?, newMediaID: Int?, newBio: String?, completion:(error: NSError?, result: User?) -> ()) {
    var parameters: [String: AnyObject] = [:]
    if let newName = newName {
      parameters["name"] = newName
    }
    if let newUsername = newUsername {
      parameters["username"] = newUsername
    }
    if let newMediaID = newMediaID {
      parameters["photo"] = newMediaID
    }
    if let newBio = newBio {
      parameters["bio"] = newBio
    }
    Alamofire.request(.POST, Router.SelfSettings, parameters: parameters, encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(error: error, result: nil)
        } else if let swiftyJSON = JSON(rawValue: data!) {
          if swiftyJSON["error"] != nil {
            let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .SelfSettings)
            completion(error: cilloError, result: nil)
          } else {
            let user = User(json: swiftyJSON)
            completion(error: nil, result: user)
          }
        } else {
          completion(error: NSError.noJSONFromDataError(requestType: .SelfSettings), result: nil)
        }
    }
  }
  
  /// Attempts to retrieve info about a board by id.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: boardID The id of the board that the server is describing.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will be the Board object for the board with id boardID.
  func getBoardByID(boardID: Int, completion:(error: NSError?, result: Board?) -> ()) {
    Alamofire.request(.GET, Router.BoardInfo(boardID), parameters: nil, encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(error: error, result: nil)
        } else if let swiftyJSON = JSON(rawValue: data!) {
          if swiftyJSON["error"] != nil {
            let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .BoardInfo(boardID))
            completion(error: cilloError, result: nil)
          } else {
            let board = Board(json: swiftyJSON)
            completion(error: nil, result: board)
          }
        } else {
          completion(error: NSError.noJSONFromDataError(requestType: .BoardInfo(boardID)), result: nil)
        }
    }
  }
  
  /// Attempts to retrieve a board's feed from server.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: boardID The id of the board that the server is retrieving a feed for.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will contain the posts to be displayed on the board's feed page.
  func getBoardFeed(#lastPostID: Int?, boardID: Int, completion:(error: NSError?, result: [Post]?) -> ()) {
    Alamofire.request(.GET, Router.BoardFeed(boardID, lastPostID), parameters: nil, encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(error: error, result: nil)
        } else if let swiftyJSON = JSON(rawValue: data!) {
          if swiftyJSON["error"] != nil {
            let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .BoardFeed(boardID, lastPostID))
            completion(error: cilloError, result: nil)
          } else {
            let posts = swiftyJSON["posts"].arrayValue
            var returnArray: [Post] = []
            for post in posts {
              var item: Post
              if post["repost"] != nil {
                item = Repost(json: post)
              } else {
                item = Post(json: post)
              }
              returnArray.append(item)
            }
            completion(error: nil, result: returnArray)
          }
        } else {
          completion(error: NSError.noJSONFromDataError(requestType: .BoardFeed(boardID, lastPostID)), result: nil)
        }
    }
  }
  
  /// Attempts to retrieve home page from server for the end user. If successful, returns an array of posts on home page in completion block
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will contain the posts to be displayed on the home page.
  func getHomePage(#lastPostID: Int?, completion:(error: NSError?, result: [Post]?) -> ()) {
    Alamofire.request(.GET, Router.Root(lastPostID), parameters: nil, encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(error: error, result: nil)
        } else if let swiftyJSON = JSON(rawValue: data!) {
          if swiftyJSON["error"] != nil {
            let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .Root(lastPostID))
            completion(error: cilloError, result: nil)
          } else {
            let posts = swiftyJSON["posts"].arrayValue
            var returnArray = [Post]()
            for post in posts {
              var item: Post
              if post["repost"] != nil {
                item = Repost(json: post)
              } else {
                item = Post(json: post)
              }
              returnArray.append(item)
            }
            completion(error: nil, result: returnArray)
          }
        } else {
          completion(error: NSError.noJSONFromDataError(requestType: .Root(lastPostID)), result: nil)
        }
    }
  }
  
  /// Attempts to retrieve info about a post by id.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: postID The id of the post that the server is describing.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will be the Post object for the post with id postID.
  func getPostByID(postID: Int, completion:(error: NSError?, result: Post?) -> ()) {
    Alamofire.request(.GET, Router.PostInfo(postID), parameters: nil, encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(error: error, result: nil)
        } else if let swiftyJSON = JSON(rawValue: data!) {
          if swiftyJSON["error"] != nil {
            let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .PostInfo(postID))
            completion(error: cilloError, result: nil)
          } else {
            var post: Post
            if swiftyJSON["repost"] != nil {
              post = Repost(json: swiftyJSON)
            } else {
              post = Post(json: swiftyJSON) // pull out the array from the JSON
            }
            completion(error: nil, result: post)
          }
        } else {
          completion(error: NSError.noJSONFromDataError(requestType: .PostInfo(postID)), result: nil)
        }
    }
  }
  
  /// Attempts to retrieve tree of comments that have replied to a post with the provided post id.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: postID The id of the post that the server is retrieving comments for.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will contain the comment tree for the post.
  func getPostCommentsByID(post: Post, completion:(error: NSError?, result: [Comment]?) -> ()) {
    Alamofire.request(.GET, Router.PostComments(post.postID), parameters: nil, encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(error: error, result: nil)
        } else if let swiftyJSON = JSON(rawValue: data!) {
          if swiftyJSON["error"] != nil {
            let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .PostComments(post.postID))
            completion(error: cilloError, result: nil)
          } else {
            let comments = swiftyJSON["comments"].arrayValue
            var rootComments: [Comment] = []
            for comment in comments {
              let item = Comment(json: comment, lengthToPost: 1)
              item.post = post
              rootComments.append(item)
            }
            var returnedTree: [Comment] = []
            for comment in rootComments {
              returnedTree += comment.makeCommentTree()
            }
            completion(error: nil, result: returnedTree)
          }
        } else {
          completion(error: NSError.noJSONFromDataError(requestType: .PostComments(post.postID)), result: nil)
        }
        
    }
  }
  
  /// Attempts to retrieve info about the end user.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will be the User object for the end user.
  func getSelfInfo(completion:(error: NSError?, result: User?) -> ()) {
    Alamofire.request(.GET, Router.SelfInfo, parameters: nil, encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(error: error, result: nil)
        } else if let swiftyJSON = JSON(rawValue: data!) {
          if swiftyJSON["error"] != nil {
            let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .SelfInfo)
            completion(error: cilloError, result: nil)
          } else {
            let user = User(json: swiftyJSON)
            completion(error: nil, result: user)
          }
        } else {
          completion(error: NSError.noJSONFromDataError(requestType: .SelfInfo), result: nil)
        }
    }
  }
  
  /// Attempts to retrieve list of boards that a user follows by user id.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: userID The id of the user that the server is retrieving a following list for.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will contain the boards that the user follows.
  func getUserBoardsByID(#lastBoardID: Int?, userID: Int, completion:(error: NSError?, result: [Board]?) -> ()) {
    Alamofire.request(.GET, Router.UserBoards(userID, lastBoardID), parameters: nil, encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(error: error, result: nil)
        } else if let swiftyJSON = JSON(rawValue: data!) {
          if swiftyJSON["error"] != nil {
            let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .UserBoards(userID, lastBoardID))
            completion(error: cilloError, result: nil)
          } else {
            let boards = swiftyJSON["boards"].arrayValue
            var returnArray = [Board]()
            for board in boards {
              let item = Board(json: board)
              returnArray.append(item)
            }
            completion(error: nil, result: returnArray)
          }
        } else {
          completion(error: NSError.noJSONFromDataError(requestType: .UserBoards(userID, lastBoardID)), result: nil)
        }
    }
  }
  
  /// Attempts to retrieve info about a user by id.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: userID The id of the user that the server is describing.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will be the User object for the user with id userID.
  func getUserByID(userID: Int, completion:(error: NSError?, result: User?) -> ()) {
    Alamofire.request(.GET, Router.UserInfo, parameters: ["user_id": userID], encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(error: error, result: nil)
        } else if let swiftyJSON = JSON(rawValue: data!) {
          if swiftyJSON["error"] != nil {
            let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .UserInfo)
            completion(error: cilloError, result: nil)
          } else {
            let user = User(json: swiftyJSON)
            completion(error: nil, result: user)
          }
        } else {
          completion(error: NSError.noJSONFromDataError(requestType: .UserInfo), result: nil)
        }
    }
  }
  
  /// Attempts to retrieve info about a user by unique username.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: username The unique username of the user that the server is describing.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will be the User object for the user with the given username.
  func getUserByUsername(username: String, completion:(error: NSError?, result: User?) -> ()) {
    Alamofire.request(.GET, Router.UserInfo, parameters: ["username": username], encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(error: error, result: nil)
        } else if let swiftyJSON = JSON(rawValue: data!) {
          if swiftyJSON["error"] != nil {
            let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .UserInfo)
            completion(error: cilloError, result: nil)
          } else {
            let user = User(json: swiftyJSON)
            completion(error: nil, result: user)
          }
        } else {
          completion(error: NSError.noJSONFromDataError(requestType: .UserInfo), result: nil)
        }
    }
  }
  
  /// Attempts to retrieve list of posts that a user has made by user id.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: userID The id of the user that the server is retrieving comments for.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will contain the comments that the user has made.
  func getUserCommentsByID(#lastCommentID: Int?, userID: Int, completion:(error: NSError?, result: [Comment]?) -> ()) {
    Alamofire.request(.GET, Router.UserComments(userID, lastCommentID), parameters: nil, encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(error: error, result: nil)
        } else if let swiftyJSON = JSON(rawValue: data!) {
          if swiftyJSON["error"] != nil {
            let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .UserComments(userID, lastCommentID))
            completion(error: cilloError, result: nil)
          } else {
            let comments = swiftyJSON["comments"].arrayValue
            var returnArray = [Comment]()
            for comment in comments {
              let item = Comment(json: comment, lengthToPost: nil)
              returnArray.append(item)
            }
            completion(error: nil, result: returnArray)
          }
        } else {
          completion(error: NSError.noJSONFromDataError(requestType: .UserComments(userID, lastCommentID)), result: nil)
        }
    }
  }
  
  /// Attempts to retrieve list of posts that a user has made by user id.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: userID The id of the user that the server is retrieving posts for.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will contain the posts that the user has made.
  func getUserPostsByID(#lastPostID: Int?, userID: Int, completion:(error: NSError?, result: [Post]?) -> ()) {
    Alamofire.request(.GET, Router.UserPosts(userID, lastPostID), parameters: nil, encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(error: error, result: nil)
        } else if let swiftyJSON = JSON(rawValue: data!) {
          if swiftyJSON["error"] != nil {
            let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .UserPosts(userID, lastPostID))
            completion(error: cilloError, result: nil)
          } else {
            let posts = swiftyJSON["posts"].arrayValue
            var returnArray = [Post]()
            for post in posts {
              var item: Post
              if post["repost"] != nil {
                item = Repost(json: post)
              } else {
                item = Post(json: post)
              }
              returnArray.append(item)
            }
            completion(error: nil, result: returnArray)
          }
        } else {
          completion(error: NSError.noJSONFromDataError(requestType: .UserPosts(userID, lastPostID)), result: nil)
        }
    }
  }
  
  /// Attempts to upload an image.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: imageData The data containing the image to be uploaded.
  ///
  /// :param: * The data can be retrieved via UIImagePNGRepresentation(_:)
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will contain the id of the image in Cillo servers.
  func imageUpload(imageData: NSData, completion:(error: NSError?, result: Int?) -> ()) {
    let urlRequest = urlRequestWithComponents(Router.MediaUpload.URLString, parameters: ["hi":"daniel"], imageData: imageData)
    upload(urlRequest.0, urlRequest.1)
      .progress { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
        println("bytes written: \(totalBytesWritten), bytes expected: \(totalBytesExpectedToWrite)")
      }
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(error: error, result: nil)
        } else if let swiftyJSON = JSON(rawValue: data!) {
          if swiftyJSON["error"] != nil {
            let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .MediaUpload)
            completion(error: cilloError, result: nil)
          } else {
            let mediaID = swiftyJSON["media_id"].intValue
            completion(error: nil, result: mediaID)
          }
        } else {
          completion(error: NSError.noJSONFromDataError(requestType: .MediaUpload), result: nil)
        }
    }
  }
  
  /// Attempts to log into server and retrieve an Auth Token.
  ///
  /// **Note:** Set KeychainWrapper's .auth key to the retrieved Auth Token.
  ///
  /// :param: username The username of the user attempting to login to the server.
  /// :param: password The password of the user attempting to login to the server.
  /// :param: completion A completion block for the network request.
  /// :param: error If the login was unsuccessful, this will contain the error message.
  /// :param: result If the login was successful, this will be the Auth Token.
  func login(email: String, password: String, completion:(error: NSError?, result: String?) -> ()) {
    Alamofire.request(.POST, Router.Login, parameters: ["email": email, "password": password], encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(error: error, result: nil)
        } else if let swiftyJSON = JSON(rawValue: data!) {
          if swiftyJSON["error"] != nil {
            let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .Login)
            completion(error: cilloError, result: nil)
          } else {
            let authToken = swiftyJSON["auth_token"].stringValue
            completion(error: nil, result: authToken)
          }
        } else {
          completion(error: NSError.noJSONFromDataError(requestType: .Login), result: nil)
        }
    }
  }
  
  /// Attempts to logout of server.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: completion A completion block for the network request.
  /// :param: error If the logout was unsuccessful, this will contain the error message.
  /// :param: success If the logout was successful, this will be true.
  func logout(completion:(error: NSError?, success: Bool) -> ()) {
    Alamofire.request(.POST, Router.Logout, parameters: nil, encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(error: error, success: false)
        } else if let swiftyJSON = JSON(rawValue: data!) {
          if swiftyJSON["error"] != nil {
            let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .Logout)
            completion(error: cilloError, success: false)
          } else {
            completion(error: nil, success: true)
          }
        } else {
          completion(error: NSError.noJSONFromDataError(requestType: .Logout), success: false)
        }
    }
  }
  
  /// Attempts to downvote a post.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: postID The id of the post that is being downvoted.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: success If the request was successful, this will be true.
  func postDownvote(postID: Int, completion:(error: NSError?, success: Bool) -> ()) {
    Alamofire.request(.POST, Router.PostDown(postID), parameters: nil, encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(error: error, success: false)
        } else if let swiftyJSON = JSON(rawValue: data!) {
          if swiftyJSON["error"] != nil {
            let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .PostDown(postID))
            completion(error: cilloError, success: false)
          } else {
            completion(error: nil, success: true)
          }
        } else {
          completion(error: NSError.noJSONFromDataError(requestType: .PostDown(postID)), success: false)
        }
    }
  }
  
  /// Attempts to upvote a post.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: postID The id of the post that is being upvoted.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: success If the request was successful, this will be true.
  func postUpvote(postID: Int, completion:(error: NSError?, success: Bool) -> ()) {
    Alamofire.request(.POST, Router.PostUp(postID), parameters: nil, encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(error: error, success: false)
        } else if let swiftyJSON = JSON(rawValue: data!) {
          if swiftyJSON["error"] != nil {
            let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .PostUp(postID))
            completion(error: cilloError, success: false)
          } else {
            completion(error: nil, success: true)
          }
        } else {
          completion(error: NSError.noJSONFromDataError(requestType: .PostUp(postID)), success: false)
        }
    }
  }
  
  /// Attempts to register user with server.
  ///
  /// :param: username The username of the user attempting to register with the server. This must be unique.
  /// :param: name The display name of the user attempting to register with the server. This doesn't have to be unique.
  /// :param: password The password of the user attempting to register with the server.
  /// :param: email The email of the user attempting to register with the server. This must be unique.
  /// :param: completion A completion block for the network request.
  /// :param: error If the registration was unsuccessful, this will contain the error message.
  /// :param: success If the registration was successful, this will be true.
  func register(username: String, name: String, password: String, email: String, completion:(error: NSError?, success: Bool) -> ()) {
    Alamofire.request(.POST, Router.Register, parameters: ["username": username, "name": name, "password": password, "email": email], encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(error: error, success: false)
        } else if let swiftyJSON = JSON(rawValue: data!) {
          if swiftyJSON["error"] != nil {
            let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .Register)
            completion(error: cilloError, success: false)
          } else {
            completion(error: nil, success: true)
          }
        } else {
          completion(error: NSError.noJSONFromDataError(requestType: .Register), success: false)
        }
    }
  }
  /// Attempts to update the end user's password on the server.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: oldPassword The old password of the end user.
  /// :param: newPassword The password that the end user wants to change to.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: success If the request was successful, this will be true.
  func updatePassword(#oldPassword: String, newPassword: String, completion:(error: NSError?, success: Bool) -> ()) {
    Alamofire.request(.POST, Router.PasswordUpdate, parameters: ["current": oldPassword, "new": newPassword], encoding: .URL)
      .responseJSON { request, response, data, error in
        if let error = error {
          completion(error: error, success: false)
        } else if let swiftyJSON = JSON(rawValue: data!) {
          if swiftyJSON["error"] != nil {
            let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .PasswordUpdate)
            completion(error: cilloError, success: false)
          } else {
            completion(error: nil, success: true)
          }
        } else {
          completion(error: NSError.noJSONFromDataError(requestType: .PasswordUpdate), success: false)
        }
    }
  }
  
  // MARK: Upload Helper Functions
  
  /// This function creates the required URLRequestConvertible and NSData we need to use Alamofire.upload
  ///
  /// :param: urlString The url of the request that is being performed.
  /// :param: parameters The parameters attached to the request.
  /// :param: * These are not important for cillo image uploads so anything can be written in this dictionary.
  /// :param: imageData The data of the image to be converted to Alamofire compatible image data.
  /// :returns: The tuple that is needed for the Alamofire.upload function.
  func urlRequestWithComponents(urlString: String, parameters: [String: String], imageData: NSData) -> (URLRequestConvertible, NSData) {
    
    // create url request to send
    var mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
    mutableURLRequest.HTTPMethod = Method.POST.rawValue
    let boundaryConstant = "myRandomBoundary12345";
    let contentType = "multipart/form-data;boundary="+boundaryConstant
    mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
    
    // create upload data to send
    let uploadData = NSMutableData()
    
    // add image
    uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    uploadData.appendData("Content-Disposition: form-data; name=\"media\"; filename=\"file.jpeg\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    uploadData.appendData("Content-Type: image/jpeg\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    uploadData.appendData(imageData)
    
    // add parameters
    for (key, value) in parameters {
      uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
      uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    
    // return URLRequestConvertible and NSData
    return (ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
  }
}
