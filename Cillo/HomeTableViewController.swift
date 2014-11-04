//
//  FrontPageTableViewController.swift
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
    var data : [Post]
    
    
    // MARK: - Constants
    
    ///Width of postTextView in PostCell
    var prototypeTextViewWidth:CGFloat {
        //margins are 16
        return tableView.frame.width - 16
    }
    
    ///Max height of postTextView in PostCell before it is expanded by seeFullButton
    var maxContractedHeight:CGFloat {
        return tableView.frame.height * 0.625 - PostCell.additionalVertSpaceNeeded
    }
    
    
    // MARK: - Initializers
    
    ///Initializes the data array. Currently hardcoded... Will retrieve from database
    required init(coder aDecoder: NSCoder) {
        self.data = []
        //Hardcoded posts
        let c7 = Comment(user: "Dan6", picture: UIImage(named: "Me")!, text: "hi", time: "10m", numComments: 0, rep: -2, lengthToPost: 7, comments: [])
        let c6 = Comment(user: "Dan5", picture: UIImage(named: "Me")!, text: "hi", time: "10m", numComments: 1, rep: -2, lengthToPost: 6, comments: [c7])
        let c5 = Comment(user: "Dan4", picture: UIImage(named: "Me")!, text: "hi", time: "10m", numComments: 2, rep: -2, lengthToPost: 5, comments: [c6])
        let c4 = Comment(user: "Dan3", picture: UIImage(named: "Me")!, text: "hi", time: "10m", numComments: 3, rep: -2, lengthToPost: 4, comments: [c5])
        let c3 = Comment(user: "Dan2", picture: UIImage(named: "Me")!, text: "hi", time: "10m", numComments: 4, rep: -2, lengthToPost: 3, comments: [c4])
        let c2 = Comment(user: "Dan", picture: UIImage(named: "Me")!, text: "hi", time: "10m", numComments: 5, rep: -2, lengthToPost: 2, comments: [c3])
        let c1 = Comment(user: "Andrew", picture: UIImage(named: "Me")!, text: "Hello", time: "21d", numComments: 6, rep: 10, lengthToPost: 1, comments: [c2])
        let c8 = Comment(user: "Kevin", picture: UIImage(named: "Me")!, text: "Daniel is stupid", time: "5h", numComments: 0, rep: 42, lengthToPost: 1, comments: [])
        data.append(Post(text: "A game played by two teams of eleven players with a round ball that may not be touched with the hands or arms during play except by the goalkeepers. The object of the game is to score goals by kicking or heading the ball into the opponents' goal.A game played by two teams of eleven players with a round ball that may not be touched with the hands or arms during play except by the goalkeepers. The object of the game is to score goals by kicking or heading the ball into the opponents' goal.A game played by two teams of eleven players with a round ball that may not be touched with the hands or arms during play except by the goalkeepers. The object of the game is to score goals by kicking or heading the ball into the opponents' goal.A game played by two teams of eleven players with a round ball that may not be touched with the hands or arms during play except by the goalkeepers. The object of the game is to score goals by kicking or heading the ball into the opponents' goal.A game played by two teams of eleven players with a round ball that may not be touched with the hands or arms during play except by the goalkeepers. The object of the game is to score goals by kicking or heading the ball into the opponents' goal.", numComments: 3, user: "Daniel Li", rep: 1501, time: "21h", group: "Soccer", title: "What is Soccer?", picture: UIImage(named: "Me")!, comments: [c1, c8]))
        data.append(Post(text: "A game played between two teams of five players in which goals are scored by throwing a ball through a netted hoop fixed above each end of the court.", numComments: 10, user: "Andrew Daley", rep: 3412, time: "10h", group: "Basketball", title: "What is Basketball?", picture: UIImage(named: "Me")!, comments: []))
        data.append(Post(text: "I Have no title", numComments: 1401, user: "Edmund Lau", rep: -20, time: "1m", group: "Useless Info", title: nil, picture: UIImage(named: "Me")!, comments: []))
        data.append(Post(text: "This morning I was getting late to a meeting, so I decided to hit the gas a bit harder than usual. Before I know, I\'m over-speeding on the highway. Not by much, about 10mph over the speeding limit. Two minutes later I hear the sirens behind my car and stop on the sides of the road.\n\"You know why I stopped you sir?\" the officer asks.\n\"Let me be honest with you officer, I have a really important meeting now, one that can change my life, and I\'m late. Since I have no previous traffic felony or accident I took a calculated and responsible civilian decision to speed up a notch above the limit\"\n\"Well, that's not an excuse sir, you may be risking yourself and other people lives.\" He said, took my license and went to check my driving history.\n\"Well\" he said when coming back \"you are clean and we wouldn't want to change it. Be careful and DO NOT go over the speeding limit again, the law is there for a reason. It doesn't matter how good of driver you are.\"\nI was so relived and happy with the officer\'s decision and not getting a speeding ticket, that I immediately reached to my pocket, pulled $20, and tried to hand it to the officer.\n\"What are you doing sir?\"\n\"I..I\'m tipping you for your service officer\"\n\"You are what?! Sir you do realise this is an attempted bribery?!\"\n\"No... I\'m just... Just wanted to tip you for a good service. For a moment I had in mind... So sorry, my bad!\"\n\"Sir I\'m a public servant, not employee in a private company. I do not receive tips. For your information this can be treated as an attempted bribery.\"\n\"Deepest apologies officer, I\'m slow and stupid in mornings. Really meant it in a good way\"\n\"Let it never happen again in your life. Have a good day sir.\"\nI\'m stupid sometimes.", numComments: 2, user: "Am I Here", rep: 1347, time: "29d", group: "TIFU", title: "TIFU by trying to tip an officer", picture: UIImage(named: "Me")!, comments: []))
        
        super.init(coder: aDecoder)
    }
    
    
    // MARK: - UITableViewDataSource
    
    ///Assigns the number of sections to length of data array
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return data.count
    }

    ///Assigns 1 row to each section
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    ///Creates PostCell with appropriate properties for Post at given section in data
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Post", forIndexPath: indexPath) as PostCell
        let post = data[indexPath.section]
        
        cell.userLabel.text = post.user
        cell.groupLabel.text = post.group
        cell.profilePicView.image = post.picture
        cell.timeLabel.text = post.time
        
        cell.postTextView.text = post.text
        cell.postTextView.font = PostCell.textViewFont
        cell.postTextView.textContainer.lineFragmentPadding = 0
        cell.postTextView.textContainerInset = UIEdgeInsetsZero
        
        //tag acts as way for button to know it's position in data array
        cell.seeFullButton.tag = indexPath.section //for button
        cell.commentButton.tag = indexPath.section //for button
        
        //short posts and already expanded posts don't need to be expanded
        if post.seeFull == nil || post.seeFull! {
            cell.seeFullButton.hidden = true
        } else {
            cell.seeFullButton.hidden = false
        }
        
        //Formats numbers on screen to say #.#k if necessary
        if post.numComments >= 1000 {
            cell.commentLabel.text = convertToThousands(post.numComments)
        } else {
            cell.commentLabel.text = String(post.numComments)
        }
        if post.rep >= 1000 || post.rep <= -1000{
            cell.repLabel.text = convertToThousands(post.rep)
        } else {
            cell.repLabel.text = String(post.rep)
        }
        
        if let t = post.title {
            cell.titleLabel.text = t
        } else {
            cell.titleLabel.text = ""
            cell.titleHeightConstraint.constant = 0.0
        }
        
        return cell
    }
    
    
    // MARK: - UITableViewDelegate
    
    ///Sets height of divider inbetween cells
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 10
    }
    
    ///Makes divider inbetween cells blue
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view = UIView()
        view.backgroundColor = UIColor(red: 0.0627, green: 0.396, blue: 0.768, alpha: 0.87)
        return view
    }
    
    ///Sets height of cell to appropriate value
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if data[indexPath.section].title != nil {
           return heightForTextOfRow(indexPath.section) + PostCell.additionalVertSpaceNeeded
        }
        return heightForTextOfRow(indexPath.section) + PostCell.additionalVertSpaceNeeded - PostCell.titleHeight
    }
    
    ///If cell is selected then go to post
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("HomeToPost", sender: indexPath)
        
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
    

    // MARK: - Helper Functions
    
    ///Calculates height of postTextView according to length of Post's text. Restricts to maxContractedHeight if seeFull is false
    func heightForTextOfRow(row: Int) -> CGFloat {
        let post = data[row]
        
        //creates a mock textView to calculate height with sizeToFit() function
        var textView = UITextView(frame: CGRectMake(0, 0, prototypeTextViewWidth, CGFloat.max))
        textView.text = post.text
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsetsZero
        textView.font = PostCell.textViewFont
        textView.sizeToFit()
        
        //seeFull should not be nil if post needs expansion option
        if post.seeFull == nil && textView.frame.size.height > maxContractedHeight{
            post.seeFull = false
        }
        
        if post.seeFull == nil || post.seeFull! {
            return textView.frame.size.height
        } else {
            return maxContractedHeight
        }
        
    }
    
    ///Converts Int to formatted #.#k String
    func convertToThousands(number: Int) -> String {
        var thousands : Double = Double(number / 1000)
        if thousands < 0 {
            thousands -= Double(number % 1000 / 100) * 0.1
        } else {
            thousands += Double(number % 1000 / 100) * 0.1
        }
        return "\(thousands)k"
    }

}
