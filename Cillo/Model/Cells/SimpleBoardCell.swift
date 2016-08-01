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
  
  // MARK: IBOutlets

  /// Displays name property of Board.
  @IBOutlet weak var nameLabel: UILabel!
  
  /// Displays picture property of Board.
  @IBOutlet weak var photoButton: UIButton!
  
  // MARK: Constants
  
  /// Struct containing all relevent fonts for the elements of a SimpleBoardCell.
  struct SimpleBoardFonts {
    
    /// Font of the text contained within nameLabel.
    static let nameLabelFont = UIFont.boldSystemFont(ofSize: 20.0)
  }
  
  // MARK: Setup Helper Functions
  
  /// Makes this SimpleBoardCell's IBOutlets display the correct values of the corresponding Board.
  ///
  /// :param: board The corresponding Board to be displayed by this SimpleBoardCell.
  func makeCellFromBoard(_ board: Board) {
    
    nameLabel.font = SimpleBoardFonts.nameLabelFont
    nameLabel.text = board.name
    
    photoButton.isUserInteractionEnabled = false
    photoButton.setBackgroundImageToImageWithURL(board.photoURL, forState: UIControlState())
    photoButton.clipsToBounds = true
    photoButton.layer.cornerRadius = 5.0
  }

}
