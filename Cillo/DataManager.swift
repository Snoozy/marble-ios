//
//  DataManager.swift
//  Cillo
//
//  Created by Andrew Daley on 12/20/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import Foundation
import Alamofire

enum Router: URLStringConvertible {
    static let baseURLString = "http://api.cillo.co"
    
    //GET
    case Root //DONE
    case GroupTimeline(Int) //DONE
    case GroupInfo(Int) //DONE
    case PostInfo(Int) //DONE
    case PostComments(Int)
    case SelfInfo //DONE
    case UserInfo //DONE
    case UserGroups(Int) //DONE
    case UserPosts(Int) //DONE
    case UserComments(Int)
    
    //POST
    case Register //DONE
    case GroupCreate
    case Login //DONE
    case Logout //DONE
    case PostCreate //DONE
    case CommentCreate
    case MediaUpload
    case CommentUp(Int) //DONE
    case CommentDown(Int) //DONE
    case PostUp(Int) //DONE
    case PostDown(Int) //DONE
    
    
    
    var URLString: String {
        let auth = NSUserDefaults.standardUserDefaults().stringForKey(NSUserDefaults.AUTH)
        let authString = "?auth_token=\(auth)"
        let vNum = "v1"
        let path: String = {
            switch self {
            //GET
            case .Root:
                return "/\(vNum)/me/timeline\(authString)"
            case .GroupTimeline(let groupID):
                return "/\(vNum)/groups/\(groupID)/timeline\(authString)"
            case .GroupInfo(let groupID):
                return "/\(vNum)/groups/\(groupID)/describe\(authString)"
            case .PostInfo(let postID):
                return "/\(vNum)/posts/\(postID)/describe\(authString)"
            case .PostComments(let postID):
                return "/\(vNum)/posts/\(postID)/comments\(authString)"
            case .SelfInfo:
                return "/\(vNum)/me/describe\(authString)"
            case .UserInfo:
                return "/\(vNum)/users/describe\(authString)"
            case .UserGroups(let userID):
                return "/\(vNum)/users/\(userID)/groups\(authString)"
            case .UserPosts(let userID):
                return "/\(vNum)/users/\(userID)/posts\(authString)"
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
            }
        }()
        
        return Router.baseURLString + path
    }
    
}

class DataManager: NSObject {
    
    //MARK: - Constants
    
    //Singleton
    class var sharedInstance : DataManager {
        struct Static {
            static var instance: DataManager = DataManager()
        }
        return Static.instance
    }
    
    
    //MARK: - Networking Functions
    
    ///Attempts to log into server. If successful, returns authToken in completion block
    func login(username: String, password: String, completion:(error: NSError?, result: String?) -> Void) {
        Alamofire
            .request(.POST, Router.Login, parameters: ["username":username, "password":password], encoding: .URL)
            .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
                
                if error != nil {
                    
                    completion(error: error!, result: nil)
                    
                } else {
                    
                    if let swiftyJSON = JSON(rawValue: data!) {
                        
                        let authToken = swiftyJSON["auth_token"].stringValue
                        
                        completion(error: nil, result: authToken)
                    }
                }
            }
    }
    
    ///Attempts to register user with server. If successful, returns true in completion block
    func register(username: String, name: String, password: String, email: String, completion:(error: NSError?, success: Bool) -> Void) {
        Alamofire
            .request(.POST, Router.Register, parameters: ["username":username, "name":name, "password":password, "email":email], encoding: .URL)
            .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
                
                if error != nil {
                    
                    completion(error: error!, success: false)
                    
                } else {
                    
                    if let swiftyJSON = JSON(rawValue: data!) {
                        completion(error: nil, success: true)
                    }
                }
        }
    }
    
    ///Attempts to logout of server. If successful, returns true in completion block
    func logout(completion:(error: NSError?, success: Bool) -> Void) {
        Alamofire
            .request(.POST, Router.Logout, parameters: nil, encoding: .URL)
            .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
                
                if error != nil {
                    
                    completion(error: error!, success: false)
                    
                } else {
                    
                    if let swiftyJSON = JSON(rawValue: data!) {
                        completion(error: nil, success: true)
                    }
                }
        }
    }
    
    ///Attempts to retrieve Home page from server. If successful, returns an array of posts on home page in completion block
    func getHomePage(completion:(error: NSError?, result: [Post]?) -> Void) {
        Alamofire
            .request(.GET, Router.Root, parameters: nil, encoding: .URL)
            .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
                
                if error != nil {
                    
                    completion(error: error!, result: nil)
                    
                } else {
                    
                    if let swiftyJSON = JSON(rawValue: data!) {
                        
                        let posts = swiftyJSON["posts"].arrayValue // pull out the array from the JSON
                        
                        var returnArray: [Post] = []
                        
                        for post in posts {
                            let item = Post(json: post)  // convert element to our model object
                            returnArray.append(item)
                        }
                        
                        completion(error: nil, result: returnArray)
                    }
                }
            }
    }
    
    ///Attempts to retrieve Group home page from server. If successful, returns an array of posts on group page in completion block
    func getGroupTimeline(groupID: Int, completion:(error: NSError?, result: [Post]?) -> Void) {
        Alamofire
            .request(.GET, Router.GroupTimeline(groupID), parameters: nil, encoding: .URL)
            .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
                
                if error != nil {
                    
                    completion(error: error!, result: nil)
                    
                } else {
                    
                    if let swiftyJSON = JSON(rawValue: data!) {
                        
                        let posts = swiftyJSON["posts"].arrayValue // pull out the array from the JSON
                        
                        var returnArray: [Post] = []
                        
                        for post in posts {
                            let item = Post(json: post)  // convert element to our model object
                            returnArray.append(item)
                        }
                        
                        completion(error: nil, result: returnArray)
                    }
                }
        }
    }
    
    ///Attempts to retrieve info about logged in User. If successful, returns the info as a User object in completion block
    func getSelfInfo(completion:(error: NSError?, result: User?) -> Void) {
        Alamofire
            .request(.GET, Router.SelfInfo, parameters: nil, encoding: .URL)
            .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
                
                if error != nil {
                    
                    completion(error: error!, result: nil)
                    
                } else {
                    
                    if let swiftyJSON = JSON(rawValue: data!) {
                        
                        let user = User(json: swiftyJSON) // pull out the array from the JSON
                        
                        completion(error: nil, result: user)
                    }
                }
        }
    }
    
    ///Attempts to retrieve info about user by id. If successful, returns the info as a User object in completion block
    func getUserByID(userID: Int, completion:(error: NSError?, result: User?) -> Void) {
        Alamofire
            .request(.GET, Router.UserInfo, parameters: ["user_id":userID], encoding: .URL)
            .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
                
                if error != nil {
                    
                    completion(error: error!, result: nil)
                    
                } else {
                    
                    if let swiftyJSON = JSON(rawValue: data!) {
                        
                        let user = User(json: swiftyJSON) // pull out the array from the JSON
                        
                        completion(error: nil, result: user)
                    }
                }
        }
    }
    ///Attempts to retrieve info about user by unique username. If successful, returns the info as a User object in completion block
    func getUserByAccountName(accountName: String, completion:(error: NSError?, result: User?) -> Void) {
        Alamofire
            .request(.GET, Router.UserInfo, parameters: ["username":accountName], encoding: .URL)
            .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
                
                if error != nil {
                    
                    completion(error: error!, result: nil)
                    
                } else {
                    
                    if let swiftyJSON = JSON(rawValue: data!) {
                        
                        let user = User(json: swiftyJSON) // pull out the array from the JSON
                        
                        completion(error: nil, result: user)
                    }
                }
        }
    }
    
    ///Attempts to retrieve info about group by id. If successful, returns the info as a Group object in completion block
    func getGroupByID(groupID: Int, completion:(error: NSError?, result: Group?) -> Void) {
        Alamofire
            .request(.GET, Router.GroupInfo(groupID), parameters: nil, encoding: .URL)
            .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
    
            if error != nil {
    
            completion(error: error!, result: nil)
    
            } else {
    
                if let swiftyJSON = JSON(rawValue: data!) {
    
                    let group = Group(json: swiftyJSON) // pull out the array from the JSON
    
                    completion(error: nil, result: group)
                }
            }
        }
    }
    
    ///Attempts to retrieve info about post by id. If successful, returns the info as a Post object in completion block
    func getPostByID(postID: Int, completion:(error: NSError?, result: Post?) -> Void) {
        Alamofire
            .request(.GET, Router.PostInfo(postID), parameters: nil, encoding: .URL)
            .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
                
                if error != nil {
                    
                    completion(error: error!, result: nil)
                    
                } else {
                    
                    if let swiftyJSON = JSON(rawValue: data!) {
                        
                        let post = Post(json: swiftyJSON) // pull out the array from the JSON
                        
                        completion(error: nil, result: post)
                    }
                }
        }
    }
    
    ///Attempts to retrieve list of groups that user follows by id. If successful, returns the info as an array of Group objects in completion block
    func getUserGroupsByID(userID: Int, completion:(error: NSError?, result: [Group]?) -> Void) {
        Alamofire
            .request(.GET, Router.UserGroups(userID), parameters: nil, encoding: .URL)
            .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
                
                if error != nil {
                    
                    completion(error: error!, result: nil)
                    
                } else {
                    
                    if let swiftyJSON = JSON(rawValue: data!) {
                        
                        let groups = swiftyJSON["groups"].arrayValue
                        
                        var returnArray: [Group] = []
                        
                        for group in groups {
                            let item = Group(json: group)
                            returnArray.append(item)
                        }
                        
                        completion(error: nil, result: returnArray)
                    }
                }
        }
    }
    
    ///Attempts to retrieve list of posts that user made by id. If successful, returns the info as an array of Post objects in completion block
    func getUserPostsByID(userID: Int, completion:(error: NSError?, result: [Post]?) -> Void) {
        Alamofire
            .request(.GET, Router.UserPosts(userID), parameters: nil, encoding: .URL)
            .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
                
                if error != nil {
                    
                    completion(error: error!, result: nil)
                    
                } else {
                    
                    if let swiftyJSON = JSON(rawValue: data!) {
                        
                        let posts = swiftyJSON["posts"].arrayValue
                        
                        var returnArray: [Post] = []
                        
                        for post in posts {
                            let item = Post(json: post)
                            returnArray.append(item)
                        }
                        
                        completion(error: nil, result: returnArray)
                    }
                }
        }
    }
    
    ///Attempts to create a post. If successful returns the created Post in completion block
    func createPost(repostID: Int?, groupID: Int, text: String, title: String?, completion:(error: NSError?, result: Post?) -> Void) {
        Alamofire
            .request(.POST, Router.PostCreate, parameters: ["repost_id":repostID, "group_id":groupID, "data":text, "title":title], encoding: .URL)
            .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
                
                if error != nil {
                    
                    completion(error: error!, success: false)
                    
                } else {
                    
                    if let swiftyJSON = JSON(rawValue: data!) {
                        let post = Post(json: swiftyJSON)
                        completion(error: nil, success: post)
                    }
                }
        }
    }
    

    ///Attempts to upvote a post. If successful returns true in completion block
    func postUpvote(postID: Int, completion:(error: NSError?, success: Bool) -> Void) {
        Alamofire
            .request(.POST, Router.PostUp(postID), parameters: nil, encoding: .URL)
            .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
                
                if error != nil {
                    
                    completion(error: error!, success: false)
                    
                } else {
                    
                    if let swiftyJSON = JSON(rawValue: data!) {
                        completion(error: nil, success: true)
                    }
                }
        }
    }
    
    ///Attempts to downvote a post. If successful returns true in completion block
    func postDownvote(postID: Int, completion:(error: NSError?, success: Bool) -> Void) {
        Alamofire
            .request(.POST, Router.PostDown(postID), parameters: nil, encoding: .URL)
            .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
                
                if error != nil {
                    
                    completion(error: error!, success: false)
                    
                } else {
                    
                    if let swiftyJSON = JSON(rawValue: data!) {
                        completion(error: nil, success: true)
                    }
                }
        }
    }
    
    ///Attempts to upvote a comment. If successful returns true in completion block
    func commentUpvote(commentID: Int, completion:(error: NSError?, success: Bool) -> Void) {
        Alamofire
            .request(.POST, Router.CommentUp(commentID), parameters: nil, encoding: .URL)
            .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
                
                if error != nil {
                    
                    completion(error: error!, success: false)
                    
                } else {
                    
                    if let swiftyJSON = JSON(rawValue: data!) {
                        completion(error: nil, success: true)
                    }
                }
        }
    }
    
    ///Attempts to downvote a comment. If successful returns true in completion block
    func commentDownvote(commentID: Int, completion:(error: NSError?, success: Bool) -> Void) {
        Alamofire
            .request(.POST, Router.CommentDown(commentID), parameters: nil, encoding: .URL)
            .responseJSON { (request : NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
                
                if error != nil {
                    
                    completion(error: error!, success: false)
                    
                } else {
                    
                    if let swiftyJSON = JSON(rawValue: data!) {
                        completion(error: nil, success: true)
                    }
                }
        }
    }

    
}
