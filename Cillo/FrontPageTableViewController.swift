//
//  FrontPageTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 10/23/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//


/********************
Known Bugs:
when see more button is pressed, arrow is changing directions and then chaning back for some reason
when view is expanded, it expands way too much
To Do: 
clean up code (a lot of the code may be redundent because I was trying to make things work)
********************/
import UIKit

class FrontPageTableViewController: UITableViewController {
    
    required init(coder aDecoder: NSCoder) {
        self.data = []
        super.init(coder: aDecoder)
    }

    var data : [Post]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //random posts
        data.append(Post(post: "Iryna Yakovlevna Kyrylina (Ukrainian: Ірина Яківна Кириліна; born 23 March 1955) is a Ukrainian composer. She was born in Dresden, Germany, and studied with R.I. Vereschagin at the Kiev Musical College, and with M.V. Dremlyuga at the Kiev Conservatory, graduating in 1977. After completing her studies, she taught at a Kiev Music School and directed children’s choirs. Since 1982 she has worked as a full-time composer.Iryna Yakovlevna Kyrylina (Ukrainian: Ірина Яківна Кириліна; born 23 March 1955) is a Ukrainian composer. She was born in Dresden, Germany, and studied with R.I. Vereschagin at the Kiev Musical College, and with M.V. Dremlyuga at the Kiev Conservatory, graduating in 1977. After completing her studies, she taught at a Kiev Music School and directed children’s choirs. Since 1982 she has worked as a full-time composer.Iryna Yakovlevna Kyrylina (Ukrainian: Ірина Яківна Кириліна; born 23 March 1955) is a Ukrainian composer. She was born in Dresden, Germany, and studied with R.I. Vereschagin at the Kiev Musical College, and with M.V. Dremlyuga at the Kiev Conservatory, graduating in 1977. After completing her studies, she taught at a Kiev Music School and directed children’s choirs. Since 1982 she has worked as a full-time composer.Iryna Yakovlevna Kyrylina (Ukrainian: Ірина Яківна Кириліна; born 23 March 1955) is a Ukrainian composer. She was born in Dresden, Germany, and studied with R.I. Vereschagin at the Kiev Musical College, and with M.V. Dremlyuga at the Kiev Conservatory, graduating in 1977. After completing her studies, she taught at a Kiev Music School and directed children’s choirs. Since 1982 she has worked as a full-time composer.", comNum: 25, user: "ADaley121", karma: 4120, date: "12/1/1995", group: "Ukraine"))
        data.append(Post(post: "h M.V. Dremlyuga at the Kiev Conservatory, graduating in 1977. After completing her studies, she taught at a Kiev Music School and directed children’s choirs. Since 1982 she has worked as a full-time composer.", comNum: 25, user: "ADaley121", karma: 4120, date: "12/1/1995", group: "Ukraine"))
        data.append(Post(post: "h M.V. Dremlyuga at the Kiev Conservatory, graduating in 1977. After completing her studies, she taught at a Kiev Music School and directed children’s choirs. Since 1982 she has worked as a full-time composer.", comNum: 25, user: "ADaley121", karma: 4120, date: "12/1/1995", group: "Ukraine"))
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    @IBAction func seeMorePressed(sender: UIButton) {
        tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return data.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Post", forIndexPath: indexPath) as PostCell
        let post = data[indexPath.row]
        cell.post = post
        if !post.seeMore {
            cell.seeMoreButton.titleLabel!.text = "▼"
        } else {
            cell.seeMoreButton.titleLabel!.text = "▲"
        }
        cell.postTextView.text = post.post
        cell.postTextView.frame = CGRectMake(cell.postTextView.frame.origin.x, cell.postTextView.frame.origin.y, tableView.frame.width - 16, heightForText(post.post, width: tableView.frame.width - 16, font: PostCell.textViewFont, seeMore: post.seeMore))
        if cell.postTextView.frame.height < tableView.frame.height * 0.625 - PostCell.additionalVertSpaceNeeded {
            cell.seeMoreButton.hidden = true
        }
        if post.comNum < 100000 { //not sure if I like the k yet
            cell.commentLabel.text = String(post.comNum)
        }
        else {
            cell.commentLabel.text = convertToThousands(post.comNum)
        }
        if post.karma < 100000 {//not sure if I like the k yet
            cell.repLabel.text = String(post.karma)
        } else {
            cell.repLabel.text = convertToThousands(post.karma)
        }
        cell.authorLabel.text = "Written on \(post.date) by \(post.user) in \(post.group)"
        

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = data[indexPath.row]
        return heightForText(post.post, width: tableView.frame.width - 16, font: PostCell.textViewFont, seeMore: post.seeMore) + PostCell.additionalVertSpaceNeeded
    }
    
    func heightForText(text: String, width: CGFloat, font: UIFont, seeMore: Bool) -> CGFloat {
        let maxHeight = tableView.frame.height * 0.625 - PostCell.additionalVertSpaceNeeded
        var textView = UITextView(frame: CGRectMake(0, 0, width, maxHeight))
        textView.text = text
        textView.font = font
        textView.sizeToFit()
        if textView.frame.height > maxHeight && !seeMore {
            return maxHeight
        } else {
            return textView.frame.height
        }
        
    }

    func convertToThousands(number: Int) -> String {
        var thousands : Double = Double(number % 1000)
        thousands += 0.001 * (Double(number) - thousands * 1000)
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
