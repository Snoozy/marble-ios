//
//  MultiplePostsTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 12/18/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

///Inherit this class for any TVC that is only a table of PostCells
///Note: must override SEGUE_IDENTIFIER_THIS_TO_POST
class MultiplePostsTableViewController: UITableViewController {

    // MARK: - Properties
    
    ///Stores list of all posts retrieved from JSON
    var posts : [Post] = []
    
    
    // MARK: - Constants
    
    ///Segue Identifier in Storyboard for this VC to PostTableViewController
    ///Note: Subclasses must override
    var SEGUE_IDENTIFIER_THIS_TO_POST : String {return ""}
    
    
    //MARK: - UIViewController
    
    ///Transfer selected Post to PostTableViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SEGUE_IDENTIFIER_THIS_TO_POST {
            var destination = segue.destinationViewController as PostTableViewController
            if sender is UIButton {
                destination.post = posts[(sender as UIButton).tag]
            } else if sender is NSIndexPath {
                destination.post = posts[(sender as NSIndexPath).section]
            }
        }
    }
    
    
    //MARK: - UITableViewDataSource
    
    //Assigns the number of sections to length of posts array
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return posts.count
    }
    
    //Assigns 1 row to each section
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //Creates PostCell with appropriate properties for Post at given section in posts
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PostCell.REUSE_IDENTIFIER, forIndexPath: indexPath) as PostCell
        let post = posts[indexPath.section]
        
        cell.makeCellFromPost(post, withButtonTag: indexPath.section)
        
        return cell
    }
    
    
    //MARK: - UITableViewDelegate
    
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
    
    //Sets height of cell to appropriate value depending on length of post and whether post is expanded
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = posts[indexPath.section]
        let height = post.heightOfPostWithWidth(PROTOTYPE_TEXT_VIEW_WIDTH, andMaxContractedHeight: MAX_CONTRACTED_HEIGHT) + PostCell.ADDITIONAL_VERT_SPACE_NEEDED
        return post.title != nil ? height : height - PostCell.TITLE_HEIGHT
    }
    
    //If cell is selected then go to post
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier(SEGUE_IDENTIFIER_THIS_TO_POST, sender: indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    
    //MARK: - IBActions
    
    ///Expands post in PostCell of sender when seeFullButton is pressed
    @IBAction func seeFullPressed(sender: UIButton) {
        var post = posts[sender.tag]
        if post.seeFull != nil {
            post.seeFull! = !post.seeFull!
        }
        tableView.reloadData()
    }

}
