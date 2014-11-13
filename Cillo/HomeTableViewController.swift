//
//  HomeTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 10/23/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

///Handles first view of Home tab (Front Page of Cillo). Formats TableView to look appealing and be functional. Embedded in HomeNavigationController
class HomeTableViewController: UITableViewController {

    // MARK: - Properties
    
    ///Stores list of all posts retrieved from JSON
    var data : [Post] = []
    
    
    // MARK: - Constants
    
    ///Width of postTextView in PostCell
    var PROTOTYPE_TEXT_VIEW_WIDTH:CGFloat {
        //margins are 16
        return tableView.frame.width - 16
    }
    
    ///Max height of postTextView in PostCell before it is expanded by seeFullButton
    var MAX_CONTRACTED_HEIGHT:CGFloat {
        return tableView.frame.height * 0.625 - PostCell.ADDITIONAL_VERT_SPACE_NEEDED
    }
    
    
    // MARK: - Initializers
    
    ///Initializes the data array. Currently hardcoded... Will retrieve from database
    required init(coder aDecoder: NSCoder) {
        //Hardcoded posts
        let c7 = Comment(user: "Dan6", picture: UIImage(named: "Me")!, text: "hi", time: "10m", numComments: 0, rep: -2, lengthToPost: 7, comments: [])
        let c6 = Comment(user: "Dan5", picture: UIImage(named: "Me")!, text: "hi", time: "10m", numComments: 1, rep: -2, lengthToPost: 6, comments: [c7])
        let c5 = Comment(user: "Dan4", picture: UIImage(named: "Me")!, text: "hi", time: "10m", numComments: 2, rep: -2, lengthToPost: 5, comments: [c6])
        let c4 = Comment(user: "Dan3", picture: UIImage(named: "Me")!, text: "hi", time: "10m", numComments: 3, rep: -2, lengthToPost: 4, comments: [c5])
        let c3 = Comment(user: "Dan2", picture: UIImage(named: "Me")!, text: "hi", time: "10m", numComments: 4, rep: -2, lengthToPost: 3, comments: [c4])
        let c2 = Comment(user: "Dan", picture: UIImage(named: "Me")!, text: "hi", time: "10m", numComments: 5, rep: -2, lengthToPost: 2, comments: [c3])
        let c1 = Comment(user: "Andrew", picture: UIImage(named: "Me")!, text: "Hello", time: "21d", numComments: 6, rep: 10, lengthToPost: 1, comments: [c2])
        let c8 = Comment(user: "Kevin", picture: UIImage(named: "Me")!, text: "Daniel is stupid", time: "5h", numComments: 0, rep: 42, lengthToPost: 1, comments: [])
        let p1 = Post(text: "A game played by two teams of eleven players with a round ball that may not be touched with the hands or arms during play except by the goalkeepers. The object of the game is to score goals by kicking or heading the ball into the opponents' goal.A game played by two teams of eleven players with a round ball that may not be touched with the hands or arms during play except by the goalkeepers. The object of the game is to score goals by kicking or heading the ball into the opponents' goal.A game played by two teams of eleven players with a round ball that may not be touched with the hands or arms during play except by the goalkeepers. The object of the game is to score goals by kicking or heading the ball into the opponents' goal.A game played by two teams of eleven players with a round ball that may not be touched with the hands or arms during play except by the goalkeepers. The object of the game is to score goals by kicking or heading the ball into the opponents' goal.A game played by two teams of eleven players with a round ball that may not be touched with the hands or arms during play except by the goalkeepers. The object of the game is to score goals by kicking or heading the ball into the opponents' goal.", numComments: 8, user: "Daniel Li", rep: 1501, time: "21h", group: "Soccer", title: "What is Soccer?", picture: UIImage(named: "Me")!, comments: [c1, c8])
        c7.post = p1
        c6.post = p1
        c5.post = p1
        c4.post = p1
        c3.post = p1
        c2.post = p1
        c1.post = p1
        data.append(p1)
        data.append(Post(text: "A game played between two teams of five players in which goals are scored by throwing a ball through a netted hoop fixed above each end of the court.", numComments: 10, user: "Andrew Daley", rep: 3412, time: "10h", group: "Basketball", title: "What is Basketball?", picture: UIImage(named: "Me")!, comments: []))
        data.append(Post(text: "I Have no title", numComments: 1401, user: "Other Person", rep: -20, time: "1m", group: "Useless Info", title: nil, picture: UIImage(named: "Me")!, comments: []))
        data.append(Post(text: "This morning I was getting late to a meeting, so I decided to hit the gas a bit harder than usual. Before I know, I\'m over-speeding on the highway. Not by much, about 10mph over the speeding limit. Two minutes later I hear the sirens behind my car and stop on the sides of the road.\n\"You know why I stopped you sir?\" the officer asks.\n\"Let me be honest with you officer, I have a really important meeting now, one that can change my life, and I\'m late. Since I have no previous traffic felony or accident I took a calculated and responsible civilian decision to speed up a notch above the limit\"\n\"Well, that's not an excuse sir, you may be risking yourself and other people lives.\" He said, took my license and went to check my driving history.\n\"Well\" he said when coming back \"you are clean and we wouldn't want to change it. Be careful and DO NOT go over the speeding limit again, the law is there for a reason. It doesn't matter how good of driver you are.\"\nI was so relived and happy with the officer\'s decision and not getting a speeding ticket, that I immediately reached to my pocket, pulled $20, and tried to hand it to the officer.\n\"What are you doing sir?\"\n\"I..I\'m tipping you for your service officer\"\n\"You are what?! Sir you do realise this is an attempted bribery?!\"\n\"No... I\'m just... Just wanted to tip you for a good service. For a moment I had in mind... So sorry, my bad!\"\n\"Sir I\'m a public servant, not employee in a private company. I do not receive tips. For your information this can be treated as an attempted bribery.\"\n\"Deepest apologies officer, I\'m slow and stupid in mornings. Really meant it in a good way\"\n\"Let it never happen again in your life. Have a good day sir.\"\nI\'m stupid sometimes.", numComments: 2, user: "Am I Here", rep: 1347, time: "29d", group: "TIFU", title: "TIFU by trying to tip an officer", picture: UIImage(named: "Me")!, comments: []))
        
        super.init(coder: aDecoder)
        
        //gets rid of Front Page Text on back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
    }
    
    
    // MARK: - UITableViewDataSource
    
    //Assigns the number of sections to length of data array
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return data.count
    }

    //Assigns 1 row to each section
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    //Creates PostCell with appropriate properties for Post at given section in data
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Post", forIndexPath: indexPath) as PostCell
        let post = data[indexPath.section]
        
        cell.makeStandardPostCellFromPost(post, forIndexPath: indexPath)
        
        return cell
    }
    
    
    // MARK: - UITableViewDelegate
    
    //Sets height of divider inbetween cells
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 10
    }
    
    //Makes divider inbetween cells blue
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view = UIView()
        view.backgroundColor = UIColor.cilloBlue()
        return view
    }
    
    //Sets height of cell to appropriate value
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = data[indexPath.section]
        let height = post.heightOfPostWithWidth(PROTOTYPE_TEXT_VIEW_WIDTH, andMaxContractedHeight: MAX_CONTRACTED_HEIGHT) + PostCell.ADDITIONAL_VERT_SPACE_NEEDED
        return post.title != nil ? height : height - PostCell.TITLE_HEIGHT
    }
    
    //If cell is selected then go to post
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("HomeToPost", sender: indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    
    // MARK: - IBActions
    
    ///Expands Post for cell of sender
    @IBAction func seeFullPressed(sender: UIButton) {
        var post = data[sender.tag]
        if post.seeFull != nil {
            post.seeFull! = !post.seeFull!
        }
        tableView.reloadData()
    }
    
    
    // MARK: - Navigation
    
    ///Transfer selected post to post data
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "HomeToPost" {
            var destination = segue.destinationViewController as PostTableViewController
            if sender is UIButton {
                destination.post = data[(sender as UIButton).tag]
            } else if sender is NSIndexPath {
                destination.post = data[(sender as NSIndexPath).section]
            }
        }
    }

}
