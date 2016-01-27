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
  case Value(Box<T>)
  case Error(NSError)
  
  /// Flag representing whether this represents an error with the cillo servers.
  var isCilloError: Bool {
    switch self {
    case .Value(_):
      return false
    case .Error(let error):
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
  case Root(Int?)
  case BoardFeed(Int, Int?)
  case BoardInfo(Int)
  case PostInfo(Int)
  case PostComments(Int)
  case SelfInfo
  case UserInfo
  case UserBoards(Int)
  case UserPosts(Int, Int?)
  case UserComments(Int, Int?)
  case BoardSearch
  case BoardAutocomplete
  case Notifications
  case Conversations
  case ConversationMessages(Int)
  case ConversationPaged(Int, Int)
  case ConversationPoll(Int, Int)
  case UserMessages(Int)
  case TrendingBoards
  
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
  case ReadNotifications
  case SendMessage(Int)
  case ReadInbox
  case FlagPost
  case FlagComment
  case BlockUser
  case SendDeviceToken
  
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
      case .UserBoards(let userID):
        return "/\(vNum)/users/\(userID)/boards\(authString)"
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
      case .Notifications:
        return "/\(vNum)/me/notifications\(authString)"
      case .Conversations:
        return "/\(vNum)/me/conversations\(authString)"
      case .ConversationMessages(let conversationID):
        return "/\(vNum)/conversations/\(conversationID)/messages\(authString)"
      case .ConversationPaged(let conversationID, let beforeMessageID):
        return "/\(vNum)/conversations/\(conversationID)/paged\(authString)&before=\(beforeMessageID)"
      case .ConversationPoll(let conversationID, let afterMessageID):
        return "/\(vNum)/conversations/\(conversationID)/poll\(authString)&after=\(afterMessageID)"
      case .UserMessages(let userID):
        return "/\(vNum)/user/\(userID)/messages\(authString)"
      case .TrendingBoards:
        return "/\(vNum)/me/boards/trending\(authString)"
        
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
      case .ReadNotifications:
        return "/\(vNum)/me/notifications/read\(authString)"
      case .SendMessage(let userID):
        return "/\(vNum)/user/\(userID)/message\(authString)"
      case .ReadInbox:
        return "/\(vNum)/me/inbox/read\(authString)"
      case .FlagPost:
        return "/\(vNum)/report/post\(authString)"
      case .FlagComment:
        return "/\(vNum)/report/comment\(authString)"
      case .BlockUser:
        return "/\(vNum)/block/user\(authString)"
      case .SendDeviceToken:
        return "/\(vNum)/me/ping\(authString)"
      }
    }()
    
    return Router.baseURLString + path
  }
  
  /// Description of the Router call.
  var requestDescription: String {
    switch self {
      // GET
    case .Root(let pgNum):
      let page = pgNum ?? 1
      return "Home Feed Page \(page)"
    case .BoardFeed(let boardID, let pgNum):
      let page = pgNum ?? 1
      return "Board \(boardID) Feed Page \(page)"
    case .BoardInfo(let boardID):
      return "Board \(boardID) Info"
    case .PostInfo(let postID):
      return "Post \(postID) Info"
    case .PostComments(let postID):
      return "Post \(postID) Comments"
    case .SelfInfo:
      return "End User Info"
    case .UserInfo:
      return "User Info"
    case .UserBoards(let userID):
      return "User \(userID) Boards"
    case .UserPosts(let userID, let pgNum):
      let page = pgNum ?? 1
      return "User \(userID) Posts Page \(page)"
    case .UserComments(let userID, let pgNum):
      let page = pgNum ?? 1
      return "User \(userID) Comments Page \(page)"
    case .BoardSearch:
      return "Board Search"
    case .BoardAutocomplete:
      return "Board Autocomplete"
    case .Notifications:
      return "End User Notifications"
    case .Conversations:
      return "End User Conversations"
    case .ConversationMessages(let conversationID):
      return "Conversation \(conversationID) Messages"
    case .ConversationPaged(let conversationID, let beforeMessageID):
      return "Conversation \(conversationID) Paged Before \(beforeMessageID)"
    case .ConversationPoll(let conversationID, let afterMessageID):
      return "Conversation \(conversationID) Polled After \(afterMessageID)"
    case .UserMessages(let userID):
      return "End User Messages with User \(userID)"
    case .TrendingBoards:
      return "End User Trending Boards"
      
      // POST
    case .Register:
      return "Registration"
    case .BoardCreate:
      return "Board Creation"
    case .Login:
      return "Login"
    case .Logout:
      return "Logout"
    case .PostCreate:
      return "Post Creation"
    case .CommentCreate:
      return "Comment Creation"
    case .MediaUpload:
      return "Media Upload"
    case .CommentUp(let commentID):
      return "Comment \(commentID) Upvote"
    case .CommentDown(let commentID):
      return "Comment \(commentID) Downvote"
    case .PostUp(let postID):
      return "Post \(postID) Upvote"
    case .PostDown(let postID):
      return "Post \(postID) Downvote"
    case .BoardFollow(let boardID):
      return "Board \(boardID) Follow"
    case .BoardUnfollow(let boardID):
      return "Board \(boardID) Unfollow"
    case .SelfSettings:
      return "Update End User Settings"
    case .PasswordUpdate:
      return "Update End User Password"
    case .ReadNotifications:
      return "Read End User Notifications"
    case .SendMessage(let userID):
      return "End User Send Message to User \(userID)"
    case .ReadInbox:
      return "Read End User Inbox"
    case .FlagPost:
      return "Flag Post"
    case .FlagComment:
      return "Flag Comment"
    case .BlockUser:
      return "Block User"
    case .SendDeviceToken:
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
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
      } else {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      }
    }
  }
  
  // MARK: Helper Functions
  
  func responseJSONHandlerForRequest<T>(requestType: Router, completionHandler: ValueOrError<T> -> (), valueHandler: JSON -> T) -> ((NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> ()) {
    return { request, response, data, error in
      self.activeRequests--
      if let error = error {
        completionHandler(.Error(error))
      } else if let data: AnyObject = data, json = JSON(rawValue: data) {
        if json["error"] != nil {
          let cilloError = NSError(json: json, requestType: requestType)
          completionHandler(.Error(cilloError))
        } else {
          let value = valueHandler(json)
          completionHandler(.Value(Box<T>(value)))
        }
      } else {
        completionHandler(.Error(NSError.noJSONFromDataError(requestType: requestType)))
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
  func blockUser(user: User, completionHandler: ValueOrError<()> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.BlockUser, completionHandler: completionHandler) { json in
      ()
    }
    activeRequests++
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
  func flagComment(comment: Comment, completionHandler: ValueOrError<()> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.FlagComment, completionHandler: completionHandler) { json in
      ()
    }
    activeRequests++
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
  func flagPost(post: Post, completionHandler: ValueOrError<()> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.FlagPost, completionHandler: completionHandler) { json in
      ()
    }
    activeRequests++
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
  func getEndUserMessagesWithUser(user: User, completionHandler: ValueOrError<[Message]> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.UserMessages(user.userID), completionHandler: completionHandler) { json in
      let messages = json["messages"].arrayValue
      var returnArray = [Message]()
      for message in messages {
        returnArray.append(Message(json: message))
      }
      return returnArray
    }
    activeRequests++
    request(.GET, Router.UserMessages(user.userID), parameters: nil, encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }

  /// Attempts to retrieve the end user's conversations.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: completionHandler A completion block for the network request containing either a tuple of the inboxCount and conversations or an error.
  func getEndUserConversations(completionHandler: ValueOrError<(Int,[Conversation])> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.Conversations, completionHandler: completionHandler) { json in
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
    activeRequests++
    request(.GET, Router.Conversations, parameters: nil, encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to retrieve the end user's trending boards.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: completionHandler A completion block for the network request containing either an array of trending boards or an error.
  func getEndUserTrendingBoards(completionHandler: ValueOrError<[Board]> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.TrendingBoards, completionHandler: completionHandler) { json in
      let boards = json["trending"].arrayValue
      var returnArray = [Board]()
      for board in boards {
        let item = Board(json: board)
        returnArray.append(item)
      }
      return returnArray
    }
    activeRequests++
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
  func getMessagesByConversationID(conversationID: Int, completionHandler: ValueOrError<[Message]> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.ConversationMessages(conversationID), completionHandler: completionHandler) { json in
      let messages = json["messages"].arrayValue
      var returnArray = [Message]()
      for message in messages {
        let item = Message(json: message)
        returnArray.append(item)
      }
      return returnArray
    }
    activeRequests++
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
  func pollConversationByID(conversationID: Int, withMostRecentMessageID messageID: Int, completionHandler: ValueOrError<(Bool,[Message])> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.ConversationPoll(conversationID, messageID), completionHandler: completionHandler) { json in
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
    activeRequests++
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
  func pageConversationByID(conversationID: Int, withOldestMessageID messageID: Int, completionHandler: ValueOrError<(Bool,[Message])> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.ConversationPaged(conversationID, messageID), completionHandler: completionHandler) { json in
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
    activeRequests++
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
  func sendMessage(message: String, toUserWithID userID: Int, completionHandler: ValueOrError<Message> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.SendMessage(userID), completionHandler: completionHandler) { json in
      return Message(json: json["message"])
    }
    activeRequests++
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
  func followBoardWithID(boardID: Int, completionHandler: ValueOrError<()> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.BoardFollow(boardID), completionHandler: completionHandler) { json in
      ()
    }
    activeRequests++
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
  func unfollowBoardWithID(boardID: Int, completionHandler: ValueOrError<()> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.BoardUnfollow(boardID), completionHandler: completionHandler) { json in
      ()
    }
    activeRequests++
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
  func boardsAutocompleteByName(name: String, completionHandler: ValueOrError<[String]> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.BoardAutocomplete, completionHandler: completionHandler) { json in
      let boards = json["results"].arrayValue
      var returnArray = [String]()
      for board in boards {
        let name = board["name"].stringValue
        returnArray.append(name)
      }
      return returnArray
    }
    activeRequests++
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
  func boardsSearchByName(name: String, completionHandler: ValueOrError<[Board]> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.BoardSearch, completionHandler: completionHandler) { json in
      let boards = json["results"].arrayValue
      var returnArray = [Board]()
      for board in boards {
        let item = Board(json: board)
        returnArray.append(item)
      }
      return returnArray
    }
    activeRequests++
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
  func downvoteCommentWithID(commentID: Int, completionHandler: ValueOrError<()> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.CommentDown(commentID), completionHandler: completionHandler) { json in
      ()
    }
    activeRequests++
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
  func upvoteCommentWithID(commentID: Int, completionHandler: ValueOrError<()> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.CommentUp(commentID), completionHandler: completionHandler) { json in
      ()
    }
    activeRequests++
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
  func createBoardWithName(name: String, description: String = "", mediaID: Int = -1, completionHandler: ValueOrError<Board> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.BoardCreate, completionHandler: completionHandler) { json in
      return Board(json: json)
    }
    var parameters: [String: AnyObject] = ["name": name]
    if description != "" {
      parameters["description"] = description
    }
    if mediaID != -1 {
      parameters["photo"] = mediaID
    }
    activeRequests++
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
  func createCommentWithText(text: String, postID: Int, lengthToPost: Int, parentID: Int = -1, completionHandler: ValueOrError<Comment> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.CommentCreate, completionHandler: completionHandler) { json in
      return Comment(json: json, lengthToPost: lengthToPost)
    }
    var parameters: [String: AnyObject] = ["post_id": postID, "data": text]
    if parentID != -1 {
      parameters["parent_id"] = parentID
    }
    activeRequests++
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
  func createPostByBoardID(boardID: Int, text: String, title: String? = nil, mediaID: Int = -1, repostID: Int = -1,  completionHandler: ValueOrError<Post> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.PostCreate, completionHandler: completionHandler) { json in
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
    activeRequests++
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
  func createPostByBoardName(boardName: String, text: String, title: String? = nil, mediaID: Int = -1, repostID: Int = -1, completionHandler: ValueOrError<Post> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.PostCreate, completionHandler: completionHandler) { json in
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
    activeRequests++
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
  func updateEndUserSettingsTo(newName: String = "", newUsername: String = "", newBio: String = "", newMediaID: Int = -1, completionHandler: ValueOrError<User> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.SelfSettings, completionHandler: completionHandler) { json in
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
    activeRequests++
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
  func getBoardByID(boardID: Int, completionHandler: ValueOrError<Board> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.BoardInfo(boardID), completionHandler: completionHandler) { json in
      return Board(json: json)
    }
    activeRequests++
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
  func getBoardFeedByID(boardID: Int, lastPostID: Int?, completionHandler: ValueOrError<[Post]> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.BoardFeed(boardID, lastPostID), completionHandler: completionHandler) { json in
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
    activeRequests++
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
  func getHomeFeed(#lastPostID: Int?, completionHandler: ValueOrError<[Post]> -> ()) {
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
    activeRequests++
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
  func getPostByID(postID: Int, completionHandler: ValueOrError<Post> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.PostInfo(postID), completionHandler: completionHandler) { json in
      if json["repost"] != nil {
        return Repost(json: json)
      } else {
        return Post(json: json)
      }
    }
    activeRequests++
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
  func getCommentsForPost(post: Post, completionHandler: ValueOrError<[Comment]> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.PostComments(post.postID), completionHandler: completionHandler) { json in
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
    activeRequests++
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
  func getEndUserInfo(completionHandler: ValueOrError<User> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.SelfInfo, completionHandler: completionHandler) { json in
      return User(json: json)
    }
    activeRequests++
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
  func getEndUserNotifications(completionHandler: ValueOrError<[Notification]> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.Notifications, completionHandler: completionHandler) { json in
      let notifications = json["notifications"].arrayValue
      var returnArray = [Notification]()
      for notification in notifications {
        let item = Notification(json: notification)
        returnArray.append(item)
      }
      return returnArray
    }
    activeRequests++
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
  func getUserBoardsByID(userID: Int, completionHandler: ValueOrError<[Board]> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.UserBoards(userID), completionHandler: completionHandler) { json in
      let boards = json["boards"].arrayValue
      var returnArray = [Board]()
      for board in boards {
        let item = Board(json: board)
        returnArray.append(item)
      }
      return returnArray
    }
    activeRequests++
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
  func getUserByID(userID: Int, completionHandler: ValueOrError<User> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.UserInfo, completionHandler: completionHandler) { json in
      return User(json: json)
    }
    activeRequests++
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
  func getUserByUsername(username: String, completionHandler: ValueOrError<User> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.UserInfo, completionHandler: completionHandler) { json in
      return User(json: json)
    }
    activeRequests++
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
  func getUserCommentsByID(userID: Int, lastCommentID: Int?, completionHandler: ValueOrError<[Comment]> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.UserComments(userID, lastCommentID), completionHandler: completionHandler) { json in
      let comments = json["comments"].arrayValue
      var returnArray = [Comment]()
      for comment in comments {
        let item = Comment(json: comment, lengthToPost: nil)
        returnArray.append(item)
      }
      return returnArray
    }
    activeRequests++
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
  func getUserPostsByID(userID: Int, lastPostID: Int?, completionHandler: ValueOrError<[Post]> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.UserPosts(userID, lastPostID), completionHandler: completionHandler) { json in
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
    activeRequests++
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
  func uploadImageData(imageData: NSData, completionHandler: ValueOrError<Int> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.MediaUpload, completionHandler: completionHandler) { json in
      return json["media_id"].intValue
    }
    let urlRequest = urlRequestWithComponents(Router.MediaUpload.URLString, parameters: ["hi":"daniel"], imageData: imageData)
    activeRequests++
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
  func loginWithEmail(email: String, andPassword password: String, completionHandler: ValueOrError<(String,User)> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.Login, completionHandler: completionHandler) { json in
      let authToken = json["auth_token"].stringValue
      let user = User(json: json["user"])
      return (authToken, user)
    }
    activeRequests++
    request(.POST, Router.Login, parameters: ["email": email, "password": password], encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to logout of server.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
  func logout(completionHandler: ValueOrError<()> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.Logout, completionHandler: completionHandler) { json in
      ()
    }
    activeRequests++
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
  func downvotePostWithID(postID: Int, completionHandler: ValueOrError<()> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.PostDown(postID), completionHandler: completionHandler) { json in
      ()
    }
    activeRequests++
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
  func upvotePostWithID(postID: Int, completionHandler: ValueOrError<()> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.PostUp(postID), completionHandler: completionHandler) { json in
      ()
    }
    activeRequests++
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
  func registerUserWithName(name: String, username: String, password: String, andEmail email: String, completionHandler: ValueOrError<(String,User)> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.Register, completionHandler: completionHandler) { json in
      let authToken = json["auth_token"].stringValue
      let user = User(json: json["user"])
      return (authToken,user)
    }
    activeRequests++
    request(.POST, Router.Register, parameters: ["username": username, "name": name, "password": password, "email": email], encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to read the end user's inbox on the server.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
  func readEndUserInbox(completionHandler: ValueOrError<()> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.ReadInbox, completionHandler: completionHandler) { json in
      ()
    }
    activeRequests++
    request(.POST, Router.ReadInbox, parameters: nil, encoding: .URL).responseJSON { request, response, data, error in
      responseHandler(request,response,data,error)
    }
  }
  
  /// Attempts to read the end user's notifications on the server.
  ///
  /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
  ///
  /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
  func readEndUserNotifications(completionHandler: ValueOrError<()> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.ReadNotifications, completionHandler: completionHandler) { json in
      ()
    }
    activeRequests++
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
  func sendDeviceToken(token: String, completionHandler: ValueOrError<()> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.SendDeviceToken, completionHandler: completionHandler) { json in
      ()
    }
    activeRequests++
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
  func updatePassword(oldPassword: String, toNewPassword newPassword: String, completionHandler: ValueOrError<()> -> ()) {
    let responseHandler = responseJSONHandlerForRequest(Router.PasswordUpdate, completionHandler: completionHandler) { json in
      ()
    }
    activeRequests++
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