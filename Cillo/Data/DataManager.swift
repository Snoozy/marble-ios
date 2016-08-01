//
//  DataManager.swift
//  Cillo
//
//  Created by Andrew Daley on 12/20/14.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import Foundation
import UIKit

// TODO: Implement page number functionality for comments
// TODO: When private boards are implemented, get rid of createPostByBoardName

// MARK: - Enums

/// Structure that represents the callback of a network call
///
/// * Value(T): Request was successful and Value carries the result of that request.
/// * Error(NSError): Request was unsuccessful and Error carries the error from the request.
enum ValueOrError<T> {
  case value(Box<T>)
  case error(NSError)
  
  /// Flag representing whether this represents an error with the cillo servers.
  var isCilloError: Bool {
    switch self {
    case .value(_):
      return false
    case .error(let error):
      return error.domain == NSError.cilloErrorDomain
    }
  }
}

/// List of possible requests to Cillo servers.
///
/// **Note:** KeychainWrapper must have an Auth Token stored in order for requests to work.
///
/// **Note:** Login and Register do not need an Auth Token.
///
/// GET Requests:
///
/// * Root(Int?): Request to retrieve feed of posts for end user. Parameter is the page number on the home page.
/// * BoardFeed(Int, Int?): Request to retrieve feed of posts for a specific board. Parameter is a board id and the page number on the feed.
/// * BoardInfo(Int): Request to retrieve info about a specific board. Parameter is a board id.
/// * PostInfo(Int): Request to retrieve info about a specific post. Parameter is a post id.
/// * PostComments(Int): Request to retrieve all comments for a specific post. Parameter is a post id.
/// * SelfInfo: Request to retrieve info about the end user.
/// * UserInfo: Request to retrieve info about a specific user. No Parameter is present because either a user id or username may be passed when the request is performed.
/// * UserBoards(Int): Request to retrieve the boards that a specific user follows. Parameter is a user id.
/// * UserPosts(Int, Int?): Request to retrieve the posts that a specific user has made. Parameter is a user id and the page number in the list of posts.
/// * UserComments(Int, Int?): Request to retrieve the comments that a specific user has made. parameter is a user id and the page number in the list of comments.
/// * BoardSearch: Request to retrieve the boards that match a specific search string.
/// * BoardAutocomplete: Request to retrieve board names that autocomplete a specific search string.
/// * Notifications: Request to retrieve the notifications for the end user.
/// * Conversations: Request to retrieve the conversations for the end user.
/// * ConversationMessages(Int): Request to retrieve the last 20 messages of a conversation. Parameter is the id of the conversation.
/// * ConversationPaged(Int, Int): Request to retrieve earlier messages than what is retrieved by ConversationMessages. First parameter is the conversation id. Second parameter is the id of the oldest message already retrieved.
/// * ConversationPoll(Int, Int): Request to retrieve new messages and check if there are any new messages. First parameter is the conversation id. Second parameter is the id of the newest message already retrieved.
/// * UserMessages(Int): Request to retrieve the messages with a specific user. Parameter is the user id of the user that the messages are being retrieved for.
/// * TrendingBoards: Request to retrieve the current list of trending boards for the end user.
///
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
/// * ReadNotifications: Request to read the notifications of the end user.
/// * SendMessage(Int): Request to send a message to a user. Parameter is the id of the user that the end user is sending to.
/// * ReadInbox: Request to read the new messages in the inbox of the end user.
/// * FlagPost: Request to flag a post.
/// * FlagComment: Request to flag a comment.
/// * BlockUser: Request to block a user.
/// * SendDeviceToken: Request to send a device token for push notifications.
enum Router: URLStringConvertible {
  /// Basic URL of website without any request extensions.
  static let baseURLString = "http://api.themarble.co"
  
  //GET
  case root(Int?)
  case boardFeed(Int, Int?)
  case boardInfo(Int)
  case postInfo(Int)
  case postComments(Int)
  case selfInfo
  case userInfo
  case userBoards(Int)
  case userPosts(Int, Int?)
  case userComments(Int, Int?)
  case boardSearch
  case boardAutocomplete
  case notifications
  case conversations
  case conversationMessages(Int)
  case conversationPaged(Int, Int)
  case conversationPoll(Int, Int)
  case userMessages(Int)
  case trendingBoards
  
  //POST
  case register
  case boardCreate
  case login
  case logout
  case postCreate
  case commentCreate
  case mediaUpload
  case commentUp(Int)
  case commentDown(Int)
  case postUp(Int)
  case postDown(Int)
  case boardFollow(Int)
  case boardUnfollow(Int)
  case selfSettings
  case passwordUpdate
  case readNotifications
  case sendMessage(Int)
  case readInbox
  case flagPost
  case flagComment
  case blockUser
  case sendDeviceToken
  
  /// URL of the server call.
  var URLString: String {
    let auth = KeychainWrapper.authToken()
    var authString: String = ""
    if let auth = auth {
      authString = "?auth_token=\(auth)"
    }
    let vNum = "v1"
    let pageString = "&after="
    let path: String = {
      switch self {
        // GET
      case .root(let pgNum):
        let page = pgNum != nil ? "\(pageString)\(pgNum!)" : ""
        return "/\(vNum)/me/feed\(authString)\(page)"
      case .boardFeed(let boardID, let pgNum):
        let page = pgNum != nil ? "\(pageString)\(pgNum!)" : ""
        return "/\(vNum)/boards/\(boardID)/feed\(authString)\(page)"
      case .boardInfo(let boardID):
        return "/\(vNum)/boards/\(boardID)/describe\(authString)"
      case .postInfo(let postID):
        return "/\(vNum)/posts/\(postID)/describe\(authString)"
      case .postComments(let postID):
        return "/\(vNum)/posts/\(postID)/comments\(authString)"
      case .selfInfo:
        return "/\(vNum)/me/describe\(authString)"
      case .userInfo:
        return "/\(vNum)/users/describe\(authString)"
      case .userBoards(let userID):
        return "/\(vNum)/users/\(userID)/boards\(authString)"
      case .userPosts(let userID, let pgNum):
        let page = pgNum != nil ? "\(pageString)\(pgNum!)" : ""
        return "/\(vNum)/users/\(userID)/posts\(authString)\(page)"
      case .userComments(let userID, let pgNum):
        let page = pgNum != nil ? "\(pageString)\(pgNum!)" : ""
        return "/\(vNum)/users/\(userID)/comments\(authString)\(page)"
      case .boardSearch:
        return "/\(vNum)/boards/search\(authString)"
      case .boardAutocomplete:
        return "/\(vNum)/boards/autocomplete\(authString)"
      case .notifications:
        return "/\(vNum)/me/notifications\(authString)"
      case .conversations:
        return "/\(vNum)/me/conversations\(authString)"
      case .conversationMessages(let conversationID):
        return "/\(vNum)/conversations/\(conversationID)/messages\(authString)"
      case .conversationPaged(let conversationID, let beforeMessageID):
        return "/\(vNum)/conversations/\(conversationID)/paged\(authString)&before=\(beforeMessageID)"
      case .conversationPoll(let conversationID, let afterMessageID):
        return "/\(vNum)/conversations/\(conversationID)/poll\(authString)&after=\(afterMessageID)"
      case .userMessages(let userID):
        return "/\(vNum)/user/\(userID)/messages\(authString)"
      case .trendingBoards:
        return "/\(vNum)/me/boards/trending\(authString)"
        
        // POST
      case .register:
        return "/\(vNum)/users/register"
      case .boardCreate:
        return "/\(vNum)/boards/create\(authString)"
      case .login:
        return "/\(vNum)/auth/login"
      case .logout:
        return "/\(vNum)/auth/logout\(authString)"
      case .postCreate:
        return "/\(vNum)/posts/create\(authString)"
      case .commentCreate:
        return "/\(vNum)/comments/create\(authString)"
      case .mediaUpload:
        return "/\(vNum)/media/upload\(authString)"
      case .commentUp(let commentID):
        return "/\(vNum)/comments/\(commentID)/upvote\(authString)"
      case .commentDown(let commentID):
        return "/\(vNum)/comments/\(commentID)/downvote\(authString)"
      case .postUp(let postID):
        return "/\(vNum)/posts/\(postID)/upvote\(authString)"
      case .postDown(let postID):
        return "/\(vNum)/posts/\(postID)/downvote\(authString)"
      case .boardFollow(let boardID):
        return "/\(vNum)/boards/\(boardID)/follow\(authString)"
      case .boardUnfollow(let boardID):
        return "/\(vNum)/boards/\(boardID)/unfollow\(authString)"
      case .selfSettings:
        return "/\(vNum)/me/settings\(authString)"
      case .passwordUpdate:
        return "/\(vNum)/me/settings/password\(authString)"
      case .readNotifications:
        return "/\(vNum)/me/notifications/read\(authString)"
      case .sendMessage(let userID):
        return "/\(vNum)/user/\(userID)/message\(authString)"
      case .readInbox:
        return "/\(vNum)/me/inbox/read\(authString)"
      case .flagPost:
        return "/\(vNum)/report/post\(authString)"
      case .flagComment:
        return "/\(vNum)/report/comment\(authString)"
      case .blockUser:
        return "/\(vNum)/block/user\(authString)"
      case .sendDeviceToken:
        return "/\(vNum)/me/ping\(authString)"
      }
    }()
    
    return Router.baseURLString + path
  }
  
  /// Description of the Router call.
  var requestDescription: String {
    switch self {
      // GET
    case .root(let pgNum):
      let page = pgNum ?? 1
      return "Home Feed Page \(page)"
    case .boardFeed(let boardID, let pgNum):
      let page = pgNum ?? 1
      return "Board \(boardID) Feed Page \(page)"
    case .boardInfo(let boardID):
      return "Board \(boardID) Info"
    case .postInfo(let postID):
      return "Post \(postID) Info"
    case .postComments(let postID):
      return "Post \(postID) Comments"
    case .selfInfo:
      return "End User Info"
    case .userInfo:
      return "User Info"
    case .userBoards(let userID):
      return "User \(userID) Boards"
    case .userPosts(let userID, let pgNum):
      let page = pgNum ?? 1
      return "User \(userID) Posts Page \(page)"
    case .userComments(let userID, let pgNum):
      let page = pgNum ?? 1
      return "User \(userID) Comments Page \(page)"
    case .boardSearch:
      return "Board Search"
    case .boardAutocomplete:
      return "Board Autocomplete"
    case .notifications:
      return "End User Notifications"
    case .conversations:
      return "End User Conversations"
    case .conversationMessages(let conversationID):
      return "Conversation \(conversationID) Messages"
    case .conversationPaged(let conversationID, let beforeMessageID):
      return "Conversation \(conversationID) Paged Before \(beforeMessageID)"
    case .conversationPoll(let conversationID, let afterMessageID):
      return "Conversation \(conversationID) Polled After \(afterMessageID)"
    case .userMessages(let userID):
      return "End User Messages with User \(userID)"
    case .trendingBoards:
      return "End User Trending Boards"
      
      // POST
    case .register:
      return "Registration"
    case .boardCreate:
      return "Board Creation"
    case .login:
      return "Login"
    case .logout:
      return "Logout"
    case .postCreate:
      return "Post Creation"
    case .commentCreate:
      return "Comment Creation"
    case .mediaUpload:
      return "Media Upload"
    case .commentUp(let commentID):
      return "Comment \(commentID) Upvote"
    case .commentDown(let commentID):
      return "Comment \(commentID) Downvote"
    case .postUp(let postID):
      return "Post \(postID) Upvote"
    case .postDown(let postID):
      return "Post \(postID) Downvote"
    case .boardFollow(let boardID):
      return "Board \(boardID) Follow"
    case .boardUnfollow(let boardID):
      return "Board \(boardID) Unfollow"
    case .selfSettings:
      return "Update End User Settings"
    case .passwordUpdate:
      return "Update End User Password"
    case .readNotifications:
      return "Read End User Notifications"
    case .sendMessage(let userID):
      return "End User Send Message to User \(userID)"
    case .readInbox:
      return "Read End User Inbox"
    case .flagPost:
      return "Flag Post"
    case .flagComment:
      return "Flag Comment"
    case .blockUser:
      return "Block User"
    case .sendDeviceToken:
      return "End User Send Device Token"
    }
  }
}

// MARK: - Classes

/// Used for all the network calls to the Cillo servers.
///
/// **Warning:** Always call this class's methods through the sharedInstance.
class DataManager: NSObject {
  
  // MARK: Singleton
  
  /// Singleton network manager.
  ///
  /// **Note:** each network call should start with DataManager.sharedInstance.functionName(_:).
  static let sharedInstance = DataManager()
  
  // MARK: Properties
  
  /// Property used to keep track of the number of active requests happening in the server at a time.
  ///
  /// Property manages the visibility of the network activity indicator in the status bar.
  var activeRequests = 0 {
    didSet {
      if activeRequests > 0 {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
      } else {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
      }
    }
  }
  
  // MARK: Helper Functions
  
  func responseJSONHandlerForRequest<T>(_ requestType: Router, completionHandler: (ValueOrError<T>) -> (), valueHandler: (JSON) -> T) -> ((Foundation.URLRequest, HTTPURLResponse?, AnyObject?, NSError?) -> ()) {
    return { request, response, data, error in
      DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
        self.activeRequests -= 1
        if let error = error {
          completionHandler(.error(error))
        } else if let data: AnyObject = data, json = JSON(rawValue: data) {
          if json["error"] != nil {
            let cilloError = NSError(json: json, requestType: requestType)
            completionHandler(.error(cilloError))
          } else {
            let value = valueHandler(json)
            completionHandler(.value(Box<T>(value)))
          }
        } else {
          completionHandler(.Error(NSError.noJSONFromDataError(requestType: requestType)))
        }
      }
    }
  }
  
  // MARK: Networking Functions
  
  /// Attempts to block the specified user.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: user The user that is to be blocked.
  /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
  func blockUser(_ user: User, completionHandler: (ValueOrError<()>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.blockUser, completionHandler: completionHandler) { json in
      ()
    }
    activeRequests += 1
    request(.POST, Router.BlockUser, parameters: ["user_id": user.userID], encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to flag the specified comment.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: comment The comment that is to be flagged.
  /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
  func flagComment(_ comment: Comment, completionHandler: (ValueOrError<()>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.flagComment, completionHandler: completionHandler) { json in
      ()
    }
    activeRequests += 1
    request(.POST, Router.FlagComment, parameters: ["comment_id": comment.commentID], encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to flag the specified post.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: post The post that is to be flagged.
  /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
  func flagPost(_ post: Post, completionHandler: (ValueOrError<()>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.flagPost, completionHandler: completionHandler) { json in
      ()
    }
    activeRequests += 1
    request(.POST, Router.FlagPost, parameters: ["post_id": post.postID], encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to retrieve the end user's messages with another specified user.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: user The user that the messages are being retrieved for.
  /// :param: completionHandler A completion block for the network request containing either the array of messages (empty if they don't have a conversation yet) in that conversation, or an error.
  func getEndUserMessagesWithUser(_ user: User, completionHandler: (ValueOrError<[Message]>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.userMessages(user.userID), completionHandler: completionHandler) { json in
      let messages = json["messages"].arrayValue
      var returnArray = [Message]()
      for message in messages {
        returnArray.append(Message(json: message))
      }
      return returnArray
    }
    activeRequests += 1
    request(.GET, Router.UserMessages(user.userID), parameters: nil, encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }

  /// Attempts to retrieve the end user's conversations.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: completionHandler A completion block for the network request containing either a tuple of the inboxCount and conversations or an error.
  func getEndUserConversations(_ completionHandler: (ValueOrError<(Int,[Conversation])>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.conversations, completionHandler: completionHandler) { json in
      let conversations = json["conversations"].arrayValue
      var returnArray = [Conversation]()
      for conversation in conversations {
        let item = Conversation(json: conversation)
        returnArray.append(item)
      }
      let count = json["inbox_count"].intValue
      let returnTuple = (count,returnArray)
      return returnTuple
    }
    activeRequests += 1
    request(.GET, Router.Conversations, parameters: nil, encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to retrieve the end user's trending boards.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: completionHandler A completion block for the network request containing either an array of trending boards or an error.
  func getEndUserTrendingBoards(_ completionHandler: (ValueOrError<[Board]>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.trendingBoards, completionHandler: completionHandler) { json in
      let boards = json["trending"].arrayValue
      var returnArray = [Board]()
      for board in boards {
        let item = Board(json: board)
        returnArray.append(item)
      }
      return returnArray
    }
    activeRequests += 1
    request(.GET, Router.TrendingBoards, parameters: nil, encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to retrieve the messages for a specific conversation with the provided id.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: conversationID The id of the conversation that messages are being retrieved for.
  /// :param: completionHandler A completion block for the network request containing either an array of the messages or an error.
  func getMessagesByConversationID(_ conversationID: Int, completionHandler: (ValueOrError<[Message]>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.conversationMessages(conversationID), completionHandler: completionHandler) { json in
      let messages = json["messages"].arrayValue
      var returnArray = [Message]()
      for message in messages {
        let item = Message(json: message)
        returnArray.append(item)
      }
      return returnArray
    }
    activeRequests += 1
    request(.GET, Router.ConversationMessages(conversationID), parameters: nil, encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to retrieve the new messages for a specific conversation with the provided id.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: conversationID The id of the conversation that messages are being retrieved for.
  /// :param: messageID The id of the most recent message in the conversation that has been retrieved already.
  /// :param: completionHandler A completion block for the network request containing either a tuple of a bool stating whether there are new messages and an array of messages, or an error.
  func pollConversationByID(_ conversationID: Int, withMostRecentMessageID messageID: Int, completionHandler: (ValueOrError<(Bool,[Message])>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.conversationPoll(conversationID, messageID), completionHandler: completionHandler) { json in
      let empty = json["status"].stringValue == "empty"
      let messages = json["messages"].arrayValue
      var returnArray = [Message]()
      for message in messages {
        let item = Message(json: message)
        returnArray.append(item)
      }
      let returnTuple = (empty,returnArray)
      return returnTuple
    }
    activeRequests += 1
    request(.GET, Router.ConversationPoll(conversationID, messageID), parameters: nil, encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to retrieve the old messages for a specific conversation with the provided id that were not given by `getMessagesByConversationID:completionHandler:`.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: conversationID The id of the conversation that messages are being retrieved for.
  /// :param: messageID The id of the oldest message in the conversation that has been retrieved already.
  /// :param: completionHandler A completion block for the network request containing either a tuple of a bool stating whether we are done paging and an array of messages, or an error.
  func pageConversationByID(_ conversationID: Int, withOldestMessageID messageID: Int, completionHandler: (ValueOrError<(Bool,[Message])>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.conversationPaged(conversationID, messageID), completionHandler: completionHandler) { json in
      let empty = json["status"].stringValue == "empty"
      let messages = json["messages"].arrayValue
      var returnArray = [Message]()
      for message in messages {
        let item = Message(json: message)
        returnArray.append(item)
      }
      let returnTuple = (empty,returnArray)
      return returnTuple
    }
    activeRequests += 1
    request(.GET, Router.ConversationPaged(conversationID, messageID), parameters: nil, encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }

  /// Attempts to send a message to a specific user with the provided id.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: message The text of the message to send.
  /// :param: userID The id of the user that the message is being sent to.
  /// :param: completionHandler A completion block for the network request containing either the created message or an error.
  func sendMessage(_ message: String, toUserWithID userID: Int, completionHandler: (ValueOrError<Message>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.sendMessage(userID), completionHandler: completionHandler) { json in
      return Message(json: json["message"])
    }
    activeRequests += 1
    request(.POST, Router.SendMessage(userID), parameters: ["content": message], encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to follow a board.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: boardID The id of the board that is being followed.
  /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
  func followBoardWithID(_ boardID: Int, completionHandler: (ValueOrError<()>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.boardFollow(boardID), completionHandler: completionHandler) { json in
      ()
    }
    activeRequests += 1
    request(.POST, Router.BoardFollow(boardID), parameters: nil, encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to unfollow a board.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: boardID The id of the board that is being followed.
  /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
  func unfollowBoardWithID(_ boardID: Int, completionHandler: (ValueOrError<()>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.boardUnfollow(boardID), completionHandler: completionHandler) { json in
      ()
    }
    activeRequests += 1
    request(.POST, Router.BoardUnfollow(boardID), parameters: nil, encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to retrieve a list of board names based on a search term.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: name The name of the board that is being searched.
  /// :param: completionHandler A completion block for the network request containing either an array of board names or an error.
  func boardsAutocompleteByName(_ name: String, completionHandler: (ValueOrError<[String]>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.boardAutocomplete, completionHandler: completionHandler) { json in
      let boards = json["results"].arrayValue
      var returnArray = [String]()
      for board in boards {
        let name = board["name"].stringValue
        returnArray.append(name)
      }
      return returnArray
    }
    activeRequests += 1
    request(.GET, Router.BoardAutocomplete, parameters: ["q": name], encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to a list of boards based on a search term.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: name The name of the board that is being searched.
  /// :param: completionHandler A completion block for the network request containing either an array of boards that were found or an error.
  func boardsSearchByName(_ name: String, completionHandler: (ValueOrError<[Board]>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.boardSearch, completionHandler: completionHandler) { json in
      let boards = json["results"].arrayValue
      var returnArray = [Board]()
      for board in boards {
        let item = Board(json: board)
        returnArray.append(item)
      }
      return returnArray
    }
    activeRequests += 1
    request(.GET, Router.BoardSearch, parameters: ["q": name], encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to downvote a comment.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: commentID The id of the comment that is being downvoted.
  /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
  func downvoteCommentWithID(_ commentID: Int, completionHandler: (ValueOrError<()>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.commentDown(commentID), completionHandler: completionHandler) { json in
      ()
    }
    activeRequests += 1
    request(.POST, Router.CommentDown(commentID), parameters: nil, encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to upvote a comment.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: commentID The id of the comment that is being upvoted.
  /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
  func upvoteCommentWithID(_ commentID: Int, completionHandler: (ValueOrError<()>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.commentUp(commentID), completionHandler: completionHandler) { json in
      ()
    }
    activeRequests += 1
    request(.POST, Router.CommentUp(commentID), parameters: nil, encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to create a new board made by the end user.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: name The name of the new board.
  /// :param: description The description of the board.
  /// :param: * Optional parameter
  /// :param: completionHandler A completion block for the network request containing either the created Board or an error.
  func createBoardWithName(_ name: String, description: String = "", mediaID: Int = -1, completionHandler: (ValueOrError<Board>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.boardCreate, completionHandler: completionHandler) { json in
      return Board(json: json)
    }
    var parameters: [String: AnyObject] = ["name": name]
    if description != "" {
      parameters["description"] = description
    }
    if mediaID != -1 {
      parameters["photo"] = mediaID
    }
    activeRequests += 1
    request(.POST, Router.BoardCreate, parameters: parameters, encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to create a new board made by the end user.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: text The content of the comment.
  /// :param: postID The id of the post that this comment is associated with.
  /// :param: lengthToPost The level of this comment in the comment tree.
  /// :param: * **Note:** Should be equal to parentComment.lengthToPost + 1.
  /// :param: parentID The id of the comment that this comment is reply to.
  /// :param: * Optional Parameter
  /// :param: completionHandler A completion block for the network request containing either the created comment or an error.
  func createCommentWithText(_ text: String, postID: Int, lengthToPost: Int, parentID: Int = -1, completionHandler: (ValueOrError<Comment>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.commentCreate, completionHandler: completionHandler) { json in
      return Comment(json: json, lengthToPost: lengthToPost)
    }
    var parameters: [String: AnyObject] = ["post_id": postID, "data": text]
    if parentID != -1 {
      parameters["parent_id"] = parentID
    }
    activeRequests += 1
    request(.POST, Router.CommentCreate, parameters: parameters, encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to create a new post made by the end user.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: boardID The id of the board that the new post is being posted in.
  /// :param: text The content of the post.
  /// :param: title The title of the post.
  /// :param: * Optional parameter
  /// :param: mediaID The id of the image for this post.
  /// :param: * Optional parameter. Only use if this post should be an image post.
  /// :param: repostID The id of the original post that is being reposted.
  /// :param: * Optional parameter. Only use if this post should be a repost.
  /// :param: completionHandler A completion block for the network request containing either the created Post or an error.
  func createPostByBoardID(_ boardID: Int, text: String, title: String? = nil, mediaID: Int = -1, repostID: Int = -1,  completionHandler: (ValueOrError<Post>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.postCreate, completionHandler: completionHandler) { json in
      if json["repost"] != nil {
        return Repost(json: json)
      } else {
        return Post(json: json)
      }
    }
    var parameters: [String: AnyObject] = ["board_id": boardID, "data": text]
    if repostID != -1 {
      parameters["repost_id"] = repostID
    }
    if title != nil {
      parameters["title"] = title
    }
    if mediaID != -1 {
      parameters["media"] = mediaID
    }
    activeRequests += 1
    request(.POST, Router.PostCreate, parameters: parameters, encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to create a new post made by the end user.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: boardName The name of the board that the new post is being posted in.
  /// :param: text The content of the post.
  /// :param: title The title of the post.
  /// :param: * Optional parameter
  /// :param: mediaID The id of the image for this post.
  /// :param: * Optional parameter. Only use if this post should be an image post.
  /// :param: repostID The id of the original post that is being reposted.
  /// :param: * Optional parameter. Only use if this post should be a repost.
  /// :param: completionHandler A completion block for the network request containing either the created Post or an error.
  func createPostByBoardName(_ boardName: String, text: String, title: String? = nil, mediaID: Int = -1, repostID: Int = -1, completionHandler: (ValueOrError<Post>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.postCreate, completionHandler: completionHandler) { json in
      if json["repost"] != nil {
        return Repost(json: json)
      } else {
        return Post(json: json)
      }
    }
    var parameters: [String: AnyObject] = ["board_name": boardName, "data": text]
    if repostID != -1 {
      parameters["repost_id"] = repostID
    }
    if title != nil {
      parameters["title"] = title
    }
    if mediaID != -1 {
      parameters["media"] = mediaID
    }
    activeRequests += 1
    request(.POST, Router.PostCreate, parameters: parameters, encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
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
  /// :param: newUsername The new username of the end user.
  /// :param: newMediaID The media ID of the new profile picture of the end user.
  /// :param: newBio The new bio of the end user.
  /// :param: completionHandler A completion block for the network request containing either the updated user or an error.
  func updateEndUserSettingsTo(_ newName: String = "", newUsername: String = "", newBio: String = "", newMediaID: Int = -1, completionHandler: (ValueOrError<User>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.selfSettings, completionHandler: completionHandler) { json in
      return User(json: json)
    }
    var parameters: [String: AnyObject] = [:]
    if newName != "" {
      parameters["name"] = newName
    }
    if newUsername != "" {
      parameters["username"] = newUsername
    }
    if newMediaID != -1 {
      parameters["photo"] = newMediaID
    }
    if newBio != "" {
      parameters["bio"] = newBio
    }
    activeRequests += 1
    request(.POST, Router.SelfSettings, parameters: parameters, encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to retrieve info about a board by id.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: boardID The id of the board that the server is describing.
  /// :param: completionHandler A completion block for the network request containing either the board with the given ID or an error.
  func getBoardByID(_ boardID: Int, completionHandler: (ValueOrError<Board>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.boardInfo(boardID), completionHandler: completionHandler) { json in
      return Board(json: json)
    }
    activeRequests += 1
    request(.GET, Router.BoardInfo(boardID), parameters: nil, encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to retrieve a board's feed from server.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: boardID The id of the board that the server is retrieving a feed for.
  /// :param: lastPostID The id of the last post retrieved by a previous call board feed call.
  /// :param: * Nil if this is the first board feed call for a particular controller.
  /// :param: completionHandler A completion block for the network request containing either the array of posts in this board's feed or an error.
  func getBoardFeedByID(_ boardID: Int, lastPostID: Int?, completionHandler: (ValueOrError<[Post]>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.boardFeed(boardID, lastPostID), completionHandler: completionHandler) { json in
      let posts = json["posts"].arrayValue
      var returnArray: [Post] = []
      for post in posts {
        let item: Post = {
          if post["repost"] != nil {
            return Repost(json: post)
          } else {
            return Post(json: post)
          }
          }()
        returnArray.append(item)
      }
      return returnArray
    }
    activeRequests += 1
    request(.GET, Router.BoardFeed(boardID, lastPostID), parameters: nil, encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to retrieve home page from server for the end user. If successful, returns an array of posts on home page in completion block
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: lastPostID The id of the last post retrieved by a previous call home feed call.
  /// :param: * Nil if this is the first board feed call for a particular controller.
  /// :param: completionHandler A completion block for the network request containing either the array of posts in the home feed or an error.
  func getHomeFeed(#lastPostID: Int?, _ completionHandler: (ValueOrError<[Post]>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.Root(lastPostID), completionHandler: completionHandler) { json in
      let posts = json["posts"].arrayValue
      var returnArray = [Post]()
      for post in posts {
        let item: Post = {
          if post["repost"] != nil {
            return Repost(json: post)
          } else {
            return Post(json: post)
          }
          }()
        returnArray.append(item)
      }
      return returnArray
    }
    activeRequests += 1
    request(.GET, Router.Root(lastPostID), parameters: nil, encoding: .URL) .responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to retrieve info about a post by id.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: postID The id of the post that the server is describing.
  /// :param: completionHandler A completion block for the network request containing either the retrieved Post or an error.
  func getPostByID(_ postID: Int, completionHandler: (ValueOrError<Post>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.postInfo(postID), completionHandler: completionHandler) { json in
      if json["repost"] != nil {
        return Repost(json: json)
      } else {
        return Post(json: json)
      }
    }
    activeRequests += 1
    request(.GET, Router.PostInfo(postID), parameters: nil, encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to retrieve tree of comments that have replied to a post with the provided post id.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: post The post that the server is retrieving comments for.
  /// :param: completionHandler A completion block for the network request containing either the comments for the post or an error.
  func getCommentsForPost(_ post: Post, completionHandler: (ValueOrError<[Comment]>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.postComments(post.postID), completionHandler: completionHandler) { json in
      let comments = json["comments"].arrayValue
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
      return returnedTree
    }
    activeRequests += 1
    request(.GET, Router.PostComments(post.postID), parameters: nil, encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to retrieve info about the end user.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: completionHandler A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will be the User object for the end user.
  func getEndUserInfo(_ completionHandler: (ValueOrError<User>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.selfInfo, completionHandler: completionHandler) { json in
      return User(json: json)
    }
    activeRequests += 1
    request(.GET, Router.SelfInfo, parameters: nil, encoding: .URL) .responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to retrieve notifications for the end user.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: completionHandler A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will be the array of Notification objects for the end user.
  func getEndUserNotifications(_ completionHandler: (ValueOrError<[Notification]>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.notifications, completionHandler: completionHandler) { json in
      let notifications = json["notifications"].arrayValue
      var returnArray = [Notification]()
      for notification in notifications {
        let item = Notification(json: notification)
        returnArray.append(item)
      }
      return returnArray
    }
    activeRequests += 1
    request(.GET, Router.Notifications, parameters: nil, encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to retrieve list of boards that a user follows by user id.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: userID The id of the user that the server is retrieving a following list for.
  /// :param: lastBoardID The id of the last board retrieved by a previous user boards call.
  /// :param: * Nil if this is the first user boards call for a particular controller.
  /// :param: completionHandler A completion block for the network request containing either the user's boards or an error.
  func getUserBoardsByID(_ userID: Int, completionHandler: (ValueOrError<[Board]>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.userBoards(userID), completionHandler: completionHandler) { json in
      let boards = json["boards"].arrayValue
      var returnArray = [Board]()
      for board in boards {
        let item = Board(json: board)
        returnArray.append(item)
      }
      return returnArray
    }
    activeRequests += 1
    request(.GET, Router.UserBoards(userID), parameters: nil, encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to retrieve info about a user by id.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: userID The id of the user that the server is describing.
  /// :param: completionHandler A completion block for the network request containing either the retrieved user or an error.
  func getUserByID(_ userID: Int, completionHandler: (ValueOrError<User>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.userInfo, completionHandler: completionHandler) { json in
      return User(json: json)
    }
    activeRequests += 1
    request(.GET, Router.UserInfo, parameters: ["user_id": userID], encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to retrieve info about a user by unique username.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: username The unique username of the user that the server is describing.
  /// :param: completionHandler A completion block for the network request containing either the retrieved user or an error.
  func getUserByUsername(_ username: String, completionHandler: (ValueOrError<User>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.userInfo, completionHandler: completionHandler) { json in
      return User(json: json)
    }
    activeRequests += 1
    request(.GET, Router.UserInfo, parameters: ["username": username], encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to retrieve list of posts that a user has made by user id.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: userID The id of the user that the server is retrieving comments for.
  /// :param: lastCommentID The id of the last comment retrieved by a previous user comments call.
  /// :param: * Nil if this is the first user comments call for a particular controller.
  /// :param: completionHandler A completion block for the network request containing either the user's comments or an error.
  func getUserCommentsByID(_ userID: Int, lastCommentID: Int?, completionHandler: (ValueOrError<[Comment]>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.userComments(userID, lastCommentID), completionHandler: completionHandler) { json in
      let comments = json["comments"].arrayValue
      var returnArray = [Comment]()
      for comment in comments {
        let item = Comment(json: comment, lengthToPost: nil)
        returnArray.append(item)
      }
      return returnArray
    }
    activeRequests += 1
    request(.GET, Router.UserComments(userID, lastCommentID), parameters: nil, encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to retrieve list of posts that a user has made by user id.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: userID The id of the user that the server is retrieving posts for.
  /// :param: lastPostID The id of the last board retrieved by a previous user posts call.
  /// :param: * Nil if this is the first user posts call for a particular controller.
  /// :param: completionHandler A completion block for the network request containing either the user's posts or an error.
  func getUserPostsByID(_ userID: Int, lastPostID: Int?, completionHandler: (ValueOrError<[Post]>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.userPosts(userID, lastPostID), completionHandler: completionHandler) { json in
      let posts = json["posts"].arrayValue
      var returnArray = [Post]()
      for post in posts {
        let item: Post = {
          if post["repost"] != nil {
            return Repost(json: post)
          } else {
            return Post(json: post)
          }
          }()
        returnArray.append(item)
      }
      return returnArray
    }
    activeRequests += 1
    request(.GET, Router.UserPosts(userID, lastPostID), parameters: nil, encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to upload an image.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: imageData The data containing the image to be uploaded.
  /// :param: * The data can be retrieved via UIImageJPEGRepresentation(_:)
  /// :param: completionHandler A completion block for the network request containing either the media id of the image or an error.
  func uploadImageData(_ imageData: Data, completionHandler: (ValueOrError<Int>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.mediaUpload, completionHandler: completionHandler) { json in
      return json["media_id"].intValue
    }
    let urlRequest = urlRequestWithComponents(Router.mediaUpload.URLString, parameters: ["hi":"daniel"], imageData: imageData)
    activeRequests += 1
    upload(urlRequest.0, urlRequest.1)
      .progress { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
        println("bytes written: \(totalBytesWritten), bytes expected: \(totalBytesExpectedToWrite)")
      }
      .responseJSON { request, response, data, error in
        responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to log into server and retrieve an Auth Token.
  ///
  /// **Note:** Set KeychainWrapper's .auth key to the retrieved Auth Token.
  ///
  /// :param: email The email of the user attempting to login to the server.
  /// :param: password The password of the user attempting to login to the server.
  /// :param: completionHandler A completion block for the network request containing either a tuple of the authtoken and the retrieved user or an error.
  func loginWithEmail(_ email: String, andPassword password: String, completionHandler: (ValueOrError<(String,User)>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.login, completionHandler: completionHandler) { json in
      println(json)
      let authToken = json["auth_token"].stringValue
      let user = User(json: json["user"])
      return (authToken, user)
    }
    activeRequests += 1
    request(.POST, Router.Login, parameters: ["email": email, "password": password], encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to logout of server.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
  func logout(_ completionHandler: (ValueOrError<()>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.logout, completionHandler: completionHandler) { json in
      ()
    }
    activeRequests += 1
    request(.POST, Router.Logout, parameters: nil, encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to downvote a post.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: postID The id of the post that is being downvoted.
  /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
  func downvotePostWithID(_ postID: Int, completionHandler: (ValueOrError<()>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.postDown(postID), completionHandler: completionHandler) { json in
      ()
    }
    activeRequests += 1
    request(.POST, Router.PostDown(postID), parameters: nil, encoding: .URL) .responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to upvote a post.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: postID The id of the post that is being upvoted.
  /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
  func upvotePostWithID(_ postID: Int, completionHandler: (ValueOrError<()>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.postUp(postID), completionHandler: completionHandler) { json in
      ()
    }
    activeRequests += 1
    request(.POST, Router.PostUp(postID), parameters: nil, encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to register user with server.
  ///
  /// :param: name The display name of the user attempting to register with the server. This doesn't have to be unique.
  /// :param: username The username of the user attempting to register with the server. This must be unique.
  /// :param: password The password of the user attempting to register with the server.
  /// :param: email The email of the user attempting to register with the server. This must be unique.
  /// :param: completionHandler A completion block for the network request containing either a tuple of the auth token and the retrieved user or an error.
  func registerUserWithName(_ name: String, username: String, password: String, andEmail email: String, completionHandler: (ValueOrError<(String,User)>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.register, completionHandler: completionHandler) { json in
      let authToken = json["auth_token"].stringValue
      let user = User(json: json["user"])
      return (authToken,user)
    }
    activeRequests += 1
    request(.POST, Router.Register, parameters: ["username": username, "name": name, "password": password, "email": email], encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to read the end user's inbox on the server.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
  func readEndUserInbox(_ completionHandler: (ValueOrError<()>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.readInbox, completionHandler: completionHandler) { json in
      ()
    }
    activeRequests += 1
    request(.POST, Router.ReadInbox, parameters: nil, encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to read the end user's notifications on the server.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
  func readEndUserNotifications(_ completionHandler: (ValueOrError<()>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.readNotifications, completionHandler: completionHandler) { json in
      ()
    }
    activeRequests += 1
    request(.POST, Router.ReadNotifications, parameters: nil, encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to send the ios device token to the server for push notifications.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: token The device token for this device.
  /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
  func sendDeviceToken(_ token: String, completionHandler: (ValueOrError<()>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.sendDeviceToken, completionHandler: completionHandler) { json in
      ()
    }
    activeRequests += 1
    request(.POST, Router.SendDeviceToken, parameters: ["device_token": token], encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to update the end user's password on the server.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: oldPassword The old password of the end user.
  /// :param: newPassword The password that the end user wants to change to.
  /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
  func updatePassword(_ oldPassword: String, toNewPassword newPassword: String, completionHandler: (ValueOrError<()>) -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.passwordUpdate, completionHandler: completionHandler) { json in
      ()
    }
    activeRequests += 1
    request(.POST, Router.PasswordUpdate, parameters: ["current": oldPassword, "new": newPassword], encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  // MARK: Upload Helper Functions
  
  /// This function creates the required URLRequestConvertible and NSData we need to use upload
  ///
  /// :param: urlString The url of the request that is being performed.
  /// :param: parameters The parameters attached to the request.
  /// :param: * These are not important for cillo image uploads so anything can be written in this dictionary.
  /// :param: imageData The data of the image to be converted to Alamofire compatible image data.
  /// :returns: The tuple that is needed for the upload function.
  func urlRequestWithComponents(_ urlString: String, parameters: [String: String], imageData: Data) -> (URLRequestConvertible, Data) {
    
    // create url request to send
    var mutableURLRequest = NSMutableURLRequest(url: URL(string: urlString)!)
    mutableURLRequest.httpMethod = Method.POST.rawValue
    let boundaryConstant = "myRandomBoundary12345";
    let contentType = "multipart/form-data;boundary="+boundaryConstant
    mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
    
    // create upload data to send
    let uploadData = NSMutableData()
    
    // add image
    uploadData.append("\r\n--\(boundaryConstant)\r\n".data(using: String.Encoding.utf8)!)
    uploadData.append("Content-Disposition: form-data; name=\"media\"; filename=\"file.jpeg\"\r\n".data(using: String.Encoding.utf8)!)
    uploadData.append("Content-Type: image/jpeg\r\n\r\n".data(using: String.Encoding.utf8)!)
    uploadData.append(imageData)
    
    // add parameters
    for (key, value) in parameters {
      uploadData.append("\r\n--\(boundaryConstant)\r\n".data(using: String.Encoding.utf8)!)
      uploadData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".data(using: String.Encoding.utf8)!)
    }
    uploadData.append("\r\n--\(boundaryConstant)--\r\n".data(using: String.Encoding.utf8)!)
    
    // return URLRequestConvertible and NSData
    return (ParameterEncoding.url.encode(mutableURLRequest, parameters: nil).0, uploadData)
  }
  
}
