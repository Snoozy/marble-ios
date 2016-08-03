//
//  Votable.swift
//  Cillo
//
//  Created by Andrew Daley on 8/2/16.
//  Copyright © 2016 Cillo. All rights reserved.
//

import Foundation

/// Objects conforming to this protocol can be upvoted and downvoted.
protocol Votable {
    
    /// The voting status of the end user on this Votable object.
    ///
    /// * -1: This Votable object has been downvoted by the User.
    /// * 0: This Votable object has not been upvoted or downvoted by the User.
    /// * 1: This Votable object has been upvoted by the User.
    var voteValue: Int { get set }
    
    /// Reputation of this Votable object.
    ///
    /// Formula: Upvotes - Downvotes
    var rep: Int { get set }
}

extension Votable {
    
    /// Updates the Votable model to be downvoted.
    mutating func downvote() {
        switch voteValue {
        case 0:
            rep -= 1
        case 1:
            rep -= 2
        default:
            break
        }
        voteValue = -1
    }
    
    /// Updates the Votable model to be upvoted
    mutating func upvote() {
        switch voteValue {
        case 0:
            rep += 1
        case -1:
            rep += 2
        default:
            break
        }
        voteValue = 1
    }
}
