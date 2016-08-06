//
//  Int64Ext.swift
//  Cillo
//
//  Created by Andrew Daley on 8/6/16.
//  Copyright © 2016 Cillo. All rights reserved.
//

import Foundation

extension Int64 {
    
    // MARK: - Properties
    
    /// Used to convert a large integer that represents milliseconds since epoch to a compact String.
    ///
    /// String is formatted in one of the following ways:
    ///
    /// * 1m - all times that are less than 2 minutes default to a 1m display time since creation
    /// * 15m - any time that is in the order of minutes
    /// * 3h - any time that is in the order of hours
    /// * 2y - any time that is in the order of years
    ///
    /// :param: time The time of an instance's creation in milliseconds since epoch.
    /// :returns: A readable String representing the time since the instance's creation.
    var compactTimeDisplay: String {
        let date = Date()
        let timeSince1970 = Int64(floor(date.timeIntervalSince1970 * 1000))
        let millisSincePost = timeSince1970 - self
        switch millisSincePost {
        case -1_000_000...59_999:
            return "1m"
        case 60_000...3_599_999:
            return "\(millisSincePost / 60_000)m"
        case 3_600_000...86_399_999:
            return "\(millisSincePost / 3_600_000)h"
        case 86_400_000...31_535_999_999:
            return "\(millisSincePost / 86_400_000)d"
        case 31_536_000_000..<Int64.max:
            return "\(millisSincePost / 31_536_000_000)y"
        default:
            return ""
        }
    }
}
