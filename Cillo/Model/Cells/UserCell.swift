//
//  UserCell.swift
//  Cillo
//
//  Created by Andrew Daley on 11/13/14.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Cell that corresponds to reuse identifier "User".
///
/// Used to format Users in UITableView.
class UserCell: UITableViewCell {
    
    // MARK: IBOutlets
    
    /// Displays bio property of User.
    ///
    /// Height of this UITextView is calulated by heightOfBioWithWidth(_:) in User.
    @IBOutlet weak var bioAttributedLabel: TTTAttributedLabel!
    
    /// Displays numBoards propert of User.
    ///
    /// Text should display a bolded numBoards value followed by an unbolded " GROUPS".
    ///
    /// **Note:** Use NSMutableAttributedString.twoFontString(firstHalf:firstFont:secondHalf:secondFont:) to format text properly.
    @IBOutlet weak var boardsButton: UIButton!
    
    /// Displays name property of User.
    @IBOutlet weak var nameButton: UIButton!
    
    /// Displays profilePic property of User.
    @IBOutlet weak var photoButton: UIButton!
    
    /// Displays rep property of User.
    ///
    /// Text should display a bolded rep value followed by an unbolded " REP".
    ///
    /// **Note:** Use NSMutableAttributedString.twoFontString(firstHalf:firstFont:secondHalf:secondFont:) to format text properly.
    @IBOutlet weak var repLabel: UILabel!
    
    /// Displays username property of User.
    @IBOutlet weak var usernameButton: UIButton!
    
    // MARK: - Constants
    
    /// Font used for the word " BOARDS" in boardsButton.
    private let boardsButtonFont = UIFont.systemFont(ofSize: 15.0)
    
    /// Font used for the boardCount value in boardsButton.
    private let boardsCountFont = UIFont.boldSystemFont(ofSize: 18.0)
    
    /// Font used for the word " REP" in repLabel.
    private let repLabelFont = UIFont.systemFont(ofSize: 15.0)
    
    /// Font used for the rep value in repLabel.
    private let repCountFont = UIFont.boldSystemFont(ofSize: 18.0)
    
    // MARK: - Setup Helper Functions
    
    /// Assigns all delegates of cell to the given parameter.
    ///
    /// :param: delegate The delegate that will be assigned to elements of the cell pertaining to the required protocols specified in the function header.
    func assignDelegatesForCellTo<T: UIViewController where T: TTTAttributedLabelDelegate>(_ delegate: T) {
        bioAttributedLabel.delegate = delegate
    }
    
    /// Makes this UserCell's IBOutlets display the correct values of the corresponding User.
    ///
    /// :param: user The corresponding User to be displayed by this UserCell.
    func makeFrom(user: User) {
        let scheme = ColorScheme.defaultScheme
        
        nameButton.setTitle(user.name, for: UIControlState())
        usernameButton.setTitle(user.usernameDisplay, for: UIControlState())
        
        photoButton.clipsToBounds = true
        photoButton.layer.cornerRadius = 5.0
        if let url = user.photoURL {
            ImageLoadingManager.sharedInstance.downloadImageFrom(url: url) { image in
                DispatchQueue.main.async {
                    self.photoButton.setImage(image, for: UIControlState())
                }
            }
        }
        
        bioAttributedLabel.setupFrom(user.bio)
        
        if user.isSelf {
            nameButton.setTitleColor(scheme.meTextColor(), for: UIControlState())
        } else {
            nameButton.setTitleColor(UIColor.darkText, for: UIControlState())
        }
        
        // Make only the number in repLabel bold
        let repText = NSMutableAttributedString.twoFontString(firstHalf: user.rep.fiveCharacterDisplay,
                                                              firstFont: repCountFont,
                                                              secondHalf: " REP",
                                                              secondFont: repLabelFont)
        repLabel.attributedText = repText
        
        // Make only the number in boardsButton bold
        let boardString = user.boardCount == 1 ? " BOARD" : " BOARDS"
        let boardsText = NSMutableAttributedString.twoFontString(firstHalf: user.boardCount.fiveCharacterDisplay,
                                                                 firstFont: boardsCountFont,
                                                                 secondHalf: boardString,
                                                                 secondFont: boardsButtonFont)
        boardsButton.setAttributedTitle(boardsText, forState: .Normal)
        boardsButton.tintColor = UIColor.darkText
    }
    
}
