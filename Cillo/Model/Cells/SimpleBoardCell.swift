//
//  SimpleBoardCell.swift
//  Cillo
//
//  Created by Andrew Daley on 9/4/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

/// Cell that corresponds to reuse identifier "SimpleBoard".
///
/// Used to format Boards in OverlayBoardTableView.
class SimpleBoardCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    /// Displays name property of Board.
    @IBOutlet weak var nameLabel: UILabel!
    
    /// Displays picture property of Board.
    @IBOutlet weak var photoButton: UIButton!
    
    // MARK: Setup Helper Functions
    
    /// Makes this SimpleBoardCell's IBOutlets display the correct values of the corresponding Board.
    ///
    /// :param: board The corresponding Board to be displayed by this SimpleBoardCell.
    func makeFrom(board: Board) {
        
        nameLabel.text = board.name
        
        photoButton.isUserInteractionEnabled = false
        photoButton.clipsToBounds = true
        photoButton.layer.cornerRadius = 5.0
        if let url = board.photoURL {
            ImageLoadingManager.sharedInstance.downloadImageFrom(url: url) { image in
                DispatchQueue.main.async {
                    self.photoButton.setImage(image, for: UIControlState())
                }
            }
        }
    }
    
}
