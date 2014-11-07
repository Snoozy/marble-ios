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
    
    //MARK - IBOutlets
    
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var groupsButton: UIButton!
    @IBOutlet weak var postsSegControl: UISegmentedControl!
    @IBOutlet weak var postsTableView: UITableView!
    @IBOutlet weak var bioHeightConstraint: NSLayoutConstraint!
    
    
    //MARK - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        return section == 0 ? 0 : 10
    }
    
    //Makes divider inbetween cells blue
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view = UIView()
        view.backgroundColor = Format.cilloBlue()
        return view
    }
    
}
