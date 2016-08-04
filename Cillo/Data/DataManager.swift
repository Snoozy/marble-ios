//
//  DataManager.swift
//  Cillo
//
//  Created by Andrew Daley on 12/20/14.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

// TODO: Implement page number functionality for comments
// TODO: When private boards are implemented, get rid of createPostByBoardName

// MARK: - Enums

/// Structure that represents the callback of a network call
///
/// * Value(T): Request was successful and Value carries the result of that request.
/// * Error(NSError): Request was unsuccessful and Error carries the error from the request.
enum ValueOrError<T> {
    case value(T)
    case error(ErrorType)
    
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

// MARK: - Classes

/// Used for all the network calls to the Cillo servers.
///
/// **Warning:** Always call this class's methods through the sharedInstance.
class DataManager: NSObject {
  
    // MARK: - Singleton Instance
    
    /// Singleton network manager.
    ///
    /// **Note:** each network call should start with DataManager.sharedInstance.functionName(_:).
    static let sharedInstance = DataManager()
    
    // MARK: - Helper Functions
  
    private func responseJSONHandlerForRequest<T>(_ requestType: Router,
                                                  completionHandler: (ValueOrError<T>) -> (),
                                                  valueHandler: (JSON) -> T)
        -> ((Response<AnyObject, NSError>) -> ()) {
        return { response in
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
                if let error = response.result.error {
                    completionHandler(.error(error))
                } else if let data: AnyObject = response.result.value,
                          let json = JSON(rawValue: data) {
                    if json["error"] != nil {
                        let cilloError = NSError(json: json, requestType: requestType)
                        completionHandler(.error(cilloError))
                    } else {
                        let value = valueHandler(json)
                        completionHandler(.value(value))
                    }
                } else {
                    completionHandler(.error(NSError.noJSONFromDataError(requestType: requestType)))
                }
            }
        }
    }
    
    /// This function creates the required URLRequestConvertible and NSData we need to use upload
    ///
    /// :param: urlString The url of the request that is being performed.
    /// :param: parameters The parameters attached to the request.
    /// :param: * These are not important for cillo image uploads so anything can be written in this dictionary.
    /// :param: imageData The data of the image to be converted to Alamofire compatible image data.
    /// :returns: The tuple that is needed for the upload function.
    private func urlRequestWithComponents(_ urlString: String,
                                          parameters: [String: String],
                                          imageData: Data) -> (URLRequestConvertible, Data) {
        
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
    
    // MARK: - Account Networking Functions
    
    /// Attempts to log into server and retrieve an Auth Token.
    ///
    /// **Note:** Set KeychainWrapper's .auth key to the retrieved Auth Token.
    ///
    /// :param: email The email of the user attempting to login to the server.
    /// :param: password The password of the user attempting to login to the server.
    /// :param: completionHandler A completion block for the network request containing either a tuple of the authtoken and the retrieved user or an error.
    func loginWith(email: String,
                   andPassword password: String,
                   completionHandler: (ValueOrError<(String,User)>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.login,
                                                            completionHandler: completionHandler) { json in
            print(json)
            let authToken = json["auth_token"].stringValue
            let user = User(json: json["user"])
            return (authToken, user)
        }
        request(.POST,
                Router.login,
                parameters: ["email": email, "password": password])
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    /// Attempts to logout of server.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
    func logout(_ completionHandler: (ValueOrError<()>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.logout,
                                                            completionHandler: completionHandler) { json in
            ()
        }
        request(.POST,
                Router.logout)
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    /// Attempts to register user with server.
    ///
    /// :param: name The display name of the user attempting to register with the server. This doesn't have to be unique.
    /// :param: username The username of the user attempting to register with the server. This must be unique.
    /// :param: password The password of the user attempting to register with the server.
    /// :param: email The email of the user attempting to register with the server. This must be unique.
    /// :param: completionHandler A completion block for the network request containing either a tuple of the auth token and the retrieved user or an error.
    func registerWith(name: String,
                      username: String,
                      password: String,
                      andEmail email: String,
                      completionHandler: (ValueOrError<(String,User)>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.register,
                                                            completionHandler: completionHandler) { json in
            let authToken = json["auth_token"].stringValue
            let user = User(json: json["user"])
            return (authToken,user)
        }
        request(.POST,
                Router.register,
                parameters: ["username": username,
                             "name": name,
                             "password": password,
                             "email": email])
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    /// Attempts to send the ios device token to the server for push notifications.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: token The device token for this device.
    /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
    func send(deviceToken token: String, completionHandler: (ValueOrError<()>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.sendDeviceToken,
                                                            completionHandler: completionHandler) { json in
            ()
        }
        request(.POST,
                Router.sendDeviceToken,
                parameters: ["device_token": token])
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    /// Attempts to update the end user's password on the server.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: oldPassword The old password of the end user.
    /// :param: newPassword The password that the end user wants to change to.
    /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
    func update(password oldPassword: String,
                toNewPassword newPassword: String,
                completionHandler: (ValueOrError<()>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.passwordUpdate,
                                                            completionHandler: completionHandler) { json in
            ()
        }
        request(.POST,
                Router.passwordUpdate,
                parameters: ["current": oldPassword, "new": newPassword])
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    // MARK: - Post Info Networking Functions
    
    /// Attempts to retrieve info about a post by id.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: postId The id of the post that the server is describing.
    /// :param: completionHandler A completion block for the network request containing either the retrieved Post or an error.
    func postWith(id postId: Int, completionHandler: (ValueOrError<Post>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.postInfo(id: postId),
                                                            completionHandler: completionHandler) { json in
            if json["repost"] != nil {
                return Repost(json: json)
            } else {
                return Post(json: json)
            }
        }
        request(.GET,
                Router.postInfo(id: postId))
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    /// Attempts to retrieve tree of comments that have replied to a post with the provided post id.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: post The post that the server is retrieving comments for.
    /// :param: completionHandler A completion block for the network request containing either the comments for the post or an error.
    func commentsFor(post: Post, completionHandler: (ValueOrError<[Comment]>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.postComments(id: post.id),
                                                            completionHandler: completionHandler) { json in
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
        request(.GET,
                Router.postComments(id: post.id))
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    // MARK: - Post Interaction Networking Functions
    
    /// Attempts to flag the specified post.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: post The post that is to be flagged.
    /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
    func flag(post: Post, completionHandler: (ValueOrError<()>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.flagPost,
                                                            completionHandler: completionHandler) { json in
            ()
        }
        request(.POST,
                Router.flagPost,
                parameters: ["post_id": post.id])
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    /// Attempts to create a new post made by the end user.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: boardId The id of the board that the new post is being posted in.
    /// :param: text The content of the post.
    /// :param: title The title of the post.
    /// :param: * Optional parameter
    /// :param: mediaId The id of the image for this post.
    /// :param: * Optional parameter. Only use if this post should be an image post.
    /// :param: repostId The id of the original post that is being reposted.
    /// :param: * Optional parameter. Only use if this post should be a repost.
    /// :param: completionHandler A completion block for the network request containing either the created Post or an error.
    func createPostWith(boardId: Int,
                        text: String,
                        title: String? = nil,
                        mediaId: Int = -1,
                        repostId: Int = -1,
                        completionHandler: (ValueOrError<Post>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.postCreate,
                                                            completionHandler: completionHandler) { json in
            if json["repost"] != nil {
                return Repost(json: json)
            } else {
                return Post(json: json)
            }
        }
        var parameters: [String: AnyObject] = ["board_id": boardId, "data": text]
        if repostId != -1 {
            parameters["repost_id"] = repostId
        }
        if title != nil {
            parameters["title"] = title
        }
        if mediaId != -1 {
            parameters["media"] = mediaId
        }
        request(.POST,
                Router.postCreate,
                parameters: parameters)
            .responseJSON { response in
                responseHandler(response)
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
    /// :param: mediaId The id of the image for this post.
    /// :param: * Optional parameter. Only use if this post should be an image post.
    /// :param: repostId The id of the original post that is being reposted.
    /// :param: * Optional parameter. Only use if this post should be a repost.
    /// :param: completionHandler A completion block for the network request containing either the created Post or an error.
    func createPostWith(boardName: String,
                        text: String,
                        title: String? = nil,
                        mediaId: Int = -1,
                        repostId: Int = -1,
                        completionHandler: (ValueOrError<Post>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.postCreate,
                                                            completionHandler: completionHandler) { json in
            if json["repost"] != nil {
                return Repost(json: json)
            } else {
                return Post(json: json)
            }
        }
        var parameters: [String: AnyObject] = ["board_name": boardName, "data": text]
        if repostId != -1 {
            parameters["repost_id"] = repostId
        }
        if title != nil {
            parameters["title"] = title
        }
        if mediaId != -1 {
            parameters["media"] = mediaId
        }
        request(.POST,
                Router.postCreate,
                parameters: parameters)
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    /// Attempts to downvote a post.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: postId The id of the post that is being downvoted.
    /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
    func downvotePostWith(id postId: Int, completionHandler: (ValueOrError<()>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.postDown(id: postId),
                                                            completionHandler: completionHandler) { json in
            ()
        }
        request(.POST,
                Router.postDown(id: postId))
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    /// Attempts to upvote a post.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: postId The id of the post that is being upvoted.
    /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
    func upvotePostWith(id postId: Int, completionHandler: (ValueOrError<()>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.postUp(id: postId),
                                                            completionHandler: completionHandler) { json in
            ()
        }
        request(.POST,
                Router.postUp(id: postId))
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    // MARK: - Comment Interaction Networking Functions
    
    /// Attempts to flag the specified comment.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: comment The comment that is to be flagged.
    /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
    func flag(comment: Comment, completionHandler: (ValueOrError<()>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.flagComment,
                                                            completionHandler: completionHandler) { json in
            ()
        }
        request(.POST,
                Router.flagComment,
                parameters: ["comment_id": comment.id])
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    /// Attempts to downvote a comment.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: commentId The id of the comment that is being downvoted.
    /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
    func downvoteCommentWith(id commentId: Int, completionHandler: (ValueOrError<()>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.commentDown(id: commentId),
                                                            completionHandler: completionHandler) { json in
            ()
        }
        request(.POST,
                Router.commentDown(id: commentId))
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    /// Attempts to upvote a comment.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: commentId The id of the comment that is being upvoted.
    /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
    func upvoteCommentWith(id commentId: Int, completionHandler: (ValueOrError<()>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.commentUp(id: commentId),
                                                            completionHandler: completionHandler) { json in
            ()
        }
        request(.POST,
                Router.commentUp(id: commentId))
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    /// Attempts to create a new board made by the end user.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: text The content of the comment.
    /// :param: postId The id of the post that this comment is associated with.
    /// :param: lengthToPost The level of this comment in the comment tree.
    /// :param: * **Note:** Should be equal to parentComment.lengthToPost + 1.
    /// :param: parentId The id of the comment that this comment is reply to.
    /// :param: * Optional Parameter
    /// :param: completionHandler A completion block for the network request containing either the created comment or an error.
    func createCommentWith(text: String,
                           postId: Int,
                           lengthToPost: Int,
                           parentId: Int = -1,
                           completionHandler: (ValueOrError<Comment>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.commentCreate,
                                                            completionHandler: completionHandler) { json in
            return Comment(json: json, lengthToPost: lengthToPost)
        }
        var parameters: [String: AnyObject] = ["post_id": postId, "data": text]
        if parentId != -1 {
            parameters["parent_id"] = parentId
        }
        request(.POST,
                Router.commentCreate,
                parameters: parameters)
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    // MARK: - Board Info Networking Functions
    
    /// Attempts to retrieve the end user's trending boards.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: completionHandler A completion block for the network request containing either an array of trending boards or an error.
    func trendingBoards(_ completionHandler: (ValueOrError<[Board]>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.trendingBoards,
                                                            completionHandler: completionHandler) { json in
            let boards = json["trending"].arrayValue
            var returnArray = [Board]()
            for board in boards {
                let item = Board(json: board)
                returnArray.append(item)
            }
            return returnArray
        }
        request(.GET,
                Router.trendingBoards)
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    /// Attempts to retrieve a list of board names based on a search term.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: name The name of the board that is being searched.
    /// :param: completionHandler A completion block for the network request containing either an array of board names or an error.
    func autocompleteBoardsBy(name: String,
                              completionHandler: (ValueOrError<[String]>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.boardAutocomplete,
                                                            completionHandler: completionHandler) { json in
            let boards = json["results"].arrayValue
            var returnArray = [String]()
            for board in boards {
                let name = board["name"].stringValue
                returnArray.append(name)
            }
            return returnArray
        }
        request(.GET,
                Router.boardAutocomplete,
                parameters: ["q": name])
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    /// Attempts to a list of boards based on a search term.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: name The name of the board that is being searched.
    /// :param: completionHandler A completion block for the network request containing either an array of boards that were found or an error.
    func searchBoardsBy(name: String, completionHandler: (ValueOrError<[Board]>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.boardSearch,
                                                            completionHandler: completionHandler) { json in
            let boards = json["results"].arrayValue
            var returnArray = [Board]()
            for board in boards {
                let item = Board(json: board)
                returnArray.append(item)
            }
            return returnArray
        }
        request(.GET,
                Router.boardSearch,
                parameters: ["q": name])
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    /// Attempts to retrieve info about a board by id.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: boardId The id of the board that the server is describing.
    /// :param: completionHandler A completion block for the network request containing either the board with the given Id or an error.
    func boardWith(id boardId: Int, completionHandler: (ValueOrError<Board>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.boardInfo(id: boardId),
                                                            completionHandler: completionHandler) { json in
            return Board(json: json)
        }
        request(.GET,
                Router.boardInfo(id: boardId))
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    // MARK: - Board Interaction Networking Functions
    
    /// Attempts to follow a board.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: boardId The id of the board that is being followed.
    /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
    func followBoardWith(id boardId: Int, completionHandler: (ValueOrError<()>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.boardFollow(id: boardId),
                                                            completionHandler: completionHandler) { json in
            ()
        }
        request(.POST,
                Router.boardFollow(id: boardId))
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    /// Attempts to unfollow a board.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: boardId The id of the board that is being followed.
    /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
    func unfollowBoardWith(id boardId: Int, completionHandler: (ValueOrError<()>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.boardUnfollow(id: boardId),
                                                            completionHandler: completionHandler) { json in
            ()
        }
        request(.POST,
                Router.boardUnfollow(id: boardId))
            .responseJSON { response in
                responseHandler(response)
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
    func createBoardWith(name: String,
                         description: String = "",
                         mediaId: Int = -1,
                         completionHandler: (ValueOrError<Board>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.boardCreate,
                                                            completionHandler: completionHandler) { json in
            return Board(json: json)
        }
        var parameters: [String: AnyObject] = ["name": name]
        if description != "" {
            parameters["description"] = description
        }
        if mediaId != -1 {
            parameters["photo"] = mediaId
        }
        request(.POST,
                Router.boardCreate,
                parameters: parameters)
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    /// Attempts to retrieve a board's feed from server.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: boardId The id of the board that the server is retrieving a feed for.
    /// :param: lastPostId The id of the last post retrieved by a previous call board feed call.
    /// :param: * Nil if this is the first board feed call for a particular controller.
    /// :param: completionHandler A completion block for the network request containing either the array of posts in this board's feed or an error.
    func boardFeedWith(id boardId: Int,
                       lastPostId: Int?,
                       completionHandler: (ValueOrError<[Post]>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.boardFeed(id: boardId,
                                                                             page: lastPostId),
                                                            completionHandler: completionHandler) { json in
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
        request(.GET,
                Router.boardFeed(id: boardId, page: lastPostId))
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    // MARK: - User Info Networking Functions
    
    /// Attempts to retrieve home page from server for the end user. If successful, returns an array of posts on home page in completion block
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: lastPostId The id of the last post retrieved by a previous call home feed call.
    /// :param: * Nil if this is the first board feed call for a particular controller.
    /// :param: completionHandler A completion block for the network request containing either the array of posts in the home feed or an error.
    func homeFeed(lastPostId: Int?, _ completionHandler: (ValueOrError<[Post]>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.root(page: lastPostId),
                                                            completionHandler: completionHandler) { json in
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
        request(.GET,
                Router.root(page: lastPostId))
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    /// Attempts to retrieve info about the end user.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: completionHandler A completion block for the network request.
    /// :param: error If the request was unsuccessful, this will contain the error message.
    /// :param: result If the request was successful, this will be the User object for the end user.
    func endUser(_ completionHandler: (ValueOrError<User>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.selfInfo,
                                                            completionHandler: completionHandler) { json in
            return User(json: json)
        }
        request(.GET,
                Router.selfInfo)
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    /// Attempts to retrieve list of boards that a user follows by user id.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: userId The id of the user that the server is retrieving a following list for.
    /// :param: lastBoardId The id of the last board retrieved by a previous user boards call.
    /// :param: * Nil if this is the first user boards call for a particular controller.
    /// :param: completionHandler A completion block for the network request containing either the user's boards or an error.
    func userBoardsWith(id userId: Int, completionHandler: (ValueOrError<[Board]>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.userBoards(id: userId),
                                                            completionHandler: completionHandler) { json in
            let boards = json["boards"].arrayValue
            var returnArray = [Board]()
            for board in boards {
                let item = Board(json: board)
                returnArray.append(item)
            }
            return returnArray
        }
        request(.GET,
                Router.userBoards(id: userId))
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    /// Attempts to retrieve info about a user by id.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: userId The id of the user that the server is describing.
    /// :param: completionHandler A completion block for the network request containing either the retrieved user or an error.
    func userWith(id userId: Int, completionHandler: (ValueOrError<User>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.userInfo,
                                                            completionHandler: completionHandler) { json in
            return User(json: json)
        }
        request(.GET,
                Router.userInfo,
                parameters: ["user_id": userId])
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    /// Attempts to retrieve list of posts that a user has made by user id.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: userId The id of the user that the server is retrieving comments for.
    /// :param: lastCommentId The id of the last comment retrieved by a previous user comments call.
    /// :param: * Nil if this is the first user comments call for a particular controller.
    /// :param: completionHandler A completion block for the network request containing either the user's comments or an error.
    func userCommentsWith(id userId: Int,
                             lastCommentId: Int?,
                             completionHandler: (ValueOrError<[Comment]>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.userComments(id: userId,
                                                                                page: lastCommentId),
                                                            completionHandler: completionHandler) { json in
            let comments = json["comments"].arrayValue
            var returnArray = [Comment]()
            for comment in comments {
                let item = Comment(json: comment, lengthToPost: nil)
                returnArray.append(item)
            }
            return returnArray
        }
        request(.GET,
                Router.userComments(id: userId, page: lastCommentId))
            .responseJSON { response in
                    responseHandler(response)
        }
    }
    
    /// Attempts to retrieve list of posts that a user has made by user id.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: userId The id of the user that the server is retrieving posts for.
    /// :param: lastPostId The id of the last board retrieved by a previous user posts call.
    /// :param: * Nil if this is the first user posts call for a particular controller.
    /// :param: completionHandler A completion block for the network request containing either the user's posts or an error.
    func userPostsWith(id userId: Int,
                       lastPostId: Int?,
                       completionHandler: (ValueOrError<[Post]>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.userPosts(id: userId,
                                                                             page: lastPostId),
                                                            completionHandler: completionHandler) { json in
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
        request(.GET,
                Router.userPosts(id: userId, page: lastPostId))
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    // MARK: - User Interaction Networking Functions
    
    /// Attempts to block the specified user.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: user The user that is to be blocked.
    /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
    func block(user: User, completionHandler: (ValueOrError<()>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.blockUser,
                                                            completionHandler: completionHandler) { json in
            ()
        }
        request(.POST,
                Router.blockUser,
                parameters: ["user_id": user.id])
            .responseJSON { response in
                responseHandler(response)
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
    /// :param: newMediaId The media Id of the new profile picture of the end user.
    /// :param: newBio The new bio of the end user.
    /// :param: completionHandler A completion block for the network request containing either the updated user or an error.
    func updateUserSettingsTo(newName: String = "",
                              newUsername: String = "",
                              newBio: String = "",
                              newMediaId: Int = -1,
                              completionHandler: (ValueOrError<User>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.selfSettings,
                                                            completionHandler: completionHandler) { json in
            return User(json: json)
        }
        var parameters: [String: AnyObject] = [:]
        if newName != "" {
            parameters["name"] = newName
        }
        if newUsername != "" {
            parameters["username"] = newUsername
        }
        if newMediaId != -1 {
            parameters["photo"] = newMediaId
        }
        if newBio != "" {
            parameters["bio"] = newBio
        }
        request(.POST,
                Router.selfSettings,
                parameters: parameters)
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    /// Attempts to retrieve info about a user by unique username.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: username The unique username of the user that the server is describing.
    /// :param: completionHandler A completion block for the network request containing either the retrieved user or an error.
    func userWith(username: String, completionHandler: (ValueOrError<User>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.userInfo,
                                                            completionHandler: completionHandler) { json in
            return User(json: json)
        }
        request(.GET,
                Router.userInfo,
                parameters: ["username": username])
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    // MARK: - Conversation Info Networking Functions
    
    /// Attempts to retrieve the end user's messages with another specified user.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: user The user that the messages are being retrieved for.
    /// :param: completionHandler A completion block for the network request containing either the array of messages (empty if they don't have a conversation yet) in that conversation, or an error.
    func messagesWith(user: User, completionHandler: (ValueOrError<[Message]>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.userMessages(id: user.id),
                                                            completionHandler: completionHandler) { json in
            let messages = json["messages"].arrayValue
            var returnArray = [Message]()
            for message in messages {
                returnArray.append(Message(json: message))
            }
            return returnArray
        }
        request(.GET,
                Router.userMessages(id: user.id))
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    /// Attempts to retrieve the end user's conversations.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: completionHandler A completion block for the network request containing either a tuple of the inboxCount and conversations or an error.
    func conversations(_ completionHandler: (ValueOrError<(Int,[Conversation])>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.conversations,
                                                            completionHandler: completionHandler) { json in
            let conversations = json["conversations"].arrayValue
            var returnArray = [Conversation]()
            for conversation in conversations {
                let item = Conversation(json: conversation)
                returnArray.append(item)
            }
            let count = json["inbox_count"].intValue
            let returnTuple = (count, returnArray)
            return returnTuple
        }
        request(.GET,
                Router.conversations)
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    /// Attempts to retrieve the messages for a specific conversation with the provided id.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: conversationId The id of the conversation that messages are being retrieved for.
    /// :param: completionHandler A completion block for the network request containing either an array of the messages or an error.
    func coonversationMessagesWith(id conversationId: Int,
                      completionHandler: (ValueOrError<[Message]>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.conversationMessages(id: conversationId),
                                                            completionHandler: completionHandler) { json in
            let messages = json["messages"].arrayValue
            var returnArray = [Message]()
            for message in messages {
                let item = Message(json: message)
                returnArray.append(item)
            }
            return returnArray
        }
        request(.GET,
                Router.conversationMessages(id: conversationId))
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    /// Attempts to retrieve the new messages for a specific conversation with the provided id.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: conversationId The id of the conversation that messages are being retrieved for.
    /// :param: messageId The id of the most recent message in the conversation that has been retrieved already.
    /// :param: completionHandler A completion block for the network request containing either a tuple of a bool stating whether there are new messages and an array of messages, or an error.
    func pollConversationWith(id conversationId: Int,
                              withMostRecentMessageId messageId: Int,
                              completionHandler: (ValueOrError<(Bool,[Message])>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.conversationPoll(id: conversationId,
                                                                                    newestMessageId: messageId),
                                                            completionHandler: completionHandler) { json in
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
        request(.GET,
                Router.conversationPoll(id: conversationId, newestMessageId: messageId))
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    /// Attempts to retrieve the old messages for a specific conversation with the provided id that were not given by `getMessagesByConversationId:completionHandler:`.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: conversationId The id of the conversation that messages are being retrieved for.
    /// :param: messageId The id of the oldest message in the conversation that has been retrieved already.
    /// :param: completionHandler A completion block for the network request containing either a tuple of a bool stating whether we are done paging and an array of messages, or an error.
    func pageConversationWith(id conversationId: Int,
                              withOldestMessageId messageId: Int,
                              completionHandler: (ValueOrError<(Bool,[Message])>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.conversationPaged(id: conversationId,
                                                                                     oldestMessageId: messageId),
                                                            completionHandler: completionHandler) { json in
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
        request(.GET,
                Router.conversationPaged(id: conversationId, oldestMessageId: messageId))
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    // MARK: - Conversation Interaction Networking Functions
    
    /// Attempts to send a message to a specific user with the provided id.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: message The text of the message to send.
    /// :param: userId The id of the user that the message is being sent to.
    /// :param: completionHandler A completion block for the network request containing either the created message or an error.
    func send(message: String,
              toUserWithId userId: Int,
              completionHandler: (ValueOrError<Message>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.sendMessage(toId: userId),
                                                            completionHandler: completionHandler) { json in
            return Message(json: json["message"])
        }
        request(.POST,
                Router.sendMessage(toId: userId),
                parameters: ["content": message])
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    /// Attempts to read the end user's inbox on the server.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
    func readInbox(_ completionHandler: (ValueOrError<()>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.readInbox,
                                                            completionHandler: completionHandler) { json in
            ()
        }
        request(.POST,
                Router.readInbox)
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    // MARK: - Notification Info Networking Functions
    
    /// Attempts to retrieve notifications for the end user.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: completionHandler A completion block for the network request.
    /// :param: error If the request was unsuccessful, this will contain the error message.
    /// :param: result If the request was successful, this will be the array of Notification objects for the end user.
    func notifications(_ completionHandler: (ValueOrError<[Notification]>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.notifications,
                                                            completionHandler: completionHandler) { json in
            let notifications = json["notifications"].arrayValue
            var returnArray = [Notification]()
            for notification in notifications {
                let item = Notification(json: notification)
                returnArray.append(item)
            }
            return returnArray
        }
        request(.GET,
                Router.notifications).responseJSON { response in
                    responseHandler(response)
        }
    }
    
    // MARK: - Notification Interaction Networking Functions
    
    /// Attempts to read the end user's notifications on the server.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: completionHandler A completion block for the network request containing either an empty value or an error.
    func readNotifications(_ completionHandler: (ValueOrError<()>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.readNotifications,
                                                            completionHandler: completionHandler) { json in
            ()
        }
        request(.POST,
                Router.readNotifications)
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
    // MARK: - Image Uploading Networking Functions
    
    /// Attempts to upload an image.
    ///
    /// **Warning:** KeychainWrapper's .auth key must have an auth token stored.
    ///
    /// :param: imageData The data containing the image to be uploaded.
    /// :param: * The data can be retrieved via UIImageJPEGRepresentation(_:)
    /// :param: completionHandler A completion block for the network request containing either the media id of the image or an error.
    func uploadImageData(_ imageData: Data, completionHandler: (ValueOrError<Int>) -> ()) {
        let responseHandler = responseJSONHandlerForRequest(Router.mediaUpload,
                                                            completionHandler: completionHandler) { json in
            return json["media_id"].intValue
        }
        let urlRequest = urlRequestWithComponents(Router.mediaUpload.URLString,
                                                  parameters: ["hi":"daniel"],
                                                  imageData: imageData)
        upload(urlRequest.0, urlRequest.1)
            .progress { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                print("bytes written: \(totalBytesWritten), bytes expected: \(totalBytesExpectedToWrite)")
            }
            .responseJSON { response in
                responseHandler(response)
        }
    }
    
}
