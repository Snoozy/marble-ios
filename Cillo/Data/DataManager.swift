//
//  DataManager.swift
//  Cillo
//
//  Created by Andrew Daley on 12/20/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import Foundation
import Alamofire

// TODO: Implement ?page=2 functionality for feeds (defaults to 1).
// TODO: Possibly implement &page_size=50 functionality for feeds (defaults to 20).
// TODO: When private groups are implemented, get rid of createPostByGroupName

// MARK: - Enums

/// List of possible requests to Cillo servers.
///
/// **Note:** NSUserDefaults must have an Auth Token stored in order for requests to work.
///
/// **Note:** Login and Register do not need an Auth Token.
///
/// GET Requests:
///
/// * Root: Request to retrieve feed of posts for logged in user.
/// * GroupFeed(Int): Request to retrieve feed of posts for a specific group. Parameter is a group id.
/// * GroupInfo(Int): Request to retrieve info about a specific group. Parameter is a group id.
/// * PostInfo(Int): Request to retrieve info about a specific post. Parameter is a post id.
/// * PostComments(Int): Request to retrieve all comments for a specific post. Parameter is a post id.
/// * SelfInfo: Request to retrieve info about the logged in user.
/// * UserInfo: Request to retrieve info about a specific user. No Parameter is present because either a user id or username may be passed when the request is performed.
/// * UserGroups(Int): Request to retrieve the groups that a specific user follows. Parameter is a user id.
/// * UserPosts(Int): Request to retrieve the posts that a specific user has made. Parameter is a user id.
/// * UserComments(Int): Request to retrieve the comments that a specific user has made. parameter is a user id.
///
/// POST Requests:
///
/// * Register: Request to register user with server. Does not need an Auth Token.
/// * GroupCreate: Request to create a group.
/// * Login: Request to login to server. Does not need an Auth Token.
/// * Logout: Request to logout of server.
/// * PostCreate: Request to create a post.
/// * CommentCreate: Request to create a comment.
/// * MediaUpload: Request to upload a form of media, such as a photo.
/// * CommentUp(Int): Request to upvote a comment. Parameter is a comment id.
/// * CommentDown(Int): Request to downvote a comment. Parameter is a comment id.
/// * PostUp(Int): Request to upvote a post. Parameter is a post id.
/// * PostDown(Int): Request to downvote a post. Parameter is a post id.
/// * GroupFollow(Int): Request to follow a group. Parameter is a group id.
/// * GroupUnfollow(Int): Request to unfollow a group. Parameter is a group id.
enum Router: URLStringConvertible {
  /// Basic URL of website without any request extensions.
  static let baseURLString = "https://api.cillo.co"
  
  //GET
  case Root // DONE
  case GroupFeed(Int) // DONE
  case GroupInfo(Int) // DONE
  case PostInfo(Int) // DONE
  case PostComments(Int) // DONE
  case SelfInfo // DONE
  case UserInfo //DONE
  case UserGroups(Int) // DONE
  case UserPosts(Int) // DONE
  case UserComments(Int) // DONE
  
  //POST
  case Register // DONE
  case GroupCreate // DONE
  case Login // DONE
  case Logout // DONE
  case PostCreate // DONE
  case CommentCreate // DONE
  case MediaUpload // DONE
  case CommentUp(Int) // DONE
  case CommentDown(Int) // DONE
  case PostUp(Int) // DONE
  case PostDown(Int) // DONE
  case GroupFollow(Int) // DONE
  case GroupUnfollow(Int) // DONE
  case SelfSettings // DONE
  
  /// Part of URL after the baseURLString.
  var URLString: String {
    let auth = NSUserDefaults.standardUserDefaults().stringForKey(NSUserDefaults.Auth)
    var authString: String = ""
    if let auth = auth {
      authString = "?auth_token=\(auth)"
    }
    let vNum = "v1"
    var pageString = "&page=1"
    let path: String = {
      switch self {
        //GET
      case .Root:
        return "/\(vNum)/me/feed\(authString)\(pageString)"
      case .GroupFeed(let groupID):
        return "/\(vNum)/groups/\(groupID)/feed\(authString)"
      case .GroupInfo(let groupID):
        return "/\(vNum)/groups/\(groupID)/describe\(authString)"
      case .PostInfo(let postID):
        return "/\(vNum)/posts/\(postID)/describe\(authString)"
      case .PostComments(let postID):
        return "/\(vNum)/posts/\(postID)/comments\(authString)\(pageString)"
      case .SelfInfo:
        return "/\(vNum)/me/describe\(authString)"
      case .UserInfo:
        return "/\(vNum)/users/describe\(authString)"
      case .UserGroups(let userID):
        return "/\(vNum)/users/\(userID)/groups\(authString)"
      case .UserPosts(let userID):
        return "/\(vNum)/users/\(userID)/posts\(authString)\(pageString)"
      case .UserComments(let userID):
        return "/\(vNum)/users/\(userID)/comments\(authString)"
        
        //POST
      case .Register:
        return "/\(vNum)/users/register"
      case .GroupCreate:
        return "/\(vNum)/groups/create\(authString)"
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
      case .GroupFollow(let groupID):
        return "/\(vNum)/groups/\(groupID)/follow\(authString)"
      case .GroupUnfollow(let groupID):
        return "/\(vNum)/groups/\(groupID)/unfollow\(authString)"
      case .SelfSettings:
        return "/\(vNum)/me/settings\(authString)"
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
  
  /// Attempts to log into server and retrieve an Auth Token.
  ///
  /// **Note:** Set NSUserDefaults's .Auth key to the retrieved Auth Token.
  ///
  /// :param: username The username of the user attempting to login to the server.
  /// :param: password The password of the user attempting to login to the server.
  /// :param: completion A completion block for the network request.
  /// :param: error If the login was unsuccessful, this will contain the error message.
  /// :param: result If the login was successful, this will be the Auth Token.
  func login(username: String, password: String, completion:(error: NSError?, result: String?) -> Void) {
    Alamofire
      .request(.POST, Router.Login, parameters: ["username":username, "password":password], encoding: .URL)
      .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
        if error != nil {
          completion(error: error!, result: nil)
        } else {
          if let swiftyJSON = JSON(rawValue: data!) {
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
  func register(username: String, name: String, password: String, email: String, completion:(error: NSError?, success: Bool) -> Void) {
    Alamofire
      .request(.POST, Router.Register, parameters: ["username":username, "name":name, "password":password, "email":email], encoding: .URL)
      .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
        if error != nil {
          completion(error: error!, success: false)
        } else {
          if let swiftyJSON = JSON(rawValue: data!) {
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
  }
  
  /// Attempts to logout of server.
  ///
  /// **Warning:** NSUserDefaults's .Auth key must have an Auth Token stored.
  ///
  /// :param: completion A completion block for the network request.
  /// :param: error If the logout was unsuccessful, this will contain the error message.
  /// :param: success If the logout was successful, this will be true.
  func logout(completion:(error: NSError?, success: Bool) -> Void) {
    Alamofire
      .request(.POST, Router.Logout, parameters: nil, encoding: .URL)
      .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
        if error != nil {
          completion(error: error!, success: false)
        } else {
          if let swiftyJSON = JSON(rawValue: data!) {
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
  }
  
  /// Attempts to retrieve home page from server for the logged in user. If successful, returns an array of posts on home page in completion block
  ///
  /// **Warning:** NSUserDefaults's .Auth key must have an Auth Token stored.
  ///
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will contain the posts to be displayed on the home page.
  func getHomePage(completion:(error: NSError?, result: [Post]?) -> Void) {
    Alamofire
      .request(.GET, Router.Root, parameters: nil, encoding: .URL)
      .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
        if error != nil {
          completion(error: error!, result: nil)
        } else {
          if let swiftyJSON = JSON(rawValue: data!) {
            if swiftyJSON["error"] != nil {
              let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .Root)
              completion(error: cilloError, result: nil)
            } else {
              let posts = swiftyJSON["posts"].arrayValue
              var returnArray: [Post] = []
              for post in posts {
                var item: Post
                if post["repost"].boolValue {
                  item = Repost(json: post)
                } else {
                  item = Post(json: post)
                }
                returnArray.append(item)
              }
              completion(error: nil, result: returnArray)
            }
          } else {
            completion(error: NSError.noJSONFromDataError(requestType: .Root), result: nil)
          }
        }
      }
  }
  
  /// Attempts to retrieve a group's feed from server.
  ///
  /// **Warning:** NSUserDefaults's .Auth key must have an Auth Token stored.
  ///
  /// :param: groupID The id of the group that the server is retrieving a feed for.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will contain the posts to be displayed on the group's feed page.
  func getGroupFeed(groupID: Int, completion:(error: NSError?, result: [Post]?) -> Void) {
    Alamofire
      .request(.GET, Router.GroupFeed(groupID), parameters: nil, encoding: .URL)
      .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
        if error != nil {
          completion(error: error!, result: nil)
        } else {
          if let swiftyJSON = JSON(rawValue: data!) {
            if swiftyJSON["error"] != nil {
              let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .GroupFeed(groupID))
              completion(error: cilloError, result: nil)
            } else {
              let posts = swiftyJSON["posts"].arrayValue
              var returnArray: [Post] = []
              for post in posts {
                var item: Post
                if post["repost"].boolValue {
                  item = Repost(json: post)
                } else {
                  item = Post(json: post)
                }
                returnArray.append(item)
              }
              completion(error: nil, result: returnArray)
            }
          } else {
            completion(error: NSError.noJSONFromDataError(requestType: .GroupFeed(groupID)), result: nil)
          }
        }
      }
  }
  
  /// Attempts to retrieve info about the logged in user.
  ///
  /// **Warning:** NSUserDefaults's .Auth key must have an Auth Token stored.
  ///
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will be the User object for the logged in user.
  func getSelfInfo(completion:(error: NSError?, result: User?) -> Void) {
    Alamofire
      .request(.GET, Router.SelfInfo, parameters: nil, encoding: .URL)
      .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
        if error != nil {
          completion(error: error!, result: nil)
        } else {
          if let swiftyJSON = JSON(rawValue: data!) {
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
  }
  
  /// Attempts to retrieve info about a user by id.
  ///
  /// **Warning:** NSUserDefaults's .Auth key must have an Auth Token stored.
  ///
  /// :param: userID The id of the user that the server is describing.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will be the User object for the user with id userID.
  func getUserByID(userID: Int, completion:(error: NSError?, result: User?) -> Void) {
    Alamofire
      .request(.GET, Router.UserInfo, parameters: ["user_id":userID], encoding: .URL)
      .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
        if error != nil {
          completion(error: error!, result: nil)
        } else {
          if let swiftyJSON = JSON(rawValue: data!) {
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
  }
  /// Attempts to retrieve info about a user by unique username.
  ///
  /// **Warning:** NSUserDefaults's .Auth key must have an Auth Token stored.
  ///
  /// :param: username The unique username of the user that the server is describing.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will be the User object for the user with the given username.
  func getUserByUsername(username: String, completion:(error: NSError?, result: User?) -> Void) {
    Alamofire
      .request(.GET, Router.UserInfo, parameters: ["username":username], encoding: .URL)
      .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
        if error != nil {
          completion(error: error!, result: nil)
        } else {
          if let swiftyJSON = JSON(rawValue: data!) {
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
  }
  
  /// Attempts to retrieve info about a group by id.
  ///
  /// **Warning:** NSUserDefaults's .Auth key must have an Auth Token stored.
  ///
  /// :param: groupID The id of the group that the server is describing.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will be the Group object for the group with id groupID.
  func getGroupByID(groupID: Int, completion:(error: NSError?, result: Group?) -> Void) {
    Alamofire
      .request(.GET, Router.GroupInfo(groupID), parameters: nil, encoding: .URL)
      .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
        if error != nil {
          completion(error: error!, result: nil)
        } else {
          if let swiftyJSON = JSON(rawValue: data!) {
            if swiftyJSON["error"] != nil {
              let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .GroupInfo(groupID))
              completion(error: cilloError, result: nil)
            } else {
              let group = Group(json: swiftyJSON)
              completion(error: nil, result: group)
            }
          } else {
            completion(error: NSError.noJSONFromDataError(requestType: .GroupInfo(groupID)), result: nil)
          }
        }
      }
  }
  
  /// Attempts to retrieve info about a post by id.
  ///
  /// **Warning:** NSUserDefaults's .Auth key must have an Auth Token stored.
  ///
  /// :param: postID The id of the post that the server is describing.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will be the Post object for the post with id postID.
  func getPostByID(postID: Int, completion:(error: NSError?, result: Post?) -> Void) {
    Alamofire
      .request(.GET, Router.PostInfo(postID), parameters: nil, encoding: .URL)
      .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
        if error != nil {
          completion(error: error!, result: nil)
        } else {
          if let swiftyJSON = JSON(rawValue: data!) {
            if swiftyJSON["error"] != nil {
              let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .PostInfo(postID))
              completion(error: cilloError, result: nil)
            } else {
              var post: Post
              if swiftyJSON["repost"].boolValue {
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
  }
  
  /// Attempts to retrieve tree of comments that have replied to a post with the provided post id.
  ///
  /// **Warning:** NSUserDefaults's .Auth key must have an Auth Token stored.
  ///
  /// :param: postID The id of the post that the server is retrieving comments for.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will contain the comment tree for the post.
  func getPostCommentsByID(postID: Int, completion:(error: NSError?, result: [Comment]?) -> Void) {
    Alamofire
      .request(.GET, Router.PostComments(postID), parameters: nil, encoding: .URL)
      .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
        if error != nil {
          completion(error: error!, result: nil)
        } else {
          if let swiftyJSON = JSON(rawValue: data!) {
            if swiftyJSON["error"] != nil {
              let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .PostComments(postID))
              completion(error: cilloError, result: nil)
            } else {
              let comments = swiftyJSON["comments"].arrayValue
              var rootComments: [Comment] = []
              for comment in comments {
                let item = Comment(json: comment, lengthToPost: 1)
                rootComments.append(item)
              }
              var returnedTree: [Comment] = []
              for comment in rootComments {
                returnedTree += comment.makeCommentTree()
              }
              completion(error: nil, result: returnedTree)
            }
          } else {
            completion(error: NSError.noJSONFromDataError(requestType: .PostComments(postID)), result: nil)
          }
        }
    }
  }
  
  /// Attempts to retrieve list of groups that a user follows by user id.
  ///
  /// **Warning:** NSUserDefaults's .Auth key must have an Auth Token stored.
  ///
  /// :param: userID The id of the user that the server is retrieving a following list for.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will contain the groups that the user follows.
  func getUserGroupsByID(userID: Int, completion:(error: NSError?, result: [Group]?) -> Void) {
    Alamofire
      .request(.GET, Router.UserGroups(userID), parameters: nil, encoding: .URL)
      .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
        if error != nil {
          completion(error: error!, result: nil)
        } else {
          if let swiftyJSON = JSON(rawValue: data!) {
            if swiftyJSON["error"] != nil {
              let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .UserGroups(userID))
              completion(error: cilloError, result: nil)
            } else {
              let groups = swiftyJSON["groups"].arrayValue
              var returnArray: [Group] = []
              for group in groups {
                let item = Group(json: group)
                returnArray.append(item)
              }
              completion(error: nil, result: returnArray)
            }
          } else {
            completion(error: NSError.noJSONFromDataError(requestType: .UserGroups(userID)), result: nil)
          }
        }
      }
  }
  
  /// Attempts to retrieve list of posts that a user has made by user id.
  ///
  /// **Warning:** NSUserDefaults's .Auth key must have an Auth Token stored.
  ///
  /// :param: userID The id of the user that the server is retrieving posts for.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will contain the posts that the user has made.
  func getUserPostsByID(userID: Int, completion:(error: NSError?, result: [Post]?) -> Void) {
    Alamofire
      .request(.GET, Router.UserPosts(userID), parameters: nil, encoding: .URL)
      .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
        if error != nil {
          completion(error: error!, result: nil)
        } else {
          if let swiftyJSON = JSON(rawValue: data!) {
            if swiftyJSON["error"] != nil {
              let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .UserPosts(userID))
              completion(error: cilloError, result: nil)
            } else {
              let posts = swiftyJSON["posts"].arrayValue
              var returnArray: [Post] = []
              for post in posts {
                var item: Post
                if post["repost"].boolValue {
                  item = Repost(json: post)
                } else {
                  item = Post(json: post)  // convert element to our model object
                }
                returnArray.append(item)
              }
              completion(error: nil, result: returnArray)
            }
          } else {
            completion(error: NSError.noJSONFromDataError(requestType: .UserPosts(userID)), result: nil)
          }
        }
      }
  }
  
  /// Attempts to retrieve list of posts that a user has made by user id.
  ///
  /// **Warning:** NSUserDefaults's .Auth key must have an Auth Token stored.
  ///
  /// :param: userID The id of the user that the server is retrieving comments for.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will contain the comments that the user has made.
  func getUserCommentsByID(userID: Int, completion:(error: NSError?, result: [Comment]?) -> Void) {
    Alamofire
      .request(.GET, Router.UserComments(userID), parameters: nil, encoding: .URL)
      .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
        if error != nil {
          completion(error: error!, result: nil)
        } else {
          if let swiftyJSON = JSON(rawValue: data!) {
            if swiftyJSON["error"] != nil {
              let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .UserComments(userID))
              completion(error: cilloError, result: nil)
            } else {
              let comments = swiftyJSON["comments"].arrayValue
              var returnArray: [Comment] = []
              for comment in comments {
                let item = Comment(json: comment, lengthToPost: nil)
                returnArray.append(item)
              }
              completion(error: nil, result: returnArray)
            }
          } else {
            completion(error: NSError.noJSONFromDataError(requestType: .UserComments(userID)), result: nil)
          }
        }
      }
  }
  
  /// Attempts to create a new post made by the logged in user. 
  ///
  /// **Warning:** NSUserDefaults's .Auth key must have an Auth Token stored.
  ///
  /// :param: repostID The id of the original post that is being reposted.
  /// 
  ///  Nil if the post being created is not a repost.
  /// :param: groupID The id of the group that the new post is being posted in.
  /// :param: text The content of the post.
  /// :param: title The title of the post.
  ///
  ///  Nil if the post has no title.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will be the created Post.
  func createPostByGroupID(repostID: Int?, groupID: Int, text: String, title: String?, completion:(error: NSError?, result: Post?) -> Void) {
    var parameters: [String: AnyObject] = ["group_id": groupID, "data": text]
    if let repostID = repostID {
      parameters["repost_id"] = repostID
    }
    if let title = title {
      parameters["title"] = title
    }
    Alamofire
      .request(.POST, Router.PostCreate, parameters: parameters, encoding: .URL)
      .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
        if error != nil {
          completion(error: error!, result: nil)
        } else {
          if let swiftyJSON = JSON(rawValue: data!) {
            if swiftyJSON["error"] != nil {
              let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .PostCreate)
              completion(error: cilloError, result: nil)
            } else {
              var post: Post
              if swiftyJSON["repost"].boolValue {
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
  }
  
  /// Attempts to create a new post made by the logged in user.
  ///
  /// **Warning:** NSUserDefaults's .Auth key must have an Auth Token stored.
  ///
  /// :param: repostID The id of the original post that is being reposted.
  ///
  ///  Nil if the post being created is not a repost.
  /// :param: groupName The name of the group that the new post is being posted in.
  /// :param: text The content of the post.
  /// :param: title The title of the post.
  ///
  ///  Nil if the post has no title.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will be the created Post.
  func createPostByGroupName(groupName: String, repostID: Int?, text: String, title: String?, completion:(error: NSError?, result: Post?) -> Void) {
    var parameters: [String: AnyObject] = ["group_name": groupName, "data": text]
    if let repostID = repostID {
      parameters["repost_id"] = repostID
    }
    if let title = title {
      parameters["title"] = title
    }
    Alamofire
      .request(.POST, Router.PostCreate, parameters: parameters, encoding: .URL)
      .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
        if error != nil {
          completion(error: error!, result: nil)
        } else {
          if let swiftyJSON = JSON(rawValue: data!) {
            if swiftyJSON["error"] != nil {
              let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .PostCreate)
              completion(error: cilloError, result: nil)
            } else {
              var post: Post
              if swiftyJSON["repost"].boolValue {
                post = Repost(json: swiftyJSON)
                completion(error: nil, result: post)
              } else {
                post = Post(json: swiftyJSON)
                completion(error: nil, result: post)
              }
            }
          } else {
            completion(error: NSError.noJSONFromDataError(requestType: .PostCreate), result: nil)
          }
        }
    }
  }
  
  /// Attempts to create a new group made by the logged in user.
  ///
  /// **Warning:** NSUserDefaults's .Auth key must have an Auth Token stored.
  ///
  /// :param: name The name of the new group.
  /// :param: description The description of the group.
  ///
  ///  Nil if the group has no description.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will be the created Group.
  func createGroup(#name: String, description: String?, mediaID: Int?, completion:(error: NSError?, result: Group?) -> Void) {
    var parameters: [String: AnyObject] = ["name": name]
    if let description = description {
      parameters["description"] = description
    }
    if let mediaID = mediaID {
      parameters["media_id"] = mediaID
    }
    Alamofire
      .request(.POST, Router.GroupCreate, parameters: parameters, encoding: .URL)
      .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
        if error != nil {
          completion(error: error!, result: nil)
        } else {
          if let swiftyJSON = JSON(rawValue: data!) {
            if swiftyJSON["error"] != nil {
              let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .GroupCreate)
              completion(error: cilloError, result: nil)
            } else {
              let group = Group(json: swiftyJSON)
              completion(error: nil, result: group)
            }
          } else {
            completion(error: NSError.noJSONFromDataError(requestType: .GroupCreate), result: nil)
          }
        }
    }
  }
  
  /// Attempts to create a new group made by the logged in user.
  ///
  /// **Warning:** NSUserDefaults's .Auth key must have an Auth Token stored.
  ///
  /// :param: parentID The id of the comment that this comment is reply to.
  ///
  /// Nil if the comment is replying to the post directly.
  /// :param: postID The id of the post that this comment is associated with.
  /// :param: text The content of the comment.
  /// :param: lengthToPost The level of this comment in the comment tree.
  ///
  /// **Note:** Should be equal to parentComment.lengthToPost + 1.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will be the created Comment.
  func createComment(#parentID: Int?, postID: Int, text: String, lengthToPost: Int, completion:(error: NSError?, result: Comment?) -> Void) {
    var parameters: [String: AnyObject] = ["post_id": postID, "data": text]
    if let parentID = parentID {
      parameters["parent_id"] = parentID
    }
    Alamofire
      .request(.POST, Router.CommentCreate, parameters: parameters, encoding: .URL)
      .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
        if error != nil {
          completion(error: error!, result: nil)
        } else {
          if let swiftyJSON = JSON(rawValue: data!) {
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
  }
  
  
  /// Attempts to upvote a post.
  ///
  /// **Warning:** NSUserDefaults's .Auth key must have an Auth Token stored.
  ///
  /// :param: postID The id of the post that is being upvoted.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: success If the request was successful, this will be true.
  func postUpvote(postID: Int, completion:(error: NSError?, success: Bool) -> Void) {
    Alamofire
      .request(.POST, Router.PostUp(postID), parameters: nil, encoding: .URL)
      .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
        if error != nil {
          completion(error: error!, success: false)
        } else {
          if let swiftyJSON = JSON(rawValue: data!) {
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
  }
  
  /// Attempts to downvote a post.
  ///
  /// **Warning:** NSUserDefaults's .Auth key must have an Auth Token stored.
  ///
  /// :param: postID The id of the post that is being downvoted.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: success If the request was successful, this will be true.
  func postDownvote(postID: Int, completion:(error: NSError?, success: Bool) -> Void) {
    Alamofire
      .request(.POST, Router.PostDown(postID), parameters: nil, encoding: .URL)
      .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
        if error != nil {
          completion(error: error!, success: false)
        } else {
          if let swiftyJSON = JSON(rawValue: data!) {
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
  }
  
  /// Attempts to upvote a comment.
  ///
  /// **Warning:** NSUserDefaults's .Auth key must have an Auth Token stored.
  ///
  /// :param: commentID The id of the comment that is being upvoted.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: success If the request was successful, this will be true.
  func commentUpvote(commentID: Int, completion:(error: NSError?, success: Bool) -> Void) {
    Alamofire
      .request(.POST, Router.CommentUp(commentID), parameters: nil, encoding: .URL)
      .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
        if error != nil {
          completion(error: error!, success: false)
        } else {
          if let swiftyJSON = JSON(rawValue: data!) {
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
  }
  
  /// Attempts to downvote a comment.
  ///
  /// **Warning:** NSUserDefaults's .Auth key must have an Auth Token stored.
  ///
  /// :param: commentID The id of the comment that is being downvoted.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: success If the request was successful, this will be true.
  func commentDownvote(commentID: Int, completion:(error: NSError?, success: Bool) -> Void) {
    Alamofire
      .request(.POST, Router.CommentDown(commentID), parameters: nil, encoding: .URL)
      .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
        if error != nil {
          completion(error: error!, success: false)
        } else {
          if let swiftyJSON = JSON(rawValue: data!) {
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
  }
  
  /// Attempts to follow a group.
  ///
  /// **Warning:** NSUserDefaults's .Auth key must have an Auth Token stored.
  ///
  /// :param: groupID The id of the group that is being followed.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: success If the request was successful, this will be true.
  func groupFollow(groupID: Int, completion:(error: NSError?, success: Bool) -> Void) {
    Alamofire
      .request(.POST, Router.GroupFollow(groupID), parameters: nil, encoding: .URL)
      .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
        if error != nil {
          completion(error: error!, success: false)
        } else {
          if let swiftyJSON = JSON(rawValue: data!) {
            if swiftyJSON["error"] != nil {
              let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .GroupFollow(groupID))
              completion(error: cilloError, success: false)
            } else {
              completion(error: nil, success: true)
            }
          } else {
            completion(error: NSError.noJSONFromDataError(requestType: .GroupFollow(groupID)), success: false)
          }
        }
      }
  }
  
  /// Attempts to unfollow a group.
  ///
  /// **Warning:** NSUserDefaults's .Auth key must have an Auth Token stored.
  ///
  /// :param: groupID The id of the group that is being followed.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: success If the request was successful, this will be true.
  func groupUnfollow(groupID: Int, completion:(error: NSError?, success: Bool) -> Void) {
    Alamofire
      .request(.POST, Router.GroupUnfollow(groupID), parameters: nil, encoding: .URL)
      .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
        if error != nil {
          completion(error: error!, success: false)
        } else {
          if let swiftyJSON = JSON(rawValue: data!) {
            if swiftyJSON["error"] != nil {
              let cilloError = NSError(cilloErrorString: swiftyJSON["error"].stringValue, requestType: .GroupUnfollow(groupID))
              completion(error: cilloError, success: false)
            } else {
              completion(error: nil, success: true)
            }
          } else {
            completion(error: NSError.noJSONFromDataError(requestType: .GroupUnfollow(groupID)), success: false)
          }
        }
      }
  }
  
  /// Attempts to upload an image.
  ///
  /// **Warning:** NSUserDefaults's .Auth key must have an Auth Token stored.
  ///
  /// :param: imageData The data containing the image to be uploaded.
  ///
  /// :param: * The data can be retrieved via UIImagePNGRepresentation(_:)
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will contain the id of the image in Cillo servers.
  func imageUpload(imageData: NSData, completion:(error: NSError?, result: Int?) -> Void) {
    let urlRequest = urlRequestWithComponents(Router.MediaUpload.URLString, parameters: ["hi":"daniel"], imageData: imageData)
    Alamofire
      .upload(urlRequest.0, urlRequest.1)
      .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
        println("bytes written: \(totalBytesWritten), bytes expected: \(totalBytesExpectedToWrite)")
      }
      .responseJSON { (request: NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
        if error != nil {
          completion(error: error!, result: nil)
        } else {
          if let swiftyJSON = JSON(rawValue: data!) {
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
  }
  
  /// Attempts to update the settings of the logged in User.
  ///
  /// **Note:** All parameters are optional because settings can be updated independent of each other.
  ///
  /// * At least one parameter should not be nil.
  ///
  /// **Warning:** NSUserDefaults's .Auth key must have an Auth Token stored.
  ///
  /// :param: newName The new name of the logged in User.
  /// :param: newMediaID The media ID of the new profile picture of the logged in User.
  /// :param: newBio The new bio of the logged in User.
  /// :param: completion A completion block for the network request.
  /// :param: error If the request was unsuccessful, this will contain the error message.
  /// :param: result If the request was successful, this will contain the user object of the logged in User with the updated settings.
  func editSelfSettings(#newName: String?, newMediaID: Int?, newBio: String?, completion:(error: NSError?, result: User?) -> Void) {
    var parameters: [String: AnyObject] = [:]
    if let newName = newName {
      parameters["name"] = newName
    }
    if let newMediaID = newMediaID {
      parameters["photo"] = newMediaID
    }
    if let newBio = newBio {
      parameters["bio"] = newBio
    }
    Alamofire
      .request(.POST, Router.SelfSettings, parameters: parameters, encoding: .URL)
      .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
        if error != nil {
          completion(error: error!, result: nil)
        } else {
          if let swiftyJSON = JSON(rawValue: data!) {
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
  }
  
  // MARK: Helper Functions
  
  /// This function creates the required URLRequestConvertible and NSData we need to use Alamofire.upload
  ///
  /// :param: urlString The url of the request that is being performed.
  /// :param: parameters The parameters attached to the request.
  /// :param: * These are not important for cillo image uploads so anything can be written in this dictionary.
  /// :param: imageData The data of the image to be converted to Alamofire compatible image data.
  /// :returns: The tuple that is needed for the Alamofire.upload function.
  func urlRequestWithComponents(urlString: String, parameters: [String:String], imageData: NSData) -> (URLRequestConvertible, NSData) {
    
    // create url request to send
    var mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
    mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
    let boundaryConstant = "myRandomBoundary12345";
    let contentType = "multipart/form-data;boundary="+boundaryConstant
    mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
    
    // create upload data to send
    let uploadData = NSMutableData()
    
    // add image
    uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    uploadData.appendData("Content-Disposition: form-data; name=\"media\"; filename=\"file.png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    uploadData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    uploadData.appendData(imageData)
    
    // add parameters
    for (key, value) in parameters {
      uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
      uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    
    // return URLRequestConvertible and NSData
    return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
  }
  
}
