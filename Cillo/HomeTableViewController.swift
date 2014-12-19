//
//  HomeTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 10/23/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

///Handles first view of Home tab (Front Page of Cillo). Formats TableView to look appealing and be functional.
class HomeTableViewController: MultiplePostsTableViewController {
    
    //MARK: - Constants
    
    override var SEGUE_IDENTIFIER_THIS_TO_POST : String {return "HomeToPost"}
    
    
    //MARK: - UIViewController
    
    //Initializes posts array
    override func viewDidLoad() {
        //Hardcoded posts
        let c7 = Comment(user: "Dan6", picture: UIImage(named: "Me")!, text: "hi", time: "10m", numComments: 0, rep: -2, lengthToPost: 7, comments: [])
        let c6 = Comment(user: "Dan5", picture: UIImage(named: "Me")!, text: "hi", time: "10m", numComments: 1, rep: -2, lengthToPost: 6, comments: [c7])
        let c5 = Comment(user: "Dan4", picture: UIImage(named: "Me")!, text: "hi", time: "10m", numComments: 2, rep: -2, lengthToPost: 5, comments: [c6])
        let c4 = Comment(user: "Dan3", picture: UIImage(named: "Me")!, text: "hi", time: "10m", numComments: 3, rep: -2, lengthToPost: 4, comments: [c5])
        let c3 = Comment(user: "Dan2", picture: UIImage(named: "Me")!, text: "hi", time: "10m", numComments: 4, rep: -2, lengthToPost: 3, comments: [c4])
        let c2 = Comment(user: "Dan", picture: UIImage(named: "Me")!, text: "hi", time: "10m", numComments: 5, rep: -2, lengthToPost: 2, comments: [c3])
        let c1 = Comment(user: "Andrew", picture: UIImage(named: "Me")!, text: "Hello", time: "21d", numComments: 6, rep: 10, lengthToPost: 1, comments: [c2])
        let c9 = Comment(user: "Bjas", picture: UIImage(named: "Me")!, text: "Nsjdaio", time: "5h", numComments: 0, rep: 42, lengthToPost: 2, comments: [])
        let c8 = Comment(user: "Kevin", picture: UIImage(named: "Me")!, text: "Daniel is stupid", time: "5h", numComments: 1, rep: 42, lengthToPost: 1, comments: [c9])
        let p1 = Post(text: "A game played by two teams of eleven players with a round ball that may not be touched with the hands or arms during play except by the goalkeepers. The object of the game is to score goals by kicking or heading the ball into the opponents' goal.A game played by two teams of eleven players with a round ball that may not be touched with the hands or arms during play except by the goalkeepers. The object of the game is to score goals by kicking or heading the ball into the opponents' goal.A game played by two teams of eleven players with a round ball that may not be touched with the hands or arms during play except by the goalkeepers. The object of the game is to score goals by kicking or heading the ball into the opponents' goal.A game played by two teams of eleven players with a round ball that may not be touched with the hands or arms during play except by the goalkeepers. The object of the game is to score goals by kicking or heading the ball into the opponents' goal.A game played by two teams of eleven players with a round ball that may not be touched with the hands or arms during play except by the goalkeepers. The object of the game is to score goals by kicking or heading the ball into the opponents' goal.", numComments: 8, user: "Daniel Li", rep: 1501, time: "21h", group: "Soccer", title: "What is Soccer?", picture: UIImage(named: "Me")!, comments: [c1, c8])
        c9.post = p1
        c8.post = p1
        c7.post = p1
        c6.post = p1
        c5.post = p1
        c4.post = p1
        c3.post = p1
        c2.post = p1
        c1.post = p1
        posts.append(p1)
        posts.append(Post(text: "A game played between two teams of five players in which goals are scored by throwing a ball through a netted hoop fixed above each end of the court.", numComments: 10, user: "Andrew Daley", rep: 3412, time: "10h", group: "Basketball", title: "What is Basketball?", picture: UIImage(named: "Me")!, comments: []))
        posts.append(Post(text: "I Have no title", numComments: 1401, user: "Other Person", rep: -20, time: "1m", group: "Useless Info", title: nil, picture: UIImage(named: "Me")!, comments: []))
        posts.append(Post(text: "This morning I was getting late to a meeting, so I decided to hit the gas a bit harder than usual. Before I know, I\'m over-speeding on the highway. Not by much, about 10mph over the speeding limit. Two minutes later I hear the sirens behind my car and stop on the sides of the road.\n\"You know why I stopped you sir?\" the officer asks.\n\"Let me be honest with you officer, I have a really important meeting now, one that can change my life, and I\'m late. Since I have no previous traffic felony or accident I took a calculated and responsible civilian decision to speed up a notch above the limit\"\n\"Well, that's not an excuse sir, you may be risking yourself and other people lives.\" He said, took my license and went to check my driving history.\n\"Well\" he said when coming back \"you are clean and we wouldn't want to change it. Be careful and DO NOT go over the speeding limit again, the law is there for a reason. It doesn't matter how good of driver you are.\"\nI was so relived and happy with the officer\'s decision and not getting a speeding ticket, that I immediately reached to my pocket, pulled $20, and tried to hand it to the officer.\n\"What are you doing sir?\"\n\"I..I\'m tipping you for your service officer\"\n\"You are what?! Sir you do realise this is an attempted bribery?!\"\n\"No... I\'m just... Just wanted to tip you for a good service. For a moment I had in mind... So sorry, my bad!\"\n\"Sir I\'m a public servant, not employee in a private company. I do not receive tips. For your information this can be treated as an attempted bribery.\"\n\"Deepest apologies officer, I\'m slow and stupid in mornings. Really meant it in a good way\"\n\"Let it never happen again in your life. Have a good day sir.\"\nI\'m stupid sometimes.", numComments: 2, user: "Am I Here", rep: 1347, time: "29d", group: "TIFU", title: "TIFU by trying to tip an officer", picture: UIImage(named: "Me")!, comments: []))
        
        //gets rid of Front Page Text on back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
    }
    
}
