//
//  SelectBoardOverlayView.swift
//  Cillo
//
//  Created by Andrew Daley on 9/4/15.
//  Copyright (c) 2015 Cillo. All rights reserved.
//

import UIKit

// MARK: - Protocols

/// Delegate for the overlay that allows the overlay to pass back a selected board and tell the previous controller when it is dismissed.
protocol SelectBoardOverlayViewDelegate {
  func overlay(overlay: SelectBoardOverlayView, selectedBoard board: Board)
  func overlayDismissed(overlay: SelectBoardOverlayView)
}

// MARK: - Classes

/// A presentable view that shows a popup table view allowing the end user to select a board from the boards that they follow.
class SelectBoardOverlayView: UIView {
  
  // MARK: Properties
  
  /// The UITableViewController that will be the centerpiece for this overlay. Controls the popup tableView.
  let tableController: BoardOverlayTableViewController
  
  /// The view that will blur the background surrounding the popup tableView.
  ///
  /// **Note:** This will only take effect in iOS 8.
  var blurView: UIVisualEffectView?
  
  /// The delegate that allows the overlay to pass back any selected board from the table.
  var delegate: SelectBoardOverlayViewDelegate?
  
  // MARK: Initializers
  
  override init(frame: CGRect) {
    tableController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(StoryboardIdentifiers.boardOverlay) as! BoardOverlayTableViewController
    tableController.tableView.frame = frame.rectByInsetting(dx: frame.width / 16, dy: frame.height / 4)
    tableController.tableView.layer.cornerRadius = 8.0
    super.init(frame: frame)
    tableController.delegate = self
    // ios 7 will just use this backgroundColor because there is no UIVisualEffectView
    backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.5)
    addSubview(tableController.tableView)
    bringSubviewToFront(tableController.tableView)
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissView:")
    gestureRecognizer.delegate = self
    addGestureRecognizer(gestureRecognizer)
  }
  
  /// **Warning:** Do not use this initializer.
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: Setup Helper Functions
  
  /// Animates the popup table to expand in the center of the screen.
  private func animateInnerFrame() {
    tableController.tableView.transform = CGAffineTransformMakeScale(0.1, 0.1)
    UIView.animateWithDuration(0.15, delay: 0, options: .CurveEaseOut,
      animations: {
        self.tableController.tableView.transform = CGAffineTransformIdentity
      },
      completion: nil
    )
  }
  
  /// Animates the blurView to fade in.
  private func animateBlur() {
    if objc_getClass("UIVisualEffectView") != nil {
      blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
      blurView!.frame = frame
      blurView!.autoresizingMask = .FlexibleWidth | .FlexibleHeight
      backgroundColor = UIColor.clearColor()
      blurView!.alpha = 0.0
      UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut,
        animations: {
          self.blurView!.alpha = 1.0
          self.addSubview(self.blurView!)
          self.bringSubviewToFront(self.tableController.tableView)
        },
        completion: nil
      )
    }
  }
  
  /// Presents the overlay as a subview with a popup animation into the provided view.
  ///
  /// :param: view The view that this overlay will be added as a subview to.
  func animateInto(view: UIView) {
    animateBlur()
    animateInnerFrame()
    view.addSubview(self)
    view.bringSubviewToFront(self)
  }
  
  /// Fades away the overlay and removes it from its superview.
  func animateOut() {
    alpha = 1.0
    UIView.animateWithDuration(0.15, delay: 0.0, options: .CurveEaseInOut,
      animations: {
        self.alpha = 0.0
      },
      completion: { _ in
        self.removeFromSuperview()
      }
    )
  }
  
  /// Dismisses the view when the `blurView` is touched.
  ///
  /// :param: sender The sender of this function is the tap gesture in the blurView.
  func dismissView(sender: UITapGestureRecognizer) {
    delegate?.overlayDismissed(self)
  }
}

// MARK: - BoardOverlayTableViewControllerDelegate

extension SelectBoardOverlayView: BoardOverlayTableViewControllerDelegate {
  
  /// Forwards the passed back board to the delegate of this class.
  ///
  /// :param: table The controller that is passing a board back to this overlay.
  /// :param: board The board that is being passed back.
  func overlayTableViewController(table: BoardOverlayTableViewController, didSelectBoard board: Board) {
    delegate?.overlay(self, selectedBoard: board)
  }
}

// MARK: UIGestureRecognizerDelegate

extension SelectBoardOverlayView: UIGestureRecognizerDelegate {

  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
    return touch.view == blurView || touch.view == self
  }
}
