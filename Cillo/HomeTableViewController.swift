//
//  FrontPageTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 10/23/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//


/********************
Known Bugs:
when view is expanded, it expands way too much
To Do: 
clean up code (a lot of the code may be redundent because I was trying to make things work)
********************/
import UIKit

class HomeTableViewController: UITableViewController {

    var data : [Post]
    
    var prototypeTextViewWidth:CGFloat {
        //margins are 16
        return tableView.frame.width - 16
    }
    
    required init(coder aDecoder: NSCoder) {
        self.data = []
        //initialize posts
        data.append(Post(text: "A game played by two teams of eleven players with a round ball that may not be touched with the hands or arms during play except by the goalkeepers. The object of the game is to score goals by kicking or heading the ball into the opponents' goal.", numComments: 150, user: "Daniel Li", rep: 1501, time: "21h", group: "Soccer", title: "What is Soccer?", picture: UIImage(named: "Me")!))
        data.append(Post(text: "A game played between two teams of five players in which goals are scored by throwing a ball through a netted hoop fixed above each end of the court.", numComments: 10, user: "Andrew Daley", rep: 3412, time: "10h", group: "Basketball", title: "What is Basketball?", picture: UIImage(named: "Me")!))
        data.append(Post(text: "I got no title bitches", numComments: 1401, user: "Edmund Lau", rep: -20, time: "1m", group: "Useless Info", title: nil, picture: UIImage(named: "Me")!))
        super.init(coder: aDecoder)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
/**
SEE MORE TEMPORARILY REMOVED
**/
    
//    @IBAction func seeMorePressed(sender: UIButton) {
//        var post = data[sender.tag]
////        println("Called")
//        if post.seeMore {
//            //fixes flashing arrow change bug
//            sender.titleLabel!.text = "▼"
//            //fixes permanent arrow look bug
//            sender.setTitle("▼", forState:UIControlState.Normal)
//        } else {
//            sender.titleLabel!.text = "▲"
//            sender.setTitle("▲", forState: UIControlState.Normal)
//        }
//        post.seeMore = !post.seeMore
//        tableView.reloadData()
//    }
    
//    var maxHeight:CGFloat {
//        return tableView.frame.height * 0.625 - PostCell.additionalVertSpaceNeeded
//    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return data.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Post", forIndexPath: indexPath) as PostCell
        let post = data[indexPath.section]
        
        cell.postTextView.text = post.text
        cell.postTextView.font = PostCell.textViewFont
        cell.postTextView.textContainer.lineFragmentPadding = 0
        cell.postTextView.textContainerInset = UIEdgeInsetsZero
        
        //SEE MORE TEMPORARILY REMOVED
//        cell.seeMoreButton.tag = indexPath.row
//        //short posts don't need to be expanded
//        if heightForTextOfRow(indexPath.row) < maxHeight {
//            cell.seeMoreButton.hidden = true
//        } else {
//            cell.seeMoreButton.hidden = false
//        }
        
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
        
        cell.userLabel.text = post.user
        cell.groupLabel.text = post.group
        
        if let t = post.title {
            cell.titleLabel.text = t
        } else {
            cell.titleLabel.text = ""
            cell.titleLabel.frame.size = CGSizeMake(cell.titleLabel.frame.size.width, 0)
        }
        
        cell.profilePicView.image = post.picture
        cell.timeLabel.text = post.time
        
//        cell.layer.cornerRadius = 5.0
//        cell.layer.masksToBounds = true
//        cell.layer.borderWidth = 4.0
//        var color = UIColor(red: 0.0627, green: 0.396, blue: 0.768, alpha: 0.87)
//        cell.layer.borderColor = color.CGColor
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return section == 0 ? 0 : 10
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view = UIView()
        view.backgroundColor = UIColor(red: 0.0627, green: 0.396, blue: 0.768, alpha: 0.87)
        return view
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if data[indexPath.section].title != nil {
           return heightForTextOfRow(indexPath.section) + PostCell.additionalVertSpaceNeeded
        }
        return heightForTextOfRow(indexPath.section) + PostCell.additionalVertSpaceNeeded - PostCell.titleHeight
    }
    
    func heightForTextOfRow(row: Int) -> CGFloat {
        var textView = UITextView(frame: CGRectMake(0, 0, prototypeTextViewWidth, CGFloat.max))
        let post = data[row]
        
        textView.text = post.text
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsetsZero
        textView.font = PostCell.textViewFont
        textView.sizeToFit()
        return textView.frame.size.height
    
        //SEE MORE TEMPORARILY REMOVED
//        if textView.frame.size.height > maxHeight && !post.seeMore {
//            return maxHeight
//        } else {
//            return textView.frame.size.height
//        }
    
    }

    func convertToThousands(number: Int) -> String {
        var thousands : Double = Double(number / 1000)
        thousands += Double(number % 1000 / 100) * 0.1
        return "\(thousands)k"
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
