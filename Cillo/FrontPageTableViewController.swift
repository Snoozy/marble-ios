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

class FrontPageTableViewController: UITableViewController {
    
    required init(coder aDecoder: NSCoder) {
        self.data = []
        data.append(Post(postText: "Iryna Yakovlevna Kyrylina (Ukrainian: Ірина Яківна Кириліна; born 23 March 1955) is a Ukrainian composer. She was born in Dresden, Germany, and studied with R.I. Vereschagin at the Kiev Musical College, and with M.V. Dremlyuga at the Kiev Conservatory, graduating in 1977. After completing her studies, she taught at a Kiev Music School and directed children’s choirs. Since 1982 she has worked as a full-time composer.Iryna Yakovlevna Kyrylina (Ukrainian: Ірина Яківна Кириліна; born 23 March 1955) is a Ukrainian composer. She was born in Dresden, Germany, and studied with R.I. Vereschagin at the Kiev Musical College, and with M.V. Dremlyuga at the Kiev Conservatory, graduating in 1977. After completing her studies, she taught at a Kiev Music School and directed children’s choirs. Since 1982 she has worked as a full-time composer.Iryna Yakovlevna Kyrylina (Ukrainian: Ірина Яківна Кириліна; born 23 March 1955) is a Ukrainian composer. She was born in Dresden, Germany, and studied with R.I. Vereschagin at the Kiev Musical College, and with M.V. Dremlyuga at the Kiev Conservatory, graduating in 1977. After completing her studies, she taught at a Kiev Music School and directed children’s choirs. Since 1982 she has worked as a full-time composer.Iryna Yakovlevna Kyrylina (Ukrainian: Ірина Яківна Кириліна; born 23 March 1955) is a Ukrainian composer. She was born in Dresden, Germany, and studied with R.I. Vereschagin at the Kiev Musical College, and with M.V. Dremlyuga at the Kiev Conservatory, graduating in 1977. After completing her studies, she taught at a Kiev Music School and directed children’s choirs. Since 1982 she has worked as a full-time composer.", comNum: 25, user: "user",rep: 4120, date: "12/1/1995", group: "group"))
               data.append(Post(postText: "MUCH SMALLER POST MUCH SMALLER POST MUCH SMALLER POST MUCH SMALLER POST MUCH SMALLER POST MUCH SMALLER POST MUCH SMALLER POST MUCH SMALLER POST MUCH SMALLER POST MUCH SMALLER POST MUCH SMALLER POST MUCH SMALLER POST MUCH SMALLER POST MUCH SMALLER POST MUCH SMALLER POST MUCH SMALLER POST MUCH SMALLER POST MUCH SMALLER POST MUCH SMALLER POST MUCH SMALLER POST ", comNum: 25, user: "user",rep: 4120, date: "12/1/1995", group: "group"))
        //        data.append(Post(postText: "IANDJLE.AAAnJkbuibasudibsabdiupbsaubdisabdipsbauidbsaibdispbadpibsaiudbisapbdisbadpibsapibdsipabdipsbaidbspabduipsabdpisbadpibsaupidbisabdibsapidbspiabdpsbadisbapidbsipabdipsbadipbsaipdbsipabdispabdiubsaidbsipabdisabdiupsbapdibsaibdpisabidpbsapidbspabdspiabdiuspabdiubsaidbsipabdpisabdipsbadiapbdisapbdipsabdipsbaipdbsaipdbsaibdsipabdipsabdiusabdibsaipdbsaiubdpisabiudsabidpsbaidbusapbdpsiabdpisabdpisabdipsuabdiusbaiudpbsaidbsipabduisabdiubsaipdbaiIANDJLE.AAAnJkbuibasudibsabdiupbsaubdisabdipsbauidbsaibdispbadpibsaiudbisapbdisbadpibsapibdsipabdipsbaidbspabduipsabdpisbadpibsaupidbisabdibsapidbspiabdpsbadisbapidbsipabdipsbadipbsaipdbsipabdispabdiubsaidbsipabdisabdiupsbapdibsaibdpisabidpbsapidbspabdspiabdiuspabdiubsaidbsipabdpisabdipsbadiapbdisapbdipsabdipsbaipdbsaipdbsaibdsipabdipsabdiusabdibsaipdbsaiubdpisabiudsabidpsbaidbusapbdpsiabdpisabdpisabdipsuabdiusbaiudpbsaidbsipabduisabdiubsaipdbaiIANDJLE.AAAnJkbuibasudibsabdiupbsaubdisabdipsbauidbsaibdispbadpibsaiudbisapbdisbadpibsapibdsipabdipsbaidbspabduipsabdpisbadpibsaupidbisabdibsapidbspiabdpsbadisbapidbsipabdipsbadipbsaipdbsipabdispabdiubsaidbsipabdisabdiupsbapdibsaibdpisabidpbsapidbspabdspiabdiuspabdiubsaidbsipabdpisabdipsbadiapbdisapbdipsabdipsbaipdbsaipdbsaibdsipabdipsabdiusabdibsaipdbsaiubdpisabiudsabidpsbaidbusapbdpsiabdpisabdpisabdipsuabdiusbaiudpbsaidbsipabduisabdiubsaipdbaiIANDJLE.AAAnJkbuibasudibsabdiupbsaubdisabdipsbauidbsaibdispbadpibsaiudbisapbdisbadpibsapibdsipabdipsbaidbspabduipsabdpisbadpibsaupidbisabdibsapidbspiabdpsbadisbapidbsipabdipsbadipbsaipdbsipabdispabdiubsaidbsipabdisabdiupsbapdibsaibdpisabidpbsapidbspabdspiabdiuspabdiubsaidbsipabdpisabdipsbadiapbdisapbdipsabdipsbaipdbsaipdbsaibdsipabdipsabdiusabdibsaipdbsaiubdpisabiudsabidpsbaidbusapbdpsiabdpisabdpisabdipsuabdiusbaiudpbsaidbsipabduisabdiubsaipdbaiIANDJLE.AAAnJkbuibasudibsabdiupbsaubdisabdipsbauidbsaibdispbadpibsaiudbisapbdisbadpibsapibdsipabdipsbaidbspabduipsabdpisbadpibsaupidbisabdibsapidbspiabdpsbadisbapidbsipabdipsbadipbsaipdbsipabdispabdiubsaidbsipabdisabdiupsbapdibsaibdpisabidpbsapidbspabdspiabdiuspabdiubsaidbsipabdpisabdipsbadiapbdisapbdipsabdipsbaipdbsaipdbsaibdsipabdipsabdiusabdibsaipdbsaiubdpisabiudsabidpsbaidbusapbdpsiabdpisabdpisabdipsuabdiusbaiudpbsaidbsipabduisabdiubsaipdbai", comNum: 25, user: "ADaley121",rep: 4120, date: "12/1/1995", group: "Ukraine"))
        //        data.append(Post(postText: "h M.V. Dremlyuga at the Kiev Conservatory, graduating in 1977. After completing her studies, she taught at a Kiev Music School and directed children’s choirs. Since 1982 she has worked as a full-time composer.", comNum: 25, user: "ADaley121", rep: 4120, date: "12/1/1995", group: "Ukraine"))
        //        data.append(Post(postText: "h M.V. Dremlyuga at the Kiev Conservatory, graduating in 1977. After completing her studies, she taught at a Kiev Music School and directed children’s choirs. Since 1982 she has worked as a full-time composer.", comNum: 25, user: "ADaley121", rep: 4120, date: "12/1/1995", group: "Ukraine"))
        super.init(coder: aDecoder)
    }

    var data : [Post]
    
    var maxHeight:CGFloat {
        return tableView.frame.height * 0.625 - PostCell.additionalVertSpaceNeeded
    }
    
    var prototypeTextViewWidth:CGFloat {
        return tableView.frame.width - 16
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    @IBAction func seeMorePressed(sender: UIButton) {
        var post = data[sender.tag]
//        println("Called")
        if post.seeMore {
            //fixes flashing arrow change bug
            sender.titleLabel!.text = "▼"
            //fixes permanent arrow look bug
            sender.setTitle("▼", forState:UIControlState.Normal)
        } else {
            sender.titleLabel!.text = "▲"
            sender.setTitle("▲", forState: UIControlState.Normal)
        }
        post.seeMore = !post.seeMore
        tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Post", forIndexPath: indexPath) as PostCell
        let post = data[indexPath.row]
        cell.seeMoreButton.tag = indexPath.row
        cell.postTextView.text = post.postText
        cell.postTextView.textContainer.lineFragmentPadding = 0
        cell.postTextView.textContainerInset = UIEdgeInsetsZero
//        println("Protoype Width: \(prototypeTextViewWidth)")
//        println("TextView Width: \(cell.postTextView.frame.size.width)")
//        println("Protoype Height: \(heightForTextOfRow(indexPath.row))")
//        println("TextView Height: \(cell.postTextView.frame.size.height)")
//        println("Max Height: \(maxHeight)")
        //short posts don't need to be expanded
        if heightForTextOfRow(indexPath.row) < maxHeight {
            cell.seeMoreButton.hidden = true
        } else {
            cell.seeMoreButton.hidden = false
        }
        cell.commentLabel.text = String(post.comNum)
        cell.repLabel.text = String(post.rep)
        cell.authorLabel.text = "Written on \(post.date) by \(post.user) in \(post.group)"
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return heightForTextOfRow(indexPath.row) + PostCell.additionalVertSpaceNeeded
    }
    
    func heightForTextOfRow(row: Int) -> CGFloat {
        var textView = UITextView(frame: CGRectMake(0, 0, prototypeTextViewWidth, CGFloat.max))
        let post = data[row]
        
        textView.text = (post.postText as NSString).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsetsZero
        textView.font = PostCell.textViewFont
        textView.frame.size = textView.sizeThatFits(CGSizeMake(prototypeTextViewWidth, CGFloat.max))
        if textView.frame.size.height > maxHeight && !post.seeMore {
            return maxHeight
        } else {
            return textView.frame.size.height
        }
    
    }

    //not using right now.... i disliked the look
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
