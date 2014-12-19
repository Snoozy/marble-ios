//
//  MeTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 11/13/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

///Handles first view of Me tab (Profile of logged in User). Formats TableView to look appealing and be functional.
class MeTableViewController: SingleUserTableViewController {
    
    //MARK: - Constants
    
    override var SEGUE_IDENTIFIER_THIS_TO_POST:String {return "MeToPost"}
    
    
    //MARK: - UIViewController
    
    //Initializes user
    override func viewDidLoad() {
        
        var comment = Comment(user: "Andrew Daley", picture: UIImage(named: "Me")!, text: "hi", time: "1d", numComments: 0, rep: -1, lengthToPost: 1, comments: [])
        var comment2 = Comment(user: "Andrew Daley", picture: UIImage(named: "Me")!, text: "his", time: "1h", numComments: 0, rep: -2, lengthToPost: 1, comments: [])
        var post = Post(text: "Hi people", numComments: 2, user: "Andrew Daley", rep: 10, time: "2d", group: "Basketball", title: "Hello", picture: UIImage(named: "Me")!, comments: [comment, comment2])
        var post2 = Post(text: "Hi peoples", numComments: 0, user: "Andrew Daley", rep: 11, time: "2h", group: "Soccer", title: "Hellos", picture: UIImage(named: "Me")!, comments: [])
        comment.post = post
        comment2.post = post
        user = User(username: "Andrew Daley", accountname: "@adaley121", posts: [post, post2], comments: [comment, comment2], profilePic: UIImage(named: "Me")!, bio: "Hello, my name is Andrew Daley. I am widely regarded as the best human being on the planet. Thank you for visitng my page. Read my posts carefully, you might learn something.", numGroups: 20, rep: -3)
        
        //gets rid of Me Text on back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Bordered, target: nil, action: nil)
    }

}
