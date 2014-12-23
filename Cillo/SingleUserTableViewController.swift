//
//  SingleUserTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 12/19/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

///Inherit this class for any TVC that is a UserCell followed by PostCells and CommentCells
///Note: must override SEGUE_IDENTIFIER_THIS_TO_POST
class SingleUserTableViewController: UITableViewController {
    
    //MARK: -  Properties
    
    ///User for this ViewController
    var user: User = User()
    
    ///Corresponds to segmentIndex of postsSegControl in UserCell
    var cellsShown = UserCell.segIndex.POSTS
    
    
    //MARK: - Constants
    
    var SEGUE_IDENTIFIER_THIS_TO_POST : String {return ""}
    
    
    //MARK: - UIViewController
    
    ///Transfer selected Post to PostTableViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SEGUE_IDENTIFIER_THIS_TO_POST {
            var destination = segue.destinationViewController as PostTableViewController
            switch cellsShown {
            case .POSTS:
                if sender is UIButton {
                    destination.post = user.posts[(sender as UIButton).tag - 1]
                } else if sender is NSIndexPath {
                    destination.post = user.posts[(sender as NSIndexPath).section - 1]
                }
            case .COMMENTS:
                if sender is NSIndexPath {
                    destination.post = user.comments[(sender as NSIndexPath).section - 1].post
                }
            default:
                break
            }
        }
    }
    
    
    // MARK: - UITableViewDataSource
    
    //Assigns number of sections based on the length of the User array corresponding to cellsShown
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        switch cellsShown {
        case .POSTS:
            return 1 + user.posts.count
        case .COMMENTS:
            return 1 + user.comments.count
        default:
            return 1
        }
    }
    
    //Assigns 1 row to each section
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //Creates UserCell, PostCell, or CommentCell based on section # and value of cellsShown
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(UserCell.REUSE_IDENTIFIER, forIndexPath: indexPath) as UserCell
            cell.makeCellFromUser(user)
            return cell
        } else {
            switch cellsShown {
            case .POSTS:
                let cell = tableView.dequeueReusableCellWithIdentifier(PostCell.REUSE_IDENTIFIER, forIndexPath: indexPath) as PostCell
                cell.makeCellFromPost(user.posts[indexPath.section - 1], withButtonTag: indexPath.section)
                return cell
            case .COMMENTS:
                let cell = tableView.dequeueReusableCellWithIdentifier(CommentCell.REUSE_IDENTIFIER, forIndexPath: indexPath) as CommentCell
                cell.makeCellFromComment(user.comments[indexPath.section - 1], withSelected: false)
                return cell
            default:
                return UITableViewCell()
            }
        }
    }
    
    //MARK: - UITableViewDelegate
    
    //Sets height of divider inbetween cells
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {return 0}
        switch cellsShown {
        case .POSTS:
            return 10
        case .COMMENTS:
            return 5
        default:
            return 0
        }
    }
    
    //Makes divider inbetween cells blue
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view = UIView()
        view.backgroundColor = UIColor.cilloBlue()
        return view
    }
    
    //Sets height of cell to appropriate value based on value of cellsShown
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return user.heightOfBioWithWidth(PROTOTYPE_TEXT_VIEW_WIDTH) + UserCell.ADDITIONAL_VERT_SPACE_NEEDED
        }
        switch cellsShown {
        case .POSTS:
            let post = user.posts[indexPath.section - 1]
            let height = post.heightOfPostWithWidth(PROTOTYPE_TEXT_VIEW_WIDTH, andMaxContractedHeight: MAX_CONTRACTED_HEIGHT) + PostCell.ADDITIONAL_VERT_SPACE_NEEDED
            return post.title != nil ? height : height - PostCell.TITLE_HEIGHT
        case .COMMENTS:
            return user.comments[indexPath.section - 1].heightOfCommentWithWidth(PROTOTYPE_TEXT_VIEW_WIDTH, withSelected: false) + CommentCell.ADDITIONAL_VERT_SPACE_NEEDED - CommentCell.BUTTON_HEIGHT
        default:
            return 0
        }
    }
    
    //Sends to PostTableViewController if CommentCell or PostCell is selected
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if indexPath.section != 0 {
            self.performSegueWithIdentifier(SEGUE_IDENTIFIER_THIS_TO_POST, sender: indexPath)
        }
    }
    
    
    //MARK: - IBActions
    
    ///Update cellsShown when the postsSegControl in UserCell changes its selectedIndex
    @IBAction func valueChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            cellsShown = .POSTS
        case 1:
            cellsShown = .COMMENTS
        default:
            break
        }
        tableView.reloadData()
    }
    
    ///Expand post in PostCell of sender when seeFullButton is pressed
    @IBAction func seeFullPressed(sender: UIButton) {
        var post = user.posts[sender.tag]
        if post.seeFull != nil {
            post.seeFull! = !post.seeFull!
        }
        tableView.reloadData()
    }

}
