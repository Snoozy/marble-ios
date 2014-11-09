//
//  MeViewController.swift
//  Cillo
//
//  Created by Andrew Daley on 11/6/14.
//  Copyright (c) 2014 Cillo. All rights reserved.
//

import UIKit

class MeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var user: User = User()
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var groupsButton: UIButton!
    @IBOutlet weak var postsSegControl: UISegmentedControl!
    @IBOutlet weak var postsTableView: UITableView!
    @IBOutlet weak var bioHeightConstraint: NSLayoutConstraint!
    
    //MARK: - Constants
    
    var PROTOTYPE_TEXT_VIEW_WIDTH:CGFloat{return view.frame.size.width - 16}
    
    var MAX_CONTRACTED_HEIGHT:CGFloat{return max(postsTableView.frame.height * 0.625 - PostCell.ADDITIONAL_VERT_SPACE_NEEDED, 200)}
    
    var BIO_FONT:UIFont {return UIFont.systemFontOfSize(15.0)}
    
    
    //MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var post = Post(text: "Hi people", numComments: 0, user: "Andrew Daley", rep: 10, time: "2d", group: "Basketball", title: "Hello", picture: UIImage(named: "Me")!, comments: [])
        var post2 = Post(text: "Hi peoples", numComments: 0, user: "Andrew Daley", rep: 11, time: "2h", group: "Soccer", title: "Hellos", picture: UIImage(named: "Me")!, comments: [])
        var comment = Comment(user: "Andrew Daley", picture: UIImage(named: "Me")!, text: "hi", time: "1d", numComments: 0, rep: -1, lengthToPost: 1, comments: [])
        var comment2 = Comment(user: "Andrew Daley", picture: UIImage(named: "Me")!, text: "his", time: "1h", numComments: 0, rep: -2, lengthToPost: 1, comments: [])
        user = User(username: "Andrew Daley", posts: [post, post2], comments: [comment, comment2], profilePic: UIImage(named: "Me")!, bio: "hi people", numGroups: 20, rep: -3)
        profilePicView.image = user.profilePic
        userLabel.text = user.username
        bioTextView.text = user.bio
        bioTextView.font = BIO_FONT
        bioTextView.textContainer.lineFragmentPadding = 0
        bioTextView.textContainerInset = UIEdgeInsetsZero
        bioHeightConstraint.constant = user.heightOfBioWithWidth(PROTOTYPE_TEXT_VIEW_WIDTH)
        groupsButton.setTitle("\(user.numGroups) Groups", forState: UIControlState.Normal)
    }
    
    
    //MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if postsSegControl.selectedSegmentIndex == 0 { //postsTableView is displaying Posts
            return user.posts.count
        } else { //postsTableView is displaying Comments
            return user.comments.count
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if postsSegControl.selectedSegmentIndex == 0 {
            let cell = postsTableView.dequeueReusableCellWithIdentifier("Post", forIndexPath: indexPath) as PostCell
            
            cell.makeStandardPostCellFromPost(user.posts[indexPath.section], forIndexPath: indexPath)
            
            return cell
        } else {
            let cell = postsTableView.dequeueReusableCellWithIdentifier("Comment", forIndexPath: indexPath) as CommentCell
            
            cell.makeStandardCommentCellFromComment(user.comments[indexPath.section], forIndexPath: indexPath, withSelected: false)
            
            return cell
        }
    }
    
    //MARK: - UITableViewDelegate

    //Sets height of divider inbetween cells
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if postsSegControl.selectedSegmentIndex == 0 {
            return section == 0 ? 0 : 10
        } else {
            return section == 0 ? 0 : 5
        }
    }
    
    //Makes divider inbetween cells blue
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view = UIView()
        view.backgroundColor = Format.cilloBlue()
        return view
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if postsSegControl.selectedSegmentIndex == 0 {
            let post = user.posts[indexPath.section]
            let height = post.heightOfPostWithWidth(PROTOTYPE_TEXT_VIEW_WIDTH, andMaxContractedHeight: MAX_CONTRACTED_HEIGHT) + PostCell.ADDITIONAL_VERT_SPACE_NEEDED
            return post.title != nil ? height : height - PostCell.TITLE_HEIGHT
        }
        return user.comments[indexPath.section].heightOfCommentWithWidth(PROTOTYPE_TEXT_VIEW_WIDTH) + CommentCell.ADDITIONAL_VERT_SPACE_NEEDED - CommentCell.BUTTON_HEIGHT
    }
    
    //MARK: - IBActions
    
    @IBAction func valueChanged(sender: UISegmentedControl) {
        postsTableView.reloadData()
    }
    
    @IBAction func seeFullPressed(sender: UIButton) {
        var post = user.posts[sender.tag]
        if post.seeFull != nil {
            post.seeFull! = !post.seeFull!
        }
        postsTableView.reloadData()
    }
    
}