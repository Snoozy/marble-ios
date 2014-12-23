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
    case Root
    case Group(String)
    case GroupInfo(String)
    case PostInfo(String)
    case PostComments(String)
    case UserInfo(String)
    case UserGroups(String)
    case UserPosts(String)
    case UserComments(String)
    
    //POST
    case Register
    case GroupCreate
    case Login
    case Logout
    case PostCreate
    case CommentCreate
    case MediaUpload
    case CommentUp(String)
    case CommentDown(String)
    case PostUp(String)
    case PostDown(String)
    
    
    
    var URLString: String {
        let auth = NSUserDefaults.standardUserDefaults().stringForKey(NSUserDefaults.AUTH)
        let authString = "?auth_token=\(auth)"
        let vNum = "v1"
        let path: String = {
            switch self {
            //GET
            case .Root:
                return "/\(vNum)/me/timeline\(authString)"
            case .Group(let groupID):
                return "/\(vNum)/groups/\(groupID)/timeline\(authString)"
            case .GroupInfo(let groupID):
                return "/\(vNum)/groups/\(groupID)/describe\(authString)"
            case .PostInfo(let postID):
                return "/\(vNum)/posts/\(postID)/describe\(authString)"
            case .PostComments(let postID):
                return "/\(vNum)/posts/\(postID)/comments\(authString)"
            case .UserInfo(let userID):
                return "/\(vNum)/users/\(userID)/describe\(authString)"
            case .UserGroups(let userID):
                return "/\(vNum)/users/\(userID)/groups\(authString)"
            case .UserPosts(let userID):
                return "/\(vNum)/users/\(userID)/posts\(authString)"
            case .UserComments(let userID):
                return "/\(vNum)/users/\(userID)/comments\(authString)"
                
            //POST
            case .Register:
                return "/\(vNum)/user/register"
            case .GroupCreate:
                return "/\(vNum)/group/create\(authString)"
            case .Login:
                return "/\(vNum)/auth/login"
            case .Logout:
                return "/\(vNum)/auth/logout\(authString)"
            case .PostCreate:
                return "/\(vNum)/post/create\(authString)"
            case .CommentCreate:
                return "/\(vNum)/comment/create\(authString)"
            case .MediaUpload:
                return "/\(vNum)/media/upload\(authString)"
            case .CommentUp(let commentID):
                return "/\(vNum)/comment/\(commentID)/upvote\(authString)"
            case .CommentDown(let commentID):
                return "/\(vNum)/comment/\(commentID)/downvote\(authString)"
            case .PostUp(let postID):
                return "/\(vNum)/post/\(postID)/upvote\(authString)"
            case .PostDown(let postID):
                return "/\(vNum)/post/\(postID)/downvote\(authString)"
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
    
}
