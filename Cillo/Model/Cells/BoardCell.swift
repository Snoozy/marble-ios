//
//  BoardCell.swift
//  Cillo
//
//  Created by Andrew Daley on 11/25/14.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Cell that corresponds to reuse identifier "Board".
///
/// Used to format Boards in UITableView.
class BoardCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    /// Displays descrip property of Board.
    ///
    /// Height of this UITextView is calulated by heightOfDescripWithWidth(_:) in Board.
    @IBOutlet weak var descripAttributedLabel: TTTAttributedLabel!
    
    /// Follows or unfollows Board.
    @IBOutlet weak var followButton: UIButton!
    
    /// Displays numFollowers property of Board.
    ///
    /// Text should display a bolded numFollowers value followed by an unbolded " MEMBERS".
    ///
    /// **Note:** Use NSMutableAttributedString.twoFontString(firstHalf:firstFont:secondHalf:secondFont:) to format text properly.
    @IBOutlet weak var followersLabel: UILabel!
    
    /// Displays name property of Board.
    @IBOutlet weak var nameButton: UIButton!
    
    /// Displays picture property of Board.
    @IBOutlet weak var photoButton: UIButton!
    
    // MARK: - Constants
    
    
    /// Font used for the word " MEMBERS" in followersLabel.
    private let followerLabelFont = UIFont.systemFont(ofSize: 12.0)
    
    /// Font used for the followerCount value in followersLabel.
    private let followerCountFont = UIFont.boldSystemFont(ofSize: 14.0)
    
    /// Color of the border of `followButton`. Also is the color of the background when the button is filled (signifying that the user is following already).
    private let followButtonColor = UIColor.gray
    
    // MARK: - UITableViewCell
    
    override func prepareForReuse() {
        nameButton.setTitleWithoutAnimation("")
    }
    
    // MARK: - Setup Helper Functions
    
    /// Assigns all delegates of cell to the given parameter.
    ///
    /// :param: delegate The delegate that will be assigned to elements of the cell pertaining to the required protocols specified in the function header.
    func assignDelegatesForCellTo<T: UIViewController where T: TTTAttributedLabelDelegate>(_ delegate: T) {
        descripAttributedLabel.delegate = delegate
    }
    
    /// Makes this BoardCell's IBOutlets display the correct values of the corresponding Board.
    ///
    /// :param: board The corresponding Board to be displayed by this BoardCell.
    func makeFrom(board: Board) {
        let scheme = ColorScheme.defaultScheme
        
        nameButton.setTitleWithoutAnimation(board.name)
        
        photoButton.clipsToBounds = true
        photoButton.layer.cornerRadius = 5.0
        if let url = board.photoURL {
            ImageLoadingManager.sharedInstance.downloadImageFrom(url: url) { image in
                DispatchQueue.main.async {
                    self.photoButton.setImage(image, for: UIControlState())
                }
            }
        }
        
        descripAttributedLabel.setupFor(board.descrip)
        
        followButton.setupWithRoundedBorderOfWidth(UIButton.standardBorderWidth,
                                                   andColor: followButtonColor)
        if !board.following {
            followButton.setTitle("Join", for: UIControlState())
            followButton.setTitleColor(UIColor.lighterBlack, for: UIControlState())
            followButton.backgroundColor = UIColor.white
        } else {
            followButton.setTitle("Joined", for: UIControlState())
            followButton.setTitleColor(UIColor.white, for: UIControlState())
            followButton.backgroundColor = followButtonColor
        }
        
        // Make only the number in followersLabel bold
        let followersString = board.followerCount == 1 ? " MEMBER" : " MEMBERS"
        let followersText = NSMutableAttributedString.twoFontString(firstHalf: board.followerCount.fiveCharacterDisplay,
                                                                    firstFont: followerCountFont,
                                                                    secondHalf: followersString,
                                                                    secondFont: followerLabelFont)
        followersLabel.attributedText = followersText
        
    }
    
}
