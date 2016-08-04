//
//  Router.swift
//  Cillo
//
//  Created by Andrew Daley on 8/3/16.
//  Copyright © 2016 Cillo. All rights reserved.
//

import Foundation

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
    case root(page: Int?)
    case boardFeed(id: Int, page: Int?)
    case boardInfo(id: Int)
    case postInfo(id: Int)
    case postComments(id: Int)
    case selfInfo
    case userInfo
    case userBoards(id: Int)
    case userPosts(id: Int, page: Int?)
    case userComments(id: Int, page: Int?)
    case boardSearch
    case boardAutocomplete
    case notifications
    case conversations
    case conversationMessages(id: Int)
    case conversationPaged(id: Int, oldestMessageId: Int)
    case conversationPoll(id: Int, newestMessageId: Int)
    case userMessages(id: Int)
    case trendingBoards
    
    //POST
    case register
    case boardCreate
    case login
    case logout
    case postCreate
    case commentCreate
    case mediaUpload
    case commentUp(id: Int)
    case commentDown(id: Int)
    case postUp(id: Int)
    case postDown(id: Int)
    case boardFollow(id: Int)
    case boardUnfollow(id: Int)
    case selfSettings
    case passwordUpdate
    case readNotifications
    case sendMessage(toId: Int)
    case readInbox
    case flagPost
    case flagComment
    case blockUser
    case sendDeviceToken
    
    /// URL of the server call.
    var urlString: String {
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
            case .boardFeed(let boardId, let pgNum):
                let page = pgNum != nil ? "\(pageString)\(pgNum!)" : ""
                return "/\(vNum)/boards/\(boardId)/feed\(authString)\(page)"
            case .boardInfo(let boardId):
                return "/\(vNum)/boards/\(boardId)/describe\(authString)"
            case .postInfo(let postId):
                return "/\(vNum)/posts/\(postId)/describe\(authString)"
            case .postComments(let postId):
                return "/\(vNum)/posts/\(postId)/comments\(authString)"
            case .selfInfo:
                return "/\(vNum)/me/describe\(authString)"
            case .userInfo:
                return "/\(vNum)/users/describe\(authString)"
            case .userBoards(let userId):
                return "/\(vNum)/users/\(userId)/boards\(authString)"
            case .userPosts(let userId, let pgNum):
                let page = pgNum != nil ? "\(pageString)\(pgNum!)" : ""
                return "/\(vNum)/users/\(userId)/posts\(authString)\(page)"
            case .userComments(let userId, let pgNum):
                let page = pgNum != nil ? "\(pageString)\(pgNum!)" : ""
                return "/\(vNum)/users/\(userId)/comments\(authString)\(page)"
            case .boardSearch:
                return "/\(vNum)/boards/search\(authString)"
            case .boardAutocomplete:
                return "/\(vNum)/boards/autocomplete\(authString)"
            case .notifications:
                return "/\(vNum)/me/notifications\(authString)"
            case .conversations:
                return "/\(vNum)/me/conversations\(authString)"
            case .conversationMessages(let conversationId):
                return "/\(vNum)/conversations/\(conversationId)/messages\(authString)"
            case .conversationPaged(let conversationId, let beforeMessageId):
                return "/\(vNum)/conversations/\(conversationId)/paged\(authString)&before=\(beforeMessageId)"
            case .conversationPoll(let conversationId, let afterMessageId):
                return "/\(vNum)/conversations/\(conversationId)/poll\(authString)&after=\(afterMessageId)"
            case .userMessages(let userId):
                return "/\(vNum)/user/\(userId)/messages\(authString)"
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
            case .commentUp(let commentId):
                return "/\(vNum)/comments/\(commentId)/upvote\(authString)"
            case .commentDown(let commentId):
                return "/\(vNum)/comments/\(commentId)/downvote\(authString)"
            case .postUp(let postId):
                return "/\(vNum)/posts/\(postId)/upvote\(authString)"
            case .postDown(let postId):
                return "/\(vNum)/posts/\(postId)/downvote\(authString)"
            case .boardFollow(let boardId):
                return "/\(vNum)/boards/\(boardId)/follow\(authString)"
            case .boardUnfollow(let boardId):
                return "/\(vNum)/boards/\(boardId)/unfollow\(authString)"
            case .selfSettings:
                return "/\(vNum)/me/settings\(authString)"
            case .passwordUpdate:
                return "/\(vNum)/me/settings/password\(authString)"
            case .readNotifications:
                return "/\(vNum)/me/notifications/read\(authString)"
            case .sendMessage(let userId):
                return "/\(vNum)/user/\(userId)/message\(authString)"
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
        case .boardFeed(let boardId, let pgNum):
            let page = pgNum ?? 1
            return "Board \(boardId) Feed Page \(page)"
        case .boardInfo(let boardId):
            return "Board \(boardId) Info"
        case .postInfo(let postId):
            return "Post \(postId) Info"
        case .postComments(let postId):
            return "Post \(postId) Comments"
        case .selfInfo:
            return "End User Info"
        case .userInfo:
            return "User Info"
        case .userBoards(let userId):
            return "User \(userId) Boards"
        case .userPosts(let userId, let pgNum):
            let page = pgNum ?? 1
            return "User \(userId) Posts Page \(page)"
        case .userComments(let userId, let pgNum):
            let page = pgNum ?? 1
            return "User \(userId) Comments Page \(page)"
        case .boardSearch:
            return "Board Search"
        case .boardAutocomplete:
            return "Board Autocomplete"
        case .notifications:
            return "End User Notifications"
        case .conversations:
            return "End User Conversations"
        case .conversationMessages(let conversationId):
            return "Conversation \(conversationId) Messages"
        case .conversationPaged(let conversationId, let beforeMessageId):
            return "Conversation \(conversationId) Paged Before \(beforeMessageId)"
        case .conversationPoll(let conversationId, let afterMessageId):
            return "Conversation \(conversationId) Polled After \(afterMessageId)"
        case .userMessages(let userId):
            return "End User Messages with User \(userId)"
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
        case .commentUp(let commentId):
            return "Comment \(commentId) Upvote"
        case .commentDown(let commentId):
            return "Comment \(commentId) Downvote"
        case .postUp(let postId):
            return "Post \(postId) Upvote"
        case .postDown(let postId):
            return "Post \(postId) Downvote"
        case .boardFollow(let boardId):
            return "Board \(boardId) Follow"
        case .boardUnfollow(let boardId):
            return "Board \(boardId) Unfollow"
        case .selfSettings:
            return "Update End User Settings"
        case .passwordUpdate:
            return "Update End User Password"
        case .readNotifications:
            return "Read End User Notifications"
        case .sendMessage(let userId):
            return "End User Send Message to User \(userId)"
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
