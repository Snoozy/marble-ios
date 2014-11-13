//
//  MeTableViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 11/13/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

class MeTableViewController: UITableViewController {

    //MARK: -  Properties
    
    var user: User = User()
    
    enum segIndex {
        case POSTS
        case COMMENTS
    }
    
    var cellsShown = segIndex.POSTS
    
    
    //MARK: - Constants
    
    var PROTOTYPE_TEXT_VIEW_WIDTH:CGFloat {return view.frame.size.width - 16}
    
    var MAX_CONTRACTED_HEIGHT:CGFloat {return tableView.frame.height * 0.625 - PostCell.ADDITIONAL_VERT_SPACE_NEEDED}

    
    //MARK: - UIViewController
    
    override func viewDidLoad() {
        
        var comment = Comment(user: "Andrew Daley", picture: UIImage(named: "Me")!, text: "hi", time: "1d", numComments: 0, rep: -1, lengthToPost: 1, comments: [])
        var comment2 = Comment(user: "Andrew Daley", picture: UIImage(named: "Me")!, text: "his", time: "1h", numComments: 0, rep: -2, lengthToPost: 1, comments: [])
        var post = Post(text: "Hi people", numComments: 2, user: "Andrew Daley", rep: 10, time: "2d", group: "Basketball", title: "Hello", picture: UIImage(named: "Me")!, comments: [comment, comment2])
        var post2 = Post(text: "Hi peoples", numComments: 0, user: "Andrew Daley", rep: 11, time: "2h", group: "Soccer", title: "Hellos", picture: UIImage(named: "Me")!, comments: [])
        comment.post = post
        comment2.post = post
        user = User(username: "Andrew Daley", accountname: "ADaley121", posts: [post, post2], comments: [comment, comment2], profilePic: UIImage(named: "Me")!, bio: "Hello, my name is Andrew Daley. I am widely regarded as the best human being on the planet. Thank you for visitng my page. Read my posts carefully, you might learn something.", numGroups: 20, rep: -3)
        
        //gets rid of Me Text on back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Bordered, target: nil, action: nil)
    }
    
    // MARK: - UITableViewDataSource

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

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("User", forIndexPath: indexPath) as UserCell
            cell.makeStandardUserCellFromUser(user)
            return cell
        } else {
            switch cellsShown {
            case .POSTS:
                let cell = tableView.dequeueReusableCellWithIdentifier("Post", forIndexPath: indexPath) as PostCell
                cell.makeStandardPostCellFromPost(user.posts[indexPath.section - 1], forIndexPath: indexPath)
                return cell
            case .COMMENTS:
                let cell = tableView.dequeueReusableCellWithIdentifier("Comment", forIndexPath: indexPath) as CommentCell
                cell.makeStandardCommentCellFromComment(user.comments[indexPath.section - 1], forIndexPath: indexPath, withSelected: false)
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
            return user.comments[indexPath.section - 1].heightOfCommentWithWidth(PROTOTYPE_TEXT_VIEW_WIDTH) + CommentCell.ADDITIONAL_VERT_SPACE_NEEDED - CommentCell.BUTTON_HEIGHT
        default:
            return 0
        }
    }
    
    //If cell is selected then go to post
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if indexPath.section != 0 {
           self.performSegueWithIdentifier("MeToPost", sender: indexPath)
        }
    }
    
    
    //MARK: - IBActions
    
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
    
    @IBAction func seeFullPressed(sender: UIButton) {
        var post = user.posts[sender.tag]
        if post.seeFull != nil {
            post.seeFull! = !post.seeFull!
        }
        tableView.reloadData()
    }
    
    
    //MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MeToPost" {
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
}
