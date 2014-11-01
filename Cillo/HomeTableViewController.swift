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

    //********** Properties **********
    
    ///Stores list of all posts retrieved from JSON
    var data : [Post]
    
    
    //********** Constants **********
    
    ///Define - width of postTextView in PostCell
    var prototypeTextViewWidth:CGFloat {
        //margins are 16
        return tableView.frame.width - 16
    }
    
    ///Define - max height of postTextView in PostCell before it is expanded by seeFullButton
    var maxContractedHeight:CGFloat {
        return tableView.frame.height * 0.625 - PostCell.additionalVertSpaceNeeded
    }
    
    
    //**********  Initializers **********
    
    ///Initializes the data array. Currently hardcoded... Will retrieve from database
    required init(coder aDecoder: NSCoder) {
        self.data = []
        //Hardcoded posts
        data.append(Post(text: "A game played by two teams of eleven players with a round ball that may not be touched with the hands or arms during play except by the goalkeepers. The object of the game is to score goals by kicking or heading the ball into the opponents' goal.A game played by two teams of eleven players with a round ball that may not be touched with the hands or arms during play except by the goalkeepers. The object of the game is to score goals by kicking or heading the ball into the opponents' goal.A game played by two teams of eleven players with a round ball that may not be touched with the hands or arms during play except by the goalkeepers. The object of the game is to score goals by kicking or heading the ball into the opponents' goal.A game played by two teams of eleven players with a round ball that may not be touched with the hands or arms during play except by the goalkeepers. The object of the game is to score goals by kicking or heading the ball into the opponents' goal.A game played by two teams of eleven players with a round ball that may not be touched with the hands or arms during play except by the goalkeepers. The object of the game is to score goals by kicking or heading the ball into the opponents' goal.", numComments: 150, user: "Daniel Li", rep: 1501, time: "21h", group: "Soccer", title: "What is Soccer?", picture: UIImage(named: "Me")!))
        data.append(Post(text: "A game played between two teams of five players in which goals are scored by throwing a ball through a netted hoop fixed above each end of the court.", numComments: 10, user: "Andrew Daley", rep: 3412, time: "10h", group: "Basketball", title: "What is Basketball?", picture: UIImage(named: "Me")!))
        data.append(Post(text: "I got no title bitches", numComments: 1401, user: "Edmund Lau", rep: -20, time: "1m", group: "Useless Info", title: nil, picture: UIImage(named: "Me")!))
        
        super.init(coder: aDecoder)
    }
    
    
    //********** Data Source **********
    
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
        cell.seeFullButton.tag = indexPath.section
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
        if post.rep >= 1000 {
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
    
    
    //********** Delegate **********
    
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
    
    
    //********** IBActions **********
    
    ///Expands Post for cell of sender
    @IBAction func seeFullPressed(sender: UIButton) {
        var post = data[sender.tag]
        if post.seeFull != nil {
            post.seeFull! = !post.seeFull!
        }
        tableView.reloadData()
    }
    
    ///Pushes to PostTableViewController when anywhere in cell is tapped
    @IBAction func tapPost(sender: UITapGestureRecognizer) {
        self.performSegueWithIdentifier("HomeToPost", sender: sender)
    }
    

    //********** Helper Functions **********
    
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
        thousands += Double(number % 1000 / 100) * 0.1
        return "\(thousands)k"
    }

}
